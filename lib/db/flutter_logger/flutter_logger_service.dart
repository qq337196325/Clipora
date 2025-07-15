import 'dart:async';

import 'package:isar/isar.dart';
import 'package:get/get.dart';

import '../../basics/logger.dart';
import '../../basics/utils/user_utils.dart';
import '../../api/user_api.dart';
import '../database_service.dart';
import 'flutter_logger_db.dart';


class FlutterLoggerService extends GetxService {
  static FlutterLoggerService get instance => Get.find<FlutterLoggerService>();

  final DatabaseService _dbService = DatabaseService.instance;
  Timer? _uploadTimer;

  @override
  void onInit() {
    super.onInit();
    // Start the timer when the service is initialized
    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndUploadLogs();
    });
  }

  @override
  void onClose() {
    _uploadTimer?.cancel(); // Cancel the timer when the service is closed
    super.onClose();
  }

  /// Check for pending logs and upload them.
  Future<void> _checkAndUploadLogs() async {
    final pendingLogs = await getPendingLogs();
    if (pendingLogs.isNotEmpty) {
      // Limit batch size to avoid overwhelming the server
      const batchSize = 50;
      final logsToUpload = pendingLogs.take(batchSize).toList();
      
      getLogger().i('发现 ${pendingLogs.length} 条待上传日志，准备上传前 ${logsToUpload.length} 条...');
      await _uploadLogs(logsToUpload);
      
      // Clean up old uploaded logs periodically
      await cleanUploadedLogs();
    }
  }

  /// Upload logs to the server with retry mechanism.
  Future<void> _uploadLogs(List<FlutterLogger> logs) async {
    if (logs.isEmpty) return;

    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Convert logs to API format
        final apiData = _convertLogsToApiFormat(logs);
        
        getLogger().i('开始上传 ${logs.length} 条日志到服务器... (尝试 ${retryCount + 1}/$maxRetries)');
        
        // Call the API
        final response = await UserApi.createFlutterLoggerApi(apiData);
        
        // Check if upload was successful
        if (response['code'] == 0) {
          // After successful upload, delete the logs from the local database.
          final logIds = logs.map((e) => e.id).toList();
          await _deleteLogs(logIds);
          getLogger().i('✅ 成功上传并清除了 ${logs.length} 条日志');
          return; // Success, exit retry loop
        } else {
          final errorMsg = response['message'] ?? response['msg'] ?? 'Unknown error';
          getLogger().e('❌ 服务器返回错误: $errorMsg');
          throw Exception('Server error: $errorMsg');
        }

      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          getLogger().e('❌ 上传日志最终失败，已重试 $maxRetries 次: $e');
          // Mark logs with failed upload attempt for debugging
          await _markLogsWithFailure(logs, e.toString());
          return;
        } else {
          getLogger().w('⚠️ 上传日志失败，将重试 (${retryCount}/$maxRetries): $e');
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      }
    }
  }

  /// Mark logs with failure information for debugging purposes.
  Future<void> _markLogsWithFailure(List<FlutterLogger> logs, String errorInfo) async {
    try {
      await _dbService.isar.writeTxn(() async {
        for (final log in logs) {
          final updatedLog = log;
          updatedLog.errorMessage = '${log.errorMessage} [Upload Failed: $errorInfo]';
          await _dbService.isar.flutterLoggers.put(updatedLog);
        }
      });
    } catch (e) {
      getLogger().e('❌ 标记日志上传失败状态时出错: $e');
    }
  }

  /// Convert FlutterLogger list to API format
  Map<String, dynamic> _convertLogsToApiFormat(List<FlutterLogger> logs) {
    final List<Map<String, dynamic>> data = logs.map((log) {
      return {
        'user_id': log.userId,
        'message': log.message,
        'lines_message': log.linesMessage,
        'error_message': log.errorMessage,
        'error_level': log.errorLevel,
        'client_create_time': log.createdAt.millisecondsSinceEpoch ~/ 1000,
      };
    }).toList();

    return {
      'data': data,
    };
  }

  /// Delete logs by their IDs.
  Future<void> _deleteLogs(List<int> logIds) async {
    try {
      await _dbService.isar.writeTxn(() async {
        await _dbService.isar.flutterLoggers.deleteAll(logIds);
      });
    } catch (e) {
      getLogger().e('❌ 删除日志失败: $e');
    }
  }


  /// 保存日志到数据库
  Future<void> saveLog({
    required String level,
    required String message,
    String? errorMessage,
    String? linesMessage,
  }) async {
    try {
      final log = FlutterLogger()
        ..userId = getUserId()
        ..message = message
        ..linesMessage = linesMessage ?? ''
        ..errorMessage = errorMessage ?? ''
        ..errorLevel = level
        ..isUpdateService = false
        ..createdAt = DateTime.now();

      await _dbService.isar.writeTxn(() async {
        await _dbService.isar.flutterLoggers.put(log);
      });
    } catch (e) {
      // getLogger().e('❌ 保存日志到数据库失败: $e');
    }
  }


  /// 获取待上传的日志
  Future<List<FlutterLogger>> getPendingLogs() async {
    try {
      return await _dbService.isar.flutterLoggers
          .where()
          .userIdEqualTo(getUserId())
          .filter()
          .isUpdateServiceEqualTo(false)
          .sortByCreatedAt()
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取待上传日志失败: $e');
      return [];
    }
  }

  /// 标记日志为已上传
  Future<void> markLogAsUploaded(int logId) async {
    try {
      await _dbService.isar.writeTxn(() async {
        final log = await _dbService.isar.flutterLoggers.get(logId);
        if (log != null) {
          log.isUpdateService = true;
          await _dbService.isar.flutterLoggers.put(log);
        }
      });
    } catch (e) {
      getLogger().e('❌ 标记日志为已上传失败: $e');
    }
  }

  /// 清理已上传的日志（保留最近7天）
  Future<void> cleanUploadedLogs() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final logsToDelete = await _dbService.isar.flutterLoggers
          .where()
          .userIdEqualTo(getUserId())
          .filter()
          .isUpdateServiceEqualTo(true)
          .and()
          .createdAtLessThan(sevenDaysAgo)
          .findAll();

      if (logsToDelete.isNotEmpty) {
        await _dbService.isar.writeTxn(() async {
          await _dbService.isar.flutterLoggers.deleteAll(logsToDelete.map((e) => e.id).toList());
        });
        getLogger().i('🧹 清理了 ${logsToDelete.length} 条已上传的日志');
      }
    } catch (e) {
      getLogger().e('❌ 清理已上传日志失败: $e');
    }
  }

  /// 手动触发日志上传
  Future<void> uploadLogsNow() async {
    getLogger().i('📤 手动触发日志上传...');
    await _checkAndUploadLogs();
  }

}
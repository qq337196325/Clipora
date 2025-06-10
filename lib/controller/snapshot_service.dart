import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../basics/logger.dart';
import '../db/article/article_db.dart';
import '../db/article/article_service.dart';
import '../api/user_api.dart';

enum SnapshotType {
  mhtml,
  html,
}

class SnapshotResult {
  final String? filePath;
  final SnapshotType type;
  final bool success;
  final String? error;

  SnapshotResult({
    this.filePath,
    required this.type,
    required this.success,
    this.error,
  });
}

class SnapshotService extends GetxService {
  static SnapshotService get instance => Get.find<SnapshotService>();
  Timer? _snapshotTimer;
  bool _isProcessing = false; // 防止任务重叠

  @override
  void onInit() {
    super.onInit();
    getLogger().i('SnapshotService onInit');
    _initializePermissions();
    // 每1分钟检查一次是否有需要生成快照的文章
    _snapshotTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      getLogger().i('⏰ 定时快照任务触发');
      processUnsnapshottedArticles();
    });
    // 应用启动30秒后也执行一次
    // Future.delayed(const Duration(seconds: 5), () => processUnsnapshottedArticles());
  }

  @override
  void onClose() {
    _snapshotTimer?.cancel();
    super.onClose();
    getLogger().i('SnapshotService onClose');
  }

  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.storage.request();
      getLogger().i('存储权限状态: $status');
    } catch (e) {
      getLogger().e('❌ 请求存储权限失败: $e');
    }
  }

  Future<void> processUnsnapshottedArticles() async {
    if (_isProcessing) {
      getLogger().i('🔄 快照任务正在处理中，跳过此次触发。');
      return;
    }
    _isProcessing = true;

    try {
      getLogger().i('🔄 开始执行快照生成任务...');
      final articlesToProcess = await ArticleService.instance.getUnsnapshottedArticles();

      if (articlesToProcess.isEmpty) {
        getLogger().i('✅ 没有需要生成快照的文章。');
        return;
      }

      getLogger().i('发现 ${articlesToProcess.length} 篇文章需要生成快照，开始处理...');
      for (final article in articlesToProcess) {

        // 一次只处理一个，避免过多资源消耗
        await _generateAndUploadSnapshot(article);
        // 添加间隔，避免资源冲突
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      getLogger().e('❌ 执行快照任务时出错: $e');
    } finally {
      _isProcessing = false;
      getLogger().i('✅ 快照生成任务执行完毕。');
    }
  }

  Future<void> _generateAndUploadSnapshot(ArticleDb article) async {
    if (article.url.isEmpty) {
      getLogger().w('⚠️ 文章 "${article.title}" URL为空，无法生成快照。');
      return;
    }

    getLogger().i('🔄 开始为文章 "${article.title}" 生成快照...');
    
    // 尝试多种快照方式
    SnapshotResult? result;
    
    // 1. 首先尝试MHTML
    result = await _tryMhtmlSnapshot(article);
    
    if (!result.success) {
      getLogger().w('⚠️ MHTML快照失败，尝试HTML内容保存...');
      // 2. 尝试保存HTML内容
      result = await _tryHtmlSnapshot(article);
    }

    if (result.success && result.filePath != null) {
      getLogger().i('✅ 快照已生成 (${result.type.name}): ${result.filePath}');
      
      // 调用上传服务器的逻辑
      final uploadSuccess = await uploadSnapshotToServer(result.filePath!);
      if (uploadSuccess) {
        // 更新数据库
        await ArticleService.instance.updateArticleSnapshotInfo(article.id, result.filePath!);
        getLogger().i('✅ 文章 "${article.title}" 快照处理完成');
      } else {
        getLogger().w('⚠️ 快照生成成功但上传失败，文章: "${article.title}"');
      }
    } else {
      getLogger().e('❌ 所有快照方式都失败了，文章: "${article.title}", 错误: ${result.error}');
    }
  }

  Future<SnapshotResult> _tryMhtmlSnapshot(ArticleDb article) async {
    final Completer<SnapshotResult> completer = Completer<SnapshotResult>();
    HeadlessInAppWebView? headlessWebView;
    bool isSaving = false; // 防止onLoadStop重入

    const String userAgent = 'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Mobile Safari/537.36';

    // 设置90秒超时
    final timeout = Timer(const Duration(seconds: 90), () {
      if (!completer.isCompleted) {
        getLogger().e('❌ MHTML快照任务超时 for ${article.url}');
        completer.complete(SnapshotResult(
          type: SnapshotType.mhtml,
          success: false,
          error: 'Timeout after 90 seconds',
        ));
      }
    });

    try {
      // 获取保存目录
      final snapshotDir = await _getSnapshotDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String mhtFileName = 'snapshot_${article.id}_$timestamp.mht';
      final String mhtFilePath = '$snapshotDir/$mhtFileName';

      headlessWebView = HeadlessInAppWebView(
        initialSettings: InAppWebViewSettings(
          userAgent: userAgent,
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          clearSessionCache: false,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          iframeAllowFullscreen: true,
          // 添加更多设置
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          cacheEnabled: true,
        ),
        initialUrlRequest: URLRequest(url: WebUri(article.url)),
        onLoadStop: (controller, url) async {
          // 如果任务已经完成（成功、失败或超时），或者正在保存中，则忽略后续的事件
          if (completer.isCompleted || isSaving) {
            getLogger().d('MHTML快照任务已完成或正在处理中，忽略后续 onLoadStop 事件: $url');
            return;
          }
          isSaving = true; // 标记为正在保存
          getLogger().i('✅ MHTML页面加载完成: $url');
          
          try {
            // 等待页面渲染
            await Future.delayed(const Duration(seconds: 4));
            
            // 滚动页面加载懒加载内容
            await controller.evaluateJavascript(source: '''
              window.scrollTo(0, document.body.scrollHeight);
              setTimeout(() => {
                window.scrollTo(0, 0);
              }, 1000);
            ''');
            
            await Future.delayed(const Duration(seconds: 3));
            
            getLogger().i('🔄 尝试生成MHTML快照: $mhtFilePath');
            
            // 确保目录存在
            final file = File(mhtFilePath);
            await file.parent.create(recursive: true);
            
            final savedPath = await controller.saveWebArchive(
              filePath: mhtFilePath,
              autoname: false,
            ).timeout(const Duration(seconds: 30));

            if (savedPath != null && savedPath.isNotEmpty && await File(savedPath).exists()) {
              final fileSize = await File(savedPath).length();
              getLogger().i('✅ MHTML快照成功生成，大小: $fileSize字节');
              
              if (!completer.isCompleted) {
                completer.complete(SnapshotResult(
                  filePath: savedPath,
                  type: SnapshotType.mhtml,
                  success: true,
                ));
              }
            } else {
              getLogger().e('❌ MHTML快照生成失败或文件不存在');
              if (!completer.isCompleted) {
                completer.complete(SnapshotResult(
                  type: SnapshotType.mhtml,
                  success: false,
                  error: 'MHTML file not generated or empty',
                ));
              }
            }
          } catch (e) {
            getLogger().e('❌ MHTML快照生成过程中出错: $e');
            if (!completer.isCompleted) {
              completer.complete(SnapshotResult(
                type: SnapshotType.mhtml,
                success: false,
                error: e.toString(),
              ));
            }
          }
        },
        onReceivedError: (controller, request, error) {
          getLogger().e('❌ MHTML页面加载错误: ${error.description} (Code: ${error.type}, URL: ${request.url})');
          if (!completer.isCompleted) {
            completer.complete(SnapshotResult(
              type: SnapshotType.mhtml,
              success: false,
              error: 'Load error: ${error.description}',
            ));
          }
        },
      );

      await headlessWebView.run();
      final result = await completer.future;
      
      return result;
    } catch (e) {
      getLogger().e('❌ MHTML快照整体流程出错: $e');
      return SnapshotResult(
        type: SnapshotType.mhtml,
        success: false,
        error: e.toString(),
      );
    } finally {
      timeout.cancel();
      if (headlessWebView != null && headlessWebView.isRunning()) {
        await headlessWebView.dispose();
      }
    }
  }

  Future<SnapshotResult> _tryHtmlSnapshot(ArticleDb article) async {
    final Completer<SnapshotResult> completer = Completer<SnapshotResult>();
    HeadlessInAppWebView? headlessWebView;

    const String userAgent = 'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Mobile Safari/537.36';

    final timeout = Timer(const Duration(seconds: 60), () {
      if (!completer.isCompleted) {
        completer.complete(SnapshotResult(
          type: SnapshotType.html,
          success: false,
          error: 'HTML snapshot timeout',
        ));
      }
    });

    try {
      final snapshotDir = await _getSnapshotDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String htmlFileName = 'snapshot_${article.id}_$timestamp.html';
      final String htmlPath = '$snapshotDir/$htmlFileName';

      headlessWebView = HeadlessInAppWebView(
        initialSettings: InAppWebViewSettings(
          userAgent: userAgent,
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        initialUrlRequest: URLRequest(url: WebUri(article.url)),
        onLoadStop: (controller, url) async {
          // 如果任务已经完成（成功、失败或超时），则忽略后续的onLoadStop事件
          if (completer.isCompleted) {
            getLogger().d('HTML快照任务已完成，忽略后续 onLoadStop 事件: $url');
            return;
          }

          try {
            await Future.delayed(const Duration(seconds: 3));
            
            final htmlContent = await controller.evaluateJavascript(source: 'document.documentElement.outerHTML');
            
            if (htmlContent != null && htmlContent.toString().isNotEmpty) {
              final file = File(htmlPath);
              await file.parent.create(recursive: true);
              
              // 创建一个包含CSS和基本样式的完整HTML文档
              final fullHtml = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${article.title}</title>
    <base href="${article.url}">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        img { max-width: 100%; height: auto; }
    </style>
</head>
<body>
    <!-- 原始URL: ${article.url} -->
    <!-- 快照时间: ${DateTime.now().toIso8601String()} -->
    ${htmlContent.toString()}
</body>
</html>
              ''';
              
              await file.writeAsString(fullHtml, encoding: utf8);
              
              getLogger().i('✅ HTML快照生成成功: $htmlPath');
              
              if (!completer.isCompleted) {
                completer.complete(SnapshotResult(
                  filePath: htmlPath,
                  type: SnapshotType.html,
                  success: true,
                ));
              }
            } else {
              if (!completer.isCompleted) {
                completer.complete(SnapshotResult(
                  type: SnapshotType.html,
                  success: false,
                  error: 'HTML content is empty',
                ));
              }
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete(SnapshotResult(
                type: SnapshotType.html,
                success: false,
                error: e.toString(),
              ));
            }
          }
        },
        onReceivedError: (controller, request, error) {
          if (!completer.isCompleted) {
            completer.complete(SnapshotResult(
              type: SnapshotType.html,
              success: false,
              error: 'Load error: ${error.description}',
            ));
          }
        },
      );

      await headlessWebView.run();
      return await completer.future;
    } catch (e) {
      return SnapshotResult(
        type: SnapshotType.html,
        success: false,
        error: e.toString(),
      );
    } finally {
      timeout.cancel();
      if (headlessWebView != null && headlessWebView.isRunning()) {
        await headlessWebView.dispose();
      }
    }
  }

  Future<String> _getSnapshotDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String snapshotDir = '${appDir.path}/snapshots';
    await Directory(snapshotDir).create(recursive: true);
    return snapshotDir;
  }

  // 实现上传快照到服务器的逻辑
  Future<bool> uploadSnapshotToServer(String snapshotPath) async {
    try {
      getLogger().i('🔄 开始上传快照到服务器: $snapshotPath');

      // 1. 从文件路径中提取文章ID
      final fileName = snapshotPath.split('/').last;
      final parts = fileName.split('_');
      if (parts.length < 2 || parts[0] != 'snapshot') {
        getLogger().e('上传失败：无效的快照文件名格式: $fileName');
        return false;
      }
      final articleId = int.tryParse(parts[1]);
      if (articleId == null) {
        getLogger().e('上传失败：无法从文件名中解析文章ID: $fileName');
        return false;
      }

      // 2. 根据ID从数据库获取文章信息
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article == null) {
        getLogger().e('上传失败：未找到ID为 $articleId 的文章');
        return false;
      }

      final serviceArticleId = article.serviceId;

      // 3. 检查文件和文章服务器ID的有效性
      if (snapshotPath.isEmpty) {
        getLogger().e('上传失败：文件路径为空');
        return false;
      }

      if (serviceArticleId.isEmpty) {
        getLogger().e('上传失败：文章尚未同步到服务器，无法上传快照');
        return false;
      }

      if (!_isValidObjectId(serviceArticleId)) {
        getLogger().e('上传失败：无效的文章服务端ID格式: "$serviceArticleId"');
        return false;
      }

      // 4. 准备并执行上传
      final File file = File(snapshotPath);
      if (!await file.exists()) {
        getLogger().e('上传失败：快照文件不存在于 $snapshotPath');
        return false;
      }

      final uploadFileName = snapshotPath.split('/').last;
      final dio.FormData formData = dio.FormData.fromMap({
        "service_article_id": serviceArticleId,
        'file': await dio.MultipartFile.fromFile(
          snapshotPath,
          filename: uploadFileName,
        ),
      });

      final response = await UserApi.uploadMhtmlApi(formData);

      if (response['code'] == 0) {
        getLogger().i('✅ 快照上传成功！');
        return true;
      } else {
        getLogger().e('❌ 快照上传失败: ${response['message'] ?? '未知错误'}');
        return false;
      }
    } catch (e) {
      getLogger().e('❌ 快照上传过程中发生异常: $e');
      return false;
    }
  }

  // 手动触发快照生成（用于测试和调试）
  Future<void> manualTriggerSnapshot({int? articleId}) async {
    getLogger().i('🔄 手动触发快照生成...');
    
    if (articleId != null) {
      // 如果指定了文章ID，只处理该文章
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        await _generateAndUploadSnapshot(article);
      } else {
        getLogger().w('⚠️ 未找到ID为 $articleId 的文章');
      }
    } else {
      // 否则处理所有未快照的文章
      await processUnsnapshottedArticles();
    }
  }

  // 获取快照统计信息
  Future<Map<String, int>> getSnapshotStats() async {
    try {
      final allArticles = await ArticleService.instance.getAllArticles();
      final snapshotDirectory = await _getSnapshotDirectory();
      final snapshotDir = Directory(snapshotDirectory);
      
      int totalArticles = allArticles.length;
      int snapshottedArticles = allArticles.where((article) => 
        article.mhtmlPath.isNotEmpty).length;
      int pendingArticles = totalArticles - snapshottedArticles;
      
      int totalSnapshotFiles = 0;
      if (await snapshotDir.exists()) {
        final files = await snapshotDir.list().toList();
        totalSnapshotFiles = files.whereType<File>().length;
      }
      
      return {
        'totalArticles': totalArticles,
        'snapshottedArticles': snapshottedArticles,
        'pendingArticles': pendingArticles,
        'totalSnapshotFiles': totalSnapshotFiles,
      };
    } catch (e) {
      getLogger().e('❌ 获取快照统计信息失败: $e');
      return {
        'totalArticles': 0,
        'snapshottedArticles': 0,
        'pendingArticles': 0,
        'totalSnapshotFiles': 0,
      };
    }
  }

  /// 验证MongoDB ObjectID格式
  /// ObjectID应该是24位十六进制字符串，且不能是全0
  bool _isValidObjectId(String id) {
    // 检查长度
    if (id.length != 24) {
      getLogger().w('ObjectID长度错误: ${id.length}, 期望: 24');
      return false;
    }

    // 检查是否为十六进制字符串
    final hexPattern = RegExp(r'^[0-9a-fA-F]{24}$');
    if (!hexPattern.hasMatch(id)) {
      getLogger().w('ObjectID格式错误，应为24位十六进制字符串: "$id"');
      return false;
    }

    // 检查是否为全0（无效的ObjectID）
    if (id == '000000000000000000000000') {
      getLogger().w('ObjectID不能为全0: "$id"');
      return false;
    }

    return true;
  }

  // 清理过期的快照文件
  Future<void> cleanupOldSnapshots({int daysOld = 30}) async {
    try {
      final snapshotDirectory = await _getSnapshotDirectory();
      final snapshotDir = Directory(snapshotDirectory);
      
      if (!await snapshotDir.exists()) {
        getLogger().i('快照目录不存在，无需清理');
        return;
      }
      
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final files = await snapshotDir.list().toList();
      int deletedCount = 0;
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            deletedCount++;
            getLogger().d('删除过期快照文件: ${file.path}');
          }
        }
      }
      
      getLogger().i('✅ 清理完成，删除了 $deletedCount 个过期快照文件');
    } catch (e) {
      getLogger().e('❌ 清理快照文件失败: $e');
    }
  }
} 
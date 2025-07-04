import 'dart:async';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../basics/logger.dart';
import '../db/article/service/article_service.dart';
import '../db/database_service.dart';
import '../db/sync_operation.dart';


/// 负责处理数据同步的后台服务
class SyncService extends GetxService {
  static SyncService get instance => Get.find<SyncService>();

  final _dbService = DatabaseService.instance;
  final _articleService = ArticleService.instance;
  
  Timer? _timer;
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    getLogger().i('SyncService Initialized');
    // 每30秒触发一次同步检查
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _triggerSync();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// 触发同步流程
  void _triggerSync() {
    if (_isSyncing) {
      getLogger().i('Sync is already in progress. Skipping.');
      return;
    }
    getLogger().i('Triggering periodic sync...');
    _performSync();
  }

  /// 执行同步操作
  Future<void> _performSync() async {
    _isSyncing = true;
    try {
      // 1. 获取所有待处理的操作
      var pendingOps = await _dbService.syncOperations
          .where()
          .statusEqualTo(SyncStatus.pending)
          .findAll();

      // 2. 在Dart中对结果进行排序
      pendingOps.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (pendingOps.isEmpty) {
        getLogger().i('No pending operations to sync.');
        return;
      }

      getLogger().i('Found ${pendingOps.length} pending operations.');

      for (final op in pendingOps) {
        bool success = false;
        try {
          switch (op.collectionName) {
            case 'ArticleDb':
              success = await _handleArticleSync(op);
              break;
            // TODO: 添加对其他数据模型（如CategoryDb, TagDb）的处理
            default:
              getLogger().w('Unknown collection to sync: ${op.collectionName}');
              success = false; // 标记为失败，避免无限重试
          }

          // 更新操作状态
          await _dbService.isar.writeTxn(() async {
            op.status = success ? SyncStatus.synced : SyncStatus.failed;
            await _dbService.syncOperations.put(op);
          });

        } catch (e) {
          getLogger().e('Error syncing operation ${op.id}: $e');
           await _dbService.isar.writeTxn(() async {
            op.status = SyncStatus.failed;
            await _dbService.syncOperations.put(op);
          });
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// 处理文章相关的同步操作
  Future<bool> _handleArticleSync(SyncOperation op) async {
    switch (op.operation) {
      case SyncOp.create:
        getLogger().i('Syncing CREATE for Article ${op.entityId}');
        // final articleData = jsonDecode(op.data!);
        // TODO: 调用API创建文章: final response = await Api.createArticle(articleData);
        // 模拟API调用
        await Future.delayed(const Duration(milliseconds: 500));
        // 假设API调用成功，并返回了服务端的ID
        final newServiceIdFromServer = "server-id-${DateTime.now().millisecondsSinceEpoch}";
        
        // 使用临时的客户端ID找到本地文章
        final localArticle = await _articleService.findArticleByServiceId(op.entityId);
        if (localArticle != null) {
          // 更新本地文章的服务端ID
          await _articleService.updateServiceId(localArticle.id, newServiceIdFromServer);
          getLogger().i('Updated local article with server ID: $newServiceIdFromServer');
        } else {
           getLogger().w('Could not find local article with client ID: ${op.entityId}');
        }
        return true; // 假设成功

      case SyncOp.update:
        getLogger().i('Syncing UPDATE for Article ${op.entityId}');
        // final articleData = jsonDecode(op.data!);
        // TODO: 调用API更新文章: await Api.updateArticle(op.entityId, articleData);
        await Future.delayed(const Duration(milliseconds: 500));
        return true; // 假设成功

      case SyncOp.delete:
        getLogger().i('Syncing DELETE for Article ${op.entityId}');
        // TODO: 调用API删除文章: await Api.deleteArticle(op.entityId);
        await Future.delayed(const Duration(milliseconds: 500));
        return true; // 假设成功
    }
  }
} 
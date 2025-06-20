import 'dart:async';
import 'package:get/get.dart';

import '../basics/logger.dart';
import '../db/article/article_db.dart';
import '../db/article/article_service.dart';
import '../api/user_api.dart';


class SyncService extends GetxService {
  static SyncService get instance => Get.find<SyncService>();
  Timer? _syncTimer;
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    getLogger().i('SyncService onInit');
    // 每5分钟执行一次同步
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getLogger().i('⏰ 定时同步任务触发');
      syncUnsyncedArticles();
    });
    // 应用启动10秒后也执行一次，以尽快同步离线时添加的数据
    // Future.delayed(const Duration(seconds: 3), () => syncUnsyncedArticles());
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
    getLogger().i('SyncService onClose');
  }

  /// 获取未同步的文章并同步到后端
  Future<void> syncUnsyncedArticles() async {
    if (_isSyncing) {
      getLogger().i('🔄 文章同步正在进行中，跳过此次触发。');
      return;
    }
    _isSyncing = true;
    getLogger().i('🔄 开始执行文章同步...');
    try {
      // 假设 article_service 中有 getUnsyncedArticles 方法
      final unsyncedArticles = await ArticleService.instance.getUnsyncedArticles();
      if (unsyncedArticles.isEmpty) {
        getLogger().i('✅ 没有需要同步的文章。');
        return;
      }

      getLogger().i('发现 ${unsyncedArticles.length} 篇未同步的文章，开始同步...');
      for (final article in unsyncedArticles) {
        await _syncArticleToBackend(article);
      }
      getLogger().i('✅ 所有文章同步任务完成。');
    } catch (e) {
      getLogger().e('❌ 执行同步任务时出错: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 同步单篇文章到后端
  Future<void> _syncArticleToBackend(ArticleDb article) async {
    try {
      getLogger().i('🌐 正在同步文章到后端: ${article.title} (本地ID: ${article.id})');
      
      final param = {
        'client_article_id': article.id,
        'title': article.title,
        'url': article.url,
        'share_original_content': article.shareOriginalContent,
      };
      
      final response = await UserApi.createArticleApi(param);
      if (response['code'] == 0) {
        final serviceIdData = response['data'];
        String serviceId = '';
        
        if (serviceIdData != null) {
          serviceId = serviceIdData.toString();
        }
        
        if (serviceId.isNotEmpty) {
          // 假设 article_service 中有 markArticleAsSynced 方法
          await ArticleService.instance.markArticleAsSynced(article.id, serviceId);
          getLogger().i('✅ 文章同步成功。 服务端ID: $serviceId');
          // 触发Markdown生成
          // MarkdownService.instance.triggerMarkdownProcessing();
        } else {
          getLogger().e('❌ 后端返回了无效的服务端ID: "$serviceId" (本地ID: ${article.id})');
        }
      } else {
        getLogger().e('❌ 后端同步失败 (本地ID: ${article.id}): ${response['msg']}');
      }
    } catch (e) {
      getLogger().e('❌ 同步文章失败 (本地ID: ${article.id}): $e');
    }
  }

} 
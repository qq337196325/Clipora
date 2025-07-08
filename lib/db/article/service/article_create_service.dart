import '../../../api/user_api.dart';
import '../../../basics/ui.dart';
import '../article_db.dart';
import '../../../basics/logger.dart';
import 'article_service.dart';
import 'article_update_service.dart';


/// 文章服务类
class ArticleCreateService extends ArticleUpdateService {



  /// 从分享内容创建文章
  Future<ArticleDb> createArticleFromShare({
    required String title,
    required String url,
    required String originalContent,
    String? excerpt,
    List<String>? tags,
  }) async {

    try {
      getLogger().i('📝 从分享内容创建文章: $title');

      final article = ArticleDb()
        ..title = title
        ..url = url
        ..shareOriginalContent = originalContent
        ..excerpt = excerpt
        ..isRead = 0
        ..readCount = 0
        ..readDuration = 0
        ..updateTimestamp = getStorageServiceCurrentTime()
        ..readProgress = 0.0;


      final savedArticle = await saveArticle(article);

      /// 将数据保存到服务端
      final param = {
        'client_article_id': savedArticle.id,
        'title': savedArticle.title,
        'url': savedArticle.url,
        'share_original_content': savedArticle.shareOriginalContent,
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
      }

      getLogger().i('📝 文章已创建，serviceId将在后端同步完成后设置');
      return savedArticle;
    } catch (e) {
      getLogger().e('❌ 从分享内容创建文章失败: $e');
      rethrow;
    }
  }


}
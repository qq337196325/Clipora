import 'package:flutter/material.dart';

import '../../../../basics/logger.dart';
import '../../../../db/article/article_db.dart';
import '../../../../db/article/service/article_service.dart';
import '../../../../db/article_content/article_content_service.dart';
import '../../controller/article_controller.dart';
import '../../../../basics/web_view/snapshot/snapshot_base_utils.dart';
import '../../../../api/user_api.dart';
import '../../../../db/annotation/enhanced_annotation_service.dart';


/// MHTML快照生成工具类
class GenerateMhtmlUtils extends SnapshotBaseUtils {

  /// 检查是否需要自动生成MHTML快照
  Future<void> checkAndGenerateSnapshotIfNeeded({
    required ArticleController articleController,
    required Function(String)? onSnapshotCreated,
    required Function(bool) onLoadingStateChanged,
    required bool mounted,
    required VoidCallback? onMarkdownGenerated,
  }) async {
    // 检查是否有文章ID
    try {
      // 等待3秒，确保网页完全加载稳定
      await Future.delayed(const Duration(seconds: 3));

      // 再次检查WebView是否还存在（防止用户已经离开页面）
      if (webViewController == null || !mounted) {
        getLogger().w('⚠️ WebView已销毁或页面已离开，跳过自动生成快照');
        return;
      }

      getLogger().i('🔍 检查文章是否需要生成MHTML快照，文章ID: ${articleController.articleId}');

      // 从数据库获取文章信息
      final article = articleController.currentArticle;

      if (article == null) {
        getLogger().w('⚠️ 未找到文章，ID: ${articleController.articleId}');
        return;
      }

      // 检查是否已经生成过快照
      if (article.isGenerateMhtml) {
        getLogger().i('✅ 文章已有MHTML快照，跳过自动生成: ${article.title}');
        return;
      }

      // 检查URL是否有效
      if (article.url.isEmpty) {
        getLogger().w('⚠️ 文章URL为空，无法生成快照: ${article.title}');
        return;
      }

      getLogger().i('🚀 开始自动生成MHTML快照: ${article.title}');

      // 生成快照
      final filePath = await generateSnapshot();
      updateArticleSnapshot(filePath,articleController.articleId); // 将快照目录更新到数据库
      final uploadStatus = await uploadSnapshotToServer(filePath,articleController.articleId); // 上传快照到服务器
      if(uploadStatus){
        await fetchMarkdownFromServer(
          article: articleController.currentArticle!,
          onMarkdownGenerated: onMarkdownGenerated,
        );
        articleController.refreshCurrentArticle();
      }

      getLogger().i('✅ 自动MHTML快照生成完成: ${article.title}');

    } catch (e) {
      getLogger().e('❌ 检查和生成MHTML快照失败: $e');
    }
  }

  /// 从服务端获取Markdown内容
  Future<void> fetchMarkdownFromServer({
    required ArticleDb article,
    required VoidCallback? onMarkdownGenerated,
    bool isReCreate = false,
  }) async {
    try {
      // 获取当前文章

      // 检查是否有serviceId
      if (article.serviceId.isEmpty) {
        getLogger().w('⚠️ 文章serviceId为空，无法获取Markdown内容');
        return;
      }

      // 检查是否有serviceId
      if (!isReCreate && article.markdownStatus != 0) {
        getLogger().w('⚠️ article的markdownStatus状态非0，不自动获取');
        return;
      }

      // 等待服务端处理MHTML转换为Markdown（延迟10秒让服务端有足够时间处理）
      getLogger().i('⏳ 等待服务端处理MHTML转Markdown，延迟3秒...');
      await Future.delayed(const Duration(seconds: 3));

      // 重试机制：最多重试3次，每次间隔5秒
      for (int retry = 0; retry < 5; retry++) {
        try {
          getLogger().i('🌐 第${retry + 1}次尝试从服务端获取Markdown内容，serviceId: ${article.serviceId}');

          final response = await UserApi.getArticleApi({
            'service_article_id': article.serviceId,
          });

          if (response['code'] == 0 && response['data'] != null) {
            final markdownContent = response['data']['markdown'] as String? ?? '';
            final title = response['data']['title'] as String? ?? '';
            final userId = response['data']['user_id'] as String? ?? '';

            if (markdownContent.isNotEmpty) {
              // Markdown已生成成功
              getLogger().i('✅ Markdown获取成功，长度: ${markdownContent.length}');

              /// 重新获取，避免覆盖之前更新的数据
              final newArticle = await ArticleService.instance.getArticleById(article.id);
              // 如果是重新生成，先删除所有标注和相关的文章内容
              if (isReCreate) {
                try {
                  // 获取现有的文章内容记录
                  final existingContent = await ArticleService.instance.getOriginalArticleContent(newArticle!.id);
                  
                  if (existingContent != null) {
                    // 删除与该内容相关的标注
                    final deletedAnnotationCount = await EnhancedAnnotationService.instance.clearArticleContentAnnotations(existingContent.id);
                    getLogger().i('🗑️ 重新生成时已删除 $deletedAnnotationCount 个标注');
                  }
                  
                  // 删除旧的文章内容记录
                  final deletedContentCount = await ArticleService.instance.deleteAllArticleContents(newArticle!.id);
                  getLogger().i('🗑️ 重新生成时已删除 $deletedContentCount 个文章内容记录');
                } catch (e) {
                  getLogger().e('❌ 删除旧内容和标注失败: $e');
                }
              }
              
              // 保存到 ArticleContentDb 表
              final articleContent = await ArticleContentService.instance.createArticleContent(
                articleId: newArticle!.id,
                markdown: markdownContent,
                languageCode: "original",
                isOriginal: true,
                serviceId: response['data']['service_article_content_id'],
                uuid: response['data']['article_content_uuid'],
              );

              // 更新 ArticleDb 的相关状态
              newArticle.isGenerateMarkdown = true;
              newArticle.markdownStatus = 1;
              newArticle.updatedAt = DateTime.now();
              newArticle.title = title;
              newArticle.userId = userId;
              await ArticleService.instance.saveArticle(newArticle);

              // 通知父组件刷新 tabs
              onMarkdownGenerated?.call();

              getLogger().i('🎉 Markdown内容已保存到ArticleContentDb表（ID: ${articleContent.id}），已通知父组件刷新tabs');
              return;
            }
          } else {
            getLogger().e('❌ 获取Markdown失败: ${response['msg']}');
          }
        } catch (e) {
          getLogger().e('❌ 第${retry + 1}次获取Markdown失败: $e');
        }

        // 如果不是最后一次重试，等待5秒后再试
        await Future.delayed(const Duration(seconds: 3));
      }

      getLogger().w('⚠️ 多次重试后仍无法获取Markdown内容，放弃');

    } catch (e) {
      getLogger().e('❌ fetchMarkdownFromServer 失败: $e');
    }
  }
}






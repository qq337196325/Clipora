import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../basics/logger.dart';
import '../../controller/article_controller.dart';
import '../../utils/snapshot_utils.dart';
import '../../../../db/article/article_service.dart';
import '../../../../api/user_api.dart';

/// MHTML快照生成工具类
class GenerateMhtmlUtils {
  
  /// 生成MHTML快照并保存到本地
  static Future<void> generateMHTMLSnapshot({
    required InAppWebViewController? webViewController,
    required ArticleController articleController,
    required Function(String)? onSnapshotCreated,
    required Function(bool) onLoadingStateChanged,
    required bool mounted,
    required VoidCallback? onMarkdownGenerated,
  }) async {
    await SnapshotUtils.generateAndProcessSnapshot(
        webViewController: webViewController,
        articleId: articleController.articleId,
        onSnapshotCreated: onSnapshotCreated,
        onLoadingStateChanged: onLoadingStateChanged,
        onSuccess: (status) async { /// 生成快照并且上传到服务器以后执行的操作
          getLogger().i('🎯 MHTML快照上传成功，开始获取Markdown内容');
          await fetchMarkdownFromServer(
            articleController: articleController,
            onMarkdownGenerated: onMarkdownGenerated,
          );
        }
    );
  }

  /// 检查是否需要自动生成MHTML快照
  static Future<void> checkAndGenerateSnapshotIfNeeded({
    required InAppWebViewController? webViewController,
    required ArticleController articleController,
    required Function(String)? onSnapshotCreated,
    required Function(bool) onLoadingStateChanged,
    required bool mounted,
    required VoidCallback? onMarkdownGenerated,
  }) async {
    // 检查是否有文章ID
    try {
      // 等待3秒，确保网页完全加载稳定
      await Future.delayed(const Duration(seconds: 2));

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

      // 生成快照（使用现有的方法）
      await generateMHTMLSnapshot(
        webViewController: webViewController,
        articleController: articleController,
        onSnapshotCreated: onSnapshotCreated,
        onLoadingStateChanged: onLoadingStateChanged,
        mounted: mounted,
        onMarkdownGenerated: onMarkdownGenerated,
      );

      getLogger().i('✅ 自动MHTML快照生成完成: ${article.title}');

    } catch (e) {
      getLogger().e('❌ 检查和生成MHTML快照失败: $e');
    }
  }

  /// 从服务端获取Markdown内容
  static Future<void> fetchMarkdownFromServer({
    required ArticleController articleController,
    required VoidCallback? onMarkdownGenerated,
  }) async {
    try {
      // 获取当前文章
      final article = articleController.currentArticle;
      if (article == null) {
        getLogger().w('⚠️ 当前文章为空，无法获取Markdown');
        return;
      }

      // 检查是否有serviceId
      if (article.serviceId.isEmpty) {
        getLogger().w('⚠️ 文章serviceId为空，无法获取Markdown内容');
        return;
      }

      // 检查是否有serviceId
      if (article.markdownStatus != 0) {
        getLogger().w('⚠️ article的markdownStatus状态非0，不自动获取');
        return;
      }

      // 等待服务端处理MHTML转换为Markdown（延迟10秒让服务端有足够时间处理）
      getLogger().i('⏳ 等待服务端处理MHTML转Markdown，延迟10秒...');
      await Future.delayed(const Duration(seconds: 4));

      // 重试机制：最多重试3次，每次间隔5秒
      for (int retry = 0; retry < 5; retry++) {
        try {
          getLogger().i('🌐 第${retry + 1}次尝试从服务端获取Markdown内容，serviceId: ${article.serviceId}');

          final response = await UserApi.getArticleApi({
            'service_article_id': article.serviceId,
          });

          if (response['code'] == 0 && response['data'] != null) {
            final markdownContent = response['data']['markdown_content'] as String? ?? '';
            final title = response['data']['title'] as String? ?? '';

            getLogger().i('📊 服务端返回： 内容长度=${markdownContent.length}');

            if (markdownContent.isNotEmpty) {
              // Markdown已生成成功
              getLogger().i('✅ Markdown获取成功，长度: ${markdownContent.length}');
              await ArticleService.instance.updateArticleMarkdown(article.id, markdownContent, title);

              // 刷新当前文章数据
              await articleController.refreshCurrentArticle();

              // 通知父组件刷新 tabs
              onMarkdownGenerated?.call();

              getLogger().i('🎉 Markdown内容已保存到本地数据库，已通知父组件刷新tabs');
              return;
            }
          } else {
            getLogger().e('❌ 获取Markdown失败: ${response['msg']}');
          }
        } catch (e) {
          getLogger().e('❌ 第${retry + 1}次获取Markdown失败: $e');
        }

        // 如果不是最后一次重试，等待5秒后再试
        if (retry < 2) {
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      getLogger().w('⚠️ 多次重试后仍无法获取Markdown内容，放弃');

    } catch (e) {
      getLogger().e('❌ fetchMarkdownFromServer 失败: $e');
    }
  }
}






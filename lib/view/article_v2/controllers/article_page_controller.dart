import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../basics/logger.dart';
import '../../../db/article/article_db.dart';
import '../../../db/article/service/article_service.dart';


class ArticlePageController extends GetxController {

// 获取文章服务实例
  final ArticleService articleService = ArticleService.instance;

  // 当前文章数据
  final Rx<ArticleDb?> currentArticleRx = Rx<ArticleDb?>(null);
  ArticleDb? get currentArticle => currentArticleRx.value;

  /// 根据ID加载文章数据
  Future<void> loadArticleById(int articleId) async {
    try {
      getLogger().i('🔄 开始加载文章，ID: $articleId');

      final article = await articleService.getArticleById(articleId);

      if (article != null) {
        currentArticleRx.value = article;
        getLogger().i('✅ 文章加载完成: ${article.title}');

        // 更新阅读次数
        await _updateReadCount(articleId);

        // 加载当前语言的 Markdown 内容
        // await loadMarkdownContent();

        // 初始化翻译状态（为了在打开翻译弹窗时显示正确状态）
        // await _initializeTranslationStatusForCurrentArticle();
      } else {
        getLogger().w('⚠️ 文章不存在，ID: $articleId');
      }
    } catch (e) {
      getLogger().e('❌ 加载文章失败: $e');
    } finally {
      // _isLoading.value = false;
    }
  }


  /// 更新阅读次数
  Future<void> _updateReadCount(int articleId) async {
    try {
      await articleService.updateReadStatus(
        articleId,
        isRead: true,
      );
      // 重新加载文章数据以更新计数
      final updatedArticle = await articleService.getArticleById(articleId);
      if (updatedArticle != null) {
        currentArticleRx.value = updatedArticle;
      }
    } catch (e) {
      getLogger().e('❌ 更新阅读计数失败: $e');
    }
  }


}
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../basics/api_services_interface.dart';
import '../../../basics/logger.dart';
import '../../../db/article_content/article_content_service.dart';
import 'article_base_controller.dart';
import 'package:get/get.dart';


/// 文章控制器
class ArticleMarkdownController extends ArticleBaseController {

  InAppWebViewController? markdownController;
  DateTime? _lastSaveTime;


  /// 加载 Markdown 内容
  Future<void> loadMarkdownContent([String? language]) async {
    final article = currentArticleRx.value;
    if (article == null) return;

    final targetLanguage = language ?? "original";

    try {
      getLogger().i('📄 开始加载Markdown内容，文章ID: ${article.id}，语言: ${targetLanguage}');

      // 更新当前语言状态
      currentLanguageCodeRx.value = targetLanguage;

      // 从 ArticleContentDb 获取指定语言的内容
      final articleContent = await articleService.getArticleContentByLanguage(
          currentArticle!.id,
          targetLanguage
      );

      if (articleContent != null && articleContent.markdown.isNotEmpty) {
        getLogger().i('✅ 使用ArticleContentDb中的Markdown内容，语言: ${targetLanguage}，长度: ${articleContent.markdown.length}');
        // getLogger().i('✅ 使用ArticleContentDb中的Markdown内容，语言: ${articleContent.markdown}');
        currentArticleContentRx.value = articleContent;
        currentMarkdownContentRx.value = articleContent.markdown;
        update();
      } else {
        getLogger().i('📄 ArticleContentDb 中无该语言的Markdown内容，尝试从服务端获取');

        // 如果是原文且有 serviceId，从服务端获取
        if (article.serviceId.isNotEmpty) {
          await _fetchMarkdownFromServer(article.serviceId, article.id, targetLanguage);
        } else {
          currentMarkdownContentRx.value = '';
          // getLogger().w('⚠️ 无法获取该语言的Markdown内容: ${targetLanguage.label}');
        }
      }
    } catch (e) {
      getLogger().e('❌ 加载Markdown内容失败: $e');
      currentMarkdownContentRx.value = '';
    } finally {
      // _isMarkdownLoading.value = false;
    }
  }

  /// 从服务端获取Markdown内容
  Future<void> _fetchMarkdownFromServer(String serviceId, int articleId, String language) async {
    try {
      getLogger().i('🌐 从服务端获取Markdown内容，serviceId: $serviceId，语言: ${language}');

      final apiServices = Get.find<IApiServices>();
      final response = await apiServices.getArticle({
        'service_article_id': serviceId,
      });

      if (response['code'] == 0) {
        final data = response['data'];
        final markdownContent = data['markdown_content'] ?? '';

        if (markdownContent.isNotEmpty) {
          getLogger().i('✅ 服务端Markdown内容获取成功，长度: ${markdownContent.length}');

          // 更新本地状态
          currentMarkdownContentRx.value = markdownContent;

          // 保存到数据库
          await _saveMarkdownToDatabase(articleId, markdownContent, language);
        } else {
          getLogger().i('ℹ️ 服务端暂无Markdown内容，等待生成');
          currentMarkdownContentRx.value = '';
        }
      } else {
        // 检查是否是"系统错误"或类似的服务端错误
        final errorMsg = response['msg'] ?? '获取文章失败';
        if (errorMsg.contains('系统错误') || errorMsg.contains('暂无') || errorMsg.contains('不存在')) {
          getLogger().w('⚠️ 服务端暂无Markdown内容: $errorMsg');
          currentMarkdownContentRx.value = '';
        } else {
          throw Exception(errorMsg);
        }
      }
    } catch (e) {
      getLogger().w('⚠️ 获取Markdown内容时出现异常: $e');
      currentMarkdownContentRx.value = '';
    }
  }


  /// 保存Markdown内容到数据库
  Future<void> _saveMarkdownToDatabase(int articleId, String markdownContent, String language) async {
    try {
      getLogger().i('💾 保存Markdown内容到ArticleContentDb，文章ID: $articleId，语言: ${language}');

      // 保存到 ArticleContentDb 表
      final articleContent = await articleService.saveOrUpdateArticleContent(
        articleId: articleId,
        markdown: markdownContent,
        languageCode: language,
        isOriginal: language == "original",
      );

      // 如果是原文，更新 ArticleDb 的状态
      if (language == "original") {
        final article = await articleService.getArticleById(articleId);
        if (article != null) {
          article.isGenerateMarkdown = true;
          article.markdownStatus = 1;
          article.updatedAt = DateTime.now();
          await articleService.saveArticle(article);
        }
      }

      getLogger().i('✅ Markdown内容保存成功，ArticleContentDb ID: ${articleContent.id}');

    } catch (e) {
      getLogger().e('❌ 保存Markdown内容到数据库失败: $e');
    }
  }


  /// 手动触发位置保存
  Future<void> manualSavePosition() async {
    getLogger().i('🔧 手动触发位置保存...');
    final oldLastSaveTime = _lastSaveTime;
    _lastSaveTime = null; // 临时重置保存时间限制
    await _saveCurrentReadingPosition();
    if (oldLastSaveTime != null) _lastSaveTime = oldLastSaveTime;
  }

  /// 保存阅读位置
  Future<void> _saveCurrentReadingPosition() async {
    try {
      // 使用简单的滚动位置保存
      final scrollY = await markdownController!.getScrollY();
      final scrollX = await markdownController!.getScrollX();

      final currentScrollY = scrollY ?? 0;
      final currentScrollX = scrollX ?? 0;
      if ((currentScrollY - (currentArticleContent?.markdownScrollY ?? 0)).abs() > 50) {
        if (currentArticleContent != null) {
          await ArticleContentService.instance.saveMarkdownScroll(
            currentArticleContentRx.value!.id,
              currentScrollY,
              currentScrollX,
          );

          getLogger().i('💾 保存阅读位置成功: X=$currentScrollX, Y=$currentScrollY');
          _lastSaveTime = DateTime.now();


        }
      } else {
        getLogger().d('📍 位置变化不大，跳过保存 (差值: ${(currentScrollY - (currentArticleContent?.markdownScrollY ?? 0)).abs()})');
      }
    } catch (e) {
      if (e.toString().contains('disposed')) {
        getLogger().w('⚠️ WebView已销毁，跳过保存阅读位置');
      } else {
        getLogger().e('❌ 保存阅读位置异常: $e');
      }
    }finally {
      // final article = await dbService.articles.get(articleId);
      final article = await articleService.getArticleById(articleId);
      getLogger().i('🔧 手动触发位置保存1...$article');
      getLogger().i('🔧 手动触发位置保存2...$articleId');
      if (article != null) {
        article.lastReadTime = DateTime.now();
        await articleService.saveArticle(article);
      }
    }
  }

}
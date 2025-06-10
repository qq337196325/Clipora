import 'dart:async';
import 'package:get/get.dart';

import '../basics/logger.dart';
import '../db/article/article_db.dart';
import '../db/article/article_service.dart';
import '../api/user_api.dart';

class MarkdownService extends GetxService {
  static MarkdownService get instance => Get.find<MarkdownService>();
  Timer? _markdownTimer;
  bool _isProcessing = false; // 防止任务重叠
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    getLogger().i('MarkdownService onInit');
    // 每2分钟检查一次
    _markdownTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      getLogger().i('⏰ 定时Markdown生成任务触发');
      processArticlesForMarkdown();
    });
    // 应用启动60秒后也执行一次
    Future.delayed(const Duration(seconds: 60), () => processArticlesForMarkdown());
  }

  @override
  void onClose() {
    _markdownTimer?.cancel();
    _debounce?.cancel();
    super.onClose();
    getLogger().i('MarkdownService onClose');
  }

  /// 触发一次Markdown生成任务，带有防抖处理
  void triggerMarkdownProcessing() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 5), () {
      processArticlesForMarkdown();
    });
  }

  Future<void> processArticlesForMarkdown() async {
    if (_isProcessing) {
      getLogger().i('🔄 Markdown生成任务正在处理中，跳过此次触发。');
      return;
    }
    _isProcessing = true;

    try {
      getLogger().i('🔄 开始执行Markdown生成任务...');
      final articlesToProcess = await ArticleService.instance.getArticlesToGenerateMarkdown();

      if (articlesToProcess.isEmpty) {
        getLogger().i('✅ 没有需要生成Markdown的文章。');
        return;
      }

      getLogger().i('发现 ${articlesToProcess.length} 篇需要生成Markdown的文章，开始处理...');
      for (final article in articlesToProcess) {
        await _fetchAndSaveMarkdown(article);
      }
    } catch (e) {
      getLogger().e('❌ 执行Markdown生成任务时出错: $e');
    } finally {
      _isProcessing = false;
      getLogger().i('✅ Markdown生成任务执行完毕。');
    }
  }

  Future<void> _fetchAndSaveMarkdown(ArticleDb article) async {
    if (article.serviceId.isEmpty) {
      getLogger().w('⚠️ 文章 "${article.title}" serviceId为空，无法获取Markdown。');
      return;
    }

    try {
      getLogger().i('🌐 从服务端获取Markdown，serviceId: ${article.serviceId}');
      final response = await UserApi.getArticleApi({'service_article_id': article.serviceId});

      if (response['code'] == 0 && response['data'] != null) {
        final markdownContent = response['data']['markdown_content'] as String? ?? '';
        if (markdownContent.isNotEmpty) {
          getLogger().i('✅ Markdown获取成功，长度: ${markdownContent.length}');
          await ArticleService.instance.updateArticleMarkdown(article.id, markdownContent);
        } else {
          getLogger().w('⚠️ 服务端返回的Markdown内容为空 for article ${article.id}');
        }
      } else {
        getLogger().e('❌ 获取Markdown失败: ${response['msg']}');
      }
    } catch (e) {
      getLogger().e('❌ _fetchAndSaveMarkdown 失败: $e');
    }
  }
} 
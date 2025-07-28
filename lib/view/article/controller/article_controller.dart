// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


import 'dart:async';
import 'package:clipora/db/article/article_db.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:isar/isar.dart';

import '../../../basics/api_services_interface.dart';
import '../../../db/article/service/article_service.dart';
import '../../../db/article_content/article_content_db.dart';
import '../../../basics/logger.dart';
import '../../../db/article_content/article_content_service.dart';
import 'article_read_theme_controller.dart';
import 'models/translate_content_model.dart';


/// 文章控制器
class ArticleController extends ArticleReadThemeController {


  /// ------------------------------------------------------------------------------


  // 加载状态
  // final RxBool _isLoading = false.obs;
  // bool get isLoading => _isLoading.value;
  //
  // // Markdown 内容加载状态
  // final RxBool _isMarkdownLoading = false.obs;
  // bool get isMarkdownLoading => _isMarkdownLoading.value;

  // 错误信息
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  // 是否有错误
  bool get hasError => _errorMessage.value.isNotEmpty;

  // 翻译相关状态
  final RxMap<String, String> _translationStatus = <String, String>{}.obs;
  Map<String, String> get translationStatus => _translationStatus;
  
  final Map<String, Timer?> _pollingTimers = {};
  final Map<String, String> _translationUpIds = {};
  // 添加请求进行中的标记，防止重复请求
  final Map<String, bool> _translationRequesting = {};



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
        await loadMarkdownContent();

        // 初始化翻译状态（为了在打开翻译弹窗时显示正确状态）
        await _initializeTranslationStatusForCurrentArticle();
      } else {
        getLogger().w('⚠️ 文章不存在，ID: $articleId');
      }
    } catch (e) {
      getLogger().e('❌ 加载文章失败: $e');
    } finally {
      // _isLoading.value = false;
    }
  }

  /// Markdown 生成成功回调
  Future<void> onMarkdownGenerated() async {
    getLogger().i('🎯 收到 Markdown 生成成功通知，刷新内容');
    
    // 刷新当前文章数据
    await refreshCurrentArticle();
    
    // 重新加载当前语言的 Markdown 内容
    await loadMarkdownContent();
  }

  /// 刷新 Markdown 内容（用于重新生成后的刷新）
  Future<void> refreshMarkdownContent() async {
    await loadMarkdownContent();
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

  /// 更新阅读进度
  Future<void> updateReadProgress(double progress) async {
    final article = currentArticleRx.value;
    if (article == null) return;

    try {
      await articleService.updateReadStatus(
        article.id,
        isRead: true,
        readProgress: progress,
      );
      
      // 更新本地数据
      article.readProgress = progress;
      currentArticleRx.refresh();
      
      getLogger().i('📊 更新阅读进度: ${(progress * 100).toStringAsFixed(1)}%');
    } catch (e) {
      getLogger().e('❌ 更新阅读进度失败: $e');
    }
  }

  /// 标记文章为已读
  Future<void> markAsRead() async {
    final article = currentArticleRx.value;
    if (article == null) return;

    try {
      await articleService.updateReadStatus(
        article.id,
        isRead: true,
        readProgress: 1.0,
      );
      
      // 更新本地数据
      article.isRead = 1;
      article.readProgress = 1.0;
      currentArticleRx.refresh();
      
      getLogger().i('✅ 文章已标记为已读');
    } catch (e) {
      getLogger().e('❌ 标记已读失败: $e');
    }
  }

  /// 清除当前文章数据
  void clearCurrentArticle() {
    currentArticleRx.value = null;
    currentMarkdownContentRx.value = '';
    getLogger().i('🧹 清除当前文章数据');
  }

  /// 重新加载当前文章
  Future<void> refreshCurrentArticle() async {
    final article = currentArticleRx.value;
    if (article != null) {
      await loadArticleById(article.id);
    }
  }

  /// 检查文章是否存在
  bool get hasArticle => currentArticleRx.value != null;

  /// 获取文章标题
  String get articleTitle => currentArticleRx.value?.title ?? 'i18n_article_未知标题'.tr;

  /// 获取文章URL
  String get articleUrl => currentArticleRx.value?.url ?? '';

  // ============================================================================
  // 翻译相关方法
  // ============================================================================

  /// 开始翻译 返回API状态码
  Future<int> startTranslation(String languageCode) async {
    // 检查是否已经在请求中，防止重复请求
    if (_translationRequesting[languageCode] == true) {
      getLogger().w('⚠️ 翻译请求已在进行中，忽略重复请求: $languageCode');
      return 99;
    }

    // 检查是否已经在翻译中
    if (_translationStatus[languageCode] == 'translating') {
      getLogger().w('⚠️ 该语言正在翻译中，忽略重复请求: $languageCode');
      return 99;
    }

    final article = currentArticleRx.value;
    if (article == null || article.serviceId.isEmpty) {
      BotToast.showText(text: 'i18n_article_文章信息获取失败'.tr);
      return 99;
    }

    getLogger().i('🌐 开始翻译，语言: $languageCode');
    
    // 设置请求进行中标记
    _translationRequesting[languageCode] = true;
    // 设置翻译状态为进行中
    _translationStatus[languageCode] = 'translating';

    try {
      // 调用翻译 API
      final apiServices = Get.find<IApiServices>();
      final response = await apiServices.translate({
        'service_article_id': article.serviceId,
        'language_code': languageCode,
      });

      if (response['code'] == 0) {
        final upId = response['data'].toString();
        _translationUpIds[languageCode] = upId;
        
        getLogger().i('✅ 翻译请求成功，up_id: $upId，开始轮询');
        
        // 开始轮询翻译结果
        _startPolling(languageCode, upId);
        return 0;
      } else if (response['code'] == 100) {
        _translationStatus[languageCode] = 'failed';
        final errorMsg = response['msg'] ?? 'i18n_article_您的翻译额度已用完'.tr;
        return response['code'];
      } else {
        _translationStatus[languageCode] = 'failed';
        final errorMsg = response['msg'] ?? 'i18n_article_翻译请求失败'.tr;
        BotToast.showText(text: errorMsg);
        getLogger().e('❌ 翻译请求失败: $errorMsg');
        return response['code'];
      }
    } catch (e) {
      _translationStatus[languageCode] = 'failed';
      BotToast.showText(text: 'i18n_article_翻译请求失败请重试'.tr);
      getLogger().e('❌ 翻译请求异常: $e');
      return 99;
    } finally {
      // 清除请求进行中标记
      _translationRequesting[languageCode] = false;
    }
  }

  /// 开始轮询翻译结果
  void _startPolling(String languageCode, String upId) {
    // 清除之前的轮询
    _pollingTimers[languageCode]?.cancel();
    
    // 开始新的轮询，每3秒查询一次
    _pollingTimers[languageCode] = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _checkTranslationResult(languageCode, upId, timer),
    );
  }

  /// 检查翻译结果
  Future<void> _checkTranslationResult(String languageCode, String upId, Timer timer) async {
    try {
      final article = currentArticleRx.value;
      if (article == null) {
        timer.cancel();
        return;
      }

      /// 已经有了自动数据同步，所以这里不需要再写入数据库了；
      // final articleContent = await DatabaseService.instance.articleContent
      //     .filter()
      //     .articleIdEqualTo(articleId)
      //     .languageCodeEqualTo(languageCode)
      //     .findFirst();
      // if (articleContent != null) {
      //   timer.cancel();
      //   _pollingTimers.remove(languageCode);
      //   _translationUpIds.remove(languageCode);
      //   _translationStatus[languageCode] = 'translated';
      // }

      final apiServices = Get.find<IApiServices>();
      final response = await apiServices.getTranslateContent({
        'up_id': upId,
        'service_article_id': article.serviceId,
      });

      if (response['code'] == 0) {
        // 翻译完成
        timer.cancel();
        _pollingTimers.remove(languageCode);
        _translationUpIds.remove(languageCode);

        _translationStatus[languageCode] = 'translated';

        final data = response['data'];
        if (data != null) {
          try {
            // 解析翻译内容
            final translateContent = TranslateContentModel.fromJson(data);

            // 保存翻译后的内容到数据库
            await _saveTranslatedContent(translateContent);
            getLogger().i('✅ 翻译完成并保存，语言: $languageCode，内容长度: ${translateContent.markdown.length}');
          } catch (e) {
            getLogger().e('❌ 解析翻译内容失败: $e');
            _translationStatus[languageCode] = 'failed';
          }
        }
      } else {
        // 继续轮询（翻译仍在进行中）
        getLogger().d('⏳ 翻译进行中，语言: $languageCode');
      }

      getLogger().d('⏳ 翻译进行中，语言: $languageCode');
    } catch (e) {
      getLogger().e('❌ 检查翻译结果异常: $e');
      // 网络错误不停止轮询，继续重试
    }
  }

  /// 保存翻译内容到数据库
  Future<void> _saveTranslatedContent(TranslateContentModel translateContent) async {
    try {

      final articleData = await ArticleService.instance.dbService.articles
          .where()
          .serviceIdEqualTo(translateContent.serviceArticleId)
          .findFirst();


      await ArticleContentService.instance.createArticleContent(
        articleId: articleData!.id,
        markdown: translateContent.markdown,
        languageCode: translateContent.languageCode,
        isOriginal: false,
        uuid: translateContent.uuid,
        serviceId: translateContent.id, // 保存服务端的翻译内容ID
      );
      getLogger().i('💾 翻译内容已保存到数据库，语言: ${translateContent.languageCode}，serviceId: ${translateContent.id}');
    } catch (e) {
      getLogger().e('❌ 保存翻译内容失败: $e');
    }
  }

  /// 重新翻译
  Future<int> retranslate(String languageCode) async {
    // 检查是否已经在请求中
    if (_translationRequesting[languageCode] == true) {
      getLogger().w('⚠️ 重新翻译请求已在进行中，忽略重复请求: $languageCode');
      return 99;
    }

    // 停止当前轮询
    _pollingTimers[languageCode]?.cancel();
    _pollingTimers.remove(languageCode);
    _translationUpIds.remove(languageCode);
    
    // 重新开始翻译
    return await startTranslation(languageCode);
  }

  /// 获取语言翻译状态
  String getTranslationStatus(String languageCode) {
    return _translationStatus[languageCode] ?? 'untranslated';
  }

  /// 检查是否有任何语言正在翻译中
  bool get isAnyLanguageTranslating {
    return _translationStatus.values.any((status) => status == 'translating');
  }

  /// 检查语言是否已翻译
  Future<bool> isLanguageTranslated(String languageCode) async {
    final article = currentArticleRx.value;
    if (article == null) return false;

    // 首先检查内存状态
    if (_translationStatus[languageCode] == 'translated') {
      return true;
    }

    // 检查数据库中是否已有翻译内容
    try {
      final content = await articleService.getArticleContentByLanguage(
        article.id,
        languageCode,
      );
      final isTranslated = content != null && content.markdown.isNotEmpty;
      
      if (isTranslated) {
        _translationStatus[languageCode] = 'translated';
      }
      
      return isTranslated;
    } catch (e) {
      getLogger().e('❌ 检查翻译状态失败: $e');
      return false;
    }
  }

  /// 批量初始化所有语言的翻译状态
  Future<void> initializeAllLanguageStatus(List<String> languageCodes) async {
    final article = currentArticleRx.value;
    if (article == null) return;

    getLogger().i('🔄 初始化所有语言翻译状态，文章ID: ${article.id}');

    try {
      // 获取文章的所有已翻译内容
      final allContents = await articleService.getAllArticleContents(article.id);
      
      // 清空当前状态
      _translationStatus.clear();
      
      // 为每个语言设置状态
      for (final languageCode in languageCodes) {
        ArticleContentDb? content;
        try {
          content = allContents.firstWhere(
            (content) => content.languageCode == languageCode,
          );
        } catch (e) {
          content = null;
        }
        
        if (content != null && content.markdown.isNotEmpty) {
          _translationStatus[languageCode] = 'translated';
          getLogger().d('✅ 语言 $languageCode 已翻译，内容长度: ${content.markdown.length}');
        } else {
          _translationStatus[languageCode] = 'untranslated';
          getLogger().d('⏳ 语言 $languageCode 未翻译');
        }
      }
      
      getLogger().i('🎯 翻译状态初始化完成，已翻译语言数: ${_translationStatus.values.where((status) => status == 'translated').length}');
     } catch (e) {
       getLogger().e('❌ 初始化翻译状态失败: $e');
     }
   }

   /// 为当前文章初始化常用语言的翻译状态
   Future<void> _initializeTranslationStatusForCurrentArticle() async {
     // 定义常用的翻译语言
     const commonLanguages = [
       'en-US', 'ja-JP', 'ko-KR', 'fr-FR', 'de-DE', 'es-ES', 
       'ru-RU', 'ar-AR', 'pt-PT', 'it-IT', 'nl-NL', 'th-TH', 
       'vi-VN', 'zh-CN', 'zh-TW'
     ];
     
     await initializeAllLanguageStatus(commonLanguages);
   }

  /// 切换到指定语言
  Future<void> switchToLanguage(String languageCode) async {
    getLogger().i('🌐 切换到语言: $languageCode');
    
    // 更新当前语言状态
    currentLanguageCodeRx.value = languageCode;
    
    // 加载对应语言的Markdown内容
    await loadMarkdownContent(languageCode);
    
    // 通过update()触发UI刷新，确保ArticleMarkdownWidget能够接收到新内容
    update();
  }

  /// 清理翻译状态
  void _clearTranslationState() {
    // 取消所有轮询
    for (final timer in _pollingTimers.values) {
      timer?.cancel();
    }
    _pollingTimers.clear();
    _translationUpIds.clear();
    _translationRequesting.clear();
    _translationStatus.clear();
  }

  @override
  void onClose() {
    getLogger().i('🔄 ArticleController 销毁');
    _clearTranslationState();
    super.onClose();
  }
}
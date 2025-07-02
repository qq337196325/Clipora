import 'dart:async';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';

import '../../../db/article/article_db.dart';
import '../../../db/article/article_service.dart';
import '../../../db/article_content/article_content_db.dart';
import '../../../api/user_api.dart';
import '../../../basics/logger.dart';

/// 翻译内容模型
class TranslateContentModel {
  final String id;
  final String userId;
  final String serviceArticleId;
  final int articleId;
  final String languageCode;
  final String markdown;
  final String upId;

  TranslateContentModel({
    required this.id,
    required this.userId,
    required this.serviceArticleId,
    required this.articleId,
    required this.languageCode,
    required this.markdown,
    required this.upId,
  });

  factory TranslateContentModel.fromJson(Map<String, dynamic> json) {
    return TranslateContentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      serviceArticleId: json['service_article_id'] ?? '',
      articleId: json['article_id'] ?? 0,
      languageCode: json['language_code'] ?? '',
      markdown: json['markdown'] ?? '',
      upId: json['up_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_article_id': serviceArticleId,
      'article_id': articleId,
      'language_code': languageCode,
      'markdown': markdown,
      'up_id': upId,
    };
  }
}

/// 文章控制器
class ArticleController extends GetxController {

  int articleId = 0;

  /// ------------------------------------------------------------------------------

  // 获取文章服务实例
  final ArticleService _articleService = ArticleService.instance;

  // 当前文章数据
  final Rx<ArticleDb?> _currentArticle = Rx<ArticleDb?>(null);
  ArticleDb? get currentArticle => _currentArticle.value;

  // 当前语言的 Markdown 内容
  final RxString _currentMarkdownContent = ''.obs;
  String get currentMarkdownContent => _currentMarkdownContent.value;

  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Markdown 内容加载状态
  final RxBool _isMarkdownLoading = false.obs;
  bool get isMarkdownLoading => _isMarkdownLoading.value;

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
  
  // 当前显示的语言代码
  final RxString _currentLanguageCode = 'original'.obs;
  String get currentLanguageCode => _currentLanguageCode.value;

  /// 根据ID加载文章数据
  Future<void> loadArticleById(int articleId) async {
    try {
      getLogger().i('🔄 开始加载文章，ID: $articleId');
      _isLoading.value = true;
      _errorMessage.value = '';

      final article = await _articleService.getArticleById(articleId);
      
      if (article != null) {
        _currentArticle.value = article;
        getLogger().i('✅ 文章加载完成: ${article.title}');
        
        // 更新阅读次数
        await _updateReadCount(articleId);
        
        // 加载当前语言的 Markdown 内容
        await loadMarkdownContent();
        
        // 初始化翻译状态（为了在打开翻译弹窗时显示正确状态）
        await _initializeTranslationStatusForCurrentArticle();
      } else {
        _errorMessage.value = '未找到指定的文章';
        getLogger().w('⚠️ 文章不存在，ID: $articleId');
      }
    } catch (e) {
      _errorMessage.value = '加载文章失败: $e';
      getLogger().e('❌ 加载文章失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }


  /// 加载 Markdown 内容
  Future<void> loadMarkdownContent([String? language]) async {
    final article = _currentArticle.value;
    if (article == null) return;

    final targetLanguage = language ?? "original";

    try {
      getLogger().i('📄 开始加载Markdown内容，文章ID: ${article.id}，语言: ${targetLanguage}');
      _isMarkdownLoading.value = true;
      
      // 更新当前语言状态
      _currentLanguageCode.value = targetLanguage;
      
      // 从 ArticleContentDb 获取指定语言的内容
      final articleContent = await _articleService.getArticleContentByLanguage(
        article.id, 
        targetLanguage
      );
      
      if (articleContent != null && articleContent.markdown.isNotEmpty) {
        getLogger().i('✅ 使用ArticleContentDb中的Markdown内容，语言: ${targetLanguage}，长度: ${articleContent.markdown.length}');
        _currentMarkdownContent.value = articleContent.markdown;
      } else {
        getLogger().i('📄 ArticleContentDb 中无该语言的Markdown内容，尝试从服务端获取');
        
        // 如果是原文且有 serviceId，从服务端获取
        if (article.serviceId.isNotEmpty) {
          await _fetchMarkdownFromServer(article.serviceId, article.id, targetLanguage);
        } else {
          _currentMarkdownContent.value = '';
          // getLogger().w('⚠️ 无法获取该语言的Markdown内容: ${targetLanguage.label}');
        }
      }
    } catch (e) {
      getLogger().e('❌ 加载Markdown内容失败: $e');
      _currentMarkdownContent.value = '';
    } finally {
      _isMarkdownLoading.value = false;
    }
  }

  /// 从服务端获取Markdown内容
  Future<void> _fetchMarkdownFromServer(String serviceId, int articleId, String language) async {
    try {
      getLogger().i('🌐 从服务端获取Markdown内容，serviceId: $serviceId，语言: ${language}');
      
      final response = await UserApi.getArticleApi({
        'service_article_id': serviceId,
      });

      if (response['code'] == 0) {
        final data = response['data'];
        final markdownContent = data['markdown_content'] ?? '';
        
        if (markdownContent.isNotEmpty) {
          getLogger().i('✅ 服务端Markdown内容获取成功，长度: ${markdownContent.length}');
          
          // 更新本地状态
          _currentMarkdownContent.value = markdownContent;
          
          // 保存到数据库
          await _saveMarkdownToDatabase(articleId, markdownContent, language);
        } else {
          getLogger().i('ℹ️ 服务端暂无Markdown内容，等待生成');
          _currentMarkdownContent.value = '';
        }
      } else {
        // 检查是否是"系统错误"或类似的服务端错误
        final errorMsg = response['msg'] ?? '获取文章失败';
        if (errorMsg.contains('系统错误') || errorMsg.contains('暂无') || errorMsg.contains('不存在')) {
          getLogger().w('⚠️ 服务端暂无Markdown内容: $errorMsg');
          _currentMarkdownContent.value = '';
        } else {
          throw Exception(errorMsg);
        }
      }
    } catch (e) {
      getLogger().w('⚠️ 获取Markdown内容时出现异常: $e');
      _currentMarkdownContent.value = '';
    }
  }

  /// 保存Markdown内容到数据库
  Future<void> _saveMarkdownToDatabase(int articleId, String markdownContent, String language) async {
    try {
      getLogger().i('💾 保存Markdown内容到ArticleContentDb，文章ID: $articleId，语言: ${language}');
      
      // 保存到 ArticleContentDb 表
      final articleContent = await _articleService.saveOrUpdateArticleContent(
        articleId: articleId,
        markdown: markdownContent,
        languageCode: language,
        isOriginal: language == "original",
      );
      
      // 如果是原文，更新 ArticleDb 的状态
      if (language == "original") {
        final article = await _articleService.getArticleById(articleId);
        if (article != null) {
          article.isGenerateMarkdown = true;
          article.markdownStatus = 1;
          article.updatedAt = DateTime.now();
          await _articleService.saveArticle(article);
        }
      }
      
      getLogger().i('✅ Markdown内容保存成功，ArticleContentDb ID: ${articleContent.id}');

    } catch (e) {
      getLogger().e('❌ 保存Markdown内容到数据库失败: $e');
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
      await _articleService.updateReadStatus(
        articleId,
        isRead: true,
      );
      // 重新加载文章数据以更新计数
      final updatedArticle = await _articleService.getArticleById(articleId);
      if (updatedArticle != null) {
        _currentArticle.value = updatedArticle;
      }
    } catch (e) {
      getLogger().e('❌ 更新阅读计数失败: $e');
    }
  }

  /// 更新阅读进度
  Future<void> updateReadProgress(double progress) async {
    final article = _currentArticle.value;
    if (article == null) return;

    try {
      await _articleService.updateReadStatus(
        article.id,
        isRead: true,
        readProgress: progress,
      );
      
      // 更新本地数据
      article.readProgress = progress;
      _currentArticle.refresh();
      
      getLogger().i('📊 更新阅读进度: ${(progress * 100).toStringAsFixed(1)}%');
    } catch (e) {
      getLogger().e('❌ 更新阅读进度失败: $e');
    }
  }

  /// 标记文章为已读
  Future<void> markAsRead() async {
    final article = _currentArticle.value;
    if (article == null) return;

    try {
      await _articleService.updateReadStatus(
        article.id,
        isRead: true,
        readProgress: 1.0,
      );
      
      // 更新本地数据
      article.isRead = 1;
      article.readProgress = 1.0;
      _currentArticle.refresh();
      
      getLogger().i('✅ 文章已标记为已读');
    } catch (e) {
      getLogger().e('❌ 标记已读失败: $e');
    }
  }

  /// 清除当前文章数据
  void clearCurrentArticle() {
    _currentArticle.value = null;
    _currentMarkdownContent.value = '';
    _errorMessage.value = '';
    getLogger().i('🧹 清除当前文章数据');
  }

  /// 重新加载当前文章
  Future<void> refreshCurrentArticle() async {
    final article = _currentArticle.value;
    if (article != null) {
      await loadArticleById(article.id);
    }
  }

  /// 检查文章是否存在
  bool get hasArticle => _currentArticle.value != null;

  /// 获取文章标题
  String get articleTitle => _currentArticle.value?.title ?? '未知标题';

  /// 获取文章URL
  String get articleUrl => _currentArticle.value?.url ?? '';

  // ============================================================================
  // 翻译相关方法
  // ============================================================================

  /// 开始翻译
  Future<void> startTranslation(String languageCode) async {
    final article = _currentArticle.value;
    if (article == null || article.serviceId.isEmpty) {
      BotToast.showText(text: '文章信息获取失败');
      return;
    }

    getLogger().i('🌐 开始翻译，语言: $languageCode');
    
    // 设置翻译状态为进行中
    _translationStatus[languageCode] = 'translating';

    try {
      // 调用翻译 API
      final response = await UserApi.translateApi({
        'service_article_id': article.serviceId,
        'language_code': languageCode,
      });

      if (response['code'] == 0) {
        final upId = response['data'].toString();
        _translationUpIds[languageCode] = upId;
        
        getLogger().i('✅ 翻译请求成功，up_id: $upId，开始轮询');
        
        // 开始轮询翻译结果
        _startPolling(languageCode, upId);
      } else {
        _translationStatus[languageCode] = 'failed';
        final errorMsg = response['msg'] ?? '翻译请求失败';
        BotToast.showText(text: errorMsg);
        getLogger().e('❌ 翻译请求失败: $errorMsg');
      }
    } catch (e) {
      _translationStatus[languageCode] = 'failed';
      BotToast.showText(text: '翻译请求失败，请重试');
      getLogger().e('❌ 翻译请求异常: $e');
    }
  }

  /// 开始轮询翻译结果
  void _startPolling(String languageCode, String upId) {
    // 清除之前的轮询
    _pollingTimers[languageCode]?.cancel();
    
    // 开始新的轮询，每3秒查询一次
    _pollingTimers[languageCode] = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _checkTranslationResult(languageCode, upId, timer),
    );
  }

  /// 检查翻译结果
  Future<void> _checkTranslationResult(String languageCode, String upId, Timer timer) async {
    try {
      final article = _currentArticle.value;
      if (article == null) {
        timer.cancel();
        return;
      }

      final response = await UserApi.getTranslateContentApi({
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
    } catch (e) {
      getLogger().e('❌ 检查翻译结果异常: $e');
      // 网络错误不停止轮询，继续重试
    }
  }

  /// 保存翻译内容到数据库
  Future<void> _saveTranslatedContent(TranslateContentModel translateContent) async {
    try {
      await _articleService.saveOrUpdateArticleContent(
        articleId: translateContent.articleId,
        markdown: translateContent.markdown,
        languageCode: translateContent.languageCode,
        isOriginal: false,
        serviceId: translateContent.id, // 保存服务端的翻译内容ID
      );
      getLogger().i('💾 翻译内容已保存到数据库，语言: ${translateContent.languageCode}，serviceId: ${translateContent.id}');
    } catch (e) {
      getLogger().e('❌ 保存翻译内容失败: $e');
    }
  }

  /// 重新翻译
  Future<void> retranslate(String languageCode) async {
    // 停止当前轮询
    _pollingTimers[languageCode]?.cancel();
    _pollingTimers.remove(languageCode);
    _translationUpIds.remove(languageCode);
    
    // 重新开始翻译
    await startTranslation(languageCode);
  }

  /// 获取语言翻译状态
  String getTranslationStatus(String languageCode) {
    return _translationStatus[languageCode] ?? 'untranslated';
  }

  /// 检查语言是否已翻译
  Future<bool> isLanguageTranslated(String languageCode) async {
    final article = _currentArticle.value;
    if (article == null) return false;

    // 首先检查内存状态
    if (_translationStatus[languageCode] == 'translated') {
      return true;
    }

    // 检查数据库中是否已有翻译内容
    try {
      final content = await _articleService.getArticleContentByLanguage(
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
    final article = _currentArticle.value;
    if (article == null) return;

    getLogger().i('🔄 初始化所有语言翻译状态，文章ID: ${article.id}');

    try {
      // 获取文章的所有已翻译内容
      final allContents = await _articleService.getAllArticleContents(article.id);
      
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
    await loadMarkdownContent(languageCode);
  }

  /// 清理翻译状态
  void _clearTranslationState() {
    // 取消所有轮询
    for (final timer in _pollingTimers.values) {
      timer?.cancel();
    }
    _pollingTimers.clear();
    _translationUpIds.clear();
    _translationStatus.clear();
  }

  @override
  void onClose() {
    getLogger().i('🔄 ArticleController 销毁');
    _clearTranslationState();
    super.onClose();
  }
}
import 'package:get/get.dart';

import '../db/article/article_db.dart';
import '../db/article/article_service.dart';
import '../basics/logger.dart';

/// 文章控制器
class ArticleController extends GetxController {
  // 获取文章服务实例
  final ArticleService _articleService = ArticleService.instance;

  // 当前文章数据
  final Rx<ArticleDb?> _currentArticle = Rx<ArticleDb?>(null);
  ArticleDb? get currentArticle => _currentArticle.value;

  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // 错误信息
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  // 是否有错误
  bool get hasError => _errorMessage.value.isNotEmpty;

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

  /// 获取文章内容
  String get articleContent => _currentArticle.value?.content ?? '';

  /// 获取文章Markdown内容
  String get articleMarkdown => _currentArticle.value?.markdown ?? '';

  /// 获取分享的原始内容
  String get shareOriginalContent => _currentArticle.value?.shareOriginalContent ?? '';

  /// 获取文章摘要
  String get articleExcerpt => _currentArticle.value?.excerpt ?? '';

  /// 获取阅读进度
  double get readProgress => _currentArticle.value?.readProgress ?? 0.0;

  /// 获取阅读次数
  int get readCount => _currentArticle.value?.readCount ?? 0;

  /// 检查是否已读
  bool get isRead => (_currentArticle.value?.isRead ?? 0) == 1;

  /// 获取创建时间
  DateTime? get createdAt => _currentArticle.value?.createdAt;

  /// 获取更新时间
  DateTime? get updatedAt => _currentArticle.value?.updatedAt;

  @override
  void onClose() {
    getLogger().i('🔄 ArticleController 销毁');
    super.onClose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../route/route_name.dart';
import '../../db/article/article_service.dart';
import '../../db/tag/tag_service.dart';
import '../../db/article/article_db.dart';
import '../../db/database_service.dart';


class IndexWidget extends StatefulWidget {
  const IndexWidget({super.key});

  @override
  State<IndexWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<IndexWidget> with IndexWidgetBLoC, TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 调用AutomaticKeepAliveClientMixin的build方法
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _refreshArticles,
        color: const Color(0xFF007AFF),
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 8),
            _buildUnreadSection(),
            _buildRecentlyReadSection(),
            _buildTagsSection(),
            _buildArticleHeader(),
            _buildArticleList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 构建文章标题栏
  Widget _buildArticleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 4),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFF007AFF),
                  width: 3,
                ),
              ),
            ),
            child: const Text(
              '我的文章',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(articles.length),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '共 ${articles.length} 篇',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

mixin IndexWidgetBLoC on State<IndexWidget> {

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  // 文章列表相关变量
  List<ArticleDb> articles = [];
  List<ArticleDb> unreadArticles = [];
  List<ArticleDb> recentlyReadArticles = [];
  List<TagWithCount> tagsWithCount = [];
  int unreadArticlesCount = 0; // 未读文章总数量

  // 数据缓存时间戳，用于智能刷新
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5); // 缓存有效期5分钟


  @override
  void initState() {
    super.initState();

    // 确保UI完全初始化后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 添加额外延迟确保GetX服务完全就绪
      Future.delayed(const Duration(milliseconds: 500), () {
        print('🚀 开始加载文章列表 (延迟后)');
        _loadArticles();
      });
    });
  }


  /// 刷新文章列表
  Future<void> _refreshArticles() async {
    await _loadArticles(forceRefresh: true);
  }

  /// 获取文章列表
  Future<void> _loadArticles({bool forceRefresh = false}) async {
    // 如果不是强制刷新且缓存仍然有效，则跳过加载
    if (!forceRefresh && _lastLoadTime != null) {
      final cacheAge = DateTime.now().difference(_lastLoadTime!);
      if (cacheAge < _cacheValidDuration) {
        print('📋 使用缓存数据，缓存时间: ${cacheAge.inMinutes}分钟');
        return;
      }
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      // 添加详细的调试信息
      print('📋 开始获取文章列表...');

      // 检查GetX依赖是否正常
      try {
        final articleService = ArticleService.instance;
        print('✅ ArticleService 获取成功: ${articleService.runtimeType}');
      } catch (e) {
        print('❌ ArticleService 获取失败: $e');
        // 尝试手动注册
        print('🔧 尝试手动注册 ArticleService...');
        Get.put(ArticleService(), permanent: true);
        print('✅ ArticleService 手动注册完成');
      }

      // 检查数据库服务是否已初始化
      final dbService = DatabaseService.instance;
      print('🗄️ 数据库是否已初始化: ${dbService.isInitialized}');

      if (!dbService.isInitialized) {
        print('⏳ 数据库未初始化，正在初始化...');
        await dbService.initDb();
        print('✅ 数据库初始化完成');
      }

      // 直接查询数据库中的文章总数
      final totalCount = await dbService.articles.count();
      print('📊 数据库中文章总数: $totalCount');

      // 执行正常的查询
      final results = await Future.wait([
        ArticleService.instance.getAllArticles(),
        ArticleService.instance.getUnreadArticles(limit: 5),
        ArticleService.instance.getRecentlyReadArticles(limit: 5),
        TagService.instance.getTagsWithArticleCount(),
        ArticleService.instance.getUnreadArticlesCount(), // 获取未读文章总数量
      ]);
      final articleList = results[0] as List<ArticleDb>;
      final unreadList = results[1] as List<ArticleDb>;
      final recentlyReadList = results[2] as List<ArticleDb>;
      final tagsList = results[3] as List<TagWithCount>;
      final unreadCount = results[4] as int;


      if (articleList.isNotEmpty) {
        final firstArticle = articleList.first;
      }

      setState(() {
        articles = articleList;
        unreadArticles = unreadList;
        recentlyReadArticles = recentlyReadList;
        tagsWithCount = tagsList;
        unreadArticlesCount = unreadCount; // 使用真实的未读文章总数量
        isLoading = false;
        _lastLoadTime = DateTime.now(); // 更新缓存时间
      });

    } catch (e, stackTrace) {
      print('❌ 获取文章列表失败: $e   堆栈跟踪: $stackTrace');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  /// 构建文章列表
  Widget _buildArticleList() {

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '加载中...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Color(0xFFFF3B30),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadArticles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (articles.isEmpty) {
      print('📝 显示空状态 - articles.isEmpty=${articles.isEmpty}');
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 40,
                color: Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '暂无文章',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '分享内容到应用即可自动保存',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: _buildArticleItem(article),
        );
      },
    );
  }

  /// 构建文章列表项
  Widget _buildArticleItem(ArticleDb article) {
    final hasUrl = article.url.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/${RouteName.articlePage}?id=${article.id}');
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF007AFF).withOpacity(0.1),
          highlightColor: const Color(0xFF007AFF).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    // URL 指示器
                    if (hasUrl)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '链接',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (hasUrl) const SizedBox(width: 12),
                    // 标题
                    Expanded(
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // 摘要
                if (article.excerpt?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    article.excerpt!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6D6D70),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // 底部信息
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: const Color(0xFF8E8E93).withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MM-dd HH:mm').format(article.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (article.isRead == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '已读',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF34C759),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// 构建最近阅读文章区域
  Widget _buildRecentlyReadSection() {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '最近阅读',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: recentlyReadArticles.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 32,
                      color: Color(0xFFD1D1D6),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '暂无最近阅读记录',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recentlyReadArticles.expand((article) {
                final index = recentlyReadArticles.indexOf(article);
                return [
                  if (index > 0)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE5E5EA).withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.push('/${RouteName.articlePage}?id=${article.id}');
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: const Color(0xFF34C759).withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34C759),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                article.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1D1D1F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFFD1D1D6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签区域
  Widget _buildTagsSection() {
    if (tagsWithCount.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  size: 20,
                  color: Color(0xFFFF9500),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '我的标签',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: tagsWithCount.map((tagWithCount) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('筛选标签: ${tagWithCount.tag.name}'),
                        backgroundColor: const Color(0xFF007AFF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: const Color(0xFFFF9500).withOpacity(0.2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9500).withOpacity(0.1),
                          const Color(0xFFFF9500).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF9500).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: 14,
                          color: const Color(0xFFFF9500),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tagWithCount.tag.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1D1D1F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${tagWithCount.count}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建未读文章区域
  Widget _buildUnreadSection() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _navigateToReadLaterList(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      size: 20,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '稍后阅读',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  const Spacer(),
                  if (unreadArticlesCount > 0)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(unreadArticlesCount),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '共 $unreadArticlesCount 篇',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: unreadArticles.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 32,
                      color: Color(0xFFD1D1D6),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '暂无需要稍后阅读的文章',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: unreadArticles.expand((article) {
                final index = unreadArticles.indexOf(article);
                return [
                  if (index > 0)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE5E5EA).withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      context.push('/${RouteName.articlePage}?id=${article.id}');
                    },
                    borderRadius: BorderRadius.circular(8),
                    splashColor: const Color(0xFF007AFF).withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              article.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1D1D1F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFFD1D1D6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 导航到稍后阅读列表页
  void _navigateToReadLaterList() {
    context.push('/${RouteName.articleList}?type=read-later&title=稍后阅读');
  }


}
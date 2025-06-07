import 'dart:io';
import 'dart:typed_data';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import '../../../route/route_name.dart';
import '../../db/article/article_service.dart';
import '../../db/article/article_db.dart';
import '../../db/database_service.dart';
import 'package:get/get.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin, IndexPageBLoC {

@override
  Widget build(BuildContext context) {
    return Scaffold( 
      // appBar: AppBar(
      //   title: const Text('InAppWebView Demo'),
      //   backgroundColor: Colors.blue,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: Row(
                children: [
                  // 左边的"我的"图标
                  GestureDetector(
                    onTap: () {
                      // 处理"我的"点击事件
                      // TODO: 添加"我的"页面路由
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('我的页面')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Icon(
                        Icons.person_outline,
                        size: 24,
                        color: Color(0xFF161514),
                      ),
                    ),
                  ),
                  // 中间的 SegmentedTabControl
                  Expanded(
                    child: SegmentedTabControl(
                      controller: tabController, // 使用自定义的TabController
                      barDecoration: BoxDecoration(
                        color: Color(0xFFF3F2F1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      tabTextColor: Color(0xFF161514),
                      selectedTabTextColor: Color(0xFFF3F2F1),
                      squeezeIntensity: 3,
                      height: 28,
                      tabPadding: EdgeInsets.symmetric(horizontal: 8),
                      tabs: tabs,
                    ),
                  ),
                  // 右边的"添加"图标
                  GestureDetector(
                    onTap: () {
                      // 处理"添加"点击事件
                      // TODO: 添加"添加"页面路由
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('添加功能')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 24,
                        color: Color(0xFF161514),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  // 记录滑动增量
                  _updatePanDelta(details.delta);
                },
                onPanEnd: (details) {
                  // 检查是否应该切换页面
                  _handlePanEnd();
                },
                child: TabBarView(
                  controller: tabController, // 使用自定义的TabController
                  physics: const NeverScrollableScrollPhysics(), // 禁用默认滑动切换
                  clipBehavior: Clip.none, // 避免裁剪问题
                  children: [
                    _buildArticleListPage(), // 动态构建
                    Container(
                      child: const Center(
                        child: Text('收藏页面', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

mixin IndexPageBLoC on State<IndexPage> {

  late TabController tabController;
  List<SegmentTab> tabs = [];
  
  // 手势检测相关变量
  double _totalDx = 0.0; // 水平滑动总距离
  double _totalDy = 0.0; // 垂直滑动总距离
  static const double _horizontalThreshold = 80.0; // 水平滑动阈值
  static const double _verticalTolerance = 80.0; // 垂直滑动容忍度

  // 文章列表相关变量
  List<ArticleDb> articles = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  // 更新滑动增量
  void _updatePanDelta(Offset delta) {
    _totalDx += delta.dx;
    _totalDy += delta.dy.abs(); // 垂直距离取绝对值
  }

  // 处理滑动结束
  void _handlePanEnd() {
    // 只有当水平滑动距离足够大，且垂直滑动距离相对较小时，才切换页面
    if (_totalDx.abs() > _horizontalThreshold && _totalDy < _verticalTolerance) {
      if (_totalDx > 0) {
        // 向右滑动，切换到上一个tab
        if (tabController.index > 0) {
          tabController.animateTo(tabController.index - 1);
        }
      } else {
        // 向左滑动，切换到下一个tab
        if (tabController.index < tabController.length - 1) {
          tabController.animateTo(tabController.index + 1);
        }
      }
    }
    
    // 重置滑动距离
    _totalDx = 0.0;
    _totalDy = 0.0;
  }

  /// 获取文章列表
  Future<void> _loadArticles() async {
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
      final articleList = await ArticleService.instance.getAllArticles();
      print('📋 查询结果数量: ${articleList.length}');
      
      if (articleList.isNotEmpty) {
        print('📄 第一篇文章信息:');
        final firstArticle = articleList.first;
        print('  - ID: ${firstArticle.id}, 标题: ${firstArticle.title}, 创建时间: ${firstArticle.createdAt}');
      }
      
      setState(() {
        print('🔄 setState 前: articles.length = ${articles.length}');
        articles = articleList;
        isLoading = false;
        print('🔄 setState 后: articles.length = ${articles.length}');
      });
      
      print('✅ 文章列表加载完成: ${articles.length} 篇文章');
    } catch (e, stackTrace) {
      print('❌ 获取文章列表失败: $e');
      print('堆栈跟踪: $stackTrace');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  /// 刷新文章列表
  Future<void> _refreshArticles() async {
    await _loadArticles();
  }

  /// 删除文章
  Future<void> _deleteArticle(ArticleDb article) async {
    try {
      final success = await ArticleService.instance.deleteArticle(article.id);
      if (success) {
        setState(() {
          articles.removeWhere((item) => item.id == article.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文章删除成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：$e')),
      );
    }
  }

  /// 构建文章列表页面
  Widget _buildArticleListPage() {
    return RefreshIndicator(
      onRefresh: _refreshArticles,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

    Container(
      // 添加一些内容以便测试滑动效果
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              await context.push('/${RouteName.articlePage}');
            },
            child: Center(
              child: Text('文章页面', style: TextStyle(fontSize: 18)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              await context.push('/${RouteName.articlePage2}');
            },
            child: Center(
              child: Text('文章页面2', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    ),

            // 标题栏
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Text(
                    '我的文章',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF161514),
                    ),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      print('📊 标题栏显示: articles.length = ${articles.length}');
                      return Text(
                        '共 ${articles.length} 篇',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 文章列表
            Expanded(
              child: _buildArticleList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文章列表
  Widget _buildArticleList() {

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text('加载失败：$errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadArticles,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (articles.isEmpty) {
      print('📝 显示空状态 - articles.isEmpty=${articles.isEmpty}');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('暂无文章'),
            SizedBox(height: 8),
            Text(
              '分享内容到应用即可自动保存',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildArticleItem(article);
      },
    );
  }

  /// 构建文章列表项
  Widget _buildArticleItem(ArticleDb article) {
    final hasUrl = article.url.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: InkWell(
        onTap: () {
          // 打印详细的文章信息
          print('📰 ==========  文章详细信息  ==========');
          print('📋 文章ID: ${article.id}');
          print('📝 标题: ${article.title}');
          print('🔗 URL: ${article.url}');
          print('📄 摘要: ${article.excerpt ?? "无摘要"}');
          print('📖 内容: ${article.content ?? "无内容"}');
          print('📑 Markdown: ${article.markdown}');
          print('💾 MHTML路径: ${article.mhtmlPath}');
          print('📤 分享原始内容: ${article.shareOriginalContent}');
          print('🏷️ 标签: ${article.tags}');
          print('📚 是否已读: ${article.isRead == 1 ? "已读" : "未读"}');
          print('🔢 阅读次数: ${article.readCount}');
          print('⏱️ 阅读时长: ${article.readDuration}秒');
          print('📊 阅读进度: ${(article.readProgress * 100).toStringAsFixed(1)}%');
          print('📅 创建时间: ${article.createdAt}');
          print('🔄 更新时间: ${article.updatedAt}');
          print('========================================');
          
          // TODO: 跳转到文章详情页
          context.push('/${RouteName.articlePage}?id=${article.id}');
          // if (hasUrl) {
          //   // 如果有URL，可以跳转到网页查看
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('打开链接：${article.url}')),
          //   );
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('查看文章：${article.title}')),
          //   );
          // }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  // URL 指示器
                  if (hasUrl)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '链接',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF00BCF6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (hasUrl) const SizedBox(width: 8),
                  // 标题
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF161514),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 删除按钮
                  GestureDetector(
                    onTap: () => _showDeleteDialog(article),
                    child: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              
              // 摘要
              if (article.excerpt?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  article.excerpt!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              
              // 底部信息
              Row(
                children: [
                  // 创建时间
                  Text(
                    DateFormat('MM-dd HH:mm').format(article.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const Spacer(),
                  // 标签
                  if (article.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: article.tags.take(2).map((tag) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteDialog(ArticleDb article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除文章'),
          content: Text('确定要删除「${article.title}」吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteArticle(article);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

    @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2, 
      vsync: this as TickerProvider,
      animationDuration: const Duration(milliseconds: 350), // 优化切换动画时长
    );
    
    // 添加页面切换监听，确保tab指示器与页面同步
    tabController.addListener(() {
      // 监听tab切换，保持状态同步
      if (mounted) {
        setState(() {});
      }
    });

    tabs.add(const SegmentTab(label: '首页', color: Color(0xFF00BCF6)));
    tabs.add(const SegmentTab(label: '收藏', color: Color(0xFF00BCF6)));
    
    // 确保UI完全初始化后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 添加额外延迟确保GetX服务完全就绪
      Future.delayed(const Duration(milliseconds: 500), () {
        print('🚀 开始加载文章列表 (延迟后)');
        _loadArticles();
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

}

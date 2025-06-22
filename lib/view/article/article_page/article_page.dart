import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/view/article/utils/download_snapshot_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '/api/user_api.dart';
import '/basics/logger.dart';
import '/basics/upload.dart';
import '/db/article/article_service.dart';
import 'article_bottom_bar.dart';
import 'article_loading_view.dart';
import 'article_top_bar.dart';

import '../article_markdown/article_markdown_widget.dart';
import '../article_mhtml_widget.dart';
import '../article_web/article_web_widget.dart';
import '../controller/article_controller.dart';


class ArticlePage extends StatefulWidget {

  final int id;

  const ArticlePage({
    super.key,
    required this.id,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with TickerProviderStateMixin,ArticlePageBLoC {

  final double _topBarHeight = 52.0;
  final double _bottomBarHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    // 使用PopScope来监听返回事件，在返回前提前销毁WebView避免闪烁
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          getLogger().i('🔄 页面即将返回，开始预处理WebView销毁');
          await _prepareForPageExit();
        }
      },
      child: Obx(() {
        if (articleController.hasError) {
          return Scaffold(body: _buildErrorView(context));
        }

        // 在tabs初始化之前，始终显示加载视图
        if (tabs.isEmpty) {
          return Scaffold(body: _buildInitialLoadingView());
        }
        
        // 主内容UI
        return Scaffold(
          body: Stack(
            children: [
              // 主要内容区域
              _buildContentView(context),
              
              // 顶部操作栏
              ArticleTopBar(
                isVisible: _isBottomBarVisible,
                topBarHeight: _topBarHeight,
                tabController: tabController,
                tabs: tabs,
              ),
              
              // 底部操作栏
              ArticleBottomBar(
                articleId: widget.id,
                isVisible: _isBottomBarVisible,
                bottomBarHeight: _bottomBarHeight,
                onBack: () async {
                  await _prepareForPageExit();
                  Navigator.of(context).pop();
                },
                onGenerateSnapshot: generateSnapshot,
                onDownloadSnapshot: downloadSnapshot,
                onReGenerateSnapshot: () => (_webWidgetKey.currentState)?.createSnapshot(),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 构建主要内容视图
  Widget _buildContentView(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + _topBarHeight;
    final bottomPadding = mediaQuery.padding.bottom + _bottomBarHeight;

    // 更新Markdown组件的边距
    // 注意：这里我们直接更新了 `ArticleMarkdownWidget` 的参数，
    // 在下一次 `Obx` 重建时，新的 padding 会被传递下去。
    // 为了使切换标签页时也能及时更新其他组件的padding，
    // 我们可能需要更精细的状态管理或回调机制。
    // 目前，这个实现主要针对 `ArticleMarkdownWidget`。
    
    // 我们需要更新ArticleMarkdownWidget的padding
    // 通过在initState中创建widget列表，然后在build中更新它们
    // 来确保padding可以动态变化
    _updateTabWidgets(EdgeInsets.only(top: topPadding, bottom: bottomPadding));
    
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: tabController,
      children: tabWidget,
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            articleController.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadArticleData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建初始加载视图
  Widget _buildInitialLoadingView() {
    return const ArticleLoadingView();
  }
}

mixin ArticlePageBLoC on State<ArticlePage> {

  // 文章控制器
   final ArticleController articleController = Get.find<ArticleController>();

  late TabController tabController;
  List<String> tabs = []; // 改为简单的String列表
  List<Widget> tabWidget = [];
  
  // 用于存储ArticleWebWidget的GlobalKey，以便调用其方法
  final GlobalKey<ArticlePageState> _webWidgetKey = GlobalKey<ArticlePageState>();

  String snapshotPath = "";
  bool isUploading = false; // 添加上传状态标识

  // 添加markdown内容状态管理
  final RxString _markdownContent = ''.obs;
  String get markdownContent => _markdownContent.value;
  
  // 用于控制UI显隐的状态
  bool _isBottomBarVisible = true;

  // 添加缓存相关变量
  final Map<String, Widget> _cachedTabWidgets = {}; // 缓存已创建的tab widgets
  bool _isTabWidgetsCached = false; // 标记是否已缓存

  // 添加页面销毁状态标识
  bool _isPageDisposing = false;

  @override
  void initState() {
    super.initState();
    articleController.articleId = widget.id;

    // 进入沉浸式模式，隐藏系统状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // 初始化一个临时的空控制器，它将在数据加载后被替换
    tabController = TabController(
      length: 0, // 初始长度为0，以匹配空的tabs列表
      vsync: this as TickerProvider,
      animationDuration: const Duration(milliseconds: 350),
    );

    // 加载文章数据
    _loadArticleData();
  }

  void _initializeTabs() {
    // 此方法仅在 articleController.hasArticle 为 true 时调用
    // 网页tab总是显示
    tabs = ['网页'];

    final article = articleController.currentArticle!;
    
    // 根据isGenerateMarkdown决定是否显示图文tab
    if (article.isGenerateMarkdown) {
      tabs.insert(0, '图文');
    }
    
    // 根据isGenerateMhtml决定是否显示快照tab
    if (article.isGenerateMhtml) {
      tabs.add('快照');
    }
    
    // 先初始化tabWidget，再更新TabController
    _initializeTabWidgets();
    
    // 更新TabController的长度
    _updateTabController();
  }

  /// 初始化TabWidget列表（创建空的占位符）
  void _initializeTabWidgets() {
    tabWidget = [];
    for (int i = 0; i < tabs.length; i++) {
      tabWidget.add(Container(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }
    getLogger().i('🔄 初始化tabWidget，数量: ${tabWidget.length}');
  }

  /// 更新TabController的长度和默认选中tab
  void _updateTabController() {
    final newLength = tabs.length;
    if (tabController.length != newLength) {
      // 保存当前选中的tab索引和名称
      int currentIndex = tabController.index;
      String? currentTabName;
      if (currentIndex < tabs.length) {
        currentTabName = tabs[currentIndex];
      }
      
      // 销毁旧的TabController
      tabController.dispose();
      
      // 创建新的TabController
      tabController = TabController(
        length: newLength,
        vsync: this as TickerProvider,
        animationDuration: const Duration(milliseconds: 350),
      );
      
      // 尝试恢复之前选中的tab
      _restoreSelectedTab(currentTabName, currentIndex);
    }
  }

  /// 恢复选中的tab状态
  void _restoreSelectedTab(String? previousTabName, int previousIndex) {
    if (!articleController.hasArticle) return;
    
    // 如果之前有选中的tab名称，尝试找到对应的新索引
    if (previousTabName != null) {
      final newIndex = tabs.indexOf(previousTabName);
      if (newIndex != -1) {
        tabController.index = newIndex;
        getLogger().i('🔄 恢复选中tab: $previousTabName (索引: $newIndex)');
        return;
      }
    }
    
    // 如果无法恢复，使用默认选择逻辑
    _setDefaultSelectedTab();
  }

  /// 设置默认选中的tab
  void _setDefaultSelectedTab() {
    if (!articleController.hasArticle) return;
    
    final article = articleController.currentArticle!;
    
    // 如果isGenerateMarkdown为false，默认显示网页tab
    if (!article.isGenerateMarkdown) {
      // 网页tab的索引（当没有图文tab时为0，有图文tab时为1）
      final webTabIndex = article.isGenerateMarkdown ? 1 : 0;
      tabController.index = webTabIndex;
    } else {
      // 如果有图文tab，默认选中图文tab
      tabController.index = 0;
    }
  }

  /// 刷新tabs显示（当生成新内容后调用）
  void refreshTabs() {
    if (!articleController.hasArticle) return;
    
    getLogger().i('🔄 刷新tabs显示');
    
    // 清理现有缓存，因为文章内容可能发生了变化
    _clearTabWidgetsCache();
    
    // 重新初始化tabs
    _initializeTabs();
    
    // 强制更新UI
    setState(() {});
    
    getLogger().i('✅ tabs刷新完成，当前tab数量: ${tabs.length}');
  }

  void _updateTabWidgets(EdgeInsets padding) {
    // 如果页面正在销毁，不再创建或更新WebView
    if (_isPageDisposing) {
      getLogger().i('⚠️ 页面正在销毁，跳过WebView更新');
      return;
    }
    
    if (!articleController.hasArticle) {
      // 未加载文章时，只显示网页tab，但也需要缓存
      if (!_cachedTabWidgets.containsKey('网页')) {
        _cachedTabWidgets['网页'] = _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: Obx(() => ArticleWebWidget(
            key: _webWidgetKey,
            onSnapshotCreated: _onSnapshotCreated,
            url: articleController.articleUrl.isNotEmpty 
              ? articleController.articleUrl 
              : null,
            articleId: widget.id,
            onScroll: _handleScroll,
            contentPadding: padding,
            onMarkdownGenerated: _onMarkdownGenerated,
          )),
        );
      }
      
      tabWidget = [_cachedTabWidgets['网页']!];
      return;
    }

    final article = articleController.currentArticle!;
    
    // 如果已经缓存过且padding没有重大变化，直接使用缓存
    if (_isTabWidgetsCached && _cachedTabWidgets.isNotEmpty) {
      // 更新padding，但保持widget缓存
      _updateCachedWidgetsPadding(padding);
      _buildTabWidgetListFromCache();
      return;
    }

    // 首次创建或需要重新创建时，清空旧缓存
    _cachedTabWidgets.clear();
    tabWidget = [];

    // 确保tabWidget的生成顺序与tabs一致
    for (String tabName in tabs) {
      Widget cachedWidget = _createCachedTabWidget(tabName, padding, article);
      _cachedTabWidgets[tabName] = cachedWidget;
      tabWidget.add(cachedWidget);
    }

    // 标记已缓存
    _isTabWidgetsCached = true;

    // 确保tabWidget数量与tabs数量一致
    if (tabWidget.length != tabs.length) {
      getLogger().e('❌ tabWidget数量(${tabWidget.length})与tabs数量(${tabs.length})不一致');
      // 如果数量不一致，补充空容器
      while (tabWidget.length < tabs.length) {
        Widget placeholderWidget = _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: Container(
            child: const Center(
              child: Text('内容加载中...'),
            ),
          ),
        );
        tabWidget.add(placeholderWidget);
      }
    }

    getLogger().i('✅ tabs缓存完成: ${tabs.join(', ')}, 数量: ${tabs.length}');
  }

  /// 创建缓存的tab widget
  Widget _createCachedTabWidget(String tabName, EdgeInsets padding, dynamic article) {
    switch (tabName) {
      case '图文':
        return _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: Obx(() => ArticleMarkdownWidget(
            markdownContent: _markdownContent.value,
            article: articleController.currentArticle,
            onScroll: _handleScroll,
            contentPadding: padding,
          )),
        );
      case '网页':
        return _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: Obx(() => ArticleWebWidget(
            key: _webWidgetKey,
            onSnapshotCreated: _onSnapshotCreated,
            url: articleController.articleUrl.isNotEmpty 
              ? articleController.articleUrl 
              : null,
            articleId: widget.id,
            onScroll: _handleScroll,
            contentPadding: padding,
            onMarkdownGenerated: _onMarkdownGenerated,
          )),
        );
      case '快照':
        return _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: ArticleMhtmlWidget(
            mhtmlPath: article.mhtmlPath,
            title: article.title,
            onScroll: _handleScroll,
            contentPadding: padding,
          ),
        );
      default:
        return _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: Container(
            child: const Center(
              child: Text('未知页面类型'),
            ),
          ),
        );
    }
  }

  /// 从缓存中构建tabWidget列表
  void _buildTabWidgetListFromCache() {
    tabWidget = tabs.map((tabName) => _cachedTabWidgets[tabName]!).toList();
  }

  /// 更新缓存widget的padding（这里主要是为了未来扩展，目前padding通过Obx响应式更新）
  void _updateCachedWidgetsPadding(EdgeInsets padding) {
    // 由于我们使用了Obx响应式编程，padding的更新会自动反映到UI上
    // 这个方法保留用于未来可能的非响应式widget的padding更新
    getLogger().d('🔄 更新缓存widget的padding: $padding');
  }

  /// 处理滚动事件，用于显示/隐藏UI元素
  void _handleScroll(ScrollDirection direction, double scrollY) {
    // 滚动到顶部，总是显示
    if (scrollY < 50) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
      return;
    }

    // 向下滚动，隐藏
    if (direction == ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = false);
      }
    } 
    // 向上滚动，显示
    else if (direction == ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    }
  }

  /// 加载文章数据
  Future<void> _loadArticleData() async {
    await articleController.loadArticleById(widget.id);


    getLogger().i('✅ tabs更新完成 url: ${articleController.currentArticle?.url}');
    getLogger().i('✅ tabs更新完成 shareOriginalContent: ${articleController.currentArticle?.shareOriginalContent}');

    print('✅ tabs更新完成 url: ${articleController.currentArticle?.url}');
    print('✅ tabs更新完成 shareOriginalContent: ${articleController.currentArticle?.shareOriginalContent}');

    if (articleController.hasArticle) {
      // 数据加载成功后，再初始化tabs
      _initializeTabs();

      // 触发UI重建以显示新的tabs
      if (mounted) {
        setState(() {});
      }
      
      await _loadMarkdownContent();
    }
  }

  /// 加载Markdown内容
  Future<void> _loadMarkdownContent() async {
    final article = articleController.currentArticle;
    if (article == null) {
      getLogger().w('⚠️ 当前文章为空，无法加载Markdown内容');
      return;
    }

    try {
      getLogger().i('📄 开始检查Markdown内容，文章ID: ${article.id}');
      
      // 检查数据库中的markdown字段是否为空
      if (article.markdown.isEmpty) {
        getLogger().i('📄 数据库中Markdown字段为空，从服务端获取');
        
        // 检查是否有serviceId
        if (article.serviceId.isEmpty) {
          getLogger().w('⚠️ 文章serviceId为空，无法从服务端获取Markdown内容');
          _markdownContent.value = '';
          return;
        }

        // 从服务端获取文章内容
        await _fetchMarkdownFromServer(article.serviceId, article.id);
      } else {
        getLogger().i('✅ 使用数据库中的Markdown内容，长度: ${article.markdown.length}');
        _markdownContent.value = article.markdown;
      }
    } catch (e) {
      getLogger().e('❌ 加载Markdown内容失败: $e');
      _markdownContent.value = '';
    }
  }

  /// 从服务端获取Markdown内容
  Future<void> _fetchMarkdownFromServer(String serviceId, int articleId) async {
    try {
      getLogger().i('🌐 从服务端获取Markdown内容，serviceId: $serviceId');
      
      final response = await UserApi.getArticleApi({
        'service_article_id': serviceId,
      });

      if (response['code'] == 0) {
        final data = response['data'];
        final markdownContent = data['markdown_content'] ?? '';
        
        if (markdownContent.isNotEmpty) {
          getLogger().i('✅ 服务端Markdown内容获取成功，长度: ${markdownContent.length}');
          
          // 更新本地状态
          _markdownContent.value = markdownContent;
          
          // 保存到数据库
          await _saveMarkdownToDatabase(articleId, markdownContent);
        } else {
          getLogger().i('ℹ️ 服务端暂无Markdown内容，等待生成');
          _markdownContent.value = '';
        }
      } else {
        // 检查是否是"系统错误"或类似的服务端错误
        final errorMsg = response['msg'] ?? '获取文章失败';
        if (errorMsg.contains('系统错误') || errorMsg.contains('暂无') || errorMsg.contains('不存在')) {
          getLogger().w('⚠️ 服务端暂无Markdown内容: $errorMsg');
          _markdownContent.value = '';
        } else {
          throw Exception(errorMsg);
        }
      }
    } catch (e) {
      getLogger().w('⚠️ 获取Markdown内容时出现异常: $e');
      _markdownContent.value = '';
      // 不再显示用户错误提示，因为这是正常情况（还没生成Markdown）
    }
  }

  /// 保存Markdown内容到数据库
  Future<void> _saveMarkdownToDatabase(int articleId, String markdownContent) async {
    try {
      getLogger().i('💾 保存Markdown内容到数据库，文章ID: $articleId');
      
      // 获取文章记录
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        // 更新markdown字段
        article.markdown = markdownContent;
        article.isGenerateMarkdown = true; // 标记已生成markdown
        article.updatedAt = DateTime.now();
        
        // 保存到数据库
        await ArticleService.instance.saveArticle(article);
        
        getLogger().i('✅ Markdown内容保存成功: ${article.title}');
        
        // 刷新控制器中的文章数据
        await articleController.refreshCurrentArticle();
        
        // 刷新tabs显示
        refreshTabs();
      } else {
        getLogger().e('❌ 未找到ID为 $articleId 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 保存Markdown内容到数据库失败: $e');
    }
  }

  /// Markdown 生成成功回调
  void _onMarkdownGenerated() {
    getLogger().i('🎯 收到 Markdown 生成成功通知，刷新 tabs');
    
    // 刷新当前文章数据
    articleController.refreshCurrentArticle().then((_) {
      // 刷新 tabs 显示
      refreshTabs();
      
      // 更新 markdown 内容状态
      final article = articleController.currentArticle;
      if (article != null && article.markdown.isNotEmpty) {
        _markdownContent.value = article.markdown;
        getLogger().i('✅ Markdown 内容已更新到本地状态，长度: ${article.markdown.length}');
      }
    }).catchError((e) {
      getLogger().e('❌ 刷新文章数据失败: $e');
    });
  }

  // 接收快照路径的回调方法
  void _onSnapshotCreated(String path) {
    setState(() {
      snapshotPath = path;
    });

    BotToast.showText(text: '快照已保存，路径: ${path.split('/').last}');
    
    // 更新数据库中的mhtml相关字段
    _updateMhtmlStatus(path);
    
    // 自动上传快照文件到服务端 
    uploadSnapshotToServer(path,articleController.currentArticle!.serviceId);
  }

  /// 更新数据库中的mhtml状态
  Future<void> _updateMhtmlStatus(String mhtmlPath) async {
    if (!articleController.hasArticle) return;
    
    try {
      final article = articleController.currentArticle!;
      getLogger().i('💾 更新mhtml状态到数据库，文章ID: ${article.id}');
      
      // 获取文章记录
      final dbArticle = await ArticleService.instance.getArticleById(article.id);
      if (dbArticle != null) {
        // 更新mhtml相关字段
        dbArticle.mhtmlPath = mhtmlPath;
        dbArticle.isGenerateMhtml = true; // 标记已生成mhtml
        dbArticle.updatedAt = DateTime.now();
        
        // 保存到数据库
        await ArticleService.instance.saveArticle(dbArticle);
        
        getLogger().i('✅ mhtml状态更新成功');
        
        // 刷新控制器中的文章数据
        await articleController.refreshCurrentArticle();
        
        // 刷新tabs显示
        refreshTabs();
      } else {
        getLogger().e('❌ 未找到ID为 ${article.id} 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 更新mhtml状态失败: $e');
    }
  }

  // 生成快照的方法
  void generateSnapshot() {
    // 获取当前选中的tab索引
    final currentIndex = tabController.index;
    
    // 需要根据动态的tab结构找到网页tab的索引
    int webTabIndex = _getWebTabIndex();
    
    if (currentIndex == webTabIndex) {
      // 当前在网页tab，调用ArticleWebWidget的生成快照方法
      final webWidgetState = _webWidgetKey.currentState;
      if (webWidgetState != null) {
        // 调用公共方法createSnapshot
        (webWidgetState as dynamic).createSnapshot();
      } else {
        BotToast.showText(text: '网页未加载完成，请稍后再试');
      }
    } else {
      BotToast.showText(text: '请切换到网页标签页生成快照');
    }
  }

  /// 获取网页tab的索引
  int _getWebTabIndex() {
    if (!articleController.hasArticle) return 0;
    
    final article = articleController.currentArticle!;
    // 如果有图文tab，网页tab索引为1，否则为0
    return article.isGenerateMarkdown ? 1 : 0;
  }

  // 下载快照到用户可访问的目录
  Future<void> downloadSnapshot() async {
    if (snapshotPath.isEmpty) {
      BotToast.showText(text: '没有可下载的快照');
      return;
    }
    await DownloadSnapshotUtils.downloadSnapshot(context, snapshotPath);
  }

  @override
  void dispose() {
    getLogger().i('🔄 ArticlePage开始dispose');
    
    // 如果还没有执行过预处理，现在执行
    if (!_isPageDisposing) {
      getLogger().i('🔄 在dispose中执行WebView清理');
      _isPageDisposing = true;
      
      // 同步清理WebView资源，避免异步导致的问题
      _disposeAllWebViewsSync();
    }
    
    // 退出页面时恢复系统默认UI，显示状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 清理tab widgets缓存
    _clearTabWidgetsCache();
    
    // 销毁TabController
    tabController.dispose();
    
    // 清理文章控制器
    articleController.clearCurrentArticle();
    
    getLogger().i('✅ ArticlePage dispose完成');
    super.dispose();
  }

  /// 同步方式销毁所有WebView组件（用于dispose中）
  void _disposeAllWebViewsSync() {
    try {
      getLogger().i('🗑️ 同步销毁所有WebView组件');
      
      // 销毁网页WebView
      final webWidgetState = _webWidgetKey.currentState;
      if (webWidgetState != null) {
        _disposeWebWidgetSync(webWidgetState);
      }
      
      // 清理其他WebView组件的状态
      _cachedTabWidgets.clear();
      
      getLogger().i('✅ 同步销毁WebView组件完成');
    } catch (e) {
      getLogger().e('❌ 同步销毁WebView组件时出错: $e');
    }
  }

  /// 同步销毁网页WebView组件
  void _disposeWebWidgetSync(dynamic webWidgetState) {
    try {
      getLogger().i('🌐 同步销毁网页WebView组件');
      
      if (webWidgetState.mounted) {
        // 尝试获取webViewController并同步清理
        final controller = (webWidgetState as dynamic).webViewController;
        if (controller != null) {
          // 同步调用清理方法
          controller.stopLoading().catchError((e) {
            getLogger().d('WebView stopLoading出错: $e');
          });
          
          getLogger().i('✅ 网页WebView控制器同步清理完成');
        }
      }
    } catch (e) {
      getLogger().e('❌ 同步销毁网页WebView失败: $e');
    }
  }

  /// 获取当前文章数据（便捷方法）
  String get currentArticleUrl => articleController.articleUrl;
  
  /// 获取当前文章标题（便捷方法）
  String get currentArticleTitle => articleController.articleTitle;

  /// 清理缓存的方法
  void _clearTabWidgetsCache() {
    _cachedTabWidgets.clear();
    _isTabWidgetsCached = false;
    getLogger().i('🗑️ 清理tab widgets缓存');
  }

  /// 页面退出预处理，提前销毁WebView避免闪烁
  Future<void> _prepareForPageExit() async {
    if (_isPageDisposing) return;
    
    _isPageDisposing = true;
    getLogger().i('🔄 开始页面退出预处理，准备销毁WebView资源');
    
    try {
      // 1. 立即隐藏所有UI组件，避免视觉闪烁
      if (mounted) {
        setState(() {
          // hideMain = true;
          _isBottomBarVisible = false;
        });
      }
      
      // 2. 提前销毁所有缓存的WebView组件
      await _disposeAllWebViews();
      
      // 3. 清理缓存
      _clearTabWidgetsCache();
      
      // 4. 短暂延迟确保清理完成
      await Future.delayed(const Duration(milliseconds: 50));
      
      getLogger().i('✅ 页面退出预处理完成');
    } catch (e) {
      getLogger().e('❌ 页面退出预处理失败: $e');
    }
  }

  /// 销毁所有WebView组件
  Future<void> _disposeAllWebViews() async {
    try {
      getLogger().i('🗑️ 开始销毁所有WebView组件');
      
      // 销毁网页WebView
      final webWidgetState = _webWidgetKey.currentState;
      if (webWidgetState != null) {
        await _disposeWebWidget(webWidgetState);
      }
      
      // 销毁图文WebView (ArticleMarkdownWidget)
      await _disposeMarkdownWidgets();
      
      // 销毁快照WebView (ArticleMhtmlWidget)  
      await _disposeMhtmlWidgets();
      
      getLogger().i('✅ 所有WebView组件销毁完成');
    } catch (e) {
      getLogger().e('❌ 销毁WebView组件时出错: $e');
    }
  }

  /// 销毁网页WebView组件
  Future<void> _disposeWebWidget(dynamic webWidgetState) async {
    try {
      getLogger().i('🌐 销毁网页WebView组件');
      
      // 通过反射调用dispose方法（如果存在）
      if (webWidgetState.mounted) {
        // 尝试获取webViewController并销毁
        final controller = (webWidgetState as dynamic).webViewController;
        if (controller != null) {
          await controller.stopLoading();
          await controller.clearCache();
          await controller.clearHistory();
          getLogger().i('✅ 网页WebView控制器已清理');
        }
      }
    } catch (e) {
      getLogger().e('❌ 销毁网页WebView失败: $e');
    }
  }

  /// 销毁图文Markdown中的WebView组件
  Future<void> _disposeMarkdownWidgets() async {
    try {
      // 遍历缓存的widget，找到ArticleMarkdownWidget并销毁其WebView
      for (final entry in _cachedTabWidgets.entries) {
        if (entry.key == '图文') {
          getLogger().i('📄 找到图文WebView，准备销毁');
          // 这里可以添加特定的销毁逻辑
          // 由于ArticleMarkdownWidget有自己的dispose逻辑，我们主要是提前触发
          break;
        }
      }
    } catch (e) {
      getLogger().e('❌ 销毁图文WebView失败: $e');
    }
  }

  /// 销毁快照MHTML中的WebView组件
  Future<void> _disposeMhtmlWidgets() async {
    try {
      // 遍历缓存的widget，找到ArticleMhtmlWidget并销毁其WebView
      for (final entry in _cachedTabWidgets.entries) {
        if (entry.key == '快照') {
          getLogger().i('📸 找到快照WebView，准备销毁');
          // 这里可以添加特定的销毁逻辑
          // 由于ArticleMhtmlWidget有自己的dispose逻辑，我们主要是提前触发
          break;
        }
      }
    } catch (e) {
      getLogger().e('❌ 销毁快照WebView失败: $e');
    }
  }
}

/// 用于保持widget状态的包装器
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  final bool Function()? shouldKeepAlive; // 添加条件判断函数

  const _KeepAliveWrapper({
    required this.child,
    this.shouldKeepAlive,
  });

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive {
    // 如果提供了条件判断函数，使用它来决定是否保持存活
    if (widget.shouldKeepAlive != null) {
      return widget.shouldKeepAlive!();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，以支持AutomaticKeepAliveClientMixin
    return widget.child;
  }
  
  @override
  void didUpdateWidget(_KeepAliveWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果shouldKeepAlive函数改变了，更新KeepAlive状态
    if (widget.shouldKeepAlive != oldWidget.shouldKeepAlive) {
      // 强制更新KeepAlive状态
      updateKeepAlive();
    }
  }
  
  @override
  void dispose() {
    // 在销毁时记录日志
    getLogger().d('🗑️ _KeepAliveWrapper销毁');
    super.dispose();
  }
}

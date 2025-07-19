import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../db/article/service/article_service.dart';
import '/basics/logger.dart';
import '/basics/upload.dart';
import 'components/article_bottom_bar.dart';
import 'components/article_loading_view.dart';
import 'components/article_top_bar.dart';
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
                  await articleController.manualSavePosition();
                  // await (_markdownWidgetKey.currentState)?.manualSavePosition();
                  // Navigator.of(context).pop();
                  context.pop(true);
                },
                onGenerateSnapshot: generateSnapshot,
                onReGenerateSnapshot: () async {
                  getLogger().i('🎯 开始重新生成快照');
                  
                  try {
                    // 1. 首先生成新的快照
                    await (_webWidgetKey.currentState)?.createSnapshot();
                    
                    // 2. 等待一短时间，确保快照生成完成
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    // 3. 获取最新的文章数据（包含新的mhtmlPath）
                    await articleController.refreshCurrentArticle();
                    
                    // 4. 直接调用 ArticleMhtmlWidget 的方法加载新快照
                    final mhtmlState = _mhtmlWidgetKey.currentState;

                    if (mhtmlState != null && articleController.hasArticle) {
                      final currentArticle = articleController.currentArticle!;

                      if (currentArticle.mhtmlPath.isNotEmpty) {
                        await mhtmlState.loadNewSnapshot(currentArticle.mhtmlPath);
                      } else {
                        await mhtmlState.reloadSnapshot();
                      }
                    } else {
                      refreshTabs();
                      getLogger().w('⚠️ 无法获取快照widget状态或文章数据');
                      getLogger().w('   mhtmlState: ${mhtmlState?.runtimeType}');
                      getLogger().w('   hasArticle: ${articleController.hasArticle}');
                    }
                    
                    BotToast.showText(text: 'i18n_article_快照更新成功'.tr);
                  } catch (e) {
                    getLogger().e('❌ 重新生成快照失败: $e');
                    BotToast.showText(text: '${'i18n_article_快照更新失败'.tr}$e');
                  }
                },
                onReGenerateMarkdown: () async {
                  getLogger().i('🎯 开始重新生成Markdown');
                  
                  try {
                    // 1. 首先生成新的Markdown
                    await (_webWidgetKey.currentState)?.createMarkdown();

                    // 3. 获取最新的文章数据
                    await articleController.refreshCurrentArticle();
                    
                    // 4. 从 ArticleContentDb 获取最新的 Markdown 内容
                    final currentArticle = articleController.currentArticle;
                    if (currentArticle != null) {
                      try {
                        // 使用控制器刷新 Markdown 内容
                        await articleController.refreshMarkdownContent();
                        
                        if (articleController.currentMarkdownContent.isNotEmpty) {
                          // 5. 直接调用 ArticleMarkdownWidget 的方法重新加载内容
                          final markdownState = _markdownWidgetKey.currentState;
                          if (markdownState != null) {
                            getLogger().i('📄 调用Markdown组件重新加载方法');
                            await markdownState.reloadMarkdownContent();
                          }

                          BotToast.showText(text: 'i18n_article_图文更新成功'.tr);
                        } else {
                          getLogger().w('⚠️ ArticleContentDb 中未找到新的 Markdown 内容');
                          BotToast.showText(text: 'i18n_article_Markdown生成中请稍后查看'.tr);
                        }
                      } catch (e) {
                        getLogger().e('❌ 从ArticleContentDb获取Markdown内容失败: $e');
                        BotToast.showText(text: '${'i18n_article_Markdown获取失败'.tr}$e');
                      }
                    } else {
                      getLogger().w('⚠️ 未获取到文章数据');
                      BotToast.showText(text: 'i18n_article_Markdown生成中请稍后查看'.tr);
                    }
                  } catch (e) {
                    getLogger().e('❌ 重新生成Markdown失败: $e');
                    BotToast.showText(text: '${'i18n_article_Markdown更新失败'.tr}$e');
                  }
                },
                currentTab: tabController,
                webTabIndex: _getWebTabIndex(),
                tabs: tabs,
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
          Text('i18n_article_加载失败'.tr, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            articleController.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadArticleData,
            child: Text('i18n_article_重试'.tr),
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

  final double _topBarHeight = 34.0;
  final double _bottomBarHeight = 38.0;

  // 文章控制器
   final ArticleController articleController = Get.find<ArticleController>();

  late TabController tabController;
  List<String> tabs = []; // 改为简单的String列表
  List<Widget> tabWidget = [];
  
  // 用于存储ArticleWebWidget的GlobalKey，以便调用其方法
  final GlobalKey<ArticlePageState> _webWidgetKey = GlobalKey<ArticlePageState>();
  final GlobalKey<ArticleMhtmlWidgetState> _mhtmlWidgetKey = GlobalKey<ArticleMhtmlWidgetState>();
  final GlobalKey<_KeepAliveWrapperState> _mhtmlWidgetKey2 = GlobalKey<_KeepAliveWrapperState>();
  final GlobalKey<ArticleMarkdownWidgetState> _markdownWidgetKey = GlobalKey<ArticleMarkdownWidgetState>();

  String snapshotPath = "";
  bool isUploading = false; // 添加上传状态标识

  // markdown内容现在通过控制器管理
  String get markdownContent => articleController.currentMarkdownContent;
  
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); // 进入沉浸式模式，隐藏系统状态栏
    
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
    final article = articleController.currentArticle!;

    // 根据isGenerateMarkdown决定是否显示图文tab
    if (article.isGenerateMarkdown) {
      tabs.insert(0, 'i18n_article_图文'.tr);
    }
    if (article.url != "") {
      tabs.add('i18n_article_网页'.tr);
    }
    // 根据isGenerateMhtml决定是否显示快照tab
    if (article.isGenerateMhtml) {
      tabs.add('i18n_article_快照'.tr);
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
        child: Center(
          child: Text('i18n_article_内容加载中'.tr),
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
    tabs = [];
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
      if (!_cachedTabWidgets.containsKey('i18n_article_网页'.tr)) {
        _cachedTabWidgets['i18n_article_网页'.tr] = _KeepAliveWrapper(
          shouldKeepAlive: () => !_isPageDisposing,
          child: Obx(() => ArticleWebWidget(
            key: _webWidgetKey,
            onSnapshotCreated: _onSnapshotCreated,
            url: articleController.articleUrl.isNotEmpty 
              ? articleController.articleUrl 
              : null,
            articleId: widget.id,
            onScroll: _handleScroll,
            onTap: _handlePageTap, // 添加点击回调
            contentPadding: padding,
            onMarkdownGenerated: _onMarkdownGenerated,
          )),
        );
      }
      
      tabWidget = [_cachedTabWidgets['i18n_article_网页'.tr]!];
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
            child: Center(
              child: Text('i18n_article_内容加载中'.tr),
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
    if (tabName == 'i18n_article_图文'.tr) {
      return _KeepAliveWrapper(
        shouldKeepAlive: () => !_isPageDisposing,
        child: Obx(() => ArticleMarkdownWidget(
          key: _markdownWidgetKey,
          markdownContent: articleController.currentMarkdownContent,
          article: articleController.currentArticle,
          onScroll: _handleScroll,
          onTap: _handlePageTap, // 添加点击回调
          contentPadding: padding,
        )),
      );
    } else if (tabName == 'i18n_article_网页'.tr) {
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
          onTap: _handlePageTap, // 添加点击回调
          contentPadding: padding,
          onMarkdownGenerated: _onMarkdownGenerated,
        )),
      );
    } else if (tabName == 'i18n_article_快照'.tr) {
      return _KeepAliveWrapper(
        key: _mhtmlWidgetKey2,
        shouldKeepAlive: () => !_isPageDisposing,
        child: ArticleMhtmlWidget(
          key: _mhtmlWidgetKey,
          mhtmlPath: article.mhtmlPath,
          title: article.title,
          onScroll: _handleScroll,
          onTap: _handlePageTap, // 添加点击回调
          contentPadding: padding,
        ),
      );
    } else {
      return _KeepAliveWrapper(
        shouldKeepAlive: () => !_isPageDisposing,
        child: Container(
          child: Center(
            child: Text('i1s8n_article_未知页面类型'.tr),
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

  /// 处理页面点击事件，切换操作栏显示/隐藏状态
  void _handlePageTap() {
    setState(() {
      _isBottomBarVisible = !_isBottomBarVisible;
    });
    getLogger().d('🎯 用户点击页面，切换操作栏状态: ${_isBottomBarVisible ? "显示" : "隐藏"}');
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

    if (articleController.hasArticle) {
      // 数据加载成功后，再初始化tabs
      _initializeTabs();

      // 触发UI重建以显示新的tabs
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Markdown 生成成功回调
  void _onMarkdownGenerated() {
    getLogger().i('🎯 收到 Markdown 生成成功通知，使用控制器刷新');
    
    // 使用控制器的方法处理 markdown 生成成功
    articleController.onMarkdownGenerated().then((_) {
      // 刷新 tabs 显示
      refreshTabs();
    }).catchError((e) {
      getLogger().e('❌ 刷新Markdown内容失败: $e');
    });
  }

  // 接收快照路径的回调方法
  void _onSnapshotCreated(String path) {
    setState(() {
      snapshotPath = path;
    });

    BotToast.showText(text: '${'i18n_article_快照已保存路径'.tr}${path.split('/').last}');
    
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
        BotToast.showText(text: 'i18n_article_网页未加载完成请稍后再试'.tr);
      }
    } else {
      BotToast.showText(text: 'i18n_article_请切换到网页标签页生成快照'.tr);
    }
  }

  /// 获取网页tab的索引
  int _getWebTabIndex() {
    if (!articleController.hasArticle) return 0;
    
    final article = articleController.currentArticle!;
    // 如果有图文tab，网页tab索引为1，否则为0
    return article.isGenerateMarkdown ? 1 : 0;
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
    try {
      await articleController.manualSavePosition();
      
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
        if (entry.key == 'i18n_article_图文'.tr) {
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
        if (entry.key == 'i18n_article_快照'.tr) {
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
  final bool Function()? keepAlive; // 添加条件判断函数

  const _KeepAliveWrapper({
    super.key,
    required this.child,
    this.shouldKeepAlive,
    this.keepAlive,
  });

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  
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


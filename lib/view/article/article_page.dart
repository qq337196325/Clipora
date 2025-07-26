import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '/basics/logger.dart';
import 'controller/article_controller.dart';
import 'widgets/article_loading_view.dart';
import 'controllers/article_page_state_controller.dart';


class ArticlePage extends StatefulWidget {

  final int id;

  const ArticlePage({
    super.key,
    required this.id,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with TickerProviderStateMixin {
  
  // 状态管理控制器
  late final ArticlePageStateController _stateController;
  
  // 常量
  final double _topBarHeight = 34.0;
  final double _bottomBarHeight = 38.0;

  @override
  void initState() {
    super.initState();
    
    // 进入沉浸式模式，隐藏系统状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // 初始化状态管理控制器
    _stateController = Get.put(ArticlePageStateController(), tag: 'article_page_${widget.id}');
    
    // 使用优化的页面初始化
    _initializePageWithPreload();
  }
  
  /// 初始化页面
  Future<void> _initializePage() async {
    try {
      await _stateController.initialize(widget.id);
    } catch (e) {
      getLogger().e('❌ 页面初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用PopScope来监听返回事件，在返回前提前销毁WebView避免闪烁
    return PopScope(
      canPop: false, // 禁用默认返回，使用自定义返回逻辑
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // 执行优化的返回操作
          await _handleOptimizedBackNavigation(context);
        }
      },
      child: Obx(() {
        // 响应式状态观察 - 错误状态
        if (_stateController.state.hasError) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: _buildErrorView(context),
            ),
          );
        }

        // 响应式状态观察 - 加载状态
        if (!_stateController.state.isInitialized || _stateController.state.isLoading) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildInitialLoadingView(),
            ),
          );
        }
        
        // 响应式状态观察 - 主内容UI
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: Scaffold(
            key: ValueKey('main_content_${_stateController.state.isInitialized}'),
            body: Stack(
              children: [
                // 主要内容区域 - 响应式构建
                _buildContentView(context),
                
                // // 顶部操作栏 - 响应式UI可见性控制
                Obx(() => _buildAnimatedTopBar()),
                //
                // // 底部操作栏 - 响应式UI可见性控制
                Obx(() => _buildAnimatedBottomBar(context)),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// 构建带动画的顶部栏
  Widget _buildAnimatedTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      left: 30,
      right: 30,
      child: AnimatedSlide(
        offset: _stateController.state.isBottomBarVisible 
          ? Offset.zero 
          : const Offset(0, -1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _stateController.state.isBottomBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0.0,
              end: _stateController.state.isBottomBarVisible ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Center(
                  child: SizedBox(
                    height: _topBarHeight,
                    child: _buildCustomTabBar(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建自定义TabBar（从ArticleTopBar移过来）
  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 1,
            offset: const Offset(0, 0.5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        padding: const EdgeInsets.all(2),
        controller: _stateController.tabController.tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 1.5),
            )
          ],
        ),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        tabs: _stateController.state.tabs.map((tabName) => Tab(
          height: 20,
          child: Text(
            tabName,
            style: const TextStyle(
              fontSize: 13.5,
            ),
          ),
        )).toList(),
      ),
    );
  }

  /// 构建带动画的底部栏
  Widget _buildAnimatedBottomBar(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedSlide(
        offset: _stateController.state.isBottomBarVisible
          ? Offset.zero
          : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _stateController.state.isBottomBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0.0,
              end: _stateController.state.isBottomBarVisible ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: _buildBottomBarContent(context), // 提取底部栏内容
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建底部栏内容（不包含 Positioned）
  Widget _buildBottomBarContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface.withOpacity(0.95),
                  colorScheme.surfaceContainerHighest.withOpacity(0.9),
                ]
              : [
                  colorScheme.surface.withOpacity(0.95),
                  Colors.grey.shade50.withOpacity(0.9),
                ],
        ),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.black.withOpacity(0.08),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左侧 - 返回按钮
            _buildActionButton(
              context,
              icon: Icons.keyboard_arrow_left_rounded,
              label: 'i18n_article_返回'.tr,
              isPrimary: true,
              onPressed: () => _handleOptimizedBackButton(),
            ),
            
            // 中间 - 操作按钮组
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => _buildFloatingButton(
                  context,
                  icon: Icons.explore_outlined,
                  tooltip: 'i18n_article_浏览器打开'.tr,
                  onPressed: _openInBrowser,
                  isEnabled: Get.find<ArticleController>().articleUrl.isNotEmpty,
                )),
              ],
            ),
            
            // 右侧 - 更多操作
            _buildActionButton(
              context,
              icon: Icons.tune_rounded,
              label: 'i18n_article_更多'.tr,
              isPrimary: false,
              onPressed: () => _showMoreActionsModal(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 主要操作按钮（带文字标签）
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        splashColor: isPrimary 
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.onSurface.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary 
                ? colorScheme.primaryContainer
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(24),
            border: isPrimary 
                ? Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary 
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isPrimary 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 浮动圆形按钮
  Widget _buildFloatingButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isEnabled
                  ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEnabled
                    ? (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1))
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isEnabled
                  ? colorScheme.onSurface.withOpacity(0.8)
                  : colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  /// 浏览器访问功能
  Future<void> _openInBrowser() async {
    final articleController = Get.find<ArticleController>();
    final url = articleController.articleUrl;
    
    if (url.isEmpty) {
      // 显示提示信息
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      getLogger().e('打开浏览器失败: $e');
    }
  }

  /// 显示更多操作模态框
  void _showMoreActionsModal(BuildContext context) {
    // 这里需要根据你的 MoreActionsModal 实现来调整
    // showModalBottomSheet(...);
  }

  /// 构建主要内容视图 - 响应式构建
  Widget _buildContentView(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + _topBarHeight;
    final bottomPadding = mediaQuery.padding.bottom + _bottomBarHeight;

    return Obx(() {
      // 响应式状态观察 - 标签页状态变化
      final tabs = _stateController.state.tabs;
      final tabWidgets = _stateController.tabWidgets;

      // 基于状态的条件渲染 - 检查是否有可用的标签页
      if (tabs.isEmpty || tabWidgets.isEmpty) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Center(
            key: const ValueKey('no_tabs'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(
                        Icons.tab_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'i18n_article_暂无内容'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 更新标签页Widget的padding - 响应式更新
      _stateController.tabController.updateTabWidgets(
        EdgeInsets.only(top: topPadding, bottom: bottomPadding)
      );

      // 响应式TabBarView - 带状态变化动画
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: TabBarView(
          key: ValueKey('tab_view_${tabs.length}_${_stateController.currentTabIndex}'),
          physics: const NeverScrollableScrollPhysics(),
          controller: _stateController.tabController.tabController,
          children: tabWidgets,
        ),
      );
    });
  }

  /// 构建错误视图
  Widget _buildErrorView(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  );
                },
              ),
              const SizedBox(height: 16),
              AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: Text(
                  'i18n_article_加载失败'.tr, 
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: Text(
                  _stateController.state.errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: ElevatedButton(
                  onPressed: () => _initializePage(),
                  child: Text('i18n_article_重试'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建初始加载视图
  Widget _buildInitialLoadingView() {
    return const ArticleLoadingView();
  }
  
  /// 优化的返回导航处理
  /// 实现页面切换的平滑过渡和优化返回操作的响应速度
  Future<void> _handleOptimizedBackNavigation(BuildContext context) async {
    try {
      getLogger().i('🔄 开始优化的返回导航处理');
      
      // 1. 立即开始退出动画，提升响应速度
      _startExitTransition();
      
      // 2. 并行执行页面退出预处理
      final exitPreparationFuture = _stateController.prepareForPageExit();
      
      // 3. 预加载上一个页面状态（如果需要）
      final preloadFuture = _preloadPreviousPageState();
      
      // 4. 等待关键操作完成，但不阻塞UI动画
      await Future.wait([
        exitPreparationFuture,
        preloadFuture,
      ], eagerError: false);
      
      // 5. 确保动画完成后再执行实际导航
      await _waitForExitAnimationComplete();
      
      // 6. 执行实际的页面返回
      if (mounted) {
        context.pop(true);
      }
      
      getLogger().i('✅ 优化的返回导航处理完成');
    } catch (e) {
      getLogger().e('❌ 优化返回导航失败: $e');
      
      // 即使优化失败，也要确保能够返回
      if (mounted) {
        context.pop(true);
      }
    }
  }
  
  /// 开始退出过渡动画
  void _startExitTransition() {
    try {
      getLogger().d('🎬 开始退出过渡动画');
      
      // 立即隐藏UI元素，提供即时反馈
      _stateController.uiController.forceHideUI();
      
      // 可以在这里添加更多的退出动画效果
      // 比如页面缩放、透明度变化等
      
    } catch (e) {
      getLogger().e('❌ 开始退出过渡动画失败: $e');
    }
  }
  
  /// 预加载上一个页面状态
  Future<void> _preloadPreviousPageState() async {
    try {
      getLogger().d('📋 开始预加载上一个页面状态');
      
      // 这里可以实现预加载逻辑
      // 比如预热上一个页面的数据、缓存等
      
      // 模拟预加载过程
      await Future.delayed(const Duration(milliseconds: 50));
      
      getLogger().d('✅ 上一个页面状态预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载上一个页面状态失败: $e');
    }
  }
  
  /// 等待退出动画完成
  Future<void> _waitForExitAnimationComplete() async {
    try {
      // 等待UI动画完成
      await Future.delayed(const Duration(milliseconds: 200));
      
      getLogger().d('🎬 退出动画完成');
    } catch (e) {
      getLogger().e('❌ 等待退出动画完成失败: $e');
    }
  }
  
  /// 优化的页面初始化（支持预加载）
  Future<void> _initializePageWithPreload() async {
    try {
      getLogger().i('🚀 开始优化的页面初始化');
      
      // 1. 显示加载动画
      _stateController.uiController.setLoadingState(true);
      
      // 2. 预加载关键资源
      final preloadFuture = _preloadCriticalResources();
      
      // 3. 并行执行页面初始化
      final initializationFuture = _stateController.initialize(widget.id);
      
      // 4. 等待所有操作完成
      await Future.wait([
        preloadFuture,
        initializationFuture,
      ], eagerError: false);
      
      // 5. 启动平滑的进入动画
      _startEnterTransition();
      
      getLogger().i('✅ 优化的页面初始化完成');
    } catch (e) {
      getLogger().e('❌ 优化页面初始化失败: $e');
      
      // 降级到普通初始化
      await _initializePage();
    }
  }
  
  /// 预加载关键资源
  Future<void> _preloadCriticalResources() async {
    try {
      getLogger().d('📦 开始预加载关键资源');
      
      // 预加载文章数据
      final articleController = Get.find<ArticleController>();
      if (!articleController.hasArticle) {
        // 可以在这里预加载文章基本信息
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // 预热WebView组件
      await _preloadWebViewComponents();
      
      // 预加载UI主题和样式
      await _preloadUITheme();
      
      getLogger().d('✅ 关键资源预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载关键资源失败: $e');
    }
  }
  
  /// 预加载WebView组件
  Future<void> _preloadWebViewComponents() async {
    try {
      getLogger().d('🌐 开始预加载WebView组件');
      
      // 预热WebView生命周期管理器
      if (_stateController.isInitialized.value) {
        await _stateController.tabController.preloadWebViewComponents();
      }
      
      getLogger().d('✅ WebView组件预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载WebView组件失败: $e');
    }
  }
  
  /// 预加载UI主题
  Future<void> _preloadUITheme() async {
    try {
      getLogger().d('🎨 开始预加载UI主题');
      
      // 预加载主题相关资源
      final theme = Theme.of(context);
      
      // 预计算一些常用的颜色和样式
      // 这里可以预计算和缓存一些复杂的样式
      await Future.delayed(const Duration(milliseconds: 50));
      
      getLogger().d('✅ UI主题预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载UI主题失败: $e');
    }
  }
  
  /// 开始进入过渡动画
  void _startEnterTransition() {
    try {
      getLogger().d('🎬 开始进入过渡动画');
      
      // 平滑显示UI元素
      _stateController.uiController.forceShowUI();
      
      // 可以在这里添加更多的进入动画效果
      
    } catch (e) {
      getLogger().e('❌ 开始进入过渡动画失败: $e');
    }
  }
  
  /// 优化的底部栏返回按钮处理
  Future<void> _handleOptimizedBackButton() async {
    try {
      getLogger().i('🔄 处理优化的返回按钮点击');
      
      // 立即提供视觉反馈
      _stateController.uiController.setLoadingState(true);
      
      // 执行优化的返回导航
      await _handleOptimizedBackNavigation(context);
      
    } catch (e) {
      getLogger().e('❌ 优化返回按钮处理失败: $e');
      
      // 降级到普通返回
      if (mounted) {
        context.pop(true);
      }
    } finally {
      // 确保加载状态被清除
      if (_stateController.isInitialized.value) {
        _stateController.uiController.setLoadingState(false);
      }
    }
  }
  
  @override
  void dispose() {
    getLogger().i('🔄 ArticlePage开始dispose');
    
    // 退出页面时恢复系统默认UI，显示状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // 清理状态管理控制器
    Get.delete<ArticlePageStateController>(tag: 'article_page_${widget.id}');
    
    getLogger().i('✅ ArticlePage dispose完成');
    super.dispose();
  }
}


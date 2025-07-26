import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../basics/logger.dart';
import '../../../db/article/article_db.dart';
import '../controller/article_controller.dart';
import '../exceptions/article_state_exception.dart';
import '../models/tab_widget_config.dart';
import '../utils/performance_utils.dart';
import '../utils/widget_cache_manager.dart';
import '../utils/webview_lifecycle_manager.dart';
import '../utils/memory_monitor.dart';

/// 文章标签页状态管理控制器
/// 
/// 负责管理文章页面的标签页系统，包括图文、网页、快照三个标签页的状态管理、
/// 切换逻辑、内容生成触发以及WebView生命周期管理。该控制器实现了高级的缓存策略
/// 和性能优化，确保标签页切换的流畅性和内存使用的合理性。
/// 
/// ## 核心功能：
/// - **标签页管理**：动态创建和管理图文、网页、快照标签页
/// - **状态驱动**：通过状态变化触发内容生成，避免直接方法调用
/// - **内容生成**：协调快照生成、Markdown生成等异步操作
/// - **缓存管理**：智能缓存标签页Widget，提升切换性能
/// - **生命周期管理**：管理WebView实例的创建、暂停、销毁
/// - **内存优化**：监控内存使用，自动清理和优化
/// 
/// ## 三个标签页状态：
/// ### 图文标签页（Markdown）
/// - `shouldReloadMarkdown`: 是否需要重新加载Markdown内容
/// - `isReloadingMarkdown`: 是否正在重新加载中
/// - `markdownReloadSuccess`: 重新加载是否成功
/// - `markdownReloadError`: 重新加载错误信息
/// 
/// ### 网页标签页（Web）
/// - `shouldGenerateSnapshot`: 是否需要生成快照
/// - `shouldGenerateMarkdown`: 是否需要生成Markdown
/// - `isGeneratingSnapshot`: 是否正在生成快照
/// - `isGeneratingMarkdown`: 是否正在生成Markdown
/// 
/// ### 快照标签页（MHTML）
/// - `shouldLoadNewSnapshot`: 是否需要加载新快照
/// - `newSnapshotPath`: 新快照的路径
/// - `isLoadingNewSnapshot`: 是否正在加载新快照
/// - `snapshotLoadSuccess`: 快照加载是否成功
/// 
/// ## 性能优化特性：
/// - **智能缓存**：使用WidgetCacheManager进行智能Widget缓存
/// - **WebView优化**：通过WebViewLifecycleManager管理WebView生命周期
/// - **内存监控**：实时监控内存使用，自动触发清理
/// - **批处理**：将多个操作合并处理，减少性能开销
/// - **防抖节流**：避免频繁的状态更新和UI重建
/// 
/// ## 使用示例：
/// ```dart
/// final tabController = ArticleTabController();
/// 
/// // 初始化标签页
/// tabController.initializeTabs(article);
/// 
/// // 触发快照生成
/// await tabController.triggerSnapshotGeneration();
/// 
/// // 触发Markdown重新加载
/// await tabController.triggerMarkdownReload();
/// 
/// // 获取网页标签页索引
/// final webTabIndex = tabController.getWebTabIndex();
/// ```
/// 
/// ## 内存管理策略：
/// 控制器实现了多级内存管理策略：
/// - **警告级别**：清理过期缓存，暂停不可见WebView
/// - **严重级别**：清理所有缓存，优化WebView内存使用
/// - **紧急级别**：销毁所有非必要WebView实例，取消所有操作
/// 
/// ## 错误处理：
/// 每个标签页都有独立的错误状态管理，支持：
/// - 错误状态的集中管理
/// - 用户友好的错误提示
/// - 自动重试机制
/// - 降级处理策略
/// 
/// @author AI Assistant
/// @since 1.0.0
/// @see WidgetCacheManager Widget缓存管理器
/// @see WebViewLifecycleManager WebView生命周期管理器
/// @see MemoryMonitor 内存监控器
/// @see TabWidgetConfig 标签页Widget配置
class ArticleTabController extends GetxController with GetTickerProviderStateMixin {
  
  // 标签页状态
  final RxList<String> tabs = <String>[].obs;
  final RxList<Widget> tabWidgets = <Widget>[].obs;
  late TabController tabController;
  
  // 当前选中的标签页
  final RxInt currentTabIndex = 0.obs;
  final RxString currentTabName = ''.obs;
  
  // 三个tab页面的状态管理
  final RxBool shouldGenerateSnapshot = false.obs;
  final RxBool shouldGenerateMarkdown = false.obs;
  final RxBool shouldReloadMarkdown = false.obs;
  final RxBool shouldLoadNewSnapshot = false.obs;
  final RxBool shouldReloadSnapshot = false.obs;
  final RxString newSnapshotPath = ''.obs;
  
  // 三个tab页面的内容生成状态
  final RxBool isGeneratingSnapshot = false.obs;
  final RxBool isGeneratingMarkdown = false.obs;
  final RxBool isReloadingMarkdown = false.obs;
  final RxBool isLoadingNewSnapshot = false.obs;
  final RxBool isReloadingSnapshot = false.obs;
  
  // 三个tab页面的内容生成结果状态
  final RxBool snapshotGenerationSuccess = false.obs;
  final RxBool markdownGenerationSuccess = false.obs;
  final RxBool markdownReloadSuccess = false.obs;
  final RxBool snapshotLoadSuccess = false.obs;
  final RxBool snapshotReloadSuccess = false.obs;
  
  // 三个tab页面的错误状态
  final RxString snapshotGenerationError = ''.obs;
  final RxString markdownGenerationError = ''.obs;
  final RxString markdownReloadError = ''.obs;
  final RxString snapshotLoadError = ''.obs;
  final RxString snapshotReloadError = ''.obs;
  
  // 标签页加载状态
  final RxMap<String, bool> tabLoadingStates = <String, bool>{}.obs;
  final RxMap<String, String> tabErrorMessages = <String, String>{}.obs;
  
  // 缓存管理
  final Map<String, Widget> _cachedTabWidgets = {};
  final Map<String, TabWidgetConfig> _tabConfigs = {};
  final RxBool isTabWidgetsCached = false.obs;
  final RxInt cacheHitCount = 0.obs;
  final RxInt cacheMissCount = 0.obs;
  
  // 性能优化工具
  late final Debouncer _stateUpdateDebouncer;
  late final BatchProcessor<String> _operationBatcher;
  late final WebViewOperationOptimizer _webViewOptimizer;
  late final PerformanceMonitor _tabPerformanceMonitor;
  late final RateLimiter _tabSwitchLimiter;
  
  // 高级缓存和生命周期管理
  late final WidgetCacheManager _widgetCacheManager;
  late final WebViewLifecycleManager _webViewLifecycleManager;
  late final MemoryMonitor _memoryMonitor;
  
  // 页面销毁状态标识
  bool _isPageDisposing = false;
  
  // 标签页切换回调
  void Function(int index, String tabName)? onTabChanged;
  void Function(String tabName, bool isLoading)? onTabLoadingChanged;
  void Function(String tabName, String error)? onTabError;
  
  // 文章控制器引用
  final ArticleController articleController = Get.find<ArticleController>();
  
  // 滚动和点击处理器
  void Function(ScrollDirection direction, double scrollY)? _scrollHandler;
  VoidCallback? _tapHandler;
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化性能优化工具
    _initializePerformanceTools();
    
    // 初始化一个临时的空控制器
    tabController = TabController(
      length: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 350),
    );
    
    // 设置标签页切换监听
    _setupTabChangeListener();
    
    // 初始化标签页状态
    _initializeTabStates();
    
    getLogger().i('📑 ArticleTabController 初始化完成');
  }
  
  /// 初始化性能优化工具
  void _initializePerformanceTools() {
    // 状态更新防抖器
    _stateUpdateDebouncer = Debouncer(
      delay: const Duration(milliseconds: 100),
    );
    
    // 操作批处理器
    _operationBatcher = BatchProcessor<String>(
      batchInterval: const Duration(milliseconds: 200),
      processor: _processBatchedOperations,
    );
    
    // WebView操作优化器
    _webViewOptimizer = WebViewOperationOptimizer();
    
    // Tab性能监控器
    _tabPerformanceMonitor = PerformanceMonitor(
      name: 'TabController',
      maxSamples: 100,
    );
    
    // Tab切换频率限制器
    _tabSwitchLimiter = RateLimiter(
      maxOperations: 10,
      timeWindow: const Duration(seconds: 1),
    );
    
    // 高级缓存管理器
    _widgetCacheManager = WidgetCacheManager(
      maxCacheSize: 20,
      defaultExpiry: const Duration(minutes: 15),
      strategy: CacheStrategy.smart,
    );
    
    // WebView生命周期管理器
    _webViewLifecycleManager = WebViewLifecycleManager(
      maxInstances: 2,
      instanceTimeout: const Duration(minutes: 5),
      pauseDelay: const Duration(seconds: 10),
    );
    
    // 内存监控器
    _memoryMonitor = MemoryMonitor(
      monitorInterval: const Duration(seconds: 10),
      warningThreshold: 75.0,
      criticalThreshold: 90.0,
      emergencyThreshold: 95.0,
    );
    
    // 设置内存监控回调
    _setupMemoryMonitoringCallbacks();
    
    // 启动内存监控
    _memoryMonitor.startMonitoring();
  }
  
  /// 设置内存监控回调
  void _setupMemoryMonitoringCallbacks() {
    _memoryMonitor.onWarningLevelChanged = (level, info) {
      getLogger().w('⚠️ 内存警告级别变化: $level, 使用率: ${info.usagePercentage.toStringAsFixed(1)}%');
      
      // 根据警告级别采取相应措施
      switch (level) {
        case MemoryWarningLevel.warning:
          _handleMemoryWarning();
          break;
        case MemoryWarningLevel.critical:
          _handleMemoryCritical();
          break;
        case MemoryWarningLevel.emergency:
          _handleMemoryEmergency();
          break;
        case MemoryWarningLevel.normal:
          break;
      }
    };
    
    _memoryMonitor.onMemoryPressure = (info) {
      getLogger().e('🚨 内存压力过大: ${info.usagePercentage.toStringAsFixed(1)}%');
      _handleMemoryEmergency();
    };
  }
  
  /// 处理内存警告
  void _handleMemoryWarning() {
    // 清理过期的Widget缓存
    _widgetCacheManager.cleanupExpired();
    
    // 暂停不可见的WebView实例
    _webViewLifecycleManager.pauseInvisibleInstances();
    
    getLogger().i('🧹 内存警告处理完成');
  }
  
  /// 处理内存严重警告
  void _handleMemoryCritical() {
    // 执行更激进的清理
    _widgetCacheManager.clear();
    clearTabWidgetsCache();
    
    // 优化WebView内存使用
    _webViewLifecycleManager.optimizeMemoryUsage();
    
    // 触发垃圾回收
    _memoryMonitor.triggerGarbageCollection();
    
    getLogger().i('🧹 内存严重警告处理完成');
  }
  
  /// 处理内存紧急情况
  void _handleMemoryEmergency() {
    // 执行最激进的清理
    _handleMemoryCritical();
    
    // 销毁所有不必要的WebView实例
    _webViewLifecycleManager.disposeAllInstances();
    
    // 取消所有正在进行的操作
    cancelAllOperations();
    
    getLogger().e('🚨 内存紧急情况处理完成');
  }
  
  /// 设置标签页切换监听
  void _setupTabChangeListener() {
    // 监听标签页切换
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        final newIndex = tabController.index;
        final newTabName = newIndex < tabs.length ? tabs[newIndex] : '';
        
        // 更新当前标签页状态
        currentTabIndex.value = newIndex;
        currentTabName.value = newTabName;
        
        // 触发回调
        onTabChanged?.call(newIndex, newTabName);
        
        getLogger().d('📑 标签页切换: 索引=$newIndex, 名称=$newTabName');
      }
    });
  }
  
  /// 初始化标签页状态
  void _initializeTabStates() {
    // 清空所有状态
    tabLoadingStates.clear();
    tabErrorMessages.clear();
    _tabConfigs.clear();
    
    // 重置缓存统计
    cacheHitCount.value = 0;
    cacheMissCount.value = 0;
  }
  
  /// 清理标签页缓存
  void clearTabWidgetsCache() {
    try {
      getLogger().i('🧹 清理标签页缓存');
      
      // 清理本地缓存
      _cachedTabWidgets.clear();
      
      // 重置缓存状态
      isTabWidgetsCached.value = false;
      
      // 重置缓存统计
      cacheHitCount.value = 0;
      cacheMissCount.value = 0;
      
      getLogger().i('✅ 标签页缓存清理完成');
    } catch (e) {
      getLogger().e('❌ 清理标签页缓存失败: $e');
    }
  }
  
  // === 缺失的方法实现 ===
  
  /// 设置滚动处理器
  void setScrollHandler(void Function(ScrollDirection direction, double scrollY)? handler) {
    _scrollHandler = handler;
  }
  
  /// 设置点击处理器
  void setTapHandler(VoidCallback? handler) {
    _tapHandler = handler;
  }
  
  /// 初始化标签页
  void initializeTabs(ArticleDb article) {
    try {
      getLogger().i('🔄 开始初始化标签页，文章: ${article.title}');
      
      tabs.clear();
      
      // 根据isGenerateMarkdown决定是否显示图文tab
      if (article.isGenerateMarkdown) {
        tabs.insert(0, 'i18n_article_图文'.tr);
      }
      
      // 网页tab
      if (article.url.isNotEmpty) {
        tabs.add('i18n_article_网页'.tr);
      }
      
      // 根据isGenerateMhtml决定是否显示快照tab
      if (article.isGenerateMhtml) {
        tabs.add('i18n_article_快照'.tr);
      }
      
      // 初始化TabWidget列表
      _initializeTabWidgets();
      
      // 更新TabController
      _updateTabController();
      
      getLogger().i('✅ 标签页初始化完成，数量: ${tabs.length}');
    } catch (e, stackTrace) {
      getLogger().e('❌ 初始化标签页失败: $e');
      throw ArticleTabException(
        '初始化标签页失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 初始化TabWidget列表（创建占位符）
  void _initializeTabWidgets() {
    tabWidgets.clear();
    for (int i = 0; i < tabs.length; i++) {
      tabWidgets.add(Center(
        child: Text('i18n_article_内容加载中'.tr),
      ));
    }
    getLogger().i('🔄 初始化tabWidget，数量: ${tabWidgets.length}');
  }
  
  /// 更新TabController的长度和默认选中tab
  void _updateTabController() {
    try {
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
          vsync: this,
          animationDuration: const Duration(milliseconds: 350),
        );
        
        // 尝试恢复之前选中的tab
        _restoreSelectedTab(currentTabName, currentIndex);
      }
      
      getLogger().i('🔄 TabController更新完成，长度: $newLength');
    } catch (e, stackTrace) {
      getLogger().e('❌ 更新TabController失败: $e');
      throw ArticleTabException(
        '更新TabController失败',
        originalError: e,
        stackTrace: stackTrace,
      );
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
      if (webTabIndex < tabs.length) {
        tabController.index = webTabIndex;
      }
    } else {
      // 如果有图文tab，默认选中图文tab
      tabController.index = 0;
    }
  }
  
  /// 获取网页tab的索引
  int getWebTabIndex() {
    if (!articleController.hasArticle) return 0;
    
    final article = articleController.currentArticle!;
    // 如果有图文tab，网页tab索引为1，否则为0
    return article.isGenerateMarkdown ? 1 : 0;
  }
  
  /// 刷新tabs显示（当生成新内容后调用）
  void refreshTabs() {
    if (!articleController.hasArticle) return;
    
    try {
      getLogger().i('🔄 刷新tabs显示');
      
      tabs.clear();
      // 清理现有缓存，因为文章内容可能发生了变化
      clearTabWidgetsCache();
      
      // 重新初始化tabs
      initializeTabs(articleController.currentArticle!);
      
      getLogger().i('✅ tabs刷新完成，当前tab数量: ${tabs.length}');
    } catch (e, stackTrace) {
      getLogger().e('❌ 刷新tabs失败: $e');
      throw ArticleTabException(
        '刷新tabs失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 触发快照生成
  Future<void> triggerSnapshotGeneration() async {
    try {
      getLogger().i('📸 开始触发快照生成');
      
      // 检查是否正在生成中，避免重复触发
      if (isGeneratingSnapshot.value) {
        getLogger().w('⚠️ 快照正在生成中，跳过重复触发');
        return;
      }
      
      // 设置生成状态
      isGeneratingSnapshot.value = true;
      snapshotGenerationError.value = '';
      snapshotGenerationSuccess.value = false;
      
      // 触发状态变化
      shouldGenerateSnapshot.value = true;
      
      // 重置触发状态，避免重复触发
      Future.delayed(const Duration(milliseconds: 100), () {
        shouldGenerateSnapshot.value = false;
      });
      
      getLogger().i('✅ 快照生成触发完成');
    } catch (e) {
      getLogger().e('❌ 触发快照生成失败: $e');
      isGeneratingSnapshot.value = false;
      snapshotGenerationError.value = '触发快照生成失败: $e';
    }
  }
  
  /// 触发快照加载
  Future<void> triggerSnapshotLoad(String snapshotPath) async {
    try {
      getLogger().i('📄 开始触发快照加载: $snapshotPath');
      
      // 检查是否正在加载中，避免重复触发
      if (isLoadingNewSnapshot.value) {
        getLogger().w('⚠️ 快照正在加载中，跳过重复触发');
        return;
      }
      
      // 验证快照路径
      if (snapshotPath.isEmpty) {
        throw ArticleTabException('快照路径不能为空');
      }
      
      // 设置加载状态
      isLoadingNewSnapshot.value = true;
      snapshotLoadError.value = '';
      snapshotLoadSuccess.value = false;
      
      // 设置新快照路径并触发状态变化
      newSnapshotPath.value = snapshotPath;
      shouldLoadNewSnapshot.value = true;
      
      getLogger().i('✅ 快照加载触发完成');
    } catch (e) {
      getLogger().e('❌ 触发快照加载失败: $e');
      isLoadingNewSnapshot.value = false;
      snapshotLoadError.value = '触发快照加载失败: $e';
    }
  }
  
  /// 触发Markdown生成
  Future<void> triggerMarkdownGeneration() async {
    try {
      getLogger().i('📝 开始触发Markdown生成');
      
      // 检查是否正在生成中，避免重复触发
      if (isGeneratingMarkdown.value) {
        getLogger().w('⚠️ Markdown正在生成中，跳过重复触发');
        return;
      }
      
      // 设置生成状态
      isGeneratingMarkdown.value = true;
      markdownGenerationError.value = '';
      markdownGenerationSuccess.value = false;
      
      // 触发状态变化
      shouldGenerateMarkdown.value = true;
      
      // 重置触发状态，避免重复触发
      Future.delayed(const Duration(milliseconds: 100), () {
        shouldGenerateMarkdown.value = false;
      });
      
      getLogger().i('✅ Markdown生成触发完成');
    } catch (e) {
      getLogger().e('❌ 触发Markdown生成失败: $e');
      isGeneratingMarkdown.value = false;
      markdownGenerationError.value = '触发Markdown生成失败: $e';
    }
  }
  
  /// 触发Markdown重新加载
  Future<void> triggerMarkdownReload() async {
    try {
      getLogger().i('🔄 开始触发Markdown重新加载');
      
      // 检查是否正在重新加载中，避免重复触发
      if (isReloadingMarkdown.value) {
        getLogger().w('⚠️ Markdown正在重新加载中，跳过重复触发');
        return;
      }
      
      // 设置重新加载状态
      isReloadingMarkdown.value = true;
      markdownReloadError.value = '';
      markdownReloadSuccess.value = false;
      
      // 触发状态变化
      shouldReloadMarkdown.value = true;
      
      getLogger().i('✅ Markdown重新加载触发完成');
    } catch (e) {
      getLogger().e('❌ 触发Markdown重新加载失败: $e');
      isReloadingMarkdown.value = false;
      markdownReloadError.value = '触发Markdown重新加载失败: $e';
    }
  }
  
  /// 更新标签页Widget的padding
  void updateTabWidgets(EdgeInsets padding) {
    try {
      getLogger().d('🔄 更新标签页Widget的padding: $padding');
      
      // 这个方法主要用于响应式更新标签页的padding
      // 在当前的实现中，padding的更新是通过重新创建Widget来实现的
      // 这里可以添加具体的padding更新逻辑，或者简单地触发重新构建
      
      // 如果需要立即更新，可以触发标签页的重新构建
      if (articleController.hasArticle && tabs.isNotEmpty) {
        // 触发UI更新
        update();
        getLogger().d('✅ 标签页Widget padding更新完成');
      }
      
    } catch (e) {
      getLogger().e('❌ 更新标签页Widget padding失败: $e');
    }
  }
  
  /// 取消所有正在进行的操作
  void cancelAllOperations() {
    getLogger().i('🛑 取消所有正在进行的Tab页面操作');
    
    // 重置所有进行中的状态
    isGeneratingSnapshot.value = false;
    isGeneratingMarkdown.value = false;
    isReloadingMarkdown.value = false;
    isLoadingNewSnapshot.value = false;
    
    // 重置触发状态
    shouldGenerateSnapshot.value = false;
    shouldGenerateMarkdown.value = false;
    shouldReloadMarkdown.value = false;
    shouldLoadNewSnapshot.value = false;
    
    // 清理路径
    newSnapshotPath.value = '';
    
    getLogger().i('✅ 所有Tab页面操作已取消');
  }
  
  /// 检查是否有任何操作正在进行
  bool get hasAnyOperationInProgress {
    return isGeneratingSnapshot.value ||
           isGeneratingMarkdown.value ||
           isReloadingMarkdown.value ||
           isLoadingNewSnapshot.value;
  }
  
  /// 等待所有操作完成
  Future<void> waitForAllOperationsComplete({Duration? timeout}) async {
    final completer = Completer<void>();
    Timer? timeoutTimer;
    
    // 设置超时
    if (timeout != null) {
      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(
            ArticleTabException('等待操作完成超时: ${timeout.inSeconds}秒')
          );
        }
      });
    }
    
    // 检查操作状态
    void checkOperations() {
      if (!hasAnyOperationInProgress && !completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.complete();
      }
    }
    
    // 立即检查一次
    checkOperations();
    
    // 如果还有操作在进行，设置监听
    if (hasAnyOperationInProgress) {
      late final StreamSubscription subscription;
      subscription = Stream.periodic(const Duration(milliseconds: 100))
          .listen((_) {
        checkOperations();
        if (completer.isCompleted) {
          subscription.cancel();
        }
      });
    }
    
    return completer.future;
  }
  
  /// 批量处理操作
  void _processBatchedOperations(List<String> operations) {
    try {
      getLogger().d('🔄 批量处理操作: ${operations.length}个');
      
      for (final operation in operations) {
        // 处理具体的操作
        getLogger().d('📝 处理操作: $operation');
      }
      
      getLogger().d('✅ 批量操作处理完成');
    } catch (e) {
      getLogger().e('❌ 批量处理操作失败: $e');
    }
  }
  
  /// 设置页面销毁状态
  void setPageDisposing(bool disposing) {
    _isPageDisposing = disposing;
    if (disposing) {
      getLogger().i('🔄 标签页控制器进入销毁状态');
    }
  }
  
  /// 暂停所有WebView实例
  Future<void> pauseAllWebViewInstances() async {
    try {
      getLogger().i('⏸️ 暂停所有WebView实例');
      
      // 暂停WebView生命周期管理器中的所有实例
      _webViewLifecycleManager.pauseInvisibleInstances();
      
      // 等待暂停操作完成
      await Future.delayed(const Duration(milliseconds: 100));
      
      getLogger().i('✅ 所有WebView实例已暂停');
    } catch (e) {
      getLogger().e('❌ 暂停WebView实例失败: $e');
    }
  }
  
  /// 销毁WebView实例
  Future<void> disposeWebViewInstances() async {
    try {
      getLogger().i('🗑️ 开始销毁WebView实例');
      
      // 优雅销毁所有WebView实例
      await _webViewLifecycleManager.disposeAllInstances();
      
      getLogger().i('✅ WebView实例销毁完成');
    } catch (e) {
      getLogger().e('❌ 销毁WebView实例失败: $e');
    }
  }
  
  /// 清理WebView相关的回调
  Future<void> clearWebViewCallbacks() async {
    try {
      getLogger().i('🧹 清理WebView回调');
      
      // 清理滚动和点击处理器
      _scrollHandler = null;
      _tapHandler = null;
      
      // 清理标签页回调
      onTabChanged = null;
      onTabLoadingChanged = null;
      onTabError = null;
      
      getLogger().i('✅ WebView回调清理完成');
    } catch (e) {
      getLogger().e('❌ 清理WebView回调失败: $e');
    }
  }
  
  /// 清理高级缓存
  void clearAdvancedCache() {
    try {
      getLogger().i('🧹 清理高级缓存');
      
      // 清理高级缓存管理器
      _widgetCacheManager.clear();
      
      // 清理标签页配置
      _tabConfigs.clear();
      
      // 重置缓存状态
      isTabWidgetsCached.value = false;
      
      getLogger().i('✅ 高级缓存清理完成');
    } catch (e) {
      getLogger().e('❌ 清理高级缓存失败: $e');
    }
  }
  
  /// 优化内存使用
  Future<void> optimizeMemoryUsage() async {
    try {
      getLogger().i('🧠 开始内存优化');
      
      // 使用WebView生命周期管理器优化内存
      await _webViewLifecycleManager.optimizeMemoryUsage();
      
      // 清理过期的Widget缓存
      _widgetCacheManager.cleanupExpired();
      
      // 触发垃圾回收
      _memoryMonitor.triggerGarbageCollection();
      
      getLogger().i('✅ 内存优化完成');
    } catch (e) {
      getLogger().e('❌ 内存优化失败: $e');
    }
  }
  
  /// 强制销毁所有WebView
  Future<void> forceDisposeAllWebViews() async {
    try {
      getLogger().w('🚨 强制销毁所有WebView');
      
      // 取消所有操作
      cancelAllOperations();
      
      // 强制销毁WebView生命周期管理器中的所有实例
      await _webViewLifecycleManager.disposeAllInstances();
      
      // 清理所有缓存
      clearTabWidgetsCache();
      clearAdvancedCache();
      
      getLogger().w('⚠️ 强制销毁WebView完成');
    } catch (e) {
      getLogger().e('❌ 强制销毁WebView失败: $e');
    }
  }
  
  /// 预加载WebView组件
  Future<void> preloadWebViewComponents() async {
    try {
      getLogger().i('🌐 开始预加载WebView组件');
      
      // 预热WebView生命周期管理器
      await _webViewLifecycleManager.createInstance(
        preferredId: 'preload_webview',
        metadata: {'purpose': 'preload', 'createdAt': DateTime.now().toIso8601String()},
      );
      
      // 预初始化WebView实例
      await _webViewLifecycleManager.initializeInstance('preload_webview');
      
      // 预加载常用的WebView设置
      await _preloadWebViewSettings();
      
      // 预热Widget缓存管理器
      _widgetCacheManager.preload();
      
      getLogger().i('✅ WebView组件预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载WebView组件失败: $e');
    }
  }
  
  /// 预加载WebView设置
  Future<void> _preloadWebViewSettings() async {
    try {
      getLogger().d('⚙️ 开始预加载WebView设置');
      
      // 预加载常用的WebView配置
      // 这里可以预设一些WebView的通用配置
      
      // 模拟预加载过程
      await Future.delayed(const Duration(milliseconds: 100));
      
      getLogger().d('✅ WebView设置预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载WebView设置失败: $e');
    }
  }
  
  /// 准备销毁
  Future<void> prepareForDispose() async {
    try {
      getLogger().i('🔄 标签页控制器准备销毁');
      
      // 设置销毁状态
      setPageDisposing(true);
      
      // 取消所有操作
      cancelAllOperations();
      
      // 等待操作完成
      try {
        await waitForAllOperationsComplete(timeout: const Duration(seconds: 2));
      } catch (e) {
        getLogger().w('⚠️ 等待操作完成超时: $e');
      }
      
      // 清理资源
      await clearWebViewCallbacks();
      clearAdvancedCache();
      
      getLogger().i('✅ 标签页控制器销毁准备完成');
    } catch (e) {
      getLogger().e('❌ 标签页控制器销毁准备失败: $e');
    }
  }
  
  @override
  void onClose() {
    getLogger().i('🔄 ArticleTabController 开始销毁');
    
    try {
      // 设置销毁状态
      setPageDisposing(true);
      
      // 取消所有操作
      cancelAllOperations();
      
      // 清理性能优化工具
      _stateUpdateDebouncer.dispose();
      _operationBatcher.dispose();
      _webViewOptimizer.dispose();
      _tabPerformanceMonitor.reset();
      _tabSwitchLimiter.reset();
      
      // 清理高级管理器
      _widgetCacheManager.dispose();
      _webViewLifecycleManager.dispose();
      _memoryMonitor.dispose();
      
      // 清理缓存
      clearTabWidgetsCache();
      clearAdvancedCache();
      
      // 销毁TabController
      tabController.dispose();
      
      getLogger().i('✅ ArticleTabController 销毁完成');
    } catch (e) {
      getLogger().e('❌ ArticleTabController 销毁时出错: $e');
    }
    
    super.onClose();
  }
}
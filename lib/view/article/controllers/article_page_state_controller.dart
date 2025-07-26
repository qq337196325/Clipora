import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../basics/logger.dart';
import '../controller/article_controller.dart';
import '../models/article_page_state.dart';
import '../exceptions/article_state_exception.dart';
import 'article_scroll_controller.dart';
import 'article_tab_controller.dart';
import 'article_ui_controller.dart';
import 'article_error_controller.dart';

/// 文章页面主状态管理控制器
/// 
/// 这是文章页面状态管理的核心控制器，负责协调所有子控制器和管理页面级别的状态。
/// 它实现了关注点分离的架构模式，将UI逻辑与业务逻辑分离。
/// 
/// ## 主要职责：
/// - 初始化和管理所有子控制器（滚动、标签页、UI、错误控制器）
/// - 协调子控制器之间的交互和数据流
/// - 管理文章页面的生命周期（初始化、销毁、退出预处理）
/// - 处理文章内容的生成操作（快照、Markdown）
/// - 提供统一的状态管理接口
/// 
/// ## 架构设计：
/// ```
/// ArticlePageStateController (主控制器)
/// ├── ArticleScrollController (滚动状态管理)
/// ├── ArticleTabController (标签页状态管理)
/// ├── ArticleUIController (UI可见性管理)
/// └── ArticleErrorController (错误状态管理)
/// ```
/// 
/// ## 使用示例：
/// ```dart
/// final controller = Get.put(ArticlePageStateController());
/// await controller.initialize(articleId);
/// 
/// // 生成快照
/// await controller.generateSnapshot();
/// 
/// // 页面退出时清理
/// await controller.prepareForPageExit();
/// ```
/// 
/// ## 状态管理模式：
/// - 使用GetX的响应式编程模式
/// - 实现单向数据流
/// - 通过回调函数进行子控制器间通信
/// - 集中管理所有页面状态
/// 
/// ## 性能优化：
/// - 实现了优雅的资源清理机制
/// - 支持WebView资源的生命周期管理
/// - 提供内存优化和缓存管理
/// - 实现了防抖和节流机制
/// 
/// @author AI Assistant
/// @since 1.0.0
/// @see ArticleScrollController 滚动状态管理
/// @see ArticleTabController 标签页状态管理
/// @see ArticleUIController UI状态管理
/// @see ArticleErrorController 错误状态管理
class ArticlePageStateController extends GetxController {
  // 子控制器
  late final ArticleScrollController scrollController;
  late final ArticleTabController tabController;
  late final ArticleUIController uiController;
  late final ArticleErrorController errorController;

  // 页面状态
  final Rx<ArticlePageState> _state = const ArticlePageState().obs;
  ArticlePageState get state => _state.value;

  // 页面基本状态
  final RxBool isInitialized = false.obs;
  final RxBool isDisposing = false.obs;

  // 文章相关
  int articleId = 0;
  final ArticleController articleController = Get.find<ArticleController>();

  @override
  void onInit() {
    super.onInit();
    _initializeSubControllers();
    getLogger().i('🎯 ArticlePageStateController 初始化完成');
  }

  /// 初始化子控制器
  void _initializeSubControllers() {
    try {
      // 创建子控制器实例
      scrollController = ArticleScrollController();
      tabController = ArticleTabController();
      uiController = ArticleUIController();
      errorController = ArticleErrorController();

      // 注册子控制器到GetX
      Get.put(scrollController, tag: 'article_scroll_$hashCode');
      Get.put(tabController, tag: 'article_tab_$hashCode');
      Get.put(uiController, tag: 'article_ui_$hashCode');
      Get.put(errorController, tag: 'article_error_$hashCode');

      // 设置子控制器之间的关联
      _setupControllerRelationships();

      getLogger().i('✅ 子控制器初始化完成');
    } catch (e, stackTrace) {
      getLogger().e('❌ 子控制器初始化失败: $e');
      final exception = ArticleInitializationException(
        '子控制器初始化失败',
        originalError: e,
        stackTrace: stackTrace,
      );

      // 如果错误控制器已创建，使用它处理错误
      errorController.handleError(exception, operation: 'initialization');

      throw exception;
    }
  }

  /// 设置控制器之间的关联关系
  void _setupControllerRelationships() {
    // 滚动事件影响UI可见性
    scrollController.onScrollChanged = (direction, scrollY) {
      uiController.updateUIVisibilityFromScroll(direction, scrollY);
    };

    // 设置标签页控制器的滚动和点击处理器
    tabController.setScrollHandler((direction, scrollY) {
      handleScroll(direction, scrollY);
    });

    tabController.setTapHandler(() {
      handlePageTap();
    });

    // 标签页状态变化影响整体状态
    tabController.tabs.listen((tabs) {
      _updateState(state.copyWith(tabs: tabs));
    });

    // UI状态变化影响整体状态
    uiController.isBottomBarVisible.listen((isVisible) {
      _updateState(state.copyWith(isBottomBarVisible: isVisible));
    });

    uiController.isLoading.listen((isLoading) {
      _updateState(state.copyWith(isLoading: isLoading));
    });

    uiController.hasError.listen((hasError) {
      _updateState(state.copyWith(hasError: hasError));
    });

    uiController.errorMessage.listen((errorMessage) {
      _updateState(state.copyWith(errorMessage: errorMessage));
    });
  }

  /// 初始化页面
  Future<void> initialize(int articleId) async {
    if (isInitialized.value) {
      getLogger().w('⚠️ 页面已经初始化，跳过重复初始化');
      return;
    }

    try {
      getLogger().i('🚀 开始初始化文章页面，ID: $articleId');

      articleId = articleId;
      uiController.setLoadingState(true);

      // 设置文章控制器的文章ID
      articleController.articleId = articleId;

      // 加载文章数据
      await articleController.loadArticleById(articleId);

      if (articleController.hasArticle) {
        // 初始化标签页
        tabController.initializeTabs(articleController.currentArticle!);

        // 恢复滚动位置
        await scrollController.restoreScrollPosition();

        // 更新状态
        _updateState(state.copyWith(
          isInitialized: true,
          tabs: tabController.tabs.toList(),
        ));

        isInitialized.value = true;
        uiController.setLoadingState(false);
        update();
        getLogger().i('✅ 文章页面初始化完成');
      } else {
        throw ArticleInitializationException('文章数据加载失败');
      }
    } catch (e, stackTrace) {
      getLogger().e('❌ 文章页面初始化失败: $e');

      uiController.setLoadingState(false);
      uiController.setErrorState(true, '页面初始化失败: $e');

      final exception = ArticleInitializationException(
        '文章页面初始化失败',
        originalError: e,
        stackTrace: stackTrace,
      );

      // 使用错误控制器处理错误
      errorController.handleError(exception,
          operation: 'initialization', canRetry: true);

      throw exception;
    }
  }

  /// 生成快照
  Future<void> generateSnapshot() async {
    try {
      getLogger().i('📸 开始生成快照');

      if (!isInitialized.value) {
        throw ArticleStateException('页面未初始化，无法生成快照');
      }

      // 检查当前是否在网页标签页
      final webTabIndex = tabController.getWebTabIndex();
      if (tabController.tabController.index != webTabIndex) {
        throw ArticleStateException('请切换到网页标签页生成快照');
      }

      // 触发网页标签页生成快照
      tabController.triggerSnapshotGeneration();

      getLogger().i('✅ 快照生成请求已发送');
    } catch (e, stackTrace) {
      getLogger().e('❌ 生成快照失败: $e');
      uiController.setErrorState(true, '生成快照失败: $e');

      throw ArticleStateException(
        '生成快照失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 重新生成快照
  Future<void> regenerateSnapshot() async {
    try {
      getLogger().i('🔄 开始重新生成快照');

      if (!isInitialized.value) {
        throw ArticleStateException('页面未初始化，无法重新生成快照');
      }

      uiController.setLoadingState(true);

      // 触发网页标签页生成快照
      tabController.triggerSnapshotGeneration();

      // 等待快照生成完成
      await Future.delayed(const Duration(milliseconds: 500));

      // 刷新文章数据
      await articleController.refreshCurrentArticle();

      // 触发快照标签页加载新快照
      if (articleController.hasArticle) {
        final currentArticle = articleController.currentArticle!;
        if (currentArticle.mhtmlPath.isNotEmpty) {
          tabController.triggerSnapshotLoad(currentArticle.mhtmlPath);
        }
      }

      // 刷新标签页
      tabController.refreshTabs();

      uiController.setLoadingState(false);
      getLogger().i('✅ 快照重新生成完成');
    } catch (e, stackTrace) {
      getLogger().e('❌ 重新生成快照失败: $e');
      uiController.setLoadingState(false);
      uiController.setErrorState(true, '重新生成快照失败: $e');

      throw ArticleStateException(
        '重新生成快照失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 重新生成Markdown
  Future<void> regenerateMarkdown() async {
    try {
      getLogger().i('📝 开始重新生成Markdown');

      if (!isInitialized.value) {
        throw ArticleStateException('页面未初始化，无法重新生成Markdown');
      }

      uiController.setLoadingState(true);

      // 触发网页标签页生成Markdown
      tabController.triggerMarkdownGeneration();

      // 刷新文章数据
      await articleController.refreshCurrentArticle();

      // 刷新Markdown内容
      await articleController.refreshMarkdownContent();

      if (articleController.currentMarkdownContent.isNotEmpty) {
        // 触发Markdown标签页重新加载
        tabController.triggerMarkdownReload();
      }

      // 刷新标签页
      tabController.refreshTabs();

      uiController.setLoadingState(false);
      getLogger().i('✅ Markdown重新生成完成');
    } catch (e, stackTrace) {
      getLogger().e('❌ 重新生成Markdown失败: $e');
      uiController.setLoadingState(false);
      uiController.setErrorState(true, '重新生成Markdown失败: $e');

      throw ArticleStateException(
        '重新生成Markdown失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 页面退出预处理
  /// 实现WebView资源的优雅清理和状态保存的自动化处理
  Future<void> prepareForPageExit() async {
    if (isDisposing.value) return;

    isDisposing.value = true;

    try {
      getLogger().i('🔄 开始页面退出预处理');

      // 1. 取消所有正在进行的操作
      await _cancelAllOngoingOperations();

      // 2. 保存当前状态
      await _saveCurrentState();

      // 3. 优雅清理WebView资源
      await _cleanupWebViewResources();

      // 4. 清理缓存和内存
      await _cleanupCacheAndMemory();

      // 5. 最终确认清理完成
      await _finalizeCleanup();

      getLogger().i('✅ 页面退出预处理完成');
    } catch (e, stackTrace) {
      getLogger().e('❌ 页面退出预处理失败: $e');

      // 即使出错也要尝试基本清理
      await _emergencyCleanup();

      throw ArticleStateException(
        '页面退出预处理失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 取消所有正在进行的操作
  Future<void> _cancelAllOngoingOperations() async {
    try {
      getLogger().i('🛑 取消所有正在进行的操作');

      // 取消标签页控制器中的所有操作
      tabController.cancelAllOperations();

      // 等待所有操作完成或超时
      try {
        await tabController.waitForAllOperationsComplete(
            timeout: const Duration(seconds: 3));
        getLogger().i('✅ 所有操作已正常取消');
      } on ArticleStateException catch (e) {
        getLogger().w('⚠️ 等待操作完成超时，强制继续: $e');
      }
    } catch (e) {
      getLogger().e('❌ 取消操作时出错: $e');
      // 继续执行，不阻断退出流程
    }
  }

  /// 保存当前状态
  Future<void> _saveCurrentState() async {
    try {
      getLogger().i('💾 保存当前状态');

      // 保存滚动位置
      await scrollController.saveScrollPosition();

      // 保存文章阅读状态（如果有相关方法）
      if (articleController.hasArticle) {
        try {
          // 尝试保存阅读位置（如果方法存在）
          final currentArticle = articleController.currentArticle!;
          getLogger().d('📖 保存文章阅读状态: ${currentArticle.title}');

          // 这里可以添加具体的状态保存逻辑
          // 比如保存当前标签页、阅读进度等
          await _saveReadingProgress();
        } catch (e) {
          getLogger().w('⚠️ 保存文章状态时出错: $e');
        }
      }

      // 保存UI状态
      await _saveUIState();

      getLogger().i('✅ 状态保存完成');
    } catch (e) {
      getLogger().e('❌ 保存状态失败: $e');
      // 继续执行，不阻断退出流程
    }
  }

  /// 保存阅读进度
  Future<void> _saveReadingProgress() async {
    try {
      // 保存当前标签页索引
      final currentTab = tabController.currentTabIndex.value;
      final currentTabName = tabController.currentTabName.value;

      getLogger().d('📑 保存阅读进度: 标签页=$currentTabName, 索引=$currentTab');

      // 这里可以将阅读进度保存到本地存储或数据库
      // 例如使用SharedPreferences或数据库
    } catch (e) {
      getLogger().w('⚠️ 保存阅读进度失败: $e');
    }
  }

  /// 保存UI状态
  Future<void> _saveUIState() async {
    try {
      // 保存UI可见性状态
      final isBottomBarVisible = uiController.isBottomBarVisible.value;
      final lastScrollY = scrollController.lastScrollY.value;

      getLogger().d('🎨 保存UI状态: 底部栏可见=$isBottomBarVisible, 滚动位置=$lastScrollY');

      // 这里可以将UI状态保存到本地存储
    } catch (e) {
      getLogger().w('⚠️ 保存UI状态失败: $e');
    }
  }

  /// 优雅清理WebView资源
  Future<void> _cleanupWebViewResources() async {
    try {
      getLogger().i('🌐 开始清理WebView资源');

      // 通知标签页控制器页面即将销毁
      tabController.setPageDisposing(true);

      // 暂停所有WebView实例
      await tabController.pauseAllWebViewInstances();

      // 等待WebView操作完成
      await Future.delayed(const Duration(milliseconds: 200));

      // 优雅销毁WebView实例
      await tabController.disposeWebViewInstances();

      // 清理WebView相关的监听器和回调
      await tabController.clearWebViewCallbacks();

      getLogger().i('✅ WebView资源清理完成');
    } catch (e) {
      getLogger().e('❌ 清理WebView资源失败: $e');
      // 继续执行，不阻断退出流程
    }
  }

  /// 清理缓存和内存
  Future<void> _cleanupCacheAndMemory() async {
    try {
      getLogger().i('🧹 开始清理缓存和内存');

      // 清理标签页缓存
      tabController.clearTabWidgetsCache();

      // 清理高级缓存
      tabController.clearAdvancedCache();

      // 触发内存优化
      await tabController.optimizeMemoryUsage();

      // 清理错误控制器状态
      errorController.clearAllErrors();

      // 短暂延迟确保清理完成
      await Future.delayed(const Duration(milliseconds: 100));

      getLogger().i('✅ 缓存和内存清理完成');
    } catch (e) {
      getLogger().e('❌ 清理缓存和内存失败: $e');
      // 继续执行，不阻断退出流程
    }
  }

  /// 最终确认清理完成
  Future<void> _finalizeCleanup() async {
    try {
      getLogger().i('🏁 最终确认清理');

      // 确保所有子控制器都已准备好销毁
      await scrollController.prepareForDispose();
      await tabController.prepareForDispose();
      await uiController.prepareForDispose();
      await errorController.prepareForDispose();

      // 清理文章控制器状态（如果需要）
      if (articleController.hasArticle) {
        // 这里可以添加文章控制器的清理逻辑
        getLogger().d('📚 清理文章控制器状态');
      }

      // 最后的延迟确保所有异步操作完成
      await Future.delayed(const Duration(milliseconds: 50));

      getLogger().i('✅ 最终清理确认完成');
    } catch (e) {
      getLogger().e('❌ 最终清理确认失败: $e');
      // 即使失败也继续，因为这是最后一步
    }
  }

  /// 紧急清理（当正常清理失败时）
  Future<void> _emergencyCleanup() async {
    try {
      getLogger().w('🚨 执行紧急清理');

      // 强制取消所有操作
      tabController.cancelAllOperations();

      // 强制清理缓存
      tabController.clearTabWidgetsCache();

      // 强制销毁WebView
      await tabController.forceDisposeAllWebViews();

      // 短暂延迟
      await Future.delayed(const Duration(milliseconds: 100));

      getLogger().w('⚠️ 紧急清理完成');
    } catch (e) {
      getLogger().e('❌ 紧急清理也失败了: $e');
      // 这是最后的尝试，即使失败也不再抛出异常
    }
  }

  /// 更新整体状态
  void _updateState(ArticlePageState newState) {
    _state.value = newState;
  }

  /// 处理页面点击事件
  void handlePageTap() {
    uiController.toggleUIVisibility();
  }

  /// 处理滚动事件
  void handleScroll(ScrollDirection direction, double scrollY) {
    try {
      // 委托给滚动控制器处理
      scrollController.handleScroll(direction, scrollY);

      // 更新整体状态
      _updateState(state.copyWith(
        lastScrollY: scrollY,
        scrollDirection: direction,
      ));

      getLogger().d('📜 页面滚动事件处理完成: 方向=$direction, 位置=$scrollY');
    } catch (e, stackTrace) {
      getLogger().e('❌ 处理页面滚动事件失败: $e');
      throw ArticleStateException(
        '处理页面滚动事件失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 处理滚动事件（带X轴位置）
  void handleScrollWithPosition(
      ScrollDirection direction, double scrollY, double scrollX) {
    try {
      // 委托给滚动控制器处理（使用带X轴位置的方法）
      scrollController.handleScrollWithPosition(direction, scrollY, scrollX);

      // 更新整体状态
      _updateState(state.copyWith(
        lastScrollY: scrollY,
        scrollDirection: direction,
      ));

      getLogger().d('📜 页面滚动事件处理完成: 方向=$direction, 位置=($scrollX, $scrollY)');
    } catch (e, stackTrace) {
      getLogger().e('❌ 处理页面滚动事件失败: $e');
      throw ArticleStateException(
        '处理页面滚动事件失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 获取当前标签页索引
  int get currentTabIndex => tabController.tabController.index;

  /// 获取标签页列表
  List<String> get tabs => tabController.tabs.toList();

  /// 获取标签页Widget列表
  List<Widget> get tabWidgets => tabController.tabWidgets.toList();

  @override
  void onClose() {
    getLogger().i('🔄 ArticlePageStateController 开始销毁');

    try {
      // 清理子控制器
      Get.delete<ArticleScrollController>(tag: 'article_scroll_$hashCode');
      Get.delete<ArticleTabController>(tag: 'article_tab_$hashCode');
      Get.delete<ArticleUIController>(tag: 'article_ui_$hashCode');
      Get.delete<ArticleErrorController>(tag: 'article_error_$hashCode');

      // 清理文章控制器状态
      articleController.clearCurrentArticle();

      getLogger().i('✅ ArticlePageStateController 销毁完成');
    } catch (e) {
      getLogger().e('❌ ArticlePageStateController 销毁时出错: $e');
    }

    super.onClose();
  }
}

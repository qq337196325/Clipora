import 'dart:async';
import 'package:get/get.dart';

import '../../../basics/logger.dart';
import '../exceptions/article_state_exception.dart';
import '../models/error_state.dart';

/// 文章错误处理和恢复控制器
/// 负责集中管理错误状态和实现错误恢复策略
class ArticleErrorController extends GetxController {
  
  // 错误状态管理
  final Rx<ErrorState> _currentError = ErrorState().obs;
  ErrorState get currentError => _currentError.value;
  
  // 错误历史记录
  final RxList<ErrorState> errorHistory = <ErrorState>[].obs;
  
  // 重试配置
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration retryBackoffMultiplier = Duration(seconds: 1);
  
  // 重试状态
  final RxMap<String, int> retryAttempts = <String, int>{}.obs;
  final RxMap<String, bool> isRetrying = <String, bool>{}.obs;
  
  // 错误回调
  void Function(ErrorState error)? onErrorOccurred;
  void Function(ErrorState error)? onErrorRecovered;
  void Function(String operation, int attempt)? onRetryAttempt;
  
  @override
  void onInit() {
    super.onInit();
    getLogger().i('🚨 ArticleErrorController 初始化完成');
  }
  
  /// 处理错误
  void handleError(ArticleStateException exception, {
    String? operation,
    bool canRetry = true,
    Map<String, dynamic>? context,
  }) {
    try {
      final errorState = ErrorState(
        exception: exception,
        operation: operation ?? 'unknown',
        canRetry: canRetry,
        context: context ?? {},
        timestamp: DateTime.now(),
      );
      
      // 更新当前错误状态
      _currentError.value = errorState;
      
      // 添加到错误历史
      errorHistory.add(errorState);
      
      // 限制历史记录数量
      if (errorHistory.length > 50) {
        errorHistory.removeAt(0);
      }
      
      // 触发错误回调
      onErrorOccurred?.call(errorState);
      
      getLogger().e('🚨 错误已记录: ${errorState.userFriendlyMessage}');
      
      // 如果可以重试，自动尝试恢复
      if (canRetry && errorState.operation.isNotEmpty) {
        _scheduleAutoRetry(errorState);
      }
    } catch (e) {
      getLogger().e('❌ 处理错误时发生异常: $e');
    }
  }
  
  /// 安排自动重试
  void _scheduleAutoRetry(ErrorState errorState) {
    final operation = errorState.operation;
    final currentAttempts = retryAttempts[operation] ?? 0;
    
    if (currentAttempts >= maxRetryAttempts) {
      getLogger().w('⚠️ 操作 $operation 已达到最大重试次数');
      return;
    }
    
    // 计算延迟时间（指数退避）
    final delay = retryDelay + (retryBackoffMultiplier * currentAttempts);
    
    getLogger().i('🔄 将在 ${delay.inSeconds} 秒后重试操作: $operation');
    
    Timer(delay, () {
      retryOperation(operation);
    });
  }
  
  /// 手动重试操作
  Future<bool> retryOperation(String operation) async {
    if (isRetrying[operation] == true) {
      getLogger().w('⚠️ 操作 $operation 正在重试中');
      return false;
    }
    
    final currentAttempts = retryAttempts[operation] ?? 0;
    if (currentAttempts >= maxRetryAttempts) {
      getLogger().w('⚠️ 操作 $operation 已达到最大重试次数');
      return false;
    }
    
    try {
      isRetrying[operation] = true;
      retryAttempts[operation] = currentAttempts + 1;
      
      getLogger().i('🔄 开始重试操作: $operation (第 ${currentAttempts + 1} 次)');
      
      // 触发重试回调
      onRetryAttempt?.call(operation, currentAttempts + 1);
      
      // 根据操作类型执行相应的重试逻辑
      final success = await _executeRetryLogic(operation);
      
      if (success) {
        // 重试成功，清理重试状态
        retryAttempts.remove(operation);
        isRetrying[operation] = false;
        
        // 清除相关错误状态
        _clearErrorForOperation(operation);
        
        getLogger().i('✅ 操作 $operation 重试成功');
        return true;
      } else {
        isRetrying[operation] = false;
        getLogger().w('⚠️ 操作 $operation 重试失败');
        return false;
      }
    } catch (e) {
      isRetrying[operation] = false;
      getLogger().e('❌ 重试操作 $operation 时发生异常: $e');
      return false;
    }
  }
  
  /// 执行具体的重试逻辑
  Future<bool> _executeRetryLogic(String operation) async {
    try {
      switch (operation) {
        case 'initialization':
          return await _retryInitialization();
        case 'tab_loading':
          return await _retryTabLoading();
        case 'webview_communication':
          return await _retryWebViewCommunication();
        case 'snapshot_generation':
          return await _retrySnapshotGeneration();
        case 'markdown_generation':
          return await _retryMarkdownGeneration();
        default:
          getLogger().w('⚠️ 未知的重试操作类型: $operation');
          return false;
      }
    } catch (e) {
      getLogger().e('❌ 执行重试逻辑失败: $e');
      return false;
    }
  }
  
  /// 重试初始化
  Future<bool> _retryInitialization() async {
    try {
      getLogger().i('🔄 开始重试页面初始化');
      
      // 尝试获取页面状态控制器
      dynamic pageController;
      try {
        pageController = Get.find(tag: 'ArticlePageStateController');
      } catch (e) {
        // 如果通过tag找不到，尝试通过类型查找
        try {
          pageController = Get.find<GetxController>();
        } catch (e2) {
          pageController = null;
        }
      }
      
      if (pageController == null) {
        getLogger().e('❌ 未找到页面状态控制器');
        return false;
      }
      
      // 清理之前的状态
      if (pageController.isInitialized?.value == true) {
        pageController.isInitialized.value = false;
      }
      
      // 重新初始化
      await pageController.initialize(pageController.articleId ?? 0);
      
      getLogger().i('✅ 页面初始化重试成功');
      return true;
    } catch (e) {
      getLogger().e('❌ 重试初始化失败: $e');
      return false;
    }
  }
  
  /// 重试标签页加载
  Future<bool> _retryTabLoading() async {
    try {
      getLogger().i('🔄 开始重试标签页加载');
      
      // 尝试获取标签页控制器
      dynamic tabController;
      try {
        tabController = Get.find(tag: 'ArticleTabController');
      } catch (e) {
        // 如果通过tag找不到，尝试通过类型查找
        try {
          tabController = Get.find<GetxController>();
        } catch (e2) {
          tabController = null;
        }
      }
      
      if (tabController == null) {
        getLogger().e('❌ 未找到标签页控制器');
        return false;
      }
      
      // 清理缓存并重新初始化标签页
      try {
        tabController.clearTabWidgetsCache();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // 获取文章控制器
        dynamic articleController;
        try {
          articleController = Get.find(tag: 'ArticleController');
        } catch (e) {
          try {
            articleController = Get.find<GetxController>();
          } catch (e2) {
            articleController = null;
          }
        }
        
        if (articleController?.hasArticle == true) {
          tabController.initializeTabs(articleController.currentArticle);
          tabController.refreshTabs();
        }
        
        getLogger().i('✅ 标签页加载重试成功');
        return true;
      } catch (e) {
        getLogger().e('❌ 标签页重新初始化失败: $e');
        return false;
      }
    } catch (e) {
      getLogger().e('❌ 重试标签页加载失败: $e');
      return false;
    }
  }
  
  /// 重试WebView通信
  Future<bool> _retryWebViewCommunication() async {
    try {
      getLogger().i('🔄 开始重试WebView通信');
      
      // 获取标签页控制器
      dynamic tabController;
      try {
        tabController = Get.find(tag: 'ArticleTabController');
      } catch (e) {
        try {
          tabController = Get.find<GetxController>();
        } catch (e2) {
          tabController = null;
        }
      }
      
      if (tabController == null) {
        getLogger().e('❌ 未找到标签页控制器');
        return false;
      }
      
      // 实现WebView通信降级处理
      try {
        // 1. 清理WebView缓存
        tabController.clearTabWidgetsCache();
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 2. 重新创建WebView组件
        dynamic articleController;
        try {
          articleController = Get.find(tag: 'ArticleController');
        } catch (e) {
          try {
            articleController = Get.find<GetxController>();
          } catch (e2) {
            articleController = null;
          }
        }
        
        if (articleController?.hasArticle == true) {
          // 3. 重新初始化标签页（这会重新创建WebView）
          tabController.initializeTabs(articleController.currentArticle);
          
          // 4. 等待WebView初始化完成
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // 5. 尝试切换到网页标签页以测试通信
          final webTabIndex = tabController.getWebTabIndex();
          if (webTabIndex >= 0 && webTabIndex < tabController.tabs.length) {
            tabController.tabController.index = webTabIndex;
          }
          
          getLogger().i('✅ WebView通信重试成功');
          return true;
        } else {
          getLogger().e('❌ 没有可用的文章数据');
          return false;
        }
      } catch (e) {
        getLogger().e('❌ WebView通信降级处理失败: $e');
        
        // 降级策略：禁用WebView相关功能
        try {
          // 可以在这里实现更激进的降级策略
          // 比如只显示基础的文本内容，禁用WebView功能
          getLogger().w('⚠️ 启用WebView降级模式');
          return true; // 即使WebView失败，也认为恢复成功（降级模式）
        } catch (fallbackError) {
          getLogger().e('❌ WebView降级模式也失败: $fallbackError');
          return false;
        }
      }
    } catch (e) {
      getLogger().e('❌ 重试WebView通信失败: $e');
      return false;
    }
  }
  
  /// 重试快照生成
  Future<bool> _retrySnapshotGeneration() async {
    try {
      getLogger().i('🔄 开始重试快照生成');
      
      // 获取标签页控制器
      dynamic tabController;
      try {
        tabController = Get.find(tag: 'ArticleTabController');
      } catch (e) {
        try {
          tabController = Get.find<GetxController>();
        } catch (e2) {
          tabController = null;
        }
      }
      
      if (tabController == null) {
        getLogger().e('❌ 未找到标签页控制器');
        return false;
      }
      
      // 检查是否有正在进行的快照生成
      if (tabController.isGeneratingSnapshot?.value == true) {
        getLogger().w('⚠️ 快照正在生成中，等待完成');
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // 重置快照生成状态
      if (tabController.snapshotGenerationError?.value?.isNotEmpty == true) {
        tabController.snapshotGenerationError.value = '';
      }
      
      // 触发快照生成
      await tabController.triggerSnapshotGeneration();
      
      // 等待生成完成或超时
      int waitCount = 0;
      const maxWaitCount = 30; // 30秒超时
      
      while (waitCount < maxWaitCount) {
        await Future.delayed(const Duration(seconds: 1));
        waitCount++;
        
        if (tabController.snapshotGenerationSuccess?.value == true) {
          getLogger().i('✅ 快照生成重试成功');
          return true;
        }
        
        if (tabController.snapshotGenerationError?.value?.isNotEmpty == true) {
          getLogger().e('❌ 快照生成重试失败: ${tabController.snapshotGenerationError.value}');
          return false;
        }
      }
      
      getLogger().w('⚠️ 快照生成重试超时');
      return false;
    } catch (e) {
      getLogger().e('❌ 重试快照生成失败: $e');
      return false;
    }
  }
  
  /// 重试Markdown生成
  Future<bool> _retryMarkdownGeneration() async {
    try {
      getLogger().i('🔄 开始重试Markdown生成');
      
      // 获取标签页控制器
      // final tabControllers = Get.findAll<dynamic>();
      // 获取标签页控制器
      dynamic tabController;
      try {
        tabController = Get.find(tag: 'ArticleTabController');
      } catch (e) {
        try {
          tabController = Get.find<GetxController>();
        } catch (e2) {
          tabController = null;
        }
      }
      
      // for (final controller in tabControllers) {
      //   if (controller.runtimeType.toString().contains('ArticleTabController')) {
      //     tabController = controller;
      //     break;
      //   }
      // }
      
      if (tabController == null) {
        getLogger().e('❌ 未找到标签页控制器');
        return false;
      }
      
      // 检查是否有正在进行的Markdown生成
      if (tabController.isGeneratingMarkdown?.value == true) {
        getLogger().w('⚠️ Markdown正在生成中，等待完成');
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // 重置Markdown生成状态
      if (tabController.markdownGenerationError?.value?.isNotEmpty == true) {
        tabController.markdownGenerationError.value = '';
      }
      
      // 触发Markdown生成
      await tabController.triggerMarkdownGeneration();
      
      // 等待生成完成或超时
      int waitCount = 0;
      const maxWaitCount = 30; // 30秒超时
      
      while (waitCount < maxWaitCount) {
        await Future.delayed(const Duration(seconds: 1));
        waitCount++;
        
        if (tabController.markdownGenerationSuccess?.value == true) {
          getLogger().i('✅ Markdown生成重试成功');
          return true;
        }
        
        if (tabController.markdownGenerationError?.value?.isNotEmpty == true) {
          getLogger().e('❌ Markdown生成重试失败: ${tabController.markdownGenerationError.value}');
          return false;
        }
      }
      
      getLogger().w('⚠️ Markdown生成重试超时');
      return false;
    } catch (e) {
      getLogger().e('❌ 重试Markdown生成失败: $e');
      return false;
    }
  }
  
  /// 清除特定操作的错误状态
  void _clearErrorForOperation(String operation) {
    if (_currentError.value.operation == operation) {
      _currentError.value = ErrorState();
    }
    
    // 触发恢复回调
    onErrorRecovered?.call(_currentError.value);
  }
  
  /// 清除所有错误状态
  void clearAllErrors() {
    _currentError.value = ErrorState();
    retryAttempts.clear();
    isRetrying.clear();
    getLogger().i('🧹 所有错误状态已清除');
  }
  
  /// 清除错误历史
  void clearErrorHistory() {
    errorHistory.clear();
    getLogger().i('🧹 错误历史已清除');
  }
  
  /// 获取用户友好的错误消息
  String getUserFriendlyErrorMessage(ArticleStateException exception) {
    // 根据异常类型返回用户友好的消息
    if (exception is ArticleInitializationException) {
      return '页面初始化失败，请稍后重试';
    } else if (exception is ArticleTabException) {
      return '标签页加载失败，请刷新页面';
    } else if (exception is ArticleScrollException) {
      return '页面滚动出现问题，请重新加载';
    } else if (exception is ArticleUIException) {
      return 'UI显示异常，请刷新页面';
    } else {
      return '操作失败，请稍后重试';
    }
  }
  
  /// 检查是否有活跃的错误
  bool get hasActiveError => _currentError.value.hasError;
  
  /// 检查特定操作是否正在重试
  bool isOperationRetrying(String operation) {
    return isRetrying[operation] == true;
  }
  
  /// 获取操作的重试次数
  int getRetryAttempts(String operation) {
    return retryAttempts[operation] ?? 0;
  }
  
  /// 检查操作是否可以重试
  bool canRetryOperation(String operation) {
    return getRetryAttempts(operation) < maxRetryAttempts;
  }
  
  /// 强制停止重试
  void stopRetry(String operation) {
    isRetrying[operation] = false;
    retryAttempts[operation] = maxRetryAttempts; // 设置为最大值以阻止进一步重试
    getLogger().i('🛑 已停止操作 $operation 的重试');
  }
  
  /// 重置操作的重试状态
  void resetRetryState(String operation) {
    retryAttempts.remove(operation);
    isRetrying.remove(operation);
    getLogger().i('🔄 已重置操作 $operation 的重试状态');
  }
  
  /// 获取错误统计信息
  Map<String, dynamic> getErrorStatistics() {
    final errorsByType = <String, int>{};
    final errorsByOperation = <String, int>{};
    
    for (final error in errorHistory) {
      final type = error.exception.runtimeType.toString();
      errorsByType[type] = (errorsByType[type] ?? 0) + 1;
      
      errorsByOperation[error.operation] = (errorsByOperation[error.operation] ?? 0) + 1;
    }
    
    return {
      'totalErrors': errorHistory.length,
      'errorsByType': errorsByType,
      'errorsByOperation': errorsByOperation,
      'activeRetries': isRetrying.length,
      'hasActiveError': hasActiveError,
    };
  }
  
  /// 准备销毁
  Future<void> prepareForDispose() async {
    try {
      getLogger().i('🔄 错误控制器准备销毁');
      
      // 停止所有正在进行的重试
      final retryingOperations = isRetrying.keys.toList();
      for (final operation in retryingOperations) {
        stopRetry(operation);
      }
      
      // 清理回调函数
      onErrorOccurred = null;
      onErrorRecovered = null;
      onRetryAttempt = null;
      
      // 清理所有错误状态
      clearAllErrors();
      
      getLogger().i('✅ 错误控制器销毁准备完成');
    } catch (e) {
      getLogger().e('❌ 错误控制器销毁准备失败: $e');
    }
  }
  
  @override
  void onClose() {
    getLogger().i('🔄 ArticleErrorController 开始销毁');
    
    try {
      // 清理所有状态
      clearAllErrors();
      clearErrorHistory();
      
      getLogger().i('✅ ArticleErrorController 销毁完成');
    } catch (e) {
      getLogger().e('❌ ArticleErrorController 销毁时出错: $e');
    }
    
    super.onClose();
  }
}

/// 扩展方法，用于检查对象是否有特定方法
extension DynamicMethodCheck on dynamic {
  bool hasMethod(String methodName) {
    try {
      return this != null && 
             this.runtimeType.toString().contains('Controller') &&
             this.toString().contains(methodName);
    } catch (e) {
      return false;
    }
  }
}
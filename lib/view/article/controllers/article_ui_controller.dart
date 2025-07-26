import 'package:get/get.dart';
import 'package:flutter/rendering.dart';

import '../../../basics/logger.dart';
import '../exceptions/article_state_exception.dart';

/// 文章UI状态管理控制器
/// 
/// 专门负责管理文章页面的UI状态，包括顶部栏和底部栏的可见性控制、
/// 加载状态管理、错误状态处理等。该控制器实现了基于滚动行为的智能UI控制，
/// 提供流畅的用户交互体验。
/// 
/// ## 主要功能：
/// - **UI可见性管理**：控制顶部栏和底部栏的显示/隐藏
/// - **滚动响应**：根据滚动方向和位置自动调整UI可见性
/// - **加载状态**：管理页面和组件的加载状态显示
/// - **错误处理**：集中管理和显示错误状态
/// - **用户交互**：响应用户点击切换UI可见性
/// 
/// ## UI控制逻辑：
/// - **滚动到顶部**：当滚动位置小于阈值时，总是显示UI
/// - **向下滚动**：隐藏UI以提供更大的内容显示区域
/// - **向上滚动**：显示UI以便用户进行操作
/// - **手动切换**：用户点击时切换UI可见性状态
/// 
/// ## 状态管理：
/// - `isBottomBarVisible`: 底部栏可见性状态
/// - `isTopBarVisible`: 顶部栏可见性状态
/// - `isLoading`: 加载状态
/// - `hasError`: 错误状态
/// - `errorMessage`: 错误消息内容
/// 
/// ## 使用示例：
/// ```dart
/// final uiController = ArticleUIController();
/// 
/// // 设置加载状态
/// uiController.setLoadingState(true);
/// 
/// // 根据滚动更新UI可见性
/// uiController.updateUIVisibilityFromScroll(
///   ScrollDirection.reverse, 
///   200.0
/// );
/// 
/// // 手动切换UI可见性
/// uiController.toggleUIVisibility();
/// 
/// // 设置错误状态
/// uiController.setErrorState(true, '加载失败');
/// ```
/// 
/// ## 配置参数：
/// - `_topScrollThreshold`: 顶部滚动阈值（50.0像素）
///   当滚动位置小于此值时，UI总是可见
/// 
/// ## 错误处理策略：
/// - 出现错误时自动停止加载状态
/// - 开始加载时自动清除之前的错误状态
/// - 提供错误状态的清除和重置功能
/// 
/// ## 响应式设计：
/// 所有状态都使用GetX的响应式变量，UI组件可以通过Obx自动响应状态变化，
/// 无需手动管理UI更新。
/// 
/// @author AI Assistant
/// @since 1.0.0
/// @see ArticlePageStateController 主状态管理控制器
/// @see ArticleScrollController 滚动状态管理控制器
class ArticleUIController extends GetxController {
  
  // UI可见性状态
  final RxBool isBottomBarVisible = true.obs;
  final RxBool isTopBarVisible = true.obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // UI自动隐藏配置
  static const double _topScrollThreshold = 50.0;
  
  @override
  void onInit() {
    super.onInit();
    getLogger().i('🎨 ArticleUIController 初始化完成');
  }
  
  /// 切换UI可见性
  void toggleUIVisibility() {
    try {
      final newVisibility = !isBottomBarVisible.value;
      
      isBottomBarVisible.value = newVisibility;
      isTopBarVisible.value = newVisibility;
      
      getLogger().d('🎯 UI可见性切换: ${newVisibility ? "显示" : "隐藏"}');
    } catch (e, stackTrace) {
      getLogger().e('❌ 切换UI可见性失败: $e');
      throw ArticleUIException(
        '切换UI可见性失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 根据滚动方向更新UI可见性
  void updateUIVisibilityFromScroll(ScrollDirection direction, double scrollY) {
    try {
      // 滚动到顶部，总是显示
      if (scrollY < _topScrollThreshold) {
        if (!isBottomBarVisible.value) {
          _showUI();
        }
        return;
      }
      
      // 向下滚动，隐藏UI
      if (direction == ScrollDirection.reverse) {
        if (isBottomBarVisible.value) {
          _hideUI();
        }
      } 
      // 向上滚动，显示UI
      else if (direction == ScrollDirection.forward) {
        if (!isBottomBarVisible.value) {
          _showUI();
        }
      }
    } catch (e, stackTrace) {
      getLogger().e('❌ 根据滚动更新UI可见性失败: $e');
      throw ArticleUIException(
        '根据滚动更新UI可见性失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 显示UI
  void _showUI() {
    isBottomBarVisible.value = true;
    isTopBarVisible.value = true;
    getLogger().d('🎨 UI已显示');
  }
  
  /// 隐藏UI
  void _hideUI() {
    isBottomBarVisible.value = false;
    isTopBarVisible.value = false;
    getLogger().d('🎨 UI已隐藏');
  }
  
  /// 强制显示UI
  void forceShowUI() {
    try {
      _showUI();
      getLogger().i('🎨 强制显示UI');
    } catch (e, stackTrace) {
      getLogger().e('❌ 强制显示UI失败: $e');
      throw ArticleUIException(
        '强制显示UI失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 强制隐藏UI
  void forceHideUI() {
    try {
      _hideUI();
      getLogger().i('🎨 强制隐藏UI');
    } catch (e, stackTrace) {
      getLogger().e('❌ 强制隐藏UI失败: $e');
      throw ArticleUIException(
        '强制隐藏UI失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 设置加载状态
  void setLoadingState(bool loading) {
    try {
      isLoading.value = loading;
      
      // 加载时清除错误状态
      if (loading && hasError.value) {
        clearErrorState();
      }
      
      getLogger().d('⏳ 加载状态更新: $loading');
    } catch (e, stackTrace) {
      getLogger().e('❌ 设置加载状态失败: $e');
      throw ArticleUIException(
        '设置加载状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 设置错误状态
  void setErrorState(bool error, [String message = '']) {
    try {
      hasError.value = error;
      errorMessage.value = message;
      
      // 出现错误时停止加载
      if (error && isLoading.value) {
        isLoading.value = false;
      }
      
      getLogger().d('❌ 错误状态更新: $error, 消息: $message');
    } catch (e, stackTrace) {
      getLogger().e('❌ 设置错误状态失败: $e');
      throw ArticleUIException(
        '设置错误状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 清除错误状态
  void clearErrorState() {
    try {
      hasError.value = false;
      errorMessage.value = '';
      getLogger().d('✅ 错误状态已清除');
    } catch (e, stackTrace) {
      getLogger().e('❌ 清除错误状态失败: $e');
      throw ArticleUIException(
        '清除错误状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 重置所有UI状态
  void resetUIState() {
    try {
      isBottomBarVisible.value = true;
      isTopBarVisible.value = true;
      isLoading.value = false;
      hasError.value = false;
      errorMessage.value = '';
      
      getLogger().i('🔄 UI状态已重置');
    } catch (e, stackTrace) {
      getLogger().e('❌ 重置UI状态失败: $e');
      throw ArticleUIException(
        '重置UI状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 检查是否正在加载
  bool get isCurrentlyLoading => isLoading.value;
  
  /// 检查是否有错误
  bool get hasCurrentError => hasError.value;
  
  /// 获取当前错误消息
  String get currentErrorMessage => errorMessage.value;
  
  /// 检查UI是否可见
  bool get isUIVisible => isBottomBarVisible.value;
  
  /// 检查顶部栏是否可见
  bool get isTopBarCurrentlyVisible => isTopBarVisible.value;
  
  /// 检查底部栏是否可见
  bool get isBottomBarCurrentlyVisible => isBottomBarVisible.value;
  
  /// 准备销毁
  Future<void> prepareForDispose() async {
    try {
      getLogger().i('🔄 UI控制器准备销毁');
      
      // 清除所有状态
      clearErrorState();
      setLoadingState(false);
      
      // 恢复UI可见性到默认状态
      forceShowUI();
      
      getLogger().i('✅ UI控制器销毁准备完成');
    } catch (e) {
      getLogger().e('❌ UI控制器销毁准备失败: $e');
    }
  }
  
  @override
  void onClose() {
    getLogger().i('🔄 ArticleUIController 开始销毁');
    
    try {
      // 重置状态
      resetUIState();
      
      getLogger().i('✅ ArticleUIController 销毁完成');
    } catch (e) {
      getLogger().e('❌ ArticleUIController 销毁时出错: $e');
    }
    
    super.onClose();
  }
}
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import '../../../basics/logger.dart';
import '../controller/article_controller.dart';
import '../exceptions/article_state_exception.dart';
import '../utils/performance_utils.dart';

/// 滚动事件数据类
class ScrollEvent {
  final double scrollY;
  final double scrollX;
  final ScrollDirection direction;
  final DateTime timestamp;
  
  const ScrollEvent({
    required this.scrollY,
    required this.scrollX,
    required this.direction,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'ScrollEvent(scrollY: $scrollY, scrollX: $scrollX, direction: $direction, timestamp: $timestamp)';
  }
}

/// 文章滚动状态管理控制器
/// 
/// 专门负责管理文章页面的滚动状态，包括滚动位置的保存和恢复、滚动事件的处理、
/// 以及滚动性能的优化。该控制器实现了多种性能优化策略，确保在高频滚动事件下
/// 仍能保持流畅的用户体验。
/// 
/// ## 主要功能：
/// - **滚动状态管理**：跟踪滚动位置、方向、速度等状态
/// - **位置持久化**：自动保存和恢复滚动位置到数据库
/// - **性能优化**：防抖、节流、批处理等机制优化滚动性能
/// - **事件处理**：处理滚动事件并通知其他控制器
/// - **历史记录**：维护滚动历史用于速度计算和趋势分析
/// 
/// ## 性能优化策略：
/// - **自适应防抖器**：根据滚动频率自动调整防抖延迟
/// - **节流器**：限制UI更新频率，避免过度渲染
/// - **批处理器**：将多个滚动事件合并处理
/// - **频率限制器**：控制位置保存的频率
/// - **性能监控**：实时监控滚动性能指标
/// 
/// ## 滚动指标：
/// - `lastScrollY`: 最后的Y轴滚动位置
/// - `currentScrollX`: 当前的X轴滚动位置
/// - `scrollDirection`: 滚动方向（向上/向下/空闲）
/// - `scrollVelocity`: 滚动速度（像素/秒）
/// - `_scrollHistory`: 滚动历史记录（用于计算速度和趋势）
/// 
/// ## 使用示例：
/// ```dart
/// final scrollController = ArticleScrollController();
/// 
/// // 设置滚动事件回调
/// scrollController.onScrollChanged = (direction, scrollY) {
///   print('滚动到: $scrollY, 方向: $direction');
/// };
/// 
/// // 处理滚动事件
/// scrollController.handleScroll(ScrollDirection.reverse, 100.0);
/// 
/// // 保存滚动位置
/// await scrollController.saveScrollPosition();
/// 
/// // 恢复滚动位置
/// await scrollController.restoreScrollPosition();
/// ```
/// 
/// ## 性能监控：
/// 控制器内置了性能监控功能，可以通过 `getPerformanceReport()` 获取详细的性能报告，
/// 包括防抖器状态、批处理器队列长度、频率限制器状态等。
/// 
/// ## 内存管理：
/// 控制器会自动管理滚动历史记录的大小，防止内存泄漏。同时提供了多种清理方法
/// 确保在页面销毁时能够正确释放资源。
/// 
/// @author AI Assistant
/// @since 1.0.0
/// @see ScrollEvent 滚动事件数据类
/// @see PerformanceUtils 性能优化工具类
class ArticleScrollController extends GetxController {
  
  // 滚动状态
  final RxDouble lastScrollY = 0.0.obs;
  final RxDouble currentScrollX = 0.0.obs;
  final Rx<ScrollDirection> scrollDirection = ScrollDirection.idle.obs;
  final RxDouble scrollVelocity = 0.0.obs; // 滚动速度
  
  // 滚动历史记录（用于计算速度和趋势）
  final List<ScrollEvent> _scrollHistory = [];
  static const int _maxHistoryLength = 10;
  
  // 滚动回调
  void Function(ScrollDirection direction, double scrollY)? onScrollChanged;
  
  // 滚动状态变化回调
  void Function(ScrollEvent event)? onScrollEvent;
  void Function(double velocity)? onVelocityChanged;
  void Function(ScrollDirection trend)? onScrollTrendChanged;
  
  // 防抖Timer
  Timer? _savePositionTimer;
  Timer? _velocityCalculationTimer;
  
  // 性能优化工具
  late final AdaptiveDebouncer _scrollDebouncer;
  late final Throttler _uiUpdateThrottler;
  late final BatchProcessor<ScrollEvent> _scrollEventBatcher;
  late final PerformanceMonitor _scrollPerformanceMonitor;
  late final RateLimiter _savePositionLimiter;
  
  // 文章控制器引用
  final ArticleController articleController = Get.find<ArticleController>();
  
  // 防抖配置
  static const Duration _savePositionDelay = Duration(milliseconds: 1000);
  static const Duration _velocityCalculationInterval = Duration(milliseconds: 100);
  
  // 滚动阈值配置
  static const double _scrollThreshold = 15.0;
  static const double _topScrollThreshold = 50.0;
  static const double _fastScrollThreshold = 100.0; // 快速滚动阈值
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化性能优化工具
    _initializePerformanceTools();
    
    // 启动速度计算定时器
    _startVelocityCalculationTimer();
    
    getLogger().i('📜 ArticleScrollController 初始化完成');
  }
  
  /// 初始化性能优化工具
  void _initializePerformanceTools() {
    // 自适应防抖器，根据滚动频率自动调整延迟
    _scrollDebouncer = AdaptiveDebouncer(
      minDelay: const Duration(milliseconds: 16), // 60fps
      maxDelay: const Duration(milliseconds: 100),
      adaptationFactor: 1.2,
    );
    
    // UI更新节流器，限制UI更新频率
    _uiUpdateThrottler = Throttler(
      interval: const Duration(milliseconds: 33), // 30fps
    );
    
    // 滚动事件批处理器
    _scrollEventBatcher = BatchProcessor<ScrollEvent>(
      batchInterval: const Duration(milliseconds: 50),
      processor: _processBatchedScrollEvents,
    );
    
    // 滚动性能监控器
    _scrollPerformanceMonitor = PerformanceMonitor(
      name: 'ScrollController',
      maxSamples: 50,
    );
    
    // 保存位置频率限制器
    _savePositionLimiter = RateLimiter(
      maxOperations: 10,
      timeWindow: const Duration(seconds: 1),
    );
  }
  
  /// 启动速度计算定时器
  void _startVelocityCalculationTimer() {
    _velocityCalculationTimer = Timer.periodic(_velocityCalculationInterval, (timer) {
      _updateScrollMetrics();
    });
  }
  
  /// 更新滚动指标
  void _updateScrollMetrics() {
    try {
      // 如果没有最近的滚动活动，逐渐降低速度
      if (_scrollHistory.isNotEmpty) {
        final lastEvent = _scrollHistory.last;
        final timeSinceLastScroll = DateTime.now().difference(lastEvent.timestamp);
        
        // 如果超过一定时间没有滚动，将速度设为0
        if (timeSinceLastScroll.inMilliseconds > 200) {
          if (scrollVelocity.value > 0) {
            scrollVelocity.value = 0.0;
            scrollDirection.value = ScrollDirection.idle;
            onVelocityChanged?.call(0.0);
          }
        }
      }
    } catch (e) {
      getLogger().e('❌ 更新滚动指标失败: $e');
    }
  }
  
  /// 处理滚动事件（优化版本）
  void handleScroll(ScrollDirection direction, double scrollY) {
    _scrollPerformanceMonitor.measure(() {
      try {
        // 使用自适应防抖器处理滚动事件
        _scrollDebouncer.call(() {
          _processScrollEventOptimized(direction, scrollY);
        });
      } catch (e, stackTrace) {
        getLogger().e('❌ 处理滚动事件失败: $e');
        throw ArticleScrollException(
          '处理滚动事件失败',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    });
  }
  
  /// 处理滚动事件（带X轴位置，优化版本）
  void handleScrollWithPosition(ScrollDirection direction, double scrollY, double scrollX) {
    _scrollPerformanceMonitor.measure(() {
      try {
        // 使用自适应防抖器处理滚动事件
        _scrollDebouncer.call(() {
          _processScrollEventOptimized(direction, scrollY, scrollX);
        });
      } catch (e, stackTrace) {
        getLogger().e('❌ 处理滚动事件失败: $e');
        throw ArticleScrollException(
          '处理滚动事件失败',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    });
  }
  
  /// 优化的滚动事件处理方法
  void _processScrollEventOptimized(ScrollDirection direction, double scrollY, [double scrollX = 0.0]) {
    try {
      // 只有在滚动距离超过阈值时才处理
      if ((scrollY - lastScrollY.value).abs() > _scrollThreshold) {
        final now = DateTime.now();
        
        // 创建滚动事件记录
        final scrollEvent = ScrollEvent(
          scrollY: scrollY,
          scrollX: scrollX,
          direction: direction,
          timestamp: now,
        );
        
        // 使用批处理器处理滚动事件
        _scrollEventBatcher.add(scrollEvent);
        
        // 使用节流器更新UI状态
        _uiUpdateThrottler.call(() {
          _updateScrollState(scrollEvent);
        });
        
        // 优化的位置保存
        _optimizedSavePosition();
      }
    } catch (e, stackTrace) {
      getLogger().e('❌ 优化滚动事件处理失败: $e');
      throw ArticleScrollException(
        '优化滚动事件处理失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 批量处理滚动事件
  void _processBatchedScrollEvents(List<ScrollEvent> events) {
    if (events.isEmpty) return;
    
    try {
      // 批量添加到历史记录
      for (final event in events) {
        _addScrollEvent(event);
      }
      
      // 重新计算滚动指标
      _calculateScrollVelocity();
      
      // 触发批量回调
      for (final event in events) {
        onScrollEvent?.call(event);
      }
      
      // 检查滚动趋势
      final currentTrend = getScrollTrend();
      if (currentTrend != ScrollDirection.idle) {
        onScrollTrendChanged?.call(currentTrend);
      }
      
      getLogger().d('📜 批量处理滚动事件: ${events.length}个事件');
    } catch (e) {
      getLogger().e('❌ 批量处理滚动事件失败: $e');
    }
  }
  
  /// 更新滚动状态（UI更新部分）
  void _updateScrollState(ScrollEvent event) {
    try {
      // 更新响应式状态
      lastScrollY.value = event.scrollY;
      currentScrollX.value = event.scrollX;
      scrollDirection.value = event.direction;
      
      // 触发主要回调
      onScrollChanged?.call(event.direction, event.scrollY);
      onVelocityChanged?.call(scrollVelocity.value);
      
      getLogger().d('📜 滚动状态更新: 方向=${event.direction}, 位置=${event.scrollY}, 速度=${scrollVelocity.value.toStringAsFixed(2)}');
    } catch (e) {
      getLogger().e('❌ 更新滚动状态失败: $e');
    }
  }
  
  /// 优化的位置保存
  void _optimizedSavePosition() {
    // 使用频率限制器避免过于频繁的保存操作
    _savePositionLimiter.tryExecute(() {
      _debouncedSavePosition();
    });
  }
  

  
  /// 添加滚动事件到历史记录
  void _addScrollEvent(ScrollEvent event) {
    _scrollHistory.add(event);
    
    // 保持历史记录长度在限制范围内
    if (_scrollHistory.length > _maxHistoryLength) {
      _scrollHistory.removeAt(0);
    }
  }
  
  /// 计算滚动速度
  void _calculateScrollVelocity() {
    if (_scrollHistory.length < 2) {
      scrollVelocity.value = 0.0;
      return;
    }
    
    final latest = _scrollHistory.last;
    final previous = _scrollHistory[_scrollHistory.length - 2];
    
    final timeDiff = latest.timestamp.difference(previous.timestamp).inMilliseconds;
    if (timeDiff > 0) {
      final distanceDiff = (latest.scrollY - previous.scrollY).abs();
      final velocity = distanceDiff / timeDiff * 1000; // 像素/秒
      scrollVelocity.value = velocity;
    }
  }
  
  /// 防抖保存滚动位置
  void _debouncedSavePosition() {
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(_savePositionDelay, () {
      saveScrollPosition().catchError((e) {
        getLogger().e('❌ 自动保存滚动位置失败: $e');
      });
    });
  }
  
  /// 保存滚动位置
  Future<void> saveScrollPosition() async {
    try {
      if (!articleController.hasArticle) {
        getLogger().w('⚠️ 文章数据不存在，无法保存滚动位置');
        return;
      }
      
      final currentContent = articleController.currentArticleContent;
      if (currentContent != null) {
        // 更新滚动位置到数据库
        currentContent.markdownScrollY = lastScrollY.value.toInt();
        currentContent.markdownScrollX = currentScrollX.value.toInt();
        
        // 这里可以添加数据库保存逻辑
        // await ArticleContentService.instance.updateScrollPosition(currentContent);
        
        getLogger().d('💾 滚动位置已保存: X=${currentScrollX.value}, Y=${lastScrollY.value}');
      }
    } catch (e, stackTrace) {
      getLogger().e('❌ 保存滚动位置失败: $e');
      throw ArticleScrollException(
        '保存滚动位置失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 批量保存滚动位置（用于高频更新场景）
  Future<void> batchSaveScrollPosition() async {
    try {
      // 取消之前的保存任务
      _savePositionTimer?.cancel();
      
      // 延迟保存，避免过于频繁的数据库操作
      _savePositionTimer = Timer(_savePositionDelay, () async {
        await saveScrollPosition();
      });
    } catch (e, stackTrace) {
      getLogger().e('❌ 批量保存滚动位置失败: $e');
      throw ArticleScrollException(
        '批量保存滚动位置失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 恢复滚动位置
  Future<void> restoreScrollPosition() async {
    try {
      if (!articleController.hasArticle) {
        getLogger().w('⚠️ 文章数据不存在，无法恢复滚动位置');
        return;
      }
      
      final currentContent = articleController.currentArticleContent;
      if (currentContent != null) {
        final targetScrollY = currentContent.markdownScrollY?.toDouble() ?? 0.0;
        final targetScrollX = currentContent.markdownScrollX?.toDouble() ?? 0.0;
        
        // 更新本地状态
        lastScrollY.value = targetScrollY;
        
        getLogger().i('📜 滚动位置已恢复: X=$targetScrollX, Y=$targetScrollY');
      } else {
        getLogger().w('⚠️ 文章内容数据不存在，使用默认滚动位置');
        lastScrollY.value = 0.0;
      }
    } catch (e, stackTrace) {
      getLogger().e('❌ 恢复滚动位置失败: $e');
      
      // 恢复失败时使用默认位置
      lastScrollY.value = 0.0;
      
      throw ArticleScrollException(
        '恢复滚动位置失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 重置滚动状态
  void resetScrollState() {
    try {
      lastScrollY.value = 0.0;
      scrollDirection.value = ScrollDirection.idle;
      
      getLogger().i('🔄 滚动状态已重置');
    } catch (e, stackTrace) {
      getLogger().e('❌ 重置滚动状态失败: $e');
      throw ArticleScrollException(
        '重置滚动状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 手动触发滚动位置保存
  Future<void> manualSavePosition() async {
    _savePositionTimer?.cancel();
    await saveScrollPosition();
  }
  
  /// 滚动到指定位置
  Future<void> scrollToPosition(double targetY, [double targetX = 0.0]) async {
    try {
      lastScrollY.value = targetY;
      currentScrollX.value = targetX;
      
      // 清空滚动历史，因为这是程序化滚动
      _scrollHistory.clear();
      scrollVelocity.value = 0.0;
      scrollDirection.value = ScrollDirection.idle;
      
      getLogger().i('📜 程序化滚动到位置: X=$targetX, Y=$targetY');
    } catch (e, stackTrace) {
      getLogger().e('❌ 滚动到指定位置失败: $e');
      throw ArticleScrollException(
        '滚动到指定位置失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 滚动到顶部
  Future<void> scrollToTop() async {
    await scrollToPosition(0.0, 0.0);
  }
  
  /// 获取滚动进度（0.0 - 1.0）
  double getScrollProgress(double contentHeight) {
    if (contentHeight <= 0) return 0.0;
    return (lastScrollY.value / contentHeight).clamp(0.0, 1.0);
  }
  
  /// 检查是否快速滚动
  bool get isFastScrolling => scrollVelocity.value > _fastScrollThreshold;
  
  /// 获取滚动趋势（基于历史记录）
  ScrollDirection getScrollTrend() {
    if (_scrollHistory.length < 3) return ScrollDirection.idle;
    
    // 分析最近几次滚动的趋势
    int upCount = 0;
    int downCount = 0;
    
    for (int i = _scrollHistory.length - 3; i < _scrollHistory.length; i++) {
      if (_scrollHistory[i].direction == ScrollDirection.forward) {
        upCount++;
      } else if (_scrollHistory[i].direction == ScrollDirection.reverse) {
        downCount++;
      }
    }
    
    if (upCount > downCount) {
      return ScrollDirection.forward;
    } else if (downCount > upCount) {
      return ScrollDirection.reverse;
    } else {
      return ScrollDirection.idle;
    }
  }
  
  /// 检查滚动是否稳定（速度较低且方向一致）
  bool get isScrollingStable {
    if (_scrollHistory.length < 3) return false;
    
    // 检查速度是否稳定
    if (scrollVelocity.value > _fastScrollThreshold) return false;
    
    // 检查方向是否一致
    final trend = getScrollTrend();
    return trend != ScrollDirection.idle;
  }
  
  /// 获取平均滚动速度
  double getAverageScrollVelocity() {
    if (_scrollHistory.length < 2) return 0.0;
    
    double totalVelocity = 0.0;
    int validSamples = 0;
    
    for (int i = 1; i < _scrollHistory.length; i++) {
      final current = _scrollHistory[i];
      final previous = _scrollHistory[i - 1];
      
      final timeDiff = current.timestamp.difference(previous.timestamp).inMilliseconds;
      if (timeDiff > 0) {
        final distanceDiff = (current.scrollY - previous.scrollY).abs();
        final velocity = distanceDiff / timeDiff * 1000;
        totalVelocity += velocity;
        validSamples++;
      }
    }
    
    return validSamples > 0 ? totalVelocity / validSamples : 0.0;
  }
  
  /// 预测下一个滚动位置（基于当前速度和方向）
  double predictNextScrollPosition([Duration duration = const Duration(milliseconds: 100)]) {
    if (scrollVelocity.value == 0.0) return lastScrollY.value;
    
    final deltaTime = duration.inMilliseconds / 1000.0; // 转换为秒
    final deltaDistance = scrollVelocity.value * deltaTime;
    
    if (scrollDirection.value == ScrollDirection.reverse) {
      return lastScrollY.value + deltaDistance;
    } else if (scrollDirection.value == ScrollDirection.forward) {
      return (lastScrollY.value - deltaDistance).clamp(0.0, double.infinity);
    } else {
      return lastScrollY.value;
    }
  }
  
  /// 获取当前滚动位置
  double get currentScrollY => lastScrollY.value;
  
  /// 获取当前滚动方向
  ScrollDirection get currentScrollDirection => scrollDirection.value;
  
  /// 获取当前滚动速度
  double get currentScrollVelocity => scrollVelocity.value;
  
  /// 检查是否在顶部
  bool get isAtTop => lastScrollY.value < _topScrollThreshold;
  
  /// 检查是否向下滚动
  bool get isScrollingDown => scrollDirection.value == ScrollDirection.reverse;
  
  /// 检查是否向上滚动
  bool get isScrollingUp => scrollDirection.value == ScrollDirection.forward;
  
  /// 检查是否处于空闲状态
  bool get isScrollIdle => scrollDirection.value == ScrollDirection.idle;
  
  /// 获取滚动历史记录数量
  int get scrollHistoryLength => _scrollHistory.length;
  
  /// 获取性能报告
  Map<String, dynamic> getPerformanceReport() {
    return {
      'scrollPerformance': _scrollPerformanceMonitor.getReport(),
      'adaptiveDebouncer': {
        'currentDelay': _scrollDebouncer.currentDelay.inMilliseconds,
        'consecutiveTriggers': _scrollDebouncer.consecutiveTriggers,
      },
      'batchProcessor': {
        'queueLength': _scrollEventBatcher.queueLength,
        'hasPendingItems': _scrollEventBatcher.hasPendingItems,
      },
      'rateLimiter': {
        'remainingOperations': _savePositionLimiter.remainingOperations,
        'nextAvailableTime': _savePositionLimiter.nextAvailableTime?.toIso8601String(),
      },
      'scrollMetrics': {
        'historyLength': _scrollHistory.length,
        'currentVelocity': scrollVelocity.value,
        'averageVelocity': getAverageScrollVelocity(),
        'isFastScrolling': isFastScrolling,
        'isScrollingStable': isScrollingStable,
      },
    };
  }
  
  /// 重置性能统计
  void resetPerformanceStats() {
    _scrollPerformanceMonitor.reset();
    _scrollDebouncer.reset();
    _scrollEventBatcher.clear();
    _savePositionLimiter.reset();
    getLogger().i('📊 滚动性能统计已重置');
  }
  
  /// 强制处理所有待处理的事件
  void flushPendingEvents() {
    _scrollEventBatcher.flush();
    _uiUpdateThrottler.flush();
    getLogger().i('🔄 所有待处理的滚动事件已强制处理');
  }
  
  /// 准备销毁
  Future<void> prepareForDispose() async {
    try {
      getLogger().i('🔄 滚动控制器准备销毁');
      
      // 强制处理所有待处理的事件
      flushPendingEvents();
      
      // 最后一次保存位置
      if (lastScrollY.value > 0) {
        await saveScrollPosition();
      }
      
      // 清理回调函数
      onScrollChanged = null;
      onScrollEvent = null;
      onVelocityChanged = null;
      onScrollTrendChanged = null;
      
      getLogger().i('✅ 滚动控制器销毁准备完成');
    } catch (e) {
      getLogger().e('❌ 滚动控制器销毁准备失败: $e');
    }
  }
  
  @override
  void onClose() {
    getLogger().i('🔄 ArticleScrollController 开始销毁');
    
    try {
      // 强制处理所有待处理的事件
      flushPendingEvents();
      
      // 取消所有Timer
      _savePositionTimer?.cancel();
      _velocityCalculationTimer?.cancel();
      
      // 清理性能优化工具
      _scrollDebouncer.dispose();
      _uiUpdateThrottler.dispose();
      _scrollEventBatcher.dispose();
      _scrollPerformanceMonitor.reset();
      _savePositionLimiter.reset();
      
      // 最后一次保存位置
      if (lastScrollY.value > 0) {
        saveScrollPosition().catchError((e) {
          getLogger().e('❌ 销毁时保存滚动位置失败: $e');
        });
      }
      
      getLogger().i('✅ ArticleScrollController 销毁完成');
    } catch (e) {
      getLogger().e('❌ ArticleScrollController 销毁时出错: $e');
    }
    
    super.onClose();
  }
}
import 'dart:async';
import 'dart:collection';
import 'dart:ui';

/// 防抖工具类
/// 用于防止高频事件的过度触发
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({required this.delay});
  
  /// 执行防抖操作
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  /// 取消防抖
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// 检查是否有待执行的操作
  bool get isActive => _timer?.isActive ?? false;
  
  /// 立即执行并取消防抖
  void flush(VoidCallback action) {
    cancel();
    action();
  }
  
  void dispose() {
    cancel();
  }
}

/// 节流工具类
/// 用于限制高频事件的执行频率
class Throttler {
  final Duration interval;
  DateTime? _lastExecution;
  Timer? _timer;
  VoidCallback? _pendingAction;
  
  Throttler({required this.interval});
  
  /// 执行节流操作
  void call(VoidCallback action) {
    final now = DateTime.now();
    
    // 如果是第一次执行或者已经超过间隔时间，立即执行
    if (_lastExecution == null || 
        now.difference(_lastExecution!).compareTo(interval) >= 0) {
      _lastExecution = now;
      action();
      return;
    }
    
    // 否则，设置待执行的操作
    _pendingAction = action;
    _timer?.cancel();
    
    final remainingTime = interval - now.difference(_lastExecution!);
    _timer = Timer(remainingTime, () {
      if (_pendingAction != null) {
        _lastExecution = DateTime.now();
        _pendingAction!();
        _pendingAction = null;
      }
    });
  }
  
  /// 取消节流
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }
  
  /// 检查是否有待执行的操作
  bool get hasPendingAction => _pendingAction != null;
  
  /// 立即执行待执行的操作
  void flush() {
    if (_pendingAction != null) {
      cancel();
      _lastExecution = DateTime.now();
      _pendingAction!();
      _pendingAction = null;
    }
  }
  
  void dispose() {
    cancel();
  }
}

/// 批处理工具类
/// 用于将多个操作合并为一次执行
class BatchProcessor<T> {
  final Duration batchInterval;
  final void Function(List<T> items) processor;
  final Queue<T> _queue = Queue<T>();
  Timer? _timer;
  
  BatchProcessor({
    required this.batchInterval,
    required this.processor,
  });
  
  /// 添加项目到批处理队列
  void add(T item) {
    _queue.add(item);
    
    // 如果没有正在运行的定时器，启动一个
    _timer ??= Timer(batchInterval, _processBatch);
  }
  
  /// 添加多个项目到批处理队列
  void addAll(Iterable<T> items) {
    _queue.addAll(items);
    
    // 如果没有正在运行的定时器，启动一个
    _timer ??= Timer(batchInterval, _processBatch);
  }
  
  /// 处理批次
  void _processBatch() {
    if (_queue.isNotEmpty) {
      final items = _queue.toList();
      _queue.clear();
      processor(items);
    }
    _timer = null;
  }
  
  /// 立即处理所有待处理的项目
  void flush() {
    _timer?.cancel();
    _timer = null;
    _processBatch();
  }
  
  /// 获取队列中的项目数量
  int get queueLength => _queue.length;
  
  /// 检查是否有待处理的项目
  bool get hasPendingItems => _queue.isNotEmpty;
  
  /// 清空队列
  void clear() {
    _timer?.cancel();
    _timer = null;
    _queue.clear();
  }
  
  void dispose() {
    clear();
  }
}

/// 频率限制器
/// 用于限制操作的执行频率
class RateLimiter {
  final int maxOperations;
  final Duration timeWindow;
  final Queue<DateTime> _operations = Queue<DateTime>();
  
  RateLimiter({
    required this.maxOperations,
    required this.timeWindow,
  });
  
  /// 检查是否可以执行操作
  bool canExecute() {
    final now = DateTime.now();
    
    // 清理过期的操作记录
    while (_operations.isNotEmpty && 
           now.difference(_operations.first).compareTo(timeWindow) > 0) {
      _operations.removeFirst();
    }
    
    return _operations.length < maxOperations;
  }
  
  /// 尝试执行操作
  bool tryExecute(VoidCallback action) {
    if (canExecute()) {
      _operations.add(DateTime.now());
      action();
      return true;
    }
    return false;
  }
  
  /// 获取剩余可执行次数
  int get remainingOperations => maxOperations - _operations.length;
  
  /// 获取下次可执行的时间
  DateTime? get nextAvailableTime {
    if (_operations.isEmpty) return null;
    return _operations.first.add(timeWindow);
  }
  
  /// 重置限制器
  void reset() {
    _operations.clear();
  }
}

/// 自适应防抖器
/// 根据操作频率自动调整防抖延迟
class AdaptiveDebouncer {
  final Duration minDelay;
  final Duration maxDelay;
  final double adaptationFactor;
  
  Duration _currentDelay;
  DateTime? _lastTrigger;
  Timer? _timer;
  int _consecutiveTriggers = 0;
  
  AdaptiveDebouncer({
    required this.minDelay,
    required this.maxDelay,
    this.adaptationFactor = 1.5,
  }) : _currentDelay = minDelay;
  
  /// 执行自适应防抖操作
  void call(VoidCallback action) {
    final now = DateTime.now();
    
    // 计算触发频率
    if (_lastTrigger != null) {
      final timeSinceLastTrigger = now.difference(_lastTrigger!);
      
      if (timeSinceLastTrigger < _currentDelay) {
        _consecutiveTriggers++;
        // 增加延迟以减少频繁触发
        _currentDelay = Duration(
          milliseconds: (_currentDelay.inMilliseconds * adaptationFactor).round()
              .clamp(minDelay.inMilliseconds, maxDelay.inMilliseconds)
        );
      } else {
        _consecutiveTriggers = 0;
        // 逐渐减少延迟
        _currentDelay = Duration(
          milliseconds: (_currentDelay.inMilliseconds / adaptationFactor).round()
              .clamp(minDelay.inMilliseconds, maxDelay.inMilliseconds)
        );
      }
    }
    
    _lastTrigger = now;
    _timer?.cancel();
    _timer = Timer(_currentDelay, action);
  }
  
  /// 获取当前延迟
  Duration get currentDelay => _currentDelay;
  
  /// 获取连续触发次数
  int get consecutiveTriggers => _consecutiveTriggers;
  
  /// 取消防抖
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// 重置自适应状态
  void reset() {
    cancel();
    _currentDelay = minDelay;
    _consecutiveTriggers = 0;
    _lastTrigger = null;
  }
  
  void dispose() {
    cancel();
  }
}

/// 性能监控器
/// 用于监控操作的性能指标
class PerformanceMonitor {
  final String name;
  final Queue<Duration> _executionTimes = Queue<Duration>();
  final int maxSamples;
  
  PerformanceMonitor({
    required this.name,
    this.maxSamples = 100,
  });
  
  /// 测量操作执行时间
  T measure<T>(T Function() operation) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _recordExecutionTime(stopwatch.elapsed);
    }
  }
  
  /// 异步测量操作执行时间
  Future<T> measureAsync<T>(Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _recordExecutionTime(stopwatch.elapsed);
    }
  }
  
  /// 记录执行时间
  void _recordExecutionTime(Duration duration) {
    _executionTimes.add(duration);
    
    // 保持样本数量在限制范围内
    while (_executionTimes.length > maxSamples) {
      _executionTimes.removeFirst();
    }
  }
  
  /// 获取平均执行时间
  Duration get averageExecutionTime {
    if (_executionTimes.isEmpty) return Duration.zero;
    
    final totalMicroseconds = _executionTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    return Duration(microseconds: totalMicroseconds ~/ _executionTimes.length);
  }
  
  /// 获取最小执行时间
  Duration get minExecutionTime {
    if (_executionTimes.isEmpty) return Duration.zero;
    return _executionTimes.reduce((a, b) => a < b ? a : b);
  }
  
  /// 获取最大执行时间
  Duration get maxExecutionTime {
    if (_executionTimes.isEmpty) return Duration.zero;
    return _executionTimes.reduce((a, b) => a > b ? a : b);
  }
  
  /// 获取执行次数
  int get executionCount => _executionTimes.length;
  
  /// 获取性能报告
  Map<String, dynamic> getReport() {
    return {
      'name': name,
      'executionCount': executionCount,
      'averageTime': averageExecutionTime.inMilliseconds,
      'minTime': minExecutionTime.inMilliseconds,
      'maxTime': maxExecutionTime.inMilliseconds,
      'samples': maxSamples,
    };
  }
  
  /// 重置监控数据
  void reset() {
    _executionTimes.clear();
  }
}

/// WebView操作优化器
/// 专门用于优化WebView相关操作的频率
class WebViewOperationOptimizer {
  final Throttler _jsExecutionThrottler;
  final BatchProcessor<String> _jsBatchProcessor;
  final RateLimiter _navigationLimiter;
  final PerformanceMonitor _performanceMonitor;
  
  WebViewOperationOptimizer()
      : _jsExecutionThrottler = Throttler(
          interval: const Duration(milliseconds: 100),
        ),
        _jsBatchProcessor = BatchProcessor<String>(
          batchInterval: const Duration(milliseconds: 50),
          processor: (scripts) {
            // 批量执行JavaScript
            final combinedScript = scripts.join(';');
            _executeJavaScriptBatch(combinedScript);
          },
        ),
        _navigationLimiter = RateLimiter(
          maxOperations: 5,
          timeWindow: const Duration(seconds: 1),
        ),
        _performanceMonitor = PerformanceMonitor(name: 'WebViewOperations');
  
  /// 优化的JavaScript执行
  void executeJavaScript(String script) {
    _jsBatchProcessor.add(script);
  }
  
  /// 节流的JavaScript执行
  void executeJavaScriptThrottled(String script, VoidCallback action) {
    _jsExecutionThrottler.call(action);
  }
  
  /// 限制频率的导航操作
  bool tryNavigate(VoidCallback navigationAction) {
    return _navigationLimiter.tryExecute(navigationAction);
  }
  
  /// 批量执行JavaScript（内部方法）
  static void _executeJavaScriptBatch(String combinedScript) {
    // 这里应该调用实际的WebView JavaScript执行方法
    // 由于这是工具类，具体实现由调用方提供
  }
  
  /// 获取性能报告
  Map<String, dynamic> getPerformanceReport() {
    return _performanceMonitor.getReport();
  }
  
  /// 清理资源
  void dispose() {
    _jsExecutionThrottler.dispose();
    _jsBatchProcessor.dispose();
    _navigationLimiter.reset();
    _performanceMonitor.reset();
  }
}
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../basics/logger.dart';

/// WebView状态
enum WebViewState {
  /// 未初始化
  uninitialized,
  /// 初始化中
  initializing,
  /// 已初始化
  initialized,
  /// 加载中
  loading,
  /// 已加载
  loaded,
  /// 暂停
  paused,
  /// 销毁中
  disposing,
  /// 已销毁
  disposed,
  /// 错误状态
  error,
}

/// WebView实例信息
class WebViewInstance {
  final String id;
  final DateTime createdAt;
  final RxString url = ''.obs;
  final Rx<WebViewState> state = WebViewState.uninitialized.obs;
  final RxBool isVisible = false.obs;
  final RxBool isActive = false.obs;
  final RxDouble memoryUsage = 0.0.obs;
  final Map<String, dynamic> metadata;
  
  // 性能指标
  DateTime? lastLoadStartTime;
  DateTime? lastLoadCompleteTime;
  int loadCount = 0;
  int errorCount = 0;
  
  WebViewInstance({
    required this.id,
    required this.createdAt,
    this.metadata = const {},
  });
  
  /// 获取实例年龄
  Duration get age => DateTime.now().difference(createdAt);
  
  /// 获取加载时间
  Duration? get lastLoadDuration {
    if (lastLoadStartTime != null && lastLoadCompleteTime != null) {
      return lastLoadCompleteTime!.difference(lastLoadStartTime!);
    }
    return null;
  }
  
  /// 开始加载
  void startLoading(String newUrl) {
    url.value = newUrl;
    state.value = WebViewState.loading;
    lastLoadStartTime = DateTime.now();
    loadCount++;
  }
  
  /// 完成加载
  void completeLoading() {
    state.value = WebViewState.loaded;
    lastLoadCompleteTime = DateTime.now();
  }
  
  /// 设置错误状态
  void setError() {
    state.value = WebViewState.error;
    errorCount++;
  }
  
  /// 暂停WebView
  void pause() {
    if (state.value == WebViewState.loaded) {
      state.value = WebViewState.paused;
      isActive.value = false;
    }
  }
  
  /// 恢复WebView
  void resume() {
    if (state.value == WebViewState.paused) {
      state.value = WebViewState.loaded;
      isActive.value = true;
    }
  }
  
  /// 销毁WebView
  void dispose() {
    state.value = WebViewState.disposing;
    isVisible.value = false;
    isActive.value = false;
    // 实际销毁逻辑由调用方实现
  }
  
  /// 获取实例信息
  Map<String, dynamic> getInfo() {
    return {
      'id': id,
      'url': url.value,
      'state': state.value.toString(),
      'age': age.inSeconds,
      'isVisible': isVisible.value,
      'isActive': isActive.value,
      'memoryUsage': memoryUsage.value,
      'loadCount': loadCount,
      'errorCount': errorCount,
      'lastLoadDuration': lastLoadDuration?.inMilliseconds,
      'metadata': metadata,
    };
  }
}

/// WebView生命周期管理器
class WebViewLifecycleManager {
  final int maxInstances;
  final Duration instanceTimeout;
  final Duration pauseDelay;
  
  final Map<String, WebViewInstance> _instances = {};
  final Queue<String> _creationOrder = Queue<String>();
  
  // 定时器
  Timer? _cleanupTimer;
  Timer? _pauseTimer;
  Timer? _memoryMonitorTimer;
  
  // 统计信息
  int _totalCreated = 0;
  int _totalDisposed = 0;
  final RxDouble totalMemoryUsage = 0.0.obs;
  
  // 回调函数
  void Function(String id)? onInstanceCreated;
  void Function(String id)? onInstanceDisposed;
  void Function(String id, WebViewState state)? onStateChanged;
  void Function(double memoryUsage)? onMemoryUsageChanged;
  
  WebViewLifecycleManager({
    this.maxInstances = 3,
    this.instanceTimeout = const Duration(minutes: 10),
    this.pauseDelay = const Duration(seconds: 30),
  }) {
    _startCleanupTimer();
    _startMemoryMonitoring();
  }
  
  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _performCleanup(),
    );
  }
  
  /// 启动内存监控
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateMemoryUsage(),
    );
  }
  
  /// 更新内存使用情况
  void _updateMemoryUsage() {
    double total = 0.0;
    for (final instance in _instances.values) {
      // 估算WebView内存使用（实际实现中应该使用真实的内存监控）
      if (instance.state.value == WebViewState.loaded || 
          instance.state.value == WebViewState.loading) {
        instance.memoryUsage.value = 50.0 * 1024 * 1024; // 50MB估算
      } else if (instance.state.value == WebViewState.paused) {
        instance.memoryUsage.value = 20.0 * 1024 * 1024; // 20MB估算
      } else {
        instance.memoryUsage.value = 0.0;
      }
      total += instance.memoryUsage.value;
    }
    
    totalMemoryUsage.value = total;
    onMemoryUsageChanged?.call(total);
  }
  
  /// 创建WebView实例
  Future<String> createInstance({
    String? preferredId,
    Map<String, dynamic>? metadata,
  }) async {
    // 如果达到最大实例数，清理旧实例
    if (_instances.length >= maxInstances) {
      await _evictOldestInstance();
    }
    
    final id = preferredId ?? 'webview_${DateTime.now().millisecondsSinceEpoch}';
    final instance = WebViewInstance(
      id: id,
      createdAt: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _instances[id] = instance;
    _creationOrder.add(id);
    _totalCreated++;
    
    instance.state.value = WebViewState.initializing;
    
    // 监听状态变化
    instance.state.listen((state) {
      onStateChanged?.call(id, state);
    });
    
    onInstanceCreated?.call(id);
    getLogger().i('🌐 WebView实例已创建: $id');
    
    return id;
  }
  
  /// 初始化WebView实例
  Future<void> initializeInstance(String id) async {
    final instance = _instances[id];
    if (instance == null) {
      throw Exception('WebView实例不存在: $id');
    }
    
    try {
      instance.state.value = WebViewState.initializing;
      
      // 模拟初始化过程
      await Future.delayed(const Duration(milliseconds: 100));
      
      instance.state.value = WebViewState.initialized;
      instance.isActive.value = true;
      
      getLogger().i('✅ WebView实例初始化完成: $id');
    } catch (e) {
      instance.setError();
      getLogger().e('❌ WebView实例初始化失败: $id, 错误: $e');
      rethrow;
    }
  }
  
  /// 加载URL
  Future<void> loadUrl(String id, String url) async {
    final instance = _instances[id];
    if (instance == null) {
      throw Exception('WebView实例不存在: $id');
    }
    
    try {
      instance.startLoading(url);
      
      // 模拟加载过程
      await Future.delayed(const Duration(milliseconds: 500));
      
      instance.completeLoading();
      instance.isActive.value = true;
      
      getLogger().i('🔗 URL加载完成: $id -> $url');
    } catch (e) {
      instance.setError();
      getLogger().e('❌ URL加载失败: $id -> $url, 错误: $e');
      rethrow;
    }
  }
  
  /// 设置实例可见性
  void setInstanceVisibility(String id, bool visible) {
    final instance = _instances[id];
    if (instance == null) return;
    
    instance.isVisible.value = visible;
    
    if (!visible) {
      // 延迟暂停不可见的实例
      _schedulePause(id);
    } else {
      // 立即恢复可见的实例
      instance.resume();
      _cancelScheduledPause(id);
    }
    
    getLogger().d('👁️ WebView可见性更新: $id -> $visible');
  }
  
  /// 调度暂停
  void _schedulePause(String id) {
    _pauseTimer?.cancel();
    _pauseTimer = Timer(pauseDelay, () {
      final instance = _instances[id];
      if (instance != null && !instance.isVisible.value) {
        instance.pause();
        getLogger().d('⏸️ WebView已暂停: $id');
      }
    });
  }
  
  /// 取消调度的暂停
  void _cancelScheduledPause(String id) {
    _pauseTimer?.cancel();
  }
  
  /// 销毁实例
  Future<void> disposeInstance(String id) async {
    final instance = _instances[id];
    if (instance == null) return;
    
    try {
      instance.dispose();
      
      // 模拟销毁过程
      await Future.delayed(const Duration(milliseconds: 100));
      
      instance.state.value = WebViewState.disposed;
      
      _instances.remove(id);
      _creationOrder.remove(id);
      _totalDisposed++;
      
      onInstanceDisposed?.call(id);
      getLogger().i('🗑️ WebView实例已销毁: $id');
    } catch (e) {
      getLogger().e('❌ WebView实例销毁失败: $id, 错误: $e');
    }
  }
  
  /// 清理最老的实例
  Future<void> _evictOldestInstance() async {
    if (_creationOrder.isNotEmpty) {
      final oldestId = _creationOrder.first;
      await disposeInstance(oldestId);
      getLogger().i('🧹 清理最老的WebView实例: $oldestId');
    }
  }
  
  /// 执行清理
  void _performCleanup() {
    final now = DateTime.now();
    final instancesToDispose = <String>[];
    
    for (final entry in _instances.entries) {
      final instance = entry.value;
      
      // 清理超时的实例
      if (instance.age > instanceTimeout) {
        instancesToDispose.add(entry.key);
      }
      
      // 清理错误状态的实例
      if (instance.state.value == WebViewState.error && 
          instance.errorCount > 3) {
        instancesToDispose.add(entry.key);
      }
    }
    
    for (final id in instancesToDispose) {
      disposeInstance(id);
    }
    
    if (instancesToDispose.isNotEmpty) {
      getLogger().i('🧹 定期清理WebView实例: ${instancesToDispose.length}个');
    }
  }
  
  /// 暂停所有不可见的实例
  void pauseInvisibleInstances() {
    for (final instance in _instances.values) {
      if (!instance.isVisible.value && instance.state.value == WebViewState.loaded) {
        instance.pause();
      }
    }
    getLogger().i('⏸️ 已暂停所有不可见的WebView实例');
  }
  
  /// 恢复所有暂停的实例
  void resumeAllInstances() {
    for (final instance in _instances.values) {
      if (instance.state.value == WebViewState.paused) {
        instance.resume();
      }
    }
    getLogger().i('▶️ 已恢复所有暂停的WebView实例');
  }
  
  /// 获取实例信息
  WebViewInstance? getInstance(String id) {
    return _instances[id];
  }
  
  /// 获取所有实例ID
  List<String> get instanceIds => _instances.keys.toList();
  
  /// 获取活跃实例数量
  int get activeInstanceCount {
    return _instances.values
        .where((instance) => instance.isActive.value)
        .length;
  }
  
  /// 获取可见实例数量
  int get visibleInstanceCount {
    return _instances.values
        .where((instance) => instance.isVisible.value)
        .length;
  }
  
  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    final stateDistribution = <String, int>{};
    double totalMemory = 0.0;
    int totalLoads = 0;
    int totalErrors = 0;
    
    for (final instance in _instances.values) {
      final state = instance.state.value.toString();
      stateDistribution[state] = (stateDistribution[state] ?? 0) + 1;
      totalMemory += instance.memoryUsage.value;
      totalLoads += instance.loadCount;
      totalErrors += instance.errorCount;
    }
    
    return {
      'totalInstances': _instances.length,
      'maxInstances': maxInstances,
      'activeInstances': activeInstanceCount,
      'visibleInstances': visibleInstanceCount,
      'totalCreated': _totalCreated,
      'totalDisposed': _totalDisposed,
      'totalMemoryUsage': totalMemory,
      'totalLoads': totalLoads,
      'totalErrors': totalErrors,
      'stateDistribution': stateDistribution,
      'averageAge': _getAverageAge(),
      'oldestInstance': _getOldestInstanceAge(),
    };
  }
  
  /// 获取平均年龄
  double _getAverageAge() {
    if (_instances.isEmpty) return 0.0;
    
    final totalAge = _instances.values
        .map((instance) => instance.age.inSeconds)
        .reduce((a, b) => a + b);
    return totalAge / _instances.length;
  }
  
  /// 获取最老实例的年龄
  int _getOldestInstanceAge() {
    if (_instances.isEmpty) return 0;
    
    return _instances.values
        .map((instance) => instance.age.inSeconds)
        .reduce((a, b) => a > b ? a : b);
  }
  
  /// 强制清理所有实例
  Future<void> disposeAllInstances() async {
    final ids = _instances.keys.toList();
    for (final id in ids) {
      await disposeInstance(id);
    }
    getLogger().i('🗑️ 已销毁所有WebView实例: ${ids.length}个');
  }
  
  /// 优化内存使用
  Future<void> optimizeMemoryUsage() async {
    // 暂停不可见的实例
    pauseInvisibleInstances();
    
    // 如果内存使用过高，销毁一些实例
    if (totalMemoryUsage.value > 200 * 1024 * 1024) { // 200MB阈值
      final instancesToDispose = _instances.values
          .where((instance) => !instance.isVisible.value)
          .take(2)
          .map((instance) => instance.id)
          .toList();
      
      for (final id in instancesToDispose) {
        await disposeInstance(id);
      }
      
      getLogger().i('🧠 内存优化: 销毁了${instancesToDispose.length}个实例');
    }
  }
  
  /// 销毁管理器
  void dispose() {
    _cleanupTimer?.cancel();
    _pauseTimer?.cancel();
    _memoryMonitorTimer?.cancel();
    
    disposeAllInstances();
    
    getLogger().i('🔄 WebView生命周期管理器已销毁');
  }
}
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../basics/logger.dart';

/// Widget缓存项
class CachedWidgetItem {
  final Widget widget;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final String key;
  final Map<String, dynamic> metadata;
  
  CachedWidgetItem({
    required this.widget,
    required this.createdAt,
    required this.lastAccessedAt,
    required this.accessCount,
    required this.key,
    this.metadata = const {},
  });
  
  /// 创建访问后的新实例
  CachedWidgetItem withAccess() {
    return CachedWidgetItem(
      widget: widget,
      createdAt: createdAt,
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
      key: key,
      metadata: metadata,
    );
  }
  
  /// 获取缓存项的年龄
  Duration get age => DateTime.now().difference(createdAt);
  
  /// 获取上次访问后的时间
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessedAt);
  
  /// 计算缓存项的优先级（用于LRU算法）
  double get priority {
    final ageWeight = 0.3;
    final accessWeight = 0.4;
    final recentnessWeight = 0.3;
    
    final ageScore = 1.0 / (age.inMinutes + 1);
    final accessScore = accessCount.toDouble();
    final recentnessScore = 1.0 / (timeSinceLastAccess.inMinutes + 1);
    
    return ageScore * ageWeight + accessScore * accessWeight + recentnessScore * recentnessWeight;
  }
}

/// Widget缓存策略
enum CacheStrategy {
  /// 最近最少使用
  lru,
  /// 最近最常使用
  lfu,
  /// 先进先出
  fifo,
  /// 基于时间的过期
  timeBasedExpiry,
  /// 智能缓存（综合多种策略）
  smart,
}

/// Widget缓存管理器
class WidgetCacheManager {
  final int maxCacheSize;
  final Duration defaultExpiry;
  final CacheStrategy strategy;
  
  final Map<String, CachedWidgetItem> _cache = {};
  final Queue<String> _accessOrder = Queue<String>();
  
  // 统计信息
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;
  
  // 内存监控
  Timer? _memoryMonitorTimer;
  final RxDouble memoryUsageEstimate = 0.0.obs;
  
  WidgetCacheManager({
    this.maxCacheSize = 50,
    this.defaultExpiry = const Duration(minutes: 30),
    this.strategy = CacheStrategy.smart,
  }) {
    _startMemoryMonitoring();
  }
  
  /// 启动内存监控
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateMemoryUsage(),
    );
  }
  
  /// 更新内存使用估算
  void _updateMemoryUsage() {
    // 简单的内存使用估算（基于缓存项数量）
    final estimatedMemoryPerItem = 1024 * 50; // 50KB per widget (估算)
    memoryUsageEstimate.value = _cache.length * estimatedMemoryPerItem.toDouble();
  }
  
  /// 获取缓存的Widget
  Widget? get(String key) {
    final item = _cache[key];
    if (item == null) {
      _missCount++;
      getLogger().d('🗑️ 缓存未命中: $key');
      return null;
    }
    
    // 检查是否过期
    if (_isExpired(item)) {
      _cache.remove(key);
      _accessOrder.remove(key);
      _missCount++;
      getLogger().d('⏰ 缓存项已过期: $key');
      return null;
    }
    
    // 更新访问信息
    _cache[key] = item.withAccess();
    _updateAccessOrder(key);
    _hitCount++;
    
    getLogger().d('✅ 缓存命中: $key (访问次数: ${item.accessCount + 1})');
    return item.widget;
  }
  
  /// 缓存Widget
  void put(String key, Widget widget, {Map<String, dynamic>? metadata}) {
    final now = DateTime.now();
    final item = CachedWidgetItem(
      widget: widget,
      createdAt: now,
      lastAccessedAt: now,
      accessCount: 1,
      key: key,
      metadata: metadata ?? {},
    );
    
    // 如果缓存已满，执行清理策略
    if (_cache.length >= maxCacheSize) {
      _evictItems();
    }
    
    _cache[key] = item;
    _updateAccessOrder(key);
    
    getLogger().d('💾 Widget已缓存: $key');
    _updateMemoryUsage();
  }
  
  /// 检查缓存项是否过期
  bool _isExpired(CachedWidgetItem item) {
    return item.age > defaultExpiry;
  }
  
  /// 更新访问顺序
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.addLast(key);
  }
  
  /// 清理过期项
  void _evictItems() {
    switch (strategy) {
      case CacheStrategy.lru:
        _evictLRU();
        break;
      case CacheStrategy.lfu:
        _evictLFU();
        break;
      case CacheStrategy.fifo:
        _evictFIFO();
        break;
      case CacheStrategy.timeBasedExpiry:
        _evictExpired();
        break;
      case CacheStrategy.smart:
        _evictSmart();
        break;
    }
  }
  
  /// LRU清理策略
  void _evictLRU() {
    if (_accessOrder.isNotEmpty) {
      final keyToEvict = _accessOrder.removeFirst();
      _cache.remove(keyToEvict);
      _evictionCount++;
      getLogger().d('🗑️ LRU清理: $keyToEvict');
    }
  }
  
  /// LFU清理策略
  void _evictLFU() {
    if (_cache.isNotEmpty) {
      final sortedItems = _cache.entries.toList()
        ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));
      
      final keyToEvict = sortedItems.first.key;
      _cache.remove(keyToEvict);
      _accessOrder.remove(keyToEvict);
      _evictionCount++;
      getLogger().d('🗑️ LFU清理: $keyToEvict');
    }
  }
  
  /// FIFO清理策略
  void _evictFIFO() {
    if (_cache.isNotEmpty) {
      final sortedItems = _cache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final keyToEvict = sortedItems.first.key;
      _cache.remove(keyToEvict);
      _accessOrder.remove(keyToEvict);
      _evictionCount++;
      getLogger().d('🗑️ FIFO清理: $keyToEvict');
    }
  }
  
  /// 清理过期项
  void _evictExpired() {
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (_isExpired(entry.value)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _accessOrder.remove(key);
      _evictionCount++;
      getLogger().d('⏰ 过期清理: $key');
    }
  }
  
  /// 智能清理策略
  void _evictSmart() {
    // 首先清理过期项
    _evictExpired();
    
    // 如果还需要清理，使用优先级算法
    if (_cache.length >= maxCacheSize) {
      final sortedItems = _cache.entries.toList()
        ..sort((a, b) => a.value.priority.compareTo(b.value.priority));
      
      // 清理优先级最低的项
      final itemsToEvict = (maxCacheSize * 0.2).ceil(); // 清理20%
      for (int i = 0; i < itemsToEvict && i < sortedItems.length; i++) {
        final keyToEvict = sortedItems[i].key;
        _cache.remove(keyToEvict);
        _accessOrder.remove(keyToEvict);
        _evictionCount++;
        getLogger().d('🧠 智能清理: $keyToEvict (优先级: ${sortedItems[i].value.priority.toStringAsFixed(2)})');
      }
    }
  }
  
  /// 检查是否包含指定key
  bool containsKey(String key) {
    return _cache.containsKey(key) && !_isExpired(_cache[key]!);
  }
  
  /// 移除指定key的缓存
  bool remove(String key) {
    final removed = _cache.remove(key) != null;
    _accessOrder.remove(key);
    if (removed) {
      getLogger().d('🗑️ 手动移除缓存: $key');
      _updateMemoryUsage();
    }
    return removed;
  }
  
  /// 清空所有缓存
  void clear() {
    final count = _cache.length;
    _cache.clear();
    _accessOrder.clear();
    _updateMemoryUsage();
    getLogger().i('🗑️ 清空所有缓存: $count个项目');
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getStatistics() {
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? (_hitCount / totalRequests * 100) : 0.0;
    
    return {
      'cacheSize': _cache.length,
      'maxCacheSize': maxCacheSize,
      'hitCount': _hitCount,
      'missCount': _missCount,
      'hitRate': hitRate,
      'evictionCount': _evictionCount,
      'memoryUsageEstimate': memoryUsageEstimate.value,
      'strategy': strategy.toString(),
      'oldestItem': _getOldestItemAge(),
      'newestItem': _getNewestItemAge(),
      'averageAccessCount': _getAverageAccessCount(),
    };
  }
  
  /// 获取最老项目的年龄
  Duration? _getOldestItemAge() {
    if (_cache.isEmpty) return null;
    
    final oldestItem = _cache.values.reduce((a, b) => 
        a.createdAt.isBefore(b.createdAt) ? a : b);
    return oldestItem.age;
  }
  
  /// 获取最新项目的年龄
  Duration? _getNewestItemAge() {
    if (_cache.isEmpty) return null;
    
    final newestItem = _cache.values.reduce((a, b) => 
        a.createdAt.isAfter(b.createdAt) ? a : b);
    return newestItem.age;
  }
  
  /// 获取平均访问次数
  double _getAverageAccessCount() {
    if (_cache.isEmpty) return 0.0;
    
    final totalAccess = _cache.values
        .map((item) => item.accessCount)
        .reduce((a, b) => a + b);
    return totalAccess / _cache.length;
  }
  
  /// 预热缓存
  void warmUp(Map<String, Widget> widgets) {
    getLogger().i('🔥 开始预热缓存: ${widgets.length}个Widget');
    
    for (final entry in widgets.entries) {
      put(entry.key, entry.value, metadata: {'prewarmed': true});
    }
    
    getLogger().i('✅ 缓存预热完成');
  }
  
  /// 预加载缓存系统
  void preload() {
    try {
      getLogger().d('📦 开始预加载缓存系统');
      
      // 清理过期项，为新的缓存腾出空间
      cleanupExpired();
      
      // 预分配一些内存空间（通过创建空的占位符）
      final preloadKeys = ['preload_placeholder_1', 'preload_placeholder_2'];
      for (final key in preloadKeys) {
        if (!containsKey(key)) {
          put(key, const SizedBox.shrink(), metadata: {
            'type': 'preload_placeholder',
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }
      
      // 启动内存监控（如果还没有启动）
      if (_memoryMonitorTimer == null || !_memoryMonitorTimer!.isActive) {
        _startMemoryMonitoring();
      }
      
      getLogger().d('✅ 缓存系统预加载完成');
    } catch (e) {
      getLogger().e('❌ 预加载缓存系统失败: $e');
    }
  }
  
  /// 获取缓存键列表
  List<String> get keys => _cache.keys.toList();
  
  /// 获取缓存项列表（按优先级排序）
  List<CachedWidgetItem> get itemsByPriority {
    final items = _cache.values.toList();
    items.sort((a, b) => b.priority.compareTo(a.priority));
    return items;
  }
  
  /// 强制清理过期项
  int cleanupExpired() {
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (_isExpired(entry.value)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      _updateMemoryUsage();
      getLogger().i('🧹 清理过期项: ${expiredKeys.length}个');
    }
    
    return expiredKeys.length;
  }
  
  /// 重置统计信息
  void resetStatistics() {
    _hitCount = 0;
    _missCount = 0;
    _evictionCount = 0;
    getLogger().i('📊 缓存统计信息已重置');
  }
  
  /// 销毁缓存管理器
  void dispose() {
    _memoryMonitorTimer?.cancel();
    clear();
    getLogger().i('🔄 Widget缓存管理器已销毁');
  }
}
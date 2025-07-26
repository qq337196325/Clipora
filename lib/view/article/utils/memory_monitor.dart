import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../basics/logger.dart';

/// 内存使用信息
class MemoryUsageInfo {
  final double totalMemory;
  final double usedMemory;
  final double freeMemory;
  final double appMemory;
  final DateTime timestamp;
  
  const MemoryUsageInfo({
    required this.totalMemory,
    required this.usedMemory,
    required this.freeMemory,
    required this.appMemory,
    required this.timestamp,
  });
  
  /// 内存使用率
  double get usagePercentage => (usedMemory / totalMemory) * 100;
  
  /// 应用内存使用率
  double get appUsagePercentage => (appMemory / totalMemory) * 100;
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'totalMemory': totalMemory,
      'usedMemory': usedMemory,
      'freeMemory': freeMemory,
      'appMemory': appMemory,
      'usagePercentage': usagePercentage,
      'appUsagePercentage': appUsagePercentage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'MemoryUsage(total: ${_formatBytes(totalMemory)}, '
           'used: ${_formatBytes(usedMemory)}, '
           'app: ${_formatBytes(appMemory)}, '
           'usage: ${usagePercentage.toStringAsFixed(1)}%)';
  }
  
  /// 格式化字节数
  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 内存警告级别
enum MemoryWarningLevel {
  /// 正常
  normal,
  /// 警告
  warning,
  /// 严重
  critical,
  /// 紧急
  emergency,
}

/// 内存监控器
class MemoryMonitor {
  static const MethodChannel _channel = MethodChannel('memory_monitor');
  
  final Duration monitorInterval;
  final double warningThreshold;
  final double criticalThreshold;
  final double emergencyThreshold;
  final int maxHistorySize;
  
  Timer? _monitorTimer;
  final List<MemoryUsageInfo> _history = [];
  
  // 响应式状态
  final Rx<MemoryUsageInfo?> currentUsage = Rx<MemoryUsageInfo?>(null);
  final Rx<MemoryWarningLevel> warningLevel = MemoryWarningLevel.normal.obs;
  final RxBool isMonitoring = false.obs;
  
  // 回调函数
  void Function(MemoryUsageInfo info)? onMemoryUpdate;
  void Function(MemoryWarningLevel level, MemoryUsageInfo info)? onWarningLevelChanged;
  void Function(MemoryUsageInfo info)? onMemoryPressure;
  
  // 统计信息
  int _warningCount = 0;
  int _criticalCount = 0;
  int _emergencyCount = 0;
  
  MemoryMonitor({
    this.monitorInterval = const Duration(seconds: 5),
    this.warningThreshold = 70.0, // 70%
    this.criticalThreshold = 85.0, // 85%
    this.emergencyThreshold = 95.0, // 95%
    this.maxHistorySize = 100,
  });
  
  /// 开始监控
  void startMonitoring() {
    if (isMonitoring.value) {
      getLogger().w('⚠️ 内存监控已在运行');
      return;
    }
    
    isMonitoring.value = true;
    _monitorTimer = Timer.periodic(monitorInterval, (_) => _updateMemoryUsage());
    
    // 立即获取一次内存信息
    _updateMemoryUsage();
    
    getLogger().i('📊 内存监控已启动');
  }
  
  /// 停止监控
  void stopMonitoring() {
    if (!isMonitoring.value) return;
    
    _monitorTimer?.cancel();
    _monitorTimer = null;
    isMonitoring.value = false;
    
    getLogger().i('⏹️ 内存监控已停止');
  }
  
  /// 更新内存使用情况
  Future<void> _updateMemoryUsage() async {
    try {
      final info = await _getMemoryUsage();
      
      // 更新当前使用情况
      currentUsage.value = info;
      
      // 添加到历史记录
      _addToHistory(info);
      
      // 检查警告级别
      _checkWarningLevel(info);
      
      // 触发回调
      onMemoryUpdate?.call(info);
      
      getLogger().d('📊 内存使用更新: ${info.toString()}');
    } catch (e) {
      getLogger().e('❌ 获取内存使用信息失败: $e');
    }
  }
  
  /// 获取内存使用信息
  Future<MemoryUsageInfo> _getMemoryUsage() async {
    try {
      // 尝试通过平台通道获取精确的内存信息
      final result = await _channel.invokeMethod('getMemoryUsage');
      
      return MemoryUsageInfo(
        totalMemory: (result['totalMemory'] as num).toDouble(),
        usedMemory: (result['usedMemory'] as num).toDouble(),
        freeMemory: (result['freeMemory'] as num).toDouble(),
        appMemory: (result['appMemory'] as num).toDouble(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // 如果平台通道不可用，使用估算值
      return _getEstimatedMemoryUsage();
    }
  }
  
  /// 获取估算的内存使用信息
  MemoryUsageInfo _getEstimatedMemoryUsage() {
    // 这是一个简化的估算，实际应用中应该使用更精确的方法
    final totalMemory = Platform.isAndroid ? 2048.0 * 1024 * 1024 : 4096.0 * 1024 * 1024; // 2GB/4GB估算
    final appMemory = 100.0 * 1024 * 1024; // 100MB估算
    final usedMemory = totalMemory * 0.6; // 60%估算
    final freeMemory = totalMemory - usedMemory;
    
    return MemoryUsageInfo(
      totalMemory: totalMemory,
      usedMemory: usedMemory,
      freeMemory: freeMemory,
      appMemory: appMemory,
      timestamp: DateTime.now(),
    );
  }
  
  /// 添加到历史记录
  void _addToHistory(MemoryUsageInfo info) {
    _history.add(info);
    
    // 保持历史记录大小在限制范围内
    while (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
  }
  
  /// 检查警告级别
  void _checkWarningLevel(MemoryUsageInfo info) {
    final usage = info.usagePercentage;
    MemoryWarningLevel newLevel;
    
    if (usage >= emergencyThreshold) {
      newLevel = MemoryWarningLevel.emergency;
      _emergencyCount++;
      onMemoryPressure?.call(info);
    } else if (usage >= criticalThreshold) {
      newLevel = MemoryWarningLevel.critical;
      _criticalCount++;
    } else if (usage >= warningThreshold) {
      newLevel = MemoryWarningLevel.warning;
      _warningCount++;
    } else {
      newLevel = MemoryWarningLevel.normal;
    }
    
    if (newLevel != warningLevel.value) {
      final previousLevel = warningLevel.value;
      warningLevel.value = newLevel;
      onWarningLevelChanged?.call(newLevel, info);
      
      getLogger().i('⚠️ 内存警告级别变化: $previousLevel -> $newLevel');
    }
  }
  
  /// 获取内存使用历史
  List<MemoryUsageInfo> get history => List.unmodifiable(_history);
  
  /// 获取平均内存使用率
  double get averageUsagePercentage {
    if (_history.isEmpty) return 0.0;
    
    final totalUsage = _history
        .map((info) => info.usagePercentage)
        .reduce((a, b) => a + b);
    return totalUsage / _history.length;
  }
  
  /// 获取峰值内存使用率
  double get peakUsagePercentage {
    if (_history.isEmpty) return 0.0;
    
    return _history
        .map((info) => info.usagePercentage)
        .reduce((a, b) => a > b ? a : b);
  }
  
  /// 获取最低内存使用率
  double get minUsagePercentage {
    if (_history.isEmpty) return 0.0;
    
    return _history
        .map((info) => info.usagePercentage)
        .reduce((a, b) => a < b ? a : b);
  }
  
  /// 获取内存使用趋势
  String get usageTrend {
    if (_history.length < 2) return 'stable';
    
    final recent = _history.sublist(_history.length > 5 ? _history.length - 5 : 0);
    if (recent.length < 2) return 'stable';
    
    final firstUsage = recent.first.usagePercentage;
    final lastUsage = recent.last.usagePercentage;
    final difference = lastUsage - firstUsage;
    
    if (difference > 5.0) return 'increasing';
    if (difference < -5.0) return 'decreasing';
    return 'stable';
  }
  
  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'isMonitoring': isMonitoring.value,
      'currentUsage': currentUsage.value?.toMap(),
      'warningLevel': warningLevel.value.toString(),
      'averageUsage': averageUsagePercentage,
      'peakUsage': peakUsagePercentage,
      'minUsage': minUsagePercentage,
      'usageTrend': usageTrend,
      'historySize': _history.length,
      'warningCount': _warningCount,
      'criticalCount': _criticalCount,
      'emergencyCount': _emergencyCount,
      'thresholds': {
        'warning': warningThreshold,
        'critical': criticalThreshold,
        'emergency': emergencyThreshold,
      },
    };
  }
  
  /// 触发垃圾回收
  Future<void> triggerGarbageCollection() async {
    try {
      await _channel.invokeMethod('triggerGC');
      getLogger().i('🗑️ 已触发垃圾回收');
    } catch (e) {
      getLogger().w('⚠️ 触发垃圾回收失败: $e');
    }
  }
  
  /// 清理内存
  Future<void> cleanupMemory() async {
    try {
      // 触发垃圾回收
      await triggerGarbageCollection();
      
      // 等待一段时间让GC完成
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 更新内存使用情况
      await _updateMemoryUsage();
      
      getLogger().i('🧹 内存清理完成');
    } catch (e) {
      getLogger().e('❌ 内存清理失败: $e');
    }
  }
  
  /// 检查是否需要内存优化
  bool get needsMemoryOptimization {
    return warningLevel.value != MemoryWarningLevel.normal;
  }
  
  /// 获取内存优化建议
  List<String> getOptimizationSuggestions() {
    final suggestions = <String>[];
    
    if (currentUsage.value == null) return suggestions;
    
    final usage = currentUsage.value!.usagePercentage;
    
    if (usage > emergencyThreshold) {
      suggestions.addAll([
        '立即释放所有非必要的缓存',
        '暂停所有后台任务',
        '销毁不可见的WebView实例',
        '清理图片缓存',
        '触发垃圾回收',
      ]);
    } else if (usage > criticalThreshold) {
      suggestions.addAll([
        '释放部分缓存',
        '暂停不重要的后台任务',
        '优化WebView实例数量',
        '清理过期的缓存项',
      ]);
    } else if (usage > warningThreshold) {
      suggestions.addAll([
        '检查缓存使用情况',
        '优化图片加载',
        '清理临时文件',
      ]);
    }
    
    return suggestions;
  }
  
  /// 重置统计信息
  void resetStatistics() {
    _warningCount = 0;
    _criticalCount = 0;
    _emergencyCount = 0;
    _history.clear();
    getLogger().i('📊 内存监控统计信息已重置');
  }
  
  /// 导出历史数据
  List<Map<String, dynamic>> exportHistory() {
    return _history.map((info) => info.toMap()).toList();
  }
  
  /// 销毁监控器
  void dispose() {
    stopMonitoring();
    _history.clear();
    currentUsage.value = null;
    warningLevel.value = MemoryWarningLevel.normal;
    
    getLogger().i('🔄 内存监控器已销毁');
  }
}

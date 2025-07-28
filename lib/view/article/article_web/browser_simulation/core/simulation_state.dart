// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:uuid/uuid.dart';

/// 浏览器仿真状态管理类
/// 负责跟踪和管理仿真系统的运行状态
class SimulationState {
  // ==================== 基础状态 ====================
  
  /// 是否已初始化
  bool isInitialized = false;
  
  /// 会话ID
  late final String sessionId;
  
  /// 仿真开始时间
  DateTime? startTime;
  
  /// 最后活跃时间
  DateTime? lastActiveTime;
  
  // ==================== 存储状态 ====================
  
  /// Cookie存储状态
  final CookieStorageState cookieState = CookieStorageState();
  
  /// LocalStorage状态
  final LocalStorageState localStorageState = LocalStorageState();
  
  /// SessionStorage状态
  final SessionStorageState sessionStorageState = SessionStorageState();
  
  // ==================== 性能状态 ====================
  
  /// 内存使用量（字节）
  int memoryUsage = 0;
  
  /// 请求计数
  int requestCount = 0;
  
  /// 错误计数
  int errorCount = 0;
  
  /// 平均响应时间（毫秒）
  double averageResponseTime = 0.0;
  
  // ==================== 构造函数 ====================
  
  SimulationState() {
    _initialize();
  }
  
  /// 初始化状态
  void _initialize() {
    sessionId = const Uuid().v4();
    startTime = DateTime.now();
    lastActiveTime = DateTime.now();
  }
  
  // ==================== 状态管理方法 ====================
  
  /// 更新最后活跃时间
  void updateLastActiveTime() {
    lastActiveTime = DateTime.now();
  }
  
  /// 增加请求计数
  void incrementRequestCount() {
    requestCount++;
    updateLastActiveTime();
  }
  
  /// 增加错误计数
  void incrementErrorCount() {
    errorCount++;
    updateLastActiveTime();
  }
  
  /// 更新内存使用量
  void updateMemoryUsage(int newMemoryUsage) {
    memoryUsage = newMemoryUsage;
    updateLastActiveTime();
  }
  
  /// 更新平均响应时间
  void updateAverageResponseTime(double responseTime) {
    if (requestCount == 0) {
      averageResponseTime = responseTime;
    } else {
      // 计算移动平均值
      averageResponseTime = (averageResponseTime * (requestCount - 1) + responseTime) / requestCount;
    }
    updateLastActiveTime();
  }
  
  /// 重置状态
  void reset() {
    isInitialized = false;
    startTime = null;
    lastActiveTime = null;
    memoryUsage = 0;
    requestCount = 0;
    errorCount = 0;
    averageResponseTime = 0.0;
    
    // 重置存储状态
    cookieState.reset();
    localStorageState.reset();
    sessionStorageState.reset();
    
    // 重新初始化
    _initialize();
  }
  
  // ==================== 统计方法 ====================
  
  /// 获取运行时长（秒）
  int get runtimeSeconds {
    if (startTime == null) return 0;
    return DateTime.now().difference(startTime!).inSeconds;
  }
  
  /// 获取空闲时长（秒）
  int get idleSeconds {
    if (lastActiveTime == null) return 0;
    return DateTime.now().difference(lastActiveTime!).inSeconds;
  }
  
  /// 获取成功率
  double get successRate {
    if (requestCount == 0) return 1.0;
    return (requestCount - errorCount) / requestCount;
  }
  
  /// 获取每秒请求数
  double get requestsPerSecond {
    final runtime = runtimeSeconds;
    if (runtime == 0) return 0.0;
    return requestCount / runtime;
  }
  
  // ==================== 序列化方法 ====================
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'isInitialized': isInitialized,
      'sessionId': sessionId,
      'startTime': startTime?.toIso8601String(),
      'lastActiveTime': lastActiveTime?.toIso8601String(),
      'runtimeSeconds': runtimeSeconds,
      'idleSeconds': idleSeconds,
      'memoryUsage': memoryUsage,
      'requestCount': requestCount,
      'errorCount': errorCount,
      'successRate': successRate,
      'averageResponseTime': averageResponseTime,
      'requestsPerSecond': requestsPerSecond,
      'cookieState': cookieState.toMap(),
      'localStorageState': localStorageState.toMap(),
      'sessionStorageState': sessionStorageState.toMap(),
    };
  }
  
  @override
  String toString() {
    return 'SimulationState${toMap()}';
  }
}

/// Cookie存储状态
class CookieStorageState {
  /// Cookie数量
  int cookieCount = 0;
  
  /// 过期Cookie数量
  int expiredCookieCount = 0;
  
  /// 最后清理时间
  DateTime? lastCleanupTime;
  
  /// 总存储大小（字节）
  int totalStorageSize = 0;
  
  void reset() {
    cookieCount = 0;
    expiredCookieCount = 0;
    lastCleanupTime = null;
    totalStorageSize = 0;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'cookieCount': cookieCount,
      'expiredCookieCount': expiredCookieCount,
      'lastCleanupTime': lastCleanupTime?.toIso8601String(),
      'totalStorageSize': totalStorageSize,
    };
  }
}

/// LocalStorage状态
class LocalStorageState {
  /// 存储的键数量
  int keyCount = 0;
  
  /// 总存储大小（字节）
  int totalStorageSize = 0;
  
  /// 压缩率
  double compressionRatio = 1.0;
  
  /// 最大key长度
  int maxKeyLength = 0;
  
  /// 最大value长度
  int maxValueLength = 0;
  
  void reset() {
    keyCount = 0;
    totalStorageSize = 0;
    compressionRatio = 1.0;
    maxKeyLength = 0;
    maxValueLength = 0;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'keyCount': keyCount,
      'totalStorageSize': totalStorageSize,
      'compressionRatio': compressionRatio,
      'maxKeyLength': maxKeyLength,
      'maxValueLength': maxValueLength,
    };
  }
}

/// SessionStorage状态
class SessionStorageState {
  /// 存储的键数量
  int keyCount = 0;
  
  /// 总存储大小（字节）
  int totalStorageSize = 0;
  
  /// 会话开始时间
  DateTime? sessionStartTime;
  
  /// 最后访问时间
  DateTime? lastAccessTime;
  
  /// 是否已过期
  bool get isExpired {
    if (lastAccessTime == null) return false;
    return DateTime.now().difference(lastAccessTime!).inMinutes > 30; // 30分钟超时
  }
  
  void reset() {
    keyCount = 0;
    totalStorageSize = 0;
    sessionStartTime = DateTime.now();
    lastAccessTime = DateTime.now();
  }
  
  void updateAccessTime() {
    lastAccessTime = DateTime.now();
  }
  
  Map<String, dynamic> toMap() {
    return {
      'keyCount': keyCount,
      'totalStorageSize': totalStorageSize,
      'sessionStartTime': sessionStartTime?.toIso8601String(),
      'lastAccessTime': lastAccessTime?.toIso8601String(),
      'isExpired': isExpired,
    };
  }
} 
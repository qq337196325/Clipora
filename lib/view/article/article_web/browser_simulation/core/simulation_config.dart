// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



/// 浏览器仿真配置类
/// 包含所有仿真功能的配置参数
class SimulationConfig {
  // ==================== 基础功能开关 ====================
  
  /// 是否启用存储管理功能（Cookie、LocalStorage等）
  bool enableStorageManagement = true;
  
  /// 是否启用设备指纹仿真
  bool enableFingerprinting = true;
  
  /// 是否启用行为仿真
  bool enableBehaviorSimulation = true;
  
  /// 是否启用网络优化
  bool enableNetworkOptimization = true;
  
  /// 是否启用反检测功能
  bool enableAntiDetection = true;
  
  // ==================== 存储配置 ====================
  
  /// Cookie存储配置
  final CookieStorageConfig cookieConfig = CookieStorageConfig();
  
  /// LocalStorage配置
  final LocalStorageConfig localStorageConfig = LocalStorageConfig();
  
  /// SessionStorage配置
  final SessionStorageConfig sessionStorageConfig = SessionStorageConfig();
  
  // ==================== 性能配置 ====================
  
  /// 最大并发请求数
  int maxConcurrentRequests = 6;
  
  /// 最小请求间隔（毫秒）
  int minRequestInterval = 200;
  
  /// 最大内存使用量（MB）
  int maxMemoryUsage = 512;
  
  /// 存储清理间隔（秒）
  int storageCleanupInterval = 3600;
  
  // ==================== 安全配置 ====================
  
  /// 是否轮换设备指纹
  bool rotateFingerprint = false;
  
  /// 指纹轮换间隔（秒）
  int fingerprintRotationInterval = 3600;
  
  /// 是否启用严格模式（更严格的反检测）
  bool strictMode = false;
  
  // ==================== 调试配置 ====================
  
  /// 是否启用调试模式
  bool debugMode = false;
  
  /// 是否记录网络请求
  bool logNetworkRequests = false;
  
  /// 是否启用性能监控
  bool performanceMonitoring = false;
  
  /// 是否启用详细日志
  bool verboseLogging = false;
  
  // ==================== 构造函数 ====================
  
  /// 默认构造函数
  SimulationConfig();
  
  // ==================== 工厂方法 ====================
  
  /// 创建默认配置
  factory SimulationConfig.defaultConfig() {
    return SimulationConfig();
  }
  
  /// 创建调试配置
  factory SimulationConfig.debugConfig() {
    final config = SimulationConfig();
    config.debugMode = true;
    config.logNetworkRequests = true;
    config.performanceMonitoring = true;
    config.verboseLogging = true;
    return config;
  }
  
  /// 创建生产环境配置
  factory SimulationConfig.productionConfig() {
    final config = SimulationConfig();
    config.debugMode = false;
    config.logNetworkRequests = false;
    config.performanceMonitoring = false;
    config.verboseLogging = false;
    config.strictMode = true;
    return config;
  }
  
  // ==================== 实用方法 ====================
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'enableStorageManagement': enableStorageManagement,
      'enableFingerprinting': enableFingerprinting,
      'enableBehaviorSimulation': enableBehaviorSimulation,
      'enableNetworkOptimization': enableNetworkOptimization,
      'enableAntiDetection': enableAntiDetection,
      'maxConcurrentRequests': maxConcurrentRequests,
      'minRequestInterval': minRequestInterval,
      'maxMemoryUsage': maxMemoryUsage,
      'storageCleanupInterval': storageCleanupInterval,
      'rotateFingerprint': rotateFingerprint,
      'fingerprintRotationInterval': fingerprintRotationInterval,
      'strictMode': strictMode,
      'debugMode': debugMode,
      'logNetworkRequests': logNetworkRequests,
      'performanceMonitoring': performanceMonitoring,
      'verboseLogging': verboseLogging,
    };
  }
  
  @override
  String toString() {
    return 'SimulationConfig${toMap()}';
  }
}

/// Cookie存储配置
class CookieStorageConfig {
  /// 是否启用Cookie持久化
  bool enablePersistence = true;
  
  /// Cookie最大存储数量
  int maxCookieCount = 1000;
  
  /// Cookie默认过期时间（秒）
  int defaultExpirationTime = 86400 * 30; // 30天
  
  /// 是否自动清理过期Cookie
  bool autoCleanupExpired = true;
  
  /// 清理检查间隔（秒）
  int cleanupCheckInterval = 3600; // 1小时
}

/// LocalStorage配置
class LocalStorageConfig {
  /// 是否启用LocalStorage仿真
  bool enabled = true;
  
  /// 最大存储大小（字节）
  int maxStorageSize = 10 * 1024 * 1024; // 10MB
  
  /// 单个key的最大大小（字节）
  int maxKeySize = 1024; // 1KB
  
  /// 单个value的最大大小（字节）
  int maxValueSize = 1024 * 1024; // 1MB
  
  /// 是否压缩存储数据
  bool compressData = true;
}

/// SessionStorage配置
class SessionStorageConfig {
  /// 是否启用SessionStorage仿真
  bool enabled = true;
  
  /// 最大存储大小（字节）
  int maxStorageSize = 5 * 1024 * 1024; // 5MB
  
  /// 单个key的最大大小（字节）
  int maxKeySize = 1024; // 1KB
  
  /// 单个value的最大大小（字节）
  int maxValueSize = 512 * 1024; // 512KB
  
  /// 会话超时时间（秒）
  int sessionTimeout = 1800; // 30分钟
} 
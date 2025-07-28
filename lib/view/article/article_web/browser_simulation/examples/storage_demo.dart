// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import '../core/browser_simulation_manager.dart';
import '../core/simulation_config.dart';
import '../../../../../basics/logger.dart';

/// 浏览器存储管理功能演示
/// 展示如何使用Cookie、LocalStorage、SessionStorage功能
class BrowserStorageDemo {
  late BrowserSimulationManager _manager;
  
  /// 初始化演示
  Future<void> initialize() async {
    _manager = BrowserSimulationManager();
    _manager.onInit();
    
    getLogger().i('🎮 浏览器存储演示初始化完成');
  }
  
  /// 演示Cookie功能
  Future<void> demoCookieFeatures() async {
    getLogger().i('🍪 === Cookie功能演示 ===');
    
    final storageManager = _manager.storageManager;
    
    // 设置基本Cookie
    await storageManager.setCookie(
      url: 'https://example.com',
      name: 'user_id',
      value: '123456',
      maxAge: 86400, // 24小时
    );
    
    // 设置带过期时间的Cookie
    await storageManager.setCookie(
      url: 'https://example.com',
      name: 'session_token',
      value: 'abc123def456',
      expires: DateTime.now().add(const Duration(hours: 2)),
      httpOnly: true,
      secure: true,
    );
    
    // 设置路径特定的Cookie
    await storageManager.setCookie(
      url: 'https://example.com/api',
      name: 'api_key',
      value: 'xyz789',
      path: '/api',
    );
    
    // 获取Cookie
    final userIdCookie = storageManager.getCookie('example.com', 'user_id');
    getLogger().i('🍪 获取到Cookie: ${userIdCookie?.name} = ${userIdCookie?.value}');
    
    // 获取域名下所有Cookie
    final allCookies = storageManager.getCookiesForDomain('example.com');
    getLogger().i('🍪 example.com下的所有Cookie: ${allCookies.length}个');
    
    // 清理过期Cookie
    final cleanedCount = await storageManager.cleanupExpiredCookies();
    getLogger().i('🧹 清理了 $cleanedCount 个过期Cookie');
  }
  
  /// 演示LocalStorage功能
  Future<void> demoLocalStorageFeatures() async {
    getLogger().i('💾 === LocalStorage功能演示 ===');
    
    final storageManager = _manager.storageManager;
    
    // 设置各种类型的数据
    await storageManager.setLocalStorageItem('userName', '张三');
    await storageManager.setLocalStorageItem('userAge', '25');
    await storageManager.setLocalStorageItem('userPreferences', '{"theme":"dark","language":"zh-CN"}');
    await storageManager.setLocalStorageItem('lastVisit', DateTime.now().toIso8601String());
    
    // 设置大数据测试
    final largeData = 'x' * 1000; // 1KB数据
    await storageManager.setLocalStorageItem('largeData', largeData);
    
    // 获取数据
    final userName = storageManager.getLocalStorageItem('userName');
    final userAge = storageManager.getLocalStorageItem('userAge');
    final preferences = storageManager.getLocalStorageItem('userPreferences');
    
    getLogger().i('💾 用户名: $userName');
    getLogger().i('💾 年龄: $userAge');
    getLogger().i('💾 偏好设置: $preferences');
    
    // 获取所有键
    final keys = storageManager.getLocalStorageKeys();
    getLogger().i('💾 LocalStorage包含 ${keys.length} 个键: $keys');
    
    // 删除特定项
    await storageManager.removeLocalStorageItem('largeData');
    getLogger().i('💾 已删除大数据项');
  }
  
  /// 演示SessionStorage功能
  Future<void> demoSessionStorageFeatures() async {
    getLogger().i('🔄 === SessionStorage功能演示 ===');
    
    final storageManager = _manager.storageManager;
    
    // 设置会话数据
    storageManager.setSessionStorageItem('currentPage', 'article_detail');
    storageManager.setSessionStorageItem('scrollPosition', '1250');
    storageManager.setSessionStorageItem('tempFormData', '{"title":"文章标题","content":"文章内容"}');
    storageManager.setSessionStorageItem('sessionStart', DateTime.now().toIso8601String());
    
    // 获取数据
    final currentPage = storageManager.getSessionStorageItem('currentPage');
    final scrollPos = storageManager.getSessionStorageItem('scrollPosition');
    final formData = storageManager.getSessionStorageItem('tempFormData');
    
    getLogger().i('🔄 当前页面: $currentPage');
    getLogger().i('🔄 滚动位置: $scrollPos');
    getLogger().i('🔄 表单数据: $formData');
    
    // 获取所有键
    final keys = storageManager.getSessionStorageKeys();
    getLogger().i('🔄 SessionStorage包含 ${keys.length} 个键: $keys');
    
    // 清空部分数据
    storageManager.removeSessionStorageItem('tempFormData');
    getLogger().i('🔄 已删除临时表单数据');
  }
  
  /// 演示存储统计功能
  Future<void> demoStorageStats() async {
    getLogger().i('📊 === 存储统计演示 ===');
    
    final storageManager = _manager.storageManager;
    
    // 获取统计信息
    final stats = storageManager.getStorageStats();
    getLogger().i('📊 存储统计: $stats');
    
    // 获取总大小
    final totalSize = storageManager.getTotalStorageSize();
    getLogger().i('📊 总存储大小: ${totalSize}字节 (${(totalSize / 1024).toStringAsFixed(2)}KB)');
    
    // 获取Cookie数量
    final cookieCount = storageManager.getCookieCount();
    getLogger().i('📊 Cookie数量: $cookieCount');
    
    // 获取仿真状态信息
    final simulationInfo = _manager.getSimulationInfo();
    getLogger().i('📊 仿真状态: $simulationInfo');
  }
  
  /// 演示配置功能
  void demoConfigFeatures() {
    getLogger().i('⚙️ === 配置功能演示 ===');
    
    // 默认配置
    final defaultConfig = SimulationConfig.defaultConfig();
    getLogger().i('⚙️ 默认配置: ${defaultConfig.enableStorageManagement}');
    
    // 调试配置
    final debugConfig = SimulationConfig.debugConfig();
    getLogger().i('⚙️ 调试模式: ${debugConfig.debugMode}');
    
    // 生产配置
    final productionConfig = SimulationConfig.productionConfig();
    getLogger().i('⚙️ 生产模式: ${productionConfig.strictMode}');
    
    // 自定义配置
    final customConfig = SimulationConfig();
    customConfig.cookieConfig.maxCookieCount = 500;
    customConfig.localStorageConfig.maxStorageSize = 20 * 1024 * 1024; // 20MB
    customConfig.sessionStorageConfig.sessionTimeout = 3600; // 1小时
    
    getLogger().i('⚙️ 自定义配置完成');
  }
  
  /// 运行完整演示
  Future<void> runFullDemo() async {
    try {
      getLogger().i('🚀 开始浏览器存储功能完整演示...');
      
      await initialize();
      
      demoConfigFeatures();
      await demoCookieFeatures();
      await demoLocalStorageFeatures();
      await demoSessionStorageFeatures();
      await demoStorageStats();
      
      getLogger().i('✅ 浏览器存储功能演示完成!');
    } catch (e) {
      getLogger().e('❌ 演示执行失败: $e');
    }
  }
  
  /// 演示数据清理
  Future<void> demoDataCleanup() async {
    getLogger().i('🧹 === 数据清理演示 ===');
    
    final storageManager = _manager.storageManager;
    
    // 清理LocalStorage
    await storageManager.clearLocalStorage();
    getLogger().i('🧹 LocalStorage已清空');
    
    // 清理SessionStorage
    storageManager.clearSessionStorage();
    getLogger().i('🧹 SessionStorage已清空');
    
    // 清理过期Cookie
    final cleanedCookies = await storageManager.cleanupExpiredCookies();
    getLogger().i('🧹 清理了 $cleanedCookies 个过期Cookie');
    
    // 重置整个仿真系统
    await _manager.resetSimulation();
    getLogger().i('�� 仿真系统已重置');
  }
} 
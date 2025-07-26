
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../../../basics/logger.dart';
import '../core/simulation_config.dart';

/// 浏览器存储管理器
/// 负责管理Cookie、LocalStorage、SessionStorage的持久化存储
class BrowserStorageManager {
  // ==================== 存储实例 ====================
  
  /// GetStorage实例 - 用于复杂数据存储
  late final GetStorage _storage;
  
  /// SharedPreferences实例 - 用于简单配置存储
  late final SharedPreferences _prefs;
  
  /// Cookie管理器
  late final CookieManager _cookieManager;
  
  // ==================== 存储键定义 ====================
  
  static const String _cookieStorageKey = 'browser_cookies';
  static const String _localStorageKey = 'browser_localStorage';
  static const String _sessionStorageKey = 'browser_sessionStorage';
  static const String _storageConfigKey = 'storage_config';
  static const String _lastCleanupKey = 'last_cleanup_time';
  
  // ==================== 内存缓存 ====================
  
  /// Cookie缓存
  final Map<String, BrowserCookie> _cookieCache = {};
  
  /// LocalStorage缓存
  final Map<String, String> _localStorageCache = {};
  
  /// SessionStorage缓存（仅在会话期间有效）
  final Map<String, String> _sessionStorageCache = {};
  
  // ==================== 状态变量 ====================
  
  bool _isInitialized = false;
  SimulationConfig? _config;
  
  // ==================== 初始化方法 ====================
  
  /// 初始化存储管理器
  Future<void> initialize([SimulationConfig? config]) async {
    if (_isInitialized) return;
    
    try {
      getLogger().i('🗄️ 开始初始化浏览器存储管理器...');
      
      _config = config ?? SimulationConfig();
      
      // 初始化 GetStorage
      await GetStorage.init('browser_simulation');
      _storage = GetStorage('browser_simulation');
      
      // 初始化 SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 初始化 Cookie 管理器
      _cookieManager = CookieManager.instance();
      
      // 加载持久化数据
      await _loadPersistedData();
      
      // 启动自动清理任务
      _startAutoCleanup();
      
      _isInitialized = true;
      getLogger().i('✅ 浏览器存储管理器初始化完成');
    } catch (e) {
      getLogger().e('❌ 浏览器存储管理器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 加载持久化数据
  Future<void> _loadPersistedData() async {
    try {
      // 加载Cookie数据
      final cookieData = _storage.read<Map<String, dynamic>>(_cookieStorageKey);
      if (cookieData != null) {
        _loadCookiesFromStorage(cookieData);
      }
      
      // 加载LocalStorage数据
      final localStorageData = _storage.read<Map<String, dynamic>>(_localStorageKey);
      if (localStorageData != null) {
        _localStorageCache.addAll(Map<String, String>.from(localStorageData));
      }
      
      // SessionStorage不需要持久化加载（会话级别）
      _sessionStorageCache.clear();
      
      getLogger().i('📥 持久化数据加载完成 - Cookie: ${_cookieCache.length}, LocalStorage: ${_localStorageCache.length}');
    } catch (e) {
      getLogger().e('❌ 加载持久化数据失败: $e');
    }
  }
  
  /// 从存储中加载Cookie数据
  void _loadCookiesFromStorage(Map<String, dynamic> cookieData) {
    cookieData.forEach((domain, cookies) {
      if (cookies is Map<String, dynamic>) {
        cookies.forEach((name, cookieMap) {
          if (cookieMap is Map<String, dynamic>) {
            try {
              final cookie = BrowserCookie.fromMap(cookieMap);
              final key = '${domain}_$name';
              _cookieCache[key] = cookie;
            } catch (e) {
              getLogger().w('⚠️ 跳过无效Cookie: $domain/$name - $e');
            }
          }
        });
      }
    });
  }
  
  // ==================== Cookie 管理 ====================
  
  /// 设置Cookie
  Future<void> setCookie({
    required String url,
    required String name,
    required String value,
    String? domain,
    String? path,
    int? maxAge,
    DateTime? expires,
    bool? httpOnly,
    bool? secure,
    HTTPCookieSameSitePolicy? sameSite,
  }) async {
    try {
      final uri = Uri.parse(url);
      final cookieDomain = domain ?? uri.host;
      final cookiePath = path ?? '/';
      
      // 创建Cookie对象
      final cookie = BrowserCookie(
        name: name,
        value: value,
        domain: cookieDomain,
        path: cookiePath,
        maxAge: maxAge,
        expires: expires,
        httpOnly: httpOnly ?? false,
        secure: secure ?? false,
        sameSite: sameSite,
        createdAt: DateTime.now(),
      );
      
      // 存储到缓存
      final key = '${cookieDomain}_$name';
      _cookieCache[key] = cookie;
      
      // 持久化存储
      await _persistCookies();
      
      // 同步到WebView
      await _syncCookieToWebView(url, cookie);
      
      getLogger().d('🍪 Cookie已设置: $cookieDomain/$name = $value');
    } catch (e) {
      getLogger().e('❌ 设置Cookie失败: $e');
    }
  }
  
  /// 获取Cookie
  BrowserCookie? getCookie(String domain, String name) {
    final key = '${domain}_$name';
    final cookie = _cookieCache[key];
    
    // 检查是否过期
    if (cookie != null && cookie.isExpired) {
      _cookieCache.remove(key);
      _persistCookies(); // 异步持久化
      return null;
    }
    
    return cookie;
  }
  
  /// 获取域名下的所有Cookie
  List<BrowserCookie> getCookiesForDomain(String domain) {
    return _cookieCache.values
        .where((cookie) => cookie.domain == domain && !cookie.isExpired)
        .toList();
  }
  
  /// 删除Cookie
  Future<void> deleteCookie(String domain, String name) async {
    final key = '${domain}_$name';
    _cookieCache.remove(key);
    await _persistCookies();
    
    // 从WebView中删除
    await _cookieManager.deleteCookie(url: WebUri('https://$domain'), name: name);
    
    getLogger().d('🗑️ Cookie已删除: $domain/$name');
  }
  
  /// 清理过期Cookie
  Future<int> cleanupExpiredCookies() async {
    int cleanedCount = 0;
    final expiredKeys = <String>[];
    
    _cookieCache.forEach((key, cookie) {
      if (cookie.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cookieCache.remove(key);
      cleanedCount++;
    }
    
    if (cleanedCount > 0) {
      await _persistCookies();
      getLogger().i('🧹 清理了 $cleanedCount 个过期Cookie');
    }
    
    return cleanedCount;
  }
  
  /// 同步Cookie到WebView
  Future<void> _syncCookieToWebView(String url, BrowserCookie cookie) async {
    try {
      await _cookieManager.setCookie(
        url: WebUri(url),
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path,
        maxAge: cookie.maxAge,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly,
        sameSite: cookie.sameSite,
      );
    } catch (e) {
      getLogger().w('⚠️ 同步Cookie到WebView失败: $e');
    }
  }
  
  /// 持久化Cookie数据
  Future<void> _persistCookies() async {
    try {
      final cookieData = <String, Map<String, Map<String, dynamic>>>{};
      
      _cookieCache.forEach((key, cookie) {
        if (!cookie.isExpired) {
          final domain = cookie.domain;
          final name = cookie.name;
          
          cookieData[domain] ??= {};
          cookieData[domain]![name] = cookie.toMap();
        }
      });
      
      await _storage.write(_cookieStorageKey, cookieData);
    } catch (e) {
      getLogger().e('❌ 持久化Cookie失败: $e');
    }
  }
  
  // ==================== LocalStorage 管理 ====================
  
  /// 设置LocalStorage项
  Future<void> setLocalStorageItem(String key, String value) async {
    try {
      // 检查大小限制
      if (key.length > (_config?.localStorageConfig.maxKeySize ?? 1024)) {
        throw Exception('Key太长: ${key.length} > ${_config?.localStorageConfig.maxKeySize}');
      }
      
      if (value.length > (_config?.localStorageConfig.maxValueSize ?? 1024 * 1024)) {
        throw Exception('Value太长: ${value.length} > ${_config?.localStorageConfig.maxValueSize}');
      }
      
      // 存储到缓存
      _localStorageCache[key] = value;
      
      // 持久化
      await _persistLocalStorage();
      
      getLogger().d('💾 LocalStorage已设置: $key = ${value.length > 100 ? "${value.substring(0, 100)}..." : value}');
    } catch (e) {
      getLogger().e('❌ 设置LocalStorage失败: $e');
    }
  }
  
  /// 获取LocalStorage项
  String? getLocalStorageItem(String key) {
    return _localStorageCache[key];
  }
  
  /// 删除LocalStorage项
  Future<void> removeLocalStorageItem(String key) async {
    _localStorageCache.remove(key);
    await _persistLocalStorage();
    getLogger().d('🗑️ LocalStorage项已删除: $key');
  }
  
  /// 清空LocalStorage
  Future<void> clearLocalStorage() async {
    _localStorageCache.clear();
    await _persistLocalStorage();
    getLogger().i('🧹 LocalStorage已清空');
  }
  
  /// 获取LocalStorage所有键
  List<String> getLocalStorageKeys() {
    return _localStorageCache.keys.toList();
  }
  
  /// 持久化LocalStorage数据
  Future<void> _persistLocalStorage() async {
    try {
      await _storage.write(_localStorageKey, _localStorageCache);
    } catch (e) {
      getLogger().e('❌ 持久化LocalStorage失败: $e');
    }
  }
  
  // ==================== SessionStorage 管理 ====================
  
  /// 设置SessionStorage项
  void setSessionStorageItem(String key, String value) {
    try {
      // 检查大小限制
      if (key.length > (_config?.sessionStorageConfig.maxKeySize ?? 1024)) {
        throw Exception('Key太长: ${key.length} > ${_config?.sessionStorageConfig.maxKeySize}');
      }
      
      if (value.length > (_config?.sessionStorageConfig.maxValueSize ?? 512 * 1024)) {
        throw Exception('Value太长: ${value.length} > ${_config?.sessionStorageConfig.maxValueSize}');
      }
      
      _sessionStorageCache[key] = value;
      getLogger().d('🔄 SessionStorage已设置: $key = ${value.length > 100 ? "${value.substring(0, 100)}..." : value}');
    } catch (e) {
      getLogger().e('❌ 设置SessionStorage失败: $e');
    }
  }
  
  /// 获取SessionStorage项
  String? getSessionStorageItem(String key) {
    return _sessionStorageCache[key];
  }
  
  /// 删除SessionStorage项
  void removeSessionStorageItem(String key) {
    _sessionStorageCache.remove(key);
    getLogger().d('🗑️ SessionStorage项已删除: $key');
  }
  
  /// 清空SessionStorage
  void clearSessionStorage() {
    _sessionStorageCache.clear();
    getLogger().i('🧹 SessionStorage已清空');
  }
  
  /// 获取SessionStorage所有键
  List<String> getSessionStorageKeys() {
    return _sessionStorageCache.keys.toList();
  }
  
  // ==================== 统计和管理方法 ====================
  
  /// 获取Cookie数量
  int getCookieCount() {
    return _cookieCache.values.where((cookie) => !cookie.isExpired).length;
  }
  
  /// 获取总存储大小
  int getTotalStorageSize() {
    int size = 0;
    
    // Cookie大小
    _cookieCache.values.forEach((cookie) {
      if (!cookie.isExpired) {
        size += cookie.name.length + cookie.value.length;
      }
    });
    
    // LocalStorage大小
    _localStorageCache.forEach((key, value) {
      size += key.length + value.length;
    });
    
    // SessionStorage大小
    _sessionStorageCache.forEach((key, value) {
      size += key.length + value.length;
    });
    
    return size;
  }
  
  /// 清空所有存储
  Future<void> clearAllStorage() async {
    _cookieCache.clear();
    _localStorageCache.clear();
    _sessionStorageCache.clear();
    
    await _storage.erase();
    await _prefs.clear();
    
    getLogger().i('🧹 所有存储已清空');
  }
  
  /// 启动自动清理任务
  void _startAutoCleanup() {
    if (_config?.cookieConfig.autoCleanupExpired == true) {
      // 每小时清理一次过期Cookie
      Future.delayed(const Duration(hours: 1), () async {
        await cleanupExpiredCookies();
        _startAutoCleanup(); // 递归调用实现定时任务
      });
    }
  }
  
  /// 获取存储统计信息
  Map<String, dynamic> getStorageStats() {
    return {
      'cookieCount': getCookieCount(),
      'localStorageKeys': getLocalStorageKeys().length,
      'sessionStorageKeys': getSessionStorageKeys().length,
      'totalStorageSize': getTotalStorageSize(),
      'isInitialized': _isInitialized,
    };
  }
  
  /// 释放资源
  void dispose() {
    getLogger().i('🔄 浏览器存储管理器正在释放资源...');
    // GetStorage和SharedPreferences会自动管理资源，无需手动释放
  }
}

/// 浏览器Cookie模型
class BrowserCookie {
  final String name;
  final String value;
  final String domain;
  final String path;
  final int? maxAge;
  final DateTime? expires;
  final bool httpOnly;
  final bool secure;
  final HTTPCookieSameSitePolicy? sameSite;
  final DateTime createdAt;
  
  BrowserCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.path,
    this.maxAge,
    this.expires,
    required this.httpOnly,
    required this.secure,
    this.sameSite,
    required this.createdAt,
  });
  
  /// 检查Cookie是否过期
  bool get isExpired {
    final now = DateTime.now();
    
    // 检查绝对过期时间
    if (expires != null && now.isAfter(expires!)) {
      return true;
    }
    
    // 检查相对过期时间
    if (maxAge != null) {
      final expirationTime = createdAt.add(Duration(seconds: maxAge!));
      if (now.isAfter(expirationTime)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'domain': domain,
      'path': path,
      'maxAge': maxAge,
      'expires': expires?.toIso8601String(),
      'httpOnly': httpOnly,
      'secure': secure,
      'sameSite': sameSite?.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// 从Map创建Cookie
  factory BrowserCookie.fromMap(Map<String, dynamic> map) {
    return BrowserCookie(
      name: map['name'] ?? '',
      value: map['value'] ?? '',
      domain: map['domain'] ?? '',
      path: map['path'] ?? '/',
      maxAge: map['maxAge'],
      expires: map['expires'] != null ? DateTime.parse(map['expires']) : null,
      httpOnly: map['httpOnly'] ?? false,
      secure: map['secure'] ?? false,
      sameSite: map['sameSite'] != null ? HTTPCookieSameSitePolicy.values.firstWhere(
        (e) => e.toString() == map['sameSite'],
        orElse: () => HTTPCookieSameSitePolicy.LAX,
      ) : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  @override
  String toString() {
    return 'BrowserCookie(name: $name, domain: $domain, path: $path, expired: $isExpired)';
  }
} 
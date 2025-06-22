# 浏览器仿真存储管理功能

## 概述

这是一个为Flutter剪藏应用设计的浏览器仿真存储管理系统，主要实现了以下功能：

- **Cookie持久化存储**：完整的Cookie管理，包括过期时间、域名、路径等
- **LocalStorage仿真**：通过GetStorage实现的持久化本地存储
- **SessionStorage仿真**：会话级别的临时存储
- **JavaScript注入**：在WebView中注入存储仿真代码
- **反检测基础功能**：隐藏WebDriver特征，模拟真实浏览器环境

## 项目结构

```
browser_simulation/
├── core/                           # 核心管理类
│   ├── browser_simulation_manager.dart  # 主管理器
│   ├── simulation_config.dart          # 配置管理
│   └── simulation_state.dart           # 状态管理
├── identity/                       # 身份仿真
│   └── storage_manager.dart            # 存储管理器
├── utils/                          # 工具类
│   └── js_injector.dart               # JavaScript注入器
└── examples/                       # 示例代码
    └── storage_demo.dart               # 功能演示
```

## 快速开始

### 1. 基础集成

```dart
import 'browser_simulation/core/browser_simulation_manager.dart';
import 'browser_simulation/utils/js_injector.dart';

class MyWebView extends StatefulWidget {
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  BrowserSimulationManager? _simulationManager;
  JSInjector? _jsInjector;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeBrowserSimulation();
  }

  Future<void> _initializeBrowserSimulation() async {
    _simulationManager = BrowserSimulationManager();
    Get.put(_simulationManager!);
    _jsInjector = JSInjector(_simulationManager!.storageManager);
  }
}
```

### 2. WebView配置

```dart
InAppWebView(
  onWebViewCreated: (controller) async {
    _webViewController = controller;
    
    // 设置JavaScript处理器
    await _jsInjector!.setupJavaScriptHandlers(controller);
    
    // 注入反检测代码
    await _jsInjector!.injectAntiDetectionCode(controller);
  },
  
  onLoadStop: (controller, url) async {
    // 注入存储仿真代码
    await _jsInjector!.injectStorageSimulation(controller);
    
    // 预加载存储数据
    await _jsInjector!.preloadStorageData(controller);
  },
)
```

## 核心功能使用

### Cookie管理

```dart
final storageManager = _simulationManager!.storageManager;

// 设置Cookie
await storageManager.setCookie(
  url: 'https://example.com',
  name: 'user_id',
  value: '123456',
  maxAge: 86400, // 24小时
  httpOnly: true,
  secure: true,
);

// 获取Cookie
final cookie = storageManager.getCookie('example.com', 'user_id');
print('Cookie值: ${cookie?.value}');

// 获取域名下所有Cookie
final cookies = storageManager.getCookiesForDomain('example.com');
print('Cookie数量: ${cookies.length}');

// 删除Cookie
await storageManager.deleteCookie('example.com', 'user_id');

// 清理过期Cookie
final cleanedCount = await storageManager.cleanupExpiredCookies();
print('清理了 $cleanedCount 个过期Cookie');
```

### LocalStorage管理

```dart
// 设置数据
await storageManager.setLocalStorageItem('userName', '张三');
await storageManager.setLocalStorageItem('userPreferences', 
  '{"theme":"dark","language":"zh-CN"}');

// 获取数据
final userName = storageManager.getLocalStorageItem('userName');
final preferences = storageManager.getLocalStorageItem('userPreferences');

// 获取所有键
final keys = storageManager.getLocalStorageKeys();
print('LocalStorage键: $keys');

// 删除数据
await storageManager.removeLocalStorageItem('userName');

// 清空所有数据
await storageManager.clearLocalStorage();
```

### SessionStorage管理

```dart
// 设置会话数据
storageManager.setSessionStorageItem('currentPage', 'article_detail');
storageManager.setSessionStorageItem('scrollPosition', '1250');

// 获取数据
final currentPage = storageManager.getSessionStorageItem('currentPage');
final scrollPos = storageManager.getSessionStorageItem('scrollPosition');

// 获取所有键
final keys = storageManager.getSessionStorageKeys();

// 删除数据
storageManager.removeSessionStorageItem('currentPage');

// 清空所有数据
storageManager.clearSessionStorage();
```

## 配置选项

### 基础配置

```dart
// 默认配置
final config = SimulationConfig.defaultConfig();

// 调试配置
final debugConfig = SimulationConfig.debugConfig();

// 生产环境配置
final prodConfig = SimulationConfig.productionConfig();

// 自定义配置
final customConfig = SimulationConfig();
customConfig.enableStorageManagement = true;
customConfig.enableAntiDetection = true;
customConfig.debugMode = false;
```

### Cookie配置

```dart
final config = SimulationConfig();

// Cookie配置
config.cookieConfig.enablePersistence = true;
config.cookieConfig.maxCookieCount = 1000;
config.cookieConfig.defaultExpirationTime = 86400 * 30; // 30天
config.cookieConfig.autoCleanupExpired = true;
config.cookieConfig.cleanupCheckInterval = 3600; // 1小时
```

### LocalStorage配置

```dart
// LocalStorage配置
config.localStorageConfig.enabled = true;
config.localStorageConfig.maxStorageSize = 10 * 1024 * 1024; // 10MB
config.localStorageConfig.maxKeySize = 1024; // 1KB
config.localStorageConfig.maxValueSize = 1024 * 1024; // 1MB
config.localStorageConfig.compressData = true;
```

### SessionStorage配置

```dart
// SessionStorage配置
config.sessionStorageConfig.enabled = true;
config.sessionStorageConfig.maxStorageSize = 5 * 1024 * 1024; // 5MB
config.sessionStorageConfig.sessionTimeout = 1800; // 30分钟
```

## 存储统计

```dart
// 获取存储统计信息
final stats = storageManager.getStorageStats();
print('存储统计: $stats');

// 获取总存储大小
final totalSize = storageManager.getTotalStorageSize();
print('总大小: ${totalSize}字节');

// 获取Cookie数量
final cookieCount = storageManager.getCookieCount();
print('Cookie数量: $cookieCount');

// 获取仿真状态信息
final simulationInfo = _simulationManager!.getSimulationInfo();
print('仿真状态: $simulationInfo');
```

## JavaScript端使用

存储仿真代码注入后，网页中的JavaScript可以正常使用localStorage和sessionStorage：

```javascript
// 在网页中正常使用localStorage
localStorage.setItem('key', 'value');
const value = localStorage.getItem('key');
localStorage.removeItem('key');
localStorage.clear();

// 在网页中正常使用sessionStorage
sessionStorage.setItem('key', 'value');
const value = sessionStorage.getItem('key');
sessionStorage.removeItem('key');
sessionStorage.clear();

// 所有操作都会通过Flutter端的存储管理器处理
```

## 反检测功能

系统会自动注入以下反检测代码：

1. **隐藏WebDriver属性**：删除`navigator.webdriver`
2. **模拟浏览器插件**：提供真实的`navigator.plugins`
3. **模拟语言设置**：设置`navigator.languages`
4. **修改平台信息**：设置`navigator.platform`
5. **清理自动化标识**：删除Chrome DevTools协议相关属性

## 性能优化

### 内存管理

- Cookie使用内存缓存 + 持久化存储
- LocalStorage数据压缩存储
- SessionStorage仅在内存中保存
- 自动清理过期数据

### 异步处理

- 存储操作使用异步方法
- JavaScript注入不阻塞主线程
- 数据预加载在页面加载完成后进行

### 大小限制

- Cookie单个值最大1KB
- LocalStorage单个值最大1MB
- SessionStorage单个值最大512KB
- 总存储大小监控和限制

## 运行演示

```dart
import 'browser_simulation/examples/storage_demo.dart';

void runDemo() async {
  final demo = BrowserStorageDemo();
  await demo.runFullDemo();
}
```

演示包含：
- Cookie功能演示
- LocalStorage功能演示  
- SessionStorage功能演示
- 存储统计演示
- 配置功能演示
- 数据清理演示

## 注意事项

### 存储库选择

- **get_storage**：用于复杂数据存储（Cookie、LocalStorage）
  - 优点：性能好，支持复杂对象，JSON序列化
  - 适用：主要存储功能

- **shared_preferences**：用于简单配置存储
  - 优点：Flutter官方库，稳定性好
  - 适用：配置选项、简单键值对

### 安全考虑

1. Cookie支持HttpOnly和Secure标志
2. 存储大小限制防止内存溢出
3. 数据验证防止注入攻击
4. 自动清理过期数据

### 兼容性

- 支持Android和iOS平台
- 兼容flutter_inappwebview 6.0+
- 需要Flutter 3.0+

## 故障排除

### 常见问题

1. **存储数据丢失**
   - 检查GetStorage初始化
   - 确认权限设置正确

2. **JavaScript注入失败**
   - 确认WebView创建成功
   - 检查JavaScript执行权限

3. **Cookie同步问题**
   - 确认CookieManager初始化
   - 检查域名和路径设置

### 调试模式

```dart
final config = SimulationConfig.debugConfig();
config.verboseLogging = true;
config.logNetworkRequests = true;
```

启用调试模式后会输出详细的日志信息，帮助定位问题。

## 🚨 知乎反爬虫问题解决方案

### 问题描述
当访问知乎网站时，可能会遇到HTTP 400错误，特别是知乎的API请求（如登录接口）。这是知乎严格的反爬虫系统导致的。

### 解决方案

#### 1. 智能错误处理
```dart
// 已实现：智能区分API错误和页面错误
// API错误不会影响主页面显示，只记录日志
void _handleHttpError(controller, request, errorResponse) {
  // 检查是否是API请求
  final isApiRequest = _isApiRequest(url);
  
  if (isApiRequest && !isMainFrameRequest) {
    // API错误不显示错误界面，让页面继续正常显示
    return;
  }
}
```

#### 2. 增强反检测功能
- ✅ 多阶段JavaScript注入
- ✅ 完整的navigator属性仿真
- ✅ WebDriver属性隐藏
- ✅ 知乎特定的反检测处理

#### 3. 请求头管理
```dart
// 针对不同网站的智能请求头生成
final headerManager = RequestHeaderManager(config);
final headers = headerManager.generateOptimizedHeaders('https://www.zhihu.com');
```

#### 4. 测试和验证
```dart
// 使用测试工具验证仿真效果
final tester = SimulationTester(simulationManager);
await tester.runFullTest(webViewController);
```

### 常见问题

**Q: 知乎登录接口返回400错误怎么办？**
A: 这是正常现象。知乎的登录API有严格的加密验证，但不影响页面内容的正常浏览。

**Q: 如何判断仿真是否生效？**
A: 查看日志输出，寻找"🛡️ 反检测代码已注入"等提示，或使用测试工具验证。

**Q: 页面显示空白或加载失败？**
A: 检查是否是主页面加载失败，还是只是API请求失败。API失败不会影响页面显示。

### 调试模式

启用详细日志来调试反爬虫问题：

```dart
final config = SimulationConfig.debugConfig();
config.verboseLogging = true;
```

## 后续扩展

### 已实现功能
- ✅ **存储管理**：Cookie、LocalStorage、SessionStorage
- ✅ **基础反检测**：WebDriver隐藏、插件仿真
- ✅ **增强反检测**：多阶段JavaScript注入
- ✅ **请求头管理**：网站特定的请求头优化
- ✅ **智能错误处理**：区分API错误和页面错误
- ✅ **测试工具**：验证仿真效果

### 计划中功能
1. **设备指纹仿真**：Canvas、WebGL、字体检测等
2. **行为仿真**：鼠标移动、滚动行为、点击模拟
3. **网络请求优化**：请求时序、并发控制、资源拦截
4. **高级反检测**：WebRTC保护、时间随机化等

每个功能都会采用模块化设计，可以独立启用或禁用。 
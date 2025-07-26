import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../../../basics/logger.dart';
import '../identity/storage_manager.dart';

/// JavaScript注入工具
/// 用于在WebView中注入存储仿真和反检测代码
class JSInjector {
  final BrowserStorageManager storageManager;
  
  JSInjector(this.storageManager);

  /// 注入存储仿真代码
  Future<void> injectStorageSimulation(InAppWebViewController controller) async {
    try {
      getLogger().i('💉 开始注入存储仿真代码...');
      
      // 注入LocalStorage仿真
      await _injectLocalStorageSimulation(controller);
      
      // 注入SessionStorage仿真
      await _injectSessionStorageSimulation(controller);
      
      // 注入存储事件监听
      await _injectStorageEventListeners(controller);

      // 预加载存储数据
      await preloadStorageData(controller);
      
      getLogger().i('✅ 存储仿真代码注入完成');
    } catch (e) {
      getLogger().e('❌ 注入存储仿真代码失败: $e');
    }
  }
  
  /// 注入LocalStorage仿真
  Future<void> _injectLocalStorageSimulation(InAppWebViewController controller) async {
    final jsCode = '''
    (function() {
      // 保存原始LocalStorage引用
      const originalLocalStorage = window.localStorage;
      
      // 创建自定义LocalStorage实现
      const customLocalStorage = {
        _data: {},
        
        getItem: function(key) {
          // 通过原生桥接获取数据
          window.flutter_inappwebview.callHandler('getLocalStorageItem', key)
            .then(value => {
              if (value !== null) {
                this._data[key] = value;
              }
            });
          return this._data[key] || null;
        },
        
        setItem: function(key, value) {
          this._data[key] = String(value);
          // 通过原生桥接保存数据
          window.flutter_inappwebview.callHandler('setLocalStorageItem', {
            key: key,
            value: String(value)
          });
        },
        
        removeItem: function(key) {
          delete this._data[key];
          // 通过原生桥接删除数据
          window.flutter_inappwebview.callHandler('removeLocalStorageItem', key);
        },
        
        clear: function() {
          this._data = {};
          // 通过原生桥接清空数据
          window.flutter_inappwebview.callHandler('clearLocalStorage');
        },
        
        key: function(index) {
          const keys = Object.keys(this._data);
          return keys[index] || null;
        },
        
        get length() {
          return Object.keys(this._data).length;
        }
      };
      
      // 替换原始LocalStorage
      Object.defineProperty(window, 'localStorage', {
        value: customLocalStorage,
        writable: false,
        configurable: false
      });
      
      console.log('✅ LocalStorage仿真已注入');
    })();
    ''';
    
    await controller.evaluateJavascript(source: jsCode);
  }
  
  /// 注入SessionStorage仿真
  Future<void> _injectSessionStorageSimulation(InAppWebViewController controller) async {
    final jsCode = '''
    (function() {
      // 保存原始SessionStorage引用
      const originalSessionStorage = window.sessionStorage;
      
      // 创建自定义SessionStorage实现
      const customSessionStorage = {
        _data: {},
        
        getItem: function(key) {
          // 通过原生桥接获取数据
          window.flutter_inappwebview.callHandler('getSessionStorageItem', key)
            .then(value => {
              if (value !== null) {
                this._data[key] = value;
              }
            });
          return this._data[key] || null;
        },
        
        setItem: function(key, value) {
          this._data[key] = String(value);
          // 通过原生桥接保存数据
          window.flutter_inappwebview.callHandler('setSessionStorageItem', {
            key: key,
            value: String(value)
          });
        },
        
        removeItem: function(key) {
          delete this._data[key];
          // 通过原生桥接删除数据
          window.flutter_inappwebview.callHandler('removeSessionStorageItem', key);
        },
        
        clear: function() {
          this._data = {};
          // 通过原生桥接清空数据
          window.flutter_inappwebview.callHandler('clearSessionStorage');
        },
        
        key: function(index) {
          const keys = Object.keys(this._data);
          return keys[index] || null;
        },
        
        get length() {
          return Object.keys(this._data).length;
        }
      };
      
      // 替换原始SessionStorage
      Object.defineProperty(window, 'sessionStorage', {
        value: customSessionStorage,
        writable: false,
        configurable: false
      });
      
      console.log('✅ SessionStorage仿真已注入');
    })();
    ''';
    
    await controller.evaluateJavascript(source: jsCode);
  }
  
  /// 注入存储事件监听
  Future<void> _injectStorageEventListeners(InAppWebViewController controller) async {
    final jsCode = '''
    (function() {
      // 监听存储变化事件
      const originalDispatchEvent = window.dispatchEvent;
      
      // 重写dispatchEvent以拦截storage事件
      window.dispatchEvent = function(event) {
        if (event.type === 'storage') {
          // 通过原生桥接报告存储事件
          window.flutter_inappwebview.callHandler('onStorageEvent', {
            key: event.key,
            oldValue: event.oldValue,
            newValue: event.newValue,
            url: event.url,
            storageArea: event.storageArea === localStorage ? 'localStorage' : 'sessionStorage'
          });
        }
        return originalDispatchEvent.call(this, event);
      };
      
      console.log('✅ 存储事件监听已注入');
    })();
    ''';
    
    await controller.evaluateJavascript(source: jsCode);
  }
  
  /// 设置JavaScript处理器
  Future<void> setupJavaScriptHandlers(InAppWebViewController controller) async {
    try {
      getLogger().i('🔗 设置JavaScript处理器...');
      
      // LocalStorage处理器
      controller.addJavaScriptHandler(
        handlerName: 'getLocalStorageItem',
        callback: (args) async {
          final key = args.isNotEmpty ? args[0] as String : '';
          return storageManager.getLocalStorageItem(key);
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'setLocalStorageItem',
        callback: (args) async {
          if (args.isNotEmpty && args[0] is Map) {
            final data = args[0] as Map<String, dynamic>;
            final key = data['key'] as String;
            final value = data['value'] as String;
            await storageManager.setLocalStorageItem(key, value);
          }
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'removeLocalStorageItem',
        callback: (args) async {
          final key = args.isNotEmpty ? args[0] as String : '';
          await storageManager.removeLocalStorageItem(key);
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'clearLocalStorage',
        callback: (args) async {
          await storageManager.clearLocalStorage();
        },
      );
      
      // SessionStorage处理器
      controller.addJavaScriptHandler(
        handlerName: 'getSessionStorageItem',
        callback: (args) async {
          final key = args.isNotEmpty ? args[0] as String : '';
          return storageManager.getSessionStorageItem(key);
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'setSessionStorageItem',
        callback: (args) async {
          if (args.isNotEmpty && args[0] is Map) {
            final data = args[0] as Map<String, dynamic>;
            final key = data['key'] as String;
            final value = data['value'] as String;
            storageManager.setSessionStorageItem(key, value);
          }
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'removeSessionStorageItem',
        callback: (args) async {
          final key = args.isNotEmpty ? args[0] as String : '';
          storageManager.removeSessionStorageItem(key);
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'clearSessionStorage',
        callback: (args) async {
          storageManager.clearSessionStorage();
        },
      );
      
      // 存储事件处理器
      controller.addJavaScriptHandler(
        handlerName: 'onStorageEvent',
        callback: (args) async {
          if (args.isNotEmpty && args[0] is Map) {
            final data = args[0] as Map<String, dynamic>;
            getLogger().d('📊 存储事件: ${data['storageArea']} - ${data['key']}');
          }
        },
      );
      
      getLogger().i('✅ JavaScript处理器设置完成');
    } catch (e) {
      getLogger().e('❌ 设置JavaScript处理器失败: $e');
    }
  }
  
  /// 注入反检测代码（增强版本）
  Future<void> injectAntiDetectionCode(InAppWebViewController controller) async {
    try {
      getLogger().i('🛡️ 开始注入增强反检测代码...');
      
      // 分多个阶段注入，确保稳定性
      await _injectBasicAntiDetection(controller);
      await _injectAdvancedAntiDetection(controller);
      await _injectZhihuSpecificAntiDetection(controller);
      
      getLogger().i('✅ 增强反检测代码注入完成');
    } catch (e) {
      getLogger().e('❌ 注入反检测代码失败: $e');
    }
  }

  /// 注入基础反检测代码
  Future<void> _injectBasicAntiDetection(InAppWebViewController controller) async {
    final jsCode = '''
    (function() {
      // 1. 隐藏WebDriver属性
      Object.defineProperty(navigator, 'webdriver', {
        get: () => undefined,
        configurable: false
      });
      
      // 2. 模拟真实浏览器插件
      Object.defineProperty(navigator, 'plugins', {
        get: () => [
          {
            name: 'Chrome PDF Plugin',
            filename: 'internal-pdf-viewer',
            description: 'Portable Document Format',
            length: 1,
            0: { type: 'application/x-google-chrome-pdf', suffixes: 'pdf' }
          },
          {
            name: 'Chrome PDF Viewer',
            filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai',
            description: '',
            length: 1,
            0: { type: 'application/pdf', suffixes: 'pdf' }
          },
          {
            name: 'Native Client',
            filename: 'internal-nacl-plugin',
            description: '',
            length: 2,
            0: { type: 'application/x-nacl', suffixes: '' },
            1: { type: 'application/x-pnacl', suffixes: '' }
          }
        ],
        configurable: false
      });
      
      // 3. 完善语言设置
      Object.defineProperty(navigator, 'languages', {
        get: () => ['zh-CN', 'zh', 'en'],
        configurable: false
      });
      
      Object.defineProperty(navigator, 'language', {
        get: () => 'zh-CN',
        configurable: false
      });
      
      // 4. 硬件信息仿真
      Object.defineProperty(navigator, 'hardwareConcurrency', {
        get: () => 8,
        configurable: false
      });
      
      Object.defineProperty(navigator, 'deviceMemory', {
        get: () => 8,
        configurable: false
      });
      
      // 5. 平台信息
      Object.defineProperty(navigator, 'platform', {
        get: () => 'Win32',
        configurable: false
      });
      
      Object.defineProperty(navigator, 'userAgentData', {
        get: () => ({
          brands: [
            { brand: 'Not_A Brand', version: '8' },
            { brand: 'Chromium', version: '120' },
            { brand: 'Google Chrome', version: '120' }
          ],
          mobile: false,
          platform: 'Windows'
        }),
        configurable: false
      });
      
      console.log('🛡️ 基础反检测代码已注入');
    })();
    ''';
    
    await controller.evaluateJavascript(source: jsCode);
  }

  /// 注入高级反检测代码
  Future<void> _injectAdvancedAntiDetection(InAppWebViewController controller) async {
    final jsCode = '''
    (function() {
      // 1. 清理自动化标识
      delete window.cdc_adoQpoasnfa76pfcZLmcfl_Array;
      delete window.cdc_adoQpoasnfa76pfcZLmcfl_Promise;
      delete window.cdc_adoQpoasnfa76pfcZLmcfl_Symbol;
      delete window.callPhantom;
      delete window._phantom;
      delete window.__phantom;
      delete window.phantom;
      
      // 2. 修复权限查询
      if (navigator.permissions && navigator.permissions.query) {
        const originalQuery = navigator.permissions.query;
        navigator.permissions.query = function(parameters) {
          return parameters.name === 'notifications' 
            ? Promise.resolve({ state: Notification.permission })
            : originalQuery.apply(this, arguments);
        };
      }
      
      // 3. 重写控制台检测
      const originalConsole = window.console;
      Object.defineProperty(window, 'console', {
        get: () => originalConsole,
        set: () => {},
        configurable: false
      });
      
      // 4. 修复时间戳检测
      const originalDate = Date;
      const originalNow = Date.now;
      const originalGetTime = Date.prototype.getTime;
      
      // 添加微小的随机延迟
      Date.now = function() {
        return originalNow.call(this) + Math.floor(Math.random() * 2);
      };
      
      Date.prototype.getTime = function() {
        return originalGetTime.call(this) + Math.floor(Math.random() * 2);
      };
      
      // 5. iframe检测绕过
      Object.defineProperty(window, 'top', {
        get: () => window,
        configurable: false
      });
      
      Object.defineProperty(window, 'frameElement', {
        get: () => null,
        configurable: false
      });
      
      // 6. 修复getParameter检测
      if (WebGLRenderingContext && WebGLRenderingContext.prototype.getParameter) {
        const originalGetParameter = WebGLRenderingContext.prototype.getParameter;
        WebGLRenderingContext.prototype.getParameter = function(parameter) {
          if (parameter === 37445) { // UNMASKED_VENDOR_WEBGL
            return 'Intel Inc.';
          }
          if (parameter === 37446) { // UNMASKED_RENDERER_WEBGL
            return 'Intel(R) Iris(R) Xe Graphics';
          }
          return originalGetParameter.call(this, parameter);
        };
      }
      
      console.log('🛡️ 高级反检测代码已注入');
    })();
    ''';
    
    await controller.evaluateJavascript(source: jsCode);
  }

  /// 注入知乎特定反检测代码
  Future<void> _injectZhihuSpecificAntiDetection(InAppWebViewController controller) async {
    final jsCode = '''
    (function() {
      // 知乎特定的反检测处理
      
      // 1. 模拟正常的鼠标事件
      let lastMouseMove = Date.now();
      document.addEventListener('mousemove', function() {
        lastMouseMove = Date.now();
      });
      
      // 2. 模拟页面可见性
      Object.defineProperty(document, 'hidden', {
        get: () => false,
        configurable: false
      });
      
      Object.defineProperty(document, 'visibilityState', {
        get: () => 'visible',
        configurable: false
      });
      
      // 3. 模拟正常的窗口焦点
      Object.defineProperty(document, 'hasFocus', {
        value: () => true,
        configurable: false
      });
      
      // 4. 禁用某些检测函数
      if (window.chrome && window.chrome.runtime) {
        delete window.chrome.runtime.onConnect;
        delete window.chrome.runtime.onMessage;
      }
      
      // 5. 修复Image对象检测
      const originalImage = window.Image;
      window.Image = function(width, height) {
        const img = new originalImage(width, height);
        // 模拟正常的加载时间
        setTimeout(() => {
          if (img.onload) img.onload();
        }, Math.random() * 100 + 50);
        return img;
      };
      
      // 6. 修复fetch检测
      if (window.fetch) {
        const originalFetch = window.fetch;
        window.fetch = function(...args) {
          // 添加微小延迟模拟网络请求
          return new Promise(resolve => {
            setTimeout(() => {
              resolve(originalFetch.apply(this, args));
            }, Math.random() * 10 + 5);
          });
        };
      }
      
      console.log('🛡️ 知乎特定反检测代码已注入');
    })();
    ''';
    
    await controller.evaluateJavascript(source: jsCode);
  }
  
  /// 预加载存储数据到JavaScript环境
  Future<void> preloadStorageData(InAppWebViewController controller) async {
    try {
      getLogger().i('📥 预加载存储数据到JavaScript环境...');
      
      // 预加载LocalStorage数据
      final localStorageKeys = storageManager.getLocalStorageKeys();
      for (final key in localStorageKeys) {
        final value = storageManager.getLocalStorageItem(key);
        if (value != null) {
          await controller.evaluateJavascript(source: '''
            localStorage._data['$key'] = `$value`;
          ''');
        }
      }
      
      // 预加载SessionStorage数据
      final sessionStorageKeys = storageManager.getSessionStorageKeys();
      for (final key in sessionStorageKeys) {
        final value = storageManager.getSessionStorageItem(key);
        if (value != null) {
          await controller.evaluateJavascript(source: '''
            sessionStorage._data['$key'] = `$value`;
          ''');
        }
      }
      
      getLogger().i('✅ 存储数据预加载完成 - LocalStorage: ${localStorageKeys.length}, SessionStorage: ${sessionStorageKeys.length}');
    } catch (e) {
      getLogger().e('❌ 预加载存储数据失败: $e');
    }
  }
} 
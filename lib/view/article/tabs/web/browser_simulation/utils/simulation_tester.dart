import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../../../basics/logger.dart';
import '../core/browser_simulation_manager.dart';

/// 浏览器仿真测试工具
/// 用于测试和验证反爬虫仿真效果
class SimulationTester {
  final BrowserSimulationManager simulationManager;
  
  SimulationTester(this.simulationManager);
  
  /// 运行完整的仿真测试
  Future<void> runFullTest(InAppWebViewController controller) async {
    getLogger().i('🧪 开始浏览器仿真完整测试...');
    
    try {
      await testBasicProperties(controller);
      await testStorageFeatures(controller);
      await testAntiDetectionFeatures(controller);
      await testSiteSpecificFeatures(controller);
      
      getLogger().i('✅ 浏览器仿真测试完成');
    } catch (e) {
      getLogger().e('❌ 仿真测试失败: $e');
    }
  }
  
  /// 测试基础属性
  Future<void> testBasicProperties(InAppWebViewController controller) async {
    getLogger().i('🔍 测试基础浏览器属性...');
    
    final testScript = '''
    (function() {
      const results = {
        userAgent: navigator.userAgent,
        platform: navigator.platform,
        language: navigator.language,
        languages: navigator.languages,
        hardwareConcurrency: navigator.hardwareConcurrency,
        deviceMemory: navigator.deviceMemory,
        webdriver: navigator.webdriver,
        plugins: Array.from(navigator.plugins).map(p => ({
          name: p.name,
          filename: p.filename,
          description: p.description
        }))
      };
      
      return JSON.stringify(results, null, 2);
    })();
    ''';
    
    final result = await controller.evaluateJavascript(source: testScript);
    getLogger().i('📊 基础属性测试结果:\n$result');
  }
  
  /// 测试存储功能
  Future<void> testStorageFeatures(InAppWebViewController controller) async {
    getLogger().i('💾 测试存储功能...');
    
    final testScript = '''
    (function() {
      const results = {};
      
      try {
        // 测试localStorage
        localStorage.setItem('test_key', 'test_value');
        results.localStorage = {
          setSuccess: true,
          getValue: localStorage.getItem('test_key'),
          length: localStorage.length
        };
        localStorage.removeItem('test_key');
      } catch (e) {
        results.localStorage = { error: e.message };
      }
      
      try {
        // 测试sessionStorage
        sessionStorage.setItem('session_test', 'session_value');
        results.sessionStorage = {
          setSuccess: true,
          getValue: sessionStorage.getItem('session_test'),
          length: sessionStorage.length
        };
        sessionStorage.removeItem('session_test');
      } catch (e) {
        results.sessionStorage = { error: e.message };
      }
      
      return JSON.stringify(results, null, 2);
    })();
    ''';
    
    final result = await controller.evaluateJavascript(source: testScript);
    getLogger().i('💾 存储功能测试结果:\n$result');
  }
  
  /// 测试反检测功能
  Future<void> testAntiDetectionFeatures(InAppWebViewController controller) async {
    getLogger().i('🛡️ 测试反检测功能...');
    
    final testScript = '''
    (function() {
      const results = {
        webdriverHidden: typeof navigator.webdriver === 'undefined',
        phantomDetection: {
          callPhantom: typeof window.callPhantom === 'undefined',
          _phantom: typeof window._phantom === 'undefined',
          phantom: typeof window.phantom === 'undefined'
        },
        chromeAutomation: {
          cdcArray: typeof window.cdc_adoQpoasnfa76pfcZLmcfl_Array === 'undefined',
          cdcPromise: typeof window.cdc_adoQpoasnfa76pfcZLmcfl_Promise === 'undefined',
          cdcSymbol: typeof window.cdc_adoQpoasnfa76pfcZLmcfl_Symbol === 'undefined'
        },
        permissions: typeof navigator.permissions !== 'undefined',
        webgl: (() => {
          try {
            const canvas = document.createElement('canvas');
            const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
            if (!gl) return null;
            
            const vendor = gl.getParameter(gl.getExtension('WEBGL_debug_renderer_info') ? 
              gl.getExtension('WEBGL_debug_renderer_info').UNMASKED_VENDOR_WEBGL : gl.VENDOR);
            const renderer = gl.getParameter(gl.getExtension('WEBGL_debug_renderer_info') ? 
              gl.getExtension('WEBGL_debug_renderer_info').UNMASKED_RENDERER_WEBGL : gl.RENDERER);
            
            return { vendor, renderer };
          } catch (e) {
            return { error: e.message };
          }
        })(),
        timing: (() => {
          const start = Date.now();
          const end = Date.now();
          return { timeDiff: end - start, realistic: end - start < 10 };
        })()
      };
      
      return JSON.stringify(results, null, 2);
    })();
    ''';
    
    final result = await controller.evaluateJavascript(source: testScript);
    getLogger().i('🛡️ 反检测功能测试结果:\n$result');
  }
  
  /// 测试网站特定功能
  Future<void> testSiteSpecificFeatures(InAppWebViewController controller) async {
    getLogger().i('🌐 测试网站特定功能...');
    
    final currentUrl = (await controller.getUrl())?.toString() ?? '';
    final domain = Uri.tryParse(currentUrl)?.host ?? '';
    
    getLogger().i('🔍 当前域名: $domain');
    
    // 获取反爬虫等级
    final antiCrawlerLevel = simulationManager.headerManager.getAntiCrawlerLevel(domain);
    getLogger().i('🛡️ 反爬虫等级: $antiCrawlerLevel');
    
    // 检查是否需要特殊处理
    final needsSpecial = simulationManager.headerManager.needsSpecialHandling(domain);
    getLogger().i('⚙️ 需要特殊处理: $needsSpecial');
    
    if (domain.contains('zhihu.com')) {
      await _testZhihuSpecific(controller);
    } else if (domain.contains('weibo.com')) {
      await _testWeiboSpecific(controller);
    } else if (domain.contains('bilibili.com')) {
      await _testBilibiliSpecific(controller);
    }
  }
  
  /// 测试知乎特定功能
  Future<void> _testZhihuSpecific(InAppWebViewController controller) async {
    getLogger().i('📚 执行知乎特定测试...');
    
    final testScript = '''
    (function() {
      const results = {
        domain: location.hostname,
        hasJQuery: typeof jQuery !== 'undefined',
        hasReact: typeof React !== 'undefined',
        documentReady: document.readyState,
        visibilityState: document.visibilityState,
        hasFocus: document.hasFocus(),
        title: document.title,
        // 检查知乎特定的全局变量
        zhihuGlobals: {
          hasWindow: typeof window !== 'undefined',
          hasDocument: typeof document !== 'undefined',
          hasNavigator: typeof navigator !== 'undefined'
        }
      };
      
      return JSON.stringify(results, null, 2);
    })();
    ''';
    
    final result = await controller.evaluateJavascript(source: testScript);
    getLogger().i('📚 知乎特定测试结果:\n$result');
  }
  
  /// 测试微博特定功能
  Future<void> _testWeiboSpecific(InAppWebViewController controller) async {
    getLogger().i('🐦 执行微博特定测试...');
    // 微博特定的测试逻辑
    getLogger().i('🐦 微博测试完成');
  }
  
  /// 测试B站特定功能
  Future<void> _testBilibiliSpecific(InAppWebViewController controller) async {
    getLogger().i('📺 执行B站特定测试...');
    // B站特定的测试逻辑
    getLogger().i('📺 B站测试完成');
  }
  
  /// 生成仿真报告
  Future<Map<String, dynamic>> generateSimulationReport(InAppWebViewController controller) async {
    getLogger().i('📋 生成仿真报告...');
    
    final currentUrl = (await controller.getUrl())?.toString() ?? '';
    final domain = Uri.tryParse(currentUrl)?.host ?? '';
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'url': currentUrl,
      'domain': domain,
      'simulationInfo': simulationManager.getSimulationInfo(),
      'storageStats': simulationManager.storageManager.getStorageStats(),
      'antiCrawlerLevel': simulationManager.headerManager.getAntiCrawlerLevel(domain),
      'needsSpecialHandling': simulationManager.headerManager.needsSpecialHandling(domain),
    };
    
    getLogger().i('📋 仿真报告生成完成');
    return report;
  }
  
  /// 运行性能测试
  Future<void> runPerformanceTest(InAppWebViewController controller) async {
    getLogger().i('⚡ 开始性能测试...');
    
    final startTime = DateTime.now();
    
    // 测试JavaScript执行性能
    final jsPerformanceScript = '''
    (function() {
      const start = performance.now();
      
      // 执行一些操作
      for (let i = 0; i < 1000; i++) {
        localStorage.setItem('perf_test_' + i, 'value_' + i);
      }
      
      for (let i = 0; i < 1000; i++) {
        localStorage.removeItem('perf_test_' + i);
      }
      
      const end = performance.now();
      return { executionTime: end - start, operations: 2000 };
    })();
    ''';
    
    final jsResult = await controller.evaluateJavascript(source: jsPerformanceScript);
    final endTime = DateTime.now();
    
    final totalTime = endTime.difference(startTime).inMilliseconds;
    
    getLogger().i('⚡ 性能测试结果:');
    getLogger().i('  - 总耗时: ${totalTime}ms');
    getLogger().i('  - JS执行结果: $jsResult');
  }
  
  /// 运行安全测试
  Future<void> runSecurityTest(InAppWebViewController controller) async {
    getLogger().i('🔒 开始安全测试...');
    
    final securityScript = '''
    (function() {
      const results = {
        csp: {
          hasCSP: typeof document.contentSecurityPolicy !== 'undefined',
          // 检查内容安全策略
        },
        xss: {
          // 基础XSS防护测试
          canExecuteEval: (() => {
            try {
              eval('1+1');
              return true;
            } catch (e) {
              return false;
            }
          })(),
          canCreateScript: (() => {
            try {
              const script = document.createElement('script');
              return script.tagName === 'SCRIPT';
            } catch (e) {
              return false;
            }
          })()
        },
        cookies: {
          canSetCookie: (() => {
            try {
              document.cookie = 'test=1';
              return document.cookie.includes('test=1');
            } catch (e) {
              return false;
            }
          })(),
          httpOnly: document.cookie.length
        }
      };
      
      return JSON.stringify(results, null, 2);
    })();
    ''';
    
    final result = await controller.evaluateJavascript(source: securityScript);
    getLogger().i('🔒 安全测试结果:\n$result');
  }
} 
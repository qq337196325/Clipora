import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../basics/logger.dart';

/// WebView池管理器 - 专门用于在线Web页面的性能优化
class WebWebViewPoolManager {
  static final WebWebViewPoolManager _instance = WebWebViewPoolManager._internal();
  factory WebWebViewPoolManager() => _instance;
  WebWebViewPoolManager._internal();

  // 预热状态
  bool _isInitialized = false;
  bool _isInitializing = false;

  // 预缓存的配置和脚本
  InAppWebViewSettings? _cachedSettings;
  String? _cachedCorsScript;
  List<UserScript>? _cachedUserScripts;

  /// 初始化Web页面优化资源
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    getLogger().i('🌐 开始预热Web页面优化资源...');
    
    try {
      _preloadWebViewConfiguration();
      _isInitialized = true;
      getLogger().i('✅ Web页面优化资源预热完成');
    } catch (e) {
      getLogger().e('❌ Web页面优化资源预热失败: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// 预加载WebView配置和脚本
  void _preloadWebViewConfiguration() {
    getLogger().i('📦 预加载Web页面配置...');
    
    // 预缓存WebView设置
    _cachedSettings = _createOptimizedWebViewSettings();
    
    // 预缓存CORS处理脚本
    _cachedCorsScript = _generateOptimizedCorsScript();
    
    // 预缓存用户脚本
    _cachedUserScripts = [
      UserScript(
        source: _cachedCorsScript!,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
    ];
    
    getLogger().i('✅ Web页面配置预加载完成');
  }

  /// 获取优化的WebView设置
  InAppWebViewSettings getOptimizedSettings() {
    return _cachedSettings ?? _createOptimizedWebViewSettings();
  }

  /// 获取预缓存的用户脚本
  List<UserScript> getOptimizedUserScripts() {
    return _cachedUserScripts ?? [];
  }

  /// 快速设置WebView（适用于在线页面）
  Future<void> setupOptimizedWebView(InAppWebViewController controller) async {
    if (!_isInitialized) {
      await initialize();
    }

    getLogger().i('🎯 开始快速设置Web页面WebView...');
    
    try {
      // 预注入性能优化脚本
      await _injectPerformanceScripts(controller);
      
      getLogger().i('🚀 Web页面WebView快速设置完成');
    } catch (e) {
      getLogger().e('❌ Web页面WebView快速设置失败: $e');
      rethrow;
    }
  }

  /// 注入性能优化脚本
  Future<void> _injectPerformanceScripts(InAppWebViewController controller) async {
    final List<Future> injectionFutures = [];

    // 注入页面优化脚本
    injectionFutures.add(
      controller.evaluateJavascript(source: '''
        (function() {
          console.log('🔧 注入页面性能优化脚本...');
          
          // 优化图片加载
          function optimizeImages() {
            const images = document.querySelectorAll('img');
            images.forEach(img => {
              // 添加懒加载
              if (!img.hasAttribute('loading')) {
                img.setAttribute('loading', 'lazy');
              }
              
              // 优化图片样式
              img.style.maxWidth = '100%';
              img.style.height = 'auto';
            });
          }
          
          // 页面加载完成后优化
          if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', optimizeImages);
          } else {
            optimizeImages();
          }
          
          // 监听动态添加的图片
          const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList') {
                mutation.addedNodes.forEach(function(node) {
                  if (node.nodeType === 1 && node.tagName === 'IMG') {
                    node.style.maxWidth = '100%';
                    node.style.height = 'auto';
                    if (!node.hasAttribute('loading')) {
                      node.setAttribute('loading', 'lazy');
                    }
                  }
                });
              }
            });
          });
          
          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
          
          console.log('✅ 页面性能优化脚本注入完成');
        })();
      ''').then((_) => getLogger().d('✅ 页面优化脚本注入完成'))
    );

    // 注入移动端适配脚本
    injectionFutures.add(
      controller.evaluateJavascript(source: '''
        (function() {
          console.log('📱 注入移动端适配脚本...');
          
          // 强制设置移动端视口meta标签
          function setMobileViewport() {
            // 移除所有现有的viewport标签
            const existingViewports = document.querySelectorAll('meta[name="viewport"]');
            existingViewports.forEach(vp => vp.remove());
            
            // 添加新的优化viewport标签
            const viewport = document.createElement('meta');
            viewport.name = 'viewport';
            viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, shrink-to-fit=no';
            document.head.appendChild(viewport);
          }
          
          // 强制移动端布局适配
          function forceMobileLayout() {
            // 添加CSS样式来强制移动端布局
            const style = document.createElement('style');
            style.innerHTML = `
              html, body {
                width: 100% !important;
                max-width: 100% !important;
                overflow-x: hidden !important;
                -webkit-overflow-scrolling: touch !important;
              }
              
              * {
                max-width: 100% !important;
                box-sizing: border-box !important;
              }
              
              img, video, iframe, embed, object {
                max-width: 100% !important;
                height: auto !important;
              }
              
              table {
                width: 100% !important;
                table-layout: fixed !important;
              }
              
              pre, code {
                word-wrap: break-word !important;
                white-space: pre-wrap !important;
                overflow-x: auto !important;
              }
              
              /* 特殊处理一些常见的宽度问题 */
              .container, .content, .main, .wrapper, .layout {
                max-width: 100% !important;
                width: 100% !important;
              }
              
              /* 隐藏水平滚动条 */
              ::-webkit-scrollbar:horizontal {
                display: none !important;
              }
              
              /* 优化文本布局 */
              p, div, span, article, section {
                word-break: break-word !important;
                hyphens: auto !important;
              }
            `;
            document.head.appendChild(style);
          }
          
          // 动态监听和修复宽度问题
          function fixOverflowElements() {
            const elements = document.querySelectorAll('*');
            elements.forEach(el => {
              const styles = window.getComputedStyle(el);
              const width = parseInt(styles.width);
              const screenWidth = window.innerWidth;
              
              // 如果元素宽度超过屏幕宽度，进行修复
              if (width > screenWidth) {
                el.style.maxWidth = '100%';
                el.style.width = '100%';
                el.style.overflow = 'hidden';
              }
            });
          }
          
          // 页面加载时立即执行
          setMobileViewport();
          forceMobileLayout();
          
          // GPU和渲染优化 - 减少GPUAUX错误
          function optimizeGPURendering() {
            // 1. 优化滚动性能
            document.documentElement.style.transform = 'translateZ(0)';  // 启用硬件加速
            document.body.style.transform = 'translateZ(0)';
            
            // 2. 减少重绘和重排
            document.body.style.willChange = 'transform, opacity';
            
            // 3. 优化滚动事件
            let scrollTimeout;
            let isScrolling = false;
            
            window.addEventListener('scroll', function() {
              if (!isScrolling) {
                isScrolling = true;
                // 滚动开始时启用优化
                document.body.style.pointerEvents = 'none';
              }
              
              clearTimeout(scrollTimeout);
              scrollTimeout = setTimeout(function() {
                isScrolling = false;
                // 滚动结束时恢复正常
                document.body.style.pointerEvents = 'auto';
              }, 100);
            }, { passive: true });
            
            // 4. 内存优化
            if (window.gc && typeof window.gc === 'function') {
              // 定期清理JavaScript内存
              setTimeout(() => window.gc(), 5000);
            }
            
            console.log('✅ GPU渲染优化完成');
          }
          
          // 延迟执行GPU优化，避免与页面初始化冲突
          setTimeout(optimizeGPURendering, 200);
          
          // DOM加载完成后执行
          if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
              setTimeout(fixOverflowElements, 100);
            });
          } else {
            setTimeout(fixOverflowElements, 100);
          }
          
          // 监听窗口大小变化
          window.addEventListener('resize', function() {
            setTimeout(fixOverflowElements, 100);
          });
          
          // 监听DOM变化，动态修复新添加的元素
          const observer = new MutationObserver(function(mutations) {
            let shouldFix = false;
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                shouldFix = true;
              }
            });
            
            if (shouldFix) {
              setTimeout(fixOverflowElements, 50);
            }
          });
          
          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
          
          // 优化触摸事件
          document.addEventListener('touchstart', function() {}, { passive: true });
          document.addEventListener('touchmove', function() {}, { passive: true });
          
          // 禁用长按选择（避免意外选择）
          document.body.style.webkitUserSelect = 'none';
          document.body.style.webkitTouchCallout = 'none';
          
          console.log('✅ 移动端适配脚本注入完成');
        })();
      ''').then((_) => getLogger().d('✅ 移动端适配脚本注入完成'))
    );

    // 等待所有脚本注入完成
    await Future.wait(injectionFutures);
  }

  /// 创建优化的WebView设置
  InAppWebViewSettings _createOptimizedWebViewSettings() {
    return InAppWebViewSettings(
      // ==== 核心功能设置 ====
      javaScriptEnabled: true,
      domStorageEnabled: true,
      
      // ==== 网络和缓存设置 ====
      clearCache: false,
      cacheMode: CacheMode.LOAD_DEFAULT,
      
      // ==== 安全设置 ====
      allowFileAccess: true,
      allowContentAccess: true,
      
      // ==== CORS和跨域设置 ====
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      allowUniversalAccessFromFileURLs: true,
      allowFileAccessFromFileURLs: true,
      
      // ==== 用户代理 - 优化的移动版Chrome ====
      userAgent: "Mozilla/5.0 (Linux; Android 12; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 EdgA/120.0.0.0",
      
      // ==== 视口和缩放设置 - 关键修改点 ====
      supportZoom: false,  // 禁用缩放避免布局问题
      builtInZoomControls: false,  // 禁用内置缩放控件
      displayZoomControls: false,
      useWideViewPort: true,  // 使用宽视口
      loadWithOverviewMode: true,  // 自动适应屏幕宽度
      
      // ==== 初始缩放设置 - 新增 ====
      initialScale: 100,  // 设置初始缩放比例为100%
      
      // ==== 性能优化设置 ====
      blockNetworkImage: false,
      blockNetworkLoads: false,
      loadsImagesAutomatically: true,
      
      // ==== Cookie设置 ====
      thirdPartyCookiesEnabled: true,
      
      // ==== 媒体设置 ====
      mediaPlaybackRequiresUserGesture: false,
      
      // ==== 滚动条设置 - 关键修改点 ====
      verticalScrollBarEnabled: true,  // 保持垂直滚动条
      horizontalScrollBarEnabled: false,  // 禁用水平滚动条
      
      // ==== URL拦截设置 ====
      useShouldOverrideUrlLoading: true,
      
      // ==== GPU和渲染优化设置 - 新增 ====
      hardwareAcceleration: true,  // 启用硬件加速
      allowsInlineMediaPlayback: true,
      allowsAirPlayForMediaPlayback: false,
      
      // ==== 渲染优化 - 减少GPU缓冲区问题 ====
      disableDefaultErrorPage: false,
      supportMultipleWindows: false,  // 禁用多窗口减少资源占用
      
      // ==== 内存优化 ====
      minimumFontSize: 8,
      defaultFontSize: 16,
      defaultFixedFontSize: 13,
    );
  }

  /// 生成优化的CORS处理脚本
  String _generateOptimizedCorsScript() {
    return '''
    (function() {
      console.log('🔧 开始注入优化版CORS处理脚本...');
      
      // 性能监控
      const startTime = performance.now();
      
      // 重写fetch方法来处理CORS问题
      const originalFetch = window.fetch;
      window.fetch = function(url, options = {}) {
        if (typeof url === 'string') {
          // 针对常见API域名进行优化
          if (url.includes('api.juejin.cn') || 
              url.includes('api.toutiao.com') ||
              url.includes('api.douban.com')) {
            console.log('🌐 拦截API fetch请求:', url.substring(0, 100) + '...');
            
            options.mode = 'no-cors';
            options.credentials = 'include';
            options.headers = {
              ...options.headers,
              'User-Agent': navigator.userAgent,
              'Accept': '*/*',
              'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
              'X-Requested-With': 'XMLHttpRequest'
            };
          }
        }
        
        return originalFetch.call(this, url, options).catch(error => {
          console.warn('⚠️ Fetch请求失败，返回空响应:', error.message);
          return Promise.resolve(new Response('{"status":"ok","data":{}}', { 
            status: 200,
            headers: { 'Content-Type': 'application/json' }
          }));
        });
      };
      
      // 重写XMLHttpRequest
      const originalXHROpen = XMLHttpRequest.prototype.open;
      const originalXHRSend = XMLHttpRequest.prototype.send;
      
      XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
        this._url = url;
        this._method = method;
        this._startTime = performance.now();
        
        const result = originalXHROpen.call(this, method, url, async, user, password);
        
        if (typeof url === 'string' && (
          url.includes('api.juejin.cn') || 
          url.includes('api.toutiao.com') ||
          url.includes('api.douban.com')
        )) {
          console.log('🌐 拦截API XHR请求:', method, url.substring(0, 100) + '...');
          
          // 监听状态变化，提供更好的错误处理
          this.addEventListener('readystatechange', function() {
            if (this.readyState === 4) {
              const duration = performance.now() - this._startTime;
              if (this.status === 0) {
                console.log('🔄 XHR请求被CORS阻止，耗时:', duration.toFixed(2) + 'ms');
              } else {
                console.log('✅ XHR请求成功，状态:', this.status, '耗时:', duration.toFixed(2) + 'ms');
              }
            }
          });
        }
        
        return result;
      };
      
      XMLHttpRequest.prototype.send = function(data) {
        if (this._url && (
          this._url.includes('api.juejin.cn') || 
          this._url.includes('api.toutiao.com') ||
          this._url.includes('api.douban.com')
        )) {
          try {
            // 设置更多兼容性头部
            this.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            this.setRequestHeader('Accept', 'application/json, text/plain, */*');
          } catch(e) {
            console.warn('⚠️ 设置请求头失败:', e.message);
          }
        }
        return originalXHRSend.call(this, data);
      };
      
      // 拦截并优化页面中的资源加载
      const originalCreateElement = document.createElement;
      document.createElement = function(tagName) {
        const element = originalCreateElement.call(this, tagName);
        
        if (tagName.toLowerCase() === 'script') {
          // 为动态脚本添加错误处理
          element.addEventListener('error', function() {
            console.warn('⚠️ 脚本加载失败:', this.src);
          });
        } else if (tagName.toLowerCase() === 'img') {
          // 为动态图片添加优化
          element.style.maxWidth = '100%';
          element.style.height = 'auto';
          element.loading = 'lazy';
        }
        
        return element;
      };
      
      const endTime = performance.now();
      console.log('✅ 优化版CORS处理脚本注入完成，耗时:', (endTime - startTime).toFixed(2) + 'ms');
    })();
  ''';
  }

  /// 获取性能统计信息
  Map<String, dynamic> getPerformanceStats() {
    return {
      'isInitialized': _isInitialized,
      'hasOptimizedSettings': _cachedSettings != null,
      'hasCorsScript': _cachedCorsScript != null,
      'hasUserScripts': _cachedUserScripts != null && _cachedUserScripts!.isNotEmpty,
      'corsScriptSize': _cachedCorsScript?.length ?? 0,
    };
  }

  /// 检查是否已优化
  bool get isOptimized => _isInitialized && 
    _cachedSettings != null && 
    _cachedCorsScript != null && 
    _cachedUserScripts != null;
} 
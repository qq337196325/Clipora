import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/view/article/article_web/utils/auto_generate_utils.dart';
import 'package:clipora/view/article/article_web/utils/web_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'dart:io'; // 添加平台检测
import 'package:get/get.dart';

import '../../../basics/logger.dart';
import '../controller/article_controller.dart';
import 'browser_simulation/core/browser_simulation_manager.dart';
import 'browser_simulation/utils/js_injector.dart';


class ArticleWebWidget extends StatefulWidget {
  final Function(String)? onSnapshotCreated;
  final String? url;
  final int? articleId;  // 添加文章ID参数
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onMarkdownGenerated; // 添加 Markdown 生成成功回调
  
  const ArticleWebWidget({
    super.key,
    this.onSnapshotCreated,
    this.url,
    this.articleId,  // 添加文章ID参数
    this.onScroll,
    this.contentPadding = EdgeInsets.zero,
    this.onMarkdownGenerated, // 添加 Markdown 生成成功回调
  });

  @override
  State<ArticleWebWidget> createState() => ArticlePageState();
}


class ArticlePageState extends State<ArticleWebWidget> with ArticlePageBLoC {
  double _lastScrollY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 进度条
        if (isLoading)
          LinearProgressIndicator(
            value: loadingProgress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        // 错误信息显示
        if (hasError)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 
                   (isLoading ? kToolbarHeight : 0) - 
                   MediaQuery.of(context).padding.top - 
                   MediaQuery.of(context).padding.bottom,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.red[100]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 错误图标
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.red[500],
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 错误标题
                    Text(
                      '网页加载失败',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // 错误详情
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // 重试按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            hasError = false;
                            isLoading = true;
                          });
                          _retryLoadPage();
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          '重新加载',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // WebView
        if (!hasError)
          Expanded(
            child: InAppWebView(
              // 【初始化URL请求】: WebView启动时加载的第一个页面请求。
              initialUrlRequest: URLRequest(url: WebUri(articleController.articleUrl)),
              // 【初始化设置】: WebView的各项详细配置，通过下面的 _getWebViewSettings 方法统一定义。
              initialSettings: _getWebViewSettings(),
              // 【WebView创建完成回调】: 当WebView实例创建成功后调用，通常在这里获取WebView控制器。
              onWebViewCreated: (controller) async {
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
                
                // 设置浏览器仿真功能
                // await _setupBrowserSimulation(controller);

              },
              // 【页面开始加载回调】: 当一个页面开始加载时触发。
              onLoadStart: (controller, url) {
                getLogger().i('🌐 开始加载Web页面: $url');
                setState(() {
                  isLoading = true;

                  // 修复了一个bug：在预热跳转时，错误的URL（如zhihu://）可能导致错误页面闪现。
                  // 现在，只有在加载http/https协议时才重置错误状态。
                  if (url != null && (url.scheme == 'http' || url.scheme == 'https')) {
                    hasError = false;
                  }
                });
              },
              // 【页面加载完成回调】: 当一个页面加载结束后触发，是执行JS注入等操作的最佳时机。
              onLoadStop: (controller, url) async {

                if(hasError){
                  return;
                }


                getLogger().i('🌐 Web页面加载完成: $url');
                setState(() {
                  isLoading = false;
                });
                
                // 注入存储仿真代码
                await _injectStorageSimulation(controller);
                
                // 注入平台特定的反检测代码
                await _injectPlatformSpecificAntiDetection(controller);
                
                // 注入内边距和修复页面宽度
                final padding = widget.contentPadding.resolve(Directionality.of(context));
                controller.evaluateJavascript(source: '''
                  // 设置内边距
                  document.body.style.paddingTop = '${padding.top}px';
                  document.body.style.paddingBottom = '${padding.bottom}px';
                  document.body.style.paddingLeft = '${padding.left}px';
                  document.body.style.paddingRight = '${padding.right}px';
                  document.documentElement.style.scrollPaddingTop = '${padding.top}px';
                  
                  // 修复页面宽度和防止水平滚动
                  (function() {
                    console.log('🔧 开始修复页面宽度设置...');
                    
                    // 1. 设置或更新viewport meta标签
                    let viewport = document.querySelector('meta[name="viewport"]');
                    if (!viewport) {
                      viewport = document.createElement('meta');
                      viewport.name = 'viewport';
                      document.head.appendChild(viewport);
                    }
                    viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no';
                    
                    // 2. 强制设置HTML和body样式
                    const style = document.createElement('style');
                    style.textContent = `
                      html, body {
                        width: 100% !important;
                        max-width: 100% !important;
                        min-width: 100% !important;
                        overflow-x: hidden !important;
                        overflow-y: auto !important;
                        box-sizing: border-box !important;
                        margin: 0 !important;
                        padding: 0 !important;
                      }
                      
                      * {
                        max-width: 100% !important;
                        box-sizing: border-box !important;
                      }
                      
                      /* 防止图片和视频溢出 */
                      img, video, iframe, object, embed {
                        max-width: 100% !important;
                        height: auto !important;
                      }
                      
                      /* 防止表格溢出 */
                      table {
                        max-width: 100% !important;
                        table-layout: fixed !important;
                        word-wrap: break-word !important;
                      }
                      
                      /* 防止预格式化文本溢出 */
                      pre, code {
                        max-width: 100% !important;
                        overflow-x: auto !important;
                        word-wrap: break-word !important;
                        white-space: pre-wrap !important;
                      }
                      
                      /* 防止容器溢出 */
                      div, section, article, main, aside, nav, header, footer {
                        max-width: 100% !important;
                        overflow-x: hidden !important;
                      }
                    `;
                    document.head.appendChild(style);
                    
                    // 3. 重新应用内边距（确保样式重置后仍然生效）
                    document.body.style.paddingTop = '${padding.top}px';
                    document.body.style.paddingBottom = '${padding.bottom}px';
                    document.body.style.paddingLeft = '${padding.left}px';
                    document.body.style.paddingRight = '${padding.right}px';
                    
                    console.log('✅ 页面宽度修复完成');
                  })();
                ''');
                
                // 注入移动端弹窗处理脚本 - 恢复滚动功能
                await _injectMobilePopupHandler(controller);
                
                // 页面加载完成后进行优化设置
                finalizeWebPageOptimization(url,webViewController);
                
                // 检查是否是预热首页加载完成，如果是，则跳转到目标URL
                if (await _handleWarmupRedirect(url, webViewController!)) {
                  return; // 如果是预热跳转，则中止后续操作，等待目标页面加载
                }
                
                // 检查是否需要自动生成MHTML快照（异步执行，不阻塞主线程）
                generateMhtmlUtils.webViewController = webViewController;
                generateMhtmlUtils.checkAndGenerateSnapshotIfNeeded(
                  articleController: articleController,
                  onSnapshotCreated: widget.onSnapshotCreated,
                  onLoadingStateChanged: (loading) {
                    if (mounted) {
                      setState(() {
                        isLoading = loading;
                      });
                    }
                  },
                  mounted: mounted,
                  onMarkdownGenerated: widget.onMarkdownGenerated,
                ).catchError((e) {
                  getLogger().e('❌ 自动检查快照失败: $e');
                });
              },
              // 【加载进度变化回调】: 当页面加载进度更新时调用，可用于显示进度条。
              onProgressChanged: (controller, progress) {
                setState(() {
                  loadingProgress = progress / 100;
                });
              },
              // 【通用错误回调】: 捕获各种加载错误，如网络问题、SSL证书问题、未知URL协议等。
              onReceivedError: (controller, request, error) {
                _handleWebViewError(controller, request, error);
              },
              // 【HTTP错误回调】: 专门捕获HTTP层面的错误（如403, 404, 500等）。
              onReceivedHttpError: (controller, request, errorResponse) {
                _handleHttpError(controller, request, errorResponse);
              },
              // 【页面滚动回调】: 当用户在WebView中滚动页面时触发。
              onScrollChanged: (controller, x, y) {
                final scrollY = y.toDouble();
                // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
                if ((scrollY - _lastScrollY).abs() > 15) {
                  final direction = scrollY > _lastScrollY ? ScrollDirection.reverse : ScrollDirection.forward;
                  widget.onScroll?.call(direction, scrollY);
                  _lastScrollY = scrollY;
                }
              },
              // 【URL加载拦截回调】: 在WebView尝试加载任何新URL之前调用，可以决定是允许、取消还是交由其他应用处理。
              shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
              // 【资源请求拦截回调】: (已注释) 可以拦截页面中的所有资源请求（如图片, css, js），用于广告拦截或替换资源，功能强大但消耗性能。
              // shouldInterceptRequest: _handleAntiCrawlerResourceRequest,
            ),
          ),
      ],
    );
  }

  /// 优化的URL导航处理
  Future<NavigationActionPolicy> _handleOptimizedUrlNavigation(
    InAppWebViewController controller, 
    NavigationAction navigationAction
  ) async {
    final uri = navigationAction.request.url!;
    final url = uri.toString();
    
    getLogger().d('🌐 URL跳转拦截: $url');
    
    // 检查是否是自定义scheme（非http/https）
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      getLogger().w('⚠️ 拦截自定义scheme跳转: ${uri.scheme}://');
      return NavigationActionPolicy.CANCEL;
    }
    
    // 检查是否是应用内跳转scheme
    if (url.startsWith('snssdk') || 
        url.startsWith('sslocal') ||
        url.startsWith('toutiao') ||
        url.startsWith('newsarticle') ||
        url.startsWith('zhihu')) { // 明确拦截知乎的App拉起协议
      getLogger().w('⚠️ 拦截应用跳转scheme: $url');
      return NavigationActionPolicy.CANCEL;
    }
    
    // 允许正常的HTTP/HTTPS链接
    getLogger().d('✅ 允许正常HTTP跳转: $url');
    return NavigationActionPolicy.ALLOW;
  }

}



mixin ArticlePageBLoC on State<ArticleWebWidget> {

  final ArticleController articleController = Get.find<ArticleController>();
  GenerateMhtmlUtils generateMhtmlUtils = GenerateMhtmlUtils();

  // WebView控制器
  InAppWebViewController? webViewController;
  
  // 加载状态
  bool isLoading = true;
  double loadingProgress = 0.0;
  
  // 错误状态
  bool hasError = false;
  String errorMessage = '';

  // 重试计数器 - 记录每个URL的重试次数
  final Map<String, int> _retryCountMap = {};
  
  // 会话预热状态
  String? _urlToLoadAfterWarmup;
  final Map<String, bool> _warmupAttemptedForUrl = {};

  // 浏览器仿真管理器
  BrowserSimulationManager? _simulationManager;
  JSInjector? _jsInjector;

  @override
  void initState() {
    super.initState();
    _initializeBrowserSimulation();
  }

  /// 公共方法：供外部调用生成快照
  Future<void> createSnapshot() async {
    final filePath = await generateMhtmlUtils.generateSnapshot();
    if(filePath.isEmpty){
      BotToast.showText(text: '保存快照失败');
      return;
    }
    final updateStatus = await generateMhtmlUtils.updateArticleSnapshot(filePath,articleController.articleId);
    if(!updateStatus){
      BotToast.showText(text: '保存快照到数据库失败');
    }
  }

  /// 安全的重试加载页面方法
  Future<void> _retryLoadPage() async {
    try {
      getLogger().i('🔄 开始重试加载页面...');
      
      // 清理当前URL的重试计数器和预热状态，给手动重试一个全新的机会
      _retryCountMap.remove(articleController.articleUrl);
      _warmupAttemptedForUrl.remove(articleController.articleUrl);
      
      // 检查WebView控制器是否可用
      if (webViewController == null) {
        getLogger().w('⚠️ WebView控制器为空，等待重新创建...');
        // 如果控制器为空，等待一下让WebView重新创建
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }
      
      // 对于知乎等高防护网站，使用增强的重试策略
      final domain = Uri.parse(articleController.articleUrl).host;
      if (_isHighProtectionSite(domain)) {
        getLogger().i('🛡️ 检测到高防护网站，使用增强重试策略');
        await _retryZhihuPage(webViewController!, articleController.articleUrl);
        return;
      }
      
      // 直接使用loadUrl方法重新加载页面，避免iOS上的reload问题
      try {
        await webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(articleController.articleUrl))
        );
        getLogger().i('✅ 使用loadUrl方法重试成功');
      } catch (loadUrlError) {
        getLogger().e('❌ loadUrl方法失败: $loadUrlError');
        
        // 如果loadUrl也失败，尝试使用reload方法（作为备选）
        try {
          await webViewController!.reload();
          getLogger().i('✅ 使用reload方法重试成功');
        } catch (reloadError) {
          getLogger().e('❌ reload方法也失败: $reloadError');
          
          // 如果两种方法都失败，显示更详细的错误信息
          if (mounted) {
            setState(() {
              hasError = true;
              isLoading = false;
              errorMessage = '重新加载失败\n\n请稍后再试或重启应用。\n\n错误详情：$reloadError';
            });
          }
        }
      }
    } catch (e) {
      getLogger().e('❌ 重试加载页面时发生未知错误: $e');
      
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = '重新加载时发生错误\n\n请重启应用后再试。\n\n错误详情：$e';
        });
      }
    }
  }


  /// 公共方法：供外部调用生成Markdown
  Future<void> createMarkdown() async {
    final filePath = await generateMhtmlUtils.generateSnapshot();
    if(filePath.isEmpty){
      BotToast.showText(text: '保存快照失败');
      return;
    }

    final uploadStatus = await generateMhtmlUtils.uploadSnapshotToServer(filePath,articleController.articleId); // 上传快照到服务器
    if(uploadStatus){
      await generateMhtmlUtils.fetchMarkdownFromServer(
        articleController: articleController,
        onMarkdownGenerated: widget.onMarkdownGenerated,
        isReCreate: true,
      );
    }
  }

  /// 初始化浏览器仿真功能
  Future<void> _initializeBrowserSimulation() async {
    try {
      // 初始化仿真管理器
      _simulationManager = BrowserSimulationManager();
      Get.put(_simulationManager!);
      
      // 创建JavaScript注入器
      _jsInjector = JSInjector(_simulationManager!.storageManager);
      
      getLogger().i('🎯 浏览器仿真功能初始化完成');
    } catch (e) {
      getLogger().e('❌ 浏览器仿真功能初始化失败: $e');
    }
  }

  /// 设置浏览器仿真功能
  Future<void> _setupBrowserSimulation(InAppWebViewController controller) async {
    if (_jsInjector == null || _simulationManager == null) {
      getLogger().w('⚠️ 浏览器仿真功能未初始化，跳过设置');
      return;
    }

    try {
      getLogger().i('🔧 开始设置浏览器仿真功能...');
      
      // 设置JavaScript处理器
      await _jsInjector!.setupJavaScriptHandlers(controller);
      
      // 注入基础反检测代码
      await _jsInjector!.injectAntiDetectionCode(controller);
      
      getLogger().i('✅ 浏览器仿真功能设置完成');
    } catch (e) {
      getLogger().e('❌ 设置浏览器仿真功能失败: $e');
    }
  }

  /// 注入存储仿真代码
  Future<void> _injectStorageSimulation(InAppWebViewController controller) async {
    if (_jsInjector == null) {
      getLogger().w('⚠️ JavaScript注入器未初始化，跳过存储仿真');
      return;
    }

    try {
      getLogger().i('💉 开始注入存储仿真代码...');
      
      // 注入存储仿真代码
      await _jsInjector!.injectStorageSimulation(controller);
      
      // 预加载存储数据
      await _jsInjector!.preloadStorageData(controller);
      
      getLogger().i('✅ 存储仿真代码注入完成');
    } catch (e) {
      getLogger().e('❌ 注入存储仿真代码失败: $e');
    }
  }

  /// 注入平台特定的反检测代码
  Future<void> _injectPlatformSpecificAntiDetection(InAppWebViewController controller) async {
    try {
      getLogger().i('🛡️ 开始注入平台特定反检测代码 - 平台: ${Platform.isAndroid ? 'Android' : 'iOS'}');
      
      String antiDetectionScript;
      
      if (Platform.isAndroid) {
        // Android WebView 特有的反检测代码 (v2 - 增强版)
        antiDetectionScript = '''
        (function() {
          console.log('🤖 Android WebView Advanced Anti-Detection Script v2');
          
          try {
            // 1. 清理已知的WebView指纹
            delete window.AndroidBridge;
            delete window.android;
            delete window.prompt;

            // 2. 伪装navigator核心属性
            // 最关键的属性：webdriver
            Object.defineProperty(navigator, 'webdriver', {
              get: () => undefined,
            });

            // 伪装Chrome浏览器特有的对象
            window.chrome = window.chrome || {};
            window.chrome.app = {
              isInstalled: false,
              InstallState: {
                DISABLED: 'disabled',
                INSTALLED: 'installed',
                NOT_INSTALLED: 'not_installed'
              },
              RunningState: {
                CANNOT_RUN: 'cannot_run',
                READY_TO_RUN: 'ready_to_run',
                RUNNING: 'running'
              }
            };
            window.chrome.webstore = {
              onInstallStageChanged: {},
              onDownloadProgress: {}
            };
            window.chrome.runtime = {};

            // 3. 伪装插件和MIME类型
            const originalPlugins = navigator.plugins;
            const plugins = [
              { name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer', description: 'Portable Document Format', mimeTypes: [{ type: 'application/x-google-chrome-pdf', suffixes: 'pdf' }] },
              { name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai', description: '', mimeTypes: [{ type: 'application/pdf', suffixes: 'pdf' }] },
              { name: 'Native Client', filename: 'internal-nacl-plugin', description: '', mimeTypes: [{ type: 'application/x-nacl', suffixes: '' }, { type: 'application/x-pnacl', suffixes: '' }] }
            ];
            plugins.item = (i) => plugins[i];
            plugins.namedItem = (name) => plugins.find(p => p.name === name);
            Object.defineProperty(navigator, 'plugins', { get: () => plugins });
            
            const mimeTypes = [
                { type: 'application/pdf', suffixes: 'pdf', enabledPlugin: plugins[1] },
                { type: 'application/x-google-chrome-pdf', suffixes: 'pdf', enabledPlugin: plugins[0] },
                { type: 'application/x-nacl', suffixes: '', enabledPlugin: plugins[2] },
                { type: 'application/x-pnacl', suffixes: '', enabledPlugin: plugins[2] }
            ];
            mimeTypes.item = (i) => mimeTypes[i];
            mimeTypes.namedItem = (name) => mimeTypes.find(m => m.type === name);
            Object.defineProperty(navigator, 'mimeTypes', { get: () => mimeTypes });

            // 4. 伪装权限API
            if (navigator.permissions) {
                const originalQuery = navigator.permissions.query;
                navigator.permissions.query = (parameters) => (
                  parameters.name === 'notifications'
                    ? Promise.resolve({ state: Notification.permission })
                    : originalQuery.apply(navigator.permissions, [parameters])
                );
            }

            // 5. 伪装设备属性
            if ('deviceMemory' in navigator) {
              Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });
            }
            Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
            Object.defineProperty(navigator, 'languages', { get: () => ['zh-CN', 'zh', 'en-US', 'en'] });

            // 6. 伪装WebGL渲染信息
            try {
                const getParameter = WebGLRenderingContext.prototype.getParameter;
                WebGLRenderingContext.prototype.getParameter = function(parameter) {
                    // UNMASKED_VENDOR_WEBGL
                    if (parameter === 37445) return 'Google Inc. (NVIDIA)';
                    // UNMASKED_RENDERER_WEBGL
                    if (parameter === 37446) return 'ANGLE (NVIDIA, NVIDIA GeForce GTX 1050 Ti Direct3D11 vs_5_0 ps_5_0, D3D11)';
                    return getParameter.apply(this, [parameter]);
                };
            } catch (e) {
                console.warn('⚠️ WebGL spoofing failed:', e.toString());
            }
            
            console.log('✅ Android Advanced Anti-Detection finished.');
          } catch (e) {
            console.warn('⚠️ Android anti-detection script failed:', e.toString());
          }
        })();
        ''';
      } else {
        // iOS WebView 特有的反检测代码
        antiDetectionScript = '''
        (function() {
          console.log('🍎 iOS WebView 反检测脚本启动');
          
          try {
            // 删除 iOS WebView 的特有属性
            delete window.webkit;
            
            // 确保 Safari 特征正确
            Object.defineProperty(navigator, 'vendor', {
              get: () => 'Apple Computer, Inc.',
              configurable: true
            });
            
            // 模拟 Safari 的 plugins
            Object.defineProperty(navigator, 'plugins', {
              get: () => [],
              configurable: true
            });
            
            console.log('✅ iOS WebView 反检测完成');
            
          } catch (e) {
            console.warn('⚠️ iOS 反检测部分失败:', e);
          }
        })();
        ''';
      }
      
      await controller.evaluateJavascript(source: antiDetectionScript);
      getLogger().i('✅ 平台特定反检测代码注入完成');
      
    } catch (e) {
      getLogger().e('❌ 注入平台特定反检测代码失败: $e');
    }
  }

  /// 注入移动端弹窗处理脚本 - 恢复滚动功能
  Future<void> _injectMobilePopupHandler(InAppWebViewController controller) async {
    try {
      getLogger().i('📱 开始注入移动端弹窗处理脚本...');
      
      const jsCode = '''
      (function() {
        console.log('📱 移动端弹窗处理脚本已启动');
        
        // 定时检查并修复滚动问题
        const checkAndFixScrolling = function() {
          try {
            // 1. 强制恢复页面滚动
            const html = document.documentElement;
            const body = document.body;
            
            // 移除可能的滚动阻止样式
            [html, body].forEach(el => {
              if (el) {
                el.style.overflow = '';
                el.style.overflowY = '';
                el.style.height = '';
                el.style.position = '';
                
                // 移除data属性中的滚动锁定标记
                el.removeAttribute('data-scroll-locked');
                el.removeAttribute('data-body-scroll-lock');
              }
            });
            
            // 2. 检查并移除可能的遮罩层
            const overlays = document.querySelectorAll(
              '[style*="position: fixed"], [style*="position:fixed"], ' +
              '.modal-backdrop, .overlay, .mask, .popup-mask, ' +
              '[class*="modal"], [class*="popup"], [class*="overlay"], ' +
              '[id*="modal"], [id*="popup"], [id*="overlay"]'
            );
            
            overlays.forEach(overlay => {
              const style = window.getComputedStyle(overlay);
              const zIndex = parseInt(style.zIndex) || 0;
              const position = style.position;
              
              // 检查是否是高层级的遮罩元素
              if ((position === 'fixed' || position === 'absolute') && 
                  zIndex > 1000 && 
                  overlay.offsetWidth > window.innerWidth * 0.8 &&
                  overlay.offsetHeight > window.innerHeight * 0.8) {
                
                console.log('🗑️ 移除可疑的遮罩层:', overlay.className || overlay.id);
                
                // 尝试隐藏而不是删除，避免破坏页面
                overlay.style.display = 'none';
                overlay.style.visibility = 'hidden';
                overlay.style.zIndex = '-1';
                overlay.style.pointerEvents = 'none';
              }
            });
            
            // 3. 恢复触摸事件
            const events = ['touchstart', 'touchmove', 'touchend', 'scroll', 'wheel'];
            events.forEach(eventType => {
              // 移除所有可能的事件阻止器
              const oldHandler = document['on' + eventType];
              if (oldHandler) {
                document['on' + eventType] = null;
              }
              
              // 确保事件可以正常冒泡
              document.addEventListener(eventType, function(e) {
                // 不阻止默认行为，让滚动正常进行
                if (eventType === 'touchmove' || eventType === 'scroll' || eventType === 'wheel') {
                  e.stopImmediatePropagation = function() {}; // 禁用立即停止传播
                }
              }, { passive: true, capture: true });
            });
            
            // 4. 特殊处理知名网站的APP引导弹窗
            const hostname = window.location.hostname;
            
            // 知乎特殊处理
            if (hostname.includes('zhihu.com')) {
              const zhihuPopups = document.querySelectorAll(
                '.AppBanner, .MobileAppBanner, .DownloadBanner, ' +
                '[class*="AppBanner"], [class*="DownloadBanner"], ' +
                '[data-zop*="app"], [data-zop*="banner"]'
              );
              
              zhihuPopups.forEach(popup => {
                popup.style.display = 'none';
                console.log('🎯 隐藏知乎APP引导:', popup.className);
              });
            }
            
            // 5. 强制启用滚动并固定页面宽度 - 最后的保险措施
            html.style.overflow = 'hidden auto !important';  // 禁用水平滚动，启用垂直滚动
            body.style.overflow = 'hidden auto !important';  // 禁用水平滚动，启用垂直滚动
            html.style.position = 'static !important';
            body.style.position = 'static !important';
            html.style.width = '100% !important';
            body.style.width = '100% !important';
            html.style.maxWidth = '100% !important';
            body.style.maxWidth = '100% !important';
            
            console.log('✅ 滚动功能检查修复完成');
            
            return true;
          } catch (error) {
            console.error('❌ 修复滚动功能时出错:', error);
            return false;
          }
        };
        
        // 立即执行一次
        checkAndFixScrolling();
        
        // 延迟执行，处理可能的异步弹窗
        setTimeout(checkAndFixScrolling, 1000);
        setTimeout(checkAndFixScrolling, 3000);
        setTimeout(checkAndFixScrolling, 5000);
        
        // 监听页面变化，自动修复
        if (typeof MutationObserver !== 'undefined') {
          const observer = new MutationObserver(function(mutations) {
            let shouldCheck = false;
            
            mutations.forEach(function(mutation) {
              // 检查是否有样式或类的变化
              if (mutation.type === 'attributes' && 
                  (mutation.attributeName === 'style' || 
                   mutation.attributeName === 'class')) {
                shouldCheck = true;
              }
              
              // 检查是否有新增的元素（可能是弹窗）
              if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                mutation.addedNodes.forEach(function(node) {
                  if (node.nodeType === 1) { // Element node
                    const element = node;
                    if (element.style && 
                        (element.style.position === 'fixed' || 
                         element.style.zIndex > 1000)) {
                      shouldCheck = true;
                    }
                  }
                });
              }
            });
            
            if (shouldCheck) {
              setTimeout(checkAndFixScrolling, 500);
            }
          });
          
          observer.observe(document.body, {
            attributes: true,
            childList: true,
            subtree: true,
            attributeFilter: ['style', 'class']
          });
          
          console.log('🔍 页面变化监听器已启动');
        }
        
        console.log('✅ 移动端弹窗处理脚本初始化完成');
      })();
      ''';
      
      await controller.evaluateJavascript(source: jsCode);
      getLogger().i('✅ 移动端弹窗处理脚本注入完成');
      
    } catch (e) {
      getLogger().e('❌ 注入移动端弹窗处理脚本失败: $e');
    }
  }

  /// 智能处理HTTP错误
  void _handleHttpError(InAppWebViewController controller, WebResourceRequest request, WebResourceResponse errorResponse) {
    final url = request.url.toString();
    final statusCode = errorResponse.statusCode ?? 0;
    final domain = Uri.parse(url).host;
    
    getLogger().w('⚠️ HTTP错误: $statusCode - $url');
    
    // 检查是否是API请求错误（不影响主页面加载）
    final isApiRequest = _isApiRequest(url);
    final isMainFrameRequest = request.isForMainFrame ?? false;
    
    if (isApiRequest && !isMainFrameRequest) {
      // API请求错误，不显示错误界面
      getLogger().i('📡 API请求失败，但不影响主页面: $url');
      
      // 检查是否是知乎等高防护网站的API
      if (domain.contains('zhihu.com') && (statusCode == 400 || statusCode == 403)) {
        getLogger().i('🛡️ 检测到知乎反爬虫拦截，这是预期行为');
        _handleZhihuAntiCrawler(controller, url);
      }
      
      return; // 不设置hasError，让页面继续正常显示
    }
    
    // 主页面请求的特殊处理
    if (isMainFrameRequest) {
      // 对知乎等高防护网站的403错误进行特殊处理
      if (statusCode == 403 && _isHighProtectionSite(domain)) {
        getLogger().w('🛡️ 检测到高防护网站403错误，尝试智能重试');
        _handleHighProtectionSite403Error(controller, url, domain);
        return;
      }
      
      // 其他HTTP错误的处理
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = _generateHttpErrorMessage(statusCode, errorResponse.reasonPhrase, domain);
      });
    }
  }
  
  /// 检查是否是高防护网站
  bool _isHighProtectionSite(String domain) {
    final highProtectionSites = [
      'zhihu.com',
      'weibo.com', 
      'douban.com',
      'jianshu.com',
      'csdn.net',
    ];
    
    return highProtectionSites.any((site) => domain.contains(site));
  }
  
  /// 处理高防护网站的403错误
  Future<void> _handleHighProtectionSite403Error(InAppWebViewController controller, String url, String domain) async {
    try {
      // 检查是否已经尝试过预热策略
      final alreadyTriedWarmup = _warmupAttemptedForUrl[url] ?? false;
      
      if (!alreadyTriedWarmup) {
        _warmupAttemptedForUrl[url] = true;
        getLogger().i('🤔 知乎403：检测到首次访问失败，执行"首页预热"策略...');
        
        // 记录下真正的目标URL
        _urlToLoadAfterWarmup = url;
        
        // 计算首页URL并加载
        final homepageUrl = Uri.parse(url).replace(path: '/');
        getLogger().i('➡️ 正在导航到首页: ${homepageUrl.toString()}');
        
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri(homepageUrl.toString())));
        
        // 预热策略已启动，直接返回，等待首页加载完成后的回调
        return;
      }
      
      // 如果预热策略已尝试过，则进入常规的重试流程
      getLogger().w('⚠️ 首页预热策略已执行过，但仍然失败。转为常规重试...');
      
      getLogger().i('🔄 开始处理高防护网站403错误: $domain');
      
      // 增加重试计数器
      if (!_retryCountMap.containsKey(url)) {
        _retryCountMap[url] = 0;
      }
      
      final retryCount = _retryCountMap[url]!;
      const maxRetries = 3;
      
      if (retryCount >= maxRetries) {
        getLogger().w('⚠️ 已达到最大重试次数，显示错误页面');
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = '网站访问被限制 (403)\n\n该网站检测到非常规访问模式。\n\n建议：\n• 稍后重试\n• 使用浏览器直接访问\n• 检查网络环境';
        });
        return;
      }
      
      _retryCountMap[url] = retryCount + 1;
      
      // 在重试前，清除该站点的Cookies，尝试打破封锁
      try {
        await CookieManager.instance().deleteCookies(url: WebUri(url));
        getLogger().i('🍪 已清除Cookies，准备重试: $url');
      } catch (e) {
        getLogger().w('⚠️ 清除Cookies失败: $e');
      }
      
      // 延迟重试，避免被检测为机器人行为
      final delaySeconds = (retryCount + 1) * 2; // 递增延迟：2s, 4s, 6s
      getLogger().i('⏰ 延迟 ${delaySeconds}s 后重试 (第${retryCount + 1}/$maxRetries次)');
      
      await Future.delayed(Duration(seconds: delaySeconds));
      
      // 检查组件是否仍然挂载
      if (!mounted) return;
      
      // 针对知乎的特殊处理
      if (domain.contains('zhihu.com')) {
        await _retryZhihuPage(controller, url);
      } else {
        // 其他高防护网站的通用重试策略
        await _retryWithEnhancedHeaders(controller, url);
      }
      
    } catch (e) {
      getLogger().e('❌ 处理高防护网站403错误失败: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = '重试失败\n\n请稍后手动重试或使用浏览器访问。';
      });
    }
  }
  
  /// 检查并处理预热跳转
  /// 如果是预热加载，则返回true
  Future<bool> _handleWarmupRedirect(Uri? currentUrl, InAppWebViewController controller) async {
    if (_urlToLoadAfterWarmup != null && 
        currentUrl != null && 
        currentUrl.host == Uri.parse(_urlToLoadAfterWarmup!).host &&
        currentUrl.path == '/') {
          
      getLogger().i('✅ 首页预热成功！');
      final targetUrl = _urlToLoadAfterWarmup!;
      _urlToLoadAfterWarmup = null; // 清除标记，避免重复跳转
      
      // 稍作等待，让首页的脚本有机会执行
      await Future.delayed(const Duration(milliseconds: 500)); 
      
      getLogger().i('🚀 正在跳转至原始目标链接: $targetUrl');
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(targetUrl)));
      
      return true; // 表示已经处理了跳转，上层调用应该中断
    }
    
    return false; // 不是预热跳转
  }
  
  /// 针对知乎的特殊重试策略
  Future<void> _retryZhihuPage(InAppWebViewController controller, String url) async {
    try {
      getLogger().i('🎯 执行知乎特定重试策略 - 平台: ${Platform.isAndroid ? 'Android' : 'iOS'}');
      
      // 根据平台使用对应的User-Agent
      final enhancedUserAgent = _getPlatformOptimizedUserAgent();
      
      await controller.setSettings(settings: InAppWebViewSettings(
        userAgent: enhancedUserAgent,
        // 启用更多浏览器特性来减少检测
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        thirdPartyCookiesEnabled: true,
        useShouldOverrideUrlLoading: true,
      ));
      
      // 根据平台添加对应的浏览器请求头
      final headers = _getPlatformOptimizedHeaders();
      
      // 重新加载页面
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri(url),
          headers: headers,
        ),
      );
      
      getLogger().i('✅ 知乎页面重试请求已发送 (${Platform.isAndroid ? 'Android Chrome' : 'iOS Safari'} 模式)');
      
    } catch (e) {
      getLogger().e('❌ 知乎重试策略失败: $e');
      rethrow;
    }
  }
  
  /// 获取平台优化的请求头 
  Map<String, String> _getPlatformOptimizedHeaders() {
    if (Platform.isAndroid) {
      // Android Chrome 的典型请求头 - 更新至 Chrome 124
      return {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0',
        'sec-ch-ua': '"Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"',
        'sec-ch-ua-mobile': '?1',
        'sec-ch-ua-platform': '"Android"',
        'sec-ch-ua-platform-version': '"14.0.0"',
        'sec-ch-ua-model': '"Pixel 7 Pro"',
        'sec-ch-ua-full-version-list': '"Chromium";v="124.0.6367.123", "Google Chrome";v="124.0.6367.123", "Not-A.Brand";v="99.0.0.0"',
      };
    } else {
      // iOS Safari 的典型请求头
      return {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Cache-Control': 'max-age=0',
      };
    }
  }
  
  /// 使用增强请求头重试
  Future<void> _retryWithEnhancedHeaders(InAppWebViewController controller, String url) async {
    try {
      getLogger().i('🔧 使用增强请求头重试 - 平台: ${Platform.isAndroid ? 'Android' : 'iOS'}');
      
      // 使用平台优化的请求头，并添加一些缓存控制头
      final headers = _getPlatformOptimizedHeaders();
      headers.addAll({
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      });
      
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri(url),
          headers: headers,
        ),
      );
      
      getLogger().i('✅ 增强请求头重试请求已发送 (${Platform.isAndroid ? 'Android Chrome' : 'iOS Safari'} 模式)');
      
    } catch (e) {
      getLogger().e('❌ 增强请求头重试失败: $e');
      rethrow;
    }
  }
  
  /// 生成HTTP错误消息
  String _generateHttpErrorMessage(int statusCode, String? reasonPhrase, String domain) {
    switch (statusCode) {
      case 403:
        if (_isHighProtectionSite(domain)) {
          return '访问被限制 (403)\n\n该网站具有反爬虫保护。\n\n建议：\n• 稍后重试\n• 使用浏览器直接访问';
        }
        return '访问被拒绝 (403)\n\n您没有权限访问此页面。';
        
      case 404:
        return '页面不存在 (404)\n\n请检查链接是否正确。';
        
      case 429:
        return '请求过于频繁 (429)\n\n请稍后再试。';
        
      case 500:
        return '服务器内部错误 (500)\n\n网站服务器出现问题，请稍后重试。';
        
      case 503:
        return '服务不可用 (503)\n\n网站暂时无法访问，请稍后重试。';
        
      default:
        return '页面加载失败 ($statusCode)\n${reasonPhrase ?? 'Unknown Error'}\n\n请稍后重试或检查网络连接。';
    }
  }
  
  /// 智能处理WebView各种错误
  void _handleWebViewError(InAppWebViewController controller, WebResourceRequest request, WebResourceError error) {
    final url = request.url.toString();
    final errorType = error.type.toString();
    final domain = Uri.parse(url).host;
    
    getLogger().e('❌ WebView加载错误: ${error.description}', error: {
      'type': error.type,
      'url': request.url,
      'method': request.method,
      'headers': request.headers,
    });
    
    // 检查是否是主页面请求
    final isMainFrameRequest = request.isForMainFrame ?? false;
    
    // 检查是否是可忽略的错误类型
    final isIgnorableError = _isIgnorableError(errorType, url, domain);
    
    if (isIgnorableError && !isMainFrameRequest) {
      getLogger().i('📡 忽略第三方资源错误: $url');
      getLogger().i('  - 错误类型: $errorType');
      getLogger().i('  - 这通常是广告、统计或其他第三方资源的问题');
      getLogger().i('  - 不影响主页面正常显示');
      return; // 不设置错误状态
    }
    
    // 只有主页面加载失败或关键错误才显示错误界面
    if (isMainFrameRequest) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = _generateUserFriendlyErrorMessage(errorType, error.description ?? '', url);
      });
    }
  }
  
  /// 检查是否是可忽略的错误类型
  bool _isIgnorableError(String errorType, String url, String domain) {
    // SSL相关错误（通常是第三方资源）
    final sslErrors = [
      'FAILED_SSL_HANDSHAKE',
      'SSL_PROTOCOL_ERROR',
      'CERT_AUTHORITY_INVALID',
      'CERT_DATE_INVALID',
      'CERT_COMMON_NAME_INVALID',
    ];
    
    // 网络连接错误（可能是临时的）
    final networkErrors = [
      'NAME_NOT_RESOLVED',
      'INTERNET_DISCONNECTED',
      'CONNECTION_TIMED_OUT',
      'CONNECTION_REFUSED',
      'CONNECTION_RESET',
    ];
    
    // 第三方服务域名（通常可以忽略）
    final thirdPartyDomains = [
      'googletagmanager.com',
      'google-analytics.com',
      'doubleclick.net',
      'googlesyndication.com',
      'facebook.com',
      'twitter.com',
      'tiktok.com',
      'bytedance.com',
      'adutp.com', // 从错误URL看到的广告域名
      'ymjs.adutp.com',
    ];
    
    // 检查错误类型
    if (sslErrors.contains(errorType) || networkErrors.contains(errorType)) {
      // 如果是第三方域名的SSL/网络错误，可以忽略
      if (thirdPartyDomains.any((thirdParty) => domain.contains(thirdParty))) {
        return true;
      }
      
      // 检查是否是广告或统计URL
      if (_isAdOrAnalyticsRequest(url)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 检查是否是广告或统计请求
  bool _isAdOrAnalyticsRequest(String url) {
    final adPatterns = [
      '/ads/',
      '/ad/',
      '/analytics/',
      '/track/',
      '/pixel',
      '/beacon',
      '/stat/',
      '/click',
      'auto_ds', // 从错误URL看到的模式
      'googletagmanager',
      'google-analytics',
    ];
    
    return adPatterns.any((pattern) => url.toLowerCase().contains(pattern));
  }
  
  /// 生成用户友好的错误消息
  String _generateUserFriendlyErrorMessage(String errorType, String description, String url) {
    switch (errorType) {
      case 'FAILED_SSL_HANDSHAKE':
      case 'SSL_PROTOCOL_ERROR':
        return '网站SSL证书有问题\n\n这可能是网站配置问题或网络环境限制。\n请稍后重试或尝试其他网络。';
      
      case 'NAME_NOT_RESOLVED':
        return '无法解析网站地址\n\n请检查网络连接或稍后重试。';
      
      case 'INTERNET_DISCONNECTED':
        return '网络连接已断开\n\n请检查网络设置并重新连接。';
      
      case 'CONNECTION_TIMED_OUT':
        return '连接超时\n\n网络响应较慢，请稍后重试。';
      
      case 'CONNECTION_REFUSED':
      case 'CONNECTION_RESET':
        return '连接被拒绝\n\n网站可能暂时不可用，请稍后重试。';
      
      default:
        return '页面加载失败\n\n错误类型: $errorType\n错误描述: $description\n\n请稍后重试或检查网络连接。';
    }
  }
  
  /// 检查是否是API请求
  bool _isApiRequest(String url) {
    // 常见的API请求路径模式
    final apiPatterns = [
      '/api/',
      '/ajax/',
      '/json/',
      '/v1/',
      '/v2/',
      '/v3/',
      '/graphql',
      '.json',
      'qrcode',
      'login',
      'auth',
    ];
    
    return apiPatterns.any((pattern) => url.toLowerCase().contains(pattern));
  }
  
  /// 处理知乎反爬虫
  void _handleZhihuAntiCrawler(InAppWebViewController controller, String url) {
    // 记录知乎反爬虫事件
    getLogger().i('🔍 知乎反爬虫检测详情:');
    getLogger().i('  - URL: $url');
    getLogger().i('  - 这通常是知乎的登录/认证API被拦截');
    getLogger().i('  - 主页面内容应该仍可正常显示');
    
    // 可以在这里添加更多的知乎特定处理逻辑
    // 比如重试策略、用户提示等
  }

  /// 获取平台优化的WebView设置
  InAppWebViewSettings _getWebViewSettings() {
    // 基础设置
    final settings = InAppWebViewSettings(
      // --- 核心功能开关 ---
      // 【允许执行JavaScript】: WebView的核心能力，必须为true。
      javaScriptEnabled: true,
      // 【允许JS自动打开窗口】: 允许JS通过 `window.open()` 等方式打开新窗口，对于某些登录流程是必要的。
      javaScriptCanOpenWindowsAutomatically: true,
      
      // --- 数据与存储 (关键反爬点) ---
      // 【启用DOM存储】: 允许网站使用 localStorage 和 sessionStorage，是现代网站的标配。
      domStorageEnabled: true,
      // 【启用Web数据库】: 允许网站使用 Web SQL Database API（虽然已废弃，但一些老网站可能还在用）。
      databaseEnabled: true,
      // 【允许第三方Cookie】: 允许跨域请求设置Cookie，对于处理内嵌内容或SSO登录很重要。
      thirdPartyCookiesEnabled: true,
      
      // --- 导航与拦截 ---
      // 【启用URL加载拦截】: 设为true后，`shouldOverrideUrlLoading` 回调才会生效，是实现URL拦截的关键。
      useShouldOverrideUrlLoading: true, 
      
      // --- 身份标识 ---
      // 【设置User-Agent】: 向服务器声明自己的"身份"，是反爬虫伪装的第一步。
      userAgent: _getPlatformOptimizedUserAgent(),
      
      // --- 内容与安全策略 ---
      // 【混合内容模式】: 在HTTPS页面加载HTTP内容时的策略。`MIXED_CONTENT_ALWAYS_ALLOW` 表示总是允许，以避免内容显示不全。
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      // 【允许内联媒体播放】: 允许视频在页面内播放，而不是强制全屏。
      allowsInlineMediaPlayback: true,
      // 【允许手势导航】(iOS): 允许用户通过左右滑动手势来前进或后退页面。
      allowsBackForwardNavigationGestures: true,
      
      // --- UI与错误页面 ---
      // 【禁用默认错误页面】: 禁用WebView内置的错误页面（如"网页无法打开"），以便我们用自定义的UI组件来显示错误。
      disableDefaultErrorPage: true,
      // 【禁用上下文菜单】: 是否禁用长按时出现的系统菜单（如复制、粘贴）。设为false以更像真实浏览器。
      disableContextMenu: false,
      
      // --- 缓存策略 ---
      // 【缓存模式】: 使用默认的缓存策略，让WebView自行决定如何使用缓存。
      cacheMode: CacheMode.LOAD_DEFAULT,
      // 【清除缓存】: 在WebView启动时不清除缓存，以保留之前的会话和数据。
      clearCache: false,
      
      // --- 布局与交互 ---
      // 【文本缩放比例】: 设置页面文字的缩放百分比，100表示正常大小。
      textZoom: 100,
      // 【支持缩放】: 是否允许用户通过双指捏合来缩放页面。
      supportZoom: true,
      // 【显示内置缩放控件】: 是否显示WebView内置的缩放按钮（通常不美观，设为false）。
      builtInZoomControls: false,
      // 【在屏幕上显示缩放控件】(Android): 同上，控制原生缩放控件的显示。
      displayZoomControls: false,
      
      // --- 滚动控制 ---
      // 【禁用水平滚动】: 强制页面内容在一屏内显示，防止出现水平滚动条，提升移动端体验。
      disableHorizontalScroll: true,
      // 【禁用垂直滚动】: 设为false，允许用户正常地上下滚动页面。
      disableVerticalScroll: false,
      
      // --- 多媒体支持 ---
      // 【媒体播放需要用户手势】: 要求用户必须先点击一下才能播放视频或音频，这是现代浏览器的标准行为，可增加真实性。
      mediaPlaybackRequiresUserGesture: true,
      
      // --- 文件访问权限 ---
      // 【允许文件访问】: 允许WebView从文件系统加载资源（file://...）。
      allowFileAccess: true,
      // 【允许内容访问】(Android): 允许WebView通过Content Provider访问内容。
      allowContentAccess: true,
    );
    
    // 添加平台特定设置
    if (Platform.isIOS) {
      // 【禁用输入附件视图】(iOS): 隐藏键盘上方默认出现的辅助工具栏（包含"上一个/下一个/完成"）。
      settings.disableInputAccessoryView = true;
      // 【禁止增量渲染】(iOS): 设为false表示启用增量渲染，即边加载边显示，体验更好。
      settings.suppressesIncrementalRendering = false;
    }
    
    return settings;
  }
  
  /// 获取平台优化的User-Agent
  String _getPlatformOptimizedUserAgent() {
    if (Platform.isAndroid) {
      // Android Chrome User-Agent - 更新为更现代的版本以匹配headers
      return "Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36";
    } else if (Platform.isIOS) {
      // iOS Safari User-Agent - 同样更新到较新版本
      return "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1";
    } else {
      // 默认使用通用移动端User-Agent
      return "Mozilla/5.0 (Mobile; rv:109.0) Gecko/109.0 Firefox/119.0";
    }
  }
  
  

  @override
  void dispose() {
    webViewController?.dispose();
    _simulationManager?.dispose();
    _retryCountMap.clear(); // 清理重试计数器
    _warmupAttemptedForUrl.clear(); // 清理预热状态
    super.dispose();
  }




}
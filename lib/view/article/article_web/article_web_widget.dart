import 'package:clipora/view/article/article_web/utils/web_utils.dart';
import 'package:clipora/view/article/article_web/utils/generate_mhtml_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
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

  // 公共方法：供外部调用生成快照
  Future<void> createSnapshot() async {
    await GenerateMhtmlUtils.generateMHTMLSnapshot(
      webViewController: webViewController,
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
    );
  }

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
        // if (hasError)
        //   Container(
        //     width: double.infinity,
        //     padding: const EdgeInsets.all(16),
        //     color: Colors.red[50],
        //     child: Column(
        //       children: [
        //         Icon(Icons.error_outline, color: Colors.red[600], size: 48),
        //         const SizedBox(height: 8),
        //         Text(
        //           '网页加载失败',
        //           style: TextStyle(
        //             color: Colors.red[600],
        //             fontSize: 16,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //         const SizedBox(height: 4),
        //         Text(
        //           errorMessage,
        //           style: TextStyle(
        //             color: Colors.red[600],
        //             fontSize: 14,
        //           ),
        //           textAlign: TextAlign.center,
        //         ),
        //         const SizedBox(height: 12),
        //       ],
        //     ),
        //   ),
        // WebView
        if (!hasError)
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(articleController.articleUrl)),
              initialSettings: _getWebViewSettings(),
              onWebViewCreated: (controller) async {
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
                
                // 设置浏览器仿真功能
                await _setupBrowserSimulation(controller);
                
                // 使用优化的WebView配置
                // _setupOptimizedWebView(controller);
              },
              onLoadStart: (controller, url) {
                getLogger().i('🌐 开始加载Web页面: $url');
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              },
              onLoadStop: (controller, url) async {
                getLogger().i('🌐 Web页面加载完成: $url');
                setState(() {
                  isLoading = false;
                });
                
                // 注入存储仿真代码
                await _injectStorageSimulation(controller);
                
                // 注入内边距
                final padding = widget.contentPadding.resolve(Directionality.of(context));
                controller.evaluateJavascript(source: '''
                  document.body.style.paddingTop = '${padding.top}px';
                  document.body.style.paddingBottom = '${padding.bottom}px';
                  document.body.style.paddingLeft = '${padding.left}px';
                  document.body.style.paddingRight = '${padding.right}px';
                  document.documentElement.style.scrollPaddingTop = '${padding.top}px';
                ''');
                
                // 页面加载完成后进行优化设置
                finalizeWebPageOptimization(url,webViewController);
                
                // 检查是否需要自动生成MHTML快照（异步执行，不阻塞主线程）
                GenerateMhtmlUtils.checkAndGenerateSnapshotIfNeeded(
                  webViewController: webViewController,
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
              onProgressChanged: (controller, progress) {
                setState(() {
                  loadingProgress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                _handleWebViewError(controller, request, error);
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                _handleHttpError(controller, request, errorResponse);
              },
              onScrollChanged: (controller, x, y) {
                final scrollY = y.toDouble();
                // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
                if ((scrollY - _lastScrollY).abs() > 15) {
                  final direction = scrollY > _lastScrollY ? ScrollDirection.reverse : ScrollDirection.forward;
                  widget.onScroll?.call(direction, scrollY);
                  _lastScrollY = scrollY;
                }
              },
              // 使用优化的URL跳转处理
              shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
              // 使用优化的资源请求拦截 - 增强反爬虫处理
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
        url.startsWith('newsarticle')) {
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

  // WebView控制器
  InAppWebViewController? webViewController;
  
  // 加载状态
  bool isLoading = true;
  double loadingProgress = 0.0;
  
  // 错误状态
  bool hasError = false;
  String errorMessage = '';

  // 浏览器仿真管理器
  BrowserSimulationManager? _simulationManager;
  JSInjector? _jsInjector;

  @override
  void initState() {
    super.initState();
    _initializeBrowserSimulation();
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
      if (domain.contains('zhihu.com') && statusCode == 400) {
        getLogger().i('🛡️ 检测到知乎反爬虫拦截，这是预期行为');
        _handleZhihuAntiCrawler(controller, url);
      }
      
      return; // 不设置hasError，让页面继续正常显示
    }
    
    // 只有主要页面加载失败才显示错误
    if (isMainFrameRequest) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = '页面加载失败 ($statusCode)\n${errorResponse.reasonPhrase ?? 'Unknown Error'}\n\n这可能是网络问题或网站反爬虫保护。\n请稍后重试或检查网络连接。';
      });
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

  /// 获取优化的WebView设置
  InAppWebViewSettings _getWebViewSettings() {
    return InAppWebViewSettings(
      javaScriptEnabled: true,
      domStorageEnabled: true,
      disableContextMenu: true,
      disableDefaultErrorPage: true,
      textZoom: 100,
      // [增强浏览器仿真] 启用多窗口支持，某些网站可能需要
      supportMultipleWindows: true,
      allowsInlineMediaPlayback: true,
      disableLongPressContextMenuOnLinks: true,
      // [增强浏览器仿真] 启用缩放支持，更像真实浏览器
      supportZoom: true,
      builtInZoomControls: true,
      // [增强浏览器仿真] 隐藏缩放控件，但保持功能启用
      displayZoomControls: false,
      disableHorizontalScroll: false,
      disableVerticalScroll: false,
      // [深度反爬虫] 使用稳定的设备配置（将在onWebViewCreated中动态设置）
      userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1",
      allowFileAccess: true,
      allowContentAccess: true,
      cacheMode: CacheMode.LOAD_DEFAULT,
      clearCache: false,
      disableInputAccessoryView: true,
      // [反爬虫优化] 启用第三方Cookie支持
      thirdPartyCookiesEnabled: true,
      // [反爬虫优化] 启用混合内容模式
      // mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      // [反爬虫优化] 启用数据库存储
      databaseEnabled: true,
    );
  }

  @override
  void dispose() {
    webViewController?.dispose();
    _simulationManager?.dispose();
    super.dispose();
  }




}
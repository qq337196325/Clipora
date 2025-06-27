import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/view/article/article_web/utils/auto_generate_utils.dart';
import 'package:clipora/view/article/article_web/utils/web_utils.dart';
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
                          webViewController?.reload();
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
              initialUrlRequest: URLRequest(url: WebUri(articleController.articleUrl)),
              initialSettings: _getWebViewSettings(),
              onWebViewCreated: (controller) async {
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
                
                // 设置浏览器仿真功能
                await _setupBrowserSimulation(controller);

              },
              onLoadStart: (controller, url) {
                getLogger().i('🌐 开始加载Web页面: $url');
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              },
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
  GenerateMhtmlUtils generateMhtmlUtils = GenerateMhtmlUtils();

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
        errorMessage = '页面加载失败 ($statusCode)\n${errorResponse.reasonPhrase ?? 'Unknown Error'}\n\n部分网站可能会限制在第三方应用打开。';
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
      // [增强浏览器仿真] 禁用缩放功能，避免页面拖动问题
      supportZoom: false,
      builtInZoomControls: false,
      // [增强浏览器仿真] 隐藏缩放控件
      displayZoomControls: false,
      disableHorizontalScroll: true,
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
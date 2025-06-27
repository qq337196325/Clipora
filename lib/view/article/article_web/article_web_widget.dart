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
              initialUrlRequest: URLRequest(url: WebUri(articleController.articleUrl)),
              initialSettings: _getWebViewSettings(),
              onWebViewCreated: (controller) async {
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
                
                // 设置浏览器仿真功能
                // await _setupBrowserSimulation(controller);

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

  // 重试计数器 - 记录每个URL的重试次数
  final Map<String, int> _retryCountMap = {};

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
      
      // 清理当前URL的重试计数器，给手动重试一个全新的机会
      _retryCountMap.remove(articleController.articleUrl);
      
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
        // Android WebView 特有的反检测代码
        antiDetectionScript = '''
        (function() {
          console.log('🤖 Android WebView 反检测脚本启动');
          
          // 1. 隐藏 Android WebView 特征
          try {
            // 删除 Android WebView 的特有属性
            delete window.AndroidBridge;
            delete window.android;
            delete window.prompt;
            
            // 伪装 Chrome 浏览器特征
            Object.defineProperty(navigator, 'webdriver', {
              get: () => undefined,
              configurable: true
            });
            
            // 隐藏 automation 标记
            Object.defineProperty(navigator, 'webdriver', {
              get: () => false,
              configurable: true
            });
            
            // 模拟 Chrome 的 plugins
            Object.defineProperty(navigator, 'plugins', {
              get: () => [
                {name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer'},
                {name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai'},
                {name: 'Native Client', filename: 'internal-nacl-plugin'}
              ],
              configurable: true
            });
            
            // 模拟 Chrome 的语言设置
            Object.defineProperty(navigator, 'languages', {
              get: () => ['zh-CN', 'zh', 'en-US', 'en'],
              configurable: true
            });
            
            // 设置正确的设备内存（如果存在）
            if ('deviceMemory' in navigator) {
              Object.defineProperty(navigator, 'deviceMemory', {
                get: () => 8,
                configurable: true
              });
            }
            
            // 设置硬件并发数
            Object.defineProperty(navigator, 'hardwareConcurrency', {
              get: () => 8,
              configurable: true
            });
            
            console.log('✅ Android WebView 反检测完成');
            
          } catch (e) {
            console.warn('⚠️ Android 反检测部分失败:', e);
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
      // Android Chrome 的典型请求头
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
        'sec-ch-ua': '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"',
        'sec-ch-ua-mobile': '?1',
        'sec-ch-ua-platform': '"Android"',
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
      // 基础JavaScript支持
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      
      // 存储和数据支持 - 重要：让网站认为是真实浏览器
      domStorageEnabled: true,
      databaseEnabled: true,
      thirdPartyCookiesEnabled: true,
      
      // 根据平台使用对应的User-Agent - 关键优化点
      userAgent: _getPlatformOptimizedUserAgent(),
      
      // 网络和安全设置
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      allowsInlineMediaPlayback: true,
      allowsBackForwardNavigationGestures: true,
      
      // 禁用一些可能暴露身份的特性
      disableDefaultErrorPage: true,
      disableContextMenu: false, // 保持启用以模拟真实浏览器
      
      // 缓存策略 - 使用默认缓存策略
      cacheMode: CacheMode.LOAD_DEFAULT,
      clearCache: false,
      
      // 布局和交互
      textZoom: 100,
      supportZoom: false, // 禁用缩放避免页面拖动问题
      builtInZoomControls: false,
      displayZoomControls: false,
      
      // 滚动控制
      disableHorizontalScroll: true,
      disableVerticalScroll: false,
      
      // 多媒体支持
      mediaPlaybackRequiresUserGesture: false,
      
      // 文件访问权限
      allowFileAccess: true,
      allowContentAccess: true,
    );
    
    // 添加平台特定设置
    if (Platform.isIOS) {
      settings.disableInputAccessoryView = true;
      settings.suppressesIncrementalRendering = false;
    }
    
    return settings;
  }
  
  /// 获取平台优化的User-Agent
  String _getPlatformOptimizedUserAgent() {
    if (Platform.isAndroid) {
      // Android Chrome User-Agent - 使用最新版本
      return "Mozilla/5.0 (Linux; Android 14; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36";
    } else if (Platform.isIOS) {
      // iOS Safari User-Agent - 使用最新版本
      return "Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1";
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
    super.dispose();
  }




}
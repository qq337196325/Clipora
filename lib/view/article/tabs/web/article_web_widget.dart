import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/view/article/tabs/web/utils/auto_generate_utils.dart';
import 'package:clipora/view/article/tabs/web/utils/web_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

import '../../../../basics/logger.dart';
import '../../../../basics/web_view/settings.dart';
import '../../../../basics/web_view/utils.dart';
import '../../controller/article_controller.dart';
import 'browser_simulation/core/browser_simulation_manager.dart';
import 'browser_simulation/utils/js_injector.dart';

class ArticleWebWidget extends StatefulWidget {
  final String? url;
  final int? articleId;
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  // 状态驱动的属性 - 移除了公共方法，完全使用状态驱动
  final bool shouldGenerateSnapshot;
  final bool shouldGenerateMarkdown;

  // 回调函数替代公共方法 - 实现基于回调的父子组件通信
  final Function(String snapshotPath)? onSnapshotCreated;
  final VoidCallback? onMarkdownGenerated;
  final Function(bool success, String? error, String? snapshotPath)?
      onSnapshotGenerationComplete;
  final Function(bool success, String? error)? onMarkdownGenerationComplete;

  const ArticleWebWidget({
    super.key,
    this.url,
    this.articleId,
    this.onScroll,
    this.onTap,
    this.contentPadding = EdgeInsets.zero,
    // 状态驱动的属性
    this.shouldGenerateSnapshot = false,
    this.shouldGenerateMarkdown = false,
    // 回调函数
    this.onSnapshotCreated,
    this.onMarkdownGenerated,
    this.onSnapshotGenerationComplete,
    this.onMarkdownGenerationComplete,
  });

  @override
  State<ArticleWebWidget> createState() => ArticlePageState();
}

class ArticlePageState extends State<ArticleWebWidget> with ArticlePageBLoC {
  double _lastScrollY = 0.0;

  // 状态监听标记
  bool _lastShouldGenerateSnapshot = false;
  bool _lastShouldGenerateMarkdown = false;

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
                      'i18n_article_网页加载失败'.tr,
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
                        label: Text(
                          'i18n_article_重新加载'.tr,
                          style: const TextStyle(
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
              initialUrlRequest: URLRequest(
                  url: WebUri(articleController.articleUrl),
                  headers: WebViewSettings.getPlatformOptimizedHeaders()),
              initialSettings:
                  _getSnapshotOptimizedWebViewSettings(), // 【初始化设置】: 使用针对快照优化的WebView设置
              onWebViewCreated: (controller) async {
                // 【WebView创建完成回调】: 当WebView实例创建成功后调用，通常在这里获取WebView控制器。
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
              },
              // 【页面开始加载回调】: 当一个页面开始加载时触发。
              onLoadStart: (controller, url) {
                getLogger().i('🌐 开始加载Web页面: $url');
                setState(() {
                  isLoading = true;

                  // 修复了一个bug：在预热跳转时，错误的URL（如zhihu://）可能导致错误页面闪现。
                  // 现在，只有在加载http/https协议时才重置错误状态。
                  if (url != null &&
                      (url.scheme == 'http' || url.scheme == 'https')) {
                    hasError = false;
                  }
                });
              },
              // 【页面加载完成回调】: 当一个页面加载结束后触发，是执行JS注入等操作的最佳时机。
              onLoadStop: (controller, url) async {
                if (hasError) {
                  return;
                }

                getLogger().i('🌐 Web页面加载完成: $url');
                setState(() {
                  isLoading = false;
                });

                // 注入存储仿真代码
                await _jsInjector?.injectStorageSimulation(controller);

                // 注入平台特定的反检测代码
                await WebViewUtils.injectPlatformSpecificAntiDetection(
                    controller);

                // 注入内边距和修复页面宽度
                final padding =
                    widget.contentPadding.resolve(Directionality.of(context));
                await WebViewUtils.fixPageWidth(controller, padding);

                // 注入移动端弹窗处理脚本 - 恢复滚动功能
                await WebViewUtils.injectMobilePopupHandler(controller);

                // 注入页面点击监听器
                await _injectPageClickListener();

                // 页面加载完成后进行优化设置
                finalizeWebPageOptimization(url, webViewController);

                // 检查是否是预热首页加载完成，如果是，则跳转到目标URL
                if (await _handleWarmupRedirect(url, webViewController!)) {
                  getLogger().w('❌ 这个是预热，所以终止执行:');

                  return; // 如果是预热跳转，则中止后续操作，等待目标页面加载
                }

                // _debouncedGenerateSnapshot();
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
                  final direction = scrollY > _lastScrollY
                      ? ScrollDirection.reverse
                      : ScrollDirection.forward;
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

  // 移除了 generateSnapshot() 公共方法
  // 现在使用状态驱动的方式：通过 shouldGenerateSnapshot 属性和 _handleSnapshotGeneration() 方法

  /// 优化的URL导航处理
  Future<NavigationActionPolicy> _handleOptimizedUrlNavigation(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
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
        url.startsWith('zhihu')) {
      // 明确拦截知乎的App拉起协议
      getLogger().w('⚠️ 拦截应用跳转scheme: $url');
      return NavigationActionPolicy.CANCEL;
    }

    // 允许正常的HTTP/HTTPS链接
    getLogger().d('✅ 允许正常HTTP跳转: $url');
    return NavigationActionPolicy.ALLOW;
  }
}

/// @deprecated This mixin should be refactored to use state-driven approach
/// instead of direct method calls. Consider using callbacks and state variables.
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

  // 添加防抖Timer，避免generateSnapshot多次执行
  Timer? _generateSnapshotTimer;

  double _lastScrollY = 0.0;


  // 状态监听标记
  bool _lastShouldGenerateSnapshot = false;
  bool _lastShouldGenerateMarkdown = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化状态监听标记
    _lastShouldGenerateSnapshot = widget.shouldGenerateSnapshot;
    _lastShouldGenerateMarkdown = widget.shouldGenerateMarkdown;

    _initializeBrowserSimulation();
  }

  @override
  void didUpdateWidget(ArticleWebWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 监听快照生成状态变化
    if (widget.shouldGenerateSnapshot != _lastShouldGenerateSnapshot) {
      _lastShouldGenerateSnapshot = widget.shouldGenerateSnapshot;
      if (widget.shouldGenerateSnapshot) {
        _handleSnapshotGeneration();
      }
    }

    // 监听Markdown生成状态变化
    if (widget.shouldGenerateMarkdown != _lastShouldGenerateMarkdown) {
      _lastShouldGenerateMarkdown = widget.shouldGenerateMarkdown;
      if (widget.shouldGenerateMarkdown) {
        _handleMarkdownGeneration();
      }
    }
  }

  /// 处理快照生成（状态驱动）
  Future<void> _handleSnapshotGeneration() async {
    try {
      getLogger().i('📸 开始状态驱动的快照生成');

      generateMhtmlUtils.webViewController = webViewController;
      final filePath = await generateMhtmlUtils.generateSnapshot();

      if (filePath.isEmpty) {
        widget.onSnapshotGenerationComplete?.call(false, '保存快照失败', null);
        BotToast.showText(text: 'i18n_article_保存快照失败'.tr);
        return;
      }

      final updateStatus = await generateMhtmlUtils.updateArticleSnapshot(
          filePath, articleController.articleId);

      if (!updateStatus) {
        widget.onSnapshotGenerationComplete?.call(false, '保存快照到数据库失败', filePath);
        BotToast.showText(text: 'i18n_article_保存快照到数据库失败'.tr);
        return;
      }

      // 成功回调
      widget.onSnapshotCreated?.call(filePath);
      widget.onSnapshotGenerationComplete?.call(true, null, filePath);

      getLogger().i('✅ 状态驱动的快照生成完成: $filePath');
    } catch (e) {
      getLogger().e('❌ 状态驱动的快照生成失败: $e');
      widget.onSnapshotGenerationComplete?.call(false, e.toString(), null);
    }
  }

  /// 处理Markdown生成（状态驱动）
  Future<void> _handleMarkdownGeneration() async {
    try {
      getLogger().i('📝 开始状态驱动的Markdown生成');

      final filePath = await generateMhtmlUtils.generateSnapshot();
      if (filePath.isEmpty) {
        widget.onMarkdownGenerationComplete?.call(false, '保存快照失败');
        BotToast.showText(text: 'i18n_article_保存快照失败'.tr);
        return;
      }

      final uploadStatus = await generateMhtmlUtils.uploadSnapshotToServer(
          filePath, articleController.articleId);

      if (uploadStatus) {
        await generateMhtmlUtils.fetchMarkdownFromServer(
          article: articleController.currentArticle!,
          onMarkdownGenerated: () {
            widget.onMarkdownGenerated?.call();
            widget.onMarkdownGenerationComplete?.call(true, null);
          },
          isReCreate: true,
        );
        getLogger().i('✅ 状态驱动的Markdown生成完成');
      } else {
        widget.onMarkdownGenerationComplete?.call(false, '上传快照到服务器失败');
        getLogger().e('❌ 上传快照到服务器失败');
      }
    } catch (e) {
      getLogger().e('❌ 状态驱动的Markdown生成失败: $e');
      widget.onMarkdownGenerationComplete?.call(false, e.toString());
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
        // await _retryZhihuPage(webViewController!, articleController.articleUrl);
        return;
      }

      // 直接使用loadUrl方法重新加载页面，避免iOS上的reload问题
      try {
        await webViewController!.loadUrl(
            urlRequest: URLRequest(url: WebUri(articleController.articleUrl)));
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
              errorMessage = '${'i18n_article_重新加载失败提示'.tr}$reloadError';
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
          errorMessage = '${'i18n_article_重新加载时发生错误提示'.tr}$e';
        });
      }
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

      // 注册页面点击回调
      _setupPageClickHandler();

      getLogger().i('🎯 浏览器仿真功能初始化完成');
    } catch (e) {
      getLogger().e('❌ 浏览器仿真功能初始化失败: $e');
    }
  }

  /// 设置页面点击处理器
  void _setupPageClickHandler() {
    // 这个方法会在webViewController可用时被调用
    // 实际的Handler注册会在_injectPageClickListener中进行
  }

  /// 处理页面点击事件
  void _handlePageClick(List<dynamic> args) {
    getLogger().d('🎯 Web页面被点击');
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  /// 注入页面点击监听器
  Future<void> _injectPageClickListener() async {
    try {
      getLogger().d('🔄 开始注入Web页面点击监听器...');

      // 注册JavaScript Handler
      webViewController!.addJavaScriptHandler(
        handlerName: 'onPageClicked',
        callback: _handlePageClick,
      );

      await webViewController!.evaluateJavascript(source: '''
        (function() {
          // 防止重复注册
          if (window.webPageClickListenerInstalled) {
            console.log('⚠️ Web页面点击监听器已存在，跳过重复注册');
            return;
          }
          
          // 添加全局点击事件监听器
          document.addEventListener('click', function(e) {
            try {
              console.log('🎯 检测到Web页面点击');
              
              // 调用Flutter Handler
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('onPageClicked', {
                  timestamp: Date.now(),
                  target: e.target.tagName,
                  url: window.location.href
                });
                console.log('✅ Web页面点击数据已发送到Flutter');
              } else {
                console.error('❌ Flutter桥接不可用，无法发送Web页面点击数据');
              }
            } catch (error) {
              console.error('❌ 处理Web页面点击异常:', error);
            }
          }, false);
          
          // 标记监听器已安装
          window.webPageClickListenerInstalled = true;
          console.log('✅ Web页面点击监听器安装完成');
          
        })();
      ''');

      getLogger().i('✅ Web页面点击监听脚本注入成功');
    } catch (e) {
      getLogger().e('❌ 注入Web页面点击监听脚本失败: $e');
    }
  }

  /// 智能处理HTTP错误
  void _handleHttpError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceResponse errorResponse) {
    final url = request.url.toString();
    final statusCode = errorResponse.statusCode ?? 0;
    final domain = Uri.parse(url).host;

    getLogger().w('⚠️ HTTP错误: $statusCode - $url');

    // 检查是否是API请求错误（不影响主页面加载）
    final isApiRequest = WebViewUtils.isApiRequest(url);
    final isMainFrameRequest = request.isForMainFrame ?? false;

    if (isApiRequest && !isMainFrameRequest) {
      // API请求错误，不显示错误界面
      getLogger().i('📡 API请求失败，但不影响主页面: $url');
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
        errorMessage = WebViewUtils.generateHttpErrorMessage(
            statusCode, errorResponse.reasonPhrase, domain);
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
  Future<void> _handleHighProtectionSite403Error(
      InAppWebViewController controller, String url, String domain) async {
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

        await controller.loadUrl(
            urlRequest: URLRequest(url: WebUri(homepageUrl.toString())));

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
          errorMessage = 'i18n_article_网站访问被限制提示'.tr;
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
      getLogger()
          .i('⏰ 延迟 ${delaySeconds}s 后重试 (第${retryCount + 1}/$maxRetries次)');

      await Future.delayed(Duration(seconds: delaySeconds));

      // 检查组件是否仍然挂载
      if (!mounted) return;

      // 针对知乎的特殊处理
      if (domain.contains('zhihu.com')) {
        // await _retryZhihuPage(controller, url);
      } else {
        // 其他高防护网站的通用重试策略
        // await _retryWithEnhancedHeaders(controller, url);
      }
    } catch (e) {
      getLogger().e('❌ 处理高防护网站403错误失败: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'i18n_article_重试失败提示'.tr;
      });
    }
  }

  /// 检查并处理预热跳转
  /// 如果是预热加载，则返回true
  Future<bool> _handleWarmupRedirect(
      Uri? currentUrl, InAppWebViewController controller) async {
    if (_urlToLoadAfterWarmup != null &&
        currentUrl != null &&
        currentUrl.host == Uri.parse(_urlToLoadAfterWarmup!).host &&
        currentUrl.path == '/') {
      controller.stopLoading();
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

  /// 智能处理WebView各种错误
  void _handleWebViewError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error) {
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
    final isIgnorableError =
        WebViewUtils.isIgnorableError(errorType, url, domain);

    if (isIgnorableError && !isMainFrameRequest) {
      getLogger().i('📡 不影响主页面正常显示,忽略第三方资源错误: $url  - 错误类型: $errorType');
      return; // 不设置错误状态
    }

    // 只有主页面加载失败或关键错误才显示错误界面
    if (isMainFrameRequest) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = WebViewUtils.generateUserFriendlyErrorMessage(
            errorType, error.description ?? '', url);
      });
    }
  }

  /// 获取针对快照优化的WebView设置
  /// 确保生成快照时和显示快照时使用一致的设置
  InAppWebViewSettings _getSnapshotOptimizedWebViewSettings() {
    // 创建针对快照优化的WebView设置
    return InAppWebViewSettings(
      // --- 核心功能开关 ---
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,

      // --- 数据与存储 ---
      domStorageEnabled: true,
      databaseEnabled: true,
      thirdPartyCookiesEnabled: true,

      // --- 导航与拦截 ---
      useShouldOverrideUrlLoading: true,

      // --- 身份标识 ---
      userAgent: _getPlatformOptimizedUserAgent(),

      // --- 内容与安全策略 ---
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      allowsInlineMediaPlayback: true,
      allowsBackForwardNavigationGestures: true,

      // --- UI与错误页面 ---
      disableDefaultErrorPage: true,
      disableContextMenu: false,

      // --- 缓存策略 ---
      cacheMode: CacheMode.LOAD_DEFAULT,
      clearCache: false,

      // --- 布局与交互 ---
      textZoom: 100,
      supportZoom: true,
      builtInZoomControls: false,
      displayZoomControls: false,

      // --- 滚动控制 ---
      disableHorizontalScroll: true,
      disableVerticalScroll: false,

      // --- 文件访问权限 ---
      allowFileAccess: true,
      allowContentAccess: true,

      // === 快照优化专用设置 ===
      // 确保样式完整性
      forceDark: ForceDark.OFF, // 禁用强制暗色模式
      algorithmicDarkeningAllowed: false, // 禁用算法暗化

      // 优化渲染质量
      minimumFontSize: 0,
      defaultFontSize: 16,
      defaultFixedFontSize: 13,

      // 确保所有内容都能正确加载
      blockNetworkImage: false,
      blockNetworkLoads: false,
      loadsImagesAutomatically: true,

      // 优化布局一致性
      useWideViewPort: true,
      loadWithOverviewMode: true,

      // 禁用可能影响快照的功能
      mediaPlaybackRequiresUserGesture: false,
    );
  }

  /// 获取平台优化的User-Agent
  String _getPlatformOptimizedUserAgent() {
    if (Platform.isAndroid) {
      // Android Chrome User-Agent
      return "Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36";
    } else if (Platform.isIOS) {
      // iOS Safari User-Agent
      return "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1";
    } else {
      // 默认使用通用移动端User-Agent
      return "Mozilla/5.0 (Mobile; rv:109.0) Gecko/109.0 Firefox/119.0";
    }
  }

  /// 页面加载完成后的最终优化设置
  Future<void> finalizeWebPageOptimization(
      Uri? url, InAppWebViewController? controller) async {
    if (controller == null || url == null) return;

    try {
      getLogger().i('🎨 开始最终页面优化...');

      // 注入页面稳定化脚本
      await controller.evaluateJavascript(source: '''
        (function() {
          // 等待所有异步内容加载完成
          if (document.readyState !== 'complete') {
            window.addEventListener('load', function() {
              console.log('📄 页面完全加载完成');
            });
          }
          
          // 禁用可能影响快照的动画
          const style = document.createElement('style');
          style.textContent = `
            *, *::before, *::after {
              animation-duration: 0s !important;
              animation-delay: 0s !important;
              transition-duration: 0s !important;
              transition-delay: 0s !important;
            }
          `;
          document.head.appendChild(style);
          
          // 确保页面布局稳定
          document.body.offsetHeight;
          
          console.log('🎨 页面优化脚本执行完成');
        })();
      ''');
    } catch (e) {
      getLogger().e('❌ 页面最终优化失败: $e');
    }
  }

  @override
  void dispose() {
    if (webViewController != null) {
      webViewController?.dispose();
    }

    _simulationManager?.dispose();
    _retryCountMap.clear(); // 清理重试计数器
    _warmupAttemptedForUrl.clear(); // 清理预热状态
    super.dispose();
  }
}

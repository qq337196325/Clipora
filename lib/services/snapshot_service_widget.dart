import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../basics/logger.dart';
import '../basics/web_view/settings.dart';
import '../basics/web_view/utils.dart';
import '../basics/web_view/warmup_urls.dart';
import '../db/article/article_db.dart';
import '../db/article/service/article_service.dart';
import '../view/article/tabs/web/browser_simulation/core/browser_simulation_manager.dart';
import '../view/article/tabs/web/browser_simulation/utils/js_injector.dart';
import '../view/article/tabs/web/utils/auto_generate_utils.dart';
import '../view/article/tabs/web/utils/web_utils.dart';



class SnapshotServiceWidget extends StatefulWidget {
  const SnapshotServiceWidget({
    super.key,
  });

  @override
  State<SnapshotServiceWidget> createState() => SnapshotServiceWidgetState();
}

class SnapshotServiceWidgetState extends State<SnapshotServiceWidget> with SnapshotServiceBLoC {


  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: WebViewSettings.getWebViewSettings(),
      onWebViewCreated: (controller) async { // 【WebView创建完成回调】: 当WebView实例创建成功后调用，通常在这里获取WebView控制器。
        webViewController = controller;
        getLogger().i('🌐 Web页面WebView创建成功');
      },
      // onLoadStart: onLoadStart,
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
      onLoadStop: _onNormalLoadStop,
      onReceivedError: onReceivedError,
      onReceivedHttpError: (controller, request, errorResponse) {
        _handleHttpError(controller, request, errorResponse);
      },
      shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
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
  
  /// 获取服务状态
  bool get isServiceRunning => _serviceStarted;
}

mixin SnapshotServiceBLoC on State<SnapshotServiceWidget> {
  // 使用常量来管理时间，提高可读性和可维护性
  bool isLoadPerformWarmup = false; // 是否正在预热，如果是预热状态，不执行 onLoadStop

  // WebView相关
  InAppWebViewController? webViewController;
  URLRequest? currentUrlRequest;

  // 任务管理
  Timer? _snapshotTimer;
  Timer? _timeoutMonitorTimer;
  bool _isProcessing = false;
  bool _isLoadingSnapshot = false;
  bool _serviceStarted = false;
  ArticleDb? _currentArticle;
  Completer<void>? _warmupCompleter; // 用于同步预热流程

  // 工具类
  WarmupUrls warmupUrls = WarmupUrls();
  GenerateMhtmlUtils generateMhtmlUtils = GenerateMhtmlUtils();
  BrowserSimulationManager? _simulationManager;
  JSInjector? _jsInjector;

  final Map<String, bool> _warmupAttemptedForUrl = {};
  // 重试计数器 - 记录每个URL的重试次数
  final Map<String, int> _retryCountMap = {};
  bool isLoading = true;
  String? _urlToLoadAfterWarmup;
  bool hasError = false;
  String errorMessage = '';
  Timer? _generateSnapshotTimer;
  bool _isShowPermissionModel = false; // 是否显示申请权限模态框

  @override
  void initState() {
    super.initState();
    getLogger().i('SnapshotServiceWidget initState');
    // warmupUrls.apiUpdateWarmupUrls();
    // getLogger().w('执行 apiUpdateWarmupUrls 方法：测试完成后去除');
    
    // 使用 WidgetsBinding.instance.addPostFrameCallback 确保 Widget 完全构建后再初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeService();
    });
  }

  @override
  void dispose() {
    _stopService();
    super.dispose();
    getLogger().i('SnapshotServiceWidget dispose');
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    getLogger().i('🔧 开始初始化快照服务...');

    await _initializeBrowserSimulation();

    getLogger().i('🔧 准备自动启动快照服务...');
    _startService();
  }

  /// 启动服务
  void _startService() {
    if (_serviceStarted) return;
    
    _serviceStarted = true;
    getLogger().i('📸 快照服务已启动');
    
    // 启动快照生成定时任务
    _snapshotTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      processUnsnapshottedArticles();
    });
    
    // 启动超时监控定时任务
    _timeoutMonitorTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _monitorTimeoutArticles();
    });
  }

  /// 停止服务
  void _stopService() {
    if (!_serviceStarted) return;
    
    _serviceStarted = false;
    getLogger().i('📸 快照服务已停止');
    
    // 取消定时器
    _snapshotTimer?.cancel();
    _timeoutMonitorTimer?.cancel();
    
    // 重置状态
    _isProcessing = false;
    _isLoadingSnapshot = false;
    _currentArticle = null;
  }

  /// 监控超时的文章
  Future<void> _monitorTimeoutArticles() async {
    try {
      final timeoutArticles = await ArticleService.instance.getTimeoutProcessingArticles(timeoutSeconds: 50);
      
      if (timeoutArticles.isNotEmpty) {
        getLogger().w('⚠️ 发现 ${timeoutArticles.length} 篇文章处理超时，将状态设为生成失败');
        
        for (final article in timeoutArticles) {
          await ArticleService.instance.updateArticleMarkdownStatus(article.id, 2);
          getLogger().w('⚠️ 文章 "${article.title}" (ID: ${article.id}) 处理超时，已标记为生成失败');
        }
      }
    } catch (e) {
      getLogger().e('❌ 监控超时文章时出错: $e');
    }
  }



  /// 初始化浏览器仿真功能
  Future<void> _initializeBrowserSimulation() async {
    try {
      getLogger().i('🎯 开始初始化浏览器仿真功能...');
      // 强制重新创建BrowserSimulationManager实例，以确保获取干净的状态
      _simulationManager = BrowserSimulationManager();
      Get.put(_simulationManager!);
      
      _jsInjector = JSInjector(_simulationManager!.storageManager);
      getLogger().i('🎯 浏览器仿真功能初始化完成');
    } catch (e) {
      getLogger().e('❌ 浏览器仿真功能初始化失败: $e');
      // 即使浏览器仿真初始化失败，我们仍然可以继续运行快照服务
      getLogger().i('⚠️ 将在没有浏览器仿真的情况下继续运行快照服务');
    }
  }



  /// 开始进行生成快照
  Future<void> processUnsnapshottedArticles() async {
    getLogger().d('🔍 检查快照任务状态: _isProcessing=$_isProcessing, _isLoadingSnapshot=$_isLoadingSnapshot, mounted=$mounted, _serviceStarted=$_serviceStarted');

    // PermissionStatus status = await Permission.storage.status;
    // if (status != PermissionStatus.granted) {
    //   getLogger().w('🔄 检测到没有存储权限....');
    //   if(_isShowPermissionModel == true){
    //     return;
    //   }
    //   _isShowPermissionModel = true;
    //   await handleAndroidPermission();
    //   return;
    // }


    if (_isProcessing || _isLoadingSnapshot || !mounted || !_serviceStarted) {
      getLogger().i('🔍 检查快照任务状态: _isProcessing=$_isProcessing, _isLoadingSnapshot=$_isLoadingSnapshot, mounted=$mounted, _serviceStarted=$_serviceStarted');
      getLogger().i('🔄 快照任务正在处理中、Widget已销毁或服务未启动，跳过此次触发。');
      return;
    }
    _isProcessing = true;

    try {
      // getLogger().i('🔄 开始执行快照生成任务...');
      final articlesToProcess = await ArticleService.instance.getUnsnapshottedArticles();

      if (articlesToProcess.isEmpty) {
        return;
      }

      getLogger().i('发现 ${articlesToProcess.length} 篇文章需要生成快照，开始处理...');
      for (final article in articlesToProcess) {
        // 在处理每篇文章前检查Widget是否仍然存在且服务仍在运行
        if (!mounted || !_serviceStarted) {
          getLogger().i('🔄 Widget已销毁或服务已停止，停止快照处理');
          break;
        }
        await _generateAndUploadSnapshot(article);
        await Future.delayed(Duration(seconds: 10));
      }
    } catch (e) {
      getLogger().e('❌ 执行快照任务时出错: $e');
    } finally {
      _isProcessing = false;
      // getLogger().i('✅ 快照生成任务执行完毕。');
    }
  }

  Future<void> _generateAndUploadSnapshot(ArticleDb article) async {
    if (article.url.isEmpty) {
      getLogger().w('⚠️ 文章 "${article.title}" URL为空，无法生成快照。');
      return;
    }

    getLogger().i('🔄 开始为文章 "${article.title}" 生成快照...');
    
    // 设置状态为正在生成
    await ArticleService.instance.updateArticleMarkdownStatus(article.id, 3);
    
    final result = await _tryMhtmlSnapshot(article);
  }


  Future<void> _tryMhtmlSnapshot(ArticleDb article) async {
    _currentArticle = article;

    try {
      _isLoadingSnapshot = true;
      
      // 使用 webViewController 直接加载 URL，而不是 setState
      if (webViewController != null && mounted) {
        getLogger().i('🚀 使用 webViewController 加载 URL: ${article.url}');
        await webViewController!.loadUrl(
          urlRequest: URLRequest(
            url: WebUri(article.url),
            headers: WebViewSettings.getPlatformOptimizedHeaders(),
          ),
        );
      } else {
        final errorMsg = 'WebView controller not available or widget unmounted';
        getLogger().e('❌ $errorMsg. Cancelling snapshot.');
      }

    } catch (e) {
      getLogger().e('❌ MHTML快照整体流程出错: $e');
    } finally {
      _isLoadingSnapshot = false;
    }
  }

  /// WebView回调方法
  Future<void> onWebViewCreated(InAppWebViewController controller) async {
    webViewController = controller;
    getLogger().i('🌐 SnapshotServiceWidget WebView创建成功');
  }

  Future<void> onLoadStart(InAppWebViewController controller, WebUri? url) async {
    getLogger().i('🔄 开始加载页面: $url');
  }


  /// 正常页面加载完成回调
  Future<void> _onNormalLoadStop(InAppWebViewController controller, WebUri? url) async {

    getLogger().i('✅ 页面加载完成: $url');

    try {
      // 注入存储仿真代码
      await _jsInjector?.injectStorageSimulation(controller);

      // 注入平台特定的反检测代码
      await WebViewUtils.injectPlatformSpecificAntiDetection(controller);

      // 注入内边距和修复页面宽度
      const padding = EdgeInsets.symmetric(horizontal: 12.0);
      await WebViewUtils.fixPageWidth(controller, padding);


      await WebViewUtils.injectMobilePopupHandler(controller); // 注入移动端弹窗处理脚本
      finalizeWebPageOptimization(url, webViewController);     // 页面加载完成后进行优化设置

      if(isLoadPerformWarmup){
        isLoadPerformWarmup = false;
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri(_currentArticle!.url)));
        getLogger().w(' 当前是预热: $url');
        return;
      }

      /// 检查是否是预热首页加载完成，如果是，则跳转到目标URL
      /// 当发生请求错误的时候，尝试预热处理
      if (await _handleWarmupRedirect(url, webViewController!)) {
        getLogger().w('❌ 这个是预热，所以终止执行:');

        return; // 如果是预热跳转，则中止后续操作，等待目标页面加载
      }

      // 滚动页面以触发懒加载内容
      // await controller.evaluateJavascript(source: 'window.scrollTo(0, document.body.scrollHeight);');
      // await controller.evaluateJavascript(source: 'window.scrollTo(0, 0);');
      // await Future.delayed(const Duration(milliseconds: 800));

      /// onLoadStop 会存在多次请求的情况。所以需要等待5秒页面稳定下来
      _debouncedGenerateSnapshot();
    } catch (e) {
      getLogger().e('❌ 快照保存过程出错: $e');
    }
  }

  Future<void> onReceivedError(InAppWebViewController controller, WebResourceRequest request, WebResourceError error) async {
    getLogger().e('❌ 页面加载错误: ${error.description} (Code: ${error.type}, URL: ${request.url})');

  }


  /// 防抖执行generateSnapshot方法
  /// 等待5秒后执行，如果期间再次调用则重新计时
  void _debouncedGenerateSnapshot() {
    // 取消之前的定时器（如果存在）
    _generateSnapshotTimer?.cancel();

    getLogger().d('🕐 开始5秒防抖计时，等待generateSnapshot执行...');

    // 执行顺滑的滚动动画
    _performSmoothScroll();

    // 创建新的5秒定时器
    _generateSnapshotTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !hasError) {
        getLogger().i('✅ 5秒防抖完成，开始执行generateSnapshot');
        generateSnapshot();
      } else {
        getLogger().w('⚠️ 页面已销毁或有错误，跳过generateSnapshot执行');
      }
    });
  }

  /// 执行顺滑的滚动动画
  Future<void> _performSmoothScroll() async {
    if (webViewController == null) return;

    try {
      // 获取页面高度
      final pageHeight = await webViewController!.evaluateJavascript(
        source: 'document.body.scrollHeight || document.documentElement.scrollHeight;'
      );
      
      if (pageHeight == null) return;
      
      final height = int.tryParse(pageHeight.toString()) ?? 0;
      if (height <= 0) return;

      getLogger().d('📏 页面高度: $height，开始顺滑滚动...');

      // 顺滑滚动到底部
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          const scrollToBottom = () => {
            return new Promise((resolve) => {
              const startPosition = window.pageYOffset || document.documentElement.scrollTop;
              const targetPosition = document.body.scrollHeight - window.innerHeight;
              const distance = targetPosition - startPosition;
              const duration = 1500; // 1.5秒滚动到底部
              let startTime = null;
              
              const animation = (currentTime) => {
                if (startTime === null) startTime = currentTime;
                const timeElapsed = currentTime - startTime;
                const progress = Math.min(timeElapsed / duration, 1);
                
                // 使用缓动函数使动画更自然
                const easeInOut = progress => {
                  return progress < 0.5 
                    ? 2 * progress * progress 
                    : 1 - Math.pow(-2 * progress + 2, 2) / 2;
                };
                
                const currentPosition = startPosition + (distance * easeInOut(progress));
                window.scrollTo(0, currentPosition);
                
                if (progress < 1) {
                  requestAnimationFrame(animation);
                } else {
                  resolve();
                }
              };
              
              requestAnimationFrame(animation);
            });
          };
          
          const scrollToTop = () => {
            return new Promise((resolve) => {
              const startPosition = window.pageYOffset || document.documentElement.scrollTop;
              const distance = -startPosition;
              const duration = 1000; // 1秒滚动到顶部
              let startTime = null;
              
              const animation = (currentTime) => {
                if (startTime === null) startTime = currentTime;
                const timeElapsed = currentTime - startTime;
                const progress = Math.min(timeElapsed / duration, 1);
                
                // 使用缓动函数
                const easeOut = progress => {
                  return 1 - Math.pow(1 - progress, 3);
                };
                
                const currentPosition = startPosition + (distance * easeOut(progress));
                window.scrollTo(0, currentPosition);
                
                if (progress < 1) {
                  requestAnimationFrame(animation);
                } else {
                  resolve();
                }
              };
              
              requestAnimationFrame(animation);
            });
          };
          
          // 执行滚动序列
          scrollToBottom().then(() => {
            // 在底部停留一段时间，让懒加载内容加载
            setTimeout(() => {
              scrollToTop();
            }, 800);
          });
        })();
      ''');

      getLogger().d('✅ 顺滑滚动动画已启动');
    } catch (e) {
      getLogger().e('❌ 执行顺滑滚动时出错: $e');
      // 如果顺滑滚动失败，回退到原来的简单滚动
      webViewController?.evaluateJavascript(source: 'window.scrollTo(0, document.body.scrollHeight);');
      await Future.delayed(const Duration(milliseconds: 800));
      webViewController?.evaluateJavascript(source: 'window.scrollTo(0, 0);');
    }
  }

  generateSnapshot() async {
    generateMhtmlUtils.webViewController = webViewController;
    final filePath = await generateMhtmlUtils.generateSnapshot();
    getLogger().i(' 快照路径: $filePath   $_currentArticle');



    if (_currentArticle != null && filePath != "") {
      await generateMhtmlUtils.updateArticleSnapshot(filePath, _currentArticle!.id);
      final uploadStatus = await generateMhtmlUtils.uploadSnapshotToServer(filePath, _currentArticle!.id);

      if (uploadStatus) {
        _currentArticle!.mhtmlPath = filePath;
        _currentArticle!.isGenerateMhtml = true;
        await generateMhtmlUtils.fetchMarkdownFromServer(
          article: _currentArticle!,
          onMarkdownGenerated: () {
            getLogger().i('✅ 文章快照和Markdown处理完成，更新文章状态');
            ArticleService.instance.updateArticleMarkdownStatus(_currentArticle!.id, 1);
          },
        );
      } else {
        // 上传失败，设置状态为生成失败
        getLogger().e('❌ 快照上传失败，状态已更新为生成失败');
      }
    }
  }

  /// 检查并处理预热跳转
  /// 如果是预热加载，则返回true
  Future<bool> _handleWarmupRedirect(Uri? currentUrl, InAppWebViewController controller) async {
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

  /// 智能处理HTTP错误
  void _handleHttpError(InAppWebViewController controller, WebResourceRequest request, WebResourceResponse errorResponse) {
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
        errorMessage = WebViewUtils.generateHttpErrorMessage(statusCode, errorResponse.reasonPhrase, domain);
      });
    }
  }

  /// 检查是否是高防护网站
  bool _isHighProtectionSite(String domain) {
    final highProtectionSites = [
      'zhihu.com',
      'www.zhihu.com',
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

        isLoadPerformWarmup = true;
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri(homepageUrl.toString())));

        // 预热策略已启动，直接返回，等待首页加载完成后的回调
        return;
      }


      isLoadPerformWarmup = false;
      // 如果预热策略已尝试过，则进入常规的重试流程
      getLogger().w('🔄 开始处理高防护网站403错误: $domain');

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

    } catch (e) {
      getLogger().e('❌ 处理高防护网站403错误失败: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = '重试失败\n\n请稍后手动重试或使用浏览器访问。';
      });
    }
  }

}

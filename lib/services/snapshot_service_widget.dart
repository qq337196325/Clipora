import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../basics/logger.dart';
import '../basics/web_view/settings.dart';
import '../basics/web_view/utils.dart';
import '../basics/web_view/warmup_urls.dart';
import '../db/article/article_db.dart';
import '../db/article/article_service.dart';
import '../view/article/article_web/browser_simulation/core/browser_simulation_manager.dart';
import '../view/article/article_web/browser_simulation/utils/js_injector.dart';
import '../view/article/article_web/utils/auto_generate_utils.dart';
import '../view/article/article_web/utils/web_utils.dart';

enum SnapshotType {
  mhtml,
  html,
}

class SnapshotResult {
  final String? filePath;
  final SnapshotType type;
  final bool success;
  final String? error;

  SnapshotResult({
    this.filePath,
    required this.type,
    required this.success,
    this.error,
  });
}

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
      onLoadStop: _onLoadStopDispatcher,
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
  
  /// 手动触发快照处理（外部调用接口）
  Future<void> triggerSnapshotProcessing() async {
    await processUnsnapshottedArticles();
  }
  
  /// 启动快照服务
  void startService() {
    if (!_serviceStarted) {
      _startService();
    }
  }
  
  /// 停止快照服务
  void stopService() {
    if (_serviceStarted) {
      _stopService();
    }
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

  @override
  void initState() {
    super.initState();
    getLogger().i('SnapshotServiceWidget initState');
    warmupUrls.apiUpdateWarmupUrls();
    getLogger().w('执行 apiUpdateWarmupUrls 方法：测试完成后去除');
    
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
    
    await _initializePermissions();
    await _initializeBrowserSimulation();


    getLogger().i('🔧 准备自动启动快照服务...');
    _startService();
  }

  /// 启动服务
  void _startService() {
    if (_serviceStarted) return;
    
    _serviceStarted = true;
    getLogger().i('📸 快照服务已启动');
    
    // 启动定时任务
    _snapshotTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      processUnsnapshottedArticles();
    });
  }

  /// 停止服务
  void _stopService() {
    if (!_serviceStarted) return;
    
    _serviceStarted = false;
    getLogger().i('📸 快照服务已停止');
    
    // 取消定时器
    _snapshotTimer?.cancel();
    
    // 重置状态
    _isProcessing = false;
    _isLoadingSnapshot = false;
    _currentArticle = null;
  }

  /// 获取存储权限
  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.storage.request();
      getLogger().i('存储权限状态: $status');
    } catch (e) {
      getLogger().e('❌ 请求存储权限失败: $e');
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
        await Future.delayed(Duration(seconds: 2));
      }
    } catch (e) {
      getLogger().e('❌ 执行快照任务时出错: $e');
    } finally {
      _isProcessing = false;
      getLogger().i('✅ 快照生成任务执行完毕。');
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

  /// onLoadStop的回调分发
  Future<void> _onLoadStopDispatcher(InAppWebViewController controller, WebUri? url) async {
    if (isLoadPerformWarmup) {
      await _onWarmupLoadStop(controller, url);
    } else {
      await _onNormalLoadStop(controller, url);
    }
  }

  /// 预热加载完成回调
  Future<void> _onWarmupLoadStop(InAppWebViewController controller, WebUri? url) async {
    getLogger().i('✅ 预热页面加载完成: $url');
    if (_warmupCompleter != null && !_warmupCompleter!.isCompleted) {
      _warmupCompleter!.complete();
    }
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

      // 注入移动端弹窗处理脚本
      await WebViewUtils.injectMobilePopupHandler(controller);

      // 页面加载完成后进行优化设置
      finalizeWebPageOptimization(url, webViewController);


      if(isLoadPerformWarmup){
        getLogger().w(' 当前是预热: $url');
        return;
      }

      // 等待页面初步渲染
      await Future.delayed(const Duration(milliseconds: 500));

      // 滚动页面以触发懒加载内容
      await controller.evaluateJavascript(source: 'window.scrollTo(0, document.body.scrollHeight);');
      await Future.delayed(const Duration(milliseconds: 500));
      await controller.evaluateJavascript(source: 'window.scrollTo(0, 0);');
      await Future.delayed(const Duration(milliseconds: 500));

      // 生成MHTML快照
      generateMhtmlUtils.webViewController = webViewController;
      final filePath = await generateMhtmlUtils.generateSnapshot();
      await Future.delayed(const Duration(milliseconds: 500));
      getLogger().i(' 快照路径: $filePath   $_currentArticle');
      
      if (_currentArticle != null) {
        generateMhtmlUtils.updateArticleSnapshot(filePath, _currentArticle!.id);
        final uploadStatus = await generateMhtmlUtils.uploadSnapshotToServer(filePath, _currentArticle!.id);

        if (uploadStatus) {
          await generateMhtmlUtils.fetchMarkdownFromServer(
            article: _currentArticle!,
            onMarkdownGenerated: () {},
          );
          
          // 检查Markdown是否成功生成，通过查询文章的最新状态来判断
          final updatedArticle = await ArticleService.instance.getArticleById(_currentArticle!.id);
          if (updatedArticle != null && updatedArticle.markdownStatus == 1) {
            // fetchMarkdownFromServer内部已经设置了状态为1，这里只需要记录日志
            getLogger().i('✅ 文章快照和Markdown处理完成，状态已更新为已生成');
          } else {
            // Markdown获取失败，设置状态为生成失败
            await ArticleService.instance.updateArticleMarkdownStatus(_currentArticle!.id, 2);
            getLogger().e('❌ Markdown获取失败，状态已更新为生成失败');
          }
        } else {
          // 上传失败，设置状态为生成失败
          await ArticleService.instance.updateArticleMarkdownStatus(_currentArticle!.id, 2);
          getLogger().e('❌ 快照上传失败，状态已更新为生成失败');
        }
      }
    } catch (e) {
      getLogger().e('❌ 快照保存过程出错: $e');
      // 处理过程中出现异常，设置状态为生成失败
      if (_currentArticle != null) {
        await ArticleService.instance.updateArticleMarkdownStatus(_currentArticle!.id, 2);
        getLogger().e('❌ 快照处理异常，状态已更新为生成失败: $e');
      }
    } finally {
      controller.stopLoading();
    }
  }

  Future<void> onReceivedError(InAppWebViewController controller, WebResourceRequest request, WebResourceError error) async {
    getLogger().e('❌ 页面加载错误: ${error.description} (Code: ${error.type}, URL: ${request.url})');

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

        isLoadPerformWarmup = true;
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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';

import '../../basics/logger.dart';


/// ArticleMhtmlWidget - 快照文章显示组件
/// 
/// 使用示例：
/// ```dart
/// class ParentPage extends StatefulWidget {
///   @override
///   State<ParentPage> createState() => _ParentPageState();
/// }
/// 
/// class _ParentPageState extends State<ParentPage> {
///   final GlobalKey<_ArticlePageState> _articleKey = GlobalKey();
///   String currentMhtmlPath = 'path/to/snapshot.mhtml';
/// 
///   // 重新加载当前快照
///   Future<void> _reloadCurrentSnapshot() async {
///     await _articleKey.currentState?.reloadSnapshot();
///   }
/// 
///   // 加载新的快照文件
///   Future<void> _loadNewSnapshot(String newPath) async {
///     await _articleKey.currentState?.loadNewSnapshot(newPath);
///   }
/// 
///   // 检查加载状态
///   bool get isLoading => _articleKey.currentState?.isSnapshotLoading ?? false;
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: ArticleMhtmlWidget(
///         key: _articleKey,
///         mhtmlPath: currentMhtmlPath,
///         onScroll: (direction, scrollY) {
///           // 处理滚动事件
///         },
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: _reloadCurrentSnapshot,
///         child: Icon(Icons.refresh),
///       ),
///     );
///   }
/// }
/// ```

class ArticleMhtmlWidget extends StatefulWidget {
  final String mhtmlPath;  // MHTML文件路径
  final String? title;     // 可选的标题显示
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final VoidCallback? onTap; // 添加点击回调
  final EdgeInsetsGeometry contentPadding;
  
  const ArticleMhtmlWidget({
    super.key,
    required this.mhtmlPath,
    this.title,
    this.onScroll,
    this.onTap, // 添加点击回调
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  State<ArticleMhtmlWidget> createState() => ArticleMhtmlWidgetState();
}

class ArticleMhtmlWidgetState extends State<ArticleMhtmlWidget> with ArticlePageBLoC {
  double _lastScrollY = 0.0;

  /// 重新加载当前快照
  /// 供外部调用的公开方法
  Future<void> reloadSnapshot() async {
    await _reloadMhtml();
  }

  /// 加载新的快照文件
  /// [newMhtmlPath] 新的MHTML文件路径
  /// 供外部调用的公开方法，用于加载新生成的快照
  Future<void> loadNewSnapshot(String newMhtmlPath) async {
    getLogger().i('🔄 加载新的快照文件: $newMhtmlPath');
    
    // 重置状态
    setState(() {
      hasError = false;
      errorMessage = '';
      isLoading = true;
    });
    
    // 先验证新的快照文件
    final isValid = await validateSnapshotFile(newMhtmlPath);
    if (!isValid) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    
    // 如果路径相同，直接重新加载
    if (newMhtmlPath == widget.mhtmlPath) {
      await _reloadMhtml();
      return;
    }
    
    // 如果路径不同，需要重新加载新的URL
    if (webViewController != null) {
      final newUrl = 'file://$newMhtmlPath';
      getLogger().i('📄 加载新快照URL: $newUrl');
      await webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
    } else {
      // 如果WebView控制器不存在，重新初始化
      await _initializeMhtmlView();
    }
  }

  /// 获取当前快照的加载状态
  /// 供外部查询使用
  bool get isSnapshotLoading => isLoading;
  
  /// 获取当前快照是否有错误
  /// 供外部查询使用
  bool get hasSnapshotError => hasError;
  
  /// 获取当前快照的错误信息
  /// 供外部查询使用
  String get snapshotErrorMessage => errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // 加载进度条
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
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'i18n_article_快照加载失败'.tr,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _reloadMhtml(),
                    child: Text('i18n_article_重新加载'.tr),
                  ),
                ],
              ),
            ),
          // WebView显示MHTML内容
          if (!hasError)
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(mhtmlFileUrl)),
                // initialSettings: WebViewSettings.getWebViewSettings(),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  getLogger().i('MHTML WebView创建成功');
                },
                onLoadStart: (controller, url) {
                  getLogger().i('开始加载MHTML: $url');
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                },
                onLoadStop: (controller, url) async {
                  getLogger().i('MHTML加载完成: $url');
                  setState(() {
                    isLoading = false;
                  });


                  // 注入移动端弹窗处理脚本 - 恢复滚动功能
                  // await WebViewUtils.injectMobilePopupHandler(controller);

                  // // 注入页面点击监听器
                  // await _injectPageClickListener();
                  //
                  // // 页面加载完成后进行优化设置
                  // finalizeWebPageOptimization(url,webViewController);
                  //
                  // // 注入内边距
                  // final padding = widget.contentPadding.resolve(Directionality.of(context));
                  // controller.evaluateJavascript(source: '''
                  //   document.body.style.paddingTop = '${padding.top}px';
                  //   document.body.style.paddingBottom = '${padding.bottom}px';
                  //   document.body.style.paddingLeft = '${padding.left}px';
                  //   document.body.style.paddingRight = '${padding.right}px';
                  //   document.documentElement.style.scrollPaddingTop = '${padding.top}px';
                  // ''');
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    loadingProgress = progress / 100;
                  });
                },
                onReceivedError: (controller, request, error) {
                  getLogger().e('MHTML加载错误', error: error.description);
                  
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'i18n_article_加载错误文件路径'.trParams({
                      'description': error.description ?? '',
                      'path': widget.mhtmlPath
                    });
                  });
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  getLogger().e('MHTML HTTP错误', error: '${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                  
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'i18n_article_HTTP错误'.trParams({
                      'statusCode': errorResponse.statusCode.toString(),
                      'reasonPhrase': errorResponse.reasonPhrase ?? ''
                    });
                  });
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
                shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
                // 设置控制台消息处理
                onConsoleMessage: (controller, consoleMessage) {
                  getLogger().d('MHTML Console: ${consoleMessage.message}');
                },
              ),
            ),
        ],
      );
  }
}

mixin ArticlePageBLoC on State<ArticleMhtmlWidget> {
  // WebView控制器
  InAppWebViewController? webViewController;
  
  // 加载状态
  bool isLoading = true;
  double loadingProgress = 0.0;
  
  // 错误状态
  bool hasError = false;
  String errorMessage = '';
  
  // 获取MHTML文件的URL
  String get mhtmlFileUrl {
    final file = File(widget.mhtmlPath);
    if (!file.existsSync()) {
      getLogger().e('MHTML文件不存在: ${widget.mhtmlPath}');
      return '';
    }
    
    // 使用file协议加载本地文件
    return 'file://${widget.mhtmlPath}';
    // return '${widget.mhtmlPath}';
  }
  
  // WebView设置 - 针对MHTML文件优化
  InAppWebViewSettings webViewSettings = InAppWebViewSettings(
    // ==== 核心功能设置 ====
    javaScriptEnabled: true,
    domStorageEnabled: true,
    
    // ==== 本地文件访问设置 ====
    allowFileAccess: true,
    allowContentAccess: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    
    // ==== 缓存设置 ====
    clearCache: false,
    cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
    
    // ==== 安全设置（适用于本地文件） ====
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    
    // ==== 用户代理 ====
    userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
    
    // ==== 视口和缩放设置 ====
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    
    // ==== 基本设置 ====
    blockNetworkImage: false,
    blockNetworkLoads: false,
    loadsImagesAutomatically: true,
    
    // ==== 媒体设置 ====
    mediaPlaybackRequiresUserGesture: false,
    
    // ==== 滚动条设置 ====
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: true,
    
    // ==== 禁用URL跳转拦截（本地文件不需要） ====
    useShouldOverrideUrlLoading: false,
  );

  @override
  void initState() {
    super.initState();
    _initializeMhtmlView();
  }

  /// 处理页面点击事件
  void _handlePageClick(List<dynamic> args) {
    getLogger().d('🎯 MHTML页面被点击');
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  /// 注入页面点击监听器
  Future<void> _injectPageClickListener() async {
    try {
      getLogger().d('🔄 开始注入MHTML页面点击监听器...');
      
      // 注册JavaScript Handler
      webViewController!.addJavaScriptHandler(
        handlerName: 'onPageClicked',
        callback: _handlePageClick,
      );
      
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          // 防止重复注册
          if (window.mhtmlPageClickListenerInstalled) {
            console.log('⚠️ MHTML页面点击监听器已存在，跳过重复注册');
            return;
          }
          
          // 添加全局点击事件监听器
          document.addEventListener('click', function(e) {
            try {
              console.log('🎯 检测到MHTML页面点击');
              
              // 调用Flutter Handler
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('onPageClicked', {
                  timestamp: Date.now(),
                  target: e.target.tagName,
                  type: 'mhtml'
                });
                console.log('✅ MHTML页面点击数据已发送到Flutter');
              } else {
                console.error('❌ Flutter桥接不可用，无法发送MHTML页面点击数据');
              }
            } catch (error) {
              console.error('❌ 处理MHTML页面点击异常:', error);
            }
          }, false);
          
          // 标记监听器已安装
          window.mhtmlPageClickListenerInstalled = true;
          console.log('✅ MHTML页面点击监听器安装完成');
          
        })();
      ''');

      getLogger().i('✅ MHTML页面点击监听脚本注入成功');

    } catch (e) {
      getLogger().e('❌ 注入MHTML页面点击监听脚本失败: $e');
    }
  }

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  // 初始化MHTML视图
  Future<void> _initializeMhtmlView() async {
    try {
      getLogger().i('📄 初始化MHTML视图，文件路径: ${widget.mhtmlPath}');
      
      // 检查文件是否存在
      final file = File(widget.mhtmlPath);
      if (!file.existsSync()) {
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件不存在'.trParams({'path': widget.mhtmlPath});
          isLoading = false;
        });
        return;
      }
      
      // 检查文件大小
      final fileSize = await file.length();
      getLogger().i('📄 MHTML文件大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      if (fileSize == 0) {
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件为空'.trParams({'path': widget.mhtmlPath});
          isLoading = false;
        });
        return;
      }
      
      getLogger().i('✅ MHTML文件检查通过，准备加载');
      
    } catch (e) {
      getLogger().e('❌ 初始化MHTML视图失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '${'i18n_article_初始化失败'.tr}$e';
        isLoading = false;
      });
    }
  }

  // 重新加载MHTML
  Future<void> _reloadMhtml() async {
    getLogger().i('🔄 重新加载MHTML快照');
    
    setState(() {
      hasError = false;
      errorMessage = '';
      isLoading = true;
    });
    
    if (webViewController != null) {
      await webViewController!.reload();
    } else {
      // 如果WebView控制器不存在，重新初始化
      await _initializeMhtmlView();
    }
    setState(() {});
  }

  // 验证快照文件是否有效
  Future<bool> validateSnapshotFile(String filePath) async {
    try {
      final file = File(filePath);
      
      // 检查文件是否存在
      if (!file.existsSync()) {
        getLogger().e('❌ 快照文件不存在: $filePath');
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件不存在'.trParams({'path': filePath});
        });
        return false;
      }
      
      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize == 0) {
        getLogger().e('❌ 快照文件为空: $filePath');
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件为空'.trParams({'path': filePath});
        });
        return false;
      }
      
      getLogger().i('✅ 快照文件验证通过: $filePath (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      return true;
      
    } catch (e) {
      getLogger().e('❌ 验证快照文件失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '${'i18n_article_初始化失败'.tr}$e';
      });
      return false;
    }
  }

  // 获取当前页面信息（调试用）
  Future<void> getPageInfo() async {
    if (webViewController == null) return;
    
    try {
      final url = await webViewController!.getUrl();
      final title = await webViewController!.getTitle();
      
      getLogger().i('📄 当前页面信息:');
      getLogger().i('  URL: $url');
      getLogger().i('  标题: $title');
      
    } catch (e) {
      getLogger().e('❌ 获取页面信息失败: $e');
    }
  }

  /// 优化的URL导航处理
  Future<NavigationActionPolicy> _handleOptimizedUrlNavigation(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final uri = navigationAction.request.url!;
    final url = uri.toString();

    getLogger().d('🌐 URL跳转拦截: $url');

    // 检查是否是自定义scheme（非http/https）
    if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('file://')) {
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

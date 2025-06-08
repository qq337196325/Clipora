import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'dart:async';

import '../../basics/logger.dart';


class ArticleMhtmlWidget extends StatefulWidget {
  final String mhtmlPath;  // MHTML文件路径
  final String? title;     // 可选的标题显示
  
  const ArticleMhtmlWidget({
    super.key,
    required this.mhtmlPath,
    this.title,
  });

  @override
  State<ArticleMhtmlWidget> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticleMhtmlWidget> with ArticlePageBLoC {

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
                    '快照加载失败',
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
                    child: const Text('重新加载'),
                  ),
                ],
              ),
            ),
          // WebView显示MHTML内容
          if (!hasError)
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(mhtmlFileUrl)),
                initialSettings: webViewSettings,
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
                onLoadStop: (controller, url) {
                  getLogger().i('MHTML加载完成: $url');
                  setState(() {
                    isLoading = false;
                  });
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
                    errorMessage = '加载错误: ${error.description}\n文件路径: ${widget.mhtmlPath}';
                  });
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  getLogger().e('MHTML HTTP错误', error: '${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                  
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'HTTP错误: ${errorResponse.statusCode}\n${errorResponse.reasonPhrase}';
                  });
                },
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
          errorMessage = '快照文件不存在\n路径: ${widget.mhtmlPath}';
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
          errorMessage = '快照文件为空\n路径: ${widget.mhtmlPath}';
          isLoading = false;
        });
        return;
      }
      
      getLogger().i('✅ MHTML文件检查通过，准备加载');
      
    } catch (e) {
      getLogger().e('❌ 初始化MHTML视图失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '初始化失败: $e';
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
}

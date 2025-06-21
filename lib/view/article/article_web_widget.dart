import 'package:clipora/view/article/utils/web_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'dart:collection';
import 'package:get/get.dart';

import '../../basics/logger.dart';
import 'components/web_webview_pool_manager.dart';
import 'controller/article_controller.dart';
import 'utils/snapshot_utils.dart';
import '../../db/article/article_service.dart';
import '../../api/user_api.dart';


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
    await generateMHTMLSnapshot();
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
                  '网页加载失败',
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
              ],
            ),
          ),
        // WebView
        if (!hasError)
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(articleController.articleUrl)),
              initialSettings: WebWebViewPoolManager().getOptimizedSettings(),
              initialUserScripts: UnmodifiableListView(WebWebViewPoolManager().getOptimizedUserScripts()),
              onWebViewCreated: (controller) {
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
                
                // 使用优化的WebView配置
                _setupOptimizedWebView(controller);
              },
              onLoadStart: (controller, url) {
                getLogger().i('🌐 开始加载Web页面: $url');
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              },
              onLoadStop: (controller, url) {
                getLogger().i('🌐 Web页面加载完成: $url');
                setState(() {
                  isLoading = false;
                });
                
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
                _checkAndGenerateSnapshotIfNeeded().catchError((e) {
                  getLogger().e('❌ 自动检查快照失败: $e');
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  loadingProgress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                getLogger().e('❌ WebView加载错误: ${error.description}', error: {
                  'type': error.type,
                  'url': request.url,
                  'method': request.method,
                  'headers': request.headers,
                });
                
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = '错误代码: ${error.type}\n错误描述: ${error.description}\nURL: ${request.url}';
                });
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                getLogger().e('❌ HTTP错误: ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'HTTP错误: ${errorResponse.statusCode}\n${errorResponse.reasonPhrase}\nURL: ${request.url}';
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
              // 使用优化的URL跳转处理
              shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
              // 使用优化的资源请求拦截
              shouldInterceptRequest: _handleOptimizedResourceRequest,
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

  /// 优化的资源请求处理
  Future<WebResourceResponse?> _handleOptimizedResourceRequest(
    InAppWebViewController controller, 
    WebResourceRequest request
  ) async {
    final url = request.url.toString();
    
    // 如果是API请求，记录并优化处理
    if (url.contains('api.juejin.cn') || 
        url.contains('api.toutiao.com') ||
        url.contains('api.douban.com')) {
      getLogger().d('🌐 拦截API请求: ${url.substring(0, 100)}...');
      
      // 这里可以添加更多的请求优化逻辑
      // 比如添加缓存、请求去重等
    }
    
    // 返回null表示使用默认处理
    return null;
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

  @override
  void initState() {
    super.initState();
    // 确保Web页面优化器已初始化
    _ensureWebOptimizer();
  }

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  /// 确保Web页面优化器已初始化
  void _ensureWebOptimizer() {
    WebWebViewPoolManager().initialize().catchError((e) {
      getLogger().e('❌ Web页面优化器初始化失败: $e');
    });
  }

  /// 设置优化的WebView
  Future<void> _setupOptimizedWebView(InAppWebViewController controller) async {
    try {
      getLogger().i('🎯 开始设置优化的Web页面WebView...');
      
      // 检查优化器是否已准备就绪
      if (WebWebViewPoolManager().isOptimized) {
        getLogger().i('✅ 使用预热的Web页面优化配置');
        await WebWebViewPoolManager().setupOptimizedWebView(controller);
      } else {
        getLogger().w('⚠️ 优化器未准备就绪，使用传统方式设置');
        await _setupTraditionalWebView(controller);
      }
      
      getLogger().i('✅ Web页面WebView设置完成');
    } catch (e) {
      getLogger().e('❌ 设置优化WebView失败: $e');
      // 降级到传统方式
      await _setupTraditionalWebView(controller);
    }
  }

  /// 传统方式设置WebView（备用）
  Future<void> _setupTraditionalWebView(InAppWebViewController controller) async {
    try {
      getLogger().i('🔧 使用传统方式设置WebView...');
      
      // 注入传统CORS处理脚本
      await controller.evaluateJavascript(source: getTraditionalCorsScript());
      
      getLogger().i('✅ 传统WebView设置完成');
    } catch (e) {
      getLogger().e('❌ 传统WebView设置失败: $e');
    }
  }

  /// 生成MHTML快照并保存到本地
  Future<void> generateMHTMLSnapshot() async {
    await SnapshotUtils.generateAndProcessSnapshot(
      webViewController: webViewController,
      articleId: articleController.articleId,
      onSnapshotCreated: widget.onSnapshotCreated,
      onLoadingStateChanged: (loading) {
        if (mounted) {
          setState(() {
            isLoading = loading;
          });
        }
      },
      onSuccess: (status) async { /// 生成快照并且上传到服务器以后执行的操作
        getLogger().i('🎯 MHTML快照上传成功，开始获取Markdown内容');
        await _fetchMarkdownFromServer();
      }
    );
  }

  /// 检查是否需要自动生成MHTML快照
  Future<void> _checkAndGenerateSnapshotIfNeeded() async {
    // 检查是否有文章ID
    try {
      // 等待3秒，确保网页完全加载稳定
      await Future.delayed(const Duration(seconds: 2));
      
      // 再次检查WebView是否还存在（防止用户已经离开页面）
      if (webViewController == null || !mounted) {
        getLogger().w('⚠️ WebView已销毁或页面已离开，跳过自动生成快照');
        return;
      }
      
      getLogger().i('🔍 检查文章是否需要生成MHTML快照，文章ID: ${articleController.articleId}');
      
      // 从数据库获取文章信息
      final article = articleController.currentArticle;
      
      if (article == null) {
        getLogger().w('⚠️ 未找到文章，ID: ${articleController.articleId}');
        return;
      }
      
      // 检查是否已经生成过快照
      if (article.isGenerateMhtml) {
        getLogger().i('✅ 文章已有MHTML快照，跳过自动生成: ${article.title}');
        return;
      }
      
      // 检查URL是否有效
      if (article.url.isEmpty) {
        getLogger().w('⚠️ 文章URL为空，无法生成快照: ${article.title}');
        return;
      }
      
      getLogger().i('🚀 开始自动生成MHTML快照: ${article.title}');
      
      // 生成快照（使用现有的方法）
      await generateMHTMLSnapshot();
      
      getLogger().i('✅ 自动MHTML快照生成完成: ${article.title}');
      
    } catch (e) {
      getLogger().e('❌ 检查和生成MHTML快照失败: $e');
    }
  }

  /// 从服务端获取Markdown内容
  Future<void> _fetchMarkdownFromServer() async {
    try {
      // 获取当前文章
      final article = articleController.currentArticle;
      if (article == null) {
        getLogger().w('⚠️ 当前文章为空，无法获取Markdown');
        return;
      }

      // 检查是否有serviceId
      if (article.serviceId.isEmpty) {
        getLogger().w('⚠️ 文章serviceId为空，无法获取Markdown内容');
        return;
      }

      // 检查是否有serviceId
      if (article.markdownStatus != 0) {
        getLogger().w('⚠️ article的markdownStatus状态非0，不自动获取');
        return;
      }

      // 等待服务端处理MHTML转换为Markdown（延迟10秒让服务端有足够时间处理）
      getLogger().i('⏳ 等待服务端处理MHTML转Markdown，延迟10秒...');
      await Future.delayed(const Duration(seconds: 4));

      // 重试机制：最多重试3次，每次间隔5秒
      for (int retry = 0; retry < 5; retry++) {
        try {
          getLogger().i('🌐 第${retry + 1}次尝试从服务端获取Markdown内容，serviceId: ${article.serviceId}');
          
          final response = await UserApi.getArticleApi({
            'service_article_id': article.serviceId,
          });

          if (response['code'] == 0 && response['data'] != null) {
            final markdownContent = response['data']['markdown_content'] as String? ?? '';
            final title = response['data']['title'] as String? ?? '';

            getLogger().i('📊 服务端返回： 内容长度=${markdownContent.length}');
            
            if (markdownContent.isNotEmpty) {
              // Markdown已生成成功
              getLogger().i('✅ Markdown获取成功，长度: ${markdownContent.length}');
              await ArticleService.instance.updateArticleMarkdown(article.id, markdownContent,title);
              
              // 刷新当前文章数据
              await articleController.refreshCurrentArticle();
              
              // 通知父组件刷新 tabs
              widget.onMarkdownGenerated?.call();
              
              getLogger().i('🎉 Markdown内容已保存到本地数据库，已通知父组件刷新tabs');
              return;
            }
          } else {
            getLogger().e('❌ 获取Markdown失败: ${response['msg']}');
          }
        } catch (e) {
          getLogger().e('❌ 第${retry + 1}次获取Markdown失败: $e');
        }

        // 如果不是最后一次重试，等待5秒后再试
        if (retry < 2) {
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      getLogger().w('⚠️ 多次重试后仍无法获取Markdown内容，放弃');
      
    } catch (e) {
      getLogger().e('❌ _fetchMarkdownFromServer 失败: $e');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'dart:collection';

import '../../basics/logger.dart';
import 'components/web_webview_pool_manager.dart';
import 'utils/auto_expander.dart';
import 'utils/snapshot_utils.dart';
import '../../db/article/article_service.dart';


class ArticleWebWidget extends StatefulWidget {
  final Function(String)? onSnapshotCreated;
  final String? url;
  final int? articleId;  // 添加文章ID参数
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final EdgeInsetsGeometry contentPadding;
  
  const ArticleWebWidget({
    super.key,
    this.onSnapshotCreated,
    this.url,
    this.articleId,  // 添加文章ID参数
    this.onScroll,
    this.contentPadding = EdgeInsets.zero,
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
              initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
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
                _finalizeWebPageOptimization(url);
                
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
  // WebView控制器
  InAppWebViewController? webViewController;
  
  // 加载状态
  bool isLoading = true;
  double loadingProgress = 0.0;
  
  // 错误状态
  bool hasError = false;
  String errorMessage = '';
  
  // URL
  String get currentUrl => widget.url ?? '';
  
  // 获取文章ID
  int? get articleId => widget.articleId;

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
      await controller.evaluateJavascript(source: _getTraditionalCorsScript());
      
      getLogger().i('✅ 传统WebView设置完成');
    } catch (e) {
      getLogger().e('❌ 传统WebView设置失败: $e');
    }
  }

  /// 页面加载完成后的最终优化
  Future<void> _finalizeWebPageOptimization(WebUri? url) async {
    if (webViewController == null) return;
    
    try {
      getLogger().i('🎨 执行页面加载完成后的优化...');
      
      // 注入页面完成后的优化脚本
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          console.log('🎨 执行页面完成后优化...');
          
          // 延迟执行，确保页面完全渲染
          setTimeout(function() {
            // 强制移除水平滚动条的终极方案
            function eliminateHorizontalScroll() {
              console.log('🔧 开始消除水平滚动条...');
              
              // 1. 强制设置body和html的样式
              document.documentElement.style.overflowX = 'hidden';
              document.documentElement.style.maxWidth = '100%';
              document.body.style.overflowX = 'hidden';
              document.body.style.maxWidth = '100%';
              document.body.style.width = '100%';
              
              // 2. 检查并修复所有可能导致水平滚动的元素
              const allElements = document.querySelectorAll('*');
              let fixedCount = 0;
              
              allElements.forEach(function(el) {
                const rect = el.getBoundingClientRect();
                const computed = window.getComputedStyle(el);
                
                // 检查元素是否超出视口宽度
                if (rect.width > window.innerWidth || 
                    rect.right > window.innerWidth) {
                  
                  // 记录原始宽度用于调试
                  const originalWidth = computed.width;
                  
                  // 应用修复样式
                  el.style.maxWidth = '100%';
                  el.style.boxSizing = 'border-box';
                  
                  // 特殊处理不同类型的元素
                  const tagName = el.tagName.toLowerCase();
                  
                  if (tagName === 'img' || tagName === 'video') {
                    el.style.width = '100%';
                    el.style.height = 'auto';
                  } else if (tagName === 'table') {
                    el.style.width = '100%';
                    el.style.tableLayout = 'fixed';
                  } else if (tagName === 'pre' || tagName === 'code') {
                    el.style.whiteSpace = 'pre-wrap';
                    el.style.wordWrap = 'break-word';
                    el.style.overflowX = 'auto';
                  } else if (computed.position === 'fixed' || computed.position === 'absolute') {
                    // 对于定位元素，确保不超出边界
                    if (rect.right > window.innerWidth) {
                      el.style.right = '0';
                      el.style.left = 'auto';
                      el.style.maxWidth = '100%';
                    }
                  }
                  
                  fixedCount++;
                  console.log('🔧 修复超宽元素:', tagName, '原始宽度:', originalWidth);
                }
              });
              
              // 3. 强制刷新布局
              document.body.offsetHeight; // 触发重排
              
              // 4. 最后检查是否还有水平滚动
              const hasHorizontalScroll = document.documentElement.scrollWidth > document.documentElement.clientWidth;
              
              console.log('📊 优化结果:', {
                '修复元素数量': fixedCount,
                '视口宽度': window.innerWidth,
                '文档宽度': document.documentElement.scrollWidth,
                '是否还有水平滚动': hasHorizontalScroll
              });
              
              if (hasHorizontalScroll) {
                console.warn('⚠️ 仍存在水平滚动，应用强制CSS覆盖');
                // 最后的强制手段
                const forceStyle = document.createElement('style');
                forceStyle.innerHTML = `
                  * { 
                    max-width: 100% !important; 
                    box-sizing: border-box !important; 
                  }
                  html, body { 
                    overflow-x: hidden !important; 
                    width: 100% !important;
                  }
                `;
                document.head.appendChild(forceStyle);
              }
              
              return fixedCount;
            }
            
            // 执行消除水平滚动
            const fixedCount = eliminateHorizontalScroll();
            
            // 优化已加载的图片
            const images = document.querySelectorAll('img');
            let optimizedCount = 0;
            
            images.forEach(function(img) {
              if (!img.style.maxWidth) {
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                optimizedCount++;
              }
            });
            
            console.log('✅ 页面优化完成，修复了 ' + fixedCount + ' 个超宽元素，优化了 ' + optimizedCount + ' 张图片');
            
            // 触发性能统计
            if (window.performance && window.performance.timing) {
              const timing = window.performance.timing;
              const loadTime = timing.loadEventEnd - timing.navigationStart;
              console.log('📊 页面加载耗时: ' + loadTime + 'ms');
            }
          }, 200);
        })();
      ''');
      
      // 应用自动展开规则
      if (url != null) {
        AutoExpander.apply(webViewController!, url);
      }
      
      // 输出性能统计
      final stats = WebWebViewPoolManager().getPerformanceStats();
      getLogger().i('📊 Web页面性能统计: $stats');
      
      getLogger().i('✅ 页面最终优化完成');
    } catch (e) {
      getLogger().e('❌ 页面最终优化失败: $e');
    }
  }

  /// 获取传统CORS脚本（备用）
  String _getTraditionalCorsScript() {
    return '''
    (function() {
      console.log('🔧 注入传统CORS处理脚本...');
      
      const originalFetch = window.fetch;
      window.fetch = function(url, options = {}) {
        if (typeof url === 'string' && url.includes('api.juejin.cn')) {
          options.mode = 'no-cors';
          options.credentials = 'include';
        }
        return originalFetch.call(this, url, options).catch(error => {
          console.warn('⚠️ Fetch请求失败:', error);
          return Promise.resolve(new Response('{}', { status: 200 }));
        });
      };
      
      console.log('✅ 传统CORS处理脚本注入完成');
    })();
  ''';
  }

  // 生成MHTML快照并保存到本地
  Future<void> generateMHTMLSnapshot() async {
    await SnapshotUtils.generateAndProcessSnapshot(
      webViewController: webViewController,
      articleId: articleId,
      onSnapshotCreated: widget.onSnapshotCreated,
      onLoadingStateChanged: (loading) {
        if (mounted) {
          setState(() {
            isLoading = loading;
          });
        }
      },
    );
  }

  /// 检查是否需要自动生成MHTML快照
  Future<void> _checkAndGenerateSnapshotIfNeeded() async {
    // 检查是否有文章ID
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，跳过自动生成快照');
      return;
    }
    
    try {
      // 等待3秒，确保网页完全加载稳定
      await Future.delayed(const Duration(seconds: 3));
      
      // 再次检查WebView是否还存在（防止用户已经离开页面）
      if (webViewController == null || !mounted) {
        getLogger().w('⚠️ WebView已销毁或页面已离开，跳过自动生成快照');
        return;
      }
      
      getLogger().i('🔍 检查文章是否需要生成MHTML快照，文章ID: $articleId');
      
      // 从数据库获取文章信息
      final article = await ArticleService.instance.getArticleById(articleId!);
      
      if (article == null) {
        getLogger().w('⚠️ 未找到文章，ID: $articleId');
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
}
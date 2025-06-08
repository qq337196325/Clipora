import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import '../../basics/logger.dart';
import 'components/markdown_webview_pool_manager.dart';


class ArticleMarkdownWidget extends StatefulWidget {
  final String? url;
  final String markdownContent;

  const ArticleMarkdownWidget({
    super.key,
    this.url,
    required this.markdownContent,
  });

  @override
  State<ArticleMarkdownWidget> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticleMarkdownWidget> with ArticlePageBLoC {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 使用优化的WebView
          _buildOptimizedWebView(),
          
          // 加载指示器
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在准备文章内容...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '使用预热WebView提升性能',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptimizedWebView() {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: WebViewPoolManager().getHtmlTemplate(),
        mimeType: "text/html",
        encoding: "utf-8",
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _setupWebView();
      },
      onLoadStop: (controller, url) async {
        if (_webViewController != null) {
          await _finalizeWebViewSetup();
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        getLogger().d('WebView Console: ${consoleMessage.message}');
      },
    );
  }
}

mixin ArticlePageBLoC on State<ArticleMarkdownWidget> {
  InAppWebViewController? _webViewController;
  String get markdownContent => widget.markdownContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 确保WebView资源管理器已初始化
    _ensureResourceManagerInitialized();
  }

  @override
  void dispose() {
    _webViewController?.dispose();
    super.dispose();
  }

  /// 确保资源管理器已初始化
  void _ensureResourceManagerInitialized() {
    WebViewPoolManager().initialize().catchError((e) {
      getLogger().e('❌ 资源管理器初始化失败: $e');
    });
  }

  /// WebView创建时的设置
  Future<void> _setupWebView() async {
    if (_webViewController == null) return;
    
    try {
      getLogger().i('🎯 开始设置WebView...');
      
      // 检查资源是否已预热
      if (WebViewPoolManager().isResourcesReady) {
        getLogger().i('✅ 使用预热资源快速设置');
        await WebViewPoolManager().setupOptimizedWebView(_webViewController!);
      } else {
        getLogger().w('⚠️ 资源未预热，使用传统方式加载');
        await _setupTraditionalResources();
      }
      
      getLogger().i('✅ WebView设置完成');
    } catch (e) {
      getLogger().e('❌ WebView设置失败: $e');
      // 降级到传统方式
      await _setupTraditionalResources();
    }
  }

  /// WebView加载完成后的最终设置
  Future<void> _finalizeWebViewSetup() async {
    if (_webViewController == null) return;
    
    try {
      // 设置图片点击处理器
      await _setupImageClickHandler();
      
      // 渲染内容
      await _renderMarkdownContent();
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      
      getLogger().i('✅ WebView最终设置完成');
      
      // 输出性能统计
      final stats = WebViewPoolManager().getPerformanceStats();
      getLogger().i('📊 性能统计: $stats');
    } catch (e) {
      getLogger().e('❌ WebView最终设置失败: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// 渲染Markdown内容
  Future<void> _renderMarkdownContent() async {
    if (_webViewController == null || markdownContent.isEmpty) return;

    try {
      // 优先使用WebView池管理器的优化渲染方法
      await WebViewPoolManager().renderMarkdownContent(_webViewController!, markdownContent);
      getLogger().d('✅ Markdown内容渲染完成');
    } catch (e) {
      getLogger().e('❌ 优化渲染失败，尝试备用方法: $e');
      // 备用渲染方法
      await _renderTraditionalMarkdownContent();
    }
  }

  /// 传统资源设置方法（备用）
  Future<void> _setupTraditionalResources() async {
    getLogger().i('🔧 使用传统方式加载资源...');
    
    if (_webViewController == null) return;

    try {
      final List<Future> resourceFutures = [
        _loadGitHubCSS(),
        _loadMarkedJS(),
        _loadHighlightJS(),
      ];
      
      await Future.wait(resourceFutures);
      await _configureMarked();
      
      getLogger().i('✅ 传统方式资源加载完成');
    } catch (e) {
      getLogger().e('❌ 传统方式资源加载失败: $e');
    }
  }

  Future<void> _loadGitHubCSS() async {
    try {
      final String githubCss = await rootBundle.loadString('assets/js/github.min.css');
      await _webViewController!.evaluateJavascript(source: '''
        var githubStyles = document.getElementById('github-styles');
        if (githubStyles) {
          githubStyles.textContent = ${_escapeForJS(githubCss)};
        }
      ''');
      getLogger().d('✅ GitHub CSS 传统加载完成');
    } catch (e) {
      getLogger().e('❌ GitHub CSS 传统加载失败: $e');
    }
  }

  Future<void> _loadMarkedJS() async {
    try {
      final String markedJs = await rootBundle.loadString('assets/js/marked.min.js');
      await _webViewController!.evaluateJavascript(source: markedJs);
      getLogger().d('✅ marked.js 传统加载完成');
    } catch (e) {
      getLogger().e('❌ marked.js 传统加载失败: $e');
    }
  }

  Future<void> _loadHighlightJS() async {
    try {
      final String highlightJs = await rootBundle.loadString('assets/js/highlight.min.js');
      await _webViewController!.evaluateJavascript(source: highlightJs);
      getLogger().d('✅ highlight.js 传统加载完成');
    } catch (e) {
      getLogger().e('❌ highlight.js 传统加载失败: $e');
    }
  }

  Future<void> _configureMarked() async {
    await _webViewController!.evaluateJavascript(source: '''
      if (typeof marked !== 'undefined') {
        marked.setOptions({
          highlight: function(code, lang) {
            if (typeof hljs !== 'undefined') {
              if (lang && hljs.getLanguage(lang)) {
                try {
                  return hljs.highlight(code, { language: lang }).value;
                } catch (err) {
                  return code;
                }
              }
              return hljs.highlightAuto(code).value;
            }
            return code;
          },
          langPrefix: 'hljs language-',
          breaks: true,
          gfm: true
        });
      }
    ''');
  }

  /// 传统的Markdown渲染方法
  Future<void> _renderTraditionalMarkdownContent() async {
    if (_webViewController == null || markdownContent.isEmpty) return;

    try {
      await _webViewController!.evaluateJavascript(source: '''
        if (typeof marked !== 'undefined' && marked.parse) {
          try {
            var content = ${_escapeForJS(markdownContent)};
            var htmlContent = marked.parse(content);
            var contentDiv = document.getElementById('content');
            if (contentDiv) {
              contentDiv.innerHTML = '<div class="markdown-body">' + htmlContent + '</div>';
              
              var images = document.querySelectorAll('.markdown-body img');
              images.forEach(function(img) {
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                img.style.display = 'block';
                img.style.margin = '16px auto';
                img.style.cursor = 'pointer';
              });
              
              console.log('✅ 传统方式Markdown渲染完成');
            }
          } catch (error) {
            console.error('❌ 传统方式Markdown渲染失败:', error);
            document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 内容解析失败</h3><p>' + error.message + '</p></div>';
          }
        } else {
          console.error('❌ marked.js 未加载');
          document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 解析器未就绪</h3><p>正在加载Markdown解析器，请稍后重试</p></div>';
        }
      ''');
    } catch (e) {
      getLogger().e('传统方式渲染Markdown内容失败: $e');
    }
  }

  String _escapeForJS(String content) {
    return '`${content.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`';
  }

  Future<void> _setupImageClickHandler() async {
    if (_webViewController == null) return;
    
    _webViewController!.addJavaScriptHandler(
      handlerName: 'onImageClicked',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String imageSrc = data['src'] ?? '';
        final String imageAlt = data['alt'] ?? '';
        final int imageWidth = data['width'] ?? 0;
        final int imageHeight = data['height'] ?? 0;
        
        getLogger().d('🖼️ 图片被点击: $imageSrc');
        _handleImageClicked(imageSrc, imageAlt, imageWidth, imageHeight);
      },
    );
  }

  void _handleImageClicked(String src, String alt, int width, int height) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                src,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('图片加载失败', style: TextStyle(color: Colors.grey[600])),
                        if (alt.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(alt, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

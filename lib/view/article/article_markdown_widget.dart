import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';
import '../../basics/logger.dart';
import '../../db/article/article_db.dart';
import 'components/markdown_webview_pool_manager.dart';
import 'utils/article_markdown_logic.dart';


class ArticleMarkdownWidget extends StatefulWidget {
  final String? url;
  final String markdownContent;
  final ArticleDb? article;
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final EdgeInsetsGeometry contentPadding;

  const ArticleMarkdownWidget({
    super.key,
    this.url,
    required this.markdownContent,
    this.article,
    this.onScroll,
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  State<ArticleMarkdownWidget> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticleMarkdownWidget> with ArticleMarkdownLogic {
  @override
  final GlobalKey _webViewKey = GlobalKey();

  @override
  String get markdownContent => widget.markdownContent;
  
  @override
  ArticleDb? get article => widget.article;
  
  @override
  GlobalKey<State<StatefulWidget>> get webViewKey => _webViewKey;

  double _lastScrollY = 0.0;

  @override
  void initState() {
    super.initState();
    initLogic();
  }

  @override
  void dispose() {
    disposeLogic();
    webViewController?.dispose();
    getLogger().d('✅ ArticleMarkdownWidget销毁完成');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: Stack(
        children: [
          _buildOptimizedWebView(),
          if (isLoading) _buildLoadingIndicator(),
          if (isVisuallyRestoring) _buildRestoringIndicator(),
        ],
      ),
    );
  }

  Widget _buildOptimizedWebView() {
    return Container(
      padding: EdgeInsets.only(left: 4,right: 4),
      child: InAppWebView(
        key: _webViewKey,
        initialData: InAppWebViewInitialData(
          data: WebViewPoolManager().getHtmlTemplate(),
          mimeType: "text/html",
          encoding: "utf-8",
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          disableContextMenu: true,
          disableDefaultErrorPage: true,
          textZoom: 100,
          supportMultipleWindows: false,
          allowsInlineMediaPlayback: true,
          disableLongPressContextMenuOnLinks: true,
          supportZoom: false,
          builtInZoomControls: false,
          displayZoomControls: false,
          disableHorizontalScroll: false,
          disableVerticalScroll: false,
          userAgent: "Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 InkwellReader/1.0",
          allowFileAccess: true,
          allowContentAccess: true,
          cacheMode: CacheMode.LOAD_DEFAULT,
          clearCache: false,
          disableInputAccessoryView: true,
        ),
        onWebViewCreated: onWebViewCreated,
        onLoadStop: (controller, url) {
          onWebViewLoadStop();
          
          // 设置背景透明并注入内边距
          final padding = widget.contentPadding.resolve(Directionality.of(context));
          controller.evaluateJavascript(source: '''
            document.body.style.backgroundColor = 'transparent';
            document.documentElement.style.backgroundColor = 'transparent';
            document.body.style.paddingTop = '${padding.top}px';
            document.body.style.paddingBottom = '${padding.bottom}px';
            document.body.style.paddingLeft = '${padding.left}px';
            document.body.style.paddingRight = '${padding.right}px';
          ''');
        },
        onScrollChanged: (controller, x, y) {
          final scrollY = y.toDouble();
          // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
          if ((scrollY - _lastScrollY).abs() > 15) {
            final direction = scrollY > _lastScrollY ? ScrollDirection.reverse : ScrollDirection.forward;
            widget.onScroll?.call(direction, scrollY);
            _lastScrollY = scrollY;
          }
          
          markUnsavedChanges();
        },
      ),
    );
  }

  Widget _buildRestoringIndicator() {
    return Container(
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
              '正在恢复阅读位置...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
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
    );
  }
}

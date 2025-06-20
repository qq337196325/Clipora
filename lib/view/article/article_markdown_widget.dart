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
  final GlobalKey _webViewKey = GlobalKey();

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
    // 如果markdownContent为空，显示空状态界面
    if (markdownContent.isEmpty) {
      return _buildEmptyState(context);
    }

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

  /// 构建空状态界面
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: widget.contentPadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.article_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // 标题
            Text(
              '暂无图文内容',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            
            // 描述
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '该文章尚未生成图文版本。\n请切换到网页标签查看原始内容，或等待系统自动生成图文版本。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // 提示信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '图文版本将在后台自动生成',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedWebView() {
    return Container(
      // padding: EdgeInsets.only(left: 4,right: 4),
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

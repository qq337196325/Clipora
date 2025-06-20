import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '/view/article/components/article_markdown_add_note_dialog.dart';
import '../../../basics/logger.dart';
import '../../../db/article/article_db.dart';
import '../../../db/article/article_service.dart';
import '../components/markdown_webview_pool_manager.dart';
import '../components/article_markdown_selection_menu.dart';
import 'article_markdown_js_manager.dart';

/// ArticleMarkdownWidget的业务逻辑核心。
///
/// 这个mixin包含了状态管理、WebView交互、阅读位置追踪、
/// 文本选择处理以及生命周期管理等所有非UI的逻辑。
mixin ArticleMarkdownLogic<T extends StatefulWidget> on State<T> {
  // === 可访问的属性 ===
  @protected
  InAppWebViewController? webViewController;
  @protected
  ArticleDb? get article;
  @protected
  GlobalKey get webViewKey;
  @protected
  late ArticleMarkdownJsManager jsManager;
  @protected
  EdgeInsetsGeometry get contentPadding;

  // === 内部状态 ===
  bool isLoading = true;
  bool isVisuallyRestoring = false;
  Timer? _positionSaveTimer;
  String _currentSessionId = '';
  bool _isRestoringPosition = false;
  bool _isDisposed = false;
  
  DateTime? _lastSaveTime;
  static const Duration _saveInterval = Duration(seconds: 20);
  static const Duration _minSaveInterval = Duration(seconds: 5);

  OverlayEntry? _selectionMenuOverlay;
  OverlayEntry? _backgroundCatcher;
  String _currentSelectedText = '';
  
  late final AppLifecycleObserver _lifecycleObserver;

  // === 初始化和销毁 ===
  void initLogic() {
    _lifecycleObserver = AppLifecycleObserver(this);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _ensureResourceManagerInitialized();
    Future.microtask(() => _ensureLatestArticleData());
    _recordReadingStart();
  }

  void disposeLogic() {
    getLogger().d('🔄 ArticleMarkdownLogic开始销毁...');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    
    _hideCustomSelectionMenu();
    _positionSaveTimer?.cancel();
    
    if (webViewController != null && article != null) {
      _saveCurrentReadingPosition().catchError((e) {
        getLogger().d('⚠️ dispose时保存阅读位置失败: $e');
      });
    }
    getLogger().d('✅ ArticleMarkdownLogic销毁完成');
  }

  // === WebView 设置 ===
  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    jsManager = ArticleMarkdownJsManager(controller);
    _setupWebView();
    _setupTextSelectionHandlers();
    // WebView创建后，立即开始加载和渲染流程
    onWebViewLoadStop();
  }
  
  Future<void> _setupWebView() async {
    if (!_isWebViewAvailable()) return;
    try {
      if (WebViewPoolManager().isResourcesReady) {
        await WebViewPoolManager().setupOptimizedWebView(webViewController!);
      } else {
        await _setupTraditionalResources();
      }
    } catch (e) {
      getLogger().e('❌ WebView设置失败: $e');
      await _setupTraditionalResources();
    }
  }

  Future<void> onWebViewLoadStop() async {
    if (!_isWebViewAvailable()) return;
    try {
      await jsManager.injectAllScripts();
      await _setupImageClickHandler();
      await _renderMarkdownContent();
      
      await _restoreReadingPosition();
      
      _startPeriodicPositionSaving();
      getLogger().i('✅ WebView设置完成，页面已显示');
    } catch (e) {
      getLogger().e('❌ WebView最终设置失败: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  void _ensureResourceManagerInitialized() {
    if (_isDisposed) return;
    WebViewPoolManager().initialize().catchError((e) {
      getLogger().e('❌ 资源管理器初始化失败: $e');
    });
  }

  // === 阅读位置逻辑 ===
  void _recordReadingStart() {
    if (_isDisposed || article == null) return;
    
    article!.readingSessionId = _currentSessionId;
    article!.readingStartTime = DateTime.now().millisecondsSinceEpoch;
    article!.readCount += 1;
    getLogger().i('📖 开始阅读会话: $_currentSessionId');
  }

  void _startPeriodicPositionSaving() {
    if (_isDisposed) return;
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(_saveInterval, (timer) {
      if (_isDisposed || !_isWebViewAvailable()) {
        timer.cancel();
        return;
      }
      _saveCurrentReadingPosition();
    });
  }

  Future<void> _saveCurrentReadingPosition() async {
    if (_isDisposed || !_isWebViewAvailable() || article == null || _isRestoringPosition) return;
    if (!_shouldSave()) return;

    try {
      if (!await jsManager.isPositionTrackerAvailable()) {
        getLogger().w('⚠️ JavaScript追踪器不可用，重新注入...');
        if(!_isWebViewAvailable()) return;
        await jsManager.injectAllScripts(); // 尝试重新注入
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      final data = await jsManager.getCurrentVisibleElement();
      
      if (data != null) {
        final newScrollY = (data['scrollY'] ?? 0).toInt();
        final newElementId = data['id'] ?? '';
        final newProgress = (data['progress'] ?? 0.0).toDouble().clamp(0.0, 1.0);
        
        if ((newScrollY - article!.markdownScrollY).abs() > 50 || 
            newElementId != article!.currentElementId || 
            (newProgress - article!.readProgress).abs() > 0.01) {
          
          final oldProgress = article!.readProgress;

          article!
            ..markdownScrollY = newScrollY
            ..markdownScrollX = (data['scrollX'] ?? 0).toInt()
            ..currentElementId = newElementId
            ..currentElementText = data['text'] ?? ''
            ..currentElementOffset = (data['offsetTop'] ?? 0).toInt()
            ..viewportHeight = (data['viewportHeight'] ?? 0).toInt()
            ..contentHeight = (data['contentHeight'] ?? 0).toInt()
            ..readProgress = newProgress
            ..lastReadTime = DateTime.now()
            ..updatedAt = DateTime.now();
          
          final currentTime = DateTime.now().millisecondsSinceEpoch;
          if (article!.readingStartTime > 0) {
            article!.readDuration += ((currentTime - article!.readingStartTime) / 1000).round();
            article!.readingStartTime = currentTime;
          }
          
          getLogger().i('💾 保存阅读位置成功: 进度变化: ${(oldProgress * 100).toStringAsFixed(1)}% → ${(article!.readProgress * 100).toStringAsFixed(1)}%');
          await ArticleService.instance.saveArticle(article!);
          _lastSaveTime = DateTime.now();
        }
      }
    } catch (e) {
      if (e.toString().contains('disposed')) {
        getLogger().w('⚠️ WebView已销毁，跳过保存阅读位置');
      } else {
        getLogger().e('❌ 保存阅读位置异常: $e');
      }
    }
  }

  Future<void> _restoreReadingPosition() async {
    if (!_isWebViewAvailable() || article == null) {
      if (mounted && !_isDisposed) {
        setState(() { isLoading = false; });
      }
      return;
    }
    
    final hasPositionData = article!.markdownScrollY > 0 || article!.currentElementId.isNotEmpty;
    if (!hasPositionData) {
      getLogger().i('ℹ️ 无保存的阅读位置');
      if (mounted && !_isDisposed) {
        setState(() { isLoading = false; });
      }
      return;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        isLoading = false;
        isVisuallyRestoring = true;
      });
    }

    _isRestoringPosition = true;
    try {
      getLogger().i('🔄 开始恢复阅读位置...');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isWebViewAvailable()) return;
      
      for (int i = 0; i < 3; i++) {
        if (await jsManager.isPositionTrackerAvailable()) break;
        if (i < 2) {
          getLogger().d('⚠️ JavaScript追踪器未就绪，等待重试...');
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          getLogger().w('⚠️ JavaScript追踪器始终未就绪');
        }
      }

      bool restored = false;
      
      // 🚀 优先使用智能定位（立即跳转）
      if (article!.currentElementId.isNotEmpty && article!.markdownScrollY > 0) {
        final smartResult = await jsManager.smartJumpToPosition(
          article!.currentElementId, 
          article!.markdownScrollY, 
          article!.markdownScrollX
        );
        if (smartResult) {
          getLogger().i('⚡ 智能定位成功：立即跳转到阅读位置');
          restored = true;
        }
      }
      
      // 🎯 备用方案1：立即跳转到元素
      if (!restored && article!.currentElementId.isNotEmpty) {
        final jumped = await jsManager.jumpToElement(article!.currentElementId);
        if (jumped) {
          getLogger().i('⚡ 立即跳转到元素成功');
          restored = true;
        } else {
          getLogger().w('⚠️ 立即跳转失败，尝试平滑滚动');
          final scrolled = await jsManager.scrollToElement(article!.currentElementId);
          if (scrolled) {
            getLogger().i('✅ 平滑滚动到元素成功');
            restored = true;
          }
        }
      }
      
      // 🎯 备用方案2：立即跳转到位置
      if (!restored && article!.markdownScrollY > 0) {
        await jsManager.jumpToPosition(article!.markdownScrollY, article!.markdownScrollX);
        getLogger().i('⚡ 立即跳转到位置完成');
        restored = true;
      }

      // 短暂等待页面稳定
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (_isWebViewAvailable()) {
        final finalPosition = await jsManager.getFinalScrollPosition();
        getLogger().i('🎯 最终位置验证: $finalPosition');
      }

    } catch (e, stackTrace) {
       if (e.toString().contains('disposed')) {
         getLogger().w('⚠️ WebView已销毁，终止恢复阅读位置');
       } else {
         getLogger().e('❌ 恢复阅读位置异常: $e');
         getLogger().d('堆栈跟踪: $stackTrace');
       }
    } finally {
      _isRestoringPosition = false;
      if (mounted && !_isDisposed) {
        setState(() {
          isVisuallyRestoring = false;
        });
      }
    }
  }
  
  // === 内容渲染 ===
  Future<void> _renderMarkdownContent() async {
    final markdownContent = (this as dynamic).markdownContent as String;
    if (markdownContent.isEmpty || !_isWebViewAvailable()) return;
    
    // 解析内边距
    // final padding = contentPadding.resolve(Directionality.of(context));
    // final paddingTop = padding.top + 100;
    // final paddingBottom = padding.bottom;
    // final paddingLeft = padding.left;
    // final paddingRight = padding.right;
    
    // final paddingStyle = 'padding: ${paddingTop}px ${paddingRight}px ${paddingBottom}px ${paddingLeft}px;';
    
    // getLogger().i('🎨 使用内边距渲染Markdown: $paddingStyle');
    //paddingStyle,
    await WebViewPoolManager().renderMarkdownContent(
      webViewController!,
      markdownContent,
      "",
    );
  }
  
  String _escapeForJS(String content) {
    return '`${content.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`';
  }


  /// 传统资源设置方法（备用）
  Future<void> _setupTraditionalResources() async {
    getLogger().i('🔧 使用传统方式加载资源...');
    if (webViewController == null) return;
    try {
      final List<Future> resourceFutures = [
        _loadAssetJs('assets/js/marked.min.js'),
        _loadAssetJs('assets/js/highlight.min.js'),
        _loadAssetCss('assets/js/typora_github.css', 'github-styles'),
        // 尝试加载安全脚本
        _loadAssetJs('assets/js/markdown_safe.js').catchError((e) {
          getLogger().w('⚠️ 安全脚本加载失败，将使用基础配置: $e');
          return _configureMarked();
        }),
      ];
      await Future.wait(resourceFutures);
      getLogger().i('✅ 传统方式资源加载完成');
    } catch (e) {
      getLogger().e('❌ 传统方式资源加载失败: $e');
      // 最后的备用配置
      await _configureMarked();
    }
  }

  Future<void> _loadAssetJs(String path) async {
    final js = await rootBundle.loadString(path);
    await webViewController!.evaluateJavascript(source: js);
    getLogger().d('✅ JS资源加载: $path');
  }

  Future<void> _loadAssetCss(String path, String id) async {
    final css = await rootBundle.loadString(path);
    await webViewController!.evaluateJavascript(source: '''
      var style = document.getElementById('$id');
      if (style) { style.textContent = ${_escapeForJS(css)}; }
    ''');
     getLogger().d('✅ CSS资源加载: $path');
  }

  Future<void> _configureMarked() async {
    await webViewController!.evaluateJavascript(source: '''
      if (typeof marked !== 'undefined') {
        marked.setOptions({
          highlight: function(code, lang) {
            if (typeof hljs !== 'undefined') {
              if (lang && hljs.getLanguage(lang)) {
                try {
                  return hljs.highlight(code, { language: lang }).value;
                } catch (err) { return code; }
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

  // === JS事件处理 ===
  void _setupTextSelectionHandlers() {
    webViewController!.addJavaScriptHandler(handlerName: 'onTextSelected', callback: _handleTextSelected);
    webViewController!.addJavaScriptHandler(handlerName: 'onSelectionCleared', callback: _handleSelectionCleared);
    webViewController!.addJavaScriptHandler(handlerName: 'onTextHighlighted', callback: _handleTextHighlighted);
    webViewController!.addJavaScriptHandler(handlerName: 'onNoteAdded', callback: _handleNoteAdded);
  }

  void _handleTextSelected(List<dynamic> args) {
    final data = args[0] as Map<String, dynamic>;
    final String selectedText = data['text'] ?? '';
    final double x = (data['x'] ?? 0).toDouble();
    final double y = (data['y'] ?? 0).toDouble();
    final double width = (data['width'] ?? 0).toDouble();
    final double height = (data['height'] ?? 0).toDouble();
    
    getLogger().d('📝 文字被选择: $selectedText at ($x, $y)');
    _showCustomSelectionMenu(selectedText, x, y, width, height);
  }

  void _handleSelectionCleared(List<dynamic> args) {
    getLogger().d('❌ 选择已取消');
    _hideCustomSelectionMenu();
  }

  void _handleTextHighlighted(List<dynamic> args) {
    final data = args[0] as Map<String, dynamic>;
    // TODO: 保存高亮信息到数据库
    getLogger().i('🎨 高亮已保存: ${data['id']}');
  }

  void _handleNoteAdded(List<dynamic> args) {
    final data = args[0] as Map<String, dynamic>;
    // TODO: 保存笔记信息到数据库
    getLogger().i('📝 笔记已保存: ${data['id']}');
  }

  // === 自定义菜单 ===
  void _showCustomSelectionMenu(String selectedText, double x, double y, double width, double height) {
    if (_isDisposed || !mounted) return;
    final renderBox = webViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
        getLogger().w('⚠️无法获取WebView的RenderBox');
        return;
    }
    final webViewOffset = renderBox.localToGlobal(Offset.zero);

    _currentSelectedText = selectedText;
    _hideCustomSelectionMenu();

    final selectionRectOnScreen = Rect.fromLTWH(webViewOffset.dx + x, webViewOffset.dy + y, width, height);
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const menuHeight = 50.0;
    const menuWidth = 200.0;

    double menuY = selectionRectOnScreen.top - menuHeight - 8;
    if (menuY < padding.top) {
      menuY = selectionRectOnScreen.bottom + 8;
    }
    double menuX = selectionRectOnScreen.center.dx - (menuWidth / 2);
    if (menuX < 16) {
      menuX = 16;
    } else if (menuX + menuWidth > screenSize.width - 16) {
      menuX = screenSize.width - menuWidth - 16;
    }
    
    getLogger().d('📍 菜单位置: x=$menuX, y=$menuY');

    _backgroundCatcher = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(onTap: _hideCustomSelectionMenu, child: Container(color: Colors.transparent)),
      ),
    );

    _selectionMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: menuX,
        top: menuY,
        child: GestureDetector(
          onTap: () {}, // 阻止事件穿透
          child: ArticleMarkdownSelectionMenu(onAction: _handleMenuAction)
        ),
      ),
    );
    Overlay.of(context).insertAll([_backgroundCatcher!, _selectionMenuOverlay!]);
  }

  void _hideCustomSelectionMenu() {
    _selectionMenuOverlay?.remove();
    _selectionMenuOverlay = null;
    _backgroundCatcher?.remove();
    _backgroundCatcher = null;
  }

  void _handleMenuAction(SelectionAction action) {
    _hideCustomSelectionMenu();
    final text = _currentSelectedText;
    
    switch (action) {
      case SelectionAction.copy:
        _handleCopyText(text);
        break;
      case SelectionAction.highlight:
        _handleHighlightText(text);
        break;
      case SelectionAction.note:
        _handleAddNote(text);
        break;
      case SelectionAction.share:
        _handleShareText(text);
        break;
    }
  }

  // === 菜单动作实现 ===
  void _handleCopyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showMessage('已复制到剪贴板');
    getLogger().d('📋 文字已复制: $text');
  }

  void _handleHighlightText(String text) {
    if (!_isWebViewAvailable()) return;
    jsManager.highlightSelection('yellow');
    _showMessage('已添加高亮');
    getLogger().d('🎨 文字已高亮: $text');
  }

  void _handleAddNote(String selectedText) async {
    final noteText = await showArticleAddNoteDialog(context: context, selectedText: selectedText);
    if (noteText != null && noteText.isNotEmpty) {
      _addNoteToText(noteText, selectedText);
      _showMessage('笔记已添加');
    }
  }
  
  void _addNoteToText(String noteText, String selectedText) {
    if (!_isWebViewAvailable()) return;
    jsManager.addNoteToSelection(noteText);
    getLogger().d('📝 笔记已添加: 文字="$selectedText", 笔记="$noteText"');
  }

  void _handleShareText(String text) {
    _showMessage('分享功能待实现');
    getLogger().d('📤 分享文字: $text');
  }

  // === 图片点击 ===
  Future<void> _setupImageClickHandler() async {
    if (!_isWebViewAvailable()) return;
    webViewController!.addJavaScriptHandler(
      handlerName: 'onImageClicked',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String imageSrc = data['src'] ?? '';
        getLogger().d('🖼️ 图片被点击: $imageSrc');
        _handleImageClicked(imageSrc);
      },
    );
  }

  void _handleImageClicked(String src) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(src, fit: BoxFit.contain)
            ),
          ),
        ),
      ),
    );
  }

  // === 辅助方法 ===
  bool _isWebViewAvailable() => !_isDisposed && webViewController != null && mounted;
  bool _shouldSave() => _lastSaveTime == null || DateTime.now().difference(_lastSaveTime!) >= _minSaveInterval;

  Future<void> _ensureLatestArticleData() async {
    if (article?.id == null) return;
    try {
      final latestArticle = await ArticleService.instance.getArticleById(article!.id);
      if (latestArticle != null && !_isDisposed) {
        setState(() {
          article
          ?..markdownScrollY = latestArticle.markdownScrollY
          ..markdownScrollX = latestArticle.markdownScrollX
          ..currentElementId = latestArticle.currentElementId
          ..currentElementText = latestArticle.currentElementText
          ..currentElementOffset = latestArticle.currentElementOffset
          ..viewportHeight = latestArticle.viewportHeight
          ..contentHeight = latestArticle.contentHeight
          ..readProgress = latestArticle.readProgress
          ..lastReadTime = latestArticle.lastReadTime
          ..readCount = latestArticle.readCount
          ..readDuration = latestArticle.readDuration;
        });
      }
    } catch(e) {
      getLogger().e('❌ 刷新文章数据失败: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}

/// 监听应用生命周期变化的辅助类，用于将事件传递给mixin。
class AppLifecycleObserver with WidgetsBindingObserver {
  final ArticleMarkdownLogic logic;
  AppLifecycleObserver(this.logic);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (logic._isDisposed) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        logic._saveCurrentReadingPosition();
        break;
      case AppLifecycleState.resumed:
        // logic.markUnsavedChanges(); // onResume, a check will be triggered by the timer anyway
        break;
      default:
        break;
    }
  }
} 
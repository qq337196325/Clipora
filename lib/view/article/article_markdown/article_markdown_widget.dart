import 'dart:async';
import 'dart:math' as math;
import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/view/article/article_markdown/utils/basic_scripts_logic.dart';
import 'package:clipora/view/article/article_markdown/utils/simple_markdown_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import '../../../basics/logger.dart';
import '../../../db/annotation/enhanced_annotation_db.dart';
import '../../../db/annotation/enhanced_annotation_service.dart';
import '../../../db/article/article_db.dart';
import '../controller/article_controller.dart';
import 'components/article_markdown_add_note_dialog.dart';
import 'components/delete_highlight_dialog.dart';
import 'components/enhanced_selection_menu.dart';
import 'components/highlight_action_menu.dart';
import 'utils/simple_html_template.dart';


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
  State<ArticleMarkdownWidget> createState() => ArticleMarkdownWidgetState();
}

// with SelectionMenuLogic<ArticleMarkdownWidget>, HighlightMenuLogic<ArticleMarkdownWidget>, EnhancedMarkdownLogic<ArticleMarkdownWidget>

class ArticleMarkdownWidgetState extends State<ArticleMarkdownWidget> with ArticleMarkdownWidgetBLoC {

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: _buildOptimizedWebView(),
    );
  }

  Widget _buildOptimizedWebView() {
    return InAppWebView(
      key: _webViewKey,
      initialData: InAppWebViewInitialData(
        data: SimpleHtmlTemplate.generateHtmlTemplate(),
        mimeType: "text/html",
        encoding: "utf-8",
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        disableContextMenu: true,
        // disableDefaultErrorPage: true,
        // textZoom: 100,
        // supportMultipleWindows: false,
        // allowsInlineMediaPlayback: true,
        // disableLongPressContextMenuOnLinks: true,
        // supportZoom: false,
        // builtInZoomControls: false,
        // displayZoomControls: false,
        // disableHorizontalScroll: false,
        // disableVerticalScroll: false,
        userAgent: "Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 InkwellReader/1.0",
        // allowFileAccess: true,
        // allowContentAccess: true,
        // cacheMode: CacheMode.LOAD_DEFAULT,
        // clearCache: false,
        // disableInputAccessoryView: true,
      ),
      onWebViewCreated: (InAppWebViewController controller){
        webViewController = controller;
        articleController.markdownController = controller;
      },
      onLoadStart: (controller, url) {
        getLogger().d('🚀 WebView开始加载: $url');
      },
      onLoadStop: (controller, url) async {
        getLogger().d('🚀 WebView开始加载11111111111111: $url');
        try {
          getLogger().d('🚀 WebView开始加载11111111111111: $url');
          _setupEnhancedTextSelectionHandlers();


          // // 注入基础脚本
          basicScriptsLogic = BasicScriptsLogic(webViewController!);
          await basicScriptsLogic.injectBasicScripts(webViewController!);

          // 注入Range标注引擎（包含完整的文本选择监听逻辑）
          final injectionSuccess = await basicScriptsLogic.injectRangeAnnotationScript();
          getLogger().d('🔥 Range引擎注入结果: $injectionSuccess');

          await _injectHighlightClickListener();

          await _renderMarkdownContent(); // 渲染文档

          // 添加小延迟，避免过快操作
          await Future.delayed(const Duration(milliseconds: 20));
          _restoreReadingPosition(); // 恢复上次阅读的位置

          _restoreEnhancedAnnotations();

        } catch (e) {
          getLogger().e('❌ WebView加载后初始化失败: $e');
          // 即使初始化失败，也要隐藏加载遮罩
          controller.evaluateJavascript(source: '''
            if (window.SmoothLoading) {
              window.SmoothLoading.hide();
            }
          ''').catchError((e) => getLogger().d('⚠️ 隐藏加载遮罩失败: $e'));
        }
      },
      onProgressChanged: (controller, progress) {
        getLogger().d('📊 WebView加载进度: $progress%');
      },
      onConsoleMessage: (controller, consoleMessage) {
        getLogger().d('🖥️ WebView控制台: [${consoleMessage.messageLevel}] ${consoleMessage.message}');
      },
      onScrollChanged: (controller, x, y) {
        final scrollY = y.toDouble();
        // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
        if ((scrollY - _lastScrollY).abs() > 15) {
          final direction = scrollY > _lastScrollY ? ScrollDirection.reverse : ScrollDirection.forward;
          widget.onScroll?.call(direction, scrollY);
          _lastScrollY = scrollY;

          // // 触发位置保存（如果是EnhancedMarkdownLogic的实例）
          // if (this is dynamic && (this as dynamic).manualSavePosition != null) {
          //   // 使用防抖，避免过于频繁的保存
          //   _debounceSavePosition(() {
          //     (this as dynamic).manualSavePosition?.call();
          //   });
          // }
        }
      },
    );
  }





}


mixin ArticleMarkdownWidgetBLoC on State<ArticleMarkdownWidget> {

  final ArticleController articleController = Get.find<ArticleController>();

  final GlobalKey _webViewKey = GlobalKey();
  // @override
  GlobalKey<State<StatefulWidget>> get webViewKey => _webViewKey;
  String get markdownContent => widget.markdownContent;

  // @override
  // ArticleDb? get article => widget.article;
  InAppWebViewController? webViewController;
  late BasicScriptsLogic basicScriptsLogic;

  // @override
  EdgeInsetsGeometry get contentPadding => widget.contentPadding;

  double _lastScrollY = 0.0;
  Timer? _savePositionTimer;
  DateTime? _lastSaveTime;

  // === OverlayEntry管理 ===
  OverlayEntry? _enhancedSelectionMenuOverlay;
  OverlayEntry? _backgroundCatcher;
  Map<String, dynamic>? _currentSelectionData;

  @override
  void initState() {
    super.initState();
    // initEnhancedLogic();
  }

  @override
  void didUpdateWidget(ArticleMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检测文章是否变化（用于处理高亮和笔记的语言版本）
    if (oldWidget.article?.id != widget.article?.id) {
      getLogger().i('🔄 检测到文章变化，重新初始化增强功能');
      // 重新初始化增强功能
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          // initEnhancedLogic();
        }
      });
    }

    // 检测Markdown内容是否变化（用于语言切换等场景）
    if (oldWidget.markdownContent != widget.markdownContent && 
        widget.markdownContent.isNotEmpty) {
      getLogger().i('🌐 检测到Markdown内容变化，重新渲染内容');
      getLogger().d('📝 旧内容长度: ${oldWidget.markdownContent.length}, 新内容长度: ${widget.markdownContent.length}');
      
      // 延迟一点时间确保WebView准备就绪，然后重新渲染内容和恢复状态
      Future.delayed(const Duration(milliseconds: 100), () async {
        if (mounted && webViewController != null) {
          // 1. 重新渲染内容
          await _renderMarkdownContent();
          
          // 2. 延迟恢复阅读位置和增强标注
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _restoreReadingPosition(); // 恢复阅读位置
              _restoreEnhancedAnnotations(); // 恢复增强标注（高亮和笔记）
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _savePositionTimer?.cancel();
    // disposeEnhancedLogic();
    hideEnhancedSelectionMenu(); // 清理菜单

    getLogger().d('✅ ArticleMarkdownWidget销毁完成');
    super.dispose();
  }


  /// 防抖保存位置，避免过于频繁的保存操作
  void _debounceSavePosition(VoidCallback callback) {
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(const Duration(seconds: 2), callback);
  }


  // === 内容渲染 ===
  Future<void> _renderMarkdownContent() async {

    try {
      getLogger().i('🎨 开始渲染Markdown内容 (长度: ${markdownContent.length})...');

      // 使用简单的Markdown渲染器
      final success = await SimpleMarkdownRenderer.renderMarkdown(
        webViewController!,
        markdownContent,
      );

      if (success) {
        getLogger().i('✅ Markdown内容渲染成功');
        // 检查渲染后的页面高度
        final contentHeight = await webViewController!.evaluateJavascript(source: '''
          document.body.scrollHeight || document.documentElement.scrollHeight || 0;
        ''');
        getLogger().d('📏 渲染后页面高度: $contentHeight');
      } else {
        getLogger().w('⚠️ Markdown渲染失败，但继续执行');
      }
    } catch (e) {
      getLogger().e('❌ 渲染Markdown内容异常: $e');
    }
  }

  /// 重新加载Markdown内容
  /// 供外部调用的公开方法
  Future<void> reloadMarkdownContent() async {
    getLogger().i('🔄 重新加载Markdown内容');

    if (webViewController != null) {
      try {
        // 方式1：直接重新加载WebView（简单直接）
        await webViewController!.reload();
        getLogger().i('✅ WebView重新加载完成');

        // 注意：reload后会触发onLoadStop，在那里会重新渲染新的Markdown内容
      } catch (e) {
        getLogger().e('❌ 重新加载WebView失败，尝试直接更新内容: $e');
      }
    } else {
      getLogger().w('⚠️ WebView控制器不存在，无法重新加载');
    }
  }

  Future<void> _restoreReadingPosition() async {
    try {
      final targetScrollX = articleController.currentArticleContent?.markdownScrollX ?? 0;
      final targetScrollY = articleController.currentArticleContent?.markdownScrollY ?? 0;

      // 检查页面内容是否已加载
      final contentHeight = await webViewController!.evaluateJavascript(source: '''
        document.body.scrollHeight || document.documentElement.scrollHeight || 0;
      ''');

      // 先尝试滚动到目标位置
      await webViewController!.scrollTo(
        x: targetScrollX,
        y: targetScrollY,
      );

      // 验证滚动是否成功
      final actualY = await webViewController!.getScrollY();
      final actualX = await webViewController!.getScrollX();

      // 如果位置差异较大，可能是内容还没完全加载
      if (actualY != null && (actualY - targetScrollY).abs() > 100) {
        getLogger().w('⚠️ 位置恢复可能不准确，差异: ${(actualY - targetScrollY).abs()}px');
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('disposed')) {
        getLogger().w('⚠️ WebView已销毁，终止恢复阅读位置');
      } else {
        getLogger().e('❌ 恢复阅读位置异常: $e');
        getLogger().d('堆栈跟踪: $stackTrace');
      }
    } finally {
      // _isRestoringPosition = false;
      // // 确保在位置恢复完成后隐藏加载遮罩
      // await _hideLoadingOverlay();
      // if (mounted && !_isDisposed) {
      //   setState(() {
      //     isVisuallyRestoring = false;
      //   });
      // }
    }
  }


  // === 增强文本选择处理 ===
  void _setupEnhancedTextSelectionHandlers() {
    try {
      getLogger().d('🔥 开始注册增强文本选择回调处理器...');

      webViewController!.addJavaScriptHandler(
        handlerName: 'onEnhancedTextSelected',
        callback: handleEnhancedTextSelected,
      );
      getLogger().d('🔥 已注册: onEnhancedTextSelected');

      webViewController!.addJavaScriptHandler(
        handlerName: 'onEnhancedSelectionCleared',
        callback: handleEnhancedSelectionCleared,
      );
      getLogger().d('🔥 已注册: onEnhancedSelectionCleared');

      // webViewController!.addJavaScriptHandler(
      //   handlerName: 'onHighlightCreated',
      //   callback: handleHighlightCreated,
      // );
      // getLogger().d('🔥 已注册: onHighlightCreated');

      // === 第一步：添加标注点击监听Handler ===
      webViewController!.addJavaScriptHandler(
        handlerName: 'onHighlightClicked',
        callback: handleHighlightClicked,
      );
      getLogger().d('🔥 已注册: onHighlightClicked');

      getLogger().i('✅ 所有增强文本选择回调处理器注册完成');

      // 验证JavaScript桥接
      _verifyJavaScriptBridge();

    } catch (e) {
      getLogger().e('❌ 注册增强文本选择回调处理器失败: $e');
    }
  }


  // === 选择菜单处理方法 ===
  void handleEnhancedTextSelected(List<dynamic> args) {
    getLogger().d('🔥 handleEnhancedTextSelected 被调用，参数: $args');

    final data = args[0] as Map<String, dynamic>;
    getLogger().d('🔥 接收到的数据结构: ${data.keys.toList()}');
    getLogger().d('🔥 数据详情: $data');

    if (!_validateSelectionData(data)) {
      getLogger().w('⚠️ 选择数据验证失败，忽略');
      _logValidationDetails(data);
      return;
    }

    // _currentSelectionData = data;
    _currentSelectionData = data;
    getLogger().d('🔥 准备显示选择菜单...');
    _showEnhancedSelectionMenu(data);

    getLogger().d('📝 文字被选择: "${data['selectedText']}" at (${data['boundingRect']['x']}, ${data['boundingRect']['y']})');
  }

  /// 处理选择清除事件
  void handleEnhancedSelectionCleared(List<dynamic> args) {
    getLogger().d('🧹 handleEnhancedSelectionCleared 被调用');
    getLogger().d('🔍 清除前选择数据状态: ${_currentSelectionData != null ? "有数据" : "空"}');
    getLogger().d('📍 调用来源: JavaScript选择清除事件');
    hideEnhancedSelectionMenu();
  }

  // === 选择数据验证 ===
  bool _validateSelectionData(Map<String, dynamic> data) {
    final requiredFields = [
      'startXPath', 'startOffset', 'endXPath', 'endOffset',
      'selectedText', 'boundingRect'
    ];

    return requiredFields.every((field) =>
    data.containsKey(field) && data[field] != null);
  }

  void _logValidationDetails(Map<String, dynamic> data) {
    final requiredFields = [
      'startXPath', 'startOffset', 'endXPath', 'endOffset',
      'selectedText', 'boundingRect'
    ];

    getLogger().w('🔍 数据验证详情:');
    for (final field in requiredFields) {
      final hasField = data.containsKey(field);
      final isNotNull = hasField ? data[field] != null : false;
      getLogger().w('  - $field: 存在=$hasField, 非空=$isNotNull, 值=${data[field]}');
    }
  }

  // === 选择菜单显示逻辑 ===
  void _showEnhancedSelectionMenu(Map<String, dynamic> selectionData) {
    getLogger().d('🔥 _showEnhancedSelectionMenu 被调用');

    if (!mounted) {
      getLogger().w('⚠️ 组件未挂载，跳过显示菜单');
      return;
    }

    final renderBox = webViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      getLogger().w('⚠️ 无法获取WebView的RenderBox');
      return;
    }

    final webViewOffset = renderBox.localToGlobal(Offset.zero);
    final boundingRect = selectionData['boundingRect'] as Map<String, dynamic>;
    final scrollInfo = selectionData['scrollInfo'] as Map<String, dynamic>?;

    getLogger().d('📊 boundingRect: $boundingRect');
    getLogger().d('📊 webViewOffset: $webViewOffset');

    hideEnhancedSelectionMenu();

    getLogger().d('🎯 准备调用 _showMenuAtPosition');
    // 直接计算位置，使用JavaScript提供的视口相对位置
    _showMenuAtPosition(selectionData, webViewOffset, boundingRect, scrollInfo);
  }

  /// 隐藏增强选择菜单
  void hideEnhancedSelectionMenu() {
    getLogger().d('🧹 隐藏增强选择菜单');
    getLogger().d('🔍 清空前选择数据状态: ${_currentSelectionData != null ? "有数据(${(_currentSelectionData!['selectedText'] as String? ?? '').length}字符)" : "空"}');
    
    _enhancedSelectionMenuOverlay?.remove();
    _enhancedSelectionMenuOverlay = null;
    _backgroundCatcher?.remove();
    _backgroundCatcher = null;
    _currentSelectionData = null;
    
    getLogger().d('✅ 选择数据已清空');
  }


  void _showMenuAtPosition(
      Map<String, dynamic> selectionData,
      Offset webViewOffset,
      Map<String, dynamic> boundingRect,
      Map<String, dynamic>? scrollInfo,
      ) {
    getLogger().d('🎯 _showMenuAtPosition 开始执行');

    // 重新设置当前选择数据，因为在hideEnhancedSelectionMenu中被清空了
    _currentSelectionData = selectionData;
    getLogger().d('🔥 重新设置选择数据: ${selectionData['selectedText']}');

    // 使用JavaScript提供的视口相对位置
    final rectX = (boundingRect['x'] ?? 0).toDouble();
    final rectY = (boundingRect['y'] ?? 0).toDouble();
    final rectWidth = (boundingRect['width'] ?? 0).toDouble();
    final rectHeight = (boundingRect['height'] ?? 0).toDouble();

    // 考虑内容padding
    final padding = contentPadding.resolve(Directionality.of(context));
    final systemPadding = MediaQuery.of(context).padding;

    var absoluteY = webViewOffset.dy + rectY;
    // 针对iOS全面屏下坐标系差异的修正
    // 在iOS上，如果WebView是全面屏显示的(紧贴屏幕顶部)，JS的getBoundingClientRect().y可能是相对于SafeArea的，而不是屏幕绝对坐标
    if (Platform.isIOS && webViewOffset.dy < systemPadding.top) { //
      absoluteY += systemPadding.top;
    }

    // 计算在屏幕上的绝对位置
    final selectionRectOnScreen = Rect.fromLTWH(
      webViewOffset.dx + rectX + padding.left,
      absoluteY + padding.top,
      rectWidth,
      rectHeight,
    );

    final screenSize = MediaQuery.of(context).size;
    const menuHeight = 60.0;
    const menuWidth = 250.0;

    // 计算可用空间
    final spaceAbove = selectionRectOnScreen.top - systemPadding.top - 20;
    final spaceBelow = screenSize.height - selectionRectOnScreen.bottom - systemPadding.bottom - 20;

    double menuY;

    // 智能位置选择：优先上方，但选择空间较大的位置
    if (spaceAbove >= menuHeight) {
      // 上方有足够空间
      // menuY = selectionRectOnScreen.top - menuHeight - 180;
      if (Platform.isIOS) { 
        menuY = selectionRectOnScreen.top - menuHeight - 180;
      }else{
        menuY = selectionRectOnScreen.top - menuHeight - 50;
      }

    } else if (spaceBelow >= menuHeight) {
      // 下方有足够空间
      menuY = selectionRectOnScreen.bottom - 20;
    } else {
      // 两边空间都不足，选择空间较大的一边，并贴边显示
      if (spaceAbove >= spaceBelow) {
        // 上方空间更大，贴着顶部显示
        menuY = systemPadding.top + 10;
      } else {
        // 下方空间更大，贴着底部显示
        menuY = screenSize.height - systemPadding.bottom - menuHeight - 10;
      }
    }

    // 水平居中，但确保不超出屏幕边界
    double menuX = (menuWidth / 2);

    getLogger().d('📍 选择区域(屏幕): ${selectionRectOnScreen.toString()}');
    getLogger().d('📍 可用空间: 上方=${spaceAbove.toInt()}px, 下方=${spaceBelow.toInt()}px');
    getLogger().d('📍 最终菜单位置: x=${menuX.toInt()}, y=${menuY.toInt()}');

     _backgroundCatcher = OverlayEntry(
      builder: (context) => ModalBarrier(
        onDismiss: hideEnhancedSelectionMenu,
        color: Colors.transparent,
      ),
    );

     _enhancedSelectionMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: menuX,
        top: menuY,
        child: GestureDetector(
          onTap: () {}, // 阻止事件穿透
          child: EnhancedSelectionMenu(
            onAction: _handleEnhancedMenuAction,
          ),
        ),
      ),
    );

    Overlay.of(context).insertAll([_backgroundCatcher!, _enhancedSelectionMenuOverlay!]);
  }

  /// 处理增强菜单动作
  void _handleEnhancedMenuAction(EnhancedSelectionAction action) {
    getLogger().d('🎯 处理菜单动作: $action');
    getLogger().d('🔍 当前选择数据状态: ${_currentSelectionData != null ? "有数据" : "空"}');
    
    if (_currentSelectionData == null) {
      getLogger().w('⚠️ 当前选择数据为空，无法处理动作');
      hideEnhancedSelectionMenu();
      return;
    }

    final selectionData = _currentSelectionData!;
    final selectedText = _currentSelectionData!['selectedText'] as String;
    getLogger().d('✅ 准备处理选择文本: "${selectedText.length > 50 ? selectedText.substring(0, 50) + "..." : selectedText}"');
    
    switch (action) {
      case EnhancedSelectionAction.copy:
        _copySelectedText(selectedText);
        break;
      case EnhancedSelectionAction.highlight:
        _handleCreateHighlight(selectionData);
        break;
      case EnhancedSelectionAction.note:
        _handleCreateNote(selectionData);
        break;
    }
    
    // 隐藏菜单
    hideEnhancedSelectionMenu();
  }

  /// 复制选中文本
  void _copySelectedText(String text) {
    try {
      Clipboard.setData(ClipboardData(text: text));
      getLogger().i('✅ 文本已复制到剪贴板: ${text.length}字符');
      // 可以添加复制成功的提示
    } catch (e) {
      getLogger().e('❌ 复制文本失败: $e');
    }
  }

  /// 高亮选中文本
  Future<void> _handleCreateHighlight(Map<String, dynamic> selectionData) async {
    try {
      if (articleController.currentArticle == null) {
        BotToast.showText(text: '无法创建高亮：文章信息缺失');
        return;
      }

      // 创建增强标注
      final annotation = EnhancedAnnotationDb.fromSelectionData(
        selectionData,
        articleController.currentArticle!.id,
        AnnotationType.highlight,
        colorType: AnnotationColor.yellow,
      );

      // 设置 articleContentId（新架构）
      annotation.articleContentId = articleController.currentArticleContent!.id;

      // 保存到数据库
      await EnhancedAnnotationService.instance.saveAnnotation(annotation);

      // 在WebView中创建高亮
      final success = await basicScriptsLogic.createHighlight(
        selectionData,
        annotation.highlightId,
        annotation.colorType.cssClass,
      );

      if (success) {
        BotToast.showText(text: '高亮已添加');
        // getLogger().i('✅ 高亮创建成功: ${annotation.highlightId}，内容ID: $articleContentId');
      } else {
        BotToast.showText(text: '高亮添加失败');
        // 回滚数据库操作
        await EnhancedAnnotationService.instance.deleteAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 创建高亮失败: $e');
      BotToast.showText(text: '高亮添加失败');
    }
  }

  /// 为选中文本添加笔记
  void _handleCreateNote(Map<String, dynamic> selectionData) async {
    getLogger().i('📝 为选中文本添加笔记');
    try {
      if (articleController.currentArticle == null) {
        BotToast.showText(text: '无法创建笔记：文章信息缺失');
        return;
      }

      final selectedText = selectionData['selectedText'] as String;

      // 显示笔记输入对话框
      final noteText = await showArticleAddNoteDialog(
        context: context,
        selectedText: selectedText,
      );

      if (noteText == null || noteText.isEmpty) {
        return; // 用户取消或输入为空
      }

      // 创建带笔记的增强标注
      final annotation = EnhancedAnnotationDb.fromSelectionData(
        selectionData,
        articleController.currentArticle!.id,
        AnnotationType.note,
        colorType: AnnotationColor.green,
        noteContent: noteText,
      );

      // 设置 articleContentId（新架构）
      annotation.articleContentId = articleController.currentArticleContent!.id;

      // 保存到数据库
      await EnhancedAnnotationService.instance.saveAnnotation(annotation);

      // 在WebView中创建高亮（带笔记）
      final success = await basicScriptsLogic.createHighlight(
        selectionData,
        annotation.highlightId,
        annotation.colorType.cssClass,
        noteContent: noteText,
      );

      if (success) {
        BotToast.showText(text: '笔记已添加');
        getLogger().i('✅ 笔记创建成功: ${annotation.highlightId}，内容ID: ${articleController.currentArticle?.id}');
      } else {
        BotToast.showText(text: '笔记添加失败');
        // 回滚数据库操作
        await EnhancedAnnotationService.instance.deleteAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 创建笔记失败: $e');
      BotToast.showText(text: '笔记添加失败');
    }
  }

  // 验证JavaScript桥接
  Future<void> _verifyJavaScriptBridge() async {
    try {
      getLogger().d('🔄 验证JavaScript桥接...');

      // 检查flutter_inappwebview桥接是否可用
      final bridgeAvailable = await webViewController!.evaluateJavascript(source: '''
        (function() {
          const available = typeof window.flutter_inappwebview !== 'undefined' && 
                           typeof window.flutter_inappwebview.callHandler === 'function';
          console.log('🔍 Flutter桥接可用性:', available);
          return available;
        })();
      ''');

      getLogger().d('🔍 Flutter桥接可用: $bridgeAvailable');

      // 测试一个简单的Handler调用
      webViewController!.addJavaScriptHandler(
        handlerName: 'testHandler',
        callback: (args) {
          getLogger().d('✅ 测试Handler被成功调用: $args');
        },
      );

      // 从JavaScript端调用测试Handler
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          console.log('🧪 测试调用Flutter Handler...');
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('testHandler', 'bridge_test_successful');
          } else {
            console.error('❌ Flutter桥接不可用');
          }
        })();
      ''');

    } catch (e) {
      getLogger().e('❌ 验证JavaScript桥接失败: $e');
    }
  }



  // === 增强标注恢复 ===
  Future<void> _restoreEnhancedAnnotations() async {

    try {
      getLogger().d('🔄 开始恢复增强标注，文章ID: ${articleController.currentArticle!.id}');

      List<EnhancedAnnotationDb> annotations;

      // 优先使用基于articleContentId的新方法
      annotations = await EnhancedAnnotationService.instance.getAnnotationsForArticleContent(articleController.currentArticleContent!.id);

      getLogger().i('📊 从数据库获取到 ${annotations.length} 个增强标注');

      if (annotations.isEmpty) {
        getLogger().d('ℹ️ 本语言版本无历史增强标注');
        return;
      }

      // 转换为Range数据格式
      final rangeDataList = annotations
          .map((annotation) => annotation.toRangeData())
          .toList();

      // 批量恢复标注
      final stats = await basicScriptsLogic.batchRestoreAnnotations(rangeDataList);

      getLogger().i('✅ 增强标注恢复完成: 成功 ${stats['successCount']}, 失败 ${stats['failCount']}');

      // 如果有失败的标注，尝试逐个恢复
      if (stats['failCount']! > 0) {
        // await _restoreFailedAnnotationsOneByOne(annotations);
      }

    } catch (e) {
      getLogger().e('❌ 恢复增强标注失败: $e');
    }
  }


  // === 第一步：注入标注点击监听脚本 ===
  Future<void> _injectHighlightClickListener() async {

    try {
      getLogger().d('🔄 开始注入标注点击监听脚本...');

      // 使用事件委托监听所有标注元素的点击
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          // 防止重复注册
          if (window.highlightClickListenerInstalled) {
            console.log('⚠️ 标注点击监听器已存在，跳过重复注册');
            return;
          }
          
          // 添加全局点击事件监听器（事件委托方式）
          document.addEventListener('click', function(e) {
            try {
              // 查找点击的是否为标注元素或其子元素
              const highlightElement = e.target.closest('[data-highlight-id]');
              
              if (highlightElement) {
                // 阻止默认行为和事件冒泡
                e.preventDefault();
                e.stopPropagation();
                
                console.log('🎯 检测到标注点击:', highlightElement);
                
                // 提取标注信息
                const highlightId = highlightElement.dataset.highlightId;
                const content = highlightElement.textContent || '';
                const highlightType = highlightElement.dataset.type || 'highlight';
                const colorClass = highlightElement.className || '';
                
                // 获取元素位置信息
                const rect = highlightElement.getBoundingClientRect();
                const position = {
                  x: rect.x,
                  y: rect.y,
                  centerX: rect.x + rect.width / 2,
                  centerY: rect.y + rect.height / 2
                };
                
                const boundingRect = {
                  x: rect.x,
                  y: rect.y,
                  width: rect.width,
                  height: rect.height,
                  top: rect.top,
                  left: rect.left,
                  bottom: rect.bottom,
                  right: rect.right
                };
                
                // 构造传递给Flutter的数据
                const clickData = {
                  highlightId: highlightId,
                  content: content,
                  type: highlightType,
                  colorClass: colorClass,
                  position: position,
                  boundingRect: boundingRect,
                  elementTag: highlightElement.tagName,
                  timestamp: Date.now()
                };
                
                console.log('📦 准备发送标注点击数据:', clickData);
                
                // 调用Flutter Handler
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                  window.flutter_inappwebview.callHandler('onHighlightClicked', clickData);
                  console.log('✅ 标注点击数据已发送到Flutter');
                } else {
                  console.error('❌ Flutter桥接不可用，无法发送标注点击数据');
                }
              }
            } catch (error) {
              console.error('❌ 处理标注点击异常:', error);
            }
          }, true); // 使用capture阶段，确保能优先处理
          
          // 标记监听器已安装
          window.highlightClickListenerInstalled = true;
          console.log('✅ 标注点击监听器安装完成');
          
        })();
      ''');

      getLogger().i('✅ 标注点击监听脚本注入成功');

    } catch (e) {
      getLogger().e('❌ 注入标注点击监听脚本失败: $e');
    }
  }


  // === 第一步：标注点击处理方法 ===
  void handleHighlightClicked(List<dynamic> args) {
    try {
      getLogger().d('🎯 handleHighlightClicked 被调用，参数: $args');

      final data = args[0] as Map<String, dynamic>;
      getLogger().d('🎯 标注点击数据结构: ${data.keys.toList()}');
      getLogger().d('🎯 标注点击详情: $data');

      // 提取基本信息
      final highlightId = data['highlightId'] as String?;
      final content = data['content'] as String?;
      final highlightType = data['type'] as String?;
      final position = data['position'] as Map<String, dynamic>?;
      final boundingRect = data['boundingRect'] as Map<String, dynamic>?;

      // 验证数据完整性
      if (_validateHighlightClickData(data)) {
        getLogger().i('✅ 标注点击数据验证成功');
        getLogger().i('📍 标注ID: $highlightId');
        getLogger().i('📝 标注内容: ${content?.substring(0, (content?.length ?? 0) > 50 ? 50 : content?.length ?? 0)}${(content?.length ?? 0) > 50 ? '...' : ''}');
        getLogger().i('🏷️ 标注类型: $highlightType');
        getLogger().i('📐 位置信息: $position');
        getLogger().i('📦 边界框: $boundingRect');

        // === 第二步：显示标注操作面板 ===
        // 通过dynamic调用，因为HighlightMenuLogic在State级别混入
        showHighlightActionMenu(data);

      } else {
        getLogger().w('⚠️ 标注点击数据验证失败');
        _logHighlightClickValidationDetails(data);
      }

    } catch (e) {
      getLogger().e('❌ 处理标注点击异常: $e');
    }
  }

  // === 第一步：验证标注点击数据 ===
  bool _validateHighlightClickData(Map<String, dynamic> data) {
    final requiredFields = ['highlightId', 'content', 'type', 'position'];
    return requiredFields.every((field) =>
    data.containsKey(field) && data[field] != null);
  }

  void _logHighlightClickValidationDetails(Map<String, dynamic> data) {
    final requiredFields = ['highlightId', 'content', 'type', 'position', 'boundingRect'];
    getLogger().w('🔍 标注点击数据验证详情:');
    for (final field in requiredFields) {
      final hasField = data.containsKey(field);
      final isNotNull = hasField ? data[field] != null : false;
      getLogger().w('  - $field: 存在=$hasField, 非空=$isNotNull, 值=${data[field]}');
    }
  }

  // === 标注菜单显示逻辑 ===
  void showHighlightActionMenu(Map<String, dynamic> highlightData) {
    getLogger().d('🎯 准备显示标注操作菜单');

    if (!mounted) {
      getLogger().w('⚠️ 组件未挂载，跳过显示标注菜单');
      return;
    }

    final renderBox = webViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      getLogger().w('⚠️ 无法获取WebView的RenderBox');
      return;
    }

    final webViewOffset = renderBox.localToGlobal(Offset.zero);
    final boundingRect = highlightData['boundingRect'] as Map<String, dynamic>?;

    if (boundingRect == null) {
      getLogger().w('⚠️ 标注边界框信息缺失');
      return;
    }

    getLogger().d('📊 标注boundingRect: $boundingRect');
    getLogger().d('📊 webViewOffset: $webViewOffset');

    // 先隐藏已有菜单
    hideHighlightActionMenu();

    // 保存当前标注数据
    _currentHighlightData = highlightData;

    // 显示新菜单
    _showMenuAtPosition2(highlightData, webViewOffset, boundingRect);
  }

  // === 标注菜单相关状态 ===
  OverlayEntry? _highlightMenuOverlay;
  OverlayEntry? _highlightMenuBackgroundCatcher;
  Map<String, dynamic>? _currentHighlightData;

  void hideHighlightActionMenu() {
    if (_highlightMenuOverlay != null) {
      _highlightMenuOverlay!.remove();
      _highlightMenuOverlay = null;
      getLogger().d('🗑️ 标注菜单已隐藏');
    }

    if (_highlightMenuBackgroundCatcher != null) {
      _highlightMenuBackgroundCatcher!.remove();
      _highlightMenuBackgroundCatcher = null;
    }

    _currentHighlightData = null;
  }

  void _showMenuAtPosition2(
      Map<String, dynamic> highlightData,
      Offset webViewOffset,
      Map<String, dynamic> boundingRect,
      ) {
    getLogger().d('🎯 _showMenuAtPosition 开始执行');

    // 提取边界框坐标（相对于WebView内容的坐标）
    final rectX = (boundingRect['x'] ?? 0).toDouble();
    final rectY = (boundingRect['y'] ?? 0).toDouble();
    final rectWidth = (boundingRect['width'] ?? 0).toDouble();
    final rectHeight = (boundingRect['height'] ?? 0).toDouble();

    getLogger().d('📊 WebView内坐标: x=$rectX, y=$rectY, w=$rectWidth, h=$rectHeight');
    getLogger().d('📊 WebView偏移: dx=${webViewOffset.dx.toInt()}, dy=${webViewOffset.dy.toInt()}');

    // 考虑内容padding
    final padding = contentPadding.resolve(Directionality.of(context));
    final systemPadding = MediaQuery.of(context).padding;
    getLogger().d('📊 内容padding: left=${padding.left}, top=${padding.top}, right=${padding.right}, bottom=${padding.bottom}');

    var absoluteY = webViewOffset.dy + rectY;
    // 针对iOS全面屏下坐标系差异的修正
    if (Platform.isIOS && webViewOffset.dy < systemPadding.top) {
      absoluteY += systemPadding.top;
    }

    // 计算标注在屏幕上的绝对位置（这是关键！）
    final highlightRectOnScreen = Rect.fromLTWH(
      webViewOffset.dx + rectX + padding.left,
      absoluteY + padding.top,
      rectWidth,
      rectHeight,
    );

    final screenSize = MediaQuery.of(context).size;
    const menuHeight = 60.0;
    const menuWidth = 180.0;
    const menuMargin = 12.0; // 增加间距，确保不遮挡

    getLogger().d('📊 屏幕尺寸: ${screenSize.width.toInt()}x${screenSize.height.toInt()}');
    getLogger().d('📊 系统padding: top=${systemPadding.top}, bottom=${systemPadding.bottom}');

    // 计算可用空间（保守估计）
    final availableTop = highlightRectOnScreen.top - systemPadding.top - 20;
    final availableBottom = screenSize.height - highlightRectOnScreen.bottom - systemPadding.bottom - 20;

    getLogger().d('📊 可用空间: 上方=${availableTop.toInt()}px, 下方=${availableBottom.toInt()}px');

    double menuY;
    bool isMenuAbove = true; // 标记菜单是否在标注上方

    // 强制优先上方显示（用户的要求）
    if (availableTop >= menuHeight + menuMargin) {
      // 上方有充足空间，在标注上方显示，增加更多间距
      menuY = highlightRectOnScreen.top - menuHeight - menuMargin - 42;
      isMenuAbove = true;
      getLogger().d('🎯 菜单位置选择: 上方 (有充足空间)');
      print('菜单位置选择: 上方 (有充足空间)');
    } else if (availableTop >= menuHeight) {
      // 上方有基本空间，紧贴显示
      menuY = highlightRectOnScreen.top - menuHeight - 4;
      isMenuAbove = true;
      getLogger().d('🎯 菜单位置选择: 上方 (基本空间)');
      print('菜单位置选择: 上方 (基本空间)');
    } else if (availableBottom >= menuHeight + menuMargin) {
      // 上方空间不足，下方有充足空间
      menuY = highlightRectOnScreen.bottom + menuMargin;
      isMenuAbove = false;
      getLogger().d('🎯 菜单位置选择: 下方 (上方空间不足)');
      print('菜单位置选择: 下方 (上方空间不足)');
    } else if (availableBottom >= menuHeight) {
      // 下方有基本空间
      menuY = highlightRectOnScreen.bottom + 4;
      isMenuAbove = false;
      getLogger().d('🎯 菜单位置选择: 下方 (基本空间)');
      print('菜单位置选择: 下方 (基本空间)');
    } else {
      // 两边空间都不足，选择相对较好的位置
      if (availableTop >= availableBottom) {
        // 尽量在上方，即使会部分遮挡
        menuY = math.max(systemPadding.top + 8, highlightRectOnScreen.top - menuHeight);
        isMenuAbove = true;
        getLogger().d('🎯 菜单位置选择: 强制上方 (空间不足但优于下方)');
        print('菜单位置选择: 强制上方 (空间不足但优于下方)');
      } else {
        // 下方显示
        menuY = math.min(screenSize.height - systemPadding.bottom - menuHeight - 8,
            highlightRectOnScreen.bottom + 4);
        isMenuAbove = false;
        getLogger().d('🎯 菜单位置选择: 强制下方 (空间不足)');
        print('菜单位置选择: 强制下方 (空间不足)');
      }
    }

    // 水平居中在标注中心，但确保不超出屏幕边界
    double menuX = highlightRectOnScreen.center.dx - (menuWidth / 2);
    menuX = menuX.clamp(8.0, screenSize.width - menuWidth - 8);

    getLogger().d('📍 标注区域(屏幕): ${highlightRectOnScreen.toString()}');
    getLogger().d('📍 菜单位置: x=${menuX.toInt()}, y=${menuY.toInt()} (${isMenuAbove ? '上方' : '下方'})');

    // 最终验证：检查菜单是否与标注重叠
    final menuRect = Rect.fromLTWH(menuX, menuY, menuWidth, menuHeight);
    final hasOverlap = menuRect.overlaps(highlightRectOnScreen);

    if (hasOverlap) {
      getLogger().w('⚠️ 警告：菜单与标注有重叠！');
      getLogger().w('⚠️ 菜单矩形: ${menuRect.toString()}');
      getLogger().w('⚠️ 标注矩形: ${highlightRectOnScreen.toString()}');

      // 如果有重叠且在上方，尝试进一步上移
      if (isMenuAbove && menuY > systemPadding.top + 8) {
        menuY = math.max(systemPadding.top + 8, menuY - 10);
        getLogger().d('🔧 调整菜单位置避免重叠: y=${menuY.toInt()}');
      }
    } else {
      getLogger().d('✅ 菜单位置验证通过，不会遮挡标注');
    }
    print('menuX11111111111111: $menuX, menuY: $menuY');

    // 创建背景点击捕获器
    _highlightMenuBackgroundCatcher = OverlayEntry(
      builder: (context) => ModalBarrier(
        onDismiss: hideHighlightActionMenu,
        color: Colors.transparent,
      ),
    );

    // 创建菜单
    _highlightMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: menuX,
        top: menuY,
        child: GestureDetector(
          onTap: () {}, // 阻止事件穿透
          child: HighlightActionMenu(
            onAction: _handleHighlightAction,
          ),
        ),
      ),
    );

    // 显示菜单
    Overlay.of(context).insertAll([
      _highlightMenuBackgroundCatcher!,
      _highlightMenuOverlay!
    ]);

    getLogger().i('✅ 标注操作菜单已显示');
  }

  // === 标注菜单操作处理 ===
  void _handleHighlightAction(HighlightAction action) {
    if (_currentHighlightData == null) {
      getLogger().w('⚠️ 当前标注数据为空，无法执行操作');
      return;
    }

    final highlightData = _currentHighlightData!;
    final highlightId = highlightData['highlightId'] as String?;
    final content = highlightData['content'] as String?;

    getLogger().d('🎯 处理标注操作: $action, ID: $highlightId');

    // 先隐藏菜单
    hideHighlightActionMenu();

    switch (action) {
      case HighlightAction.copy:
        _handleCopyHighlight(content ?? '');
        break;
      case HighlightAction.delete:
        _handleDeleteHighlight(highlightId ?? '', content ?? '');
        break;
    }
  }

  // === 标注操作实现 ===
  Future<void> _handleCopyHighlight(String content) async {
    getLogger().d('📋 开始复制标注内容...');

    try {
      // 处理内容：去除多余的空白字符，保持基本格式
      final cleanContent = _cleanCopyContent(content);

      if (cleanContent.isEmpty) {
        getLogger().w('⚠️ 复制内容为空');
        BotToast.showText(text: '无法复制：内容为空');
        return;
      }

      getLogger().d('📋 准备复制内容: ${cleanContent.length > 50 ? '${cleanContent.substring(0, 50)}...' : cleanContent}');

      // 复制到剪贴板
      await Clipboard.setData(ClipboardData(text: cleanContent));

      // 触发轻触反馈
      HapticFeedback.lightImpact();

      // 用户反馈
      final previewText = cleanContent.length > 30
          ? '${cleanContent.substring(0, 30)}...'
          : cleanContent;
      BotToast.showText(text: '已复制："$previewText"');

      getLogger().i('✅ 标注内容复制成功');

    } catch (e) {
      getLogger().e('❌ 复制标注内容失败: $e');
      BotToast.showText(text: '复制失败，请重试');
    }
  }

  /// 清理复制内容
  String _cleanCopyContent(String content) {
    if (content.isEmpty) return '';

    // 移除HTML标签（如果有）
    String cleaned = content.replaceAll(RegExp(r'<[^>]*>'), '');

    // 规范化空白字符
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')  // 多个空白字符替换为单个空格
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n')  // 保留段落分隔但去除多余空行
        .trim();  // 去除首尾空白

    return cleaned;
  }

  Future<void> _handleDeleteHighlight(String highlightId, String content) async {
    getLogger().d('🗑️ 开始删除标注流程: $highlightId');

    try {
      // 第一步：显示确认对话框
      final shouldDelete = await showDeleteHighlightDialog(
        context: context,
        highlightContent: content,
        highlightId: highlightId,
      );

      if (shouldDelete != true) {
        getLogger().d('❌ 用户取消删除操作');
        return;
      }

      getLogger().i('✅ 用户确认删除，开始执行删除操作...');

      // 第二步：显示加载状态
      BotToast.showText(text: '正在删除标注...');

      // 第三步：从DOM中删除标注元素
      getLogger().d('🔄 从DOM中删除标注元素...');
      final domDeleteSuccess = await basicScriptsLogic.removeHighlight(highlightId);

      if (!domDeleteSuccess) {
        getLogger().e('❌ DOM删除失败');
        BotToast.showText(text: '删除失败：无法从页面中移除标注');
        return;
      }

      getLogger().i('✅ DOM删除成功');

      // 第四步：从数据库中删除记录
      getLogger().d('🔄 从数据库中删除标注记录...');
      await EnhancedAnnotationService.instance.deleteAnnotationByHighlightId(highlightId);

      getLogger().i('✅ 数据库删除成功');

      // 第五步：用户反馈
      BotToast.showText(text: '标注已删除');
      getLogger().i('🎉 标注删除完成: $highlightId');

    } catch (e) {
      getLogger().e('❌ 删除标注异常: $e');

      // 错误处理：尝试回滚操作
      getLogger().w('🔄 尝试回滚删除操作...');

      try {
        // 如果数据库删除失败，DOM可能已经删除，需要考虑数据一致性
        // 这里可以考虑重新加载页面或重新恢复标注
        BotToast.showText(text: '删除失败，请刷新页面重试');
      } catch (rollbackError) {
        getLogger().e('❌ 回滚操作也失败: $rollbackError');
        BotToast.showText(text: '删除异常，建议刷新页面');
      }
    }
  }


}
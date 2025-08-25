// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:math' as math;
import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/view/article/article_markdown/utils/basic_scripts_logic.dart';
import 'package:clipora/view/article/article_markdown/utils/simple_markdown_renderer.dart';
import 'package:clipora/view/article/article_markdown/utils/markdown_preprocessor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import '../../../basics/logger.dart';
import '../../../basics/ui.dart';
import '../../../db/annotation/enhanced_annotation_db.dart';
import '../../../db/annotation/enhanced_annotation_service.dart';
import '../../../db/article/article_db.dart';
import '../controller/article_controller.dart';
import 'components/article_markdown_add_note_dialog.dart';
import 'components/delete_highlight_dialog.dart';
import 'components/enhanced_selection_menu.dart';
import 'components/highlight_action_menu.dart';
import 'components/note_detail_bottom_sheet.dart';
import 'utils/simple_html_template.dart';
import 'utils/webview_injection_manager.dart';

class ArticleMarkdownWidget extends StatefulWidget {
  final String? url;
  final String markdownContent;
  final ArticleDb? article;
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final VoidCallback? onTap; // 添加点击回调
  final EdgeInsetsGeometry contentPadding;

  const ArticleMarkdownWidget({
    super.key,
    this.url,
    required this.markdownContent,
    this.article,
    this.onScroll,
    this.onTap, // 添加点击回调
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  State<ArticleMarkdownWidget> createState() => ArticleMarkdownWidgetState();
}

class ArticleMarkdownWidgetState extends State<ArticleMarkdownWidget> with ArticleMarkdownWidgetBLoC {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: _buildOptimizedWebView(),
    );
  }
  
  @override
  void dispose() {
    _injectionManager?.cleanup();
    super.dispose();
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

        articleController.context = context;

        webViewController = controller;
        articleController.markdownController = controller;
        // 注入主题色，保证加载前背景色一致（使用注入管理器）
        final config = articleController.currentThemeConfig;
        final bgColor = '#${config.backgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
        final textColor = '#${config.textColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
        _injectionManager = WebViewInjectionManager(controller);
        _injectionManager!.injectThemeColors(
          backgroundColor: bgColor,
          textColor: textColor,
        );
      },
      onLoadStart: (controller, url) {
        getLogger().d('🚀 WebView开始加载: $url');
      },
      onLoadStop: (controller, url) async {
        getLogger().d('🚀 WebView开始加载11111111111111: $url');
        try {
          getLogger().d('🚀 WebView开始加载11111111111111: $url');
          // 统一注册所有JS处理器与DOM监听器 + 注入核心脚本
          basicScriptsLogic = BasicScriptsLogic(webViewController!); // 保留实例用于后续高亮等操作
          final injectionSuccess = await _injectionManager?.initializeAll(
            onEnhancedTextSelected: handleEnhancedTextSelected,
            onSelectionCleared: handleEnhancedSelectionCleared,
            onHighlightClicked: handleHighlightClicked,
            onPageClicked: _handlePageClick,
          ) ?? false;
          getLogger().d('🔥 核心脚本注入结果: $injectionSuccess');

          await _renderMarkdownContent(); // 渲染文档

          // 您可以在这里根据业务逻辑计算动态高度，并设置顶部内边距
          // 例如，可以根据文章标题、作者信息等元素的高度来计算
          // double dynamicPadding = MediaQuery.of(context).padding.top + 20.0; // 这是一个示例值，请替换为您的计算逻辑
          // await setMarkdownPaddingTop(dynamicPadding);
          articleController.updateWebViewStyleSettings();

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

  // === WebView注入管理器 ===
  WebViewInjectionManager? _injectionManager;

  // @override
  EdgeInsetsGeometry get contentPadding => widget.contentPadding;

  double _lastScrollY = 0.0;
  Timer? _savePositionTimer;

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


  /// 预处理 Markdown 文本中的本地图片/链接路径，将以 cliporaimages/ 开头的相对路径补全为 file:// 完整路径
  /// 使用当前文章的 localMhtmlPath 作为根目录
  String _prepareMarkdownLocalImages(String content) {
    if (content.isEmpty || !content.contains('cliporaimages/')) {
      return content;
    }
    final localPath = articleController.currentArticle?.localMhtmlPath ?? '';
    if (localPath.isEmpty) {
      return content;
    }
    // 使用工具类统一处理，减少重复正则构建开销
    return MarkdownPreprocessor.prepareCliporaLocalAssets(content, localPath);
  }

  /// 为 Markdown 内容添加标题、域名和作者信息
  String _addHeaderToMarkdown(String content) {
    final article = widget.article;
    if (article == null) {
      return content;
    }

    final StringBuffer header = StringBuffer();
    
    // 添加文章标题
    if (article.title.isNotEmpty) {
      header.writeln('# ${article.title}');
      header.writeln();
    }
    
    // 添加域名和作者信息
    final List<String> metaInfo = [];
    if (article.domain.isNotEmpty) {
      metaInfo.add(article.domain);
    }
    if (article.author.isNotEmpty) {
      metaInfo.add(article.author);
    }
    
    if (metaInfo.isNotEmpty) {
      header.writeln(metaInfo.join(' | '));
      // header.writeln();
      header.writeln('---');
      header.writeln();
    }
    
    return header.toString() + content;
  }

  /// 设置Markdown内容的顶部内边距
  /// [padding] - The padding value in pixels.
  Future<void> setMarkdownPaddingTop(double padding) async {
    if (webViewController == null) {
      getLogger().w('⚠️ WebView controller is not ready, cannot set padding.');
      return;
    }
    try {
      await webViewController!.evaluateJavascript(source: 'window.setMarkdownPaddingTop($padding);');
      getLogger().i('✅ Successfully called setMarkdownPaddingTop with value: $padding');
    } catch (e) {
      getLogger().e('❌ Failed to set markdown padding top: $e');
    }
  }


  // === 内容渲染 ===
  Future<void> _renderMarkdownContent() async {

    try {
      getLogger().i('🎨 开始渲染Markdown内容 (长度: ${markdownContent.length})...');

      // 在渲染前预处理相对图片/链接路径
      final preparedContent = _prepareMarkdownLocalImages(markdownContent);
      
      // 添加标题、域名和作者信息
      final contentWithHeader = _addHeaderToMarkdown(preparedContent);

      // 使用简单的Markdown渲染器
      final success = await SimpleMarkdownRenderer.renderMarkdown(
        webViewController!,
        contentWithHeader,
      );

      if (success) {
        getLogger().i('✅ Markdown内容渲染成功');
        
        // 应用当前字体大小
        await _applyCurrentFontSize();
        
        // 应用当前主题
        await _applyCurrentTheme();
        
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

  /// 应用当前字体大小
  Future<void> _applyCurrentFontSize() async {
    if (webViewController != null) {
      try {
        final currentFontSize = articleController.fontSize;
        await webViewController!.evaluateJavascript(source: '''
          (function() {
            try {
              // 设置CSS变量
              document.documentElement.style.setProperty('--font-size', '${currentFontSize}px');
              
              // 更新所有文本元素的字体大小
              const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote, pre, code');
              textElements.forEach(element => {
                element.style.fontSize = '${currentFontSize}px';
              });
              
              // 更新行高以保持可读性
              const lineHeight = Math.max(1.4, ${currentFontSize} / 16);
              textElements.forEach(element => {
                element.style.lineHeight = lineHeight.toString();
              });
              
              console.log('✅ 初始字体大小应用成功: ${currentFontSize}px');
              return true;
            } catch (error) {
              console.error('❌ 应用字体大小失败:', error);
              return false;
            }
          })();
        ''');
        getLogger().i('✅ 初始字体大小应用成功: ${currentFontSize}px');
      } catch (e) {
        getLogger().e('❌ 应用初始字体大小失败: $e');
      }
    }
  }

  /// 应用当前主题
  Future<void> _applyCurrentTheme() async {
    if (webViewController != null) {
      try {
        final config = articleController.currentThemeConfig;
        await webViewController!.evaluateJavascript(source: '''
          (function() {
            try {
              // 更新CSS变量
              document.documentElement.style.setProperty('--background-color', '${_colorToHex(config.backgroundColor)}');
              document.documentElement.style.setProperty('--text-color', '${_colorToHex(config.textColor)}');
              document.documentElement.style.setProperty('--card-color', '${_colorToHex(config.cardColor)}');
              document.documentElement.style.setProperty('--divider-color', '${_colorToHex(config.dividerColor)}');
              
              // 更新body背景色
              document.body.style.backgroundColor = '${_colorToHex(config.backgroundColor)}';
              document.body.style.color = '${_colorToHex(config.textColor)}';
              
              // 更新所有文本元素的颜色
              const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote, pre, code, span, div');
              textElements.forEach(element => {
                element.style.color = '${_colorToHex(config.textColor)}';
              });
              
              // 更新代码块背景色
              const codeElements = document.querySelectorAll('pre, code');
              codeElements.forEach(element => {
                element.style.backgroundColor = '${_colorToHex(config.cardColor)}';
              });
              
              // 更新分割线颜色
              const hrElements = document.querySelectorAll('hr');
              hrElements.forEach(element => {
                element.style.borderColor = '${_colorToHex(config.dividerColor)}';
              });
              
              console.log('✅ 主题应用成功: ${config.name}');
              return true;
            } catch (error) {
              console.error('❌ 应用主题失败:', error);
              return false;
            }
          })();
        ''');
        getLogger().i('✅ 主题应用成功: ${config.name}');
        
        // 应用样式设置
        await _applyStyleSettings();
      } catch (e) {
        getLogger().e('❌ 应用主题失败: $e');
      }
    }
  }

  /// 应用样式设置
  Future<void> _applyStyleSettings() async {
    if (webViewController != null) {
      try {
        await webViewController!.evaluateJavascript(source: '''
          (function() {
            try {
              // 应用字体大小
              const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote, pre, code, span, div');
              textElements.forEach(element => {
                element.style.fontSize = '${articleController.fontSize}px';
                element.style.lineHeight = '${articleController.lineHeight}';
                element.style.letterSpacing = '${articleController.letterSpacing}px';
              });
              
              // 应用段落间距
              const paragraphElements = document.querySelectorAll('p');
              paragraphElements.forEach(element => {
                element.style.marginBottom = '${articleController.paragraphSpacing}px';
              });
              
              // 应用容器边距
              const container = document.querySelector('.markdown-content') || document.body;
              if (container) {
                container.style.padding = '${articleController.marginSize}px';
              }
              
              console.log('✅ 样式设置应用成功');
              return true;
            } catch (error) {
              console.error('❌ 应用样式设置失败:', error);
              return false;
            }
          })();
        ''');
        getLogger().i('✅ 样式设置应用成功');
      } catch (e) {
        getLogger().e('❌ 应用样式设置失败: $e');
      }
    }
  }

  /// 将Color转换为十六进制字符串
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
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
    _showEnhancedSelectionMenu(data);
  }

  /// 处理选择清除事件
  void handleEnhancedSelectionCleared(List<dynamic> args) {
    getLogger().d('🔍 清除前选择数据状态: ${_currentSelectionData != null ? "有数据" : "空"}');
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

    for (final field in requiredFields) {
      final hasField = data.containsKey(field);
      final isNotNull = hasField ? data[field] != null : false;
      getLogger().w('  - $field: 存在=$hasField, 非空=$isNotNull, 值=${data[field]}');
    }
  }

  // === 选择菜单显示逻辑 ===
  void _showEnhancedSelectionMenu(Map<String, dynamic> selectionData) {
    getLogger().d('🔥 _showEnhancedSelectionMenu 被调用');
    print('🔥 _showEnhancedSelectionMenu 被调用');

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
    print('🔥 scrollInfo $scrollInfo');
    hideEnhancedSelectionMenu();

    // 直接计算位置，使用JavaScript提供的视口相对位置
    _showMenuAtPosition(selectionData, webViewOffset, boundingRect, scrollInfo);
  }

  /// 隐藏增强选择菜单
  void hideEnhancedSelectionMenu() {
    getLogger().d('🔍 清空前选择数据状态: ${_currentSelectionData != null ? "有数据(${(_currentSelectionData!['selectedText'] as String? ?? '').length}字符)" : "空"}');
    
    _enhancedSelectionMenuOverlay?.remove();
    _enhancedSelectionMenuOverlay = null;
    _backgroundCatcher?.remove();
    _backgroundCatcher = null;
    _currentSelectionData = null;
  }


  void _showMenuAtPosition(
      Map<String, dynamic> selectionData,
      Offset webViewOffset,
      Map<String, dynamic> boundingRect,
      Map<String, dynamic>? scrollInfo,
      ) {

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
    if (Platform.isIOS) { //
      absoluteY += systemPadding.top;
    }

    // 计算在屏幕上的绝对位置
    final selectionRectOnScreen = Rect.fromLTWH(
      webViewOffset.dx + rectX + padding.left,
      absoluteY,
      rectWidth,
      rectHeight,
    );

    final screenSize = MediaQuery.of(context).size;
    const menuHeight = 70.0;
    const menuWidth = 230.0;

    // 计算可用空间
    final spaceAbove = selectionRectOnScreen.top - systemPadding.top - 20;
    final spaceBelow = screenSize.height - selectionRectOnScreen.bottom - systemPadding.bottom - 20;

    double menuY;

    // 智能位置选择：优先上方，但选择空间较大的位置
    if (spaceAbove >= menuHeight) {

      if (Platform.isIOS) {
        menuY = selectionRectOnScreen.top - menuHeight - systemPadding.top - 10;
      }else{
        menuY = selectionRectOnScreen.top - menuHeight ;
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

    // 计算左右位置，但确保不超出屏幕边界
    double menuX = 0;
    if(screenSize.width - boundingRect['x'] > menuWidth){
      menuX = boundingRect['x'].toDouble();
    }else{
      menuX = screenSize.width - menuWidth;
    }

    _backgroundCatcher = OverlayEntry(
      builder: (context) => SizedBox.expand(
        child: GestureDetector(
          onTap: hideEnhancedSelectionMenu,
          // behavior: HitTestBehavior.translucent,
        ),
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
        BotToast.showText(text: 'i18n_article_无法创建高亮文章信息缺失'.tr);
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
      annotation.serviceArticleId = articleController.currentArticle!.serviceId; // 服务端文章ID
      annotation.articleContentId = articleController.currentArticleContent!.id;
      annotation.serviceArticleContentId = articleController.currentArticleContent!.serviceId; // 服务端内容ID
      annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();
      annotation.uuid = getUuid();

      // 保存到数据库
      await EnhancedAnnotationService.instance.saveAnnotation(annotation);

      // 在WebView中创建高亮
      final success = await basicScriptsLogic.createHighlight(
        selectionData,
        annotation.highlightId,
        annotation.colorType.cssClass,
      );

      if (success) {
        BotToast.showText(text: 'i18n_article_高亮已添加'.tr);
        // getLogger().i('✅ 高亮创建成功: ${annotation.highlightId}，内容ID: $articleContentId');
      } else {
        BotToast.showText(text: 'i18n_article_高亮添加失败'.tr);
        // 回滚数据库操作
        await EnhancedAnnotationService.instance.deleteAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 创建高亮失败: $e');
      BotToast.showText(text: 'i18n_article_高亮添加失败'.tr);
    }
  }

  /// 为选中文本添加笔记
  void _handleCreateNote(Map<String, dynamic> selectionData) async {
    getLogger().i('📝 为选中文本添加笔记');
    try {
      if (articleController.currentArticle == null) {
        BotToast.showText(text: 'i18n_article_无法创建笔记文章信息缺失'.tr);
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
      annotation.serviceArticleId = articleController.currentArticle!.serviceId; // 服务端文章ID
      annotation.articleContentId = articleController.currentArticleContent!.id;
      annotation.serviceArticleContentId = articleController.currentArticleContent!.serviceId; // 服务端内容ID
      annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();
      annotation.uuid = getUuid();

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
        BotToast.showText(text: 'i18n_article_笔记已添加'.tr);
        getLogger().i('✅ 笔记创建成功: ${annotation.highlightId}，内容ID: ${articleController.currentArticle?.id}');
      } else {
        BotToast.showText(text: 'i18n_article_笔记添加失败'.tr);
        // 回滚数据库操作
        await EnhancedAnnotationService.instance.deleteAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 创建笔记失败: $e');
      BotToast.showText(text: 'i18n_article_笔记添加失败'.tr);
    }
  }



  // === 页面点击处理 ===
  /// 处理页面点击事件
  void _handlePageClick(List<dynamic> args) {
    getLogger().d('🎯 Markdown页面被点击');
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  // === 增强标注恢复 ===
  Future<void> _restoreEnhancedAnnotations() async {
    try {
      List<EnhancedAnnotationDb> annotations;

      // 优先使用基于articleContentId的新方法
      annotations = await EnhancedAnnotationService.instance.getAnnotationsForArticleContent(articleController.currentArticleContent!.id);

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

      // 如果有失败的标注，尝试逐个恢复
      if (stats['failCount']! > 0) {
        // await _restoreFailedAnnotationsOneByOne(annotations);
      }

    } catch (e) {
      getLogger().e('❌ 恢复增强标注失败: $e');
    }
  }



  // === 第一步：标注点击处理方法 ===
  void handleHighlightClicked(List<dynamic> args) {
    try {
      final data = args[0] as Map<String, dynamic>;

      // 验证数据完整性
      if (_validateHighlightClickData(data)) {
        // 检查是否是笔记标注
        final highlightId = data['highlightId'] as String;
        _checkAnnotationTypeAndShowContent(highlightId, data);
      } else {
        getLogger().w('⚠️ 标注点击数据验证失败');
        _logHighlightClickValidationDetails(data);
      }

    } catch (e) {
      getLogger().e('❌ 处理标注点击异常: $e');
    }
  }

  // === 检查标注类型并显示相应内容 ===
  void _checkAnnotationTypeAndShowContent(String highlightId, Map<String, dynamic> data) async {
    try {
      // 从数据库获取标注信息
      final annotation = await EnhancedAnnotationService.instance.getAnnotationByHighlightId(highlightId);
      
      if (annotation != null && annotation.annotationType == AnnotationType.note && annotation.noteContent.isNotEmpty) {
        // 这是一个笔记标注，显示底部弹窗
        _showNoteDetailBottomSheet(annotation, data);
      } else {
        // 这是普通高亮或没有笔记内容，显示标注操作菜单
        showHighlightActionMenu(data);
      }
      
    } catch (e) {
      getLogger().e('❌ 检查标注类型失败: $e');
      // 发生错误时回退到显示操作菜单
      showHighlightActionMenu(data);
    }
  }

  // === 显示笔记详情底部弹窗 ===
  void _showNoteDetailBottomSheet(EnhancedAnnotationDb annotation, Map<String, dynamic> data) async {
    try {
      await showNoteDetailBottomSheet(
        context: context,
        annotation: annotation,
        onColorSelected: (color) {
          // 处理颜色选择
          _handleColorSelectedFromBottomSheet(annotation.highlightId, color);
        },
        onDelete: () {
          // 处理删除
          _handleDeleteFromBottomSheet(annotation.highlightId, annotation.selectedText);
        },
        onCopy: () {
          // 处理复制 - 在底部弹窗中已经处理了，这里只需要记录日志
          getLogger().i('✅ 从底部弹窗复制笔记成功');
        },
      );
    } catch (e) {
      getLogger().e('❌ 显示笔记详情底部弹窗失败: $e');
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
    for (final field in requiredFields) {
      final hasField = data.containsKey(field);
      final isNotNull = hasField ? data[field] != null : false;
      getLogger().w('  - $field: 存在=$hasField, 非空=$isNotNull, 值=${data[field]}');
    }
  }

  // === 标注菜单显示逻辑 ===
  void showHighlightActionMenu(Map<String, dynamic> highlightData) {
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

  void _showMenuAtPosition2(Map<String, dynamic> highlightData, Offset webViewOffset, Map<String, dynamic> boundingRect) async {
    // 获取当前标注的颜色和笔记信息
    final highlightId = highlightData['highlightId'] as String;
    AnnotationColor currentColor = AnnotationColor.yellow; // 默认颜色
    bool hasNote = false;
    
    try {
      final annotation = await EnhancedAnnotationService.instance.getAnnotationByHighlightId(highlightId);
      if (annotation != null) {
        currentColor = annotation.colorType;
        hasNote = annotation.annotationType == AnnotationType.note && annotation.noteContent.isNotEmpty;
      }
    } catch (e) {
      getLogger().e('❌ 获取标注信息失败: $e');
    }

    // 提取边界框坐标（相对于WebView内容的坐标）
    final rectX = (boundingRect['x'] ?? 0).toDouble();
    final rectY = (boundingRect['y'] ?? 0).toDouble();
    final rectWidth = (boundingRect['width'] ?? 0).toDouble();
    final rectHeight = (boundingRect['height'] ?? 0).toDouble();

    // 考虑内容padding
    final padding = contentPadding.resolve(Directionality.of(context));
    final systemPadding = MediaQuery.of(context).padding;

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
    const menuHeight = 130.0; // 增加高度以容纳颜色选择器
    const menuWidth = 230.0;
    const menuMargin = 12.0; // 增加间距，确保不遮挡

    // 计算可用空间（保守估计）
    final availableTop = highlightRectOnScreen.top - systemPadding.top - 20;
    final availableBottom = screenSize.height - highlightRectOnScreen.bottom - systemPadding.bottom - 20;

    double menuY;
    bool isMenuAbove = true; // 标记菜单是否在标注上方

    // 强制优先上方显示（用户的要求）
    if (availableTop >= menuHeight ) {
      // 上方有充足空间，在标注上方显示，增加更多间距
      menuY = highlightRectOnScreen.top - menuHeight - menuMargin - 42;
      if (Platform.isIOS) {
        menuY = highlightRectOnScreen.top - menuHeight - 160;
      }else{
        menuY = highlightRectOnScreen.top - menuHeight - 24;
      }

      isMenuAbove = true;
    } else if (availableTop >= menuHeight) {
      // 上方有基本空间，紧贴显示
      menuY = highlightRectOnScreen.top - menuHeight - 4;
      isMenuAbove = true;
    } else if (availableBottom >= menuHeight + menuMargin) {
      // 上方空间不足，下方有充足空间
      menuY = highlightRectOnScreen.bottom + menuMargin;
      isMenuAbove = false;
    } else if (availableBottom >= menuHeight) {
      // 下方有基本空间
      menuY = highlightRectOnScreen.bottom + 4;
      isMenuAbove = false;
    } else {
      // 两边空间都不足，选择相对较好的位置
      if (availableTop >= availableBottom) {
        // 尽量在上方，即使会部分遮挡
        menuY = math.max(systemPadding.top + 8, highlightRectOnScreen.top - menuHeight);
        isMenuAbove = true;
      } else {
        // 下方显示
        menuY = math.min(screenSize.height - systemPadding.bottom - menuHeight - 8,
            highlightRectOnScreen.bottom + 4);
        isMenuAbove = false;
      }
    }

    // 水平居中在标注中心，但确保不超出屏幕边界
    double menuX = 0;
    if(screenSize.width - boundingRect['x'] > menuWidth){
      menuX = boundingRect['x'].toDouble();
    }else{
      menuX = screenSize.width - menuWidth;
    }

    // 最终验证：检查菜单是否与标注重叠
    final menuRect = Rect.fromLTWH(menuX, menuY, menuWidth, menuHeight);
    final hasOverlap = menuRect.overlaps(highlightRectOnScreen);

    if (hasOverlap) {
      // 如果有重叠且在上方，尝试进一步上移
      if (isMenuAbove && menuY > systemPadding.top + 8) {
        menuY = math.max(systemPadding.top + 8, menuY - 10);
        getLogger().d('🔧 调整菜单位置避免重叠: y=${menuY.toInt()}');
      }
    } else {
      getLogger().d('✅ 菜单位置验证通过，不会遮挡标注');
    }

    // 创建背景点击捕获器
    _highlightMenuBackgroundCatcher = OverlayEntry(
      builder: (context) => SizedBox.expand(
        child: GestureDetector(
          onTap: hideHighlightActionMenu,
          behavior: HitTestBehavior.translucent,
        ),
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
            onColorSelected: _handleColorSelected,
            currentColor: currentColor,
            hasNote: hasNote,
          ),
        ),
      ),
    );

    // 显示菜单
    Overlay.of(context).insertAll([
      _highlightMenuBackgroundCatcher!,
      _highlightMenuOverlay!
    ]);

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

    // 先隐藏菜单
    hideHighlightActionMenu();

    switch (action) {
      case HighlightAction.copy:
        _handleCopyHighlight(content ?? '');
        break;
      case HighlightAction.cancel:
        _handleDeleteHighlight(highlightId ?? '', content ?? '');
        break;
      case HighlightAction.changeColor:
        // 已通过颜色选择器处理
        break;
      case HighlightAction.viewNote:
        _handleViewNote(highlightId ?? '');
        break;
      case HighlightAction.addNote:
        _handleAddNoteToHighlight(highlightId ?? '', content ?? '');
        break;
    }
  }

  // === 为已有高亮添加笔记 ===
  void _handleAddNoteToHighlight(String highlightId, String content) async {
    if (highlightId.isEmpty) {
      getLogger().w('⚠️ 标注ID为空，无法添加笔记');
      return;
    }

    try {
      // 获取现有标注信息
      final annotation = await EnhancedAnnotationService.instance.getAnnotationByHighlightId(highlightId);
      if (annotation == null) {
        getLogger().w('⚠️ 未找到标注记录: $highlightId');
        BotToast.showText(text: 'i18n_article_标注记录不存在'.tr);
        return;
      }

      // 显示笔记输入对话框
      final noteText = await showArticleAddNoteDialog(
        context: context,
        selectedText: content,
      );

      if (noteText == null || noteText.isEmpty) {
        return; // 用户取消或输入为空
      }

      // 更新标注为笔记类型
      annotation.annotationType = AnnotationType.note;
      annotation.noteContent = noteText;
      annotation.colorType = AnnotationColor.green; // 笔记使用绿色
      annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();

      // 保存到数据库
      await EnhancedAnnotationService.instance.updateAnnotation(annotation);

      // 在WebView中更新高亮样式
      final success = await basicScriptsLogic.updateHighlightColor(
        highlightId,
        annotation.colorType.cssClass,
      );

      if (success) {
        BotToast.showText(text: 'i18n_article_笔记已添加'.tr);
        getLogger().i('✅ 为高亮添加笔记成功: $highlightId');
      } else {
        BotToast.showText(text: 'i18n_article_笔记添加失败'.tr);
        // 回滚数据库更改
        annotation.annotationType = AnnotationType.highlight;
        annotation.noteContent = '';
        await EnhancedAnnotationService.instance.updateAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 为高亮添加笔记失败: $e');
      BotToast.showText(text: 'i18n_article_笔记添加失败'.tr);
    }
  }

  // === 查看笔记处理 ===
  void _handleViewNote(String highlightId) async {
    if (highlightId.isEmpty) {
      getLogger().w('⚠️ 标注ID为空，无法查看笔记');
      return;
    }

    if (_currentHighlightData == null) {
      getLogger().w('⚠️ 当前标注数据为空，无法查看笔记');
      return;
    }

    try {
      // 获取标注信息
      final annotation = await EnhancedAnnotationService.instance.getAnnotationByHighlightId(highlightId);
      if (annotation == null) {
        getLogger().w('⚠️ 未找到标注记录: $highlightId');
        BotToast.showText(text: 'i18n_article_标注记录不存在'.tr);
        return;
      }

      if (annotation.noteContent.isEmpty) {
        getLogger().w('⚠️ 该标注没有笔记内容');
        BotToast.showText(text: 'i18n_article_该标注没有笔记内容'.tr);
        return;
      }

      // 使用底部弹窗显示笔记详情
      _showNoteDetailBottomSheet(annotation, _currentHighlightData!);
      
      getLogger().i('✅ 从操作菜单查看笔记成功');
    } catch (e) {
      getLogger().e('❌ 查看笔记失败: $e');
      BotToast.showText(text: 'i18n_article_查看笔记失败'.tr);
    }
  }

  // === 从底部弹窗处理颜色选择 ===
  void _handleColorSelectedFromBottomSheet(String highlightId, AnnotationColor selectedColor) async {
    try {
      // 在WebView中更新高亮颜色
      final success = await basicScriptsLogic.updateHighlightColor(
        highlightId,
        selectedColor.cssClass,
      );

      if (success) {
        getLogger().i('✅ 从底部弹窗更新标注颜色成功: $highlightId -> ${selectedColor.label}');
      } else {
        BotToast.showText(text: 'i18n_article_颜色更新失败'.tr);
      }
    } catch (e) {
      getLogger().e('❌ 从底部弹窗更新标注颜色失败: $e');
      BotToast.showText(text: 'i18n_article_颜色更新失败'.tr);
    }
  }

  // === 从底部弹窗处理删除 ===
  void _handleDeleteFromBottomSheet(String highlightId, String content) async {
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

      // 第二步：显示加载状态
      BotToast.showText(text: 'i18n_article_正在删除标注'.tr);

      // 第三步：从DOM中删除标注元素
      final domDeleteSuccess = await basicScriptsLogic.removeHighlight(highlightId);

      if (!domDeleteSuccess) {
        getLogger().e('❌ DOM删除失败');
        BotToast.showText(text: 'i18n_article_删除失败无法从页面中移除标注'.tr);
        return;
      }

      // 第四步：从数据库中删除记录
      getLogger().d('🔄 从数据库中删除标注记录...');
      await EnhancedAnnotationService.instance.deleteAnnotationByHighlightId(highlightId);

      // 第五步：用户反馈
      BotToast.showText(text: 'i18n_article_标注已删除'.tr);
      getLogger().i('🎉 从底部弹窗删除标注完成: $highlightId');

    } catch (e) {
      getLogger().e('❌ 从底部弹窗删除标注失败: $e');
      BotToast.showText(text: 'i18n_article_删除异常建议刷新页面'.tr);
    }
  }

  // === 颜色选择处理 ===
  void _handleColorSelected(AnnotationColor selectedColor) async {
    if (_currentHighlightData == null) {
      getLogger().w('⚠️ 当前标注数据为空，无法修改颜色');
      return;
    }

    final highlightData = _currentHighlightData!;
    final highlightId = highlightData['highlightId'] as String;

    try {
      // 隐藏菜单
      hideHighlightActionMenu();

      // 更新数据库中的颜色
      final annotation = await EnhancedAnnotationService.instance.getAnnotationByHighlightId(highlightId);
      if (annotation == null) {
        getLogger().w('⚠️ 未找到标注记录: $highlightId');
        BotToast.showText(text: 'i18n_article_标注记录不存在'.tr);
        return;
      }

      // 更新颜色
      annotation.colorType = selectedColor;
      annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();
      await EnhancedAnnotationService.instance.updateAnnotation(annotation);

      // 在WebView中更新高亮颜色
      final success = await basicScriptsLogic.updateHighlightColor(
        highlightId,
        selectedColor.cssClass,
      );

      if (success) {
        BotToast.showText(text: 'i18n_article_颜色已更新'.tr);
        getLogger().i('✅ 标注颜色更新成功: $highlightId -> ${selectedColor.label}');
      } else {
        BotToast.showText(text: 'i18n_article_颜色更新失败'.tr);
        // 回滚数据库更改
        annotation.colorType = AnnotationColor.yellow; // 回滚到默认颜色
        await EnhancedAnnotationService.instance.updateAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 更新标注颜色失败: $e');
      BotToast.showText(text: 'i18n_article_颜色更新失败'.tr);
    }
  }

  // === 标注操作实现 ===
  Future<void> _handleCopyHighlight(String content) async {
    try {
      // 处理内容：去除多余的空白字符，保持基本格式
      final cleanContent = _cleanCopyContent(content);

      if (cleanContent.isEmpty) {
        getLogger().w('⚠️ 复制内容为空');
        BotToast.showText(text: 'i18n_article_无法复制内容为空'.tr);
        return;
      }

      // 复制到剪贴板
      await Clipboard.setData(ClipboardData(text: cleanContent));

      // 触发轻触反馈
      HapticFeedback.lightImpact();

      // 用户反馈
      final previewText = cleanContent.length > 30
          ? '${cleanContent.substring(0, 30)}...'
          : cleanContent;
      BotToast.showText(text: '${'i18n_article_已复制'.tr}"$previewText"');
    } catch (e) {
      getLogger().e('❌ 复制标注内容失败: $e');
      BotToast.showText(text: 'i18n_article_复制失败请重试'.tr);
    }
  }

  /// 清理复制内容
  String _cleanCopyContent(String content) {
    return MarkdownPreprocessor.cleanTextForCopy(content);
  }

  Future<void> _handleDeleteHighlight(String highlightId, String content) async {
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

      // 第二步：显示加载状态
      BotToast.showText(text: 'i18n_article_正在删除标注'.tr);

      // 第三步：从DOM中删除标注元素
      final domDeleteSuccess = await basicScriptsLogic.removeHighlight(highlightId);

      if (!domDeleteSuccess) {
        getLogger().e('❌ DOM删除失败');
        BotToast.showText(text: 'i18n_article_删除失败无法从页面中移除标注'.tr);
        return;
      }

      // 第四步：从数据库中删除记录
      getLogger().d('🔄 从数据库中删除标注记录...');
      await EnhancedAnnotationService.instance.deleteAnnotationByHighlightId(highlightId);

      // 第五步：用户反馈
      BotToast.showText(text: 'i18n_article_标注已删除'.tr);
      getLogger().i('🎉 标注删除完成: $highlightId');

    } catch (e) {
      getLogger().e('❌ 回滚操作也失败: $e');
      BotToast.showText(text: 'i18n_article_删除异常建议刷新页面'.tr);
    }
  }


}
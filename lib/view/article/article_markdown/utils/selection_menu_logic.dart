import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../article_markdown_add_note_dialog.dart';
import '../../../../basics/logger.dart';
import '../../../../db/article/article_db.dart';
import '../../../../db/annotation/enhanced_annotation_db.dart';
import '../../../../db/annotation/enhanced_annotation_service.dart';
import 'basic_scripts_logic.dart';
import '../components/enhanced_selection_menu.dart';

/// 文本选择菜单业务逻辑 mixin
/// 
/// 负责处理：
/// - 选择菜单的显示和隐藏
/// - 选择菜单的位置计算
/// - 选择菜单动作的处理（复制、高亮、笔记）
/// - 选择数据的验证
mixin SelectionMenuLogic<T extends StatefulWidget> on State<T> {
  // === 需要在使用此 mixin 的类中提供这些属性 ===
  @protected
  ArticleDb? get article;
  @protected
  GlobalKey get webViewKey;
  @protected
  BasicScriptsLogic get basicScriptsLogic;
  @protected
  EdgeInsetsGeometry get contentPadding;

  // === 选择菜单相关状态 ===
  OverlayEntry? _enhancedSelectionMenuOverlay;
  OverlayEntry? _backgroundCatcher;
  Map<String, dynamic>? _currentSelectionData;

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
    
    _currentSelectionData = data;
    getLogger().d('🔥 准备显示选择菜单...');
    _showEnhancedSelectionMenu(data);
    
    getLogger().d('📝 文字被选择: "${data['selectedText']}" at (${data['boundingRect']['x']}, ${data['boundingRect']['y']})');
  }

  void handleEnhancedSelectionCleared(List<dynamic> args) {
    getLogger().d('❌ 选择已取消');
    hideEnhancedSelectionMenu();
    _currentSelectionData = null;
  }

  void handleHighlightCreated(List<dynamic> args) {
    final data = args[0] as Map<String, dynamic>;
    getLogger().d('🎨 高亮创建通知: $data');
    // 这里可以添加额外的处理逻辑，比如更新UI状态
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

  void _showMenuAtPosition(
    Map<String, dynamic> selectionData,
    Offset webViewOffset, 
    Map<String, dynamic> boundingRect,
    Map<String, dynamic>? scrollInfo,
  ) {
    getLogger().d('🎯 _showMenuAtPosition 开始执行');
    
    // 使用JavaScript提供的视口相对位置
    final rectX = (boundingRect['x'] ?? 0).toDouble();
    final rectY = (boundingRect['y'] ?? 0).toDouble();
    final rectWidth = (boundingRect['width'] ?? 0).toDouble();
    final rectHeight = (boundingRect['height'] ?? 0).toDouble();
    
    getLogger().d('📊 解析后的坐标: x=$rectX, y=$rectY, w=$rectWidth, h=$rectHeight');
    
    // 考虑内容padding
    final padding = contentPadding.resolve(Directionality.of(context));
    
    // 计算在屏幕上的绝对位置
    final selectionRectOnScreen = Rect.fromLTWH(
      webViewOffset.dx + rectX + padding.left,
      webViewOffset.dy + rectY + padding.top,
      rectWidth,
      rectHeight,
    );
    
    final screenSize = MediaQuery.of(context).size;
    final systemPadding = MediaQuery.of(context).padding;
    const menuHeight = 60.0;
    const menuWidth = 250.0;

    // 计算可用空间
    final spaceAbove = selectionRectOnScreen.top - systemPadding.top - 20;
    final spaceBelow = screenSize.height - selectionRectOnScreen.bottom - systemPadding.bottom - 20;
    
    double menuY;
    
    // 智能位置选择：优先上方，但选择空间较大的位置
    if (spaceAbove >= menuHeight) {
      // 上方有足够空间
      menuY = selectionRectOnScreen.top - menuHeight - 54;
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
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: hideEnhancedSelectionMenu,
          child: Container(color: Colors.transparent),
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

  void hideEnhancedSelectionMenu() {
    _enhancedSelectionMenuOverlay?.remove();
    _enhancedSelectionMenuOverlay = null;
    _backgroundCatcher?.remove();
    _backgroundCatcher = null;
  }

  void _handleEnhancedMenuAction(EnhancedSelectionAction action) {
    if (_currentSelectionData == null) return;
    
    final selectionData = _currentSelectionData!;
    final selectedText = selectionData['selectedText'] as String;
    
    hideEnhancedSelectionMenu();
    
    switch (action) {
      case EnhancedSelectionAction.copy:
        _handleCopyText(selectedText);
        break;
      case EnhancedSelectionAction.highlight:
        _handleCreateHighlight(selectionData);
        break;
      case EnhancedSelectionAction.note:
        _handleCreateNote(selectionData);
        break;
    }
  }

  // === 选择菜单动作实现 ===
  void _handleCopyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showMessage('已复制到剪贴板');
    getLogger().d('📋 文字已复制: $text');
  }

  Future<void> _handleCreateHighlight(Map<String, dynamic> selectionData) async {
    try {
      if (article?.id == null) {
        showMessage('无法创建高亮：文章信息缺失');
        return;
      }

      // 创建增强标注
      final annotation = EnhancedAnnotationDb.fromSelectionData(
        selectionData,
        article!.id,
        AnnotationType.highlight,
        colorType: AnnotationColor.yellow,
      );

      // 保存到数据库
      await EnhancedAnnotationService.instance.saveAnnotation(annotation);

      // 在WebView中创建高亮
      final success = await basicScriptsLogic.createHighlight(
        selectionData,
        annotation.highlightId,
        annotation.colorType.cssClass,
      );

      if (success) {
        showMessage('高亮已添加');
        getLogger().i('✅ 高亮创建成功: ${annotation.highlightId}');
      } else {
        showMessage('高亮添加失败');
        // 回滚数据库操作
        await EnhancedAnnotationService.instance.deleteAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 创建高亮失败: $e');
      showMessage('高亮添加失败');
    }
  }

  Future<void> _handleCreateNote(Map<String, dynamic> selectionData) async {
    try {
      if (article?.id == null) {
        showMessage('无法创建笔记：文章信息缺失');
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
        article!.id,
        AnnotationType.note,
        colorType: AnnotationColor.green,
        noteContent: noteText,
      );

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
        showMessage('笔记已添加');
        getLogger().i('✅ 笔记创建成功: ${annotation.highlightId}');
      } else {
        showMessage('笔记添加失败');
        // 回滚数据库操作
        await EnhancedAnnotationService.instance.deleteAnnotation(annotation);
      }
    } catch (e) {
      getLogger().e('❌ 创建笔记失败: $e');
      showMessage('笔记添加失败');
    }
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

  // === 消息显示辅助方法 ===
  void showMessage(String message) {
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

  // === 清理方法 ===
  void disposeSelectionMenu() {
    hideEnhancedSelectionMenu();
    _currentSelectionData = null;
  }
}


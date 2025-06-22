import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../basics/logger.dart';
import '../../../../db/article/article_db.dart';
import '../../../../db/annotation/enhanced_annotation_service.dart';
import '../components/highlight_action_menu.dart';
import '../components/delete_highlight_dialog.dart';
import 'basic_scripts_logic.dart';

/// 标注菜单业务逻辑 mixin
/// 
/// 独立处理标注点击后的操作菜单：
/// - 菜单的显示和隐藏
/// - 菜单位置计算
/// - 菜单操作处理（删除、复制等）
/// - 与文本选择菜单完全分离
mixin HighlightMenuLogic<T extends StatefulWidget> on State<T> {
  // === 需要在使用此 mixin 的类中提供这些属性 ===
  @protected
  ArticleDb? get article;
  @protected
  GlobalKey get webViewKey;
  @protected
  EdgeInsetsGeometry get contentPadding;
  @protected
  BasicScriptsLogic get basicScriptsLogic;

  // === 标注菜单相关状态 ===
  OverlayEntry? _highlightMenuOverlay;
  OverlayEntry? _highlightMenuBackgroundCatcher;
  Map<String, dynamic>? _currentHighlightData;

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
    _showMenuAtPosition(highlightData, webViewOffset, boundingRect);
  }

  void _showMenuAtPosition(
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
    getLogger().d('📊 内容padding: left=${padding.left}, top=${padding.top}, right=${padding.right}, bottom=${padding.bottom}');
    
    // 计算标注在屏幕上的绝对位置（这是关键！）
    final highlightRectOnScreen = Rect.fromLTWH(
      webViewOffset.dx + rectX + padding.left,
      webViewOffset.dy + rectY + padding.top,
      rectWidth,
      rectHeight,
    );
    
    final screenSize = MediaQuery.of(context).size;
    final systemPadding = MediaQuery.of(context).padding;
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
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: hideHighlightActionMenu,
          child: Container(color: Colors.transparent),
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
        _showMessage('无法复制：内容为空');
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
      _showMessage('已复制："$previewText"');
      
      getLogger().i('✅ 标注内容复制成功');
      
    } catch (e) {
      getLogger().e('❌ 复制标注内容失败: $e');
      _showMessage('复制失败，请重试');
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
      _showMessage('正在删除标注...');
      
      // 第三步：从DOM中删除标注元素
      getLogger().d('🔄 从DOM中删除标注元素...');
      final domDeleteSuccess = await basicScriptsLogic.removeHighlight(highlightId);
      
      if (!domDeleteSuccess) {
        getLogger().e('❌ DOM删除失败');
        _showMessage('删除失败：无法从页面中移除标注');
        return;
      }
      
      getLogger().i('✅ DOM删除成功');
      
      // 第四步：从数据库中删除记录
      getLogger().d('🔄 从数据库中删除标注记录...');
      await EnhancedAnnotationService.instance.deleteAnnotationByHighlightId(highlightId);
      
      getLogger().i('✅ 数据库删除成功');
      
      // 第五步：用户反馈
      _showMessage('标注已删除');
      getLogger().i('🎉 标注删除完成: $highlightId');
      
    } catch (e) {
      getLogger().e('❌ 删除标注异常: $e');
      
      // 错误处理：尝试回滚操作
      getLogger().w('🔄 尝试回滚删除操作...');
      
      try {
        // 如果数据库删除失败，DOM可能已经删除，需要考虑数据一致性
        // 这里可以考虑重新加载页面或重新恢复标注
        _showMessage('删除失败，请刷新页面重试');
      } catch (rollbackError) {
        getLogger().e('❌ 回滚操作也失败: $rollbackError');
        _showMessage('删除异常，建议刷新页面');
      }
    }
  }

  // === 消息显示辅助方法 ===
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

  // === 清理方法 ===
  void disposeHighlightMenu() {
    hideHighlightActionMenu();
    _currentHighlightData = null;
    getLogger().d('🧹 HighlightMenuLogic 已清理');
  }
} 
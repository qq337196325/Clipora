// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import '../../../../basics/ui.dart';
import '../../../../db/annotation/enhanced_annotation_db.dart';
import '../../../../db/annotation/enhanced_annotation_service.dart';
import '../../../../basics/logger.dart';
import 'delete_highlight_dialog.dart';

/// 笔记详情底部弹窗
/// 显示笔记内容和相关操作
class NoteDetailBottomSheet extends StatefulWidget {
  final EnhancedAnnotationDb annotation;
  final Function(AnnotationColor)? onColorSelected;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const NoteDetailBottomSheet({
    super.key,
    required this.annotation,
    this.onColorSelected,
    this.onDelete,
    this.onCopy,
  });

  @override
  State<NoteDetailBottomSheet> createState() => _NoteDetailBottomSheetState();
}

class _NoteDetailBottomSheetState extends State<NoteDetailBottomSheet> {
  late AnnotationColor _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.annotation.colorType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          _buildDragIndicator(),
          
          // 原文引用
          _buildOriginalTextSection(),
          
          // 笔记内容
          _buildNoteContentSection(),
          
          // 颜色选择器
          _buildColorSelector(),
          
          // 操作按钮
          _buildActionButtons(),
          
          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// 构建拖拽指示器
  Widget _buildDragIndicator() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建原文引用部分
  Widget _buildOriginalTextSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: _currentColor.flutterColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'i18n_article_原文引用'.tr,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.annotation.selectedText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建笔记内容部分
  Widget _buildNoteContentSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'i18n_article_笔记内容'.tr,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Text(
                widget.annotation.noteContent,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建颜色选择器
  Widget _buildColorSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'i18n_article_标注颜色'.tr,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AnnotationColor.values.map((color) {
                return _buildColorButton(color);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建颜色按钮
  Widget _buildColorButton(AnnotationColor color) {
    final isSelected = _currentColor == color;
    
    return GestureDetector(
      onTap: () => _handleColorChange(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.flutterColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : color.flutterColor.withOpacity(0.5),
            width: isSelected ? 3 : 2,
          ),
        ),
        child: isSelected 
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              )
            : null,
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.content_copy,
              label: 'i18n_article_复制'.tr,
              onTap: _handleCopy,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.delete_outline,
              label: 'i18n_article_删除'.tr,
              onTap: _handleDelete,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理颜色变更
  void _handleColorChange(AnnotationColor newColor) async {
    if (newColor == _currentColor) return;

    try {
      setState(() {
        _currentColor = newColor;
      });

      // 更新数据库
      widget.annotation.colorType = newColor;
      widget.annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();
      await EnhancedAnnotationService.instance.updateAnnotation(widget.annotation);

      // 调用回调
      widget.onColorSelected?.call(newColor);

      BotToast.showText(text: 'i18n_article_颜色已更新'.tr);
      getLogger().i('✅ 标注颜色更新成功: ${widget.annotation.highlightId} -> ${newColor.label}');
    } catch (e) {
      getLogger().e('❌ 更新标注颜色失败: $e');
      BotToast.showText(text: 'i18n_article_颜色更新失败'.tr);
      // 回滚UI状态
      setState(() {
        _currentColor = widget.annotation.colorType;
      });
    }
  }

  /// 处理复制
  void _handleCopy() async {
    try {
      // 复制笔记内容和原文
      final copyText = '${widget.annotation.selectedText}\n\n${'i18n_article_笔记'.tr}：\n${widget.annotation.noteContent}';
      await Clipboard.setData(ClipboardData(text: copyText));
      
      // 触发轻触反馈
      HapticFeedback.lightImpact();
      
      // 调用回调
      widget.onCopy?.call();
      
      BotToast.showText(text: 'i18n_article_已复制'.tr);
      Navigator.of(context).pop();
    } catch (e) {
      getLogger().e('❌ 复制失败: $e');
      BotToast.showText(text: 'i18n_article_复制失败'.tr);
    }
  }

  /// 处理删除
  void _handleDelete() async {
    Navigator.of(context).pop(); // 先关闭底部弹窗
    
    try {
      // 显示确认对话框
      final shouldDelete = await showDeleteHighlightDialog(
        context: context,
        highlightContent: widget.annotation.selectedText,
        highlightId: widget.annotation.highlightId,
      );

      if (shouldDelete == true) {
        // 调用删除回调
        widget.onDelete?.call();
      }
    } catch (e) {
      getLogger().e('❌ 删除操作失败: $e');
      BotToast.showText(text: 'i18n_article_删除失败'.tr);
    }
  }
}

/// 显示笔记详情底部弹窗
Future<void> showNoteDetailBottomSheet({
  required BuildContext context,
  required EnhancedAnnotationDb annotation,
  Function(AnnotationColor)? onColorSelected,
  VoidCallback? onDelete,
  VoidCallback? onCopy,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NoteDetailBottomSheet(
      annotation: annotation,
      onColorSelected: onColorSelected,
      onDelete: onDelete,
      onCopy: onCopy,
    ),
  );
}
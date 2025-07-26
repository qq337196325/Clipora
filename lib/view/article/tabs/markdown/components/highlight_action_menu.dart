import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../db/annotation/enhanced_annotation_db.dart';



/// 标注操作菜单动作类型
enum HighlightAction {
  cancel,     // 取消标注
  copy,       // 复制内容
  changeColor, // 改变颜色
  viewNote,   // 查看笔记
  addNote,    // 添加笔记
}

/// 标注操作菜单组件
/// 
/// 当用户点击已有标注时显示，提供删除、复制等操作
class HighlightActionMenu extends StatelessWidget {
  final Function(HighlightAction) onAction;
  final Function(AnnotationColor)? onColorSelected;
  final AnnotationColor? currentColor;
  final bool hasNote; // 是否有笔记内容

  const HighlightActionMenu({
    super.key,
    required this.onAction,
    this.onColorSelected,
    this.currentColor,
    this.hasNote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 颜色选择器
        if (onColorSelected != null) _buildColorSelector(context),
        if (onColorSelected != null) const SizedBox(height: 8),
        // 操作菜单
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                context,
                icon: Icons.content_copy,
                label: 'i18n_article_复制'.tr,
                action: HighlightAction.copy,
                color: Theme.of(context).colorScheme.primary,
              ),
              if (hasNote) ...[
                _buildDivider(context),
                _buildActionButton(
                  context,
                  icon: Icons.sticky_note_2_outlined,
                  label: 'i18n_article_查看笔记'.tr,
                  action: HighlightAction.viewNote,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
              if (!hasNote) ...[
                _buildDivider(context),
                _buildActionButton(
                  context,
                  icon: Icons.note_add_outlined,
                  label: 'i18n_article_添加笔记'.tr,
                  action: HighlightAction.addNote,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
              _buildDivider(context),
              _buildActionButton(
                context,
                icon: Icons.close_outlined,
                label: 'i18n_article_取消'.tr,
                action: HighlightAction.cancel,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required HighlightAction action,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAction(action),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }

  /// 构建颜色选择器
  Widget _buildColorSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AnnotationColor.values.map((color) {
          return _buildColorButton(context, color);
        }).toList(),
      ),
    );
  }

  /// 构建颜色按钮
  Widget _buildColorButton(BuildContext context, AnnotationColor color) {
    final isSelected = currentColor == color;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onColorSelected?.call(color),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.flutterColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : color.flutterColor.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected 
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  )
                : null,
          ),
        ),
      ),
    );
  }

}
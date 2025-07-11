import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 标注操作菜单动作类型
enum HighlightAction {
  delete,     // 删除标注
  copy,       // 复制内容
  // TODO: 后续可以添加 edit, addNote 等
}

/// 标注操作菜单组件
/// 
/// 当用户点击已有标注时显示，提供删除、复制等操作
class HighlightActionMenu extends StatelessWidget {
  final Function(HighlightAction) onAction;

  const HighlightActionMenu({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildDivider(context),
          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            label: 'i18n_article_删除'.tr,
            action: HighlightAction.delete,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
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
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 增强选择菜单动作类型
enum EnhancedSelectionAction {
  copy,       // 复制
  highlight,  // 高亮
  note,       // 笔记
}

/// 增强版选择菜单组件
/// 
/// 支持基于Range API的精确文本标注功能
class EnhancedSelectionMenu extends StatelessWidget {
  final Function(EnhancedSelectionAction) onAction;

  const EnhancedSelectionMenu({
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
            icon: Icons.copy,
            label: 'i18n_article_复制'.tr,
            action: EnhancedSelectionAction.copy,
          ),
          _buildDivider(context),
          _buildActionButton(
            context,
            icon: Icons.highlight,
            label: 'i18n_article_高亮'.tr,
            action: EnhancedSelectionAction.highlight,
            color: Colors.yellow[700],
          ),
          _buildDivider(context),
          _buildActionButton(
            context,
            icon: Icons.note_add,
            label: 'i18n_article_笔记'.tr,
            action: EnhancedSelectionAction.note,
            color: Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required EnhancedSelectionAction action,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAction(action),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      height: 32,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }
} 
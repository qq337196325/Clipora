import 'package:flutter/material.dart';

/// 文本选择操作的类型
enum SelectionAction { copy, highlight, note, share }

/// 一个自定义的文本选择弹出菜单。
class ArticleMarkdownSelectionMenu extends StatelessWidget {
  final Function(SelectionAction) onAction;

  const ArticleMarkdownSelectionMenu({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuButton(
                icon: Icons.copy,
                label: '复制',
                onTap: () => onAction(SelectionAction.copy),
              ),
              _buildDivider(),
              _buildMenuButton(
                icon: Icons.highlight,
                label: '高亮',
                onTap: () => onAction(SelectionAction.highlight),
              ),
              _buildDivider(),
              _buildMenuButton(
                icon: Icons.note_add,
                label: '笔记',
                onTap: () => onAction(SelectionAction.note),
              ),
              _buildDivider(),
              _buildMenuButton(
                icon: Icons.share,
                label: '分享',
                onTap: () => onAction(SelectionAction.share),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.grey[600]);
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
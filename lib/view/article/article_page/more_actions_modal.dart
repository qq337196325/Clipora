import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'move_to_category_modal.dart';
import 'tag_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isEnabled;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isEnabled = true,
  });
}

class MoreActionsModal extends StatelessWidget {
  final VoidCallback? onReGenerateSnapshot;
  final int articleId;

  const MoreActionsModal({super.key, this.onReGenerateSnapshot, required this.articleId});

  void _showToast(BuildContext context, String message) {
    Navigator.of(context).pop();
    BotToast.showText(text: '$message 功能待开发');
  }

  void _showTagEditModal(BuildContext context) {
    // Navigator.of(context).pop();
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => TagEditModal(articleId: articleId),
    );
  }

  void _showMoveToCategoryModal(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => MoveToCategoryModal(articleId: articleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final List<_ActionItem> actions = [
      _ActionItem(icon: Icons.edit_outlined, label: '编辑信息', onTap: () => _showToast(context, '编辑信息')),
      _ActionItem(icon: Icons.explore_outlined, label: '浏览器访问', onTap: () => _showToast(context, '使用浏览器访问')),
      _ActionItem(icon: Icons.link, label: '复制链接', onTap: () => _showToast(context, '复制网页链接')),
      _ActionItem(icon: Icons.cloud_download_outlined, label: '下载', isEnabled: false, onTap: () {}),
      _ActionItem(icon: Icons.block, label: '不再解析', onTap: () => _showToast(context, '不再解析文章')),
      _ActionItem(icon: Icons.refresh, label: '刷新解析', onTap: () => _showToast(context, '刷新文章解析')),
      _ActionItem(
          icon: Icons.camera_alt_outlined,
          label: '重新生成快照',
          onTap: () {
            if (onReGenerateSnapshot != null) {
              Navigator.of(context).pop();
              onReGenerateSnapshot!();
            } else {
              _showToast(context, '重新生成快照');
            }
          }),
      _ActionItem(icon: Icons.label_outline, label: '标签', onTap: () => _showTagEditModal(context)),
      _ActionItem(icon: Icons.drive_file_move_outline, label: '移动', onTap: () => _showMoveToCategoryModal(context)),
      _ActionItem(icon: Icons.star_border, label: '星标', onTap: () => _showToast(context, '星标')),
      _ActionItem(icon: Icons.archive_outlined, label: '归档', onTap: () => _showToast(context, '归档')),
      _ActionItem(icon: Icons.delete_outline, label: '删除', onTap: () => _showToast(context, '删除'), isDestructive: true),
    ];

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '阅读器动作',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.9,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return _buildActionGridItem(context, actions[index]);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGridItem(BuildContext context, _ActionItem item) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    Color color;
    if (!item.isEnabled) {
      color = onSurfaceColor.withOpacity(0.38);
    } else if (item.isDestructive) {
      color = const Color(0xFFFF453A);
    } else {
      color = onSurfaceColor;
    }

    return InkWell(
      onTap: item.isEnabled ? item.onTap : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(item.icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 
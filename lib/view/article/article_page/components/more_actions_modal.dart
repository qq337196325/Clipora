import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/article_controller.dart';
import 'move_to_category_modal.dart';
import 'tag_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../db/article/article_db.dart';
import '../../../../db/article/article_service.dart';
import '../../../../basics/logger.dart';


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

class MoreActionsModal extends StatefulWidget {
  final VoidCallback? onReGenerateSnapshot;
  final int articleId;
  final ArticleDb? article;

  const MoreActionsModal({
    super.key, 
    this.onReGenerateSnapshot, 
    required this.articleId,
    this.article,
  });

  @override
  State<MoreActionsModal> createState() => _MoreActionsModalState();
}

class _MoreActionsModalState extends State<MoreActionsModal> {
  ArticleDb? _article;
  bool _isLoading = false;
  // 文章控制器
  final ArticleController articleController = Get.find<ArticleController>();

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    if (_article == null) {
      _loadArticle();
    }
  }

  Future<void> _loadArticle() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final article = await ArticleService.instance.getArticleById(widget.articleId);
      if (mounted) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showToast(BuildContext context, String message) {
    Navigator.of(context).pop();
    BotToast.showText(text: '$message 功能待开发');
  }

  /// 浏览器访问功能
  Future<void> _openInBrowser(BuildContext context) async {
    final url = articleController.articleUrl;
    
    if (url.isEmpty) {
      BotToast.showText(text: '文章链接不存在');
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        Navigator.of(context).pop();
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        getLogger().i('✅ 成功在浏览器中打开: $url');
      } else {
        Navigator.of(context).pop();
        BotToast.showText(text: '无法打开该链接');
        getLogger().w('⚠️ 无法打开链接: $url');
      }
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '打开链接失败: $e');
      getLogger().e('❌ 打开链接失败: $e');
    }
  }

  /// 复制链接功能
  Future<void> _copyLink(BuildContext context) async {
    final url = articleController.articleUrl;
    
    if (url.isEmpty) {
      BotToast.showText(text: '文章链接不存在');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: url));
      Navigator.of(context).pop();
      BotToast.showText(text: '链接已复制到剪贴板');
      getLogger().i('✅ 链接已复制: $url');
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '复制失败: $e');
      getLogger().e('❌ 复制链接失败: $e');
    }
  }

  void _showTagEditModal(BuildContext context) {
    // Navigator.of(context).pop();
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => TagEditModal(articleId: widget.articleId),
    );
  }

  void _showMoveToCategoryModal(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => MoveToCategoryModal(articleId: widget.articleId),
    );
  }

  Future<void> _toggleImportantStatus(BuildContext context) async {
    if (_article == null) {
      BotToast.showText(text: '文章信息加载中，请稍后重试');
      return;
    }

    try {
      final newStatus = await ArticleService.instance.toggleImportantStatus(widget.articleId);
      
      if (mounted) {
        setState(() {
          _article!.isImportant = newStatus;
        });
        
        Navigator.of(context).pop();
        BotToast.showText(
          text: newStatus ? '已标记为重要' : '已取消重要标记',
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '操作失败：$e');
    }
  }

  Future<void> _toggleArchiveStatus(BuildContext context) async {
    if (_article == null) {
      BotToast.showText(text: '文章信息加载中，请稍后重试');
      return;
    }

    try {
      final newStatus = await ArticleService.instance.toggleArchiveStatus(widget.articleId);
      
      if (mounted) {
        setState(() {
          _article!.isArchived = newStatus;
        });
        
        Navigator.of(context).pop();
        BotToast.showText(
          text: newStatus ? '已归档' : '已取消归档',
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '操作失败：$e');
    }
  }

  /// 显示删除确认对话框
  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    if (_article == null) {
      BotToast.showText(text: '文章信息加载中，请稍后重试');
      return;
    }

    // 先关闭当前的底部弹窗
    Navigator.of(context).pop();

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '确认删除',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '确定要删除这篇文章吗？',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _article!.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '删除后的文章可以在回收站中找到。',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    // 如果用户确认删除
    if (confirmed == true) {
      await _deleteArticle(context);
    }
  }

  /// 执行删除操作
  Future<void> _deleteArticle(BuildContext context) async {
    try {
      await ArticleService.instance.softDeleteArticle(widget.articleId);
      
      if (mounted) {
        BotToast.showText(text: '文章已删除');
        
        // 返回到文章列表页面
        // 确认对话框已经通过pop(true)关闭，这里只需要返回到文章列表
        Navigator.of(context).pop(); // 返回到文章列表页面
      }
    } catch (e) {
      BotToast.showText(text: '删除失败：$e');
      getLogger().e('❌ 删除文章失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 根据文章的重要状态动态设置图标和文字
    final isImportant = _article?.isImportant ?? false;
    final isArchived = _article?.isArchived ?? false;
    
    // 检查文章URL是否存在
    final hasUrl = articleController.articleUrl.isNotEmpty;

    final List<_ActionItem> actions = [
      // _ActionItem(
      //   icon: Icons.explore_outlined,
      //   label: '浏览器访问',
      //   onTap: () => _openInBrowser(context),
      //   isEnabled: hasUrl,
      // ),
      _ActionItem(
        icon: Icons.link, 
        label: '复制链接', 
        onTap: () => _copyLink(context),
        isEnabled: hasUrl,
      ),
      _ActionItem(icon: Icons.refresh, label: '刷新解析', onTap: () => _showToast(context, '刷新文章解析')),
      _ActionItem(
          icon: Icons.camera_alt_outlined,
          label: '重新生成快照',
          onTap: () {
            if (widget.onReGenerateSnapshot != null) {
              Navigator.of(context).pop();
              widget.onReGenerateSnapshot!();
            } else {
              _showToast(context, '重新生成快照');
            }
          }),
      _ActionItem(icon: Icons.label_outline, label: '标签', onTap: () => _showTagEditModal(context)),
      _ActionItem(icon: Icons.drive_file_move_outline, label: '移动', onTap: () => _showMoveToCategoryModal(context)),
             _ActionItem(
         icon: isImportant ? Icons.star : Icons.star_border, 
         label: isImportant ? '取消重要' : '标为重要', 
         onTap: () => _toggleImportantStatus(context)
       ),
       _ActionItem(
         icon: isArchived ? Icons.unarchive : Icons.archive_outlined, 
         label: isArchived ? '取消归档' : '归档', 
         onTap: () => _toggleArchiveStatus(context)
       ),
      _ActionItem(icon: Icons.delete_outline, label: '删除', onTap: () => _showDeleteConfirmDialog(context), isDestructive: true),
    ];

    return Material(
      color: theme.cardColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
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

                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),


                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                //   child: Text(
                //     '阅读器动作',
                //     style: TextStyle(
                //       fontSize: 13,
                //       fontWeight: FontWeight.w600,
                //       color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                //     ),
                //   ),
                // ),
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
        ],
      ),
    );
  }

  Widget _buildActionGridItem(BuildContext context, _ActionItem item) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final isImportant = _article?.isImportant ?? false;
    final isArchived = _article?.isArchived ?? false;
    final isImportantAction = item.label.contains('重要');
    final isArchiveAction = item.label.contains('归档');
    
    Color color;
    if (!item.isEnabled) {
      color = onSurfaceColor.withOpacity(0.38);
    } else if (item.isDestructive) {
      color = const Color(0xFFFF453A);
    } else if (isImportantAction && isImportant) {
      // 如果是重要操作且当前已标记为重要，使用橙色
      color = Colors.orange;
    } else if (isArchiveAction && isArchived) {
      // 如果是归档操作且当前已归档，使用灰色
      color = Colors.grey;
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
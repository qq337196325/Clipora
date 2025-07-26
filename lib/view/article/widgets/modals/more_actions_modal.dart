import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../db/article/service/article_service.dart';
import '../../controller/article_controller.dart';
import '../read_theme_widget.dart';
import 'move_to_category_modal.dart';
import 'tag_edit_modal.dart';
import 'translate_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../db/article/article_db.dart';
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
  final VoidCallback? onReGenerateMarkdown;
  final int articleId;
  final ArticleDb? article;
  final TabController currentTab;
  final int? webTabIndex;
  final List<String>? tabs;

  const MoreActionsModal({
    super.key, 
    this.onReGenerateSnapshot, 
    this.onReGenerateMarkdown,
    required this.articleId,
    this.article,
    required this.currentTab,
    this.webTabIndex,
    this.tabs,
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
    BotToast.showText(text: '${message} ${'i18n_article_功能待开发'.tr}');
  }

  /// 复制链接功能
  Future<void> _copyLink(BuildContext context) async {
    final url = articleController.articleUrl;
    
    if (url.isEmpty) {
      BotToast.showText(text: 'i18n_article_文章链接不存在'.tr);
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: url));
      Navigator.of(context).pop();
      BotToast.showText(text: 'i18n_article_链接已复制到剪贴板'.tr);
      getLogger().i('✅ 链接已复制: $url');
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '${'i18n_article_复制失败'.tr}$e');
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


  void _showTranslateModal(BuildContext context) {
    Navigator.of(context).pop();
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => TranslateModal(articleId: widget.articleId),
    );
  }

  void _showMoveToCategoryModal(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => MoveToCategoryModal(articleId: widget.articleId),
    );
  }

  _showReadThemeWidgetModal(BuildContext context){

    Navigator.of(context).pop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0, // 设置阴影为0，移除阴影效果
      barrierColor: Colors.transparent, // 移除遮罩效果
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReadThemeWidget(articleId: widget.articleId),
    );
  }

  Future<void> _toggleImportantStatus(BuildContext context) async {
    if (_article == null) {
      BotToast.showText(text: 'i18n_article_文章信息加载中请稍后重试'.tr);
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
          text: newStatus ? 'i18n_article_已标记为重要'.tr : 'i18n_article_已取消重要标记'.tr,
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '${'i18n_article_操作失败'.tr}$e');
    }
  }

  Future<void> _toggleArchiveStatus(BuildContext context) async {
    if (_article == null) {
      BotToast.showText(text: 'i18n_article_文章信息加载中请稍后重试'.tr);
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
          text: newStatus ? 'i18n_article_已归档'.tr : 'i18n_article_已取消归档'.tr,
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      BotToast.showText(text: '${'i18n_article_操作失败'.tr}$e');
    }
  }

  /// 检查是否在网页tab
  bool _isInWebTab() {
    if (widget.webTabIndex == null) {
      return true; // 如果无法获取tab信息，默认允许操作
    }

    if(widget.tabs?[widget.currentTab.index] == 'i18n_article_网页'.tr){
      return true;
    }
    return false;
    // return widget.currentTabIndex == widget.webTabIndex;
  }


  /// 显示需要切换到网页tab的提示
  void _showSwitchToWebTabHint(BuildContext context, String actionName) {
    Navigator.of(context).pop();
    BotToast.showText(
      text: 'i18n_article_请切换到网页标签页进行操作'.trParams({'actionName': actionName}),
      duration: const Duration(seconds: 3),
    );
  }

  /// 显示删除确认对话框
  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    if (_article == null) {
      BotToast.showText(text: 'i18n_article_文章信息加载中请稍后重试'.tr);
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
                'i18n_article_确认删除'.tr,
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
                'i18n_article_确定要删除这篇文章吗'.tr,
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
                'i18n_article_删除后的文章可以在回收站中找到'.tr,
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
              child: Text('i18n_article_取消'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ArticleService.instance.softDeleteArticle(widget.articleId);
                  getLogger().i('🗑️ 软删除文章111111: ${widget.articleId}');
                  BotToast.showText(text: 'i18n_article_文章已删除'.tr);
                  Navigator.of(context).pop(true);
                  context.pop(true);
                  // 返回到文章列表页面
                  // 确认对话框已经通过pop(true)关闭，这里只需要返回到文章列表
                  // Navigator.of(context).pop(); // 返回到文章列表页面
                } catch (e) {
                  BotToast.showText(text: '${'i18n_article_删除失败'.tr}$e');
                  getLogger().e('❌ 删除文章失败: $e');
                }

                // Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('i18n_article_删除'.tr),
            ),
          ],
        );
      },
    );

    // 如果用户确认删除
    // if (confirmed == true) {
    //   await _deleteArticle(context);
    // }
  }

  /// 执行删除操作
  Future<void> _deleteArticle(BuildContext context) async {
    try {
      await ArticleService.instance.softDeleteArticle(widget.articleId);
      
      if (mounted) {
        BotToast.showText(text: 'i18n_article_文章已删除'.tr);
        
        // 返回到文章列表页面
        // 确认对话框已经通过pop(true)关闭，这里只需要返回到文章列表
        Navigator.of(context).pop(); // 返回到文章列表页面
      }
    } catch (e) {
      BotToast.showText(text: '${'i18n_article_删除失败'.tr}$e');
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
      _ActionItem(
        icon: Icons.link, 
        label: 'i18n_article_复制链接'.tr, 
        onTap: () => _copyLink(context),
        isEnabled: hasUrl,
      ),
      _ActionItem(
        icon: Icons.refresh,
        label: 'i18n_article_刷新解析'.tr,
        onTap: () {
          if (!_isInWebTab()) {
            _showSwitchToWebTabHint(context, 'i18n_article_刷新解析'.tr);
            return;
          }
          
          if (widget.onReGenerateMarkdown != null) {
            Navigator.of(context).pop();
            widget.onReGenerateMarkdown!();
          } else {
            _showToast(context, 'i18n_article_刷新解析'.tr);
          }
        },
    ),
    _ActionItem(
        icon: Icons.camera_alt_outlined,
        label: 'i18n_article_重新生成快照'.tr,
        onTap: () {
          if (!_isInWebTab()) {
            _showSwitchToWebTabHint(context, 'i18n_article_重新生成快照'.tr);
            return;
          }
          
          if (widget.onReGenerateSnapshot != null) {
            Navigator.of(context).pop();
            widget.onReGenerateSnapshot!();
          } else {
            _showToast(context, 'i18n_article_重新生成快照'.tr);
          }
        }),


      _ActionItem(icon: Icons.g_translate, label: 'i18n_article_AI翻译'.tr, onTap: () => _showTranslateModal(context)),

      _ActionItem(icon: Icons.local_offer_outlined, label: 'i18n_article_标签'.tr, onTap: () => _showTagEditModal(context)),
      _ActionItem(icon: Icons.drive_file_move_outline, label: 'i18n_article_移动'.tr, onTap: () => _showMoveToCategoryModal(context)),
      _ActionItem(
         icon: isImportant ? Icons.star : Icons.star_border, 
         label: isImportant ? 'i18n_article_取消重要'.tr : 'i18n_article_标为重要'.tr, 
         onTap: () => _toggleImportantStatus(context)
       ),

      _ActionItem(icon: Icons.style, label: 'i18n_article_阅读主题'.tr, onTap: () => _showReadThemeWidgetModal(context)),

       _ActionItem(
         icon: isArchived ? Icons.unarchive : Icons.archive_outlined, 
         label: isArchived ? 'i18n_article_取消归档'.tr : 'i18n_article_归档'.tr, 
         onTap: () => _toggleArchiveStatus(context)
       ),
      _ActionItem(icon: Icons.delete_outline, label: 'i18n_article_删除'.tr, onTap: () => _showDeleteConfirmDialog(context), isDestructive: true),
    ];

    return Material(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
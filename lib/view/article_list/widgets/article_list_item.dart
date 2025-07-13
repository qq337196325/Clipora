import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../db/article/article_db.dart';
import '../../../route/route_name.dart';

class ArticleListItem extends StatefulWidget {
  final ArticleDb article;
  final VoidCallback? onTap;

  const ArticleListItem({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  State<ArticleListItem> createState() => _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnread = widget.article.isRead == 0;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            // color: isUnread
            //     ? colorScheme.surface
            //     : colorScheme.surface.withOpacity(0.7),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread 
                  ? colorScheme.primary.withOpacity(0.08)
                  : colorScheme.outline.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(isUnread ? 0.06 : 0.03),
                blurRadius: isUnread ? 16 : 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              if (isUnread)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap(context),
              onTapDown: (_) {
                setState(() => _isPressed = true);
                _animationController.forward();
              },
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _animationController.reverse();
              },
              onTapCancel: () {
                setState(() => _isPressed = false);
                _animationController.reverse();
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: colorScheme.primary.withOpacity(0.08),
              highlightColor: colorScheme.primary.withOpacity(0.05),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isUnread ? LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.02),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 现代化状态指示器
                    if (isUnread) ...[
                      Container(
                        width: 3,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(2, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    // 主要内容区域
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题行with重要标记
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.article.title.isNotEmpty
                                      ? widget.article.title
                                      : 'i18n_article_list_no_title'.tr,
                                  style: TextStyle(
                                    fontSize: isUnread ? 17 : 16,
                                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                    color: isUnread 
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurface.withOpacity(0.8),
                                    height: 1.3,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              
                              // 重要标记 - 现代化设计
                              if (widget.article.isImportant) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.error,
                                        Theme.of(context).colorScheme.error.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: Theme.of(context).colorScheme.onError,
                                  ),
                                ),
                              ],
                              
                              // 归档标记 - 现代化设计
                              if (widget.article.isArchived) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.archive_rounded,
                                    size: 12,
                                    color: Theme.of(context).colorScheme.onSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          // 摘要 - 改进可读性
                          if (widget.article.excerpt != null && widget.article.excerpt!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              widget.article.excerpt!,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.65),
                                height: 1.4,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          // 底部信息行 - 重新设计布局
                          Row(
                            children: [
                              // 现代化来源标签
                              if (widget.article.domain.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primaryContainer.withOpacity(0.8),
                                        colorScheme.primaryContainer.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    widget.article.domain,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimaryContainer,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              
                              // 时间信息 - 现代化图标
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatTime(widget.article.articleDate ?? widget.article.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // 阅读信息组合
                              Row(
                                children: [
                                  // 阅读次数
                                  if (widget.article.readCount > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.visibility_rounded,
                                            size: 10,
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${widget.article.readCount}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  
                                  // 现代化进度条
                                  if (widget.article.readProgress > 0) ...[
                                    Container(
                                      width: 40,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: widget.article.readProgress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    colorScheme.primary,
                                                    colorScheme.primary.withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(3),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: colorScheme.primary.withOpacity(0.3),
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 现代化箭头指示器
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _handleTap(BuildContext context) {
    return () {
      if (widget.onTap != null) {
        widget.onTap!();
      } else {
        // 默认跳转到文章详情页
        context.push('/${RouteName.articlePage}?id=${widget.article.id}');
      }
    };
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MM-dd').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'i18n_article_list_days_ago'
          .trParams({'days': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return 'i18n_article_list_hours_ago'
          .trParams({'hours': difference.inHours.toString()});
    } else if (difference.inMinutes > 0) {
      return 'i18n_article_list_minutes_ago'
          .trParams({'minutes': difference.inMinutes.toString()});
    } else {
      return 'i18n_article_list_just_now'.tr;
    }
  }
} 
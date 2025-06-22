import 'package:flutter/material.dart';
import 'dart:ui';

import 'more_actions_modal.dart';

class ArticleBottomBar extends StatelessWidget {
  final bool isVisible;
  final double bottomBarHeight;
  final VoidCallback onBack;
  final VoidCallback onGenerateSnapshot;
  final VoidCallback onDownloadSnapshot;
  final VoidCallback onReGenerateSnapshot;
  final int articleId;

  const ArticleBottomBar({
    super.key,
    required this.isVisible,
    required this.bottomBarHeight,
    required this.onBack,
    required this.onGenerateSnapshot,
    required this.onDownloadSnapshot,
    required this.onReGenerateSnapshot,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        offset: isVisible ? Offset.zero : const Offset(0, 2.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isVisible ? 1.0 : 0.0,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colorScheme.surface.withOpacity(0.95),
                        colorScheme.surfaceVariant.withOpacity(0.9),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.grey.shade50.withOpacity(0.9),
                      ],
              ),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.08),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧 - 返回按钮
                      _buildActionButton(
                        context,
                        icon: Icons.keyboard_arrow_left_rounded,
                        label: '返回',
                        isPrimary: true,
                        onPressed: onBack,
                      ),
                      
                      // 中间 - 操作按钮组
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFloatingButton(
                            context,
                            icon: Icons.bookmark_outline_rounded,
                            tooltip: '收藏',
                            onPressed: () {
                              // TODO: 实现收藏功能
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildFloatingButton(
                            context,
                            icon: Icons.share_rounded,
                            tooltip: '分享',
                            onPressed: () {
                              // TODO: 实现分享功能
                            },
                          ),
                        ],
                      ),
                      
                      // 右侧 - 更多操作
                      _buildActionButton(
                        context,
                        icon: Icons.tune_rounded,
                        label: '更多',
                        isPrimary: false,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            builder: (BuildContext context) {
                              return MoreActionsModal(
                                articleId: articleId,
                                onReGenerateSnapshot: onReGenerateSnapshot,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 主要操作按钮（带文字标签）
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        splashColor: isPrimary 
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.onSurface.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary 
                ? colorScheme.primaryContainer.withOpacity(0.8)
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(24),
            border: isPrimary 
                ? Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary 
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isPrimary 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 浮动圆形按钮
  Widget _buildFloatingButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          splashColor: colorScheme.primary.withOpacity(0.1),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
} 
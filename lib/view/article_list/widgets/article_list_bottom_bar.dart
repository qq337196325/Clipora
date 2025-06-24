import 'package:flutter/material.dart';
import 'dart:ui';

import '../models/sort_option.dart';
import 'sort_bottom_sheet.dart';

class ArticleListBottomBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onBack;
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const ArticleListBottomBar({
    super.key,
    required this.isVisible,
    required this.onBack,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      bottom: 12 + bottomPadding,
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
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
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
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.1)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      
                      // 右侧 - 排序按钮
                      _buildActionButton(
                        context,
                        icon: Icons.sort_rounded,
                        label: _getSortText(),
                        isPrimary: false,
                        onPressed: () => _showSortBottomSheet(context),
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

  String _getSortText() {
    String sortText;
    switch (currentSort.type) {
      case SortType.createTime:
        sortText = '创建时间';
        break;
      case SortType.modifyTime:
        sortText = '修改时间';
        break;
      case SortType.name:
        sortText = '名称';
        break;
    }
    return '$sortText${currentSort.isDescending ? '↓' : '↑'}';
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return SortBottomSheet(
          currentSort: currentSort,
          onSortChanged: (sortOption) {
            onSortChanged(sortOption);
            Navigator.of(context).pop();
          },
        );
      },
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
} 
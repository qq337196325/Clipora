// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../db/category/category_db.dart';
import '../utils/group_constants.dart';

/// 分类项组件
class CategoryItemWidget extends StatelessWidget {
  final CategoryDb category;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onExpandTap;
  final VoidCallback? onMoreTap;
  final Future<int> Function(int categoryId) getCategoryItemCount;

  const CategoryItemWidget({
    super.key,
    required this.category,
    required this.hasChildren,
    required this.isExpanded,
    required this.getCategoryItemCount,
    this.onTap,
    this.onExpandTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final double indentation = category.level * 20.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: GroupConstants.itemAnimationDuration,
      margin: GroupConstants.itemPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GroupConstants.itemRadius),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GroupConstants.itemRadius),
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.only(
              left: 4.0 + indentation,
              right: 6.0,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              children: [
                _buildExpandIcon(context),
                const SizedBox(width: 10),
                _buildCategoryIcon(context),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryContent(context),
                ),
                _buildMoreButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandIcon(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!hasChildren) {
      return const SizedBox(width: GroupConstants.expandIconSize);
    }

    return SizedBox(
      width: GroupConstants.expandIconSize,
      height: GroupConstants.expandIconSize,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GroupConstants.itemRadius),
          onTap: onExpandTap,
          child: AnimatedRotation(
            turns: isExpanded ? 0.25 : 0,
            duration: GroupConstants.itemAnimationDuration,
            child: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: GroupConstants.iconSize,
      height: GroupConstants.iconSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(GroupConstants.itemRadius),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          category.icon ?? '📁',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 根据分类级别显示不同的布局
        if (category.level == 0) ...[
          // 一级分类：保持原有样式
          Text(
            category.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ] else ...[
          // 二级分类：名称 + 数量标签
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FutureBuilder<int>(
                future: getCategoryItemCount(category.id),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        if (category.level == 0) ...[
          const SizedBox(height: 1),
          FutureBuilder<int>(
            future: getCategoryItemCount(category.id),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Text(
                '$count ${'i18n_group_个项目'.tr}',
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.0,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: GroupConstants.moreButtonSize,
      height: GroupConstants.moreButtonSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onMoreTap,
          child: Icon(
            Icons.more_horiz_rounded,
            color: theme.disabledColor,
            size: 18,
          ),
        ),
      ),
    );
  }
} 
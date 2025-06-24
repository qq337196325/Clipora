import 'package:flutter/material.dart';
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
          splashColor: GroupConstants.primaryGradientStart.withOpacity(0.1),
          highlightColor: GroupConstants.primaryGradientStart.withOpacity(0.05),
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
                _buildExpandIcon(),
                const SizedBox(width: 10),
                _buildCategoryIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryContent(),
                ),
                _buildMoreButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandIcon() {
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
            child: const Icon(
              Icons.chevron_right_rounded,
              color: GroupConstants.primaryGradientStart,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: GroupConstants.iconSize,
      height: GroupConstants.iconSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GroupConstants.primaryGradientStart.withOpacity(0.1),
            GroupConstants.primaryGradientEnd.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(GroupConstants.itemRadius),
        border: Border.all(
          color: GroupConstants.primaryGradientStart.withOpacity(0.2),
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

  Widget _buildCategoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 根据分类级别显示不同的布局
        if (category.level == 0) ...[
          // 一级分类：保持原有样式
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: GroupConstants.itemText,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: GroupConstants.itemText,
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
                      color: GroupConstants.primaryGradientStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GroupConstants.primaryGradientStart.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 11,
                        color: GroupConstants.primaryGradientStart,
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
                '$count 个项目',
                style: const TextStyle(
                  fontSize: 12,
                  color: GroupConstants.hintText,
                  height: 1.0,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMoreButton() {
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
          child: const Icon(
            Icons.more_horiz_rounded,
            color: GroupConstants.lightHint,
            size: 18,
          ),
        ),
      ),
    );
  }
} 
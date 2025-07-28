// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../db/category/category_db.dart';
import '../utils/group_constants.dart';

/// 分类操作底部面板组件
class CategoryActionSheet extends StatelessWidget {
  final CategoryDb category;
  final VoidCallback? onAddSubCategory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryActionSheet({
    super.key,
    required this.category,
    this.onAddSubCategory,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(GroupConstants.cardRadius),
          topRight: Radius.circular(GroupConstants.cardRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(context),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildCategoryHeader(context),
                const SizedBox(height: 24),
                if (category.level < 1)
                  _buildActionButton(
                    icon: Icons.add_circle_outline,
                    title: 'i18n_group_添加子分类'.tr,
                    subtitle: 'i18n_group_在此分类下创建子分类'.tr,
                    color: theme.colorScheme.primary,
        context:context,
                    onTap: () {
                      Navigator.pop(context);
                      onAddSubCategory?.call();
                    },
                  ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  title: 'i18n_group_重命名'.tr,
                  subtitle: 'i18n_group_修改分类名称和图标'.tr,
                  color: theme.colorScheme.tertiary,
                  context:context,
                  onTap: () {
                    Navigator.pop(context);
                    onEdit?.call();
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  title: 'i18n_group_删除'.tr,
                  subtitle: 'i18n_group_删除此分类'.tr,
                  color: theme.colorScheme.error,
                  isDestructive: true,
                  context:context,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              category.icon ?? '📁',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
                              Text(
                  category.level == 0 ? 'i18n_group_主分类'.tr : 'i18n_group_子分类'.tr,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDestructive 
                    ? color.withOpacity(0.2) 
                    : theme.dividerColor,
                width: 1,
              ),
              color: isDestructive 
                  ? color.withOpacity(0.05) 
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? color : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.disabledColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
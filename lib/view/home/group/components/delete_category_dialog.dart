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


/// 删除分类确认对话框
class DeleteCategoryDialog extends StatelessWidget {
  final CategoryDb category;
  final int articleCount;
  final VoidCallback onConfirm;

  const DeleteCategoryDialog({
    super.key,
    required this.category,
    required this.articleCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'i18n_group_删除分类'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
              children: [
                TextSpan(text: 'i18n_group_确定要删除分类'.tr),
                TextSpan(
                  text: '「${category.name}」',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                TextSpan(text: 'i18n_group_吗'.tr),
              ],
            ),
          ),
          if (articleCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'i18n_group_删除后目录下的文章将移到未分类'.trParams({'count': articleCount.toString()}),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.bodySmall?.color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'i18n_group_取消'.tr,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            'i18n_group_删除'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onError,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
} 
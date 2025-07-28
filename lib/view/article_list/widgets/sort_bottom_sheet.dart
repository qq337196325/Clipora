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
import 'dart:ui';
import 'package:get/get.dart';

import '../models/sort_option.dart';

class SortBottomSheet extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
                    boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -8),
                spreadRadius: 0,
              ),
            ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题栏
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 20, 24),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'i18n_article_list_sort_by'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // 排序选项列表
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: SortType.values.map((sortType) {
                  final isSelected = currentSort.type == sortType;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: _buildSortOption(
                      context,
                      sortType,
                      isSelected: isSelected,
                      isDescending: currentSort.isDescending,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    SortType sortType, {
    required bool isSelected,
    required bool isDescending,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleSortOptionTap(sortType),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected 
                ? Border.all(
                    color: colorScheme.primary.withOpacity(0.15),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // 图标容器
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  _getSortIcon(sortType),
                  size: 20,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimary
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 文字信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sortType.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected 
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (isSelected && sortType != SortType.name) ...[
                      const SizedBox(height: 3),
                      Text(
                        isDescending
                            ? 'i18n_article_list_latest_first'.tr
                            : 'i18n_article_list_oldest_first'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 右侧指示器
              if (isSelected) ...[
                if (sortType != SortType.name) ...[
                  // 排序方向指示器
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.15),
                          colorScheme.primary.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDescending 
                              ? Icons.keyboard_arrow_down_rounded 
                              : Icons.keyboard_arrow_up_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isDescending
                              ? 'i18n_article_list_descending'.tr
                              : 'i18n_article_list_ascending'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // 选中状态指示器
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ] else ...[
                // 未选中状态
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.onSurface.withOpacity(0.12),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSortIcon(SortType sortType) {
    switch (sortType) {
      case SortType.createTime:
        return Icons.schedule_rounded;
      case SortType.modifyTime:
        return Icons.update_rounded;
      case SortType.name:
        return Icons.sort_by_alpha_rounded;
    }
  }

  void _handleSortOptionTap(SortType newType) {
    if (currentSort.type == newType && newType != SortType.name) {
      // 如果点击的是当前选中的排序类型且不是按名称排序，则切换升降序
      final newSort = currentSort.copyWith(isDescending: !currentSort.isDescending);
      onSortChanged(newSort);
    } else {
      // 否则切换到新的排序类型
      final newSort = SortOption(
        type: newType,
        isDescending: newType == SortType.name ? true : true, // 默认都是降序
      );
      onSortChanged(newSort);
    }
  }
} 
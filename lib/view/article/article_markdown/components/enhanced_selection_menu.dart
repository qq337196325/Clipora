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
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';

/// 增强选择菜单动作类型
enum EnhancedSelectionAction {
  copy,       // 复制
  highlight,  // 高亮
  note,       // 笔记
}

/// 增强版选择菜单组件
/// 
/// 支持基于Range API的精确文本标注功能，采用iOS风格设计
class EnhancedSelectionMenu extends StatelessWidget {
  final Function(EnhancedSelectionAction) onAction;

  const EnhancedSelectionMenu({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Row( 
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.content_copy,
                  label: 'i18n_article_复制'.tr,
                  action: EnhancedSelectionAction.copy,
                ),
                _buildDivider(context),
                _buildActionButton(
                  context,
                  icon: Icons.format_paint, 
                  label: 'i18n_article_高亮'.tr,
                  action: EnhancedSelectionAction.highlight,
                  color: const Color(0xFFFF9F0A), // iOS Amber
                ),
                _buildDivider(context),
                _buildActionButton(
                  context,
                  icon: Icons.edit_note,
                  label: 'i18n_article_笔记'.tr,
                  action: EnhancedSelectionAction.note,
                  color: const Color(0xFF30D158), // iOS Green
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required EnhancedSelectionAction action,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : Colors.black87;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onAction(action);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: (color ?? defaultColor).withOpacity(0.15),
        highlightColor: (color ?? defaultColor).withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          constraints: const BoxConstraints(minWidth: 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? defaultColor,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color ?? defaultColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 1,
      height: 45,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08),
      ),
    );
  }
}
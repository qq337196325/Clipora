// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_controller.dart';

/// 主题选择器组件
class ThemeSelectorWidget {
  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const _ThemeSelectorModal();
      },
    );
  }
}

class _ThemeSelectorModal extends StatelessWidget {
  const _ThemeSelectorModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽条和标题
          _buildHeader(),
          
          // 主题选项列表
          const Expanded(
            child: _ThemeListView(),
          ),
          
          // 底部间距
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          children: [
            // 拖拽条
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'i18n_theme_选择主题'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeListView extends StatelessWidget {
  const _ThemeListView();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: themeController.supportedThemes.length,
      itemBuilder: (context, index) {
        final theme = themeController.supportedThemes[index];
        
        return Obx(() {
          final isSelected = themeController.currentTheme.value == theme.type;
          
          return _ThemeItemWidget(
            theme: theme,
            isSelected: isSelected,
            onTap: () => _selectTheme(context, themeController, theme.type),
          );
        });
      },
    );
  }

  void _selectTheme(BuildContext context, ThemeController controller, AppThemeType themeType) {
    controller.changeTheme(themeType);
    Navigator.of(context).pop();
    
    // 显示主题切换成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('i18n_theme_主题切换成功'.tr),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _ThemeItemWidget extends StatelessWidget {
  final ThemeModel theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeItemWidget({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isSelected 
          ? Border.all(color: Theme.of(context).primaryColor, width: 2)
          : Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 主题图标
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getThemeColor(theme.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    theme.icon,
                    size: 24,
                    color: _getThemeColor(theme.type),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 主题信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.name.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.description.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 选中状态指示器
                if (isSelected) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.reading:
        return const Color(0xFF005A9C);
      case AppThemeType.light:
        return const Color(0xFF1976D2);
      case AppThemeType.dark:
        return const Color(0xFF424242);
      case AppThemeType.nightReading:
        return const Color(0xFF4A90E2);
      case AppThemeType.ocean:
        return const Color(0xFF1976D2);
      case AppThemeType.forest:
        return const Color(0xFF2E7D32);
    }
  }
}
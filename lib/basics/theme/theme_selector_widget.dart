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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        children: [
          // 拖拽条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E7),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'i18n_theme_选择主题'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
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
        backgroundColor: const Color(0xFF667eea),
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
        color: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isSelected 
          ? Border.all(color: const Color(0xFF667eea), width: 2)
          : Border.all(color: const Color(0xFFF2F2F7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                          color: isSelected ? const Color(0xFF667eea) : const Color(0xFF1D1D1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.description.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF667eea),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
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
    }
  }
}
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
import 'package:bot_toast/bot_toast.dart';

import '../../../../basics/ui.dart';
import '../../controller/article_controller.dart';


// 阅读主题枚举
enum ReadingThemeType {
  defaultTheme,    // 默认主题
  lightTheme,      // 浅色主题
  darkTheme,       // 深色主题
  sepiaTheme,      // 护眼主题
  nightTheme,      // 夜间主题
  inkGreenTheme,   // 墨绿主题
  blueLightTheme,  // 蓝光护眼主题
  pureBlackTheme,  // 极简黑白主题
  paperTheme,      // 仿纸张主题
  pinkTheme,       // 少女粉主题
}

// 主题配置模型
class ThemeConfig {
  final ReadingThemeType type;
  final String name;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final Color cardColor;
  final Color dividerColor;
  final IconData icon;

  const ThemeConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.cardColor,
    required this.dividerColor,
    required this.icon,
  });
}

class ReadThemeWidget extends StatefulWidget {
  final int articleId;
  final double? minHeight; // 最小高度
  final double? maxHeightRatio; // 最大高度比例，相对于屏幕高度

  const ReadThemeWidget({
    super.key,
    required this.articleId,
    this.minHeight,
    this.maxHeightRatio,
  });

  @override
  State<ReadThemeWidget> createState() => _ReadThemeWidgetState();
}

class _ReadThemeWidgetState extends State<ReadThemeWidget> with ReadThemeWidgetBLoC {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部指示器
          Container(
            width: 40,
            height: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // 内容区域 - 使用Flexible而不是Expanded
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主题选择区域
                  _buildThemeSection(),

                  const SizedBox(height: 16),

                  // 样式调整区域
                  _buildStyleSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// 构建主题选择区域
  Widget _buildThemeSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主题选择标题
        Row(
          children: [
            const Icon(Icons.palette, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'i18n_article_阅读主题'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 主题选择网格 - 紧凑布局
        _buildCompactThemeGrid(),
        

      ],
    );
  }

  /// 构建紧凑的主题选择网格
  Widget _buildCompactThemeGrid() {
    return GetBuilder<ArticleController>(
      builder: (controller) => SizedBox(
        height: 80, // 进一步减少高度
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2), // 进一步减少内边距
          itemCount: themeConfigs.length,
          itemBuilder: (context, index) {
            final config = themeConfigs[index];
            final isSelected = controller.currentReadingTheme == config.type;
            
            return Container(
              width: 80, // 进一步减少宽度
              margin: const EdgeInsets.symmetric(horizontal: 4), // 进一步减少边距
              child: _buildCompactThemeCard(config, isSelected),
            );
          },
        ),
      ),
    );
  }

  /// 构建紧凑的主题卡片
  Widget _buildCompactThemeCard(ThemeConfig config, bool isSelected) {
    return GestureDetector(
      onTap: () {
        articleController.changeReadingTheme(config.type);
        BotToast.showText(text: '${config.name}已应用');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(8), // 进一步减小圆角
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? Colors.blue.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 4 : 2, // 进一步减小阴影
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4), // 进一步减少内边距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 主题图标
              Icon(
                config.icon,
                color: config.textColor,
                size: 16, // 进一步减小图标
              ),
              const SizedBox(height: 3), // 进一步减少间距
              
              // 主题名称
              Text(
                config.name,
                style: TextStyle(
                  color: config.textColor,
                  fontSize: 8, // 进一步减小字体
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建简洁的主题指示器
  Widget _buildSimpleThemeIndicator() {
    return GetBuilder<ArticleController>(
      builder: (controller) {
        final currentTheme = controller.currentReadingTheme;
        final selectedConfig = themeConfigs.firstWhere(
          (config) => config.type == currentTheme,
          orElse: () => themeConfigs.first,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(themeConfigs.length, (index) {
            final config = themeConfigs[index];
            final isSelected = config.type == currentTheme;
            
            return Container(
              width: 6, // 进一步减小指示器大小
              height: 6, // 进一步减小指示器大小
              margin: const EdgeInsets.symmetric(horizontal: 3), // 进一步减少边距
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue : Colors.grey[300],
              ),
            );
          }),
        );
      },
    );
  }





  /// 构建样式调整区域
  Widget _buildStyleSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 字体大小调整
          _buildStyleControl(
            title: 'i18n_article_字体大小'.tr,
            icon: Icons.text_fields,
            value: 0.0,
            min: kMinFontSize,
            max: kMaxFontSize,
            divisions: ((kMaxFontSize - kMinFontSize) / kFontSizeStep).round(),
            onChanged: (value) => articleController.adjustFontSize(value),
            valueText: '',
          ),
          
          const SizedBox(height: 4), // 添加间距
          
          // 边距调整
          _buildStyleControl(
            title: 'i18n_article_边距'.tr,
            icon: Icons.margin,
            value: 0.0,
            min: 0.0,
            max: 50.0,
            divisions: 8,
            onChanged: (value) => articleController.adjustMarginSize(value),
            valueText: '',
          ),

          const SizedBox(height: 4), // 添加间距
          
          // 行高调整
          _buildStyleControl(
            title: 'i18n_article_行高'.tr,
            icon: Icons.format_line_spacing,
            value: 0.0,
            min: 1.0,
            max: 2.5,
            divisions: 8,
            onChanged: (value) => articleController.adjustLineHeight(value),
            valueText: '',
          ),

          const SizedBox(height: 4), // 添加间距
          
          // 字距调整
          _buildStyleControl(
            title: 'i18n_article_字距'.tr,
            icon: Icons.text_fields,
            value: 0.0,
            min: -2.0,
            max: 5.0,
            divisions: 8,
            onChanged: (value) => articleController.adjustLetterSpacing(value),
            valueText: '',
          ),

          // const SizedBox(height: 8), // 添加间距
          //
          // // 段落间距调整
          // _buildStyleControl(
          //   title: 'i18n_article_段落间距'.tr,
          //   icon: Icons.vertical_align_bottom,
          //   value: 0.0,
          //   min: 8.0,
          //   max: 32.0,
          //   divisions: 6,
          //   onChanged: (value) => articleController.adjustParagraphSpacing(value),
          //   valueText: '',
          // ),
        ],
      ),
    );
  }

  /// 构建样式控制组件
  Widget _buildStyleControl({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueText,
  }) {
    return GetBuilder<ArticleController>(
      builder: (controller) {
        // 根据不同的样式类型获取当前值
        double currentValue;
        String currentValueText;
        
        if (title == 'i18n_article_字体大小'.tr) {
          currentValue = controller.fontSize;
          currentValueText = '${currentValue.toInt()}px';
        } else if (title == 'i18n_article_边距'.tr) {
          currentValue = controller.marginSize;
          currentValueText = '${currentValue.toInt()}px';
        } else if (title == 'i18n_article_行高'.tr) {
          currentValue = controller.lineHeight;
          currentValueText = currentValue.toStringAsFixed(1);
        } else if (title == 'i18n_article_字距'.tr) {
          currentValue = controller.letterSpacing;
          currentValueText = '${currentValue.toStringAsFixed(1)}px';
        } else if (title == 'i18n_article_段落间距'.tr) {
          currentValue = controller.paragraphSpacing;
          currentValueText = '${currentValue.toInt()}px';
        } else {
          currentValue = value;
          currentValueText = valueText;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和当前值 - 更紧凑的布局
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey), // 进一步减小图标
                const SizedBox(width: 4), // 进一步减少间距
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12, // 进一步减小字体
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // 进一步减少内边距
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(3), // 进一步减小圆角
                  ),
                  child: Text(
                    currentValueText,
                    style: TextStyle(
                      fontSize: 10, // 进一步减小字体
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 2), // 进一步减少间距
            
            // 滑块
            Slider(
              value: currentValue,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[300],
            ),
          ],
        );
      },
    );
  }

}

mixin ReadThemeWidgetBLoC on State<ReadThemeWidget> {
  // 文章控制器
  final ArticleController articleController = Get.find<ArticleController>();


  // 主题配置列表
  final List<ThemeConfig> themeConfigs = [
    const ThemeConfig(
      type: ReadingThemeType.defaultTheme,
      name: '默认主题',
      description: '经典白底黑字，清晰易读',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      cardColor: Color(0xFFF5F5F5),
      dividerColor: Color(0xFFE0E0E0),
      icon: Icons.article,
    ),
    const ThemeConfig(
      type: ReadingThemeType.lightTheme,
      name: '浅色主题',
      description: '柔和浅色背景，舒适阅读',
      backgroundColor: Color(0xFFFAFAFA),
      textColor: Color(0xFF424242),
      cardColor: Colors.white,
      dividerColor: Color(0xFFE8E8E8),
      icon: Icons.light_mode,
    ),
    const ThemeConfig(
      type: ReadingThemeType.darkTheme,
      name: '深色主题',
      description: '深色背景，减少眼睛疲劳',
      backgroundColor: Color(0xFF121212),
      textColor: Color(0xFFE0E0E0),
      cardColor: Color(0xFF1E1E1E),
      dividerColor: Color(0xFF424242),
      icon: Icons.dark_mode,
    ),
    const ThemeConfig(
      type: ReadingThemeType.sepiaTheme,
      name: '护眼主题',
      description: '米色背景，模拟纸张质感',
      backgroundColor: Color(0xFFF5F5DC),
      textColor: Color(0xFF3C3C3C),
      cardColor: Color(0xFFFFF8E1),
      dividerColor: Color(0xFFE8E6D9),
      icon: Icons.visibility,
    ),
    const ThemeConfig(
      type: ReadingThemeType.nightTheme,
      name: '夜间主题',
      description: '深蓝灰背景，夜间护眼',
      backgroundColor: Color(0xFF263238),
      textColor: Color(0xFFE5E5E7),
      cardColor: Color(0xFF2E3C43),
      dividerColor: Color(0xFF455A64),
      icon: Icons.nightlight_round,
    ),
    // 新增：墨绿主题
    const ThemeConfig(
      type: ReadingThemeType.inkGreenTheme,
      name: '墨绿主题',
      description: '深墨绿背景，米白色文字，护眼文艺',
      backgroundColor: Color(0xFF223322),
      textColor: Color(0xFFF5F5E0),
      cardColor: Color(0xFF2E4D2E),
      dividerColor: Color(0xFF3C5C3C),
      icon: Icons.eco,
    ),
    // 新增：蓝光护眼主题
    const ThemeConfig(
      type: ReadingThemeType.blueLightTheme,
      name: '蓝光护眼',
      description: '淡蓝灰背景，过滤蓝光，夜间舒适',
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF263238),
      cardColor: Color(0xFFBBDEFB),
      dividerColor: Color(0xFF90CAF9),
      icon: Icons.remove_red_eye,
    ),
    // 新增：极简黑白主题
    const ThemeConfig(
      type: ReadingThemeType.pureBlackTheme,
      name: '极简黑白',
      description: '极简纯黑纯白，专注阅读',
      backgroundColor: Colors.black,
      textColor: Colors.white,
      cardColor: Color(0xFF222222),
      dividerColor: Color(0xFF444444),
      icon: Icons.crop_square,
    ),
    // 新增：仿纸张主题
    const ThemeConfig(
      type: ReadingThemeType.paperTheme,
      name: '仿纸张',
      description: '淡黄纸张，深棕文字，模拟真实书本',
      backgroundColor: Color(0xFFFFFDE7),
      textColor: Color(0xFF5D4037),
      cardColor: Color(0xFFFFF8E1),
      dividerColor: Color(0xFFE8E6D9),
      icon: Icons.menu_book,
    ),
    // 新增：少女粉主题
    const ThemeConfig(
      type: ReadingThemeType.pinkTheme,
      name: '少女粉',
      description: '浅粉色背景，温馨可爱',
      backgroundColor: Color(0xFFFFEBEE),
      textColor: Color(0xFFAD1457),
      cardColor: Color(0xFFF8BBD0),
      dividerColor: Color(0xFFF48FB1),
      icon: Icons.favorite,
    ),
  ];
}

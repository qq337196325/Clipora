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

/// 护眼主题 - 专为阅读优化，提供舒适护眼体验
class ReadingTheme {
  // ==================== 颜色定义 ====================
  
  // 主色调 - 深青色系，专业护眼
  static const Color brownPrimary = Color(0xFF2E7D8A);
  static const Color brownPrimaryLight = Color(0xFF4A9BA8);
  static const Color brownPrimaryDark = Color(0xFF1B5E6B);

  
  // 绿色系护眼色
  static const Color greenPrimary = Color(0xFF81C784);
  static const Color greenPrimaryLight = Color(0xFFA5D6A7);
  
  // 错误色
  static const Color error = Color(0xFFF44336);
  
  // 背景色系 - 护眼配色
  static const Color readingBackground = Color(0xFFF5F5DC);
  static const Color readingSurface = Color(0xFFFFF8E1);
  static const Color readingCard = Color(0xFFFFFEF7);
  static const Color readingDivider = Color(0xFFE8E6D9);
  
  // 文本色系 - 护眼配色
  static const Color readingTextPrimary = Color(0xFF3C3C3C);
  static const Color readingTextSecondary = Color(0xFF5D5D5D);
  static const Color readingTextHint = Color(0xFF9E9E9E);
  static const Color readingTextDisabled = Color(0xFFD0D0D0);
  
  // 交互状态色系
  static const Color readingHover = Color(0xFFF0F0E8);
  static const Color readingPressed = Color(0xFFE8E6D9);
  static const Color readingSelected = Color(0xFFE8F5E8);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调 - 使用深青色系，专业护眼
    primaryColor: brownPrimary,
    
    // 应用整体背景色 - 米色护眼
    scaffoldBackgroundColor: readingBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: Color(0xFFFAFAEA),
    
    // 表面颜色
    colorScheme:  ColorScheme.light(
      primary: brownPrimary,
      primaryContainer: brownPrimaryLight,
      primaryFixed: brownPrimaryDark,
      secondary: greenPrimary,
      secondaryContainer: greenPrimaryLight,
      surface: readingSurface,
      background: readingBackground,
      error: error,
      onPrimary: readingTextDisabled,
      onSecondary: Colors.black,
      onSurface: readingTextPrimary,
      onBackground: readingTextPrimary,
      onError: Colors.white,
      outline: readingDivider,
      outlineVariant: readingDivider,
    ),

    // 文本主题 - 护眼配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: readingTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: readingTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: readingTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: readingTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: readingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: readingTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: readingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: readingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: readingTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: readingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: readingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: readingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: readingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: readingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: readingTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 与背景色统一
    appBarTheme: const AppBarTheme(
      backgroundColor: readingBackground,
      elevation: 0, // 去掉阴影，更扁平
      shadowColor: readingDivider,
      iconTheme: IconThemeData(
        color: brownPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: readingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: brownPrimary,
      size: 24,
    ),

    // 卡片主题 - 纸张质感
    cardTheme: CardTheme(
      color: readingCard,
      elevation: 0, // 无阴影，更接近纸张
      shadowColor: readingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: readingDivider,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 护眼配色
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brownPrimary,
        foregroundColor: Colors.white,
        elevation: 1, // 轻微阴影
        shadowColor: readingDivider,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // 文本按钮主题
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brownPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: readingDivider,
      thickness: 0.5, // 更细的分割线
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: readingBackground,
      selectedItemColor: brownPrimary,
      unselectedItemColor: readingTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // 无阴影
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: brownPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: brownPrimary,
      linearTrackColor: readingDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return brownPrimary;
        }
        return readingTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return brownPrimaryLight;
        }
        return readingDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return brownPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: readingDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return brownPrimary;
        }
        return readingTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: brownPrimary,
      inactiveTrackColor: readingDivider,
      thumbColor: brownPrimary,
      overlayColor: brownPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: brownPrimary,
      unselectedLabelColor: readingTextSecondary,
      indicatorColor: brownPrimary,
      dividerColor: readingDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: readingCard,
      elevation: 2,
      shadowColor: readingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: const TextStyle(
        color: readingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: readingTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: readingCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: readingCard,
      elevation: 2,
      shadowColor: readingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: readingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: readingTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: readingBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: readingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: readingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 0.5,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: readingTextPrimary,
      iconColor: brownPrimary,
      tileColor: Colors.transparent,
      selectedTileColor: readingSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: readingSurface,
      selectedColor: brownPrimary,
      disabledColor: readingTextDisabled,
      labelStyle: TextStyle(color: readingTextPrimary),
      secondaryLabelStyle: TextStyle(color: readingTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: readingTextPrimary,
      iconColor: brownPrimary,
      collapsedTextColor: readingTextSecondary,
      collapsedIconColor: readingTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: readingCard,
      hourMinuteTextColor: readingTextPrimary,
      hourMinuteColor: readingSurface,
      dayPeriodTextColor: readingTextPrimary,
      dayPeriodColor: readingSurface,
      dialHandColor: brownPrimary,
      dialBackgroundColor: readingSurface,
      dialTextColor: readingTextPrimary,
      entryModeIconColor: brownPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: readingCard,
      headerBackgroundColor: brownPrimary,
      headerForegroundColor: Colors.white,
    ),
  );
}
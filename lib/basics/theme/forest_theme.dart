// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 森林主题 - 自然宁静的绿色系配色，适合阅读
class ForestTheme {
  // ==================== 颜色定义 ====================
  
  // 主色调 - 森林绿色系
  static const Color forestPrimary = Color(0xFF2E7D32);
  static const Color forestPrimaryLight = Color(0xFF4CAF50);
  static const Color forestPrimaryDark = Color(0xFF1B5E20);
  
  // 森林棕色系
  static const Color forestBrown = Color(0xFF8D6E63);
  static const Color forestBrownLight = Color(0xFFA1887F);
  
  // 错误色
  static const Color error = Color(0xFFD32F2F);
  
  // 背景色系 - 森林配色
  static const Color forestBackground = Color(0xFFF1F8E9);
  static const Color forestSurface = Color(0xFFE8F5E8);
  static const Color forestCard = Color(0xFFF9FBE7);
  static const Color forestDivider = Color(0xFFC8E6C9);
  
  // 文本色系 - 森林配色
  static const Color forestTextPrimary = Color(0xFF1B5E20);
  static const Color forestTextSecondary = Color(0xFF388E3C);
  static const Color forestTextHint = Color(0xFF66BB6A);
  static const Color forestTextDisabled = Color(0xFFA5D6A7);
  
  // 交互状态色系
  static const Color forestHover = Color(0xFFE8F5E8);
  static const Color forestPressed = Color(0xFFC8E6C9);
  static const Color forestSelected = Color(0xFFDCEDC8);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调 - 使用森林绿色系
    primaryColor: forestPrimary,
    
    // 应用整体背景色 - 森林配色
    scaffoldBackgroundColor: forestBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: forestCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.light(
      primary: forestPrimary,
      primaryContainer: forestPrimaryLight,
      primaryFixed: forestPrimaryDark,
      secondary: forestBrown,
      secondaryContainer: forestBrownLight,
      surface: forestSurface,
      background: forestBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: forestTextPrimary,
      onBackground: forestTextPrimary,
      onError: Colors.white,
      outline: forestDivider,
      outlineVariant: forestDivider,
    ),

    // 文本主题 - 森林配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: forestTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: forestTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: forestTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: forestTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: forestTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: forestTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: forestTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: forestTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: forestTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: forestTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: forestTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: forestTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: forestTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: forestTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: forestTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 森林风格
    appBarTheme: const AppBarTheme(
      backgroundColor: forestBackground,
      elevation: 0,
      shadowColor: forestDivider,
      iconTheme: IconThemeData(
        color: forestPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: forestTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: forestPrimary,
      size: 24,
    ),

    // 卡片主题 - 森林质感
    cardTheme: CardTheme(
      color: forestCard,
      elevation: 1,
      shadowColor: forestDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: forestDivider,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 森林配色
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: forestPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: forestDivider,
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
        foregroundColor: forestPrimary,
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
      color: forestDivider,
      thickness: 0.5,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: forestBackground,
      selectedItemColor: forestPrimary,
      unselectedItemColor: forestTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: forestPrimary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: forestPrimary,
      linearTrackColor: forestDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return forestPrimary;
        }
        return forestTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return forestPrimaryLight;
        }
        return forestDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return forestPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: forestDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return forestPrimary;
        }
        return forestTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: forestPrimary,
      inactiveTrackColor: forestDivider,
      thumbColor: forestPrimary,
      overlayColor: forestPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: forestPrimary,
      unselectedLabelColor: forestTextSecondary,
      indicatorColor: forestPrimary,
      dividerColor: forestDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: forestCard,
      elevation: 3,
      shadowColor: forestDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: forestTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: forestTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: forestCard,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: forestCard,
      elevation: 3,
      shadowColor: forestDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: forestTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: forestTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: forestBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: forestTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: forestTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 0.5,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: forestTextPrimary,
      iconColor: forestPrimary,
      tileColor: Colors.transparent,
      selectedTileColor: forestSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: forestSurface,
      selectedColor: forestPrimary,
      disabledColor: forestTextDisabled,
      labelStyle: TextStyle(color: forestTextPrimary),
      secondaryLabelStyle: TextStyle(color: forestTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: forestTextPrimary,
      iconColor: forestPrimary,
      collapsedTextColor: forestTextSecondary,
      collapsedIconColor: forestTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: forestCard,
      hourMinuteTextColor: forestTextPrimary,
      hourMinuteColor: forestSurface,
      dayPeriodTextColor: forestTextPrimary,
      dayPeriodColor: forestSurface,
      dialHandColor: forestPrimary,
      dialBackgroundColor: forestSurface,
      dialTextColor: forestTextPrimary,
      entryModeIconColor: forestPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: forestCard,
      headerBackgroundColor: forestPrimary,
      headerForegroundColor: Colors.white,
    ),
  );
} 
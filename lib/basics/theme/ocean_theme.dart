// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 海洋主题 - 清新宁静的蓝色系配色，适合阅读
class OceanTheme {
  // ==================== 颜色定义 ====================
  
  // 主色调 - 海洋蓝色系
  static const Color oceanPrimary = Color(0xFF1976D2);
  static const Color oceanPrimaryLight = Color(0xFF42A5F5);
  static const Color oceanPrimaryDark = Color(0xFF0D47A1);
  
  // 海洋绿色系
  static const Color oceanGreen = Color(0xFF26A69A);
  static const Color oceanGreenLight = Color(0xFF4DB6AC);
  
  // 错误色
  static const Color error = Color(0xFFEF5350);
  
  // 背景色系 - 海洋配色
  static const Color oceanBackground = Color(0xFFF0F8FF);
  static const Color oceanSurface = Color(0xFFE3F2FD);
  static const Color oceanCard = Color(0xFFFAFCFF);
  static const Color oceanDivider = Color(0xFFBBDEFB);
  
  // 文本色系 - 海洋配色
  static const Color oceanTextPrimary = Color(0xFF1A237E);
  static const Color oceanTextSecondary = Color(0xFF3949AB);
  static const Color oceanTextHint = Color(0xFF7986CB);
  static const Color oceanTextDisabled = Color(0xFFC5CAE9);
  
  // 交互状态色系
  static const Color oceanHover = Color(0xFFE8F4FD);
  static const Color oceanPressed = Color(0xFFD0E7FD);
  static const Color oceanSelected = Color(0xFFE1F5FE);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调 - 使用海洋蓝色系
    primaryColor: oceanPrimary,
    
    // 应用整体背景色 - 海洋配色
    scaffoldBackgroundColor: oceanBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: oceanCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.light(
      primary: oceanPrimary,
      primaryContainer: oceanPrimaryLight,
      primaryFixed: oceanPrimaryDark,
      secondary: oceanGreen,
      secondaryContainer: oceanGreenLight,
      surface: oceanSurface,
      background: oceanBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: oceanTextPrimary,
      onBackground: oceanTextPrimary,
      onError: Colors.white,
      outline: oceanDivider,
      outlineVariant: oceanDivider,
    ),

    // 文本主题 - 海洋配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: oceanTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: oceanTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: oceanTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: oceanTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: oceanTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: oceanTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: oceanTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: oceanTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: oceanTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: oceanTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: oceanTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: oceanTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: oceanTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: oceanTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: oceanTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 海洋风格
    appBarTheme: const AppBarTheme(
      backgroundColor: oceanBackground,
      elevation: 0,
      shadowColor: oceanDivider,
      iconTheme: IconThemeData(
        color: oceanPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: oceanTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: oceanPrimary,
      size: 24,
    ),

    // 卡片主题 - 海洋质感
    cardTheme: CardTheme(
      color: oceanCard,
      elevation: 1,
      shadowColor: oceanDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: oceanDivider,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 海洋配色
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: oceanPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: oceanDivider,
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
        foregroundColor: oceanPrimary,
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
      color: oceanDivider,
      thickness: 0.5,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: oceanBackground,
      selectedItemColor: oceanPrimary,
      unselectedItemColor: oceanTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: oceanPrimary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: oceanPrimary,
      linearTrackColor: oceanDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return oceanPrimary;
        }
        return oceanTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return oceanPrimaryLight;
        }
        return oceanDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return oceanPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: oceanDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return oceanPrimary;
        }
        return oceanTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: oceanPrimary,
      inactiveTrackColor: oceanDivider,
      thumbColor: oceanPrimary,
      overlayColor: oceanPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: oceanPrimary,
      unselectedLabelColor: oceanTextSecondary,
      indicatorColor: oceanPrimary,
      dividerColor: oceanDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: oceanCard,
      elevation: 3,
      shadowColor: oceanDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: oceanTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: oceanTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: oceanCard,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: oceanCard,
      elevation: 3,
      shadowColor: oceanDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: oceanTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: oceanTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: oceanBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: oceanTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: oceanTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 0.5,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: oceanTextPrimary,
      iconColor: oceanPrimary,
      tileColor: Colors.transparent,
      selectedTileColor: oceanSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: oceanSurface,
      selectedColor: oceanPrimary,
      disabledColor: oceanTextDisabled,
      labelStyle: TextStyle(color: oceanTextPrimary),
      secondaryLabelStyle: TextStyle(color: oceanTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: oceanTextPrimary,
      iconColor: oceanPrimary,
      collapsedTextColor: oceanTextSecondary,
      collapsedIconColor: oceanTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: oceanCard,
      hourMinuteTextColor: oceanTextPrimary,
      hourMinuteColor: oceanSurface,
      dayPeriodTextColor: oceanTextPrimary,
      dayPeriodColor: oceanSurface,
      dialHandColor: oceanPrimary,
      dialBackgroundColor: oceanSurface,
      dialTextColor: oceanTextPrimary,
      entryModeIconColor: oceanPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: oceanCard,
      headerBackgroundColor: oceanPrimary,
      headerForegroundColor: Colors.white,
    ),
  );
} 
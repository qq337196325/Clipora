// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 深色主题 - 现代深色设计，减少眼睛疲劳
class DarkTheme {
  // ==================== 颜色定义 ====================
  
  // 主色调 - 蓝色系
  static const Color bluePrimary = Color(0xFF42A5F5);
  static const Color bluePrimaryLight = Color(0xFF64B5F6);
  static const Color bluePrimaryDark = Color(0xFF1976D2);
  
  // 信息色
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  
  // 错误色
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  
  // 背景色系
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF212121);
  static const Color darkDivider = Color(0xFF424242);
  
  // 文本色系
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextHint = Color(0xFF757575);
  static const Color darkTextDisabled = Color(0xFF424242);
  
  // 交互状态色系
  static const Color darkHover = Color(0xFF2A2A2A);
  static const Color darkPressed = Color(0xFF1A1A1A);
  static const Color darkSelected = Color(0xFF1E3A5F);
  
  // 阴影色系
  static const Color darkShadow = Color(0x1AFFFFFF);
  static const Color darkShadowStrong = Color(0x33FFFFFF);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调 - 使用蓝色系
    primaryColor: bluePrimaryLight,
    
    // 应用整体背景色 - 使用更柔和的深色
    scaffoldBackgroundColor: darkBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: darkCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.dark(
      primary: bluePrimaryLight,
      primaryContainer: bluePrimary,
      primaryFixed: bluePrimaryDark,
      secondary: infoLight,
      secondaryContainer: info,
      surface: darkSurface,
      background: darkBackground,
      error: errorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
      onError: Colors.black,
      outline: darkDivider,
      outlineVariant: darkDivider,
    ),

    // 文本主题 - 增强对比度
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: darkTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: darkTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 增加层次感
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0, // 扁平化设计
      shadowColor: darkShadow,
      iconTheme: IconThemeData(
        color: darkTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: darkTextSecondary,
      size: 24,
    ),

    // 卡片主题 - 增加微妙的阴影
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 2,
      shadowColor: darkShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 增强交互反馈
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bluePrimaryLight,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: darkShadowStrong,
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
        foregroundColor: bluePrimaryLight,
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
      color: darkDivider,
      thickness: 1,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: bluePrimaryLight,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: bluePrimaryLight,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: bluePrimaryLight,
      linearTrackColor: darkDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimaryLight;
        }
        return darkTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimary;
        }
        return darkDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: darkDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimaryLight;
        }
        return darkTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: bluePrimaryLight,
      inactiveTrackColor: darkDivider,
      thumbColor: bluePrimaryLight,
      overlayColor: bluePrimary,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: bluePrimaryLight,
      unselectedLabelColor: darkTextSecondary,
      indicatorColor: bluePrimaryLight,
      dividerColor: darkDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: darkCard,
      elevation: 8,
      shadowColor: darkShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: darkTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: darkCard,
      elevation: 8,
      shadowColor: darkShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: darkTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: darkBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 1,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: darkTextPrimary,
      iconColor: darkTextSecondary,
      tileColor: Colors.transparent,
      selectedTileColor: darkSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: darkSurface,
      selectedColor: bluePrimaryLight,
      disabledColor: darkTextDisabled,
      labelStyle: TextStyle(color: darkTextPrimary),
      secondaryLabelStyle: TextStyle(color: darkTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: darkTextPrimary,
      iconColor: darkTextSecondary,
      collapsedTextColor: darkTextSecondary,
      collapsedIconColor: darkTextSecondary,
    ),
  );
}
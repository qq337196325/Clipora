import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 纯白主题 - 简洁明亮的现代设计
class LightTheme {
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
  
  // 背景色系
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightCard = Colors.white;
  static const Color lightDivider = Color(0xFFE0E0E0);
  
  // 文本色系
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextHint = Color(0xFFBDBDBD);
  static const Color lightTextDisabled = Color(0xFFE0E0E0);
  
  // 阴影色系
  static const Color lightShadow = Color(0x1A000000);
  static const Color lightShadowStrong = Color(0x33000000);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调 - 使用蓝色系
    primaryColor: bluePrimary,
    
    // 应用整体背景色
    scaffoldBackgroundColor: lightBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: lightCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.light(
      primary: bluePrimary,
      primaryContainer: bluePrimaryLight,
      secondary: info,
      secondaryContainer: infoLight,
      surface: lightSurface,
      background: lightBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
      onError: Colors.white,
      outline: lightDivider,
      outlineVariant: lightDivider,
    ),

    // 文本主题 - 增强对比度
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: lightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: lightTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: lightTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 增加层次感
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0, // 扁平化设计
      shadowColor: lightShadow,
      iconTheme: IconThemeData(
        color: lightTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: lightTextSecondary,
      size: 24,
    ),

    // 卡片主题 - 增加微妙的阴影
    cardTheme: CardTheme(
      color: lightCard,
      elevation: 1,
      shadowColor: lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 增强交互反馈
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bluePrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: lightShadowStrong,
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
        foregroundColor: bluePrimary,
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
      color: lightDivider,
      thickness: 1,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBackground,
      selectedItemColor: bluePrimary,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: bluePrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: bluePrimary,
      linearTrackColor: lightDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimary;
        }
        return lightTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimaryLight;
        }
        return lightDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: lightDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return bluePrimary;
        }
        return lightTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: bluePrimary,
      inactiveTrackColor: lightDivider,
      thumbColor: bluePrimary,
      overlayColor: bluePrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: bluePrimary,
      unselectedLabelColor: lightTextSecondary,
      indicatorColor: bluePrimary,
      dividerColor: lightDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: lightCard,
      elevation: 8,
      shadowColor: lightShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: lightTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: lightCard,
      elevation: 8,
      shadowColor: lightShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: lightTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: lightBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 1,
      columnSpacing: 16,
    ),
  );
}
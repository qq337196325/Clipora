import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// 纯白主题 - 简洁明亮的现代设计
class LightTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调 - 使用蓝色系
    primaryColor: AppColors.bluePrimary,
    
    // 应用整体背景色
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: AppColors.lightCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.light(
      primary: AppColors.bluePrimary,
      primaryContainer: AppColors.bluePrimaryLight,
      secondary: AppColors.info,
      secondaryContainer: AppColors.infoLight,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onBackground: AppColors.lightTextPrimary,
      onError: Colors.white,
      outline: AppColors.lightDivider,
      outlineVariant: AppColors.lightDivider,
    ),

    // 文本主题 - 增强对比度
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.lightTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 增加层次感
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0, // 扁平化设计
      shadowColor: AppColors.lightShadow,
      iconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: AppColors.lightTextSecondary,
      size: 24,
    ),

    // 卡片主题 - 增加微妙的阴影
    cardTheme: CardTheme(
      color: AppColors.lightCard,
      elevation: 1,
      shadowColor: AppColors.lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 增强交互反馈
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.lightShadowStrong,
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
        foregroundColor: AppColors.bluePrimary,
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

    // 输入框主题
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: AppColors.lightSurface,
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.lightDivider),
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.lightDivider),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2),
    //   ),
    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.error),
    //   ),
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //   labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
    //   hintStyle: const TextStyle(color: AppColors.lightTextHint),
    // ),

    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.bluePrimary,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.bluePrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.bluePrimary,
      linearTrackColor: AppColors.lightDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimary;
        }
        return AppColors.lightTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimaryLight;
        }
        return AppColors.lightDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.lightDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimary;
        }
        return AppColors.lightTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.bluePrimary,
      inactiveTrackColor: AppColors.lightDivider,
      thumbColor: AppColors.bluePrimary,
      overlayColor: AppColors.bluePrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.bluePrimary,
      unselectedLabelColor: AppColors.lightTextSecondary,
      indicatorColor: AppColors.bluePrimary,
      dividerColor: AppColors.lightDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.lightCard,
      elevation: 8,
      shadowColor: AppColors.lightShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.lightCard,
      elevation: 8,
      shadowColor: AppColors.lightShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.darkTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: AppColors.darkBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 1,
      columnSpacing: 16,
    ),
  );
}
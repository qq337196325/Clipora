import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// 深色主题 - 现代深色设计，减少眼睛疲劳
class DarkTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调 - 使用蓝色系
    primaryColor: AppColors.bluePrimaryLight,
    
    // 应用整体背景色 - 使用更柔和的深色
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: AppColors.darkCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.dark(
      primary: AppColors.bluePrimaryLight,
      primaryContainer: AppColors.bluePrimary,
      secondary: AppColors.infoLight,
      secondaryContainer: AppColors.info,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.errorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: Colors.black,
      outline: AppColors.darkDivider,
      outlineVariant: AppColors.darkDivider,
    ),

    // 文本主题 - 增强对比度
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.darkTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 增加层次感
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0, // 扁平化设计
      shadowColor: AppColors.darkShadow,
      iconTheme: IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: AppColors.darkTextSecondary,
      size: 24,
    ),

    // 卡片主题 - 增加微妙的阴影
    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 增强交互反馈
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.bluePrimaryLight,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: AppColors.darkShadowStrong,
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
        foregroundColor: AppColors.bluePrimaryLight,
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

    // // 输入框主题
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: AppColors.darkSurface,
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.darkDivider),
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.darkDivider),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.bluePrimaryLight, width: 2),
    //   ),
    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.errorLight),
    //   ),
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //   labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
    //   hintStyle: const TextStyle(color: AppColors.darkTextHint),
    // ),

    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.bluePrimaryLight,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.bluePrimaryLight,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.bluePrimaryLight,
      linearTrackColor: AppColors.darkDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimaryLight;
        }
        return AppColors.darkTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimary;
        }
        return AppColors.darkDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.darkDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.bluePrimaryLight;
        }
        return AppColors.darkTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.bluePrimaryLight,
      inactiveTrackColor: AppColors.darkDivider,
      thumbColor: AppColors.bluePrimaryLight,
      overlayColor: AppColors.bluePrimary,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.bluePrimaryLight,
      unselectedLabelColor: AppColors.darkTextSecondary,
      indicatorColor: AppColors.bluePrimaryLight,
      dividerColor: AppColors.darkDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.darkCard,
      elevation: 8,
      shadowColor: AppColors.darkShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.darkCard,
      elevation: 8,
      shadowColor: AppColors.darkShadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.lightTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: AppColors.lightBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 1,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.darkTextPrimary,
      iconColor: AppColors.darkTextSecondary,
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.darkSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.bluePrimaryLight,
      disabledColor: AppColors.darkTextDisabled,
      labelStyle: TextStyle(color: AppColors.darkTextPrimary),
      secondaryLabelStyle: TextStyle(color: AppColors.darkTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: AppColors.darkTextPrimary,
      iconColor: AppColors.darkTextSecondary,
      collapsedTextColor: AppColors.darkTextSecondary,
      collapsedIconColor: AppColors.darkTextSecondary,
    ),
  );
}
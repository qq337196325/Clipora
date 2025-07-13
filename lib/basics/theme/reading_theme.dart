import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// 护眼主题 - 专为阅读优化，提供舒适护眼体验
class ReadingTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调 - 使用棕色系，更接近纸张
    primaryColor: AppColors.brownPrimary,
    
    // 应用整体背景色 - 米色护眼
    scaffoldBackgroundColor: AppColors.readingBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: AppColors.readingCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.light(
      primary: AppColors.brownPrimary,
      primaryContainer: AppColors.brownPrimaryLight,
      secondary: AppColors.greenPrimary,
      secondaryContainer: AppColors.greenPrimaryLight,
      surface: AppColors.readingSurface,
      background: AppColors.readingBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.readingTextPrimary,
      onBackground: AppColors.readingTextPrimary,
      onError: Colors.white,
      outline: AppColors.readingDivider,
      outlineVariant: AppColors.readingDivider,
    ),

    // 文本主题 - 护眼配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: AppColors.readingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.readingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: AppColors.readingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.readingTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 与背景色统一
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.readingBackground,
      elevation: 0, // 去掉阴影，更扁平
      shadowColor: AppColors.readingDivider,
      iconTheme: IconThemeData(
        color: AppColors.brownPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: AppColors.brownPrimary,
      size: 24,
    ),

    // 卡片主题 - 纸张质感
    cardTheme: CardTheme(
      color: AppColors.readingCard,
      elevation: 0, // 无阴影，更接近纸张
      shadowColor: AppColors.readingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AppColors.readingDivider,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 护眼配色
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownPrimary,
        foregroundColor: Colors.white,
        elevation: 1, // 轻微阴影
        shadowColor: AppColors.readingDivider,
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
        foregroundColor: AppColors.brownPrimary,
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

    // // 输入框主题 - 护眼设计
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: AppColors.readingSurface,
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.readingDivider),
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.readingDivider),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.brownPrimary, width: 1.5),
    //   ),
    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.error),
    //   ),
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //   labelStyle: const TextStyle(color: AppColors.readingTextSecondary),
    //   hintStyle: const TextStyle(color: AppColors.readingTextHint),
    // ),

    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: AppColors.readingDivider,
      thickness: 0.5, // 更细的分割线
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.readingBackground,
      selectedItemColor: AppColors.brownPrimary,
      unselectedItemColor: AppColors.readingTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // 无阴影
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brownPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brownPrimary,
      linearTrackColor: AppColors.readingDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.brownPrimary;
        }
        return AppColors.readingTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.brownPrimaryLight;
        }
        return AppColors.readingDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.brownPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.readingDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.brownPrimary;
        }
        return AppColors.readingTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.brownPrimary,
      inactiveTrackColor: AppColors.readingDivider,
      thumbColor: AppColors.brownPrimary,
      overlayColor: AppColors.brownPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.brownPrimary,
      unselectedLabelColor: AppColors.readingTextSecondary,
      indicatorColor: AppColors.brownPrimary,
      dividerColor: AppColors.readingDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.readingCard,
      elevation: 2,
      shadowColor: AppColors.readingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.readingTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.readingCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.readingCard,
      elevation: 2,
      shadowColor: AppColors.readingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.readingTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: AppColors.readingBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: AppColors.readingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: AppColors.readingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 0.5,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.readingTextPrimary,
      iconColor: AppColors.brownPrimary,
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.readingSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.readingSurface,
      selectedColor: AppColors.brownPrimary,
      disabledColor: AppColors.readingTextDisabled,
      labelStyle: TextStyle(color: AppColors.readingTextPrimary),
      secondaryLabelStyle: TextStyle(color: AppColors.readingTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: AppColors.readingTextPrimary,
      iconColor: AppColors.brownPrimary,
      collapsedTextColor: AppColors.readingTextSecondary,
      collapsedIconColor: AppColors.readingTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.readingCard,
      hourMinuteTextColor: AppColors.readingTextPrimary,
      hourMinuteColor: AppColors.readingSurface,
      dayPeriodTextColor: AppColors.readingTextPrimary,
      dayPeriodColor: AppColors.readingSurface,
      dialHandColor: AppColors.brownPrimary,
      dialBackgroundColor: AppColors.readingSurface,
      dialTextColor: AppColors.readingTextPrimary,
      entryModeIconColor: AppColors.brownPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.readingCard,
      headerBackgroundColor: AppColors.brownPrimary,
      headerForegroundColor: Colors.white,
      // dayForegroundColor: AppColors.readingTextPrimary,
      // dayBackgroundColor: AppColors.readingSurface,
      // todayForegroundColor: AppColors.brownPrimary,
      // todayBackgroundColor: AppColors.readingSelected,
      // yearForegroundColor: AppColors.readingTextPrimary,
      // yearBackgroundColor: AppColors.readingSurface,
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// 护眼夜间主题 - 深色护眼阅读模式，减少蓝光伤害
class NightReadingTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调 - 使用绿色系，更护眼
    primaryColor: AppColors.greenPrimary,
    
    // 应用整体背景色 - 深蓝灰色，更舒适
    scaffoldBackgroundColor: AppColors.nightReadingBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: AppColors.nightReadingCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.dark(
      primary: AppColors.greenPrimary,
      primaryContainer: AppColors.greenPrimaryLight,
      secondary: AppColors.bluePrimaryLight,
      secondaryContainer: AppColors.bluePrimary,
      surface: AppColors.nightReadingSurface,
      background: AppColors.nightReadingBackground,
      error: AppColors.errorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.nightReadingTextPrimary,
      onBackground: AppColors.nightReadingTextPrimary,
      onError: Colors.white,
      outline: AppColors.nightReadingDivider,
      outlineVariant: AppColors.nightReadingDivider,
    ),

    // 文本主题 - 护眼配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: AppColors.nightReadingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.nightReadingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: AppColors.nightReadingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.nightReadingTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 深色护眼
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.nightReadingSurface,
      elevation: 0, // 扁平化设计
      shadowColor: AppColors.nightReadingDivider,
      iconTheme: IconThemeData(
        color: AppColors.nightReadingTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: AppColors.nightReadingTextSecondary,
      size: 24,
    ),

    // 卡片主题 - 护眼设计
    cardTheme: CardTheme(
      color: AppColors.nightReadingCard,
      elevation: 1, // 轻微阴影
      shadowColor: AppColors.nightReadingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 绿色护眼
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.nightReadingDivider,
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
        foregroundColor: AppColors.greenPrimary,
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
    //   fillColor: AppColors.nightReadingSurface,
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.nightReadingDivider),
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.nightReadingDivider),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.greenPrimary, width: 2),
    //   ),
    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.errorLight),
    //   ),
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //   labelStyle: const TextStyle(color: AppColors.nightReadingTextSecondary),
    //   hintStyle: const TextStyle(color: AppColors.nightReadingTextHint),
    // ),

    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: AppColors.nightReadingDivider,
      thickness: 1,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.nightReadingSurface,
      selectedItemColor: AppColors.greenPrimary,
      unselectedItemColor: AppColors.nightReadingTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.greenPrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.greenPrimary,
      linearTrackColor: AppColors.nightReadingDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.greenPrimary;
        }
        return AppColors.nightReadingTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.greenPrimaryLight;
        }
        return AppColors.nightReadingDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.greenPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.nightReadingDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.greenPrimary;
        }
        return AppColors.nightReadingTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.greenPrimary,
      inactiveTrackColor: AppColors.nightReadingDivider,
      thumbColor: AppColors.greenPrimary,
      overlayColor: AppColors.greenPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.greenPrimary,
      unselectedLabelColor: AppColors.nightReadingTextSecondary,
      indicatorColor: AppColors.greenPrimary,
      dividerColor: AppColors.nightReadingDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.nightReadingCard,
      elevation: 8,
      shadowColor: AppColors.nightReadingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.nightReadingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.nightReadingTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.nightReadingCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.nightReadingCard,
      elevation: 8,
      shadowColor: AppColors.nightReadingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.nightReadingTextPrimary,
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
        color: AppColors.nightReadingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: AppColors.nightReadingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 1,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.nightReadingTextPrimary,
      iconColor: AppColors.nightReadingTextSecondary,
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.nightReadingSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.nightReadingSurface,
      selectedColor: AppColors.greenPrimary,
      disabledColor: AppColors.nightReadingTextDisabled,
      labelStyle: TextStyle(color: AppColors.nightReadingTextPrimary),
      secondaryLabelStyle: TextStyle(color: AppColors.nightReadingTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: AppColors.nightReadingTextPrimary,
      iconColor: AppColors.nightReadingTextSecondary,
      collapsedTextColor: AppColors.nightReadingTextSecondary,
      collapsedIconColor: AppColors.nightReadingTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.nightReadingCard,
      hourMinuteTextColor: AppColors.nightReadingTextPrimary,
      hourMinuteColor: AppColors.nightReadingSurface,
      dayPeriodTextColor: AppColors.nightReadingTextPrimary,
      dayPeriodColor: AppColors.nightReadingSurface,
      dialHandColor: AppColors.greenPrimary,
      dialBackgroundColor: AppColors.nightReadingSurface,
      dialTextColor: AppColors.nightReadingTextPrimary,
      entryModeIconColor: AppColors.greenPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.nightReadingCard,
      headerBackgroundColor: AppColors.greenPrimary,
      headerForegroundColor: Colors.white,
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 午夜主题 - 神秘宁静的深紫色系配色，适合夜间阅读
class MidnightTheme {
  // ==================== 颜色定义 ====================
  
  // 主色调 - 午夜紫色系
  static const Color midnightPrimary = Color(0xFF673AB7);
  static const Color midnightPrimaryLight = Color(0xFF9575CD);
  static const Color midnightPrimaryDark = Color(0xFF512DA8);
  
  // 午夜蓝色系
  static const Color midnightBlue = Color(0xFF3F51B5);
  static const Color midnightBlueLight = Color(0xFF5C6BC0);
  
  // 错误色
  static const Color error = Color(0xFFE91E63);
  
  // 背景色系 - 午夜配色
  static const Color midnightBackground = Color(0xFF1A1A2E);
  static const Color midnightSurface = Color(0xFF16213E);
  static const Color midnightCard = Color(0xFF0F3460);
  static const Color midnightDivider = Color(0xFF533483);
  
  // 文本色系 - 午夜配色
  static const Color midnightTextPrimary = Color(0xFFE8EAF6);
  static const Color midnightTextSecondary = Color(0xFFC5CAE9);
  static const Color midnightTextHint = Color(0xFF9FA8DA);
  static const Color midnightTextDisabled = Color(0xFF7986CB);
  
  // 交互状态色系
  static const Color midnightHover = Color(0xFF2A2A4E);
  static const Color midnightPressed = Color(0xFF1A1A3E);
  static const Color midnightSelected = Color(0xFF2E1B47);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调 - 使用午夜紫色系
    primaryColor: midnightPrimary,
    
    // 应用整体背景色 - 午夜配色
    scaffoldBackgroundColor: midnightBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: midnightCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.dark(
      primary: midnightPrimary,
      primaryContainer: midnightPrimaryLight,
      primaryFixed: midnightPrimaryDark,
      secondary: midnightBlue,
      secondaryContainer: midnightBlueLight,
      surface: midnightSurface,
      background: midnightBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: midnightTextPrimary,
      onBackground: midnightTextPrimary,
      onError: Colors.white,
      outline: midnightDivider,
      outlineVariant: midnightDivider,
    ),

    // 文本主题 - 午夜配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: midnightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: midnightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: midnightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: midnightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: midnightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: midnightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: midnightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: midnightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: midnightTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: midnightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: midnightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: midnightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: midnightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: midnightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: midnightTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 午夜风格
    appBarTheme: const AppBarTheme(
      backgroundColor: midnightSurface,
      elevation: 0,
      shadowColor: midnightDivider,
      iconTheme: IconThemeData(
        color: midnightTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: midnightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: midnightPrimary,
      size: 24,
    ),

    // 卡片主题 - 午夜质感
    cardTheme: CardTheme(
      color: midnightCard,
      elevation: 2,
      shadowColor: midnightDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: midnightDivider,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 午夜配色
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: midnightPrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: midnightDivider,
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
        foregroundColor: midnightPrimary,
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
      color: midnightDivider,
      thickness: 0.5,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: midnightSurface,
      selectedItemColor: midnightPrimary,
      unselectedItemColor: midnightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: midnightPrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: midnightPrimary,
      linearTrackColor: midnightDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return midnightPrimary;
        }
        return midnightTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return midnightPrimaryLight;
        }
        return midnightDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return midnightPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: midnightDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return midnightPrimary;
        }
        return midnightTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: midnightPrimary,
      inactiveTrackColor: midnightDivider,
      thumbColor: midnightPrimary,
      overlayColor: midnightPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: midnightPrimary,
      unselectedLabelColor: midnightTextSecondary,
      indicatorColor: midnightPrimary,
      dividerColor: midnightDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: midnightCard,
      elevation: 8,
      shadowColor: midnightDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: midnightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: midnightTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: midnightCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: midnightCard,
      elevation: 8,
      shadowColor: midnightDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: midnightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: midnightTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: midnightBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: midnightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: midnightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 0.5,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: midnightTextPrimary,
      iconColor: midnightPrimary,
      tileColor: Colors.transparent,
      selectedTileColor: midnightSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: midnightSurface,
      selectedColor: midnightPrimary,
      disabledColor: midnightTextDisabled,
      labelStyle: TextStyle(color: midnightTextPrimary),
      secondaryLabelStyle: TextStyle(color: midnightTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: midnightTextPrimary,
      iconColor: midnightPrimary,
      collapsedTextColor: midnightTextSecondary,
      collapsedIconColor: midnightTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: midnightCard,
      hourMinuteTextColor: midnightTextPrimary,
      hourMinuteColor: midnightSurface,
      dayPeriodTextColor: midnightTextPrimary,
      dayPeriodColor: midnightSurface,
      dialHandColor: midnightPrimary,
      dialBackgroundColor: midnightSurface,
      dialTextColor: midnightTextPrimary,
      entryModeIconColor: midnightPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: midnightCard,
      headerBackgroundColor: midnightPrimary,
      headerForegroundColor: Colors.white,
    ),
  );
} 
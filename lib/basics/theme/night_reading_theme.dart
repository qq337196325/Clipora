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

/// 护眼夜间主题 - 深色护眼阅读模式，减少蓝光伤害
class NightReadingTheme {
  // ==================== 颜色定义 ====================
  
  // 主色调 - 绿色系，更护眼
  static const Color greenPrimary = Color(0xFF81C784);
  static const Color greenPrimaryLight = Color(0xFFA5D6A7);
  static const Color greenPrimaryDark = Color(0xFF66BB6A);
  
  // 蓝色系
  static const Color bluePrimary = Color(0xFF42A5F5);
  static const Color bluePrimaryLight = Color(0xFF64B5F6);
  
  // 错误色
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  
  // 背景色系 - 深蓝灰色，更舒适
  static const Color nightReadingBackground = Color(0xFF263238);
  static const Color nightReadingSurface = Color(0xFF2E3C43);
  static const Color nightReadingCard = Color(0xFF37474F);
  static const Color nightReadingDivider = Color(0xFF455A64);
  
  // 文本色系 - 护眼配色
  static const Color nightReadingTextPrimary = Color(0xFFE5E5E7);
  static const Color nightReadingTextSecondary = Color(0xFFB0BEC5);
  static const Color nightReadingTextHint = Color(0xFF78909C);
  static const Color nightReadingTextDisabled = Color(0xFF546E7A);
  
  // 交互状态色系
  static const Color nightReadingHover = Color(0xFF2E3C43);
  static const Color nightReadingPressed = Color(0xFF1E2C33);
  static const Color nightReadingSelected = Color(0xFF1E3A2A);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调 - 使用绿色系，更护眼
    primaryColor: greenPrimary,
    
    // 应用整体背景色 - 深蓝灰色，更舒适
    scaffoldBackgroundColor: nightReadingBackground,
    
    // 卡片和对话框等元素的背景色
    cardColor: nightReadingCard,
    
    // 表面颜色
    colorScheme: const ColorScheme.dark(
      primary: greenPrimary,
      primaryContainer: greenPrimaryLight,
      primaryFixed: greenPrimaryDark,
      secondary: bluePrimaryLight,
      secondaryContainer: bluePrimary,
      surface: nightReadingSurface,
      background: nightReadingBackground,
      error: errorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: nightReadingTextPrimary,
      onBackground: nightReadingTextPrimary,
      onError: Colors.white,
      outline: nightReadingDivider,
      outlineVariant: nightReadingDivider,
    ),

    // 文本主题 - 护眼配色
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // 增加行高，更护眼
      ),
      bodyMedium: TextStyle(
        color: nightReadingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: nightReadingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: nightReadingTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: nightReadingTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 应用栏主题 - 深色护眼
    appBarTheme: const AppBarTheme(
      backgroundColor: nightReadingSurface,
      elevation: 0, // 扁平化设计
      shadowColor: nightReadingDivider,
      iconTheme: IconThemeData(
        color: nightReadingTextPrimary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: nightReadingTextSecondary,
      size: 24,
    ),

    // 卡片主题 - 护眼设计
    cardTheme: CardTheme(
      color: nightReadingCard,
      elevation: 1, // 轻微阴影
      shadowColor: nightReadingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 按钮主题 - 绿色护眼
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: greenPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: nightReadingDivider,
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
        foregroundColor: greenPrimary,
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
      color: nightReadingDivider,
      thickness: 1,
      space: 1,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: nightReadingSurface,
      selectedItemColor: greenPrimary,
      unselectedItemColor: nightReadingTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // 浮动操作按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: greenPrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: greenPrimary,
      linearTrackColor: nightReadingDivider,
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return greenPrimary;
        }
        return nightReadingTextDisabled;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return greenPrimaryLight;
        }
        return nightReadingDivider;
      }),
    ),

    // 复选框主题
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return greenPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: nightReadingDivider),
    ),

    // 单选按钮主题
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return greenPrimary;
        }
        return nightReadingTextDisabled;
      }),
    ),

    // 滑块主题
    sliderTheme: const SliderThemeData(
      activeTrackColor: greenPrimary,
      inactiveTrackColor: nightReadingDivider,
      thumbColor: greenPrimary,
      overlayColor: greenPrimaryLight,
    ),

    // 标签页主题
    tabBarTheme: const TabBarTheme(
      labelColor: greenPrimary,
      unselectedLabelColor: nightReadingTextSecondary,
      indicatorColor: greenPrimary,
      dividerColor: nightReadingDivider,
    ),

    // 对话框主题
    dialogTheme: DialogTheme(
      backgroundColor: nightReadingCard,
      elevation: 8,
      shadowColor: nightReadingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: nightReadingTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 底部表单主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: nightReadingCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // 弹出菜单主题
    popupMenuTheme: PopupMenuThemeData(
      color: nightReadingCard,
      elevation: 8,
      shadowColor: nightReadingDivider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 工具提示主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: nightReadingTextPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        color: nightReadingBackground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // 数据表格主题
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: nightReadingTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: nightReadingTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerThickness: 1,
      columnSpacing: 16,
    ),

    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: nightReadingTextPrimary,
      iconColor: nightReadingTextSecondary,
      tileColor: Colors.transparent,
      selectedTileColor: nightReadingSelected,
    ),

    // 芯片主题
    chipTheme: const ChipThemeData(
      backgroundColor: nightReadingSurface,
      selectedColor: greenPrimary,
      disabledColor: nightReadingTextDisabled,
      labelStyle: TextStyle(color: nightReadingTextPrimary),
      secondaryLabelStyle: TextStyle(color: nightReadingTextSecondary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // 扩展面板主题
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: nightReadingTextPrimary,
      iconColor: nightReadingTextSecondary,
      collapsedTextColor: nightReadingTextSecondary,
      collapsedIconColor: nightReadingTextSecondary,
    ),

    // 选择器主题
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: nightReadingCard,
      hourMinuteTextColor: nightReadingTextPrimary,
      hourMinuteColor: nightReadingSurface,
      dayPeriodTextColor: nightReadingTextPrimary,
      dayPeriodColor: nightReadingSurface,
      dialHandColor: greenPrimary,
      dialBackgroundColor: nightReadingSurface,
      dialTextColor: nightReadingTextPrimary,
      entryModeIconColor: greenPrimary,
    ),

    // 日期选择器主题
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: nightReadingCard,
      headerBackgroundColor: greenPrimary,
      headerForegroundColor: Colors.white,
    ),
  );
}
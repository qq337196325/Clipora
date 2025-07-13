import 'package:flutter/material.dart';

/// 护眼夜间主题 - 深色护眼阅读模式
class NightReadingTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调
    primaryColor: const Color(0xFF4A90E2), // 柔和的蓝色
    
    // 应用整体背景色
    scaffoldBackgroundColor: const Color(0xFF1C1C1E), // 深灰色背景，比纯黑柔和
    
    // 卡片和对话框等元素的背景色
    cardColor: const Color(0xFF2C2C2E),

    // 文本主题
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE5E5E7)), // 柔和的浅色文本
      bodyMedium: TextStyle(color: Color(0xFFE5E5E7)), // 柔和的浅色文本
      titleLarge: TextStyle(color: Color(0xFFF2F2F7)), // 更亮的标题
    ),

    // 应用栏主题
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C2C2E), // 深色应用栏
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE5E5E7)), // 柔和浅色图标
      titleTextStyle: TextStyle(
        color: Color(0xFFF2F2F7), // 亮色标题
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: Color(0xFFAEAEB2), // 中性灰色图标
    ),

    // 其他颜色配置
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4A90E2), // 柔和蓝色主色
      secondary: Color(0xFF5AC8FA), // 浅蓝色次要色
      surface: Color(0xFF2C2C2E), // 表面颜色
      background: Color(0xFF1C1C1E), // 背景颜色
      error: Color(0xFFFF6961), // 柔和的红色错误提示
      onPrimary: Colors.white, // 在主色上的文本/图标颜色
      onSecondary: Colors.black, // 在次要颜色上的文本/图标颜色
      onSurface: Color(0xFFE5E5E7), // 在表面颜色上的文本/图标颜色
      onBackground: Color(0xFFE5E5E7), // 在背景颜色上的文本/图标颜色
      onError: Colors.white, // 在错误颜色上的文本/图标颜色
    ),
  );
}
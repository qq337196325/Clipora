import 'package:flutter/material.dart';

/// 深色主题 - 适合夜间使用
class DarkTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色调
    primaryColor: const Color(0xFF1976D2), // 蓝色主色调
    
    // 应用整体背景色
    scaffoldBackgroundColor: const Color(0xFF121212), // 深色背景
    
    // 卡片和对话框等元素的背景色
    cardColor: const Color(0xFF1E1E1E),

    // 文本主题
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)), // 浅色文本
      bodyMedium: TextStyle(color: Color(0xFFE0E0E0)), // 浅色文本
      titleLarge: TextStyle(color: Color(0xFFFFFFFF)), // 白色标题
    ),

    // 应用栏主题
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E), // 深色应用栏
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE0E0E0)), // 浅色图标
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF), // 白色标题
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: Color(0xFFB0B0B0), // 浅灰色图标
    ),

    // 其他颜色配置
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1976D2), // 主要颜色
      secondary: Color(0xFF03DAC6), // 次要颜色
      surface: Color(0xFF1E1E1E), // 表面颜色
      background: Color(0xFF121212), // 背景颜色
      error: Color(0xFFCF6679), // 错误颜色
      onPrimary: Colors.white, // 在主色上的文本/图标颜色
      onSecondary: Colors.black, // 在次要颜色上的文本/图标颜色
      onSurface: Color(0xFFE0E0E0), // 在表面颜色上的文本/图标颜色
      onBackground: Color(0xFFE0E0E0), // 在背景颜色上的文本/图标颜色
      onError: Colors.black, // 在错误颜色上的文本/图标颜色
    ),
  );
}
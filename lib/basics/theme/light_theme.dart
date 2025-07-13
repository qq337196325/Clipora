import 'package:flutter/material.dart';

/// 纯白主题 - 简洁明亮的设计
class LightTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    
    // 主色调
    primaryColor: const Color(0xFF1976D2), // 标准蓝色
    
    // 应用整体背景色
    scaffoldBackgroundColor: Colors.white, // 纯白背景
    
    // 卡片和对话框等元素的背景色
    cardColor: Colors.white,

    // 文本主题
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121)), // 深灰色文本
      bodyMedium: TextStyle(color: Color(0xFF212121)), // 深灰色文本
      titleLarge: TextStyle(color: Color(0xFF212121)), // 深色标题
    ),

    // 应用栏主题
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // 白色应用栏
      elevation: 1, // 轻微阴影
      iconTheme: IconThemeData(color: Color(0xFF212121)), // 深色图标
      titleTextStyle: TextStyle(
        color: Color(0xFF212121), // 深色标题
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 图标主题
    iconTheme: const IconThemeData(
      color: Color(0xFF757575), // 中灰色图标
    ),

    // 其他颜色配置
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1976D2), // 主要颜色
      secondary: Color(0xFF03DAC6), // 次要颜色
      surface: Colors.white, // 表面颜色
      background: Colors.white, // 背景颜色
      error: Color(0xFFB00020), // 错误颜色
      onPrimary: Colors.white, // 在主色上的文本/图标颜色
      onSecondary: Colors.white, // 在次要颜色上的文本/图标颜色
      onSurface: Color(0xFF212121), // 在表面颜色上的文本/图标颜色
      onBackground: Color(0xFF212121), // 在背景颜色上的文本/图标颜色
      onError: Colors.white, // 在错误颜色上的文本/图标颜色
    ),
  );
}
import 'package:flutter/material.dart';

/// 应用的亮色主题，专为阅读优化，提供护眼体验。
final ThemeData readingTheme = ThemeData(
  brightness: Brightness.light,
  
  // 主色调
  primaryColor: const Color(0xFF005A9C), // 一种沉稳的蓝色
  
  // 应用整体背景色
  scaffoldBackgroundColor: const Color(0xFFF8F5EC), // 柔和的米黄色，类似纸莎草纸
  
  // 卡片和对话框等元素的背景色
  cardColor: const Color(0xFFFEFDF8),

  // 文本主题
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF3C3C3C)), // 深灰色文本
    bodyMedium: TextStyle(color: Color(0xFF3C3C3C)), // 深灰色文本
    titleLarge: TextStyle(color: Color(0xFF3C3C3C)), // 标题也是深灰色
  ),

  // 应用栏主题
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF8F5EC), // 与背景色统一
    elevation: 0, // 去掉阴影，更扁平
    iconTheme: IconThemeData(color: Color(0xFF3C3C3C)), // 图标颜色
    titleTextStyle: TextStyle(
      color: Color(0xFF3C3C3C), // 标题颜色
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  ),

  // 图标主题
  iconTheme: const IconThemeData(
    color: Color(0xFF5A5A5A), // 默认图标颜色
  ),

  // 其他颜色配置
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF005A9C), // 主要颜色
    secondary: Color(0xFF4B6A88), // 次要颜色
    surface: Color(0xFFFEFDF8), // 表面颜色，如卡片
    background: Color(0xFFF8F5EC), // 背景颜色
    error: Color(0xFFB00020), // 错误颜色
    onPrimary: Colors.white, // 在主色上的文本/图标颜色
    onSecondary: Colors.white, // 在次要颜色上的文本/图标颜色
    onSurface: Color(0xFF3C3C3C), // 在表面颜色上的文本/图标颜色
    onBackground: Color(0xFF3C3C3C), // 在背景颜色上的文本/图标颜色
    onError: Colors.white, // 在错误颜色上的文本/图标颜色
  ).copyWith(background: const Color(0xFFF8F5EC)),
); 
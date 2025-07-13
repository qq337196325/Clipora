import 'package:flutter/material.dart';
import 'reading_theme.dart';
import 'light_theme.dart';
import 'dark_theme.dart';
import 'night_reading_theme.dart';
import 'theme_controller.dart';

/// 应用主题统一管理
class AppThemes {
  // 护眼主题 (默认)
  static ThemeData get readingTheme => ReadingTheme.theme;
  
  // 纯白主题
  static ThemeData get lightTheme => LightTheme.theme;
  
  // 深色主题
  static ThemeData get darkTheme => DarkTheme.theme;
  
  // 护眼夜间主题
  static ThemeData get nightReadingTheme => NightReadingTheme.theme;

  // 根据主题类型获取对应的 ThemeData
  static ThemeData getThemeData(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.reading:
        return readingTheme;
      case AppThemeType.light:
        return lightTheme;
      case AppThemeType.dark:
        return darkTheme;
      case AppThemeType.nightReading:
        return nightReadingTheme;
    }
  }

  // 获取默认主题
  static ThemeData get defaultTheme => readingTheme;
  
  // 所有主题列表
  static Map<AppThemeType, ThemeData> get allThemes => {
    AppThemeType.reading: readingTheme,
    AppThemeType.light: lightTheme,
    AppThemeType.dark: darkTheme,
    AppThemeType.nightReading: nightReadingTheme,
  };
}
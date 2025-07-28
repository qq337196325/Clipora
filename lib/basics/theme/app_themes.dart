// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'night_reading_theme.dart';
import 'reading_theme.dart';
import 'ocean_theme.dart';
import 'forest_theme.dart';
import 'theme_controller.dart';

/// 应用主题管理类
class AppThemes {
  /// 根据主题类型获取对应的主题数据
  static ThemeData getThemeData(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.reading:
        return ReadingTheme.theme;
      case AppThemeType.light:
        return LightTheme.theme;
      case AppThemeType.dark:
        return DarkTheme.theme;
      case AppThemeType.nightReading:
        return NightReadingTheme.theme;
      case AppThemeType.ocean:
        return OceanTheme.theme;
      case AppThemeType.forest:
        return ForestTheme.theme;
      default:
        return ReadingTheme.theme;
    }
  }
}
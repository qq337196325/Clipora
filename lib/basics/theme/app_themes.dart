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
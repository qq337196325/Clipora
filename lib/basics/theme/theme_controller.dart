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
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_themes.dart';

// 主题类型枚举
enum AppThemeType {
  reading,      // 护眼主题
  light,        // 纯白主题
  dark,         // 深色主题
  nightReading, // 护眼夜间主题
  ocean,        // 海洋主题
  forest,       // 森林主题
}

// 主题模型
class ThemeModel {
  final AppThemeType type;
  final String name;
  final String description;
  final IconData icon;

  const ThemeModel({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class ThemeController extends GetxController {
  static const String _storageKey = 'app_theme';
  
  final _storage = GetStorage();
  
  // 当前主题
  Rx<AppThemeType> currentTheme = AppThemeType.reading.obs;
  
  // 支持的主题列表
  final List<ThemeModel> supportedThemes = [
    const ThemeModel(
      type: AppThemeType.reading,
      name: 'i18n_theme_护眼主题',
      description: 'i18n_theme_专为阅读优化的护眼配色',
      icon: Icons.visibility,
    ),
    const ThemeModel(
      type: AppThemeType.light,
      name: 'i18n_theme_纯白主题',
      description: 'i18n_theme_简洁明亮的纯白设计',
      icon: Icons.light_mode,
    ),
    const ThemeModel(
      type: AppThemeType.dark,
      name: 'i18n_theme_深色主题',
      description: 'i18n_theme_适合夜间使用的深色模式',
      icon: Icons.dark_mode,
    ),
    const ThemeModel(
      type: AppThemeType.nightReading,
      name: 'i18n_theme_护眼夜间',
      description: 'i18n_theme_深色护眼阅读模式',
      icon: Icons.nightlight_round,
    ),

    const ThemeModel(
      type: AppThemeType.ocean,
      name: 'i18n_theme_海洋主题',
      description: 'i18n_theme_清新宁静的蓝色系配色',
      icon: Icons.water,
    ),
    const ThemeModel(
      type: AppThemeType.forest,
      name: 'i18n_theme_森林主题',
      description: 'i18n_theme_自然宁静的绿色系配色',
      icon: Icons.forest,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  // 从存储中加载主题设置
  void _loadThemeFromStorage() {
    final savedTheme = _storage.read(_storageKey);
    if (savedTheme != null) {
      try {
        final themeType = AppThemeType.values.firstWhere(
          (theme) => theme.toString() == savedTheme,
          orElse: () => AppThemeType.reading,
        );
        print('💾 从存储加载主题: $themeType');
        currentTheme.value = themeType;
        // 确保加载的主题也应用到 GetX 主题系统
        Get.changeTheme(_getThemeData(themeType));
      } catch (e) {
        print('❌ 加载主题失败: $e');
        // 如果解析失败，使用默认主题
        currentTheme.value = AppThemeType.light;
        Get.changeTheme(_getThemeData(AppThemeType.light));
      }
    } else {
      print('📝 没有保存的主题，使用默认主题');
      currentTheme.value = AppThemeType.light;
      Get.changeTheme(_getThemeData(AppThemeType.light));
    }
  }

  // 切换主题
  void changeTheme(AppThemeType themeType) {
    print('🎨 切换主题: $themeType');
    currentTheme.value = themeType;
    _saveThemeToStorage(themeType);
    
    // 触发 GetX 的主题更新
    final newTheme = _getThemeData(themeType);
    print('🎨 新主题数据: ${newTheme.primaryColor}');
    Get.changeTheme(newTheme);
    print('🎨 主题切换完成');
  }

  // 保存主题设置到存储
  void _saveThemeToStorage(AppThemeType themeType) {
    _storage.write(_storageKey, themeType.toString());
  }

  // 根据主题类型获取对应的 ThemeData
  ThemeData _getThemeData(AppThemeType themeType) {
    return AppThemes.getThemeData(themeType);
  }

  // 获取当前主题的 ThemeData
  ThemeData get currentThemeData => _getThemeData(currentTheme.value);

  // 获取主题模型
  ThemeModel get currentThemeModel {
    return supportedThemes.firstWhere(
      (theme) => theme.type == currentTheme.value,
      orElse: () => supportedThemes.first,
    );
  }

  // 是否为深色主题
  bool get isDarkTheme {
    return currentTheme.value == AppThemeType.dark || 
           currentTheme.value == AppThemeType.nightReading;
  }

  // 是否为护眼主题
  bool get isReadingTheme {
    return currentTheme.value == AppThemeType.reading || 
           currentTheme.value == AppThemeType.nightReading;
  }
}
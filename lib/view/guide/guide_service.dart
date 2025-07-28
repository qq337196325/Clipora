// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:shared_preferences/shared_preferences.dart';

class GuideService {
  static const String _hasCompletedGuideKey = 'has_completed_guide';

  /// 检查用户是否已经完成引导
  static Future<bool> hasCompletedGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedGuideKey) ?? false;
  }

  /// 标记用户已完成引导
  static Future<void> markGuideCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedGuideKey, true);
  }

  /// 重置引导状态（用于测试或重新显示引导）
  static Future<void> resetGuideState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCompletedGuideKey);
  }
} 
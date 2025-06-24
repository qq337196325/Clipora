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
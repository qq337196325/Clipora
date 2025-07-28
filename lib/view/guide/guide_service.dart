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
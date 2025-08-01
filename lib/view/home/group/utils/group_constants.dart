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

/// 分组页面相关的样式常量
class GroupConstants {
  /// 颜色常量
  static const Color primaryGradientStart = Color(0xff667eea);
  static const Color primaryGradientEnd = Color(0xff764ba2);
  static const Color backgroundGradientStart = Color(0xfff8f9fa);
  static const Color backgroundGradientEnd = Color(0xfff1f3f4);
  static const Color primaryText = Color(0xff1a1a1a);
  static const Color secondaryText = Color(0xff666666);
  static const Color itemText = Color(0xff2a2a2a);
  static const Color hintText = Color(0xff999999);
  static const Color lightHint = Color(0xffcccccc);
  static const Color dividerColor = Color(0xffe0e0e0);
  static const Color errorColor = Color(0xffff4757);
  static const Color successColor = Color(0xff52c41a);

  /// 渐变样式
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundGradientStart, backgroundGradientEnd],
  );

  /// 圆角半径
  static const double cardRadius = 20.0;
  static const double buttonRadius = 12.0;
  static const double itemRadius = 10.0;

  /// 间距
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(12, 4, 12, 12);
  static const EdgeInsets appBarPadding = EdgeInsets.fromLTRB(20, 12, 16, 12);
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 1);

  /// 尺寸
  static const double iconSize = 32.0;
  static const double expandIconSize = 30.0;
  static const double moreButtonSize = 28.0;

  /// 阴影
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

  static BoxShadow get buttonShadow => BoxShadow(
    color: primaryGradientStart.withOpacity(0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  /// 动画持续时间
  static const Duration expandAnimationDuration = Duration(milliseconds: 300);
  static const Duration itemAnimationDuration = Duration(milliseconds: 200);
} 
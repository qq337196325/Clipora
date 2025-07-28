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
import 'package:bot_toast/bot_toast.dart';


/// 分组页面工具类
class GroupUtils {
  /// 显示成功消息
  static void showSuccessMessage(String message) {
    BotToast.showText(
      text: message,
      borderRadius: BorderRadius.circular(10),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  /// 显示错误消息
  static void showErrorMessage(String message) {
    BotToast.showText(
      text: '❌ $message',
      borderRadius: BorderRadius.circular(10),
      contentColor: Colors.red,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  /// 构建分隔线
  static Widget buildDivider(int level, BuildContext context) {
    final theme = Theme.of(context);
    final double indentation = 14 + (level * 20.0) + 36;
    return Container(
      margin: EdgeInsets.only(left: indentation, right: 14),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.dividerColor.withOpacity(0.3),
            theme.dividerColor,
            theme.dividerColor.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
} 
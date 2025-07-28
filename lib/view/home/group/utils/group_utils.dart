// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



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
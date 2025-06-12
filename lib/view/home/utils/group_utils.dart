import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'group_constants.dart';

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
      contentColor: GroupConstants.errorColor,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  /// 构建分隔线
  static Widget buildDivider(int level) {
    final double indentation = 14 + (level * 20.0) + 36;
    return Container(
      margin: EdgeInsets.only(left: indentation, right: 14),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GroupConstants.dividerColor.withOpacity(0.3),
            GroupConstants.dividerColor,
            GroupConstants.dividerColor.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
} 
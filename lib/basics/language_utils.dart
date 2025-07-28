// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:get/get.dart';

/// 多语言工具类
class LanguageUtils {
  
  /// 获取翻译文本
  static String tr(String key, {Map<String, String>? args}) {
    return key.tr;
  }
  
  /// 获取带参数的翻译文本
  static String trArgs(String key, List<String> args) {
    return key.trArgs(args);
  }
  
  /// 获取复数形式的翻译文本
  static String trPlural(String key, int count, {Map<String, String>? args}) {
    return key.trPlural(count.toString());
  }
  
  /// 检查是否存在翻译
  static bool hasTranslation(String key) {
    return Get.translations.containsKey(Get.locale.toString()) &&
           Get.translations[Get.locale.toString()]!.containsKey(key);
  }
  
  /// 获取当前语言代码
  static String getCurrentLanguageCode() {
    return Get.locale?.languageCode ?? 'zh';
  }
  
  /// 获取当前完整语言标识
  static String getCurrentLocaleString() {
    return Get.locale?.toString() ?? 'zh_CN';
  }
  
  /// 判断是否为中文
  static bool isChinese() {
    return getCurrentLanguageCode() == 'zh';
  }
  
  /// 判断是否为英文
  static bool isEnglish() {
    return getCurrentLanguageCode() == 'en';
  }
  
  /// 获取格式化的日期时间字符串
  static String formatDateTime(DateTime dateTime) {
    if (isChinese()) {
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
  
  /// 获取相对时间描述
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return tr('today');
    } else if (difference.inDays == 1) {
      return tr('yesterday');
    } else if (difference.inDays < 7) {
      return tr('this_week');
    } else if (difference.inDays < 30) {
      return tr('this_month');
    } else {
      return tr('earlier');
    }
  }
  
  /// 获取文件大小的本地化字符串
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// 获取数量的本地化字符串
  static String getCountString(int count, String itemKey) {
    if (isChinese()) {
      return '$count 个$itemKey';
    } else {
      return count == 1 ? '1 $itemKey' : '$count ${itemKey}s';
    }
  }
} 
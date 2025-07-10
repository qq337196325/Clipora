// lib/basics/translations/zh_cn/zh_cn.dart

import 'login_i18n.dart';

// 汇总所有中文翻译
const Map<String, String> zhCN = {
  // 使用 ... 扩展操作符来合并 map
  ...loginI18n,
  // 如果有其他页面的翻译，也在这里添加
  // ...homeI18n,
  // ...settingsI18n,
};
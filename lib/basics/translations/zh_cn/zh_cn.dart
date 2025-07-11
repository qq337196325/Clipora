// lib/basics/translations/zh_cn/zh_cn.dart

import 'guide_i18n.dart';
import 'home_group_i18n.dart';
import 'home_index_i18n.dart';
import 'home_my_i18n.dart';
import 'home_search_i18n.dart';
import 'login_i18n.dart';

// 汇总所有中文翻译
const Map<String, String> zhCN = {
  // 使用 ... 扩展操作符来合并 map
  ...loginI18n,
  ...guideI18n,
  ...homeGroupI18n,
  ...homeIndexI18n,
  ...homeMyI18n,
  ...homeSearchI18n,

};
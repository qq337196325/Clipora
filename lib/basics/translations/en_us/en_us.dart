// lib/basics/translations/en_us/en_us.dart

import 'article_list_i18n.dart';
import 'article_i18n.dart';
import 'guide_i18n.dart';
import 'home_group_i18n.dart';
import 'home_my_i18n.dart';
import 'home_search_i18n.dart';
import 'home_index_i18n.dart';
import 'login_i18n.dart';
import 'order_i18n.dart';

// 汇总所有英文翻译
const Map<String, String> enUS = {
  // 使用 ... 扩展操作符来合并 map
  ...loginI18n,
  ...guideI18n,
  ...homeIndexI18n,
  ...homeGroupI18n,
  ...homeMyI18n,
  ...homeSearchI18n,
  ...articleI18n,
  ...articleListI18n,
  ...orderI18n,
  // 如果有其他页面的英文翻译，也在这里添加
};
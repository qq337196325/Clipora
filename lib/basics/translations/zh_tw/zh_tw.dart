// lib/basics/translations/zh_tw/zh_tw.dart

import 'theme_i18n.dart';
import 'login_i18n.dart';
import 'article_i18n.dart';
import 'article_list_i18n.dart';
import 'guide_i18n.dart';
import 'home_group_i18n.dart';
import 'home_index_i18n.dart';
import 'home_my_i18n.dart';
import 'home_search_i18n.dart';
import 'order_i18n.dart';
import 'language_selector_i18n.dart';

// 汇总所有繁体中文翻译
const Map<String, String> zhTW = {
  // 使用 ... 扩展操作符来合并 map
  ...loginI18n,
  ...themeI18n,
  ...articleI18n,
  ...articleListI18n,
  ...guideI18n,
  ...homeGroupI18n,
  ...homeIndexI18n,
  ...homeMyI18n,
  ...homeSearchI18n,
  ...orderI18n,
  ...languageSelectorI18n,
};

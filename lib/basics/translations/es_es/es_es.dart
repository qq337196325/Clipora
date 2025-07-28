// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


// lib/basics/translations/es_es/es_es.dart

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

// 汇总所有西班牙语翻译
const Map<String, String> esES = {
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
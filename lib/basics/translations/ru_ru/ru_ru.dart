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

// 汇总所有俄语翻译
const Map<String, String> ruRU = {
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

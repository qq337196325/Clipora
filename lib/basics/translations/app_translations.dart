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




import 'package:get/get.dart';
import 'zh_cn/zh_cn.dart'; // 导入中文总文件
import 'en_us/en_us.dart'; // 导入英文总文件
import 'ja_jp/ja_jp.dart'; // 导入日语总文件
import 'ko_kr/ko_kr.dart'; // 导入韩语总文件
import 'fr_fr/fr_fr.dart'; // 导入法语总文件
import 'de_de/de_de.dart'; // 导入德语总文件
import 'es_es/es_es.dart'; // 导入西班牙语总文件
import 'ru_ru/ru_ru.dart'; // 导入俄语总文件
import 'ar_ar/ar_ar.dart'; // 导入阿拉伯语总文件
import 'pt_pt/pt_pt.dart'; // 导入葡萄牙语总文件
import 'it_it/it_it.dart'; // 导入意大利语总文件
import 'nl_nl/nl_nl.dart'; // 导入荷兰语总文件
import 'th_th/th_th.dart'; // 导入泰语总文件
import 'vi_vn/vi_vn.dart'; // 导入越南语总文件
import 'zh_tw/zh_tw.dart'; // 导入繁体中文总文件

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zhCN, // 简体中文
        'en_US': enUS, // 英文
        'ja_JP': jaJP, // 日语
        'ko_KR': koKR, // 韩语
        'fr_FR': frFR, // 法语
        'de_DE': deDE, // 德语
        'es_ES': esES, // 西班牙语
        'ru_RU': ruRU, // 俄语
        'ar_AR': arAR, // 阿拉伯语
        'pt_PT': ptPT, // 葡萄牙语
        'it_IT': itIT, // 意大利语
        'nl_NL': nlNL, // 荷兰语
        'th_TH': thTH, // 泰语
        'vi_VN': viVN, // 越南语
        'zh_TW': zhTW, // 繁体中文
      };
}

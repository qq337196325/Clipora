// lib/basics/translations/app_translations.dart

import 'package:get/get.dart';
import 'zh_cn/zh_cn.dart'; // 导入中文总文件
import 'en_us/en_us.dart'; // 导入新的英文总文件

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zhCN, // 使用从 zh_cn.dart 导入的 map
        'en_US': enUS, // 添加英文翻译
      };
}

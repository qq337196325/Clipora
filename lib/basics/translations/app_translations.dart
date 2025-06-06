import 'package:get/get.dart';

import 'zh_cn.dart';
import 'en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': ZhCN.translations,
    'en_US': EnUS.translations,
  };
} 
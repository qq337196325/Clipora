import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const String _storageKey = 'app_language';
  
  final _storage = GetStorage();
  
  // 当前语言
  Rx<Locale> currentLocale = const Locale('zh', 'CN').obs;
  
  // 支持的语言列表
  final List<LanguageModel> supportedLanguages = [
    LanguageModel(
      languageCode: 'zh',
      countryCode: 'CN',
      languageName: '中文简体',
      flag: '🇨🇳',
    ),
    LanguageModel(
      languageCode: 'en',
      countryCode: 'US',
      languageName: 'English',
      flag: '🇺🇸',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// 加载保存的语言设置
  void _loadSavedLanguage() {
    final savedLanguage = _storage.read(_storageKey);
    if (savedLanguage != null) {
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        currentLocale.value = Locale(parts[0], parts[1]);
        Get.updateLocale(currentLocale.value);
      }
    } else {
      // 如果没有保存的语言，使用系统语言
      _setSystemLanguage();
    }
  }

  /// 设置系统语言
  void _setSystemLanguage() {
    final systemLocale = Get.deviceLocale;
    if (systemLocale != null) {
      // 检查系统语言是否在支持列表中
      final supportedLanguage = supportedLanguages.firstWhereOrNull(
        (lang) => lang.languageCode == systemLocale.languageCode,
      );
      
      if (supportedLanguage != null) {
        currentLocale.value = Locale(
          supportedLanguage.languageCode,
          supportedLanguage.countryCode,
        );
      } else {
        // 默认使用中文
        currentLocale.value = const Locale('zh', 'CN');
      }
    } else {
      currentLocale.value = const Locale('zh', 'CN');
    }
    
    Get.updateLocale(currentLocale.value);
    _saveLanguage();
  }

  /// 更改语言
  void changeLanguage(String languageCode, String countryCode) {
    final newLocale = Locale(languageCode, countryCode);
    currentLocale.value = newLocale;
    Get.updateLocale(newLocale);
    _saveLanguage();
  }

  /// 保存语言设置
  void _saveLanguage() {
    final languageString = '${currentLocale.value.languageCode}_${currentLocale.value.countryCode}';
    _storage.write(_storageKey, languageString);
  }

  /// 获取当前语言名称
  String getCurrentLanguageName() {
    final current = supportedLanguages.firstWhereOrNull(
      (lang) => lang.languageCode == currentLocale.value.languageCode,
    );
    return current?.languageName ?? '中文简体';
  }

  /// 获取当前语言标志
  String getCurrentLanguageFlag() {
    final current = supportedLanguages.firstWhereOrNull(
      (lang) => lang.languageCode == currentLocale.value.languageCode,
    );
    return current?.flag ?? '🇨🇳';
  }

  /// 检查是否为当前语言
  bool isCurrentLanguage(String languageCode, String countryCode) {
    return currentLocale.value.languageCode == languageCode &&
           currentLocale.value.countryCode == countryCode;
  }
}

/// 语言模型
class LanguageModel {
  final String languageCode;
  final String countryCode;
  final String languageName;
  final String flag;

  LanguageModel({
    required this.languageCode,
    required this.countryCode,
    required this.languageName,
    required this.flag,
  });

  Locale get locale => Locale(languageCode, countryCode);
} 
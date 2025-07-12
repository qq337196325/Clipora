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
      englishName: 'Simplified Chinese',
      flag: '🇨🇳',
    ),
    LanguageModel(
      languageCode: 'en',
      countryCode: 'US',
      languageName: 'English',
      englishName: 'English',
      flag: '🇺🇸',
    ),
    LanguageModel(
      languageCode: 'zh',
      countryCode: 'TW',
      languageName: '中文繁體',
      englishName: 'Traditional Chinese',
      flag: '🇭🇰',
    ),
    LanguageModel(
      languageCode: 'ja',
      countryCode: 'JP',
      languageName: '日本語',
      englishName: 'Japanese',
      flag: '🇯🇵',
    ),
    LanguageModel(
      languageCode: 'ko',
      countryCode: 'KR',
      languageName: '한국어',
      englishName: 'Korean',
      flag: '🇰🇷',
    ),
    LanguageModel(
      languageCode: 'fr',
      countryCode: 'FR',
      languageName: 'Français',
      englishName: 'French',
      flag: '🇫🇷',
    ),
    LanguageModel(
      languageCode: 'de',
      countryCode: 'DE',
      languageName: 'Deutsch',
      englishName: 'German',
      flag: '🇩🇪',
    ),
    LanguageModel(
      languageCode: 'es',
      countryCode: 'ES',
      languageName: 'Español',
      englishName: 'Spanish',
      flag: '🇪🇸',
    ),
    LanguageModel(
      languageCode: 'ru',
      countryCode: 'RU',
      languageName: 'Русский',
      englishName: 'Russian',
      flag: '🇷🇺',
    ),
    LanguageModel(
      languageCode: 'ar',
      countryCode: 'AR',
      languageName: 'العربية',
      englishName: 'Arabic',
      flag: '🇸🇦',
    ),
    LanguageModel(
      languageCode: 'pt',
      countryCode: 'PT',
      languageName: 'Português',
      englishName: 'Portuguese',
      flag: '🇵🇹',
    ),
    LanguageModel(
      languageCode: 'it',
      countryCode: 'IT',
      languageName: 'Italiano',
      englishName: 'Italian',
      flag: '🇮🇹',
    ),
    LanguageModel(
      languageCode: 'nl',
      countryCode: 'NL',
      languageName: 'Nederlands',
      englishName: 'Dutch',
      flag: '🇳🇱',
    ),
    LanguageModel(
      languageCode: 'th',
      countryCode: 'TH',
      languageName: 'ไทย',
      englishName: 'Thai',
      flag: '🇹🇭',
    ),
    LanguageModel(
      languageCode: 'vi',
      countryCode: 'VN',
      languageName: 'Tiếng Việt',
      englishName: 'Vietnamese',
      flag: '🇻🇳',
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
        (lang) => lang.languageCode == systemLocale.languageCode &&
                  lang.countryCode == systemLocale.countryCode,
      );
      
      if (supportedLanguage != null) {
        currentLocale.value = Locale(
          supportedLanguage.languageCode,
          supportedLanguage.countryCode,
        );
      } else {
        // 尝试只匹配语言代码
        final langOnlyMatch = supportedLanguages.firstWhereOrNull(
          (lang) => lang.languageCode == systemLocale.languageCode,
        );
        
        if (langOnlyMatch != null) {
          currentLocale.value = Locale(
            langOnlyMatch.languageCode,
            langOnlyMatch.countryCode,
          );
        } else {
          // 默认使用中文
          currentLocale.value = const Locale('zh', 'CN');
        }
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
      (lang) => lang.languageCode == currentLocale.value.languageCode &&
                lang.countryCode == currentLocale.value.countryCode,
    );
    return current?.languageName ?? '中文简体';
  }

  /// 获取当前语言标志
  String getCurrentLanguageFlag() {
    final current = supportedLanguages.firstWhereOrNull(
      (lang) => lang.languageCode == currentLocale.value.languageCode &&
                lang.countryCode == currentLocale.value.countryCode,
    );
    return current?.flag ?? '🇨🇳';
  }

  /// 检查是否为当前语言
  bool isCurrentLanguage(String languageCode, String countryCode) {
    return currentLocale.value.languageCode == languageCode &&
           currentLocale.value.countryCode == countryCode;
  }

  /// 获取语言的本地化名称（根据当前语言显示）
  String getLocalizedLanguageName(LanguageModel language) {
    final isZh = currentLocale.value.languageCode == 'zh';
    if (isZh) {
      return language.languageName;
    } else {
      return language.englishName;
    }
  }

  /// 获取语言描述
  String getLanguageDescription(LanguageModel language) {
    final isZh = currentLocale.value.languageCode == 'zh';
    if (isZh) {
      return language.englishName;
    } else {
      return language.languageName;
    }
  }
}

/// 语言模型
class LanguageModel {
  final String languageCode;
  final String countryCode;
  final String languageName;
  final String englishName;
  final String flag;

  LanguageModel({
    required this.languageCode,
    required this.countryCode,
    required this.languageName,
    required this.englishName,
    required this.flag,
  });

  Locale get locale => Locale(languageCode, countryCode);
} 
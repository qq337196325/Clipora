import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inkwell/controller/language_controller.dart';
import 'package:inkwell/basics/translations/app_translations.dart';
import 'package:inkwell/basics/language_utils.dart';

void main() {
  setUpAll(() async {
    // 初始化 GetStorage（测试环境）
    await GetStorage.init();
    
    // 注册依赖
    Get.put(LanguageController());
    
    // 设置翻译
    Get.addTranslations(AppTranslations().keys);
  });

  tearDownAll(() {
    Get.reset();
  });

  group('LanguageController Tests', () {
    test('should initialize with default Chinese locale', () {
      final controller = Get.find<LanguageController>();
      expect(controller.currentLocale.value.languageCode, 'zh');
      expect(controller.currentLocale.value.countryCode, 'CN');
    });

    test('should change language correctly', () {
      final controller = Get.find<LanguageController>();
      
      // 切换到英文
      controller.changeLanguage('en', 'US');
      expect(controller.currentLocale.value.languageCode, 'en');
      expect(controller.currentLocale.value.countryCode, 'US');
      
      // 切换回中文
      controller.changeLanguage('zh', 'CN');
      expect(controller.currentLocale.value.languageCode, 'zh');
      expect(controller.currentLocale.value.countryCode, 'CN');
    });

    test('should detect current language correctly', () {
      final controller = Get.find<LanguageController>();
      
      controller.changeLanguage('zh', 'CN');
      expect(controller.isCurrentLanguage('zh', 'CN'), true);
      expect(controller.isCurrentLanguage('en', 'US'), false);
      
      controller.changeLanguage('en', 'US');
      expect(controller.isCurrentLanguage('en', 'US'), true);
      expect(controller.isCurrentLanguage('zh', 'CN'), false);
    });

    test('should return correct language names and flags', () {
      final controller = Get.find<LanguageController>();
      
      controller.changeLanguage('zh', 'CN');
      expect(controller.getCurrentLanguageName(), '中文简体');
      expect(controller.getCurrentLanguageFlag(), '🇨🇳');
      
      controller.changeLanguage('en', 'US');
      expect(controller.getCurrentLanguageName(), 'English');
      expect(controller.getCurrentLanguageFlag(), '🇺🇸');
    });
  });

  group('LanguageUtils Tests', () {
    test('should detect language correctly', () {
      Get.updateLocale(const Locale('zh', 'CN'));
      expect(LanguageUtils.isChinese(), true);
      expect(LanguageUtils.isEnglish(), false);
      expect(LanguageUtils.getCurrentLanguageCode(), 'zh');
      
      Get.updateLocale(const Locale('en', 'US'));
      expect(LanguageUtils.isChinese(), false);
      expect(LanguageUtils.isEnglish(), true);
      expect(LanguageUtils.getCurrentLanguageCode(), 'en');
    });

    test('should format file size correctly', () {
      expect(LanguageUtils.getFileSizeString(512), '512 B');
      expect(LanguageUtils.getFileSizeString(1024), '1.0 KB');
      expect(LanguageUtils.getFileSizeString(1024 * 1024), '1.0 MB');
      expect(LanguageUtils.getFileSizeString(1024 * 1024 * 1024), '1.0 GB');
    });

    test('should format count string correctly', () {
      Get.updateLocale(const Locale('zh', 'CN'));
      expect(LanguageUtils.getCountString(5, '项目'), '5 个项目');
      
      Get.updateLocale(const Locale('en', 'US'));
      expect(LanguageUtils.getCountString(1, 'item'), '1 item');
      expect(LanguageUtils.getCountString(5, 'item'), '5 items');
    });

    test('should format date time correctly', () {
      final testDate = DateTime(2024, 3, 15, 14, 30);
      
      Get.updateLocale(const Locale('zh', 'CN'));
      String chineseFormat = LanguageUtils.formatDateTime(testDate);
      expect(chineseFormat, contains('2024年3月15日'));
      expect(chineseFormat, contains('14:30'));
      
      Get.updateLocale(const Locale('en', 'US'));
      String englishFormat = LanguageUtils.formatDateTime(testDate);
      expect(englishFormat, contains('Mar 15, 2024'));
      expect(englishFormat, contains('14:30'));
    });
  });

  group('Translation Tests', () {
    test('should have translations for both languages', () {
      final translations = AppTranslations();
      
      // 检查中文翻译
      expect(translations.keys['zh_CN'], isNotNull);
      expect(translations.keys['zh_CN']!['confirm'], '确认');
      expect(translations.keys['zh_CN']!['cancel'], '取消');
      
      // 检查英文翻译
      expect(translations.keys['en_US'], isNotNull);
      expect(translations.keys['en_US']!['confirm'], 'Confirm');
      expect(translations.keys['en_US']!['cancel'], 'Cancel');
    });

    test('should translate text correctly', () {
      // 测试中文翻译
      Get.updateLocale(const Locale('zh', 'CN'));
      expect('confirm'.tr, '确认');
      expect('cancel'.tr, '取消');
      expect('save'.tr, '保存');
      
      // 测试英文翻译
      Get.updateLocale(const Locale('en', 'US'));
      expect('confirm'.tr, 'Confirm');
      expect('cancel'.tr, 'Cancel');
      expect('save'.tr, 'Save');
    });

    test('should have consistent translation keys', () {
      final translations = AppTranslations();
      final chineseKeys = translations.keys['zh_CN']!.keys.toSet();
      final englishKeys = translations.keys['en_US']!.keys.toSet();
      
      // 检查两种语言的翻译键是否一致
      expect(chineseKeys, equals(englishKeys));
    });
  });
} 
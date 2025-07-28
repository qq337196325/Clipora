#!/usr/bin/env dart

import 'dart:io';


/// i18n 完整性检查工具
/// 
/// 此脚本会检查所有语言的 i18n 文件，确保每个语言都包含中文版本中的所有 key
/// 
/// 使用方法：
/// dart tools/check_i18n_completeness.dart
/// 
/// 或者在项目根目录运行：
/// dart run tools/check_i18n_completeness.dart

void main() async {
  print('🔍 开始检查 i18n 文件完整性...\n');
  
  final i18nChecker = I18nCompletenessChecker();
  await i18nChecker.checkCompleteness();
}

class I18nCompletenessChecker {
  static const String i18nBasePath = 'lib/basics/translations';
  static const String chineseLocale = 'zh_cn';
  
  /// 检查所有语言的 i18n 完整性
  Future<void> checkCompleteness() async {
    try {
      // 1. 获取中文 i18n 文件作为基准
      final chineseKeys = await _getChineseI18nKeys();
      if (chineseKeys.isEmpty) {
        print('❌ 未找到中文 i18n 文件或文件为空');
        return;
      }
      
      print('📋 中文 i18n 基准文件统计:');
      chineseKeys.forEach((fileName, keys) {
        print('  $fileName: ${keys.length} 个 key');
      });
      print('');
      
      // 2. 获取所有其他语言目录
      final otherLocales = await _getOtherLocales();
      if (otherLocales.isEmpty) {
        print('❌ 未找到其他语言目录');
        return;
      }
      
      print('🌍 发现的其他语言: ${otherLocales.join(', ')}\n');
      
      // 3. 检查每个语言的完整性
      bool hasAnyMissingKeys = false;
      
      for (final locale in otherLocales) {
        final missingKeys = await _checkLocaleCompleteness(locale, chineseKeys);
        if (missingKeys.isNotEmpty) {
          hasAnyMissingKeys = true;
          _printMissingKeys(locale, missingKeys);
        } else {
          print('✅ $locale: 所有文件都完整');
        }
      }
      
      if (!hasAnyMissingKeys) {
        print('\n🎉 所有语言的 i18n 文件都完整！');
      } else {
        print('\n📝 请根据上述信息补充缺失的翻译 key');
      }
      
    } catch (e) {
      print('❌ 检查过程中出现错误: $e');
    }
  }
  
  /// 获取中文 i18n 的所有 key
  Future<Map<String, Set<String>>> _getChineseI18nKeys() async {
    final chineseDir = Directory('$i18nBasePath/$chineseLocale');
    if (!await chineseDir.exists()) {
      throw Exception('中文 i18n 目录不存在: ${chineseDir.path}');
    }
    
    final Map<String, Set<String>> allKeys = {};
    
    await for (final entity in chineseDir.list()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        if (fileName != '$chineseLocale.dart') { // 跳过主文件
          final keys = await _extractKeysFromFile(entity);
          if (keys.isNotEmpty) {
            allKeys[fileName] = keys;
          }
        }
      }
    }
    
    return allKeys;
  }
  
  /// 获取除中文外的所有语言目录
  Future<List<String>> _getOtherLocales() async {
    final i18nDir = Directory(i18nBasePath);
    if (!await i18nDir.exists()) {
      throw Exception('i18n 目录不存在: ${i18nDir.path}');
    }
    
    final List<String> locales = [];
    
    await for (final entity in i18nDir.list()) {
      if (entity is Directory) {
        final dirName = entity.path.split(Platform.pathSeparator).last;
        if (dirName != chineseLocale && 
            dirName != 'AI翻译文档' && 
            !dirName.startsWith('.')) {
          locales.add(dirName);
        }
      }
    }
    
    return locales..sort();
  }
  
  /// 检查指定语言的完整性
  Future<Map<String, Set<String>>> _checkLocaleCompleteness(
    String locale, 
    Map<String, Set<String>> chineseKeys
  ) async {
    final localeDir = Directory('$i18nBasePath/$locale');
    if (!await localeDir.exists()) {
      return {for (final entry in chineseKeys.entries) entry.key: entry.value};
    }
    
    final Map<String, Set<String>> missingKeys = {};
    
    for (final entry in chineseKeys.entries) {
      final fileName = entry.key;
      final expectedKeys = entry.value;
      
      final localeFile = File('${localeDir.path}/$fileName');
      if (!await localeFile.exists()) {
        // 整个文件都不存在
        missingKeys[fileName] = expectedKeys;
      } else {
        // 文件存在，检查缺失的 key
        final existingKeys = await _extractKeysFromFile(localeFile);
        final missing = expectedKeys.difference(existingKeys);
        if (missing.isNotEmpty) {
          missingKeys[fileName] = missing;
        }
      }
    }
    
    return missingKeys;
  }
  
  /// 从 Dart 文件中提取所有的 i18n key
  Future<Set<String>> _extractKeysFromFile(File file) async {
    try {
      final content = await file.readAsString();
      final Set<String> keys = {};
      
      // 使用正则表达式匹配 Map 中的 key
      // 匹配格式: 'key': 'value' 或 "key": "value"
      final keyRegex = RegExp(r'''['"]([^'"]+)['"]:\s*['"]''');
      final matches = keyRegex.allMatches(content);
      
      for (final match in matches) {
        final key = match.group(1);
        if (key != null && key.isNotEmpty) {
          keys.add(key);
        }
      }
      
      return keys;
    } catch (e) {
      print('⚠️  读取文件失败: ${file.path} - $e');
      return {};
    }
  }
  
  /// 打印缺失的 key
  void _printMissingKeys(String locale, Map<String, Set<String>> missingKeys) {
    print('❌ $locale 缺失的翻译:');
    
    for (final entry in missingKeys.entries) {
      final fileName = entry.key;
      final keys = entry.value;
      
      print('  📄 $fileName (缺失 ${keys.length} 个):');
      for (final key in keys.toList()..sort()) {
        print('    - $key');
      }
    }
    print('');
  }
}
#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// i18n 完整性检查工具 - 生成 JSON 报告版本
/// 
/// 此脚本会检查所有语言的 i18n 文件，生成详细的 JSON 报告
/// 
/// 使用方法：
/// dart tools/generate_i18n_report.dart [output_file]
/// 
/// 例如：
/// dart tools/generate_i18n_report.dart i18n_report.json

void main(List<String> args) async {
  print('🔍 开始生成 i18n 完整性报告...\n');
  
  final outputFile = args.isNotEmpty ? args[0] : 'i18n_report.json';
  
  final i18nChecker = I18nReportGenerator();
  await i18nChecker.generateReport(outputFile);
}

class I18nReportGenerator {
  static const String i18nBasePath = 'lib/basics/translations';
  static const String chineseLocale = 'zh_cn';
  
  /// 生成完整性报告
  Future<void> generateReport(String outputFile) async {
    try {
      // 1. 获取中文 i18n 文件作为基准
      final chineseKeys = await _getChineseI18nKeys();
      if (chineseKeys.isEmpty) {
        print('❌ 未找到中文 i18n 文件或文件为空');
        return;
      }
      
      // 2. 获取所有其他语言目录
      final otherLocales = await _getOtherLocales();
      if (otherLocales.isEmpty) {
        print('❌ 未找到其他语言目录');
        return;
      }
      
      // 3. 生成报告数据
      final report = await _generateReportData(chineseKeys, otherLocales);
      
      // 4. 保存 JSON 报告
      await _saveJsonReport(report, outputFile);
      
      // 5. 显示摘要
      _printSummary(report);
      
    } catch (e) {
      print('❌ 生成报告过程中出现错误: $e');
    }
  }
  
  /// 生成报告数据
  Future<Map<String, dynamic>> _generateReportData(
    Map<String, Set<String>> chineseKeys,
    List<String> otherLocales,
  ) async {
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'baseLocale': chineseLocale,
      'totalFiles': chineseKeys.length,
      'totalKeys': chineseKeys.values.fold(0, (sum, keys) => sum + keys.length),
      'locales': <String, dynamic>{},
      'summary': <String, dynamic>{},
    };
    
    // 统计每个语言的完整性
    final localeStats = <String, Map<String, dynamic>>{};
    
    for (final locale in otherLocales) {
      final missingKeys = await _checkLocaleCompleteness(locale, chineseKeys);
      final totalMissing = missingKeys.values.fold(0, (sum, keys) => sum + keys.length);
      final totalExpected = chineseKeys.values.fold(0, (sum, keys) => sum + keys.length);
      final completeness = ((totalExpected - totalMissing) / totalExpected * 100);
      
      localeStats[locale] = {
        'totalExpectedKeys': totalExpected,
        'totalMissingKeys': totalMissing,
        'completenessPercentage': double.parse(completeness.toStringAsFixed(2)),
        'missingByFile': missingKeys.map((file, keys) => MapEntry(file, keys.toList()..sort())),
        'filesWithMissingKeys': missingKeys.length,
        'completeFiles': chineseKeys.length - missingKeys.length,
      };
    }
    
    report['locales'] = localeStats;
    
    // 生成摘要统计
    final completenessValues = localeStats.values.map((stats) => stats['completenessPercentage'] as double);
    report['summary'] = {
      'totalLocales': otherLocales.length,
      'averageCompleteness': completenessValues.isNotEmpty 
          ? double.parse((completenessValues.reduce((a, b) => a + b) / completenessValues.length).toStringAsFixed(2))
          : 0.0,
      'fullyCompleteLocales': localeStats.values.where((stats) => stats['totalMissingKeys'] == 0).length,
      'localesNeedingWork': localeStats.values.where((stats) => stats['totalMissingKeys'] > 0).length,
    };
    
    return report;
  }
  
  /// 保存 JSON 报告
  Future<void> _saveJsonReport(Map<String, dynamic> report, String outputFile) async {
    final jsonString = JsonEncoder.withIndent('  ').convert(report);
    await File(outputFile).writeAsString(jsonString);
    print('📄 报告已保存到: $outputFile');
  }
  
  /// 打印摘要信息
  void _printSummary(Map<String, dynamic> report) {
    final summary = report['summary'] as Map<String, dynamic>;
    final locales = report['locales'] as Map<String, dynamic>;
    
    print('\n📊 i18n 完整性摘要:');
    print('  总语言数: ${summary['totalLocales']}');
    print('  平均完整度: ${summary['averageCompleteness']}%');
    print('  完全完整的语言: ${summary['fullyCompleteLocales']}');
    print('  需要补充的语言: ${summary['localesNeedingWork']}');
    
    print('\n🏆 完整度排行榜:');
    final sortedLocales = locales.entries.toList()
      ..sort((a, b) => (b.value['completenessPercentage'] as double)
          .compareTo(a.value['completenessPercentage'] as double));
    
    for (int i = 0; i < sortedLocales.length && i < 10; i++) {
      final entry = sortedLocales[i];
      final completeness = entry.value['completenessPercentage'];
      final missing = entry.value['totalMissingKeys'];
      final emoji = completeness == 100.0 ? '🎉' : completeness >= 90.0 ? '👍' : completeness >= 70.0 ? '⚠️' : '❌';
      print('  ${i + 1}. $emoji ${entry.key}: ${completeness}% (缺失 $missing 个)');
    }
  }
  
  // 以下方法与原脚本相同
  Future<Map<String, Set<String>>> _getChineseI18nKeys() async {
    final chineseDir = Directory('$i18nBasePath/$chineseLocale');
    if (!await chineseDir.exists()) {
      throw Exception('中文 i18n 目录不存在: ${chineseDir.path}');
    }
    
    final Map<String, Set<String>> allKeys = {};
    
    await for (final entity in chineseDir.list()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        if (fileName != '$chineseLocale.dart') {
          final keys = await _extractKeysFromFile(entity);
          if (keys.isNotEmpty) {
            allKeys[fileName] = keys;
          }
        }
      }
    }
    
    return allKeys;
  }
  
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
        missingKeys[fileName] = expectedKeys;
      } else {
        final existingKeys = await _extractKeysFromFile(localeFile);
        final missing = expectedKeys.difference(existingKeys);
        if (missing.isNotEmpty) {
          missingKeys[fileName] = missing;
        }
      }
    }
    
    return missingKeys;
  }
  
  Future<Set<String>> _extractKeysFromFile(File file) async {
    try {
      final content = await file.readAsString();
      final Set<String> keys = {};
      
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
}
#!/usr/bin/env dart

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

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔄 开始更新 Dart 文件中的许可证声明...');
  
  // 新的 AGPL-3.0 许可证声明
  final newLicense = '''// Copyright (c) 2025 Clipora.
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
// along with this program. If not, see <https://www.gnu.org/licenses/>.''';

  // 查找所有 .dart 文件
  final dartFiles = await findDartFiles(Directory('.'));
  
  if (dartFiles.isEmpty) {
    print('❌ 没有找到 .dart 文件');
    return;
  }
  
  print('📁 找到 ${dartFiles.length} 个 Dart 文件');
  
  int updatedCount = 0;
  int skippedCount = 0;
  
  for (final file in dartFiles) {
    try {
      final content = await file.readAsString();
      
      // 检查是否包含 Creative Commons 许可证
      if (content.contains('Creative Commons Attribution-NonCommercial-NoDerivatives')) {
        // 使用正则表达式匹配并替换整个许可证块
        final updatedContent = replaceLicenseBlock(content, newLicense);
        
        if (updatedContent != content) {
          await file.writeAsString(updatedContent);
          print('✅ 已更新: ${file.path}');
          updatedCount++;
        } else {
          print('⚠️  无法自动更新: ${file.path} (许可证格式特殊)');
          skippedCount++;
        }
      } else if (content.contains('GNU Affero General Public License')) {
        print('⏭️  已是 AGPL: ${file.path}');
        skippedCount++;
      } else {
        print('⏭️  跳过: ${file.path} (未找到许可证)');
        skippedCount++;
      }
    } catch (e) {
      print('❌ 处理文件失败: ${file.path} - $e');
    }
  }
  
  print('\n📊 处理完成:');
  print('   ✅ 已更新: $updatedCount 个文件');
  print('   ⏭️  跳过: $skippedCount 个文件');
  print('   📁 总计: ${dartFiles.length} 个文件');
  
  if (updatedCount > 0) {
    print('\n🎉 许可证更新完成！所有文件现在使用 AGPL-3.0 许可证。');
  }
}

/// 替换许可证块
String replaceLicenseBlock(String content, String newLicense) {
  // 匹配从 "// Copyright" 开始到空行或非注释行结束的许可证块
  final licensePattern = RegExp(
    r'^// Copyright.*?(?=\n\n|\n[^/]|\n$|\Z)',
    multiLine: true,
    dotAll: true,
  );
  
  final match = licensePattern.firstMatch(content);
  if (match != null) {
    // 替换找到的许可证块
    return content.replaceFirst(licensePattern, newLicense);
  }
  
  return content;
}

/// 递归查找所有 .dart 文件
Future<List<File>> findDartFiles(Directory dir) async {
  final List<File> dartFiles = [];
  
  try {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        // 排除一些不需要处理的目录
        if (!entity.path.contains('.dart_tool') && 
            !entity.path.contains('build') &&
            !entity.path.contains('.git')) {
          dartFiles.add(entity);
        }
      }
    }
  } catch (e) {
    print('❌ 扫描目录失败: ${dir.path} - $e');
  }
  
  return dartFiles;
}
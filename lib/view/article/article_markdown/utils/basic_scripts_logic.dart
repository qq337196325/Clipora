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



import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../basics/logger.dart';


class BasicScriptsLogic {
  final InAppWebViewController controller;

  BasicScriptsLogic(this.controller);



  Future<void> injectBasicScripts(InAppWebViewController webViewController) async {
    try {
      // 注入marked.js
      final markedScript = await rootBundle.loadString('assets/js/marked.min.js');
      await webViewController.evaluateJavascript(source: markedScript);

      // 注入highlight.js
      final highlightScript = await rootBundle.loadString('assets/js/highlight.min.js');
      await webViewController.evaluateJavascript(source: highlightScript);

      // 配置marked
      await webViewController.evaluateJavascript(source: '''
        if (typeof marked !== 'undefined') {
          marked.setOptions({
            highlight: function(code, lang) {
              if (typeof hljs !== 'undefined') {
                if (lang && hljs.getLanguage(lang)) {
                  try {
                    return hljs.highlight(code, { language: lang }).value;
                  } catch (err) { return code; }
                }
                return hljs.highlightAuto(code).value;
              }
              return code;
            },
            langPrefix: 'hljs language-',
            breaks: true,
            gfm: true
          });
        }
      ''');

      getLogger().d('✅ 基础脚本注入完成');
    } catch (e) {
      getLogger().e('❌ 注入基础脚本失败: $e');
    }
  }


  /// 注入Range标注引擎脚本
  Future<bool> injectRangeAnnotationScript() async {
    try {
      getLogger().d('🔄 开始注入Range标注引擎...');

      // 加载和注入脚本
      final script = await rootBundle.loadString('assets/js/range_annotation_engine.js');
      await controller.evaluateJavascript(source: script);

      // 验证引擎是否可用
      final isAvailable = await isRangeEngineAvailable();
      if (isAvailable) {
        getLogger().i('✅ Range标注引擎注入成功');
        return true;
      } else {
        getLogger().e('❌ Range标注引擎注入失败 - 引擎不可用');
        return false;
      }
    } catch (e) {
      getLogger().e('❌ 注入Range标注引擎失败: $e');
      return false;
    }
  }

  /// 检查Range引擎是否可用
  Future<bool> isRangeEngineAvailable() async {
    try {
      final result = await controller.evaluateJavascript(source: '''
        (function() {
          return typeof window.rangeAnnotationEngine !== 'undefined' && 
                 window.rangeAnnotationEngine.isInitialized === true;
        })();
      ''');

      return result == true;
    } catch (e) {
      getLogger().e('❌ 检查Range引擎可用性失败: $e');
      return false;
    }
  }

  /// 创建高亮标注
  Future<bool> createHighlight(
      Map<String, dynamic> rangeData,
      String highlightId,
      String colorType, {
        String? noteContent,
      }) async {
    try {
      if (!await isRangeEngineAvailable()) {
        getLogger().w('⚠️ Range引擎不可用，无法创建高亮');
        return false;
      }

      final jsCode = '''
        (function() {
          try {
            const rangeData = ${jsonEncode(rangeData)};
            const result = window.rangeAnnotationEngine.createHighlight(
              rangeData,
              '$highlightId',
              '$colorType',
              ${noteContent != null ? "'$noteContent'" : 'null'}
            );
            console.log('创建高亮结果:', result);
            return result;
          } catch (error) {
            console.error('创建高亮异常:', error);
            return false;
          }
        })();
      ''';

      final result = await controller.evaluateJavascript(source: jsCode);
      final success = result == true;

      if (success) {
        getLogger().i('✅ 高亮创建成功: $highlightId');
      } else {
        getLogger().e('❌ 高亮创建失败: $highlightId');
      }

      return success;
    } catch (e) {
      getLogger().e('❌ 创建高亮异常: $e');
      return false;
    }
  }


  /// 清理所有标注
  Future<bool> clearAllAnnotations() async {
    try {
      if (!await isRangeEngineAvailable()) {
        getLogger().w('⚠️ Range引擎不可用，无法清理标注');
        return false;
      }

      final jsCode = '''
        (function() {
          try {
            // 清理所有高亮元素
            const highlights = document.querySelectorAll('[data-highlight-id]');
            highlights.forEach(element => {
              const parent = element.parentNode;
              while (element.firstChild) {
                parent.insertBefore(element.firstChild, element);
              }
              parent.removeChild(element);
            });
            
            // 清理引擎状态
            if (window.rangeAnnotationEngine) {
              window.rangeAnnotationEngine.annotations.clear();
            }
            
            console.log('清理了', highlights.length, '个标注');
            return true;
          } catch (error) {
            console.error('清理标注异常:', error);
            return false;
          }
        })();
      ''';

      final result = await controller.evaluateJavascript(source: jsCode);
      final success = result == true;

      if (success) {
        getLogger().i('✅ 标注清理成功');
      } else {
        getLogger().e('❌ 标注清理失败');
      }

      return success;
    } catch (e) {
      getLogger().e('❌ 清理标注异常: $e');
      return false;
    }
  }


  /// 删除高亮标注
  Future<bool> removeHighlight(String highlightId) async {
    try {
      if (!await isRangeEngineAvailable()) {
        getLogger().w('⚠️ Range引擎不可用，无法删除高亮');
        return false;
      }

      final jsCode = '''
        (function() {
          try {
            const result = window.rangeAnnotationEngine.removeHighlight('$highlightId');
            console.log('删除高亮结果:', result);
            return result;
          } catch (error) {
            console.error('删除高亮异常:', error);
            return false;
          }
        })();
      ''';

      final result = await controller.evaluateJavascript(source: jsCode);
      final success = result == true;

      if (success) {
        getLogger().i('✅ 高亮删除成功: $highlightId');
      } else {
        getLogger().e('❌ 高亮删除失败: $highlightId');
      }

      return success;
    } catch (e) {
      getLogger().e('❌ 删除高亮异常: $e');
      return false;
    }
  }


  /// 批量恢复标注
  Future<Map<String, int>> batchRestoreAnnotations(List<Map<String, dynamic>> annotations) async {
    try {
      if (!await isRangeEngineAvailable()) {
        getLogger().w('⚠️ Range引擎不可用，无法批量恢复标注');
        return {'successCount': 0, 'failCount': annotations.length};
      }

      getLogger().i('🔄 开始批量恢复 ${annotations.length} 个标注...');

      final jsCode = '''
        (function() {
          try {
            const annotations = ${jsonEncode(annotations)};
            const result = window.rangeAnnotationEngine.batchRestore(annotations);
            console.log('批量恢复结果:', result);
            return result;
          } catch (error) {
            console.error('批量恢复异常:', error);
            return { successCount: 0, failCount: ${annotations.length} };
          }
        })();
      ''';

      final result = await controller.evaluateJavascript(source: jsCode);

      Map<String, int> stats;
      if (result is Map) {
        stats = {
          'successCount': (result['successCount'] ?? 0) as int,
          'failCount': (result['failCount'] ?? 0) as int,
        };
      } else {
        stats = {'successCount': 0, 'failCount': annotations.length};
      }

      getLogger().i('✅ 批量恢复完成: 成功 ${stats['successCount']}, 失败 ${stats['failCount']}');
      return stats;
    } catch (e) {
      getLogger().e('❌ 批量恢复标注异常: $e');
      return {'successCount': 0, 'failCount': annotations.length};
    }
  }


  /// 恢复单个标注
  Future<bool> restoreAnnotation(Map<String, dynamic> rangeData) async {
    try {
      if (!await isRangeEngineAvailable()) {
        getLogger().w('⚠️ Range引擎不可用，无法恢复标注');
        return false;
      }

      final jsCode = '''
        (function() {
          try {
            const rangeData = ${jsonEncode(rangeData)};
            const result = window.rangeAnnotationEngine.restoreAnnotation(rangeData);
            console.log('恢复标注结果:', result);
            return result;
          } catch (error) {
            console.error('恢复标注异常:', error);
            return false;
          }
        })();
      ''';

      final result = await controller.evaluateJavascript(source: jsCode);
      final success = result == true;

      if (success) {
        getLogger().d('✅ 标注恢复成功: ${rangeData['highlightId']}');
      } else {
        getLogger().w('⚠️ 标注恢复失败: ${rangeData['highlightId']}');
      }

      return success;
    } catch (e) {
      getLogger().e('❌ 恢复标注异常: $e');
      return false;
    }
  }

  /// 更新高亮颜色
  Future<bool> updateHighlightColor(String highlightId, String newColorClass) async {
    try {
      if (!await isRangeEngineAvailable()) {
        getLogger().w('⚠️ Range引擎不可用，无法更新高亮颜色');
        return false;
      }

      final jsCode = '''
        (function() {
          try {
            // 确保引擎已初始化
            if (!window.rangeAnnotationEngine) {
              console.error('Range引擎未初始化');
              return false;
            }
            
            // 检查方法是否存在
            if (typeof window.rangeAnnotationEngine.updateHighlightColor !== 'function') {
              console.error('updateHighlightColor方法不存在');
              return false;
            }
            
            const result = window.rangeAnnotationEngine.updateHighlightColor('$highlightId', '$newColorClass');
            console.log('更新高亮颜色结果:', result);
            return result;
          } catch (error) {
            console.error('更新高亮颜色异常:', error);
            return false;
          }
        })();
      ''';

      final result = await controller.evaluateJavascript(source: jsCode);
      final success = result == true;

      if (success) {
        getLogger().i('✅ 高亮颜色更新成功: $highlightId -> $newColorClass');
      } else {
        getLogger().e('❌ 高亮颜色更新失败: $highlightId -> $newColorClass');
      }

      return success;
    } catch (e) {
      getLogger().e('❌ 更新高亮颜色异常: $e');
      return false;
    }
  }

  /// 传统资源设置方法
  Future<void> setupTraditionalResources() async {
    getLogger().i('🔧 使用传统方式加载资源...');
    try {
      // 加载CSS
      final css = await rootBundle.loadString('assets/js/typora_github.css');
      await controller.evaluateJavascript(source: '''
        var style = document.createElement('style');
        style.textContent = `$css`;
        document.head.appendChild(style);
      ''');

      getLogger().i('✅ 传统方式资源加载完成');
    } catch (e) {
      getLogger().e('❌ 传统方式资源加载失败: $e');
    }
  }

}







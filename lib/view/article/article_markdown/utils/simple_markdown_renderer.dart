// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../basics/logger.dart';

/// 简单的Markdown渲染器
/// 替代复杂的WebViewPoolManager渲染逻辑，提供更可靠的维护性
class SimpleMarkdownRenderer {
  /// 渲染Markdown内容到WebView
  /// 
  /// [controller] WebView控制器
  /// [markdownContent] 要渲染的Markdown内容
  /// [paddingStyle] 可选的内边距样式
  static Future<bool> renderMarkdown(
    InAppWebViewController controller,
    String markdownContent, {
    String paddingStyle = '',
  }) async {
    if (markdownContent.isEmpty) {
      getLogger().w('⚠️ Markdown内容为空，跳过渲染');
      return false;
    }

    try {
      getLogger().i('🎨 开始渲染Markdown内容...');
      
      // 转义特殊字符，防止JavaScript注入
      final escapedMarkdown = _escapeForJavaScript(markdownContent);
      
      // 应用内边距样式（如果提供）
      if (paddingStyle.isNotEmpty) {
        await _applyPaddingStyle(controller, paddingStyle);
      }
      
      // 渲染Markdown内容
      final renderSuccess = await controller.evaluateJavascript(source: '''
        (function() {
          try {
            console.log('🎨 开始渲染Markdown...');
            
            // 检查renderMarkdown函数是否可用
            if (typeof renderMarkdown === 'function') {
              const success = renderMarkdown(`$escapedMarkdown`);
              if (success) {
                console.log('✅ 使用内置renderMarkdown函数渲染成功');
                return true;
              }
            }
            
            // 降级到基础渲染
            console.log('🔄 降级到基础Markdown渲染...');
            return fallbackRender(`$escapedMarkdown`);
            
          } catch (error) {
            console.error('❌ Markdown渲染失败:', error);
            return false;
          }
        })();
        
        // 基础降级渲染函数
        function fallbackRender(markdown) {
          try {
            const contentElement = document.getElementById('content');
            if (!contentElement) {
              console.error('❌ 找不到content元素');
              return false;
            }
            
            // 简单的Markdown到HTML转换（如果marked不可用）
            if (typeof marked !== 'undefined') {
              contentElement.innerHTML = marked.parse(markdown);
            } else {
              // 最基础的文本显示（作为最后的降级方案）
              const pre = document.createElement('pre');
              pre.style.cssText = 'white-space: pre-wrap; word-wrap: break-word; font-family: inherit;';
              pre.textContent = markdown;
              contentElement.innerHTML = '';
              contentElement.appendChild(pre);
            }
            
            // 处理图片点击事件
            setupImageClickHandlers();
            
            console.log('✅ 基础渲染完成');
            return true;
          } catch (error) {
            console.error('❌ 基础渲染失败:', error);
            return false;
          }
        }
        
        // 设置图片点击处理
        function setupImageClickHandlers() {
          try {
            const images = document.querySelectorAll('#content img');
            images.forEach(img => {
              img.addEventListener('click', function() {
                if (window.flutter_inappwebview) {
                  window.flutter_inappwebview.callHandler('onImageClick', {
                    src: this.src,
                    alt: this.alt || ''
                  });
                }
              });
            });
          } catch (error) {
            console.warn('⚠️ 图片点击处理设置失败:', error);
          }
        }
      ''');

      if (renderSuccess == true) {
        getLogger().i('✅ Markdown渲染成功');
        return true;
      } else {
        getLogger().w('⚠️ Markdown渲染失败，但不抛出异常');
        return false;
      }
      
    } catch (e) {
      getLogger().e('❌ Markdown渲染过程中发生异常: $e');
      return false;
    }
  }
  
  /// 应用内边距样式
  static Future<void> _applyPaddingStyle(
    InAppWebViewController controller,
    String paddingStyle,
  ) async {
    try {
      await controller.evaluateJavascript(source: '''
        (function() {
          console.log('📐 应用内边距样式...');
          const contentElement = document.getElementById('content');
          if (contentElement && '$paddingStyle'.trim()) {
            contentElement.style.cssText += '; $paddingStyle';
            console.log('✅ 内边距样式应用成功');
          }
        })();
      ''');
    } catch (e) {
      getLogger().w('⚠️ 内边距样式应用失败: $e');
    }
  }
  
  /// 转义JavaScript字符串中的特殊字符
  static String _escapeForJavaScript(String text) {
    return text
        .replaceAll('\\', '\\\\')  // 反斜杠
        .replaceAll('`', '\\`')    // 反引号
        .replaceAll('\$', '\\\$')  // 美元符号
        .replaceAll('\r\n', '\\n') // Windows换行符
        .replaceAll('\r', '\\n')   // Mac换行符
        .replaceAll('\n', '\\n');  // Unix换行符
  }
  
  /// 设置WebView基础配置
  /// 简单的一次性配置，不需要复杂的状态管理
  static Future<void> setupBasicWebView(InAppWebViewController controller) async {
    try {
      getLogger().i('🔧 设置基础WebView配置...');
      
      // 等待DOM准备就绪
      await _waitForDOMReady(controller);
      
      // 确保背景透明
      await controller.evaluateJavascript(source: '''
        document.body.style.backgroundColor = 'transparent';
        document.documentElement.style.backgroundColor = 'transparent';
        console.log('✅ 背景透明设置完成');
      ''');
      
      // 注册图片点击处理器
      controller.addJavaScriptHandler(
        handlerName: 'onImageClick',
        callback: (args) {
          getLogger().d('🖼️ 图片被点击: ${args.first}');
          // 这里可以添加图片点击的具体处理逻辑   TODO: 这里可以加个查看和下载图片的功能
        },
      );
      
      getLogger().i('✅ 基础WebView配置完成');
      
    } catch (e) {
      getLogger().e('❌ 基础WebView配置失败: $e');
      rethrow;
    }
  }
  
  /// 等待DOM准备就绪
  static Future<void> _waitForDOMReady(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: '''
        (function() {
          return new Promise((resolve) => {
            if (document.readyState === 'complete') {
              resolve();
            } else {
              window.addEventListener('load', resolve);
            }
          });
        })();
      ''');
      getLogger().d('✅ DOM已准备就绪');
    } catch (e) {
      getLogger().w('⚠️ 等待DOM就绪失败，继续执行: $e');
    }
  }
  
  /// 滚动到指定位置
  static Future<void> scrollToPosition(
    InAppWebViewController controller,
    int x,
    int y,
  ) async {
    try {
      await controller.scrollTo(x: x, y: y);
      getLogger().d('📍 滚动到位置: ($x, $y)');
    } catch (e) {
      getLogger().w('⚠️ 滚动到指定位置失败: $e');
    }
  }
  
  /// 获取当前滚动位置
  static Future<Map<String, int>?> getCurrentScrollPosition(
    InAppWebViewController controller,
  ) async {
    try {
      final result = await controller.evaluateJavascript(source: '''
        ({
          x: window.pageXOffset || document.documentElement.scrollLeft,
          y: window.pageYOffset || document.documentElement.scrollTop
        });
      ''');
      
      if (result is Map) {
        return {
          'x': (result['x'] as num?)?.toInt() ?? 0,
          'y': (result['y'] as num?)?.toInt() ?? 0,
        };
      }
    } catch (e) {
      getLogger().w('⚠️ 获取滚动位置失败: $e');
    }
    return null;
  }
} 
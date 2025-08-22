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

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../basics/logger.dart';
import 'package:clipora/view/article/article_markdown/utils/basic_scripts_logic.dart';

/// WebView DOM注入管理器
/// 集中管理所有JavaScript注入逻辑，避免组件内过多碎片化代码
class WebViewInjectionManager {
  final InAppWebViewController _controller;
  bool _handlersRegistered = false;

  WebViewInjectionManager(this._controller);

  /// 一次性设置所有事件监听器和处理器
  /// 
  /// [onEnhancedTextSelected] 增强文本选择回调
  /// [onSelectionCleared] 选择清除回调
  /// [onHighlightClicked] 高亮点击回调
  /// [onPageClicked] 页面点击回调
  Future<void> setupAllEventHandlers({
    required Function(List<dynamic> args) onEnhancedTextSelected,
    required Function(List<dynamic> args) onSelectionCleared,
    required Function(List<dynamic> args) onHighlightClicked,
    required Function(List<dynamic> args) onPageClicked,
  }) async {
    try {
      getLogger().d('🔧 开始设置WebView事件处理器...');

      // 避免重复注册
      if (_handlersRegistered) {
        getLogger().w('⚠️ 事件处理器已注册，跳过重复设置');
        return;
      }

      // 1. 注册JavaScript处理器
      await _registerJavaScriptHandlers(
        onEnhancedTextSelected: onEnhancedTextSelected,
        onSelectionCleared: onSelectionCleared,
        onHighlightClicked: onHighlightClicked,
        onPageClicked: onPageClicked,
      );

      // 2. 注入DOM事件监听器
      await _injectDOMEventListeners();

      // 3. 验证桥接可用性
      await _verifyJavaScriptBridge();

      _handlersRegistered = true;
      getLogger().i('✅ WebView事件处理器设置完成');

    } catch (e) {
      getLogger().e('❌ 设置WebView事件处理器失败: $e');
      rethrow;
    }
  }

  /// 统一注入基础脚本（marked.js、highlight.js）与 Range 标注引擎
  /// 返回 Range 引擎是否注入成功
  Future<bool> injectCoreScripts() async {
    try {
      getLogger().d('🔧 开始注入核心脚本（marked、highlight、Range引擎）...');
      final basic = BasicScriptsLogic(_controller);

      // 注入基础脚本（marked.js、highlight.js）
      await basic.injectBasicScripts(_controller);

      // 注入 Range 标注引擎
      final ok = await basic.injectRangeAnnotationScript();
      getLogger().d('🔥 Range引擎注入结果: $ok');

      return ok;
    } catch (e) {
      getLogger().e('❌ 注入核心脚本失败: $e');
      return false;
    }
  }

  /// 一次性设置事件处理器并注入核心脚本（入口方法）
  /// 返回核心脚本（尤其是 Range 引擎）是否注入成功
  Future<bool> initializeAll({
    required Function(List<dynamic> args) onEnhancedTextSelected,
    required Function(List<dynamic> args) onSelectionCleared,
    required Function(List<dynamic> args) onHighlightClicked,
    required Function(List<dynamic> args) onPageClicked,
  }) async {
    try {
      getLogger().d('🚀 初始化 WebView：注册事件处理器并注入核心脚本');

      // 1) 先注册事件处理器与 DOM 监听器
      await setupAllEventHandlers(
        onEnhancedTextSelected: onEnhancedTextSelected,
        onSelectionCleared: onSelectionCleared,
        onHighlightClicked: onHighlightClicked,
        onPageClicked: onPageClicked,
      );

      // 2) 再注入核心脚本
      final ok = await injectCoreScripts();
      getLogger().d('✅ 初始化完成，脚本注入结果: $ok');
      return ok;
    } catch (e) {
      getLogger().e('❌ 初始化 WebView 失败: $e');
      return false;
    }
  }

  /// 注册JavaScript处理器
  Future<void> _registerJavaScriptHandlers({
    required Function(List<dynamic> args) onEnhancedTextSelected,
    required Function(List<dynamic> args) onSelectionCleared,
    required Function(List<dynamic> args) onHighlightClicked,
    required Function(List<dynamic> args) onPageClicked,
  }) async {
    try {
      getLogger().d('🔄 注册JavaScript处理器...');

      // 增强文本选择处理器
      _controller.addJavaScriptHandler(
        handlerName: 'onEnhancedTextSelected',
        callback: onEnhancedTextSelected,
      );
      getLogger().d('✅ 已注册: onEnhancedTextSelected');

      // 选择清除处理器
      _controller.addJavaScriptHandler(
        handlerName: 'onEnhancedSelectionCleared',
        callback: onSelectionCleared,
      );
      getLogger().d('✅ 已注册: onEnhancedSelectionCleared');

      // 高亮点击处理器
      _controller.addJavaScriptHandler(
        handlerName: 'onHighlightClicked',
        callback: onHighlightClicked,
      );
      getLogger().d('✅ 已注册: onHighlightClicked');

      // 页面点击处理器
      _controller.addJavaScriptHandler(
        handlerName: 'onPageClicked',
        callback: onPageClicked,
      );
      getLogger().d('✅ 已注册: onPageClicked');

      // 测试处理器（用于验证桥接）
      _controller.addJavaScriptHandler(
        handlerName: 'testHandler',
        callback: (args) {
          getLogger().d('✅ 测试Handler被成功调用: $args');
        },
      );

      getLogger().i('✅ JavaScript处理器注册完成');

    } catch (e) {
      getLogger().e('❌ 注册JavaScript处理器失败: $e');
      rethrow;
    }
  }

  /// 注入DOM事件监听器
  Future<void> _injectDOMEventListeners() async {
    try {
      getLogger().d('🔄 注入DOM事件监听器...');

      await Future.wait([
        _injectPageClickListener(),
        _injectHighlightClickListener(),
      ]);

      getLogger().i('✅ DOM事件监听器注入完成');

    } catch (e) {
      getLogger().e('❌ 注入DOM事件监听器失败: $e');
      rethrow;
    }
  }

  /// 注入页面点击监听器
  Future<void> _injectPageClickListener() async {
    try {
      await _controller.evaluateJavascript(source: '''
        (function() {
          // 防止重复注册
          if (window.pageClickListenerInstalled) {
            console.log('⚠️ 页面点击监听器已存在，跳过重复注册');
            return;
          }
          
          // 添加全局点击事件监听器
          document.addEventListener('click', function(e) {
            try {
              // 检查点击的是否为标注元素
              const highlightElement = e.target.closest('[data-highlight-id]');
              
              if (!highlightElement) {
                // 不是标注元素，触发页面点击事件
                console.log('🎯 检测到页面点击');
                
                // 调用Flutter Handler
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                  window.flutter_inappwebview.callHandler('onPageClicked', {
                    timestamp: Date.now(),
                    target: e.target.tagName
                  });
                  console.log('✅ 页面点击数据已发送到Flutter');
                } else {
                  console.error('❌ Flutter桥接不可用，无法发送页面点击数据');
                }
              }
            } catch (error) {
              console.error('❌ 处理页面点击异常:', error);
            }
          }, false);
          
          // 标记监听器已安装
          window.pageClickListenerInstalled = true;
          console.log('✅ 页面点击监听器安装完成');
          
        })();
      ''');

      getLogger().d('✅ 页面点击监听脚本注入成功');

    } catch (e) {
      getLogger().e('❌ 注入页面点击监听脚本失败: $e');
      rethrow;
    }
  }

  /// 注入高亮点击监听器
  Future<void> _injectHighlightClickListener() async {
    try {
      await _controller.evaluateJavascript(source: '''
        (function() {
          // 防止重复注册
          if (window.highlightClickListenerInstalled) {
            console.log('⚠️ 标注点击监听器已存在，跳过重复注册');
            return;
          }
          
          // 添加全局点击事件监听器（事件委托方式）
          document.addEventListener('click', function(e) {
            try {
              // 查找点击的是否为标注元素或其子元素
              const highlightElement = e.target.closest('[data-highlight-id]');
              
              if (highlightElement) {
                // 阻止默认行为和事件冒泡
                e.preventDefault();
                e.stopPropagation();
                
                console.log('🎯 检测到标注点击:', highlightElement);
                
                // 提取标注信息
                const highlightId = highlightElement.dataset.highlightId;
                const content = highlightElement.textContent || '';
                const highlightType = highlightElement.dataset.type || 'highlight';
                const colorClass = highlightElement.className || '';
                
                // 获取元素位置信息
                const rect = highlightElement.getBoundingClientRect();
                const boundingRect = {
                  x: rect.left,
                  y: rect.top,
                  width: rect.width,
                  height: rect.height,
                  centerX: rect.left + rect.width / 2,
                  centerY: rect.top + rect.height / 2
                };
                
                // 构建标注数据
                const highlightData = {
                  highlightId: highlightId,
                  content: content,
                  type: highlightType,
                  colorClass: colorClass,
                  boundingRect: boundingRect,
                  timestamp: Date.now()
                };
                
                console.log('🎯 标注数据:', highlightData);
                
                // 调用Flutter Handler
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                  window.flutter_inappwebview.callHandler('onHighlightClicked', highlightData);
                  console.log('✅ 标注点击数据已发送到Flutter');
                } else {
                  console.error('❌ Flutter桥接不可用，无法发送标注点击数据');
                }
              }
            } catch (error) {
              console.error('❌ 处理标注点击异常:', error);
            }
          }, false);
          
          // 标记监听器已安装
          window.highlightClickListenerInstalled = true;
          console.log('✅ 标注点击监听器安装完成');
          
        })();
      ''');

      getLogger().d('✅ 高亮点击监听脚本注入成功');

    } catch (e) {
      getLogger().e('❌ 注入高亮点击监听脚本失败: $e');
      rethrow;
    }
  }

  /// 验证JavaScript桥接
  Future<void> _verifyJavaScriptBridge() async {
    try {
      getLogger().d('🔄 验证JavaScript桥接...');

      // 检查flutter_inappwebview桥接是否可用
      final bridgeAvailable = await _controller.evaluateJavascript(source: '''
        (function() {
          const available = typeof window.flutter_inappwebview !== 'undefined' && 
                           typeof window.flutter_inappwebview.callHandler === 'function';
          console.log('🔍 Flutter桥接可用性:', available);
          return available;
        })();
      ''');

      getLogger().d('🔍 Flutter桥接可用: $bridgeAvailable');

      // 从JavaScript端调用测试Handler
      await _controller.evaluateJavascript(source: '''
        (function() {
          console.log('🧪 测试调用Flutter Handler...');
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('testHandler', 'bridge_test_successful');
          } else {
            console.error('❌ Flutter桥接不可用');
          }
        })();
      ''');

      getLogger().i('✅ JavaScript桥接验证完成');

    } catch (e) {
      getLogger().e('❌ 验证JavaScript桥接失败: $e');
    }
  }

  /// 注入主题色到WebView
  /// 
  /// [backgroundColor] 背景色
  /// [textColor] 文本色
  Future<void> injectThemeColors({
    required String backgroundColor,
    required String textColor,
  }) async {
    try {
      await _controller.evaluateJavascript(source: '''
        document.documentElement.style.setProperty('--background-color', '$backgroundColor');
        document.documentElement.style.setProperty('--text-color', '$textColor');
        document.body.style.backgroundColor = '$backgroundColor';
        document.body.style.color = '$textColor';
      ''');

      getLogger().d('✅ 主题色注入完成: bg=$backgroundColor, text=$textColor');

    } catch (e) {
      getLogger().e('❌ 注入主题色失败: $e');
    }
  }

  /// 清理所有事件监听器（如果需要）
  Future<void> cleanup() async {
    try {
      await _controller.evaluateJavascript(source: '''
        (function() {
          // 移除事件监听器标记，允许重新注册
          window.pageClickListenerInstalled = false;
          window.highlightClickListenerInstalled = false;
          console.log('🗑️ 事件监听器清理完成');
        })();
      ''');

      _handlersRegistered = false;
      getLogger().d('🗑️ WebView注入管理器清理完成');

    } catch (e) {
      getLogger().e('❌ 清理WebView注入管理器失败: $e');
    }
  }
}
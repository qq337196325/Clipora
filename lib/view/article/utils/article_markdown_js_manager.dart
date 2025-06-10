import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../basics/logger.dart';

/// 管理文章详情页中与WebView JavaScript交互的所有逻辑。
///
/// 负责注入、调用和处理来自JS脚本的事件，涵盖了
/// 阅读位置追踪、文本选择、高亮、笔记等功能。
class ArticleMarkdownJsManager {
  final InAppWebViewController _controller;

  ArticleMarkdownJsManager(this._controller);

  /// 注入所有必需的JavaScript脚本。
  Future<void> injectAllScripts() async {
    await _injectPositionTracker();
    await _injectTextSelectionScript();
  }

  /// 注入精确定位追踪脚本。
  Future<void> _injectPositionTracker() async {
    try {
      final jsCode = await rootBundle.loadString('assets/js/article_position_tracker.js');
      await _controller.evaluateJavascript(source: jsCode);
      getLogger().i('✅ 精确定位追踪脚本注入成功');
    } catch (e) {
      getLogger().e('❌ 精确定位追踪脚本注入失败: $e');
    }
  }

  /// 注入文字选择处理脚本。
  Future<void> _injectTextSelectionScript() async {
    try {
      final jsCode = await rootBundle.loadString('assets/js/article_text_selector.js');
      await _controller.evaluateJavascript(source: jsCode);
      getLogger().i('✅ 文字选择处理脚本注入成功');
    } catch (e) {
      getLogger().e('❌ 文字选择处理脚本注入失败: $e');
    }
  }

  /// 调用JS函数高亮选中的文本。
  Future<void> highlightSelection(String color) async {
    await _controller.evaluateJavascript(source: '''
      if (window.flutter_text_selector) {
        window.flutter_text_selector.highlightSelection('$color');
      }
    ''');
  }

  /// 调用JS函数为选中的文本添加笔记。
  Future<void> addNoteToSelection(String noteText) async {
    final escapedNote = noteText.replaceAll("'", "\\'").replaceAll("\n", "\\n");
    await _controller.evaluateJavascript(source: '''
      if (window.flutter_text_selector) {
        window.flutter_text_selector.addNoteToSelection('$escapedNote');
      }
    ''');
  }

  /// 检查JavaScript追踪器是否可用。
  Future<bool> isPositionTrackerAvailable() async {
    try {
      final result = await _controller.evaluateJavascript(
        source: 'typeof window.flutter_reading_tracker !== "undefined"'
      );
      return result == true;
    } catch (e) {
      getLogger().w('⚠️ 检查PositionTracker可用性时出错: $e');
      return false;
    }
  }

  /// 获取当前可见元素的信息。
  Future<Map<String, dynamic>?> getCurrentVisibleElement() async {
    try {
      final result = await _controller.evaluateJavascript(
        source: 'window.flutter_reading_tracker ? window.flutter_reading_tracker.getCurrentVisibleElement() : null'
      );
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      getLogger().e('❌ 获取可见元素信息失败: $e');
      return null;
    }
  }

  /// 滚动到指定元素。
  Future<bool> scrollToElement(String elementId) async {
    try {
      final result = await _controller.evaluateJavascript(source: '''
        (function() {
          var element = document.getElementById('$elementId');
          if (element) {
            element.scrollIntoView({ behavior: 'smooth', block: 'start' });
            return true;
          }
          return false;
        })()
      ''');
      return result == true;
    } catch (e) {
      getLogger().e('❌ 滚动到元素 $elementId 失败: $e');
      return false;
    }
  }

  /// 滚动到指定位置。
  Future<void> scrollToPosition(int scrollY, int scrollX) async {
    try {
      await _controller.evaluateJavascript(
        source: '''
          window.scrollTo({
            top: $scrollY,
            left: $scrollX,
            behavior: 'smooth'
          });
        '''
      );
    } catch (e) {
      getLogger().e('❌ 滚动到位置 Y=$scrollY 失败: $e');
    }
  }

  /// 获取最终滚动位置以供验证。
  Future<Map?> getFinalScrollPosition() async {
     try {
        return await _controller.evaluateJavascript(
          source: '({ scrollY: window.scrollY, scrollX: window.scrollX })'
        );
      } catch (e) {
        getLogger().w('⚠️ 获取最终滚动位置失败: $e');
        return null;
      }
  }
} 
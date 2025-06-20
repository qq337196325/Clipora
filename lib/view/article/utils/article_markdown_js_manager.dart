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

  /// 立即定位到指定元素（无动画）。
  Future<bool> jumpToElement(String elementId, {int offset = 0}) async {
    try {
      final result = await _controller.evaluateJavascript(source: '''
        (function() {
          var element = document.getElementById('$elementId');
          if (element) {
            const elementTop = element.getBoundingClientRect().top + window.scrollY;
            const targetPosition = Math.max(0, elementTop - $offset);
            window.scrollTo(0, targetPosition);
            return true;
          }
          return false;
        })()
      ''');
      return result == true;
    } catch (e) {
      getLogger().e('❌ 立即跳转到元素 $elementId 失败: $e');
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

  /// 立即跳转到指定位置（无动画）。
  Future<void> jumpToPosition(int scrollY, int scrollX) async {
    try {
      await _controller.evaluateJavascript(
        source: '''
          window.scrollTo($scrollX, $scrollY);
        '''
      );
    } catch (e) {
      getLogger().e('❌ 立即跳转到位置 Y=$scrollY 失败: $e');
    }
  }

  /// 智能定位：优先使用立即跳转，然后验证位置精确性。
  Future<bool> smartJumpToElement(String elementId, {int offset = 50}) async {
    try {
      // 1. 先立即跳转到元素
      final jumpSuccess = await jumpToElement(elementId, offset: offset);
      if (!jumpSuccess) {
        getLogger().w('⚠️ 元素跳转失败，尝试使用滚动定位');
        return await scrollToElement(elementId);
      }

      // 2. 等待页面稳定
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. 验证定位精确性
      final currentPos = await getCurrentVisibleElement();
      if (currentPos != null && currentPos['id'] == elementId) {
        getLogger().i('✅ 智能定位成功：已精确定位到元素 $elementId');
        return true;
      } else {
        // 4. 如果位置不够精确，使用微调
        final finetuned = await _finetunePosition(elementId, offset);
        if (finetuned) {
          getLogger().i('✅ 智能定位成功：已微调定位到元素 $elementId');
          return true;
        }
      }

      return jumpSuccess;
    } catch (e) {
      getLogger().e('❌ 智能定位失败: $e');
      return false;
    }
  }

  /// 微调定位位置，确保元素在视口中心附近。
  Future<bool> _finetunePosition(String elementId, int offset) async {
    try {
      final result = await _controller.evaluateJavascript(source: '''
        (function() {
          var element = document.getElementById('$elementId');
          if (element) {
            const rect = element.getBoundingClientRect();
            const elementTop = rect.top + window.scrollY;
            const viewportCenter = window.innerHeight / 2;
            const targetPosition = Math.max(0, elementTop - viewportCenter + (rect.height / 2) - $offset);
            window.scrollTo(0, targetPosition);
            return true;
          }
          return false;
        })()
      ''');
      return result == true;
    } catch (e) {
      getLogger().e('❌ 微调定位失败: $e');
      return false;
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

  /// 智能定位：结合元素和位置的混合定位策略。
  Future<bool> smartJumpToPosition(String elementId, int scrollY, int scrollX) async {
    try {
      final result = await _controller.evaluateJavascript(source: '''
        if (window.flutter_reading_tracker && window.flutter_reading_tracker.smartJumpToPosition) {
          return window.flutter_reading_tracker.smartJumpToPosition('$elementId', $scrollY, $scrollX, 50);
        }
        return { success: false, method: 'unavailable' };
      ''');
      
      if (result is Map && result['success'] == true) {
        getLogger().i('⚡ 智能定位成功: ${result['method']} 方式，位置: ${result['position']}');
        return true;
      } else {
        getLogger().w('⚠️ 智能定位失败: $result');
        return false;
      }
    } catch (e) {
      getLogger().e('❌ 智能定位异常: $e');
      return false;
    }
  }

  /// 渐进式定位：先立即跳转，后精细调整。
  Future<bool> progressiveJumpToElement(String elementId) async {
    try {
      final result = await _controller.evaluateJavascript(source: '''
        if (window.flutter_reading_tracker && window.flutter_reading_tracker.progressiveJumpToElement) {
          return window.flutter_reading_tracker.progressiveJumpToElement('$elementId', 50);
        }
        return { success: false, phase: 'unavailable' };
      ''');
      
      if (result is Map && result['success'] == true) {
        getLogger().i('🎯 渐进式定位成功: ${result['phase']} 阶段，位置: ${result['position']}');
        return true;
      } else {
        getLogger().w('⚠️ 渐进式定位失败: $result');
        return false;
      }
    } catch (e) {
      getLogger().e('❌ 渐进式定位异常: $e');
      return false;
    }
  }

  /// 演示不同定位策略的使用场景。
  /// 
  /// 根据传入的策略选择最合适的定位方法：
  /// - 'instant': 立即跳转（无动画，最快）
  /// - 'smooth': 平滑滚动（有动画，更优雅）
  /// - 'smart': 智能混合（元素+位置备份）
  /// - 'progressive': 渐进式（立即+微调）
  Future<bool> restorePositionWithStrategy({
    required String elementId,
    required int scrollY,
    required int scrollX,
    String strategy = 'smart',
  }) async {
    switch (strategy) {
      case 'instant':
        // 场景：用户希望快速回到阅读位置，不关心动画效果
        if (elementId.isNotEmpty) {
          final success = await jumpToElement(elementId);
          if (success) return true;
        }
        await jumpToPosition(scrollY, scrollX);
        return true;
        
      case 'smooth':
        // 场景：初次加载或用户体验优先，需要平滑过渡
        if (elementId.isNotEmpty) {
          final success = await scrollToElement(elementId);
          if (success) return true;
        }
        await scrollToPosition(scrollY, scrollX);
        return true;
        
      case 'smart':
        // 场景：最佳实践，自动选择最适合的定位方式
        return await smartJumpToPosition(elementId, scrollY, scrollX);
        
      case 'progressive':
        // 场景：需要高精度定位，先快速后精确
        if (elementId.isNotEmpty) {
          return await progressiveJumpToElement(elementId);
        }
        await jumpToPosition(scrollY, scrollX);
        return true;
        
      default:
        getLogger().w('⚠️ 未知的定位策略: $strategy，使用智能定位');
        return await smartJumpToPosition(elementId, scrollY, scrollX);
    }
  }
} 
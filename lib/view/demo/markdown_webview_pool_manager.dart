import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../basics/logger.dart';

/// WebView池管理器 - 预热资源以提升性能
class WebViewPoolManager {
  static final WebViewPoolManager _instance = WebViewPoolManager._internal();
  factory WebViewPoolManager() => _instance;
  WebViewPoolManager._internal();

  // 资源缓存 
  String? _cachedMarkedJS;
  String? _cachedHighlightJS;
  String? _cachedGitHubCSS;
  String? _cachedHtmlTemplate;
  String? _cachedEnhancedJS;
  
  // 预热状态
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// 初始化资源缓存
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    getLogger().i('🚀 开始预热WebView资源缓存...');
    
    try {
      await _preloadResources();
      _isInitialized = true;
      getLogger().i('✅ WebView资源预热完成');
    } catch (e) {
      getLogger().e('❌ WebView资源预热失败: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// 预加载所有资源文件
  Future<void> _preloadResources() async {
    getLogger().i('📦 开始预加载资源文件...');
    
    try {
      final futures = [
        rootBundle.loadString('assets/js/marked.min.js').then((content) => _cachedMarkedJS = content),
        rootBundle.loadString('assets/js/highlight.min.js').then((content) => _cachedHighlightJS = content),
        rootBundle.loadString('assets/js/typora_github.css').then((content) => _cachedGitHubCSS = content),
        // 使用安全的Markdown脚本替代增强脚本
        rootBundle.loadString('assets/js/markdown_safe.js').then((content) => _cachedEnhancedJS = content).catchError((e) {
          getLogger().w('⚠️ 安全脚本加载失败，将使用基础功能: $e');
          _cachedEnhancedJS = null;
          return '';
        }),
      ];
      
      await Future.wait(futures);
      
      // 生成优化的HTML模板
      _cachedHtmlTemplate = _generateOptimizedHtmlTemplate();
      
      getLogger().i('✅ 资源预加载完成 - marked.js: ${_cachedMarkedJS?.length ?? 0}字符, highlight.js: ${_cachedHighlightJS?.length ?? 0}字符, Typora CSS: ${_cachedGitHubCSS?.length ?? 0}字符');
    } catch (e) {
      getLogger().e('❌ 资源预加载失败: $e');
    }
  }

  /// 快速设置WebView（使用预缓存的资源）
  Future<void> setupOptimizedWebView(InAppWebViewController controller) async {
    if (!_isInitialized) {
      await initialize();
    }

    getLogger().i('🎯 开始快速设置WebView...');
    
    try {
      // 快速注入预缓存的资源
      await _injectCachedResources(controller);
      getLogger().i('🚀 WebView快速设置完成');
    } catch (e) {
      getLogger().e('❌ WebView快速设置失败: $e');
      rethrow;
    }
  }

  /// 注入所有预缓存的资源
  Future<void> _injectCachedResources(InAppWebViewController controller) async {
    final List<Future> injectionFutures = [];

    // 并行注入所有资源
    if (_cachedMarkedJS != null) {
      injectionFutures.add(
        controller.evaluateJavascript(source: _cachedMarkedJS!)
          .then((_) => getLogger().d('✅ marked.js 注入完成'))
      );
    }
    
    if (_cachedHighlightJS != null) {
      injectionFutures.add(
        controller.evaluateJavascript(source: _cachedHighlightJS!)
          .then((_) => getLogger().d('✅ highlight.js 注入完成'))
      );
    }
    
    if (_cachedGitHubCSS != null) {
      injectionFutures.add(
        controller.evaluateJavascript(source: '''
          var githubStyles = document.getElementById('github-styles');
          if (githubStyles) {
            githubStyles.textContent = `${_cachedGitHubCSS!.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`;
          }
        ''').then((_) => getLogger().d('✅ Typora GitHub CSS 注入完成'))
      );
    }

    // 等待所有资源注入完成
    await Future.wait(injectionFutures);

    // 注入安全的Markdown脚本（如果可用）
    if (_cachedEnhancedJS != null && _cachedEnhancedJS!.isNotEmpty) {
      try {
        await controller.evaluateJavascript(source: _cachedEnhancedJS!);
        getLogger().d('✅ 安全的 Markdown 脚本注入完成');
      } catch (e) {
        getLogger().w('⚠️ 安全脚本注入失败，使用基础配置: $e');
        await _setupBasicMarkdownConfig(controller);
      }
    } else {
      await _setupBasicMarkdownConfig(controller);
    }
  }

  /// 设置基础的Markdown配置（备用方案）
  Future<void> _setupBasicMarkdownConfig(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: '''
        if (typeof marked !== 'undefined') {
          marked.setOptions({
            highlight: function(code, lang) {
              if (typeof hljs !== 'undefined') {
                if (lang && hljs.getLanguage(lang)) {
                  try {
                    return hljs.highlight(code, { language: lang }).value;
                  } catch (err) {
                    return code;
                  }
                }
                return hljs.highlightAuto(code).value;
              }
              return code;
            },
            langPrefix: 'hljs language-',
            breaks: true,
            gfm: true
          });
          console.log('✅ 基础 Markdown 配置完成');
        }
      ''');
    } catch (e) {
      getLogger().e('❌ 基础Markdown配置失败: $e');
    }
  }

  /// 检查资源是否已预热
  bool get isResourcesReady => _isInitialized && 
    _cachedMarkedJS != null && 
    _cachedHighlightJS != null && 
    _cachedGitHubCSS != null;

  /// 获取预缓存的HTML模板
  String getHtmlTemplate() {
    return _cachedHtmlTemplate ?? _generateOptimizedHtmlTemplate();
  }

  /// 快速渲染Markdown内容
  Future<void> renderMarkdownContent(
    InAppWebViewController controller, 
    String markdownContent,
    [String paddingStyle = '']
  ) async {
    if (markdownContent.isEmpty) return;


    final escapedMarkdown = markdownContent.replaceAll('`', '\\`').replaceAll('\$', '\\\$');

    // 尝试使用带内边距的安全渲染函数
    final result = await controller.evaluateJavascript(source: '''
        (function() {
          try {
            if (typeof safeRenderMarkdown === 'function') {
              console.log('🛡️ 使用安全渲染函数 (带内边距)');
              return safeRenderMarkdown(`$escapedMarkdown`, 'content', `$paddingStyle`);
            }
            return false;
          } catch (e) {
            console.warn('带内边距的安全渲染失败:', e);
            return false;
          }
        })();
      ''');

    if (result == true) {
      getLogger().i('✅ 使用带内边距的安全渲染完成');
      return;
    } else {
      getLogger().w('⚠️ 安全渲染函数不可用或失败，降级到传统渲染');
      throw Exception('安全渲染函数不可用或失败');
    }

    try {

    } catch (e) {
      getLogger().w('⚠️ 安全渲染失败，使用传统渲染: $e');
    }
  }



  /// 生成优化的HTML模板
  String _generateOptimizedHtmlTemplate() {
    return '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Markdown Content</title>
    <style id="github-styles">${_cachedGitHubCSS ?? ''}</style>
    <style>
        /* 基础重置和主题适配 */
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            background-color: transparent !important; /* 确保背景透明 */
            margin: 0;
            padding: 0px; /* 移除模板中的硬编码内边距 */
            padding-top: 50px;
        }
        /* Markdown内容的基础容器 */
        #content {
            width: 100%;
            box-sizing: border-box; /* 确保内边距不会导致溢出 */
            word-wrap: break-word;
        }
        .markdown-body {
            /* 可以在此定义独立于主题的Markdown样式 */
        }
        /* 图片样式 */
        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 16px auto;
            cursor: pointer;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div id="content"></div>
</body>
</html>
''';
  }
} 
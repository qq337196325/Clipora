import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../basics/logger.dart';

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
  Future<void> renderMarkdownContent(InAppWebViewController controller, String markdownContent) async {
    if (markdownContent.isEmpty) return;

    try {
      // 首先尝试使用安全渲染函数
      final result = await controller.evaluateJavascript(source: '''
        (function() {
          try {
            if (typeof safeRenderMarkdown === 'function') {
              console.log('🛡️ 使用安全渲染函数');
              return safeRenderMarkdown(`${markdownContent.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`, 'content');
            } else {
              console.log('⚠️ 安全渲染函数不可用，使用基础渲染');
              throw new Error('安全渲染函数不可用');
            }
          } catch (e) {
            console.warn('安全渲染失败，降级到基础渲染:', e);
            throw e;
          }
        })();
      ''');

      if (result == true) {
        getLogger().i('✅ 使用安全渲染完成');
        return;
      }
    } catch (e) {
      getLogger().w('⚠️ 安全渲染失败，使用传统渲染: $e');
    }

    // 降级到传统渲染方法
    await _renderTraditionalMarkdown(controller, markdownContent);
  }

  /// 传统的Markdown渲染方法（备用）
  Future<void> _renderTraditionalMarkdown(InAppWebViewController controller, String markdownContent) async {
    try {
      await controller.evaluateJavascript(source: '''
        if (typeof marked !== 'undefined' && marked.parse) {
          try {
            var content = `${markdownContent.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`;
            var htmlContent = marked.parse(content);
            var contentDiv = document.getElementById('content');
            if (contentDiv) {
              contentDiv.innerHTML = '<div class="markdown-body">' + htmlContent + '</div>';
              
              // 处理图片
              var images = document.querySelectorAll('.markdown-body img');
              images.forEach(function(img) {
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                img.style.display = 'block';
                img.style.margin = '16px auto';
                img.style.cursor = 'pointer';
                
                // 添加图片点击事件
                img.addEventListener('click', function() {
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('onImageClicked', {
                      src: img.src,
                      alt: img.alt || '',
                      width: img.naturalWidth || 0,
                      height: img.naturalHeight || 0
                    });
                  }
                });
              });
              
              console.log('✅ 传统 Markdown 渲染完成，包含 ' + images.length + ' 张图片');
            }
          } catch (error) {
            console.error('❌ 传统 Markdown渲染失败:', error);
            document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 内容解析失败</h3><p>' + error.message + '</p></div>';
          }
        } else {
          console.error('❌ marked.js 未加载');
          document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 解析器未就绪</h3><p>Markdown解析器未加载，请稍后重试</p></div>';
        }
      ''');
    } catch (e) {
      getLogger().e('❌ 传统Markdown渲染失败: $e');
      rethrow;
    }
  }

  /// 获取性能统计信息
  Map<String, dynamic> getPerformanceStats() {
    return {
      'isInitialized': _isInitialized,
      'isResourcesReady': isResourcesReady,
      'markedJSSize': _cachedMarkedJS?.length ?? 0,
      'highlightJSSize': _cachedHighlightJS?.length ?? 0,
      'githubCSSSize': _cachedGitHubCSS?.length ?? 0,
      'htmlTemplateSize': _cachedHtmlTemplate?.length ?? 0,
    };
  }

  /// 生成优化的HTML模板
  String _generateOptimizedHtmlTemplate() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>文章阅读</title>
    
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #ffffff;
            color: #333;
            -webkit-user-select: text;
            user-select: text;
            font-size: 16px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            min-height: 100vh;
        }
        
        .loading-indicator {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Markdown样式 */
        .markdown-body {
            font-family: inherit;
            line-height: inherit;
        }
        
        .markdown-body h1, 
        .markdown-body h2, 
        .markdown-body h3, 
        .markdown-body h4, 
        .markdown-body h5, 
        .markdown-body h6 { 
            color: #2c3e50; 
            margin-top: 24px;
            margin-bottom: 16px;
            font-weight: 600;
        }
        
        .markdown-body h1 { font-size: 28px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        .markdown-body h2 { font-size: 24px; border-bottom: 1px solid #eee; padding-bottom: 8px; }
        .markdown-body h3 { font-size: 20px; }
        .markdown-body h4 { font-size: 18px; }
        
        .markdown-body p {
            margin-bottom: 16px;
            text-align: justify;
        }
        
        .markdown-body code {
            background-color: #f6f8fa;
            padding: 2px 6px;
            border-radius: 6px;
            font-family: 'SF Mono', 'Monaco', 'Cascadia Code', 'Roboto Mono', monospace;
            font-size: 85%;
            color: #e83e8c;
        }
        
        .markdown-body pre {
            background-color: #f6f8fa;
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 16px 0;
            border: 1px solid #e1e4e8;
        }
        
        .markdown-body pre code {
            background: none;
            padding: 0;
            color: inherit;
        }
        
        .markdown-body blockquote {
            border-left: 4px solid #0969da;
            margin: 16px 0;
            padding: 0 16px;
            color: #656d76;
            font-style: italic;
            background-color: #f8f9fa;
        }
        
        .markdown-body ul, 
        .markdown-body ol {
            padding-left: 24px;
            margin: 16px 0;
        }
        
        .markdown-body li {
            margin: 8px 0;
        }
        
        .markdown-body strong { 
            font-weight: 600; 
            color: #2c3e50;
        }
        
        .markdown-body em { 
            font-style: italic; 
            color: #555;
        }
        
        .markdown-body del { 
            text-decoration: line-through; 
            color: #999;
        }
        
        .markdown-body hr {
            border: none;
            border-top: 2px solid #e1e4e8;
            margin: 24px 0;
        }
        
        .markdown-body img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .markdown-body img:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        /* 移动端优化 */
        @media (max-width: 768px) {
            body { 
                padding: 12px; 
                font-size: 16px; 
            }
            .container { 
                padding: 0; 
            }
            .markdown-body h1 { font-size: 24px; }
            .markdown-body h2 { font-size: 20px; }
            .markdown-body h3 { font-size: 18px; }
        }
        
        /* 选择高亮 */
        ::selection {
            background-color: rgba(9, 105, 218, 0.2);
        }
        ::-moz-selection {
            background-color: rgba(9, 105, 218, 0.2);
        }
    </style>
    
    <style id="github-styles"></style>
</head>
<body>
    <div class="container" id="content">
        <div class="loading-indicator">
            <div class="loading-spinner"></div>
            <p>正在加载文章内容...</p>
            <p style="font-size: 14px; color: #999;">优化加载中</p>
        </div>
    </div>
    
    <script>
        console.log('📜 HTML模板加载完成，等待资源注入...');
    </script>
</body>
</html>
''';
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';

class ArticlePage2 extends StatefulWidget {
  const ArticlePage2({super.key});

  @override
  State<ArticlePage2> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage2> {
  InAppWebViewController? _webViewController;
  bool _isWebViewReady = false;
  bool _isDisposing = false; // 添加销毁状态标记

   final String _originalMarkdown = '''
# 📖 Flutter 标注功能示例文章

这是一个演示 **markdown_widget** 标注功能的示例文章。

## 🎯 核心功能

### 文本选择与标注
选择这段文字试试！您可以长按选择文本，然后添加高亮标注。这个功能类似于 **Cubox**、**Obsidian** 等阅读软件。

### 代码高亮支持
```dart
class AnnotationModel {
  final String id;
  final String selectedText;
  final int startOffset;
  final int endOffset;
  final String note;
  final DateTime createdAt;
}
```

### 富文本内容
支持 *斜体*、**粗体**、~~删除线~~、以及 `行内代码`。

> 这是一个引用块，可以用来展示重要信息。
> 
> 支持多行引用内容。

## 📝 功能特点

1. **文本选择**: 支持跨段落选择文本
2. **标注管理**: 添加颜色高亮和笔记
3. **数据持久化**: 标注信息保存到本地数据库
4. **位置恢复**: 准确恢复标注位置

### 表格支持

| 功能 | 状态 | 说明 |
|------|------|------|
| 文本选择 | ✅ | 支持 SelectionArea |
| 高亮标注 | 🚧 | 开发中 |
| 笔记功能 | 🚧 | 开发中 |
| 导出分享 | ⏳ | 计划中 |

## 🎨 样式自定义

这段文字展示了自定义样式的效果。您可以选择这些文字来测试标注功能。

---

## 💡 使用提示

- 长按文字开始选择
- 拖动选择多个段落  
- 点击标注按钮添加高亮
- 支持多种颜色标注

**试试选择这段文字并添加标注吧！**
''';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 在返回前立即隐藏WebView，避免延迟效果
        setState(() {
          _isDisposing = true;
        });
        
        // 清理WebView资源
        await _cleanupWebView();
        
        // 稍微延迟以确保清理完成
        await Future.delayed(const Duration(milliseconds: 50));
        
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('文章阅读 - WebView版'),
          actions: [
            IconButton(
              icon: const Icon(Icons.highlight),
              onPressed: _highlightSelectedText,
              tooltip: '高亮选中文本',
            ),
            IconButton(
              icon: const Icon(Icons.note_add),
              onPressed: _addAnnotation,
              tooltip: '添加标注',
            ),
          ],
        ),
        body: _isDisposing 
          ? const SizedBox.shrink() // 销毁时显示空白，避免WebView延迟消失
          : Stack(
              children: [
                InAppWebView(
                  initialData: InAppWebViewInitialData(
                    data: _generateHtmlContent(),
                    mimeType: "text/html",
                    encoding: "utf-8",
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStop: (controller, url) async {
                    if (!_isDisposing) {
                      // 页面加载完成后设置JavaScript处理器
                      await _setupJavaScriptHandlers();
                      if (mounted && !_isDisposing) {
                        setState(() {
                          _isWebViewReady = true;
                        });
                      }
                    }
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      supportZoom: false,
                      javaScriptEnabled: true,
                      clearCache: true, // 清除缓存，减少内存占用
                      cacheEnabled: false, // 禁用缓存，避免资源残留
                    ),
                    android: AndroidInAppWebViewOptions(
                      useHybridComposition: true,
                    ),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    ),
                  ),
                  onConsoleMessage: (controller, consoleMessage) {
                    print('🔍 WebView控制台: ${consoleMessage.messageLevel.toString()} - ${consoleMessage.message}');
                  },
                ),
                if (!_isWebViewReady && !_isDisposing)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
      ),
    );
  }

  // 生成HTML内容
  String _generateHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>文章阅读</title>
    
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #ffffff;
            color: #333;
            -webkit-user-select: text;
            -moz-user-select: text;
            -ms-user-select: text;
            user-select: text;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        h1, h2, h3, h4, h5, h6 { 
            color: #2c3e50; 
            margin-top: 24px;
            margin-bottom: 16px;
        }
        h1 { font-size: 28px; }
        h2 { font-size: 24px; }
        h3 { font-size: 20px; }
        
        /* 代码样式 */
        code {
            background-color: #f6f8fa;
            padding: 2px 6px;
            border-radius: 6px;
            font-family: 'SF Mono', 'Monaco', 'Cascadia Code', 'Roboto Mono', monospace;
            font-size: 14px;
        }
        pre {
            background-color: #f6f8fa;
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 16px 0;
        }
        pre code {
            background: none;
            padding: 0;
        }
        
        /* 引用块样式 */
        blockquote {
            border-left: 4px solid #0969da;
            margin: 16px 0;
            padding: 0 16px;
            color: #656d76;
            font-style: italic;
        }
        
        /* 表格样式 */
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
            font-size: 14px;
        }
        th, td {
            border: 1px solid #d0d7de;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #f6f8fa;
            font-weight: 600;
        }
        tr:nth-child(even) {
            background-color: #f6f8fa;
        }
        
        /* 列表样式 */
        ul, ol {
            padding-left: 24px;
            margin: 16px 0;
        }
        li {
            margin: 8px 0;
        }
        
        /* 标注和高亮样式 */
        .highlight {
            background-color: #fff3cd;
            padding: 2px 4px;
            border-radius: 4px;
            box-shadow: 0 0 0 2px rgba(255, 193, 7, 0.2);
            transition: all 0.2s ease;
        }
        .highlight:hover {
            background-color: #ffeaa7;
        }
        .annotation {
            background-color: #e3f2fd;
            border-left: 3px solid #2196f3;
            padding: 8px 12px;
            margin: 8px 0;
            border-radius: 4px;
            position: relative;
        }
        .annotation::before {
            content: "📝";
            margin-right: 8px;
        }
        
        /* 选择菜单样式 */
        .selection-menu {
            position: absolute;
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            padding: 8px;
            z-index: 1000;
            display: none;
            backdrop-filter: blur(10px);
        }
        .selection-menu button {
            margin: 2px;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            background: #f6f8fa;
            color: #24292f;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        .selection-menu button:hover {
            background: #0969da;
            color: white;
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
            table {
                font-size: 12px;
            }
            th, td {
                padding: 8px;
            }
            .selection-menu {
                position: fixed;
                bottom: 20px;
                left: 50%;
                transform: translateX(-50%);
                min-width: 200px;
            }
        }
        
        /* 选择文本时的样式 */
        ::selection {
            background-color: rgba(9, 105, 218, 0.1);
        }
        ::-moz-selection {
            background-color: rgba(9, 105, 218, 0.1);
        }

        /* highlight.js GitHub 样式 */
        .hljs {
            display: block;
            overflow-x: auto;
            padding: 0.5em;
            color: #333;
            background: #f8f8f8;
        }
        .hljs-comment,
        .hljs-quote {
            color: #998;
            font-style: italic;
        }
        .hljs-keyword,
        .hljs-selector-tag,
        .hljs-subst {
            color: #333;
            font-weight: bold;
        }
        .hljs-number,
        .hljs-literal,
        .hljs-variable,
        .hljs-template-variable,
        .hljs-tag .hljs-attr {
            color: #008080;
        }
        .hljs-string,
        .hljs-doctag {
            color: #d14;
        }
        .hljs-title,
        .hljs-section,
        .hljs-selector-id {
            color: #900;
            font-weight: bold;
        }
        .hljs-subst {
            font-weight: normal;
        }
        .hljs-type,
        .hljs-class .hljs-title {
            color: #458;
            font-weight: bold;
        }
        .hljs-tag,
        .hljs-name,
        .hljs-attribute {
            color: #000080;
            font-weight: normal;
        }
        .hljs-regexp,
        .hljs-link {
            color: #009926;
        }
        .hljs-symbol,
        .hljs-bullet {
            color: #990073;
        }
        .hljs-built_in,
        .hljs-builtin-name {
            color: #0086b3;
        }
        .hljs-meta {
            color: #999;
            font-weight: bold;
        }
        .hljs-deletion {
            background: #fdd;
        }
        .hljs-addition {
            background: #dfd;
        }
        .hljs-emphasis {
            font-style: italic;
        }
        .hljs-strong {
            font-weight: bold;
        }
        
        /* 加载状态样式 */
        .loading {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }
        .loading::before {
            content: "📚";
            font-size: 48px;
            display: block;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>
    <div class="container" id="content">
        <div class="loading">
            <p>正在加载 Markdown 内容...</p>
            <p style="font-size: 14px; color: #999;">使用 marked.js + highlight.js 渲染</p>
        </div>
    </div>
    
    <div id="selectionMenu" class="selection-menu">
        <button onclick="highlightSelection()">🎨 高亮</button>
        <button onclick="addAnnotation()">📝 标注</button>
        <button onclick="copySelection()">📋 复制</button>
        <button onclick="clearSelection()">❌ 取消</button>
    </div>

    <script>
        console.log('📜 HTML 页面脚本开始加载...');
        
        let selectedText = '';
        let selectionRange = null;
        
        // 监听文本选择事件
        document.addEventListener('mouseup', function(e) {
            handleTextSelection(e);
        });
        
        document.addEventListener('touchend', function(e) {
            // 延迟处理，确保选择完成
            setTimeout(() => handleTextSelection(e), 100);
        });
        
        function handleTextSelection(e) {
            console.log('🖱️ 文本选择事件触发');
            const selection = window.getSelection();
            const text = selection.toString().trim();
            
            if (text.length > 0) {
                selectedText = text;
                try {
                    selectionRange = selection.getRangeAt(0);
                } catch (err) {
                    console.log('⚠️ 无法获取选择范围:', err);
                    return;
                }
                console.log('✅ 文本已选中:', selectedText);
                
                // 计算选择菜单位置
                const rect = selectionRange.getBoundingClientRect();
                const x = rect.left + (rect.width / 2);
                const y = rect.top - 50;
                
                showSelectionMenu(x, y);
                
                // 通知Flutter端选择了文本
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    try {
                        window.flutter_inappwebview.callHandler('onTextSelected', {
                            text: selectedText,
                            startOffset: selectionRange.startOffset,
                            endOffset: selectionRange.endOffset
                        });
                        console.log('✅ 选中文本已发送到Flutter');
                    } catch (error) {
                        console.error('❌ 发送选中文本到Flutter失败:', error);
                    }
                }
            } else {
                hideSelectionMenu();
            }
        }
        
        // 显示选择菜单
        function showSelectionMenu(x, y) {
            console.log('📋 显示选择菜单 at:', x, y);
            const menu = document.getElementById('selectionMenu');
            if (menu) {
                menu.style.display = 'block';
                
                // 移动端显示在底部，桌面端显示在选择位置附近
                if (window.innerWidth <= 768) {
                    menu.style.position = 'fixed';
                    menu.style.bottom = '20px';
                    menu.style.left = '50%';
                    menu.style.transform = 'translateX(-50%)';
                } else {
                    menu.style.position = 'absolute';
                    menu.style.left = Math.max(10, Math.min(x - 100, window.innerWidth - 220)) + 'px';
                    menu.style.top = Math.max(10, y) + 'px';
                    menu.style.transform = 'none';
                }
                
                console.log('📋 选择菜单已显示');
            }
        }
        
        // 隐藏选择菜单
        function hideSelectionMenu() {
            const menu = document.getElementById('selectionMenu');
            if (menu) {
                menu.style.display = 'none';
            }
        }
        
        // 高亮选中文本
        function highlightSelection() {
            console.log('🎨 开始高亮选中文本');
            if (selectionRange && selectedText) {
                try {
                    const span = document.createElement('span');
                    span.className = 'highlight';
                    span.setAttribute('data-highlight-id', Date.now().toString());
                    span.setAttribute('title', '点击查看标注详情');
                    
                    selectionRange.surroundContents(span);
                    console.log('✅ 高亮成功');
                    
                    // 通知Flutter端添加了高亮
                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                        window.flutter_inappwebview.callHandler('onTextHighlighted', {
                            text: selectedText,
                            highlightId: span.getAttribute('data-highlight-id')
                        });
                    }
                } catch (e) {
                    console.error('❌ 高亮失败:', e);
                    // fallback: 直接通知Flutter处理
                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                        window.flutter_inappwebview.callHandler('onTextHighlighted', {
                            text: selectedText,
                            highlightId: Date.now().toString()
                        });
                    }
                }
            }
            clearSelection();
        }
        
        // 添加标注
        function addAnnotation() {
            console.log('📝 开始添加标注');
            if (selectedText) {
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    try {
                        window.flutter_inappwebview.callHandler('onAddAnnotation', {
                            text: selectedText
                        });
                        console.log('✅ 标注请求已发送到Flutter');
                    } catch (error) {
                        console.error('❌ 发送标注请求失败:', error);
                    }
                }
            }
            clearSelection();
        }
        
        // 复制选中文本
        function copySelection() {
            if (selectedText) {
                try {
                    navigator.clipboard.writeText(selectedText).then(() => {
                        console.log('✅ 文本已复制到剪贴板');
                        // 可以通知Flutter显示复制成功提示
                        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                            window.flutter_inappwebview.callHandler('onTextCopied', {
                                text: selectedText
                            });
                        }
                    });
                } catch (error) {
                    console.error('❌ 复制失败:', error);
                }
            }
            clearSelection();
        }
        
        // 清除选择
        function clearSelection() {
            window.getSelection().removeAllRanges();
            hideSelectionMenu();
            selectedText = '';
            selectionRange = null;
        }
        
        // 点击其他地方时隐藏菜单
        document.addEventListener('click', function(e) {
            if (!e.target.closest('#selectionMenu')) {
                hideSelectionMenu();
            }
        });
        
        console.log('📜 HTML 页面脚本加载完成');
    </script>
</body>
</html>
''';
  }

  // 设置JavaScript处理器
  Future<void> _setupJavaScriptHandlers() async {
    if (_webViewController == null) return;

    try {
      // 📦 加载离线 JavaScript 库文件
      print('📦 开始加载离线 JavaScript 库...');
      
      // 加载 marked.js
      final String markedJs = await rootBundle.loadString('assets/js/marked.min.js');
      await _webViewController!.evaluateJavascript(source: markedJs);
      print('✅ marked.js 加载完成');

      // 加载 highlight.js
      final String highlightJs = await rootBundle.loadString('assets/js/highlight.min.js');
      await _webViewController!.evaluateJavascript(source: highlightJs);
      print('✅ highlight.js 加载完成');

      // 等待库加载完成
      await Future.delayed(const Duration(milliseconds: 200));

      // 配置 marked 和初始化渲染
      await _webViewController!.evaluateJavascript(source: '''
        console.log('🚀 开始配置 marked.js...');
        
        // 配置 marked
        if (typeof marked !== 'undefined') {
          marked.setOptions({
            highlight: function(code, lang) {
              if (typeof hljs !== 'undefined' && lang && hljs.getLanguage(lang)) {
                try {
                  return hljs.highlight(code, { language: lang }).value;
                } catch (err) {
                  console.error('代码高亮失败:', err);
                }
              }
              if (typeof hljs !== 'undefined') {
                return hljs.highlightAuto(code).value;
              }
              return code;
            },
            langPrefix: 'hljs language-',
            breaks: true,
            gfm: true
          });
          console.log('✅ marked.js 配置完成');
        } else {
          console.error('❌ marked.js 未加载');
        }

        // 初始化页面内容
        function initializeMarkdownContent() {
          try {
            console.log('📝 开始渲染 Markdown 内容...');
            const markdownContent = `${_originalMarkdown.replaceAll('`', r'\`').replaceAll(r'$', r'\$')}`;
            
            if (typeof marked !== 'undefined') {
              const htmlContent = marked.parse(markdownContent);
              const contentDiv = document.getElementById('content');
              if (contentDiv) {
                contentDiv.innerHTML = htmlContent;
                console.log('✅ Markdown 渲染完成');
              } else {
                console.error('❌ 找不到 content 元素');
              }
            } else {
              console.error('❌ marked 库未加载，使用备用渲染');
              // 使用简化的渲染作为备用
              fallbackRender();
            }
          } catch (error) {
            console.error('❌ Markdown 渲染失败:', error);
            fallbackRender();
          }
        }

        // 备用渲染函数
        function fallbackRender() {
          console.log('🔄 使用备用渲染器...');
          const contentDiv = document.getElementById('content');
          if (contentDiv) {
            contentDiv.innerHTML = '<h1>📖 文章内容</h1><p>正在加载文章内容...</p>';
          }
        }

        // 初始化内容
        if (document.readyState === 'complete') {
          initializeMarkdownContent();
        } else {
          document.addEventListener('DOMContentLoaded', initializeMarkdownContent);
        }
      ''');

      print('✅ 所有 JavaScript 库加载和配置完成');

    } catch (e) {
      print('❌ 加载 JavaScript 库失败: $e');
      // 使用备用方案
      await _webViewController!.evaluateJavascript(source: '''
        console.error('❌ 加载外部库失败，使用内置解析器');
        // 这里可以调用之前的简化解析器
        if (typeof parseMarkdown === 'function') {
          renderMarkdown();
        }
      ''');
    }

    _webViewController!.addJavaScriptHandler(
      handlerName: 'onTextSelected',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        print('🔍 选中文本: ${data['text']}');
        print('📍 起始位置: ${data['startOffset']}');
        print('📍 结束位置: ${data['endOffset']}');
        
        // 这里可以处理文本选择事件
        _handleTextSelection(data);
      },
    );

    _webViewController!.addJavaScriptHandler(
      handlerName: 'onTextHighlighted',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        print('🎨 高亮文本: ${data['text']}');
        print('🆔 高亮ID: ${data['highlightId']}');
        
        // 这里可以保存高亮信息
        _handleTextHighlighted(data);
      },
    );

    _webViewController!.addJavaScriptHandler(
      handlerName: 'onAddAnnotation',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        print('📝 添加标注: ${data['text']}');
        
        // 这里可以弹出标注输入框
        _handleAddAnnotation(data);
      },
    );

    // 添加复制文本处理器
    _webViewController!.addJavaScriptHandler(
      handlerName: 'onTextCopied',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        print('📋 文本已复制: ${data['text']}');
        
        // 显示复制成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制: ${data['text'].substring(0, 20)}...'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );

    // 添加一个测试处理器来验证桥接是否工作
    _webViewController!.addJavaScriptHandler(
      handlerName: 'testHandler',
      callback: (args) {
        print('✅ JavaScript桥接测试成功: ${args[0]}');
      },
    );

    // 等待一小段时间确保处理器注册完成
    await Future.delayed(const Duration(milliseconds: 100));

    // 注入测试脚本验证桥接
    await _webViewController!.evaluateJavascript(source: '''
      console.log('🚀 页面加载完成，开始测试JavaScript桥接...');
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('testHandler', 'JavaScript桥接正常工作');
        console.log('✅ Flutter桥接可用');
      } else {
        console.log('❌ Flutter桥接不可用');
      }
    ''');
  }

  // 处理文本选择
  void _handleTextSelection(Map<String, dynamic> data) {
    // 在这里可以实现文本选择后的逻辑
    // 比如显示选择菜单、保存选择状态等
  }

  // 处理文本高亮
  void _handleTextHighlighted(Map<String, dynamic> data) {
    // 在这里可以实现高亮后的逻辑
    // 比如保存高亮信息到数据库
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已高亮文本: ${data['text']}')),
    );
  }

  // 处理添加标注
  void _handleAddAnnotation(Map<String, dynamic> data) {
    // 在这里可以弹出标注输入对话框
    _showAnnotationDialog(data['text']);
  }

  // 显示标注输入对话框
  void _showAnnotationDialog(String selectedText) {
    final TextEditingController noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标注'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('选中文本：', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(selectedText),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: '添加笔记',
                hintText: '在这里输入您的笔记...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 保存标注信息
              _saveAnnotation(selectedText, noteController.text);
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 保存标注信息
  void _saveAnnotation(String text, String note) {
    // 在这里实现保存标注的逻辑
    // 比如保存到数据库
    debugPrint('保存标注 - 文本: $text, 笔记: $note');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('标注已保存')),
    );
  }

  // 高亮选中文本（从AppBar按钮调用）
  void _highlightSelectedText() {
    _webViewController?.evaluateJavascript(source: 'highlightSelection();');
  }

  // 添加标注（从AppBar按钮调用）
  void _addAnnotation() {
    _webViewController?.evaluateJavascript(source: 'addAnnotation();');
  }

  // 清理WebView资源
  Future<void> _cleanupWebView() async {
    try {
      if (_webViewController != null) {
        // 停止加载
        await _webViewController!.stopLoading();
        
        // 清除历史记录
        await _webViewController!.clearHistory();
        
        // 清除缓存
        await _webViewController!.clearCache();
        
        // 移除所有JavaScript处理器
        _webViewController!.removeJavaScriptHandler(handlerName: 'onTextSelected');
        _webViewController!.removeJavaScriptHandler(handlerName: 'onTextHighlighted');
        _webViewController!.removeJavaScriptHandler(handlerName: 'onAddAnnotation');
        _webViewController!.removeJavaScriptHandler(handlerName: 'onTextCopied');
        _webViewController!.removeJavaScriptHandler(handlerName: 'testHandler');
        
        print('🧹 WebView资源清理完成');
      }
    } catch (e) {
      print('❌ WebView清理过程中出错: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _isWebViewReady = false;
    _isDisposing = false;
  }

  @override
  void dispose() {
    _isDisposing = true;
    
    // 同步清理WebView资源
    _cleanupWebView().catchError((error) {
      print('❌ dispose时WebView清理失败: $error');
    });
    
    _webViewController = null;
    
    super.dispose();
  }
}
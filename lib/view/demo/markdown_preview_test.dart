import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../basics/logger.dart';
import 'markdown_webview_pool_manager.dart';

class MarkdownPreviewTestPage extends StatefulWidget {
  const MarkdownPreviewTestPage({Key? key}) : super(key: key);

  @override
  State<MarkdownPreviewTestPage> createState() => _MarkdownPreviewTestPageState();
}

class _MarkdownPreviewTestPageState extends State<MarkdownPreviewTestPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  
  // 测试用的Markdown内容
  final String testMarkdown = '''
# 📚 Markdown显示效果测试

这是一个测试页面，展示我们优化后的Markdown渲染效果。

## 🎨 文本样式测试

这是一段普通文本，包含**粗体文字**，*斜体文字*，~~删除线文字~~，以及`行内代码`。

### 🔗 链接测试

- [内部链接](#标题锚点测试)
- [外部链接](https://github.com)
- [带标题的链接](https://flutter.dev "Flutter 官网")

## 📋 列表测试

### 无序列表
- 第一项
- 第二项
  - 嵌套项目1
  - 嵌套项目2
- 第三项

### 有序列表
1. 第一步
2. 第二步
3. 第三步

### 任务列表
- [x] 已完成的任务
- [ ] 未完成的任务
- [x] 另一个已完成的任务

## 💡 引用块测试

> 这是一个引用块的例子。
> 
> 引用块可以包含多行文本，并且支持**格式化**。
> 
> — 某位智者

## 📊 表格测试

| 功能 | 原始效果 | 优化后效果 | 改进幅度 |
|------|----------|------------|----------|
| 字体渲染 | 一般 | 优秀 | ⭐⭐⭐⭐⭐ |
| 代码高亮 | 基础 | 专业 | ⭐⭐⭐⭐⭐ |
| 移动端适配 | 有限 | 完美 | ⭐⭐⭐⭐⭐ |
| 主题支持 | 单一 | 多样 | ⭐⭐⭐⭐ |

## 💻 代码块测试

### Dart代码示例
```dart
class MarkdownRenderer {
  final String content;
  
  MarkdownRenderer(this.content);
  
  Future<String> render() async {
    try {
      final result = await marked.parse(content);
      return result;
    } catch (e) {
      getLogger().e('渲染失败: \$e');
      rethrow;
    }
  }
}
```

### JavaScript代码示例
```javascript
function enhanceMarkdown() {
  const renderer = new marked.Renderer();
  
  renderer.code = function(code, language) {
    return `<div class="code-block-wrapper">
      <div class="code-header">
        <span class="language">\${language}</span>
        <button onclick="copyCode(this)">复制</button>
      </div>
      <pre><code class="hljs language-\${language}">\${hljs.highlight(code, {language}).value}</code></pre>
    </div>`;
  };
  
  marked.setOptions({ renderer });
}
```

### CSS代码示例
```css
.markdown-body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  line-height: 1.6;
  color: var(--text-color);
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.markdown-body h1 {
  font-size: 2.2em;
  border-bottom: 2px solid var(--border-color);
  padding-bottom: 12px;
}
```

## 🖼️ 图片测试

![测试图片](https://picsum.photos/400/200?random=1)

*这是一张测试图片，展示图片的显示效果*

## 📐 数学公式测试（如果支持）

行内公式：E = mc²

块级公式：
```
∑(i=1 to n) x_i = n(n+1)/2
```

## 🏷️ 标题锚点测试

点击标题旁边的链接符号可以跳转到对应位置。

### 三级标题示例
#### 四级标题示例
##### 五级标题示例
###### 六级标题示例

## 🎯 总结

通过以上测试，你可以看到：

1. **字体渲染**：更加清晰美观
2. **代码高亮**：专业的语法高亮
3. **响应式设计**：完美适配移动端  
4. **交互增强**：代码复制、锚点导航
5. **主题支持**：自动适配亮色/暗色模式

---

*测试完成，感谢使用我们的Markdown渲染增强方案！* 🎉
''';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // 确保WebView池管理器已初始化
    WebViewPoolManager().initialize().then((_) {
      setState(() {
        // 初始化完成，WebView可以开始加载
      });
    }).catchError((e) {
      getLogger().e('❌ WebView池管理器初始化失败: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown 效果测试'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _generateHtmlContent(),
              mimeType: 'text/html',
              encoding: 'utf-8',
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              await _setupWebView();
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              useOnLoadResource: true,
              useShouldOverrideUrlLoading: true,
              supportZoom: false,
              transparentBackground: true,
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在加载优化后的Markdown渲染器...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _generateHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>Markdown 测试</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #ffffff;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .loading {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
    </style>
    <style id="github-styles"></style>
</head>
<body>
    <div class="container">
        <div id="content" class="loading">
            <h3>🚀 正在加载增强的Markdown渲染器...</h3>
            <p>请等待资源加载完成</p>
        </div>
    </div>
</body>
</html>
''';
  }

  Future<void> _setupWebView() async {
    if (webViewController == null) return;
    
    try {
      getLogger().i('🔧 开始设置WebView...');
      
      // 使用WebView池管理器设置优化的WebView
      if (WebViewPoolManager().isResourcesReady) {
        await WebViewPoolManager().setupOptimizedWebView(webViewController!);
        getLogger().i('✅ 使用优化设置');
      } else {
        await _setupTraditionalResources();
        getLogger().i('✅ 使用传统设置');
      }
      
      // 渲染Markdown内容
      await _renderMarkdownContent();
      
      setState(() {
        isLoading = false;
      });
      
      getLogger().i('🎉 Markdown测试页面设置完成');
      
    } catch (e) {
      getLogger().e('❌ WebView设置失败: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _setupTraditionalResources() async {
    if (webViewController == null) return;
    
    try {
      final futures = [
        _loadAssetJs('assets/js/marked.min.js'),
        _loadAssetJs('assets/js/highlight.min.js'),
        _loadAssetCss('assets/js/typora_github.css'),
      ];
      
      await Future.wait(futures);
      
      // 配置marked
      await webViewController!.evaluateJavascript(source: '''
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
      
    } catch (e) {
      getLogger().e('❌ 传统资源设置失败: $e');
    }
  }

  Future<void> _loadAssetJs(String path) async {
    final js = await rootBundle.loadString(path);
    await webViewController!.evaluateJavascript(source: js);
  }

  Future<void> _loadAssetCss(String path) async {
    final css = await rootBundle.loadString(path);
    await webViewController!.evaluateJavascript(source: '''
      var style = document.getElementById('github-styles');
      if (style) {
        style.textContent = `${css.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`;
      }
    ''');
  }

  Future<void> _renderMarkdownContent() async {
    if (webViewController == null) return;
    
    try {
      await webViewController!.evaluateJavascript(source: '''
        if (typeof marked !== 'undefined' && marked.parse) {
          try {
            var content = `${testMarkdown.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`;
            var htmlContent = marked.parse(content);
            var contentDiv = document.getElementById('content');
            if (contentDiv) {
              contentDiv.innerHTML = '<div class="markdown-body">' + htmlContent + '</div>';
              contentDiv.classList.remove('loading');
              console.log('✅ Markdown内容渲染完成');
            }
          } catch (error) {
            console.error('❌ Markdown渲染失败:', error);
            document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px;"><h3>⚠️ 渲染失败</h3><p>' + error.message + '</p></div>';
          }
        } else {
          console.error('❌ marked.js 未加载');
          document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px;"><h3>⚠️ 渲染器未就绪</h3><p>Markdown解析器未加载</p></div>';
        }
      ''');
    } catch (e) {
      getLogger().e('❌ 渲染Markdown内容失败: $e');
    }
  }

  @override
  void dispose() {
    webViewController = null;
    super.dispose();
  }
} 
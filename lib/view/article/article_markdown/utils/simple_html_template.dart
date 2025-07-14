/// 简单的HTML模板生成器
/// 替代复杂的WebViewPoolManager，提供更可靠的维护性
class SimpleHtmlTemplate {
  /// 生成基础HTML模板
  /// 直接返回不依赖缓存的静态模板，避免复杂的状态管理
  static String generateHtmlTemplate() {
    return '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Markdown Content</title>
    <style id="github-styles"></style>
    <style>
        /* 平滑加载遮罩样式 */
        #smooth-loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(255, 255, 255, 0.95);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            transition: opacity 0.4s ease-out, visibility 0.4s ease-out;
            backdrop-filter: blur(8px);
        }
        
        #smooth-loading-overlay.hidden {
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
        }
        
        /* 加载动画 */
        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 3px solid rgba(34, 150, 243, 0.1);
            border-left: 3px solid #2196F3;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 16px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* 加载文本 */
        .loading-text {
            color: #2196F3;
            font-size: 14px;
            font-weight: 500;
            letter-spacing: 0.5px;
            animation: pulse 1.5s ease-in-out infinite alternate;
        }
        
        @keyframes pulse {
            0% { opacity: 0.7; }
            100% { opacity: 1; }
        }
        
        /* 基础重置和主题适配 background-color: #ccc !important; */
        :root {
            
            --text-color: #222;
            --font-size: 16px;
            --line-height: 1.6;
        }
        
        body {
            background-color: var(--background-color);
            color: var(--text-color, #222);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            
            margin: 0;
            padding: 20px;
            padding-top: 40px;
            padding-bottom: 60px;
            word-wrap: break-word;
            overflow-x: hidden; /* 防止水平滚动 */
            width: 100%;
            box-sizing: border-box;
        }
        
        /* CSS变量支持字体大小调整 */
        :root {
            --font-size: 16px;
            --line-height: 1.6;
        }
        
        /* Markdown内容容器 */
        #content {
            width: 100%;
            box-sizing: border-box;
            word-wrap: break-word;
            overflow-wrap: break-word;
            overflow-x: hidden; /* 防止内容溢出 */
            max-width: 100%; /* 确保不超出容器 */
        }
        
        /* 基础Markdown样式 */
        .markdown-body {
            font-size: var(--font-size);
            line-height: var(--line-height);
        }
        
        .markdown-body h1,
        .markdown-body h2,
        .markdown-body h3,
        .markdown-body h4,
        .markdown-body h5,
        .markdown-body h6 {
            margin-top: 24px;
            margin-bottom: 16px;
            font-weight: 600;
            line-height: 1.25;
        }
        
        .markdown-body h1 { font-size: 2.2em; }
        .markdown-body h2 { font-size: 1.7em; }
        .markdown-body h3 { font-size: 1.45em; }
        .markdown-body h4 { font-size: 1.2em; }
        .markdown-body h5 { font-size: 1.075em; }
        .markdown-body h6 { font-size: 1em; }
        
        .markdown-body p {
            margin-top: 0;
            margin-bottom: 16px;
            font-size: var(--font-size);
            line-height: var(--line-height);
        }
        
        .markdown-body blockquote {
            padding: 0 1em;
            color: #656d76;
            border-left: 0.25em solid #d1d9e0;
            margin: 16px 0;
            font-size: var(--font-size);
            line-height: var(--line-height);
        }
        
        .markdown-body ul,
        .markdown-body ol {
            margin-top: 0;
            margin-bottom: 16px;
            padding-left: 2em;
        }
        
        .markdown-body li {
            margin: 0.25em 0;
            font-size: var(--font-size);
            line-height: var(--line-height);
        }
        
        .markdown-body code {
            padding: 0.2em 0.4em;
            margin: 0;
            font-size: 100%;
            background-color: rgba(175,184,193,0.2);
            border-radius: 6px;
            font-family: ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
        }
        
        .markdown-body pre {
            padding: 16px;
            overflow: auto;
            font-size: 100%;
            line-height: 1.45;
            background-color: #f6f8fa;
            border-radius: 6px;
            margin: 16px 0;
        }
        
        .markdown-body pre code {
            display: inline;
            max-width: 100%;
            padding: 0;
            margin: 0;
            overflow: visible;
            line-height: inherit;
            word-wrap: break-word;
            overflow-wrap: break-word;
            background-color: transparent;
            border: 0;
        }
        
        /* 图片样式 */
        .markdown-body img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 16px auto;
            cursor: pointer;
            border-radius: 8px;
            box-sizing: border-box;
            overflow: hidden; /* 防止图片溢出 */
        }
        
        /* 表格样式 */
        .markdown-body table {
            border-spacing: 0;
            border-collapse: collapse;
            display: block;
            width: 100%;
            max-width: 100%;
            overflow-x: auto;
            margin: 16px 0;
            box-sizing: border-box;
        }
        
        .markdown-body table th,
        .markdown-body table td {
            padding: 6px 13px;
            border: 1px solid #d1d9e0;
            word-wrap: break-word;
            overflow-wrap: break-word;
            max-width: 200px; /* 限制单元格最大宽度 */
        }
        
        .markdown-body table th {
            font-weight: 600;
            background-color: #f6f8fa;
        }
        
        /* 链接样式 */
        .markdown-body a {
            color: #0969da;
            text-decoration: none;
        }
        
        .markdown-body a:hover {
            text-decoration: underline;
        }
        
        /* 水平分割线 */
        .markdown-body hr {
            height: 0.25em;
            padding: 0;
            margin: 24px 0;
            background-color: #d1d9e0;
            border: 0;
        }
        
        /* 防止所有元素溢出 */
        .markdown-body * {
            max-width: 100%;
            box-sizing: border-box;
        }
        
        /* 确保代码块不会溢出 */
        .markdown-body pre {
            white-space: pre-wrap;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        
        /* 确保内联代码不会溢出 */
        .markdown-body code:not(pre code) {
            white-space: normal;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        
    </style>

</head>
<body>
    <!-- 平滑加载遮罩 -->

    
    <!-- Markdown内容容器 -->
    <div id="content" class="markdown-body"></div>
    
    <!-- 基础Markdown解析器 - 使用本地资源，提供更可靠的加载 -->

    
        <!-- 备用的离线脚本加载和基础实现 -->
    <script>
        // 如果CDN加载失败，提供基础的Markdown解析功能
        if (typeof marked === 'undefined') {
            console.log('CDN加载失败，使用基础文本渲染...');
            
            // 提供一个最基本的文本显示功能
            window.marked = {
                parse: function(markdown) {
                    if (!markdown) return '';
                    // 简单地将换行符转换为HTML换行
                    return '<pre style="white-space: pre-wrap; font-family: inherit;">' + 
                           markdown.replace(/</g, '&lt;').replace(/>/g, '&gt;') + 
                           '</pre>';
                }
            };
        }
        
        // 如果highlight.js加载失败，提供空的highlight函数
        if (typeof hljs === 'undefined') {
            window.hljs = {
                getLanguage: function() { return false; },
                highlight: function(code) { return { value: code }; },
                highlightAuto: function(code) { return { value: code }; }
            };
        }
        
        // 配置marked
        if (typeof marked !== 'undefined') {
            marked.setOptions({
                highlight: function(code, lang) {
                    if (typeof hljs !== 'undefined' && lang && hljs.getLanguage(lang)) {
                        try {
                            return hljs.highlight(code, { language: lang }).value;
                        } catch (err) {
                            console.warn('代码高亮失败:', err);
                        }
                    }
                    return code;
                },
                langPrefix: 'hljs language-',
                breaks: true,
                gfm: true
            });
        }
        

        

        
        // 字体大小调整函数
        function updateFontSize(fontSize) {
            try {
                // 更新CSS变量
                document.documentElement.style.setProperty('--font-size', fontSize + 'px');
                
                // 计算合适的行高
                const lineHeight = Math.max(1.4, fontSize / 16);
                document.documentElement.style.setProperty('--line-height', lineHeight.toString());
                
                // 更新所有文本元素的字体大小
                const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote, pre, code');
                textElements.forEach(element => {
                    element.style.fontSize = fontSize + 'px';
                    element.style.lineHeight = lineHeight.toString();
                });
                
                console.log('✅ 字体大小更新成功:', fontSize + 'px');
                return true;
            } catch (error) {
                console.error('❌ 更新字体大小失败:', error);
                return false;
            }
        }
        window.updateFontSize = updateFontSize;
        
        console.log('✅ HTML模板初始化完成');
    </script>
    
    <script>
        // 平滑加载控制函数

      
    </script>
</body>
</html>''';
  }
  
} 
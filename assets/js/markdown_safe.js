/* 安全的 Markdown 配置脚本 - 避免所有类型错误 */
(function() {
  console.log('🛡️ 加载安全的 Markdown 配置...');

  // 安全的类型检查和转换函数
  function safeString(value, defaultValue = '') {
    if (value === null || value === undefined) {
      return defaultValue;
    }
    if (typeof value === 'string') {
      return value;
    }
    try {
      return String(value);
    } catch (e) {
      console.warn('字符串转换失败:', e);
      return defaultValue;
    }
  }

  function safeNumber(value, defaultValue = 0) {
    if (typeof value === 'number' && !isNaN(value)) {
      return value;
    }
    const parsed = parseInt(value);
    return isNaN(parsed) ? defaultValue : parsed;
  }

  // 安全的marked.js配置
  function configureSafeMarkdown() {
    if (typeof marked === 'undefined') {
      console.error('❌ marked.js 未加载');
      return false;
    }

    try {
      // 设置安全的marked选项
      marked.setOptions({
        highlight: function(code, language) {
          const safeCode = safeString(code);
          const safeLang = safeString(language);
          
          if (typeof hljs !== 'undefined' && safeCode) {
            try {
              if (safeLang && hljs.getLanguage(safeLang)) {
                return hljs.highlight(safeCode, { language: safeLang }).value;
              }
              return hljs.highlightAuto(safeCode).value;
            } catch (err) {
              console.warn('代码高亮失败:', err);
              return safeCode;
            }
          }
          return safeCode;
        },
        langPrefix: 'hljs language-',
        breaks: true,
        gfm: true,
        pedantic: false,
        sanitize: false,
        smartLists: true,
        smartypants: false, // 禁用智能标点，避免潜在问题
        xhtml: false
      });

      console.log('✅ 安全的 Markdown 配置完成');
      return true;
    } catch (e) {
      console.error('❌ Markdown 配置失败:', e);
      return false;
    }
  }

  // 渲染Markdown内容的安全函数
  window.safeRenderMarkdown = function(content, containerId) {
    try {
      const safeContent = safeString(content);
      const safeContainerId = safeString(containerId, 'content');
      
      if (!safeContent) {
        console.warn('⚠️ 内容为空，跳过渲染');
        return false;
      }

      if (typeof marked === 'undefined' || !marked.parse) {
        console.error('❌ marked.js 未就绪');
        return false;
      }

      const container = document.getElementById(safeContainerId);
      if (!container) {
        console.error('❌ 找不到容器元素:', safeContainerId);
        return false;
      }

      // 安全渲染
      const htmlContent = marked.parse(safeContent);
      container.innerHTML = '<div class="markdown-body">' + htmlContent + '</div>';
      
      // 安全的图片处理
      const images = container.querySelectorAll('.markdown-body img');
      images.forEach(function(img) {
        if (img && img.style) {
          img.style.maxWidth = '100%';
          img.style.height = 'auto';
          img.style.display = 'block';
          img.style.margin = '16px auto';
          img.style.cursor = 'pointer';
          
          // 添加图片点击事件
          img.addEventListener('click', function() {
            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              window.flutter_inappwebview.callHandler('onImageClicked', {
                src: safeString(img.src),
                alt: safeString(img.alt),
                width: safeNumber(img.naturalWidth),
                height: safeNumber(img.naturalHeight)
              });
            }
          });
        }
      });

      console.log('✅ Markdown 内容安全渲染完成，包含 ' + images.length + ' 张图片');
      return true;

    } catch (error) {
      console.error('❌ 安全渲染失败:', error);
      
      // 降级处理
      try {
        const container = document.getElementById(safeString(containerId, 'content'));
        if (container) {
          container.innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 内容渲染失败</h3><p>请刷新页面重试</p></div>';
        }
      } catch (fallbackError) {
        console.error('❌ 降级处理也失败了:', fallbackError);
      }
      
      return false;
    }
  };

  // 初始化函数
  function initializeSafeMarkdown() {
    try {
      const success = configureSafeMarkdown();
      if (success) {
        console.log('🛡️ 安全的 Markdown 功能初始化完成');
        
        // 通知 Flutter 端初始化完成
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler('onMarkdownReady', {
            status: 'success',
            version: 'safe',
            features: ['basic_rendering', 'code_highlighting', 'image_handling']
          });
        }
      } else {
        throw new Error('Markdown 配置失败');
      }
    } catch (e) {
      console.error('❌ 安全 Markdown 初始化失败:', e);
      
      // 通知 Flutter 端初始化失败
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('onMarkdownReady', {
          status: 'error',
          error: e.message
        });
      }
    }
  }

  // 等待DOM和marked.js都准备好
  function waitForDependencies() {
    const checkInterval = setInterval(function() {
      if (typeof marked !== 'undefined' && document.readyState === 'complete') {
        clearInterval(checkInterval);
        initializeSafeMarkdown();
      }
    }, 100);

    // 超时保护
    setTimeout(function() {
      clearInterval(checkInterval);
      if (typeof marked === 'undefined') {
        console.error('❌ marked.js 加载超时');
      }
    }, 10000);
  }

  // 立即开始检查或等待DOM加载完成
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', waitForDependencies);
  } else {
    waitForDependencies();
  }

})(); 
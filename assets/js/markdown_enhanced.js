/* Markdown 增强配置 - 支持更多高级功能 */
(function() {
  console.log('🚀 加载Markdown增强配置...');

  // 安全的字符串转换函数
  function safeString(value) {
    if (value === null || value === undefined) {
      return '';
    }
    return String(value);
  }

  // 配置marked.js的高级选项
  function configureMarkdown() {
    if (typeof marked === 'undefined') {
      console.error('❌ marked.js 未加载');
      return;
    }

    // 设置marked选项
    marked.setOptions({
      highlight: function(code, language) {
        if (typeof hljs !== 'undefined') {
          const safeCode = safeString(code);
          const safeLang = safeString(language);
          
          if (safeLang && hljs.getLanguage(safeLang)) {
            try {
              return hljs.highlight(safeCode, { language: safeLang }).value;
            } catch (err) {
              console.warn('代码高亮失败:', err);
              return safeCode;
            }
          }
          try {
            return hljs.highlightAuto(safeCode).value;
          } catch (err) {
            console.warn('自动代码高亮失败:', err);
            return safeCode;
          }
        }
        return safeString(code);
      },
      langPrefix: 'hljs language-',
      breaks: true,
      gfm: true,
      pedantic: false,
      sanitize: false,
      smartLists: true,
      smartypants: true,
      xhtml: false
    });

    // 添加自定义渲染器
    const renderer = new marked.Renderer();
    
    // 自定义标题渲染（添加锚点）
    renderer.heading = function(text, level) {
      const safeText = safeString(text);
      const safeLevel = parseInt(level) || 1;
      
      try {
        const anchor = safeText.toLowerCase().replace(/[^\w\u4e00-\u9fa5]+/g, '-');
        return `<h${safeLevel} id="${anchor}" class="heading-anchor">
          <a href="#${anchor}" class="anchor-link">#</a>
          ${safeText}
        </h${safeLevel}>`;
      } catch (e) {
        console.warn('标题渲染失败:', e);
        return `<h${safeLevel}>${safeText}</h${safeLevel}>`;
      }
    };

    // 自定义链接渲染（外部链接新窗口打开）
    renderer.link = function(href, title, text) {
      const safeHref = safeString(href);
      const safeTitle = safeString(title);
      const safeText = safeString(text);
      
      try {
        const isExternal = safeHref.startsWith('http') && !safeHref.includes(window.location.hostname);
        const target = isExternal ? ' target="_blank" rel="noopener noreferrer"' : '';
        const titleAttr = safeTitle ? ` title="${safeTitle}"` : '';
        return `<a href="${safeHref}"${titleAttr}${target}>${safeText}</a>`;
      } catch (e) {
        console.warn('链接渲染失败:', e);
        return `<a href="${safeHref}">${safeText}</a>`;
      }
    };

    // 自定义代码块渲染（添加复制按钮）
    renderer.code = function(code, language) {
      const safeCode = safeString(code);
      const safeLang = safeString(language);
      
      try {
        const validLang = safeLang && hljs.getLanguage(safeLang) ? safeLang : 'plaintext';
        const highlighted = hljs.highlight(safeCode, { language: validLang }).value;
        
        return `<div class="code-block-wrapper">
          <div class="code-header">
            <span class="code-language">${validLang}</span>
            <button class="copy-code-btn" onclick="copyToClipboard(this)" data-code="${safeCode.replace(/"/g, '&quot;')}">
              📋 复制
            </button>
          </div>
          <pre><code class="hljs language-${validLang}">${highlighted}</code></pre>
        </div>`;
      } catch (e) {
        console.warn('代码块渲染失败:', e);
        return `<pre><code>${safeCode}</code></pre>`;
      }
    };

    // 自定义表格渲染（响应式）
    renderer.table = function(header, body) {
      const safeHeader = safeString(header);
      const safeBody = safeString(body);
      
      return `<div class="table-wrapper">
        <table class="responsive-table">
          <thead>${safeHeader}</thead>
          <tbody>${safeBody}</tbody>
        </table>
      </div>`;
    };

    // 自定义引用块渲染
    renderer.blockquote = function(quote) {
      const safeQuote = safeString(quote);
      
      return `<blockquote class="enhanced-blockquote">
        <div class="quote-content">${safeQuote}</div>
      </blockquote>`;
    };

    // 自定义列表项渲染（支持任务列表）
    renderer.listitem = function(text) {
      const safeText = safeString(text);
      
      try {
        // 检查是否是任务列表
        const taskMatch = safeText.match(/^(\s*)<input\s+(type="checkbox")\s*(checked)?\s*>\s*(.*)$/);
        if (taskMatch) {
          const checked = taskMatch[3] ? 'checked' : '';
          const content = safeString(taskMatch[4]);
          return `<li class="task-list-item">
            <input type="checkbox" ${checked} disabled>
            <span class="task-content">${content}</span>
          </li>`;
        }
        return `<li>${safeText}</li>`;
      } catch (e) {
        console.warn('列表项渲染失败:', e);
        return `<li>${safeText}</li>`;
      }
    };

    marked.setOptions({ renderer: renderer });
    console.log('✅ Markdown增强配置完成');
  }

  // 复制代码功能
  window.copyToClipboard = function(button) {
    try {
      const code = safeString(button.getAttribute('data-code'));
      if (navigator.clipboard) {
        navigator.clipboard.writeText(code).then(() => {
          showCopySuccess(button);
        }).catch(err => {
          console.error('复制失败:', err);
          fallbackCopyTextToClipboard(code, button);
        });
      } else {
        fallbackCopyTextToClipboard(code, button);
      }
    } catch (e) {
      console.error('复制功能出错:', e);
    }
  };

  // 备用复制方法
  function fallbackCopyTextToClipboard(text, button) {
    try {
      const textArea = document.createElement("textarea");
      textArea.value = safeString(text);
      textArea.style.position = "fixed";
      textArea.style.left = "-999999px";
      textArea.style.top = "-999999px";
      document.body.appendChild(textArea);
      textArea.focus();
      textArea.select();
      
      try {
        document.execCommand('copy');
        showCopySuccess(button);
      } catch (err) {
        console.error('备用复制方法失败:', err);
      }
      
      document.body.removeChild(textArea);
    } catch (e) {
      console.error('备用复制方法出错:', e);
    }
  }

  // 显示复制成功提示
  function showCopySuccess(button) {
    try {
      const originalText = button.textContent;
      button.textContent = '✅ 已复制';
      button.classList.add('copied');
      
      setTimeout(() => {
        button.textContent = originalText;
        button.classList.remove('copied');
      }, 2000);
    } catch (e) {
      console.error('显示复制提示出错:', e);
    }
  }

  // 添加增强样式
  function addEnhancedStyles() {
    try {
      const style = document.createElement('style');
      style.textContent = `
        /* 代码块增强样式 */
        .code-block-wrapper {
          position: relative;
          margin: 16px 0;
          border-radius: 8px;
          overflow: hidden;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .code-header {
          background: #2d3748;
          color: #e2e8f0;
          padding: 8px 16px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-size: 12px;
          border-bottom: 1px solid #4a5568;
        }
        
        .code-language {
          font-weight: 600;
          text-transform: uppercase;
          color: #a0aec0;
        }
        
        .copy-code-btn {
          background: #4a5568;
          color: #e2e8f0;
          border: none;
          padding: 4px 8px;
          border-radius: 4px;
          cursor: pointer;
          font-size: 11px;
          transition: all 0.2s ease;
        }
        
        .copy-code-btn:hover {
          background: #2d3748;
          transform: translateY(-1px);
        }
        
        .copy-code-btn.copied {
          background: #38a169;
          color: white;
        }
        
        /* 表格增强样式 */
        .table-wrapper {
          overflow-x: auto;
          margin: 16px 0;
          border-radius: 8px;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .responsive-table {
          width: 100%;
          border-collapse: collapse;
          background: white;
        }
        
        .responsive-table th {
          background: #f7fafc;
          font-weight: 600;
          text-align: left;
          padding: 12px 16px;
          border-bottom: 2px solid #e2e8f0;
          position: sticky;
          top: 0;
          z-index: 1;
        }
        
        .responsive-table td {
          padding: 12px 16px;
          border-bottom: 1px solid #e2e8f0;
          vertical-align: top;
        }
        
        .responsive-table tr:hover {
          background: #f7fafc;
        }
        
        /* 标题锚点样式 */
        .heading-anchor {
          position: relative;
        }
        
        .anchor-link {
          position: absolute;
          left: -24px;
          top: 50%;
          transform: translateY(-50%);
          opacity: 0;
          color: #a0aec0;
          text-decoration: none;
          font-weight: normal;
          transition: opacity 0.2s ease;
        }
        
        .heading-anchor:hover .anchor-link {
          opacity: 1;
        }
        
        /* 引用块增强样式 */
        .enhanced-blockquote {
          border-left: 4px solid #4299e1;
          background: linear-gradient(90deg, rgba(66, 153, 225, 0.1) 0%, transparent 100%);
          margin: 24px 0;
          padding: 16px 20px;
          border-radius: 0 8px 8px 0;
          position: relative;
        }
        
        .enhanced-blockquote::before {
          content: '"';
          font-size: 48px;
          color: #4299e1;
          position: absolute;
          left: 16px;
          top: 8px;
          opacity: 0.3;
          font-family: Georgia, serif;
          line-height: 1;
        }
        
        .quote-content {
          padding-left: 32px;
          font-style: italic;
          color: #2d3748;
        }
        
        /* 任务列表样式 */
        .task-list-item {
          list-style: none;
          padding-left: 0;
          margin: 8px 0;
          display: flex;
          align-items: flex-start;
        }
        
        .task-list-item input[type="checkbox"] {
          margin-right: 8px;
          margin-top: 2px;
          transform: scale(1.2);
          accent-color: #4299e1;
        }
        
        .task-content {
          flex: 1;
        }
        
        /* 移动端优化 */
        @media (max-width: 768px) {
          .anchor-link {
            display: none;
          }
          
          .code-header {
            padding: 6px 12px;
            font-size: 11px;
          }
          
          .copy-code-btn {
            padding: 3px 6px;
            font-size: 10px;
          }
          
          .responsive-table th,
          .responsive-table td {
            padding: 8px 12px;
            font-size: 14px;
          }
          
          .enhanced-blockquote {
            padding: 12px 16px;
          }
          
          .enhanced-blockquote::before {
            font-size: 36px;
            left: 12px;
            top: 6px;
          }
          
          .quote-content {
            padding-left: 24px;
          }
        }
      `;
      document.head.appendChild(style);
    } catch (e) {
      console.error('添加增强样式失败:', e);
    }
  }

  // 初始化增强功能
  function initializeEnhancements() {
    try {
      configureMarkdown();
      addEnhancedStyles();
      
      // 监听动态内容加载
      const observer = new MutationObserver((mutations) => {
        try {
          mutations.forEach((mutation) => {
            if (mutation.type === 'childList') {
              // 检查新添加的代码块
              mutation.addedNodes.forEach((node) => {
                if (node.nodeType === 1) { // 元素节点
                  const codeBlocks = node.querySelectorAll ? node.querySelectorAll('pre code') : [];
                  codeBlocks.forEach((block) => {
                    // 为代码块添加增强功能
                    if (!block.classList.contains('enhanced')) {
                      block.classList.add('enhanced');
                      // 可以在这里添加更多增强功能
                    }
                  });
                }
              });
            }
          });
        } catch (e) {
          console.error('内容观察器出错:', e);
        }
      });
      
      // 开始观察文档变化
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
      
      console.log('✅ Markdown增强功能初始化完成');
    } catch (e) {
      console.error('❌ Markdown增强功能初始化失败:', e);
    }
  }

  // 确保在DOM加载完成后初始化
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeEnhancements);
  } else {
    initializeEnhancements();
  }

})(); 
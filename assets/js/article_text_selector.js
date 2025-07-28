(function() {
  'use strict';
  console.log('🎯 v2.2 注入文字选择处理脚本 - 修复跨段选择问题');
  
  if (window.flutter_text_selector && window.flutter_text_selector.version === '2.2') {
    console.log('⚠️ 脚本v2.2已注入，跳过重复执行');
    return;
  }

  let selectionTimeout = null;
  
  // =================================================================================
  // 事件监听与选择处理 (v2.1 修复版)
  // =================================================================================
  
  document.addEventListener('selectionchange', () => {
    // 防抖处理：如果用户持续选择，则不断重置计时器
    if (selectionTimeout) {
      clearTimeout(selectionTimeout);
    }

    selectionTimeout = setTimeout(() => {
      const selection = window.getSelection();
      
      // 检查是否存在有效且未折叠的选择
      if (selection && !selection.isCollapsed && selection.toString().trim().length > 1) {
        // 选择稳定，显示操作栏
        try {
          const range = selection.getRangeAt(0);
          const rect = range.getBoundingClientRect();
          
          if (rect.width > 0 || rect.height > 0) { // 确保选区可见
            const selectionData = {
              text: selection.toString().trim(),
              x: rect.left,
              y: rect.top,
              width: rect.width,
              height: rect.height
            };
            notifyFlutter('onTextSelected', selectionData);
          }
        } catch (error) {
          console.error('❌ 处理稳定选择失败:', error);
        }
      } else {
        // 选择已清除或无效，隐藏操作栏
        notifyFlutter('onSelectionCleared', {});
      }
    }, 200); // 200毫秒的防抖延迟
  }, true);

  // 监听单击事件，以确保能快速清除选择
  document.addEventListener('click', () => {
    const selection = window.getSelection();
    if (selection && selection.isCollapsed) {
      notifyFlutter('onSelectionCleared', {});
    }
  }, true);


  // =================================================================================
  // 核心功能：创建、应用高亮 (v2.0代码保持不变)
  // =================================================================================
  
  /**
   * 将当前选中的文本用一个元素包裹起来，并返回包含上下文信息的标注数据
   * @param {function(string): HTMLElement} elementCreator - 一个返回包裹元素的函数
   * @param {string} eventName - 要通知Flutter的事件名
   */
  function _wrapSelectionAndNotify(elementCreator, eventName) {
    const selection = window.getSelection();
    if (!selection || selection.toString().trim().length === 0) {
      console.warn(`⚠️ ${eventName}: 没有选中的文字`);
      return;
    }

    try {
      const range = selection.getRangeAt(0);
      const selectedText = selection.toString();

      // 添加详细的调试信息
      console.log(`🔍 ${eventName} 调试信息:`, {
        selectedText: selectedText,
        startContainer: range.startContainer.nodeName,
        endContainer: range.endContainer.nodeName,
        startOffset: range.startOffset,
        endOffset: range.endOffset,
        isCollapsed: range.collapsed,
        isCrossElement: range.startContainer !== range.endContainer
      });

      const highlightElement = elementCreator(selectedText);
      
      // 获取上下文信息
      const context = getContextForRange(range, 50);
      
      // 使用更安全的方式包裹内容 - 支持跨标签选择
      const success = safeWrapRange(range, highlightElement);
      
      if (!success) {
        console.error(`❌ ${eventName}: 无法安全包裹选中的内容`);
        return;
      }
      
      selection.removeAllRanges();
      
      const annotationData = {
        id: highlightElement.dataset.highlightId,
        text: selectedText.trim(),
        beforeContext: context.before,
        afterContext: context.after,
        color: highlightElement.style.backgroundColor || '',
        note: highlightElement.dataset.noteText || null,
      };

      console.log(`✅ ${eventName} 成功:`, annotationData.id);
      notifyFlutter(eventName, annotationData);

    } catch (error) {
      console.error(`❌ ${eventName} 失败:`, error);
    }
  }
  
  /**
   * 安全地包裹Range内容，支持跨标签选择 - 优化版本
   * @param {Range} range - 要包裹的范围
   * @param {HTMLElement} wrapperElement - 包裹元素
   * @returns {boolean} - 是否成功
   */
  function safeWrapRange(range, wrapperElement) {
    // 检查选择是否有效
    if (!range || range.collapsed) {
      console.warn('⚠️ 选择范围无效或已折叠');
      return false;
    }

    // 检查是否为跨标签选择
    const isComplexSelection = (
      range.startContainer !== range.endContainer ||
      range.startContainer.nodeType !== Node.TEXT_NODE ||
      range.endContainer.nodeType !== Node.TEXT_NODE ||
      range.startContainer.parentElement !== range.endContainer.parentElement
    );

    if (isComplexSelection) {
      console.log('🔍 检测到复杂选择，直接使用复杂包裹方法');
      return complexWrapRange(range, wrapperElement);
    }

    try {
      // 对于简单选择，首先尝试 surroundContents 方法
      const clonedRange = range.cloneRange();
      clonedRange.surroundContents(wrapperElement);
      console.log('✅ 简单包裹成功');
      return true;
    } catch (error) {
      console.log('⚠️ 简单包裹失败，尝试复杂包裹方法:', error.message);
      
      try {
        // 如果简单方法失败，使用复杂方法
        return complexWrapRange(range, wrapperElement);
      } catch (complexError) {
        console.error('❌ 复杂包裹也失败:', complexError);
        return false;
      }
    }
  }

  /**
   * 复杂的Range包裹方法，能处理跨标签选择 - 修复版本
   * @param {Range} range - 要包裹的范围
   * @param {HTMLElement} wrapperElement - 包裹元素
   * @returns {boolean} - 是否成功
   */
  function complexWrapRange(range, wrapperElement) {
    try {
      // 检查是否跨越多个元素
      const startContainer = range.startContainer;
      const endContainer = range.endContainer;
      
      // 如果是跨标签选择，使用更复杂但安全的逐步处理方法
      if (startContainer !== endContainer || 
          startContainer.nodeType !== Node.TEXT_NODE || 
          endContainer.nodeType !== Node.TEXT_NODE) {
        
        console.log('🔄 检测到跨标签选择，使用安全分段处理...');
        return handleCrossTagSelection(range, wrapperElement);
      }
      
      // 对于简单的单一文本节点选择，直接使用 extractContents
      const contents = range.extractContents();
      // 添加空值检查，防止appendChild错误
      if (wrapperElement && contents) {
        wrapperElement.appendChild(contents);
        range.insertNode(wrapperElement);
      } else {
        console.error('❌ wrapperElement或contents为null，无法包裹内容:', { wrapperElement, contents });
        return false;
      }
      
      return true;
    } catch (error) {
      console.error('❌ complexWrapRange 失败:', error);
      return false;
    }
  }

  /**
   * 处理跨标签选择的安全方法
   * @param {Range} range - 要包裹的范围
   * @param {HTMLElement} wrapperElement - 包裹元素
   * @returns {boolean} - 是否成功
   */
  function handleCrossTagSelection(range, wrapperElement) {
    try {
      // 创建一个文档片段来收集所有内容
      const fragment = document.createDocumentFragment();
      
      // 使用 cloneContents 而不是 extractContents 来避免移除原始内容
      const clonedContents = range.cloneContents();
      
      // 将克隆的内容添加到包裹元素
      // 添加空值检查，防止appendChild错误
      if (wrapperElement && clonedContents) {
        wrapperElement.appendChild(clonedContents);
      } else {
        console.error('❌ wrapperElement或clonedContents为null，无法处理跨标签选择:', { wrapperElement, clonedContents });
        return false;
      }
      
      // 记录原始选择的文本内容，用于后续验证
      const originalText = range.toString();
      
      // 现在删除原始内容并插入包裹元素
      range.deleteContents();
      range.insertNode(wrapperElement);
      
      // 验证高亮后的文本是否保持完整
      const highlightedText = wrapperElement.textContent;
      if (highlightedText !== originalText) {
        console.warn('⚠️ 高亮后文本内容发生变化');
        console.log('原始文本:', originalText);
        console.log('高亮文本:', highlightedText);
      }
      
      console.log('✅ 跨标签选择处理成功');
      return true;
      
    } catch (error) {
      console.error('❌ 跨标签选择处理失败:', error);
      
      // 如果失败，尝试回退到最基本的方式
      try {
        console.log('🔄 尝试回退处理方式...');
        return handleCrossTagSelectionFallback(range, wrapperElement);
      } catch (fallbackError) {
        console.error('❌ 回退处理也失败:', fallbackError);
        return false;
      }
    }
  }

  /**
   * 跨标签选择的回退处理方法
   * @param {Range} range - 要包裹的范围
   * @param {HTMLElement} wrapperElement - 包裹元素
   * @returns {boolean} - 是否成功
   */
  function handleCrossTagSelectionFallback(range, wrapperElement) {
    // 获取选择的文本内容
    const selectedText = range.toString();
    
    // 创建一个简单的文本节点
    const textNode = document.createTextNode(selectedText);
    // 添加空值检查，防止appendChild错误
    if (wrapperElement && textNode) {
      wrapperElement.appendChild(textNode);
    } else {
      console.error('❌ wrapperElement或textNode为null，无法处理回退方案:', { wrapperElement, textNode });
      return false;
    }
    
    // 删除原始内容并插入包裹元素
    range.deleteContents();
    range.insertNode(wrapperElement);
    
    console.log('✅ 使用回退方法处理跨标签选择');
    return true;
  }

  /**
   * 应用高亮到指定节点 - 改进版，支持跨标签
   */
  function applyHighlightToNode(textNode, searchIndex, anno) {
    try {
      const range = document.createRange();
      range.setStart(textNode, searchIndex);
      range.setEnd(textNode, searchIndex + anno.selectedText.length);
      
      const span = document.createElement('span');
      span.className = anno.note && anno.note.trim() !== '' ? 'flutter-note flutter-highlight' : 'flutter-highlight';
      span.dataset.highlightId = anno.highlightId;
      if(anno.note && anno.note.trim() !== '') {
        span.dataset.noteText = anno.note;
        span.style.backgroundColor = 'rgba(255, 229, 100, 0.5)';
        span.style.borderBottom = '2px dotted #ffc107';
      } else {
        span.style.backgroundColor = 'yellow'; 
      }
      
      // 使用安全的包裹方法
      const success = safeWrapRange(range, span);
      
      if (success) {
        console.log(`✅ 成功恢复标注: "${anno.selectedText}"`);
        return true;
      } else {
        console.error(`❌ 无法安全包裹标注: "${anno.selectedText}"`);
        return false;
      }
    } catch (error) {
      console.error(`❌ 应用标注失败: "${anno.selectedText}"`, error);
      return false;
    }
  }

  /**
   * 高亮当前选中的文字
   * @param {string} color - 高亮颜色
   */
  function highlightSelection(color = 'yellow') {
    _wrapSelectionAndNotify(
      (selectedText) => {
        const span = document.createElement('span');
        span.className = 'flutter-highlight';
        span.style.backgroundColor = color;
        span.dataset.highlightId = generateUniqueId('highlight');
        return span;
      },
      'onTextHighlighted'
    );
  }

  /**
   * 为当前选中的文字添加笔记
   * @param {string} noteText - 笔记内容
   */
  function addNoteToSelection(noteText) {
    _wrapSelectionAndNotify(
      (selectedText) => {
        const span = document.createElement('span');
        span.className = 'flutter-note flutter-highlight';
        span.style.backgroundColor = 'rgba(255, 229, 100, 0.5)';
        span.style.borderBottom = '2px dotted #ffc107';
        span.dataset.highlightId = generateUniqueId('note');
        span.dataset.noteText = noteText;
        return span;
      },
      'onNoteAdded'
    );
  }

  /**
   * 在页面加载后，根据数据库数据恢复所有高亮和笔记
   * @param {string} annotationsJson - 包含所有标注对象的JSON字符串
   */
  function applyAnnotations(annotationsJson) {
    console.log('🔄 开始恢复历史标注...', annotationsJson);
    let annotations;
    try {
      annotations = JSON.parse(annotationsJson);
    } catch (e) {
      console.error('❌ 解析标注JSON失败:', e, annotationsJson);
      return;
    }

    if (!annotations || annotations.length === 0) {
      console.log('ℹ️ 无历史标注需要恢复');
      return;
    }
    
    console.log('📊 准备恢复', annotations.length, '个标注');
    
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
    let node;
    const textNodes = [];
    while(node = walker.nextNode()) {
      if (node.parentElement.tagName !== 'SCRIPT' && node.parentElement.tagName !== 'STYLE') {
        textNodes.push(node);
      }
    }
    
    console.log('📄 找到', textNodes.length, '个文本节点');
    
    let appliedCount = 0;
    annotations.forEach((anno, index) => {
      console.log(`🔍 处理标注 ${index + 1}:`, anno.selectedText);
      
      // 尝试多种匹配策略
      let matched = false;
      
      // 策略1: 精确匹配（原有逻辑）
      matched = tryExactMatch(textNodes, anno, index);
      
      // 策略2: 如果精确匹配失败，尝试简单文本匹配
      if (!matched) {
        matched = trySimpleTextMatch(textNodes, anno, index);
      }
      
      // 策略3: 如果还是失败，尝试跨节点匹配
      if (!matched) {
        matched = tryCrossNodeMatch(textNodes, anno, index);
      }
      
      if (matched) {
        appliedCount++;
      }
    });
    console.log(`🎉 ${appliedCount}/${annotations.length} 个历史标注已恢复`);
  }

  /**
   * 策略1: 精确上下文匹配
   */
  function tryExactMatch(textNodes, anno, index) {
    for (let i = 0; i < textNodes.length; i++) {
      const textNode = textNodes[i];
      if (!textNode.nodeValue) continue;
      const fullText = textNode.nodeValue;
      
      let searchIndex = fullText.indexOf(anno.selectedText);
      if (searchIndex === -1) continue;

      console.log(`📍 在节点 ${i} 中找到文本 "${anno.selectedText}"`);
      
      let contextMatches = true;
      
      if (anno.beforeContext && anno.beforeContext.trim() !== '') {
        const beforeNodeText = fullText.substring(0, searchIndex);
        if (!beforeNodeText.includes(anno.beforeContext.trim())) {
          console.log(`⚠️ 前文上下文不匹配: "${beforeNodeText}" 不包含 "${anno.beforeContext}"`);
          contextMatches = false;
        }
      }
      
      if (contextMatches && anno.afterContext && anno.afterContext.trim() !== '') {
        const afterNodeText = fullText.substring(searchIndex + anno.selectedText.length);
        if (!afterNodeText.includes(anno.afterContext.trim())) {
          console.log(`⚠️ 后文上下文不匹配: "${afterNodeText}" 不包含 "${anno.afterContext}"`);
          contextMatches = false;
        }
      }
      
      if (contextMatches) {
        return applyHighlightToNode(textNode, searchIndex, anno);
      }
    }
    return false;
  }

  /**
   * 策略2: 简单文本匹配（忽略上下文）
   */
  function trySimpleTextMatch(textNodes, anno, index) {
    console.log(`🔄 尝试简单文本匹配策略 (标注 ${index + 1})`);
    
    for (let i = 0; i < textNodes.length; i++) {
      const textNode = textNodes[i];
      if (!textNode.nodeValue) continue;
      const fullText = textNode.nodeValue;
      
      let searchIndex = fullText.indexOf(anno.selectedText);
      if (searchIndex === -1) continue;

      // 检查这个文本是否已经被高亮过了
      if (textNode.parentElement.classList.contains('flutter-highlight')) {
        console.log(`⚠️ 文本已被高亮，跳过: "${anno.selectedText}"`);
        continue;
      }

      console.log(`✨ 简单匹配成功 (节点 ${i}): "${anno.selectedText}"`);
      return applyHighlightToNode(textNode, searchIndex, anno);
    }
    return false;
  }

  /**
   * 策略3: 跨节点匹配（将来可以实现）
   */
  function tryCrossNodeMatch(textNodes, anno, index) {
    console.log(`🔄 跨节点匹配暂未实现 (标注 ${index + 1})`);
    return false;
  }

  // =================================================================================
  // 辅助函数 (v2.0代码保持不变)
  // =================================================================================

  function getContextForRange(range, length) {
    const beforeRange = document.createRange();
    beforeRange.setStart(document.body, 0);
    beforeRange.setEnd(range.startContainer, range.startOffset);
    
    const afterRange = document.createRange();
    afterRange.setStart(range.endContainer, range.endOffset);
    afterRange.setEnd(document.body, document.body.childNodes.length);
    
    let before = beforeRange.toString();
    let after = afterRange.toString();

    before = before.slice(-length).replace(/\s+/g, ' ').trim();
    after = after.slice(0, length).replace(/\s+/g, ' ').trim();

    return { before, after };
  }
  
  function generateUniqueId(prefix) {
    return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  function notifyFlutter(handlerName, data) {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler(handlerName, data);
    } else {
      console.warn('⚠️ Flutter通信渠道不可用');
    }
  }

  // =================================================================================
  // 暴露公共API
  // =================================================================================
  window.flutter_text_selector = {
    version: '2.2',
    highlightSelection,
    addNoteToSelection,
    applyAnnotations
  };

})(); 
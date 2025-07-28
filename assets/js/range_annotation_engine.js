/**
 * 基于Range API的精确文本标注引擎
 * 支持跨段落选择、精确定位和标注恢复
 */
class RangeAnnotationEngine {
  constructor() {
    this.annotations = new Map();
    this.xpathCache = new Map();
    this.isInitialized = false;
    this.selectionTimeout = null;
    this.lastSelection = null;
    
    this.init();
  }
  
  init() {
    if (this.isInitialized) return;
    
    console.log('🚀 Range标注引擎初始化...');
    this.setupEventListeners();
    this.setupStyles();
    this.isInitialized = true;
    console.log('✅ Range标注引擎初始化完成');
  }
  
  setupEventListeners() {
    // 监听选择变化
    document.addEventListener('selectionchange', this.handleSelectionChange.bind(this));
    
    // 处理移动端长按
    this.setupMobileEvents();
    
    // 处理点击事件（用于清除选择）
    document.addEventListener('click', this.handleDocumentClick.bind(this));
    
    // 增加定时检查机制，确保不遗漏选择事件
    this.setupPeriodicCheck();
  }
  
  setupPeriodicCheck() {
    setInterval(() => {
      const selection = window.getSelection();
      if (selection && selection.toString().trim().length > 0) {
        // 如果检测到选择但没有处理过，主动处理
        const range = selection.getRangeAt(0);
        const selectionData = this.extractRangeData(range);
        
        if (selectionData && !this.isSameSelection(selectionData)) {
          console.log('🔄 定时检查发现新选择，主动处理');
          this.processSelectionChange();
        }
      }
    }, 500);
  }
  
  setupMobileEvents() {
    let touchStartTime = 0;
    let touchStartPos = null;
    let longPressTimer = null;
    
    document.addEventListener('touchstart', (e) => {
      touchStartTime = Date.now();
      touchStartPos = { x: e.touches[0].clientX, y: e.touches[0].clientY };
      
      // 清除之前的长按定时器
      if (longPressTimer) {
        clearTimeout(longPressTimer);
      }
      
      // 设置长按检测
      longPressTimer = setTimeout(() => {
        console.log('⏰ 长按定时器触发，检查选择状态...');
        const selection = window.getSelection();
        if (selection && selection.toString().trim().length > 0) {
          console.log('📱 长按检测到文本选择:', selection.toString().substring(0, 30));
          this.handleLongPress(e);
        } else {
          console.log('📱 长按时未检测到文本选择');
        }
      }, 500);
    });
    
    document.addEventListener('touchmove', (e) => {
      if (touchStartPos) {
        const currentPos = { x: e.touches[0].clientX, y: e.touches[0].clientY };
        const distance = Math.sqrt(
          Math.pow(currentPos.x - touchStartPos.x, 2) + 
          Math.pow(currentPos.y - touchStartPos.y, 2)
        );
        
        // 如果移动超过阈值，取消长按检测
        if (distance > 10 && longPressTimer) {
          clearTimeout(longPressTimer);
          longPressTimer = null;
        }
      }
    });
    
    document.addEventListener('touchend', (e) => {
      if (longPressTimer) {
        clearTimeout(longPressTimer);
        longPressTimer = null;
      }
      
      // 多次检查选择状态，确保捕获到文本选择
      const checkSelection = (attempts = 0) => {
        const selection = window.getSelection();
        if (selection && selection.toString().trim().length > 0) {
          console.log('📱 touchend检测到文本选择:', selection.toString());
          this.handleSelectionComplete();
        } else if (attempts < 3) {
          // 如果没有检测到选择，再尝试几次
          setTimeout(() => checkSelection(attempts + 1), 50 * (attempts + 1));
        }
      };
      
      setTimeout(() => checkSelection(), 100);
    });
  }
  
  setupStyles() {
    if (document.getElementById('range-annotation-styles')) return;
    
    const style = document.createElement('style');
    style.id = 'range-annotation-styles';
    style.textContent = `
      .range-highlight {
        background: linear-gradient(104deg, 
          rgba(255, 255, 0, 0.3) 0.9%, 
          rgba(255, 255, 0, 0.7) 2.4%, 
          rgba(255, 255, 0, 0.3) 5.8%, 
          rgba(255, 255, 0, 0.3) 93%, 
          rgba(255, 255, 0, 0.7) 96%, 
          rgba(255, 255, 0, 0.3) 98%);
        border-radius: 2px;
        position: relative;
        cursor: pointer;
      }
      
      .range-highlight.highlight-yellow {
        background: rgba(255, 255, 0, 0.4);
      }
      
      .range-highlight.highlight-green {
        background: rgba(0, 255, 0, 0.3);
      }
      
      .range-highlight.highlight-blue {
        background: rgba(0, 150, 255, 0.3);
      }
      
      .range-highlight.highlight-pink {
        background: rgba(255, 0, 150, 0.3);
      }
      
      .range-highlight.highlight-red {
        background: rgba(255, 0, 0, 0.3);
      }
      
      .range-highlight.highlight-purple {
        background: rgba(150, 0, 255, 0.3);
      }
      
      .range-highlight.with-note {
        border-bottom: 2px dotted #ff9800;
      }
      
      .range-highlight.cross-paragraph {
        box-shadow: 0 0 0 1px rgba(255, 255, 0, 0.5);
      }
      
      .range-selection-active {
        user-select: text;
      }
    `;
    // 添加空值检查，防止appendChild错误
    if (document.head && style) {
      document.head.appendChild(style);
    } else {
      console.error('❌ document.head或style为null，无法添加样式');
    }
  }
  
  handleSelectionChange() {
    // 防抖处理
    if (this.selectionTimeout) {
      clearTimeout(this.selectionTimeout);
    }
    
    this.selectionTimeout = setTimeout(() => {
      this.processSelectionChange();
    }, 150);
  }
  
    processSelectionChange() {
    const selection = window.getSelection();
    
    if (!selection || selection.rangeCount === 0 || selection.toString().trim() === '') {
      console.log('🔍 没有检测到有效选择，清除选择状态');
      this.notifySelectionCleared();
      this.lastSelection = null;
      return;
    }

    const selectedText = selection.toString().trim();
    console.log('🔍 检测到文本选择:', selectedText.substring(0, 50) + '...');

    const range = selection.getRangeAt(0);
    const selectionData = this.extractRangeData(range);
    
    if (!selectionData) {
      console.error('❌ 提取选择数据失败');
      return;
    }
    
    // 避免重复处理相同的选择
    if (this.isSameSelection(selectionData)) {
      console.log('🔄 相同选择，跳过处理');
      return;
    }

    console.log('✅ 处理新的文本选择，长度:', selectedText.length);
    this.lastSelection = selectionData;
    this.notifyTextSelected(selectionData);
  }
  
  isSameSelection(newSelection) {
    if (!this.lastSelection) return false;
    
    return this.lastSelection.selectedText === newSelection.selectedText &&
           this.lastSelection.startXPath === newSelection.startXPath &&
           this.lastSelection.startOffset === newSelection.startOffset;
  }
  
  handleLongPress(event) {
    console.log('📱 检测到长按事件');
    // 长按时主动检查选择状态
    setTimeout(() => {
      this.processSelectionChange();
    }, 100);
  }
  
  handleSelectionComplete() {
    console.log('✅ 选择完成');
    // 选择完成时主动检查选择状态
    setTimeout(() => {
      this.processSelectionChange();
    }, 100);
  }
  
  handleDocumentClick(event) {
    // 如果点击的不是高亮元素，清除选择
    if (!event.target.closest('.range-highlight')) {
      const selection = window.getSelection();
      if (selection && selection.toString().length === 0) {
        this.notifySelectionCleared();
      }
    }
  }
  
  extractRangeData(range) {
    try {
      const rect = range.getBoundingClientRect();
      
      // 获取选择区域的中心点，用于更精确的位置计算
      const centerX = rect.left + (rect.width / 2);
      const centerY = rect.top + (rect.height / 2);
      
      return {
        // Range定位信息
        startXPath: this.getXPathForNode(range.startContainer),
        startOffset: range.startOffset,
        endXPath: this.getXPathForNode(range.endContainer),
        endOffset: range.endOffset,
        
        // 文本信息
        selectedText: range.toString(),
        beforeContext: this.getContextBefore(range, 100),
        afterContext: this.getContextAfter(range, 100),
        
        // 位置信息 - 使用相对于视口的位置，不加滚动偏移
        boundingRect: {
          x: rect.left,
          y: rect.top,
          width: rect.width,
          height: rect.height,
          centerX: centerX,
          centerY: centerY,
          right: rect.right,
          bottom: rect.bottom
        },
        
        // 滚动信息 - 单独提供，便于Flutter端处理
        scrollInfo: {
          scrollX: window.pageXOffset || document.documentElement.scrollLeft || 0,
          scrollY: window.pageYOffset || document.documentElement.scrollTop || 0
        },
        
        // 元数据
        rangeId: this.generateRangeId(range),
        crossParagraph: this.isCrossParagraph(range),
        timestamp: Date.now()
      };
    } catch (error) {
      console.error('❌ 提取Range数据失败:', error);
      return null;
    }
  }
  
  getXPathForNode(node) {
    if (!node) return '';
    
    // 检查缓存
    const cacheKey = this.getNodeKey(node);
    if (this.xpathCache.has(cacheKey)) {
      return this.xpathCache.get(cacheKey);
    }
    
    if (node.nodeType === Node.DOCUMENT_NODE) return '/';
    
    const parts = [];
    let current = node;
    
    while (current && current !== document) {
      let index = 1;
      let sibling = current.previousSibling;
      
      while (sibling) {
        if (sibling.nodeType === current.nodeType && 
            sibling.nodeName === current.nodeName) {
          index++;
        }
        sibling = sibling.previousSibling;
      }
      
      const nodeName = current.nodeType === Node.TEXT_NODE ? 
        'text()' : current.nodeName.toLowerCase();
      parts.unshift(`${nodeName}[${index}]`);
      current = current.parentNode;
    }
    
    const xpath = '/' + parts.join('/');
    
    // 缓存结果
    this.xpathCache.set(cacheKey, xpath);
    
    return xpath;
  }
  
  getNodeKey(node) {
    // 为节点生成一个简单的键值用于缓存
    return `${node.nodeType}_${node.nodeName}_${node.textContent?.substring(0, 50) || ''}`;
  }
  
  getNodeByXPath(xpath) {
    try {
      const result = document.evaluate(
        xpath, document, null, 
        XPathResult.FIRST_ORDERED_NODE_TYPE, null
      );
      return result.singleNodeValue;
    } catch (error) {
      console.error('❌ XPath查询失败:', xpath, error);
      return null;
    }
  }
  
  getContextBefore(range, maxLength = 100) {
    try {
      const startNode = range.startContainer;
      const startOffset = range.startOffset;
      
      // 创建一个范围来获取前文
      const beforeRange = document.createRange();
      beforeRange.selectNodeContents(document.body);
      beforeRange.setEnd(startNode, startOffset);
      
      const beforeText = beforeRange.toString();
      return beforeText.length > maxLength ? 
        beforeText.substring(beforeText.length - maxLength) : beforeText;
    } catch (error) {
      console.warn('⚠️ 获取前文失败:', error);
      return '';
    }
  }
  
  getContextAfter(range, maxLength = 100) {
    try {
      const endNode = range.endContainer;
      const endOffset = range.endOffset;
      
      // 创建一个范围来获取后文
      const afterRange = document.createRange();
      afterRange.setStart(endNode, endOffset);
      afterRange.selectNodeContents(document.body);
      
      const afterText = afterRange.toString();
      return afterText.length > maxLength ? 
        afterText.substring(0, maxLength) : afterText;
    } catch (error) {
      console.warn('⚠️ 获取后文失败:', error);
      return '';
    }
  }
  
  generateRangeId(range) {
    const text = range.toString();
    const startPath = this.getXPathForNode(range.startContainer);
    const timestamp = Date.now();
    return `range_${text.length}_${startPath.length}_${timestamp}`;
  }
  
  isCrossParagraph(range) {
    const blockElements = ['P', 'DIV', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'LI', 'BLOCKQUOTE'];
    
    try {
      const walker = document.createTreeWalker(
        range.commonAncestorContainer,
        NodeFilter.SHOW_ELEMENT,
        {
          acceptNode: (node) => {
            return range.intersectsNode(node) ? 
              NodeFilter.FILTER_ACCEPT : 
              NodeFilter.FILTER_SKIP;
          }
        }
      );
      
      let blockCount = 0;
      let node;
      while (node = walker.nextNode()) {
        if (blockElements.includes(node.tagName)) {
          blockCount++;
          if (blockCount > 1) return true;
        }
      }
      
      return false;
    } catch (error) {
      console.warn('⚠️ 跨段落检测失败:', error);
      return false;
    }
  }
  
  // 创建高亮标注
  createHighlight(rangeData, highlightId, colorClass = 'highlight-yellow', noteContent = null) {
    try {
      console.log('🎨 创建高亮:', highlightId, colorClass);
      
      const range = this.recreateRange(rangeData);
      if (!range) {
        console.error('❌ 无法重建Range，高亮创建失败');
        return false;
      }
      
      const success = rangeData.crossParagraph ?
        this.createCrossParagraphHighlight(range, highlightId, colorClass, noteContent) :
        this.createSimpleHighlight(range, highlightId, colorClass, noteContent);
      
      if (success) {
        this.annotations.set(highlightId, {
          rangeData,
          colorClass,
          noteContent,
          createdAt: Date.now()
        });
        console.log('✅ 高亮创建成功:', highlightId);
      }
      
      return success;
    } catch (error) {
      console.error('❌ 创建高亮异常:', error);
      return false;
    }
  }
  
  createSimpleHighlight(range, highlightId, colorClass, noteContent) {
    try {
      const mark = document.createElement('mark');
      mark.className = `range-highlight ${colorClass}`;
      mark.setAttribute('data-highlight-id', highlightId);
      mark.setAttribute('data-annotation-type', noteContent ? 'note' : 'highlight');
      
      if (noteContent) {
        mark.classList.add('with-note');
        mark.setAttribute('data-note-content', noteContent);
        mark.title = noteContent;
      }
      
      try {
        range.surroundContents(mark);
      } catch (e) {
        // 如果无法直接包围，使用提取+插入方式
        const contents = range.extractContents();
        // 添加空值检查，防止appendChild错误
        if (mark && contents) {
          mark.appendChild(contents);
          range.insertNode(mark);
        } else {
          console.error('❌ mark或contents为null，无法创建高亮:', { mark, contents });
          return false;
        }
      }
      
      return true;
    } catch (error) {
      console.error('❌ 创建简单高亮失败:', error);
      return false;
    }
  }
  
  createCrossParagraphHighlight(range, highlightId, colorClass, noteContent) {
    try {
      console.log('🔄 创建跨段落高亮...');
      
      // 获取所有相关的文本节点
      const textNodes = this.getTextNodesInRange(range);
      
      textNodes.forEach((textNode, index) => {
        const nodeRange = document.createRange();
        nodeRange.selectNode(textNode);
        
        // 计算在当前节点的有效范围
        const intersection = this.getIntersection(range, nodeRange);
        if (intersection && intersection.toString().trim()) {
          const mark = document.createElement('mark');
          mark.className = `range-highlight ${colorClass} cross-paragraph`;
          mark.setAttribute('data-highlight-id', highlightId);
          mark.setAttribute('data-part-index', index.toString());
          mark.setAttribute('data-annotation-type', noteContent ? 'note' : 'highlight');
          
          if (noteContent) {
            mark.classList.add('with-note');
            mark.setAttribute('data-note-content', noteContent);
            if (index === 0) mark.title = noteContent; // 只在第一个片段显示tooltip
          }
          
          try {
            intersection.surroundContents(mark);
          } catch (e) {
            const contents = intersection.extractContents();
            // 添加空值检查，防止appendChild错误
            if (mark && contents) {
              mark.appendChild(contents);
              intersection.insertNode(mark);
            } else {
              console.error('❌ 跨段落高亮: mark或contents为null，跳过此片段:', { mark, contents });
            }
          }
        }
      });
      
      console.log('✅ 跨段落高亮创建成功');
      return true;
    } catch (error) {
      console.error('❌ 创建跨段落高亮失败:', error);
      return false;
    }
  }
  
  getTextNodesInRange(range) {
    const textNodes = [];
    const walker = document.createTreeWalker(
      range.commonAncestorContainer,
      NodeFilter.SHOW_TEXT,
      {
        acceptNode: (node) => {
          return range.intersectsNode(node) ? 
            NodeFilter.FILTER_ACCEPT : 
            NodeFilter.FILTER_REJECT;
        }
      }
    );
    
    let node;
    while (node = walker.nextNode()) {
      textNodes.push(node);
    }
    
    return textNodes;
  }
  
  getIntersection(range1, range2) {
    try {
      const startContainer = range1.compareBoundaryPoints(Range.START_TO_START, range2) > 0 ?
        range1.startContainer : range2.startContainer;
      const startOffset = range1.compareBoundaryPoints(Range.START_TO_START, range2) > 0 ?
        range1.startOffset : range2.startOffset;
      
      const endContainer = range1.compareBoundaryPoints(Range.END_TO_END, range2) < 0 ?
        range1.endContainer : range2.endContainer;
      const endOffset = range1.compareBoundaryPoints(Range.END_TO_END, range2) < 0 ?
        range1.endOffset : range2.endOffset;
      
      if (startContainer === endContainer && startOffset >= endOffset) {
        return null;
      }
      
      const intersection = document.createRange();
      intersection.setStart(startContainer, startOffset);
      intersection.setEnd(endContainer, endOffset);
      
      return intersection;
    } catch (error) {
      console.warn('⚠️ 计算Range交集失败:', error);
      return null;
    }
  }
  
  recreateRange(rangeData) {
    try {
      const startNode = this.getNodeByXPath(rangeData.startXPath);
      const endNode = this.getNodeByXPath(rangeData.endXPath);
      
      if (!startNode || !endNode) {
        console.warn('⚠️ 无法找到XPath对应的节点，尝试文本匹配恢复...');
        return this.recreateRangeByTextMatch(rangeData);
      }
      
      const range = document.createRange();
      range.setStart(startNode, rangeData.startOffset);
      range.setEnd(endNode, rangeData.endOffset);
      
      // 验证重建的Range是否正确
      if (range.toString() === rangeData.selectedText) {
        return range;
      } else {
        console.warn('⚠️ Range重建结果不匹配，尝试文本匹配...');
        return this.recreateRangeByTextMatch(rangeData);
      }
    } catch (error) {
      console.error('❌ 重建Range失败:', error);
      return this.recreateRangeByTextMatch(rangeData);
    }
  }
  
  recreateRangeByTextMatch(rangeData) {
    try {
      console.log('🔍 尝试通过文本匹配恢复Range...');
      
      // 在整个文档中搜索匹配的文本
      const searchText = rangeData.selectedText;
      const bodyText = document.body.textContent || '';
      
      // 使用前后文来精确定位
      const contextPattern = `${rangeData.beforeContext}${searchText}${rangeData.afterContext}`;
      const contextIndex = bodyText.indexOf(contextPattern);
      
      if (contextIndex !== -1) {
        const textStart = contextIndex + rangeData.beforeContext.length;
        const textEnd = textStart + searchText.length;
        
        // 在DOM中找到对应的位置
        const range = this.createRangeFromOffsets(textStart, textEnd);
        if (range) {
          console.log('✅ 通过文本匹配成功恢复Range');
          return range;
        }
      }
      
      console.warn('⚠️ 文本匹配恢复也失败了');
      return null;
    } catch (error) {
      console.error('❌ 文本匹配恢复失败:', error);
      return null;
    }
  }
  
  createRangeFromOffsets(startOffset, endOffset) {
    try {
      const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        null,
        false
      );
      
      let currentOffset = 0;
      let startNode = null, startPos = 0;
      let endNode = null, endPos = 0;
      
      let node;
      while (node = walker.nextNode()) {
        const nodeLength = node.textContent.length;
        
        if (!startNode && currentOffset + nodeLength > startOffset) {
          startNode = node;
          startPos = startOffset - currentOffset;
        }
        
        if (!endNode && currentOffset + nodeLength >= endOffset) {
          endNode = node;
          endPos = endOffset - currentOffset;
          break;
        }
        
        currentOffset += nodeLength;
      }
      
      if (startNode && endNode) {
        const range = document.createRange();
        range.setStart(startNode, startPos);
        range.setEnd(endNode, endPos);
        return range;
      }
      
      return null;
    } catch (error) {
      console.error('❌ 从偏移量创建Range失败:', error);
      return null;
    }
  }
  
  // 批量恢复标注
  batchRestore(annotations) {
    console.log(`🔄 开始批量恢复 ${annotations.length} 个标注...`);
    
    let successCount = 0;
    let failCount = 0;
    
    annotations.forEach((annotation, index) => {
      try {
        const success = this.restoreAnnotation(annotation);
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
        
        // 添加小延迟，避免阻塞UI
        if (index % 10 === 0) {
          setTimeout(() => {}, 0);
        }
      } catch (error) {
        console.error('❌ 恢复标注异常:', annotation.highlightId, error);
        failCount++;
      }
    });
    
    console.log(`✅ 批量恢复完成: 成功 ${successCount}, 失败 ${failCount}`);
    return { successCount, failCount };
  }
  
  restoreAnnotation(annotationData) {
    try {
      return this.createHighlight(
        annotationData,
        annotationData.highlightId,
        annotationData.colorType,
        annotationData.noteContent
      );
    } catch (error) {
      console.error('❌ 恢复单个标注失败:', error);
      return false;
    }
  }
  
  // 删除标注
  removeHighlight(highlightId) {
    try {
      const elements = document.querySelectorAll(`[data-highlight-id="${highlightId}"]`);
      elements.forEach(element => {
        // 保留文本内容，移除标记
        const parent = element.parentNode;
        while (element.firstChild) {
          parent.insertBefore(element.firstChild, element);
        }
        parent.removeChild(element);
      });
      
      this.annotations.delete(highlightId);
      console.log('✅ 标注删除成功:', highlightId);
      return true;
    } catch (error) {
      console.error('❌ 删除标注失败:', error);
      return false;
    }
  }
  
  // 更新高亮颜色
  updateHighlightColor(highlightId, newColorClass) {
    try {
      console.log('🔄 更新高亮颜色:', highlightId, '->', newColorClass);
      
      const elements = document.querySelectorAll(`[data-highlight-id="${highlightId}"]`);
      if (elements.length === 0) {
        console.warn('⚠️ 未找到要更新的高亮元素:', highlightId);
        return false;
      }
      
      elements.forEach(element => {
        // 移除所有高亮相关的CSS类
        const classList = element.classList;
        const classesToRemove = [];
        
        // 收集需要移除的高亮颜色类
        classList.forEach(className => {
          if (className.startsWith('highlight-')) {
            classesToRemove.push(className);
          }
        });
        
        // 移除旧的颜色类
        classesToRemove.forEach(className => {
          classList.remove(className);
        });
        
        // 添加新的颜色类
        classList.add(newColorClass);
      });
      
      console.log('✅ 高亮颜色更新成功:', highlightId, '->', newColorClass);
      return true;
    } catch (error) {
      console.error('❌ 更新高亮颜色失败:', error);
      return false;
    }
  }
  
  // 通知Flutter层
  notifyTextSelected(selectionData) {
    console.log('🚀 准备调用Flutter回调: onEnhancedTextSelected');
    console.log('🚀 选择数据:', JSON.stringify(selectionData, null, 2));
    
    // 检查Flutter桥接的可用性
    if (!window.flutter_inappwebview) {
      console.error('❌ window.flutter_inappwebview 不存在');
      this.retryNotifyTextSelected(selectionData, 1);
      return;
    }
    
    if (!window.flutter_inappwebview.callHandler) {
      console.error('❌ window.flutter_inappwebview.callHandler 不存在');
      this.retryNotifyTextSelected(selectionData, 1);
      return;
    }
    
    console.log('✅ Flutter桥接可用，调用回调...');
    try {
      window.flutter_inappwebview.callHandler('onEnhancedTextSelected', selectionData);
      console.log('✅ Flutter回调调用成功');
    } catch (error) {
      console.error('❌ Flutter回调调用失败:', error);
      this.retryNotifyTextSelected(selectionData, 1);
    }
  }
  
  // 重试通知Flutter
  retryNotifyTextSelected(selectionData, attempt) {
    if (attempt > 3) {
      console.error('❌ 重试3次后仍然失败，放弃调用');
      return;
    }
    
    console.log(`🔄 第${attempt}次重试调用Flutter回调...`);
    setTimeout(() => {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        try {
          window.flutter_inappwebview.callHandler('onEnhancedTextSelected', selectionData);
          console.log(`✅ 第${attempt}次重试成功`);
        } catch (error) {
          console.error(`❌ 第${attempt}次重试失败:`, error);
          this.retryNotifyTextSelected(selectionData, attempt + 1);
        }
      } else {
        console.log(`⏳ 第${attempt}次重试时Flutter桥接仍不可用，继续重试...`);
        this.retryNotifyTextSelected(selectionData, attempt + 1);
      }
    }, 500 * attempt); // 递增延迟
  }
  
  notifySelectionCleared() {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler('onEnhancedSelectionCleared', {});
    }
  }
  
  notifyHighlightCreated(data) {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler('onHighlightCreated', data);
    }
  }
  
  // 清理资源
  destroy() {
    this.annotations.clear();
    this.xpathCache.clear();
    
    if (this.selectionTimeout) {
      clearTimeout(this.selectionTimeout);
    }
    
    console.log('🧹 Range标注引擎已清理');
  }
}

// 全局初始化
window.initRangeAnnotationEngine = function() {
  if (!window.rangeAnnotationEngine) {
    window.rangeAnnotationEngine = new RangeAnnotationEngine();
    console.log('🌟 Range标注引擎全局初始化完成');
  }
  return window.rangeAnnotationEngine;
};

// 自动初始化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    window.initRangeAnnotationEngine();
  });
} else {
  window.initRangeAnnotationEngine();
}
(function() {
  console.log('🎯 注入文字选择处理脚本');
  
  let currentSelection = null;
  let isSelecting = false;
  let highlightCounter = 0;
  let noteCounter = 0;
  let selectionTimeout = null;
  
  // 更强力地阻止系统默认行为
  function preventSystemBehavior(e) {
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
    return false;
  }
  
  // 禁用系统默认的上下文菜单
  document.addEventListener('contextmenu', preventSystemBehavior, true);
  
  // 阻止系统选择菜单的各种触发方式
  document.addEventListener('selectstart', function(e) {
    console.log('🎯 开始选择文字');
    isSelecting = true;
  }, true);
  
  // 监听触摸开始（移动端）
  document.addEventListener('touchstart', function(e) {
    // 清除之前的超时
    if (selectionTimeout) {
      clearTimeout(selectionTimeout);
    }
  }, true);
  
  // 监听鼠标按下
  document.addEventListener('mousedown', function(e) {
    // 清除之前的超时
    if (selectionTimeout) {
      clearTimeout(selectionTimeout);
    }
  }, true);
  
  // 监听鼠标抬起事件（选择完成）
  document.addEventListener('mouseup', function(e) {
    selectionTimeout = setTimeout(function() {
      handleTextSelection(e);
    }, 100); // 增加延迟确保选择完成
  }, true);
  
  // 监听触摸结束事件（移动端选择完成）
  document.addEventListener('touchend', function(e) {
    selectionTimeout = setTimeout(function() {
      handleTextSelection(e);
    }, 150); // 移动端需要更长延迟
  }, true);
  
  // 监听选择变化事件
  document.addEventListener('selectionchange', function(e) {
    const selection = window.getSelection();
    if (selection && selection.toString().trim().length > 0) {
      // 有文字被选择
      currentSelection = selection;
      console.log('📝 检测到文字选择变化:', selection.toString().trim());
      
      // 延迟处理，防止过度触发
      if (selectionTimeout) {
        clearTimeout(selectionTimeout);
      }
      selectionTimeout = setTimeout(function() {
        handleSelectionChange();
      }, 200);
    } else {
      // 选择被清除
      if (currentSelection) {
        console.log('❌ 选择已清除');
        currentSelection = null;
        // 通知Flutter清除选择
        notifyFlutter('onSelectionCleared', {});
      }
    }
  }, true);
  
  // 处理选择变化
  function handleSelectionChange() {
    if (!currentSelection) return;
    
    const selectedText = currentSelection.toString().trim();
    if (selectedText.length < 2) {
      console.log('⚠️ 选择文字过短，跳过处理:', selectedText.length);
      return;
    }
    
    try {
      const range = currentSelection.getRangeAt(0);
      const rect = range.getBoundingClientRect();
      
      // 使用getBoundingClientRect()返回的视窗相对坐标
      const selectionData = {
        text: selectedText,
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height
      };
      
      console.log('📍 选择位置详细信息 (viewport-relative):', selectionData);
      
      // 通知Flutter
      notifyFlutter('onTextSelected', selectionData);
      
    } catch (error) {
      console.error('❌ 处理选择变化失败:', error);
    }
  }
  
  // 处理文字选择
  function handleTextSelection(originalEvent) {
    const selection = window.getSelection();
    if (!selection || selection.toString().trim().length === 0) {
      console.log('⚠️ 选择为空，跳过处理');
      return;
    }
    
    const selectedText = selection.toString().trim();
    if (selectedText.length < 2) { // 忽略过短的选择
      console.log('⚠️ 选择文字过短，跳过处理:', selectedText.length);
      return;
    }
    
    console.log('📝 处理文字选择:', selectedText);
    
    // 强制阻止系统默认行为
    if (originalEvent) {
      originalEvent.preventDefault();
      originalEvent.stopPropagation();
      originalEvent.stopImmediatePropagation();
    }
    
    // 阻止所有可能的系统菜单
    setTimeout(function() {
      document.addEventListener('contextmenu', preventSystemBehavior, true);
    }, 10);
    
    try {
      // 获取选择的位置信息
      const range = selection.getRangeAt(0);
      const rect = range.getBoundingClientRect();
      
      // 使用getBoundingClientRect()返回的视窗相对坐标
      const selectionData = {
        text: selectedText,
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height
      };
      
      console.log('📍 最终选择位置信息 (viewport-relative):', selectionData);
      
      // 通知Flutter
      notifyFlutter('onTextSelected', selectionData);
      
    } catch (error) {
      console.error('❌ 处理文字选择失败:', error);
    }
  }
  
  // 高亮选中的文字
  function highlightSelection(color = 'yellow') {
    const selection = window.getSelection();
    if (!selection || selection.toString().trim().length === 0) {
      console.warn('⚠️ 没有选中的文字可以高亮');
      return false;
    }
    
    try {
      const range = selection.getRangeAt(0);
      const selectedText = selection.toString().trim();
      
      // 创建高亮元素
      const highlightSpan = document.createElement('span');
      highlightSpan.className = 'flutter-highlight';
      highlightSpan.style.backgroundColor = color;
      highlightSpan.style.padding = '2px 1px';
      highlightSpan.style.borderRadius = '2px';
      highlightSpan.dataset.highlightId = 'highlight_' + (++highlightCounter) + '_' + Date.now();
      highlightSpan.dataset.originalText = selectedText;
      
      // 包装选中的内容
      try {
        range.surroundContents(highlightSpan);
        console.log('✅ 文字高亮成功:', selectedText);
        
        // 清除选择
        selection.removeAllRanges();
        
        // 通知Flutter
        notifyFlutter('onTextHighlighted', {
          text: selectedText,
          id: highlightSpan.dataset.highlightId,
          color: color
        });
        
        return true;
      } catch (e) {
        // 如果surroundContents失败，使用备用方法
        const contents = range.extractContents();
        highlightSpan.appendChild(contents);
        range.insertNode(highlightSpan);
        
        selection.removeAllRanges();
        
        console.log('✅ 文字高亮成功(备用方法):', selectedText);
        
        notifyFlutter('onTextHighlighted', {
          text: selectedText,
          id: highlightSpan.dataset.highlightId,
          color: color
        });
        
        return true;
      }
    } catch (error) {
      console.error('❌ 高亮文字失败:', error);
      return false;
    }
  }
  
  // 添加笔记到选中的文字
  function addNoteToSelection(noteText) {
    const selection = window.getSelection();
    if (!selection || selection.toString().trim().length === 0) {
      console.warn('⚠️ 没有选中的文字可以添加笔记');
      return false;
    }
    
    try {
      const range = selection.getRangeAt(0);
      const selectedText = selection.toString().trim();
      
      // 创建笔记元素
      const noteSpan = document.createElement('span');
      noteSpan.className = 'flutter-note';
      noteSpan.style.backgroundColor = '#fff3cd';
      noteSpan.style.borderBottom = '2px solid #ffc107';
      noteSpan.style.position = 'relative';
      noteSpan.style.cursor = 'help';
      noteSpan.dataset.noteId = 'note_' + (++noteCounter) + '_' + Date.now();
      noteSpan.dataset.noteText = noteText;
      noteSpan.dataset.originalText = selectedText;
      noteSpan.title = '笔记: ' + noteText;
      
      // 包装选中的内容
      try {
        range.surroundContents(noteSpan);
        console.log('✅ 笔记添加成功:', selectedText, '笔记:', noteText);
        
        // 清除选择
        selection.removeAllRanges();
        
        // 通知Flutter
        notifyFlutter('onNoteAdded', {
          note: noteText,
          selectedText: selectedText,
          id: noteSpan.dataset.noteId
        });
        
        return true;
      } catch (e) {
        // 备用方法
        const contents = range.extractContents();
        noteSpan.appendChild(contents);
        range.insertNode(noteSpan);
        
        selection.removeAllRanges();
        
        console.log('✅ 笔记添加成功(备用方法):', selectedText, '笔记:', noteText);
        
        notifyFlutter('onNoteAdded', {
          note: noteText,
          selectedText: selectedText,
          id: noteSpan.dataset.noteId
        });
        
        return true;
      }
    } catch (error) {
      console.error('❌ 添加笔记失败:', error);
      return false;
    }
  }
  
  // 清除当前选择
  function clearSelection() {
    const selection = window.getSelection();
    if (selection) {
      selection.removeAllRanges();
      console.log('✅ 清除选择完成');
    }
  }
  
  // 获取当前选择的文字
  function getCurrentSelection() {
    const selection = window.getSelection();
    if (selection && selection.toString().trim().length > 0) {
      const range = selection.getRangeAt(0);
      const rect = range.getBoundingClientRect();
      
      return {
        text: selection.toString().trim(),
        x: rect.left + (rect.width / 2),
        y: rect.top,
        width: rect.width,
        height: rect.height
      };
    }
    return null;
  }
  
  // 统一的Flutter通知函数
  function notifyFlutter(handlerName, data) {
    try {
      console.log('📤 向Flutter发送消息:', handlerName, data);
      
      // 检查flutter_inappwebview是否可用
      if (typeof window.flutter_inappwebview === 'undefined') {
        console.error('❌ window.flutter_inappwebview 未定义');
        return false;
      }
      
      if (typeof window.flutter_inappwebview.callHandler !== 'function') {
        console.error('❌ window.flutter_inappwebview.callHandler 不是函数');
        return false;
      }
      
      // 调用Flutter处理器
      window.flutter_inappwebview.callHandler(handlerName, data);
      console.log('✅ 消息发送成功:', handlerName);
      return true;
      
    } catch (error) {
      console.error('❌ 发送消息到Flutter失败:', error);
      return false;
    }
  }
  
  // 暴露给Flutter调用的方法
  window.flutter_text_selector = {
    highlightSelection: highlightSelection,
    addNoteToSelection: addNoteToSelection,
    clearSelection: clearSelection,
    getCurrentSelection: getCurrentSelection
  };
  
  console.log('✅ 文字选择处理脚本注入完成');
  console.log('🔍 检查flutter_inappwebview:', typeof window.flutter_inappwebview);
})(); 
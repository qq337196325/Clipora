(function() {
  console.log('🎯 注入精确定位追踪脚本');
  
  // 为页面元素添加唯一标识符
  function addElementIds() {
    const elements = document.querySelectorAll('h1, h2, h3, h4, h5, h6, p, blockquote, pre, div.markdown-body > *');
    elements.forEach((element, index) => {
      if (!element.id) {
        element.id = 'reading_element_' + index + '_' + Date.now();
      }
    });
    console.log('✅ 为 ' + elements.length + ' 个元素添加了ID');
  }
  
  // 获取当前可见的主要元素
  function getCurrentVisibleElement() {
    try {
      const elements = document.querySelectorAll('[id^="reading_element_"], h1, h2, h3, h4, h5, h6, p');
      const viewportTop = window.scrollY;
      const viewportBottom = viewportTop + window.innerHeight;
      const viewportCenter = viewportTop + (window.innerHeight / 2);
      
      let bestElement = null;
      let minDistance = Infinity;
      
      for (let element of elements) {
        const rect = element.getBoundingClientRect();
        const elementTop = rect.top + window.scrollY;
        const elementBottom = elementTop + rect.height;
        const elementCenter = elementTop + (rect.height / 2);
        
        // 检查元素是否在视窗内
        if (elementBottom >= viewportTop && elementTop <= viewportBottom) {
          // 计算元素中心点与视窗中心点的距离
          const distance = Math.abs(elementCenter - viewportCenter);
          
          if (distance < minDistance) {
            minDistance = distance;
            bestElement = element;
          }
        }
      }
      
      if (bestElement) {
        const rect = bestElement.getBoundingClientRect();
        return {
          id: bestElement.id,
          tagName: bestElement.tagName,
          text: bestElement.textContent ? bestElement.textContent.substring(0, 100) : '',
          offsetTop: rect.top + window.scrollY,
          scrollY: window.scrollY,
          scrollX: window.scrollX,
          viewportHeight: window.innerHeight,
          contentHeight: document.documentElement.scrollHeight,
          progress: window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)
        };
      }
      
      return {
        id: '',
        tagName: '',
        text: '',
        offsetTop: 0,
        scrollY: window.scrollY,
        scrollX: window.scrollX,
        viewportHeight: window.innerHeight,
        contentHeight: document.documentElement.scrollHeight,
        progress: window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)
      };
    } catch (error) {
      console.error('❌ 获取可见元素失败:', error);
      return null;
    }
  }
  
  // 滚动到指定元素
  function scrollToElement(elementId, offset = 0) {
    try {
      const element = document.getElementById(elementId);
      if (element) {
        const elementTop = element.getBoundingClientRect().top + window.scrollY;
        const targetPosition = Math.max(0, elementTop - offset);
        
        window.scrollTo({
          top: targetPosition,
          left: 0,
          behavior: 'smooth'
        });
        
        console.log('✅ 滚动到元素:', elementId, '位置:', targetPosition);
        return true;
      } else {
        console.warn('⚠️ 未找到目标元素:', elementId);
        return false;
      }
    } catch (error) {
      console.error('❌ 滚动到元素失败:', error);
      return false;
    }
  }
  
  // 立即跳转到指定元素（无动画）
  function jumpToElement(elementId, offset = 0) {
    try {
      const element = document.getElementById(elementId);
      if (element) {
        const elementTop = element.getBoundingClientRect().top + window.scrollY;
        const targetPosition = Math.max(0, elementTop - offset);
        
        window.scrollTo(0, targetPosition);
        
        console.log('⚡ 立即跳转到元素:', elementId, '位置:', targetPosition);
        return true;
      } else {
        console.warn('⚠️ 未找到目标元素:', elementId);
        return false;
      }
    } catch (error) {
      console.error('❌ 立即跳转到元素失败:', error);
      return false;
    }
  }
  
  // 滚动到指定位置
  function scrollToPosition(scrollY, scrollX = 0) {
    try {
      window.scrollTo({
        top: Math.max(0, scrollY),
        left: Math.max(0, scrollX),
        behavior: 'smooth'
      });
      console.log('✅ 滚动到位置: Y=' + scrollY + ', X=' + scrollX);
      return true;
    } catch (error) {
      console.error('❌ 滚动到位置失败:', error);
      return false;
    }
  }
  
  // 立即跳转到指定位置（无动画）
  function jumpToPosition(scrollY, scrollX = 0) {
    try {
      window.scrollTo(Math.max(0, scrollX), Math.max(0, scrollY));
      console.log('⚡ 立即跳转到位置: Y=' + scrollY + ', X=' + scrollX);
      return true;
    } catch (error) {
      console.error('❌ 立即跳转到位置失败:', error);
      return false;
    }
  }
  
  // 智能定位：结合元素和位置的混合定位策略
  function smartJumpToPosition(elementId, scrollY, scrollX = 0, offset = 50) {
    try {
      console.log('🎯 开始智能定位...', { elementId, scrollY, offset });
      
      // 1. 优先尝试元素定位
      if (elementId) {
        const element = document.getElementById(elementId);
        if (element) {
          const elementTop = element.getBoundingClientRect().top + window.scrollY;
          const viewportCenter = window.innerHeight / 2;
          const targetPosition = Math.max(0, elementTop - viewportCenter + offset);
          
          window.scrollTo(0, targetPosition);
          console.log('⚡ 智能定位成功（元素）:', elementId, '位置:', targetPosition);
          return { success: true, method: 'element', position: targetPosition };
        }
      }
      
      // 2. 备用：使用精确位置定位
      if (scrollY > 0) {
        window.scrollTo(Math.max(0, scrollX), Math.max(0, scrollY));
        console.log('⚡ 智能定位成功（位置）: Y=' + scrollY + ', X=' + scrollX);
        return { success: true, method: 'position', position: scrollY };
      }
      
      console.warn('⚠️ 智能定位失败：无有效定位数据');
      return { success: false, method: 'none', position: 0 };
    } catch (error) {
      console.error('❌ 智能定位失败:', error);
      return { success: false, method: 'error', position: 0, error: error.message };
    }
  }
  
  // 渐进式定位：先立即跳转，后微调
  function progressiveJumpToElement(elementId, offset = 50) {
    try {
      const element = document.getElementById(elementId);
      if (!element) {
        console.warn('⚠️ 渐进式定位失败：未找到元素', elementId);
        return { success: false, phase: 'not_found' };
      }
      
      // 阶段1：立即跳转到大致位置
      const rect = element.getBoundingClientRect();
      const elementTop = rect.top + window.scrollY;
      const roughPosition = Math.max(0, elementTop - offset);
      window.scrollTo(0, roughPosition);
      
      // 阶段2：使用requestAnimationFrame进行微调
      requestAnimationFrame(() => {
        try {
          const newRect = element.getBoundingClientRect();
          const viewportCenter = window.innerHeight / 2;
          const elementCenter = newRect.top + (newRect.height / 2);
          const adjustment = elementCenter - viewportCenter;
          
          if (Math.abs(adjustment) > 10) { // 只有偏差超过10px才微调
            const finalPosition = Math.max(0, window.scrollY + adjustment);
            window.scrollTo(0, finalPosition);
            console.log('🎯 渐进式定位完成（已微调）:', elementId, '最终位置:', finalPosition);
          } else {
            console.log('🎯 渐进式定位完成（无需微调）:', elementId, '位置:', roughPosition);
          }
        } catch (error) {
          console.error('❌ 渐进式定位微调失败:', error);
        }
      });
      
      return { success: true, phase: 'completed', position: roughPosition };
    } catch (error) {
      console.error('❌ 渐进式定位失败:', error);
      return { success: false, phase: 'error', error: error.message };
    }
  }

  // 暴露给Flutter调用的方法
  window.flutter_reading_tracker = {
    addElementIds: addElementIds,
    getCurrentVisibleElement: getCurrentVisibleElement,
    scrollToElement: scrollToElement,
    jumpToElement: jumpToElement,
    scrollToPosition: scrollToPosition,
    jumpToPosition: jumpToPosition,
    smartJumpToPosition: smartJumpToPosition,
    progressiveJumpToElement: progressiveJumpToElement
  };
  
  // 内容加载完成后自动添加元素ID
  if (document.readyState === 'complete') {
    setTimeout(addElementIds, 100);
  } else {
    document.addEventListener('DOMContentLoaded', () => {
      setTimeout(addElementIds, 100);
    });
  }
  
  console.log('✅ 精确定位追踪脚本注入完成');
})(); 
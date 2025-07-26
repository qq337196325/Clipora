import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../basics/logger.dart';


/// 快照样式同步工具类
/// 确保生成的快照与原网页样式保持一致
class SnapshotStyleSync {
  
  /// 在生成快照前同步样式设置
  static Future<void> syncStylesBeforeSnapshot(InAppWebViewController controller) async {
    try {
      getLogger().i('🎨 开始同步样式设置以确保快照质量...');
      
      // 1. 等待所有资源加载完成
      await _waitForResourcesLoaded(controller);
      
      // 2. 强制应用所有CSS规则
      await _forceApplyAllStyles(controller);
      
      // 3. 修复常见的样式问题
      await _fixCommonStyleIssues(controller);
      
      // 4. 确保媒体查询正确应用
      await _ensureMediaQueriesApplied(controller);
      
      // 5. 最终样式稳定化
      await _finalizeStyleStabilization(controller);
      
      getLogger().i('✅ 样式同步完成，快照准备就绪');
      
    } catch (e) {
      getLogger().e('❌ 样式同步失败: $e');
    }
  }
  
  /// 等待所有资源加载完成
  static Future<void> _waitForResourcesLoaded(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      (function() {
        return new Promise((resolve) => {
          // 等待所有图片加载
          const images = document.querySelectorAll('img');
          let loadedImages = 0;
          const totalImages = images.length;
          
          if (totalImages === 0) {
            resolve();
            return;
          }
          
          function checkImageLoaded() {
            loadedImages++;
            if (loadedImages >= totalImages) {
              console.log('✅ 所有图片加载完成');
              resolve();
            }
          }
          
          images.forEach(img => {
            if (img.complete && img.naturalHeight !== 0) {
              checkImageLoaded();
            } else {
              img.onload = checkImageLoaded;
              img.onerror = checkImageLoaded;
            }
          });
          
          // 超时保护
          setTimeout(() => {
            console.log('⏰ 图片加载超时，继续处理');
            resolve();
          }, 8000);
        });
      })();
    ''');
    
    // 等待CSS加载完成
    await controller.evaluateJavascript(source: '''
      (function() {
        return new Promise((resolve) => {
          const stylesheets = document.styleSheets;
          let loadedSheets = 0;
          const totalSheets = stylesheets.length;
          
          if (totalSheets === 0) {
            resolve();
            return;
          }
          
          for (let i = 0; i < totalSheets; i++) {
            try {
              // 尝试访问CSS规则来确保样式表已加载
              const rules = stylesheets[i].cssRules || stylesheets[i].rules;
              loadedSheets++;
            } catch (e) {
              // 跨域样式表可能无法访问，但不影响显示
              loadedSheets++;
            }
          }
          
          console.log('✅ CSS样式表检查完成');
          resolve();
        });
      })();
    ''');
  }
  
  /// 强制应用所有CSS规则
  static Future<void> _forceApplyAllStyles(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      (function() {
        // 创建样式强化脚本
        const styleEnhancement = document.createElement('style');
        styleEnhancement.id = 'snapshot-style-enhancement';
        styleEnhancement.textContent = `
          /* 确保所有颜色和背景在快照中正确显示 */
          *, *::before, *::after {
            -webkit-print-color-adjust: exact !important;
            color-adjust: exact !important;
            print-color-adjust: exact !important;
          }
          
          /* 优化字体渲染 */
          * {
            -webkit-font-smoothing: antialiased !important;
            -moz-osx-font-smoothing: grayscale !important;
            text-rendering: optimizeLegibility !important;
          }
          
          /* 确保背景图片和渐变正确显示 */
          [style*="background"], [class*="bg-"], [id*="bg-"] {
            -webkit-print-color-adjust: exact !important;
            color-adjust: exact !important;
          }
          
          /* 修复可能的布局问题 */
          img {
            max-width: 100% !important;
            height: auto !important;
            display: block !important;
          }
          
          /* 确保文本内容可见 */
          p, div, span, h1, h2, h3, h4, h5, h6, li, td, th {
            color: inherit !important;
            opacity: 1 !important;
            visibility: visible !important;
          }
          
          /* 修复可能的响应式布局问题 */
          .container, .content, .main, main, article, section {
            width: 100% !important;
            max-width: 100% !important;
            min-height: auto !important;
          }
          
          /* 确保表格正确显示 */
          table {
            width: 100% !important;
            border-collapse: collapse !important;
          }
          
          /* 修复代码块显示 */
          pre, code {
            white-space: pre-wrap !important;
            word-wrap: break-word !important;
            overflow-wrap: break-word !important;
          }
        `;
        
        // 移除旧的增强样式
        const oldEnhancement = document.getElementById('snapshot-style-enhancement');
        if (oldEnhancement) {
          oldEnhancement.remove();
        }
        
        // 添加新的增强样式
        document.head.appendChild(styleEnhancement);
        
        // 强制重新计算样式
        document.body.offsetHeight;
        
        console.log('🎨 样式强化完成');
      })();
    ''');
  }
  
  /// 修复常见的样式问题
  static Future<void> _fixCommonStyleIssues(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      (function() {
        // 修复隐藏或透明的元素
        const hiddenElements = document.querySelectorAll('[style*="display: none"], [style*="visibility: hidden"], [style*="opacity: 0"]');
        hiddenElements.forEach(el => {
          const computedStyle = window.getComputedStyle(el);
          // 只修复内容元素，保留真正应该隐藏的UI元素
          if (el.textContent && el.textContent.trim().length > 0) {
            if (computedStyle.display === 'none') {
              el.style.display = 'block';
            }
            if (computedStyle.visibility === 'hidden') {
              el.style.visibility = 'visible';
            }
            if (computedStyle.opacity === '0') {
              el.style.opacity = '1';
            }
          }
        });
        
        // 修复可能的字体颜色问题
        const textElements = document.querySelectorAll('p, div, span, h1, h2, h3, h4, h5, h6, li, td, th, a');
        textElements.forEach(el => {
          const computedStyle = window.getComputedStyle(el);
          const color = computedStyle.color;
          
          // 如果文字颜色太浅或透明，设置为默认颜色
          if (color === 'rgba(0, 0, 0, 0)' || color === 'transparent') {
            el.style.color = '#333333';
          }
        });
        
        // 确保背景色正确显示
        if (document.body.style.backgroundColor === '' || 
            window.getComputedStyle(document.body).backgroundColor === 'rgba(0, 0, 0, 0)') {
          document.body.style.backgroundColor = '#ffffff';
        }
        
        console.log('🔧 常见样式问题修复完成');
      })();
    ''');
  }
  
  /// 确保媒体查询正确应用
  static Future<void> _ensureMediaQueriesApplied(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      (function() {
        // 获取当前视口尺寸
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;
        
        console.log('📱 当前视口尺寸:', viewportWidth + 'x' + viewportHeight);
        
        // 强制触发媒体查询重新计算
        const mediaQueryStyle = document.createElement('style');
        mediaQueryStyle.id = 'media-query-fix';
        mediaQueryStyle.textContent = `
          /* 确保移动端样式正确应用 */
          @media screen and (max-width: 768px) {
            body {
              font-size: 16px !important;
              line-height: 1.6 !important;
            }
            
            .container, .content, .main {
              padding: 15px !important;
              margin: 0 !important;
            }
          }
          
          /* 确保桌面端样式在需要时应用 */
          @media screen and (min-width: 769px) {
            .container, .content, .main {
              max-width: 100% !important;
            }
          }
        `;
        
        // 移除旧的媒体查询修复
        const oldMediaFix = document.getElementById('media-query-fix');
        if (oldMediaFix) {
          oldMediaFix.remove();
        }
        
        document.head.appendChild(mediaQueryStyle);
        
        // 触发窗口resize事件来重新应用媒体查询
        window.dispatchEvent(new Event('resize'));
        
        console.log('📱 媒体查询重新应用完成');
      })();
    ''');
  }
  
  /// 最终样式稳定化
  static Future<void> _finalizeStyleStabilization(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      (function() {
        // 禁用所有动画和过渡效果
        const animationDisabler = document.createElement('style');
        animationDisabler.id = 'animation-disabler';
        animationDisabler.textContent = `
          *, *::before, *::after {
            animation-duration: 0s !important;
            animation-delay: 0s !important;
            transition-duration: 0s !important;
            transition-delay: 0s !important;
            animation-fill-mode: forwards !important;
          }
        `;
        
        document.head.appendChild(animationDisabler);
        
        // 移除可能影响快照的元素
        const elementsToHide = [
          '.ad', '.ads', '.advertisement',
          '.popup', '.modal', '.overlay', '.toast',
          '.cookie-banner', '.newsletter-popup',
          '.social-share-fixed', '.floating-button',
          '.loading', '.spinner', '.skeleton',
          '[class*="loading"]', '[id*="loading"]',
          '[class*="spinner"]', '[id*="spinner"]'
        ];
        
        elementsToHide.forEach(selector => {
          try {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
              el.style.display = 'none';
              el.style.visibility = 'hidden';
            });
          } catch (e) {
            // 忽略选择器错误
          }
        });
        
        // 强制重新渲染所有元素
        const allElements = document.querySelectorAll('*');
        allElements.forEach(el => {
          el.offsetHeight; // 触发重排
        });
        
        // 最终的布局稳定化
        document.body.offsetHeight;
        document.documentElement.offsetHeight;
        
        console.log('🎯 样式稳定化完成，快照准备就绪');
      })();
    ''');
    
    // 等待样式完全应用
    await Future.delayed(const Duration(milliseconds: 1500));
  }
  
  /// 为MHTML显示优化样式
  static Future<void> optimizeForMhtmlDisplay(InAppWebViewController controller) async {
    try {
      getLogger().i('🎨 开始为MHTML显示优化样式...');
      
      await controller.evaluateJavascript(source: '''
        (function() {
          // 创建MHTML显示优化样式
          const mhtmlOptimization = document.createElement('style');
          mhtmlOptimization.id = 'mhtml-display-optimization';
          mhtmlOptimization.textContent = `
            /* 确保颜色和背景在MHTML中正确显示 */
            * {
              -webkit-print-color-adjust: exact !important;
              color-adjust: exact !important;
              print-color-adjust: exact !important;
            }
            
            /* 优化字体渲染 */
            body, * {
              -webkit-font-smoothing: antialiased !important;
              -moz-osx-font-smoothing: grayscale !important;
              text-rendering: optimizeLegibility !important;
            }
            
            /* 确保背景色正确显示 */
            html, body {
              background-color: white !important;
            }
            
            /* 修复图片显示 */
            img {
              max-width: 100% !important;
              height: auto !important;
              display: block !important;
              margin: 0 auto !important;
            }
            
            /* 确保文本可读性 */
            p, div, span, article, section {
              line-height: 1.6 !important;
              word-wrap: break-word !important;
            }
            
            /* 修复响应式布局 */
            .container, .content, .main, main, article {
              max-width: 100% !important;
              width: 100% !important;
              box-sizing: border-box !important;
            }
            
            /* 隐藏不必要的元素 */
            .ad, .ads, .advertisement, 
            .popup, .modal, .overlay,
            .cookie-banner, .newsletter-popup,
            .social-share-fixed, .floating-button,
            .loading, .spinner {
              display: none !important;
            }
            
            /* 修复表格显示 */
            table {
              width: 100% !important;
              border-collapse: collapse !important;
              table-layout: auto !important;
            }
            
            /* 确保代码块正确显示 */
            pre, code {
              white-space: pre-wrap !important;
              word-wrap: break-word !important;
              overflow-wrap: break-word !important;
              background-color: #f5f5f5 !important;
              padding: 10px !important;
              border-radius: 4px !important;
            }
            
            /* 修复链接样式 */
            a {
              color: #007bff !important;
              text-decoration: underline !important;
            }
            
            /* 确保列表正确显示 */
            ul, ol {
              padding-left: 20px !important;
              margin: 10px 0 !important;
            }
            
            /* 修复标题样式 */
            h1, h2, h3, h4, h5, h6 {
              margin: 20px 0 10px 0 !important;
              line-height: 1.3 !important;
              font-weight: bold !important;
            }
          `;
          
          // 移除旧的优化样式
          const oldOptimization = document.getElementById('mhtml-display-optimization');
          if (oldOptimization) {
            oldOptimization.remove();
          }
          
          // 添加新的优化样式
          document.head.appendChild(mhtmlOptimization);
          
          // 强制重新渲染
          document.body.offsetHeight;
          
          console.log('🎨 MHTML显示优化完成');
        })();
      ''');
      
      getLogger().i('✅ MHTML显示样式优化完成');
      
    } catch (e) {
      getLogger().e('❌ MHTML显示样式优化失败: $e');
    }
  }
}
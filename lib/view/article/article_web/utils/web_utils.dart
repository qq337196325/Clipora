import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../basics/logger.dart';
import '../../utils/auto_expander.dart';

/// 页面加载完成后的最终优化
Future<void> finalizeWebPageOptimization(WebUri? url,InAppWebViewController? webViewController) async {
  if (webViewController == null) return;

  try {
    getLogger().i('🎨 执行页面加载完成后的优化...');

    // 注入页面完成后的优化脚本
    await webViewController!.evaluateJavascript(source: '''
        (function() {
          console.log('🎨 执行页面完成后优化...');
          
          // 延迟执行，确保页面完全渲染
          setTimeout(function() {
            // 强制移除水平滚动条的终极方案
            function eliminateHorizontalScroll() {
              console.log('🔧 开始消除水平滚动条...');
              
              // 1. 强制设置body和html的样式
              document.documentElement.style.overflowX = 'hidden';
              document.documentElement.style.maxWidth = '100%';
              document.body.style.overflowX = 'hidden';
              document.body.style.maxWidth = '100%';
              document.body.style.width = '100%';
              
              // 2. 检查并修复所有可能导致水平滚动的元素
              const allElements = document.querySelectorAll('*');
              let fixedCount = 0;
              
              allElements.forEach(function(el) {
                const rect = el.getBoundingClientRect();
                const computed = window.getComputedStyle(el);
                
                // 检查元素是否超出视口宽度
                if (rect.width > window.innerWidth || 
                    rect.right > window.innerWidth) {
                  
                  // 记录原始宽度用于调试
                  const originalWidth = computed.width;
                  
                  // 应用修复样式
                  el.style.maxWidth = '100%';
                  el.style.boxSizing = 'border-box';
                  
                  // 特殊处理不同类型的元素
                  const tagName = el.tagName.toLowerCase();
                  
                  if (tagName === 'img' || tagName === 'video') {
                    el.style.width = '100%';
                    el.style.height = 'auto';
                  } else if (tagName === 'table') {
                    el.style.width = '100%';
                    el.style.tableLayout = 'fixed';
                  } else if (tagName === 'pre' || tagName === 'code') {
                    el.style.whiteSpace = 'pre-wrap';
                    el.style.wordWrap = 'break-word';
                    el.style.overflowX = 'auto';
                  } else if (computed.position === 'fixed' || computed.position === 'absolute') {
                    // 对于定位元素，确保不超出边界
                    if (rect.right > window.innerWidth) {
                      el.style.right = '0';
                      el.style.left = 'auto';
                      el.style.maxWidth = '100%';
                    }
                  }
                  
                  fixedCount++;
                  // console.log('🔧 修复超宽元素:', tagName, '原始宽度:', originalWidth);
                }
              });
              
              // 3. 强制刷新布局
              document.body.offsetHeight; // 触发重排
              
              // 4. 最后检查是否还有水平滚动
              const hasHorizontalScroll = document.documentElement.scrollWidth > document.documentElement.clientWidth;
              
              console.log('📊 优化结果:', {
                '修复元素数量': fixedCount,
                '视口宽度': window.innerWidth,
                '文档宽度': document.documentElement.scrollWidth,
                '是否还有水平滚动': hasHorizontalScroll
              });
              
              if (hasHorizontalScroll) {
                console.warn('⚠️ 仍存在水平滚动，应用强制CSS覆盖');
                // 最后的强制手段
                const forceStyle = document.createElement('style');
                forceStyle.innerHTML = `
                  * { 
                    max-width: 100% !important; 
                    box-sizing: border-box !important; 
                  }
                  html, body { 
                    overflow-x: hidden !important; 
                    width: 100% !important;
                  }
                `;
                document.head.appendChild(forceStyle);
              }
              
              return fixedCount;
            }
            
            // 执行消除水平滚动
            const fixedCount = eliminateHorizontalScroll();
            
            // 优化已加载的图片
            const images = document.querySelectorAll('img');
            let optimizedCount = 0;
            
            images.forEach(function(img) {
              if (!img.style.maxWidth) {
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                optimizedCount++;
              }
            });
            
            console.log('✅ 页面优化完成，修复了 ' + fixedCount + ' 个超宽元素，优化了 ' + optimizedCount + ' 张图片');
            
            // 触发性能统计
            if (window.performance && window.performance.timing) {
              const timing = window.performance.timing;
              const loadTime = timing.loadEventEnd - timing.navigationStart;
              console.log('📊 页面加载耗时: ' + loadTime + 'ms');
            }
          }, 200);
        })();
      ''');

    // 应用自动展开规则
    if (url != null) {
      AutoExpander.apply(webViewController!, url);
    }

    getLogger().i('✅ 页面最终优化完成');
  } catch (e) {
    getLogger().e('❌ 页面最终优化失败: $e');
  }
}



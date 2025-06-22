import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../basics/logger.dart';

/// 滚动修复工具类
/// 专门处理移动端网页中由APP引导弹窗导致的滚动问题
class ScrollFixUtils {
  
  /// 检测页面滚动状态
  static Future<Map<String, dynamic>?> detectScrollIssues(
    InAppWebViewController controller
  ) async {
    try {
      getLogger().i('🔍 开始检测页面滚动问题...');
      
      final result = await controller.evaluateJavascript(source: '''
        (function() {
          const html = document.documentElement;
          const body = document.body;
          
          // 检测页面基本信息
          const pageInfo = {
            url: window.location.href,
            hostname: window.location.hostname,
            userAgent: navigator.userAgent,
            viewport: {
              width: window.innerWidth,
              height: window.innerHeight
            },
            document: {
              scrollWidth: html.scrollWidth,
              scrollHeight: html.scrollHeight,
              clientWidth: html.clientWidth,
              clientHeight: html.clientHeight
            }
          };
          
          // 检测样式设置
          const htmlStyle = window.getComputedStyle(html);
          const bodyStyle = window.getComputedStyle(body);
          
          const styleIssues = {
            html: {
              overflow: htmlStyle.overflow,
              overflowY: htmlStyle.overflowY,
              height: htmlStyle.height,
              position: htmlStyle.position
            },
            body: {
              overflow: bodyStyle.overflow,
              overflowY: bodyStyle.overflowY,
              height: bodyStyle.height,
              position: bodyStyle.position
            }
          };
          
          // 检测可疑的遮罩层
          const suspiciousOverlays = [];
          const overlays = document.querySelectorAll('*');
          
          overlays.forEach(el => {
            const style = window.getComputedStyle(el);
            const position = style.position;
            const zIndex = parseInt(style.zIndex) || 0;
            
            if ((position === 'fixed' || position === 'absolute') && 
                zIndex > 1000 && 
                el.offsetWidth > window.innerWidth * 0.7 &&
                el.offsetHeight > window.innerHeight * 0.7) {
              
              suspiciousOverlays.push({
                tagName: el.tagName,
                className: el.className,
                id: el.id,
                position: position,
                zIndex: zIndex,
                width: el.offsetWidth,
                height: el.offsetHeight,
                display: style.display,
                visibility: style.visibility
              });
            }
          });
          
          // 测试滚动功能
          const originalY = window.pageYOffset;
          window.scrollBy(0, 5);
          const afterScrollY = window.pageYOffset;
          window.scrollTo(0, originalY);
          
          const canScroll = afterScrollY !== originalY;
          
          // 检测APP引导相关元素
          const appGuideElements = [];
          const appGuideSelectors = [
            '.AppBanner', '.MobileAppBanner', '.DownloadBanner',
            '[class*="app-banner"]', '[class*="download"]', '[class*="guide"]',
            '[id*="app"]', '[id*="download"]', '[id*="banner"]'
          ];
          
          appGuideSelectors.forEach(selector => {
            try {
              const elements = document.querySelectorAll(selector);
              elements.forEach(el => {
                const style = window.getComputedStyle(el);
                if (style.display !== 'none') {
                  appGuideElements.push({
                    selector: selector,
                    tagName: el.tagName,
                    className: el.className,
                    id: el.id,
                    display: style.display,
                    visibility: style.visibility
                  });
                }
              });
            } catch (e) {
              // 忽略选择器错误
            }
          });
          
          return {
            pageInfo: pageInfo,
            styleIssues: styleIssues,
            suspiciousOverlays: suspiciousOverlays,
            appGuideElements: appGuideElements,
            scrollTest: {
              canScroll: canScroll,
              originalY: originalY,
              afterScrollY: afterScrollY
            },
            timestamp: Date.now()
          };
        })();
      ''');
      
             if (result is Map) {
         final resultMap = Map<String, dynamic>.from(result);
         getLogger().i('✅ 滚动问题检测完成');
         _logDetectionResults(resultMap);
         return resultMap;
       }
      
    } catch (e) {
      getLogger().e('❌ 检测滚动问题失败: $e');
    }
    
    return null;
  }
  
  /// 应用综合修复方案
  static Future<bool> applyComprehensiveFix(
    InAppWebViewController controller
  ) async {
    try {
      getLogger().i('🔧 应用综合滚动修复方案...');
      
      final result = await controller.evaluateJavascript(source: '''
        (function() {
          console.log('🔧 开始综合滚动修复...');
          let fixedIssues = 0;
          
          // 1. 强制重置基础样式
          const resetBasicStyles = function() {
            const html = document.documentElement;
            const body = document.body;
            
            [html, body].forEach(el => {
              if (el) {
                // 重置所有可能的滚动阻止样式
                el.style.overflow = '';
                el.style.overflowY = '';
                el.style.overflowX = 'hidden'; // 保持水平滚动隐藏
                el.style.height = '';
                el.style.maxHeight = '';
                el.style.position = '';
                
                // 移除滚动锁定相关的类和属性
                el.classList.remove('noscroll', 'no-scroll', 'scroll-locked', 
                                   'modal-open', 'overflow-hidden');
                el.removeAttribute('data-scroll-locked');
                el.removeAttribute('data-body-scroll-lock');
                
                fixedIssues++;
              }
            });
          };
          
          // 2. 移除或隐藏问题遮罩层
          const removeProblematicOverlays = function() {
            const overlays = document.querySelectorAll('*');
            
            overlays.forEach(overlay => {
              const style = window.getComputedStyle(overlay);
              const position = style.position;
              const zIndex = parseInt(style.zIndex) || 0;
              
              // 识别可能导致问题的遮罩层
              if ((position === 'fixed' || position === 'absolute') && 
                  zIndex > 999 && 
                  overlay.offsetWidth > window.innerWidth * 0.8 &&
                  overlay.offsetHeight > window.innerHeight * 0.8) {
                
                // 检查是否可能是APP引导相关
                const className = (overlay.className || '').toLowerCase();
                const id = (overlay.id || '').toLowerCase();
                
                const isAppGuide = className.includes('app') || 
                                 className.includes('download') || 
                                 className.includes('banner') ||
                                 className.includes('guide') ||
                                 id.includes('app') || 
                                 id.includes('download');
                
                if (isAppGuide || zIndex > 10000) {
                  overlay.style.display = 'none';
                  overlay.style.visibility = 'hidden';
                  overlay.style.pointerEvents = 'none';
                  overlay.style.zIndex = '-1';
                  
                  console.log('🗑️ 隐藏问题遮罩:', overlay.tagName, className || id);
                  fixedIssues++;
                }
              }
            });
          };
          
          // 3. 修复触摸事件
          const fixTouchEvents = function() {
            const events = ['touchstart', 'touchmove', 'touchend', 'scroll', 'wheel'];
            
            events.forEach(eventType => {
              // 移除可能的全局事件阻止器
              try {
                document.removeEventListener(eventType, function() {}, true);
                window.removeEventListener(eventType, function() {}, true);
              } catch (e) {
                // 忽略移除失败
              }
              
              // 重新添加允许滚动的监听器
              document.addEventListener(eventType, function(e) {
                if (eventType === 'touchmove' || eventType === 'scroll') {
                  // 确保这些事件不被阻止
                  Object.defineProperty(e, 'preventDefault', {
                    value: function() {
                      // 对于滚动相关事件，不执行preventDefault
                      if (eventType !== 'touchmove' && eventType !== 'scroll') {
                        Event.prototype.preventDefault.call(this);
                      }
                    }
                  });
                }
              }, { passive: true, capture: false });
            });
            
            fixedIssues++;
          };
          
          // 4. 网站特定修复
          const applyWebsiteSpecificFixes = function() {
            const hostname = window.location.hostname;
            
            // 知乎
            if (hostname.includes('zhihu.com')) {
              const zhihuElements = document.querySelectorAll(
                '.AppBanner, .MobileAppBanner, .DownloadBanner, ' +
                '[data-zop*="app"], [data-za-module*="AppBanner"]'
              );
              zhihuElements.forEach(el => {
                el.style.display = 'none';
                fixedIssues++;
              });
            }
            
            // 微博
            if (hostname.includes('weibo.com')) {
              const weiboElements = document.querySelectorAll(
                '.m-text-download, .m-download-app, .download-layer'
              );
              weiboElements.forEach(el => {
                el.style.display = 'none';
                fixedIssues++;
              });
            }
            
            // 今日头条/抖音
            if (hostname.includes('toutiao.com') || hostname.includes('douyin.com')) {
              const ttElements = document.querySelectorAll(
                '.download-bar, .app-download-bar, .guide-download'
              );
              ttElements.forEach(el => {
                el.style.display = 'none';
                fixedIssues++;
              });
            }
          };
          
          // 5. 强制恢复滚动
          const forceEnableScrolling = function() {
            // 使用!important强制覆盖
            const style = document.createElement('style');
            style.id = 'force-scroll-fix';
            style.innerHTML = \`
              html, body {
                overflow-y: auto !important;
                overflow-x: hidden !important;
                height: auto !important;
                position: static !important;
                max-height: none !important;
              }
              
              * {
                -webkit-overflow-scrolling: touch !important;
              }
              
              /* 隐藏可能的APP引导元素 */
              [class*="app-banner"],
              [class*="download-banner"],
              [id*="app-banner"],
              [id*="download-banner"] {
                display: none !important;
              }
            \`;
            
            // 移除旧的修复样式
            const oldStyle = document.getElementById('force-scroll-fix');
            if (oldStyle) oldStyle.remove();
            
            document.head.appendChild(style);
            fixedIssues++;
          };
          
          // 执行所有修复步骤
          resetBasicStyles();
          removeProblematicOverlays();
          fixTouchEvents();
          applyWebsiteSpecificFixes();
          forceEnableScrolling();
          
          // 测试修复效果
          const originalY = window.pageYOffset;
          window.scrollBy(0, 10);
          const afterFixY = window.pageYOffset;
          window.scrollTo(0, originalY);
          
          const isFixed = afterFixY !== originalY;
          
          console.log(\`✅ 综合修复完成，修复了 \${fixedIssues} 个问题，滚动测试: \${isFixed ? '成功' : '失败'}\`);
          
          return {
            success: isFixed,
            fixedIssues: fixedIssues,
            scrollTest: {
              originalY: originalY,
              afterFixY: afterFixY,
              canScrollNow: isFixed
            }
          };
        })();
      ''');
      
      if (result is Map) {
        final success = result['success'] as bool? ?? false;
        final fixedIssues = result['fixedIssues'] as int? ?? 0;
        
        getLogger().i('🔧 综合修复完成: ${success ? "成功" : "失败"}, 修复了$fixedIssues个问题');
        return success;
      }
      
    } catch (e) {
      getLogger().e('❌ 应用综合修复失败: $e');
    }
    
    return false;
  }
  
  /// 记录检测结果
  static void _logDetectionResults(Map<String, dynamic> result) {
    final scrollTest = result['scrollTest'] as Map<String, dynamic>?;
    final canScroll = scrollTest?['canScroll'] as bool? ?? false;
    
    getLogger().i('📊 滚动检测结果:');
    getLogger().i('  - 是否可以滚动: ${canScroll ? "✅ 是" : "❌ 否"}');
    
    if (!canScroll) {
      final styleIssues = result['styleIssues'] as Map<String, dynamic>?;
      if (styleIssues != null) {
        final htmlStyle = styleIssues['html'] as Map<String, dynamic>?;
        final bodyStyle = styleIssues['body'] as Map<String, dynamic>?;
        
        getLogger().w('🔍 发现样式问题:');
        if (htmlStyle != null) {
          getLogger().w('  - HTML: overflow=${htmlStyle['overflow']}, height=${htmlStyle['height']}');
        }
        if (bodyStyle != null) {
          getLogger().w('  - BODY: overflow=${bodyStyle['overflow']}, height=${bodyStyle['height']}');
        }
      }
      
      final overlays = result['suspiciousOverlays'] as List<dynamic>?;
      if (overlays != null && overlays.isNotEmpty) {
        getLogger().w('🚨 发现可疑遮罩层 ${overlays.length} 个');
        for (final overlay in overlays) {
          final overlayMap = overlay as Map<String, dynamic>;
          getLogger().w('  - ${overlayMap['tagName']}: ${overlayMap['className']}, z-index=${overlayMap['zIndex']}');
        }
      }
      
      final appGuides = result['appGuideElements'] as List<dynamic>?;
      if (appGuides != null && appGuides.isNotEmpty) {
        getLogger().w('📱 发现APP引导元素 ${appGuides.length} 个');
      }
    }
  }
} 
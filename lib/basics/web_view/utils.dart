// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../logger.dart';

class WebViewUtils {

  /// 注入移动端弹窗处理脚本 - 恢复滚动功能
  static Future<void> injectMobilePopupHandler(InAppWebViewController controller) async {
    try {
      getLogger().i('📱 开始注入移动端弹窗处理脚本...');

      const jsCode = '''
      (function() {
        console.log('📱 移动端弹窗处理脚本已启动');
        
        // 定时检查并修复滚动问题
        const checkAndFixScrolling = function() {
          try {
            // 1. 强制恢复页面滚动
            const html = document.documentElement;
            const body = document.body;
            
            // 移除可能的滚动阻止样式
            [html, body].forEach(el => {
              if (el) {
                el.style.overflow = '';
                el.style.overflowY = '';
                el.style.height = '';
                el.style.position = '';
                
                // 移除data属性中的滚动锁定标记
                el.removeAttribute('data-scroll-locked');
                el.removeAttribute('data-body-scroll-lock');
              }
            });
            
            // 2. 检查并移除可能的遮罩层
            const overlays = document.querySelectorAll(
              '[style*="position: fixed"], [style*="position:fixed"], ' +
              '.modal-backdrop, .overlay, .mask, .popup-mask, ' +
              '[class*="modal"], [class*="popup"], [class*="overlay"], ' +
              '[id*="modal"], [id*="popup"], [id*="overlay"]'
            );
            
            overlays.forEach(overlay => {
              const style = window.getComputedStyle(overlay);
              const zIndex = parseInt(style.zIndex) || 0;
              const position = style.position;
              
              // 检查是否是高层级的遮罩元素
              if ((position === 'fixed' || position === 'absolute') && 
                  zIndex > 1000 && 
                  overlay.offsetWidth > window.innerWidth * 0.8 &&
                  overlay.offsetHeight > window.innerHeight * 0.8) {
                
                console.log('🗑️ 移除可疑的遮罩层:', overlay.className || overlay.id);
                
                // 尝试隐藏而不是删除，避免破坏页面
                overlay.style.display = 'none';
                overlay.style.visibility = 'hidden';
                overlay.style.zIndex = '-1';
                overlay.style.pointerEvents = 'none';
              }
            });
            
            // 3. 恢复触摸事件
            const events = ['touchstart', 'touchmove', 'touchend', 'scroll', 'wheel'];
            events.forEach(eventType => {
              // 移除所有可能的事件阻止器
              const oldHandler = document['on' + eventType];
              if (oldHandler) {
                document['on' + eventType] = null;
              }
              
              // 确保事件可以正常冒泡
              document.addEventListener(eventType, function(e) {
                // 不阻止默认行为，让滚动正常进行
                if (eventType === 'touchmove' || eventType === 'scroll' || eventType === 'wheel') {
                  e.stopImmediatePropagation = function() {}; // 禁用立即停止传播
                }
              }, { passive: true, capture: true });
            });
            
            // 4. 特殊处理知名网站的APP引导弹窗
            const hostname = window.location.hostname;
            
            // 知乎特殊处理
            if (hostname.includes('zhihu.com')) {
              const zhihuPopups = document.querySelectorAll(
                '.AppBanner, .MobileAppBanner, .DownloadBanner, ' +
                '[class*="AppBanner"], [class*="DownloadBanner"], ' +
                '[data-zop*="app"], [data-zop*="banner"]'
              );
              
              zhihuPopups.forEach(popup => {
                popup.style.display = 'none';
                console.log('🎯 隐藏知乎APP引导:', popup.className);
              });
            }
            
            // 5. 强制启用滚动并固定页面宽度 - 最后的保险措施
            html.style.overflow = 'hidden auto !important';  // 禁用水平滚动，启用垂直滚动
            body.style.overflow = 'hidden auto !important';  // 禁用水平滚动，启用垂直滚动
            html.style.position = 'static !important';
            body.style.position = 'static !important';
            html.style.width = '100% !important';
            body.style.width = '100% !important';
            html.style.maxWidth = '100% !important';
            body.style.maxWidth = '100% !important';
            
            console.log('✅ 滚动功能检查修复完成');
            
            return true;
          } catch (error) {
            console.error('❌ 修复滚动功能时出错:', error);
            return false;
          }
        };
        
        // 立即执行一次
        checkAndFixScrolling();
        
        // 延迟执行，处理可能的异步弹窗
        setTimeout(checkAndFixScrolling, 1000);
        setTimeout(checkAndFixScrolling, 3000);
        setTimeout(checkAndFixScrolling, 5000);
        
        // 监听页面变化，自动修复
        if (typeof MutationObserver !== 'undefined') {
          const observer = new MutationObserver(function(mutations) {
            let shouldCheck = false;
            
            mutations.forEach(function(mutation) {
              // 检查是否有样式或类的变化
              if (mutation.type === 'attributes' && 
                  (mutation.attributeName === 'style' || 
                   mutation.attributeName === 'class')) {
                shouldCheck = true;
              }
              
              // 检查是否有新增的元素（可能是弹窗）
              if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                mutation.addedNodes.forEach(function(node) {
                  if (node.nodeType === 1) { // Element node
                    const element = node;
                    if (element.style && 
                        (element.style.position === 'fixed' || 
                         element.style.zIndex > 1000)) {
                      shouldCheck = true;
                    }
                  }
                });
              }
            });
            
            if (shouldCheck) {
              setTimeout(checkAndFixScrolling, 500);
            }
          });
          
          observer.observe(document.body, {
            attributes: true,
            childList: true,
            subtree: true,
            attributeFilter: ['style', 'class']
          });
          
          console.log('🔍 页面变化监听器已启动');
        }
        
        console.log('✅ 移动端弹窗处理脚本初始化完成');
      })();
      ''';

      await controller.evaluateJavascript(source: jsCode);
      getLogger().i('✅ 移动端弹窗处理脚本注入完成');

    } catch (e) {
      getLogger().e('❌ 注入移动端弹窗处理脚本失败: $e');
    }
  }


  /// 注入平台特定的反检测代码
  static Future<void> injectPlatformSpecificAntiDetection(InAppWebViewController controller) async {
    try {
      getLogger().i('🛡️ 开始注入平台特定反检测代码 - 平台: ${Platform.isAndroid ? 'Android' : 'iOS'}');

      String antiDetectionScript;

      if (Platform.isAndroid) {
        // Android WebView 特有的反检测代码 (v2 - 增强版)
        antiDetectionScript = '''
        (function() {
          console.log('🤖 Android WebView Advanced Anti-Detection Script v2');
          
          try {
            // 1. 清理已知的WebView指纹
            delete window.AndroidBridge;
            delete window.android;
            delete window.prompt;

            // 2. 伪装navigator核心属性
            // 最关键的属性：webdriver
            Object.defineProperty(navigator, 'webdriver', {
              get: () => undefined,
            });

            // 伪装Chrome浏览器特有的对象
            window.chrome = window.chrome || {};
            window.chrome.app = {
              isInstalled: false,
              InstallState: {
                DISABLED: 'disabled',
                INSTALLED: 'installed',
                NOT_INSTALLED: 'not_installed'
              },
              RunningState: {
                CANNOT_RUN: 'cannot_run',
                READY_TO_RUN: 'ready_to_run',
                RUNNING: 'running'
              }
            };
            window.chrome.webstore = {
              onInstallStageChanged: {},
              onDownloadProgress: {}
            };
            window.chrome.runtime = {};

            // 3. 伪装插件和MIME类型
            const originalPlugins = navigator.plugins;
            const plugins = [
              { name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer', description: 'Portable Document Format', mimeTypes: [{ type: 'application/x-google-chrome-pdf', suffixes: 'pdf' }] },
              { name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai', description: '', mimeTypes: [{ type: 'application/pdf', suffixes: 'pdf' }] },
              { name: 'Native Client', filename: 'internal-nacl-plugin', description: '', mimeTypes: [{ type: 'application/x-nacl', suffixes: '' }, { type: 'application/x-pnacl', suffixes: '' }] }
            ];
            plugins.item = (i) => plugins[i];
            plugins.namedItem = (name) => plugins.find(p => p.name === name);
            Object.defineProperty(navigator, 'plugins', { get: () => plugins });
            
            const mimeTypes = [
                { type: 'application/pdf', suffixes: 'pdf', enabledPlugin: plugins[1] },
                { type: 'application/x-google-chrome-pdf', suffixes: 'pdf', enabledPlugin: plugins[0] },
                { type: 'application/x-nacl', suffixes: '', enabledPlugin: plugins[2] },
                { type: 'application/x-pnacl', suffixes: '', enabledPlugin: plugins[2] }
            ];
            mimeTypes.item = (i) => mimeTypes[i];
            mimeTypes.namedItem = (name) => mimeTypes.find(m => m.type === name);
            Object.defineProperty(navigator, 'mimeTypes', { get: () => mimeTypes });

            // 4. 伪装权限API
            if (navigator.permissions) {
                const originalQuery = navigator.permissions.query;
                navigator.permissions.query = (parameters) => (
                  parameters.name === 'notifications'
                    ? Promise.resolve({ state: Notification.permission })
                    : originalQuery.apply(navigator.permissions, [parameters])
                );
            }

            // 5. 伪装设备属性
            if ('deviceMemory' in navigator) {
              Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });
            }
            Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
            Object.defineProperty(navigator, 'languages', { get: () => ['zh-CN', 'zh', 'en-US', 'en'] });

            // 6. 伪装WebGL渲染信息
            try {
                const getParameter = WebGLRenderingContext.prototype.getParameter;
                WebGLRenderingContext.prototype.getParameter = function(parameter) {
                    // UNMASKED_VENDOR_WEBGL
                    if (parameter === 37445) return 'Google Inc. (NVIDIA)';
                    // UNMASKED_RENDERER_WEBGL
                    if (parameter === 37446) return 'ANGLE (NVIDIA, NVIDIA GeForce GTX 1050 Ti Direct3D11 vs_5_0 ps_5_0, D3D11)';
                    return getParameter.apply(this, [parameter]);
                };
            } catch (e) {
                console.warn('⚠️ WebGL spoofing failed:', e.toString());
            }
            
            console.log('✅ Android Advanced Anti-Detection finished.');
          } catch (e) {
            console.warn('⚠️ Android anti-detection script failed:', e.toString());
          }
        })();
        ''';
      } else {
        // iOS WebView 特有的反检测代码
        antiDetectionScript = '''
        (function() {
          console.log('🍎 iOS WebView 反检测脚本启动');
          
          try {
            // 删除 iOS WebView 的特有属性
            delete window.webkit;
            
            // 确保 Safari 特征正确
            Object.defineProperty(navigator, 'vendor', {
              get: () => 'Apple Computer, Inc.',
              configurable: true
            });
            
            // 模拟 Safari 的 plugins
            Object.defineProperty(navigator, 'plugins', {
              get: () => [],
              configurable: true
            });
            
            console.log('✅ iOS WebView 反检测完成');
            
          } catch (e) {
            console.warn('⚠️ iOS 反检测部分失败:', e);
          }
        })();
        ''';
      }

      await controller.evaluateJavascript(source: antiDetectionScript);
      getLogger().i('✅ 平台特定反检测代码注入完成');

    } catch (e) {
      getLogger().e('❌ 注入平台特定反检测代码失败: $e');
    }
  }


  static Future<void> fixPageWidth(InAppWebViewController controller,EdgeInsets padding) async {
    controller.evaluateJavascript(source: '''
                  // 设置内边距
                  document.body.style.paddingTop = '${padding.top}px';
                  document.body.style.paddingBottom = '${padding.bottom}px';
                  document.body.style.paddingLeft = '${padding.left}px';
                  document.body.style.paddingRight = '${padding.right}px';
                  document.documentElement.style.scrollPaddingTop = '${padding.top}px';
                  
                  // 修复页面宽度和防止水平滚动
                  (function() {
                    console.log('🔧 开始修复页面宽度设置...');
                    
                    // 1. 设置或更新viewport meta标签
                    let viewport = document.querySelector('meta[name="viewport"]');
                    if (!viewport) {
                      viewport = document.createElement('meta');
                      viewport.name = 'viewport';
                      document.head.appendChild(viewport);
                    }
                    viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no';
                    
                    // 2. 强制设置HTML和body样式
                    const style = document.createElement('style');
                    style.textContent = `
                      html, body {
                        width: 100% !important;
                        max-width: 100% !important;
                        min-width: 100% !important;
                        overflow-x: hidden !important;
                        overflow-y: auto !important;
                        box-sizing: border-box !important;
                        margin: 0 !important;
                        padding: 0 !important;
                      }
                      
                      * {
                        max-width: 100% !important;
                        box-sizing: border-box !important;
                      }
                      
                      /* 防止图片和视频溢出 */
                      img, video, iframe, object, embed {
                        max-width: 100% !important;
                        height: auto !important;
                      }
                      
                      /* 防止表格溢出 */
                      table {
                        max-width: 100% !important;
                        table-layout: fixed !important;
                        word-wrap: break-word !important;
                      }
                      
                      /* 防止预格式化文本溢出 */
                      pre, code {
                        max-width: 100% !important;
                        overflow-x: auto !important;
                        word-wrap: break-word !important;
                        white-space: pre-wrap !important;
                      }
                      
                      /* 防止容器溢出 */
                      div, section, article, main, aside, nav, header, footer {
                        max-width: 100% !important;
                        overflow-x: hidden !important;
                      }
                    `;
                    document.head.appendChild(style);
                    
                    // 3. 重新应用内边距（确保样式重置后仍然生效）
                    document.body.style.paddingTop = '${padding.top}px';
                    document.body.style.paddingBottom = '${padding.bottom}px';
                    document.body.style.paddingLeft = '${padding.left}px';
                    document.body.style.paddingRight = '${padding.right}px';
                    
                    console.log('✅ 页面宽度修复完成');
                  })();
                ''');
  }


  /// 生成用户友好的错误消息
  static String generateUserFriendlyErrorMessage(String errorType, String description, String url) {
    switch (errorType) {
      case 'FAILED_SSL_HANDSHAKE':
      case 'SSL_PROTOCOL_ERROR':
        return '网站SSL证书有问题\n\n这可能是网站配置问题或网络环境限制。\n请稍后重试或尝试其他网络。';

      case 'NAME_NOT_RESOLVED':
        return '无法解析网站地址\n\n请检查网络连接或稍后重试。';

      case 'INTERNET_DISCONNECTED':
        return '网络连接已断开\n\n请检查网络设置并重新连接。';

      case 'CONNECTION_TIMED_OUT':
        return '连接超时\n\n网络响应较慢，请稍后重试。';

      case 'CONNECTION_REFUSED':
      case 'CONNECTION_RESET':
        return '连接被拒绝\n\n网站可能暂时不可用，请稍后重试。';

      default:
        return '页面加载失败\n\n错误类型: $errorType\n错误描述: $description\n\n请稍后重试或检查网络连接。';
    }
  }

  /// 生成HTTP错误消息
  static String generateHttpErrorMessage(int statusCode, String? reasonPhrase, String domain) {
    switch (statusCode) {
      case 403:
        return '访问被限制 (403)\n\n该网站具有反爬虫保护。\n\n建议：\n• 稍后重试\n• 使用浏览器直接访问';
      case 404:
        return '页面不存在 (404)\n\n请检查链接是否正确。';

      case 429:
        return '请求过于频繁 (429)\n\n请稍后再试。';

      case 500:
        return '服务器内部错误 (500)\n\n网站服务器出现问题，请稍后重试。';

      case 503:
        return '服务不可用 (503)\n\n网站暂时无法访问，请稍后重试。';

      default:
        return '页面加载失败 ($statusCode)\n${reasonPhrase ?? 'Unknown Error'}\n\n请稍后重试或检查网络连接。';
    }
  }

  /// 检查是否是API请求
  static bool isApiRequest(String url) {
    // 常见的API请求路径模式
    final apiPatterns = [
      '/api/',
      '/ajax/',
      '/json/',
      '/v1/',
      '/v2/',
      '/v3/',
      '/graphql',
      '.json',
      'qrcode',
      'login',
      'auth',
    ];

    return apiPatterns.any((pattern) => url.toLowerCase().contains(pattern));
  }

  /// 检查是否是广告或统计请求
  static bool isAdOrAnalyticsRequest(String url) {
    final adPatterns = [
      '/ads/',
      '/ad/',
      '/analytics/',
      '/track/',
      '/pixel',
      '/beacon',
      '/stat/',
      '/click',
      'auto_ds', // 从错误URL看到的模式
      'googletagmanager',
      'google-analytics',
    ];

    return adPatterns.any((pattern) => url.toLowerCase().contains(pattern));
  }

  /// 检查是否是可忽略的错误类型
  static bool isIgnorableError(String errorType, String url, String domain) {
    // SSL相关错误（通常是第三方资源）
    final sslErrors = [
      'FAILED_SSL_HANDSHAKE',
      'SSL_PROTOCOL_ERROR',
      'CERT_AUTHORITY_INVALID',
      'CERT_DATE_INVALID',
      'CERT_COMMON_NAME_INVALID',
    ];

    // 网络连接错误（可能是临时的）
    final networkErrors = [
      'NAME_NOT_RESOLVED',
      'INTERNET_DISCONNECTED',
      'CONNECTION_TIMED_OUT',
      'CONNECTION_REFUSED',
      'CONNECTION_RESET',
    ];

    // 第三方服务域名（通常可以忽略）
    final thirdPartyDomains = [
      'googletagmanager.com',
      'google-analytics.com',
      'doubleclick.net',
      'googlesyndication.com',
      'facebook.com',
      'twitter.com',
      'tiktok.com',
      'bytedance.com',
      'adutp.com', // 从错误URL看到的广告域名
      'ymjs.adutp.com',
    ];

    // 检查错误类型
    if (sslErrors.contains(errorType) || networkErrors.contains(errorType)) {
      // 如果是第三方域名的SSL/网络错误，可以忽略
      if (thirdPartyDomains.any((thirdParty) => domain.contains(thirdParty))) {
        return true;
      }

      // 检查是否是广告或统计URL
      if (WebViewUtils.isAdOrAnalyticsRequest(url)) {
        return true;
      }
    }

    return false;
  }

}
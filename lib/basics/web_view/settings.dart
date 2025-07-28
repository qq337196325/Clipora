// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewSettings {

  /// 获取平台优化的WebView设置
  static InAppWebViewSettings getWebViewSettings() {
    // 基础设置
    final settings = InAppWebViewSettings(
      // --- 核心功能开关 ---
      // 【允许执行JavaScript】: WebView的核心能力，必须为true。
      javaScriptEnabled: true,
      // 【允许JS自动打开窗口】: 允许JS通过 `window.open()` 等方式打开新窗口，对于某些登录流程是必要的。
      javaScriptCanOpenWindowsAutomatically: true,

      // --- 数据与存储 (关键反爬点) ---
      // 【启用DOM存储】: 允许网站使用 localStorage 和 sessionStorage，是现代网站的标配。
      domStorageEnabled: true,
      // 【启用Web数据库】: 允许网站使用 Web SQL Database API（虽然已废弃，但一些老网站可能还在用）。
      databaseEnabled: true,
      // 【允许第三方Cookie】: 允许跨域请求设置Cookie，对于处理内嵌内容或SSO登录很重要。
      thirdPartyCookiesEnabled: true,

      // --- 导航与拦截 ---
      // 【启用URL加载拦截】: 设为true后，`shouldOverrideUrlLoading` 回调才会生效，是实现URL拦截的关键。
      useShouldOverrideUrlLoading: true,

      // --- 身份标识 ---
      // 【设置User-Agent】: 向服务器声明自己的"身份"，是反爬虫伪装的第一步。
      userAgent: _getPlatformOptimizedUserAgent(),

      // --- 内容与安全策略 ---
      // 【混合内容模式】: 在HTTPS页面加载HTTP内容时的策略。`MIXED_CONTENT_ALWAYS_ALLOW` 表示总是允许，以避免内容显示不全。
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      // 【允许内联媒体播放】: 允许视频在页面内播放，而不是强制全屏。
      allowsInlineMediaPlayback: true,
      // 【允许手势导航】(iOS): 允许用户通过左右滑动手势来前进或后退页面。
      allowsBackForwardNavigationGestures: true,

      // --- UI与错误页面 ---
      // 【禁用默认错误页面】: 禁用WebView内置的错误页面（如"网页无法打开"），以便我们用自定义的UI组件来显示错误。
      disableDefaultErrorPage: true,
      // 【禁用上下文菜单】: 是否禁用长按时出现的系统菜单（如复制、粘贴）。设为false以更像真实浏览器。
      disableContextMenu: false,

      // --- 缓存策略 ---
      // 【缓存模式】: 使用默认的缓存策略，让WebView自行决定如何使用缓存。
      cacheMode: CacheMode.LOAD_DEFAULT,
      // 【清除缓存】: 在WebView启动时不清除缓存，以保留之前的会话和数据。
      clearCache: false,

      // --- 布局与交互 ---
      // 【文本缩放比例】: 设置页面文字的缩放百分比，100表示正常大小。
      textZoom: 100,
      // 【支持缩放】: 是否允许用户通过双指捏合来缩放页面。
      supportZoom: true,
      // 【显示内置缩放控件】: 是否显示WebView内置的缩放按钮（通常不美观，设为false）。
      builtInZoomControls: false,
      // 【在屏幕上显示缩放控件】(Android): 同上，控制原生缩放控件的显示。
      displayZoomControls: false,

      // --- 滚动控制 ---
      // 【禁用水平滚动】: 强制页面内容在一屏内显示，防止出现水平滚动条，提升移动端体验。
      disableHorizontalScroll: true,
      // 【禁用垂直滚动】: 设为false，允许用户正常地上下滚动页面。
      disableVerticalScroll: false,

      // --- 多媒体支持 ---
      // 【媒体播放需要用户手势】: 要求用户必须先点击一下才能播放视频或音频，这是现代浏览器的标准行为，可增加真实性。
      mediaPlaybackRequiresUserGesture: true,

      // --- 文件访问权限 ---
      // 【允许文件访问】: 允许WebView从文件系统加载资源（file://...）。
      allowFileAccess: true,
      // 【允许内容访问】(Android): 允许WebView通过Content Provider访问内容。
      allowContentAccess: true,
    );

    // 添加平台特定设置
    if (Platform.isIOS) {
      // 【禁用输入附件视图】(iOS): 隐藏键盘上方默认出现的辅助工具栏（包含"上一个/下一个/完成"）。
      settings.disableInputAccessoryView = true;
      // 【禁止增量渲染】(iOS): 设为false表示启用增量渲染，即边加载边显示，体验更好。
      settings.suppressesIncrementalRendering = false;
    }

    return settings;
  }

  /// 获取平台优化的User-Agent
  static String _getPlatformOptimizedUserAgent() {
    if (Platform.isAndroid) {
      // Android Chrome User-Agent - 更新为更现代的版本以匹配headers
      return "Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36";
    } else if (Platform.isIOS) {
      // iOS Safari User-Agent - 同样更新到较新版本
      return "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1";
    } else {
      // 默认使用通用移动端User-Agent
      return "Mozilla/5.0 (Mobile; rv:109.0) Gecko/109.0 Firefox/119.0";
    }
  }


  /// 获取平台优化的请求头
  static Map<String, String> getPlatformOptimizedHeaders() {
    if (Platform.isAndroid) {
      // Android Chrome 的典型请求头 - 更新至 Chrome 124
      return {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0',
        'sec-ch-ua': '"Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"',
        'sec-ch-ua-mobile': '?1',
        'sec-ch-ua-platform': '"Android"',
        'sec-ch-ua-platform-version': '"14.0.0"',
        'sec-ch-ua-model': '"Pixel 7 Pro"',
        'sec-ch-ua-full-version-list': '"Chromium";v="124.0.6367.123", "Google Chrome";v="124.0.6367.123", "Not-A.Brand";v="99.0.0.0"',

        'Pragma': 'no-cache',
      };
    } else {
      // iOS Safari 的典型请求头
      return {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Cache-Control': 'max-age=0',

        'Pragma': 'no-cache',
      };
    }
  }


}
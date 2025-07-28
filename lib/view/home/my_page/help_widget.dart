// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../../basics/logger.dart';
import '../../../basics/translations/language_controller.dart';
import '../../../basics/web_view/settings.dart';


/// 帮助文档页面
class HelpDocumentationPage extends StatefulWidget {

  const HelpDocumentationPage({
    super.key,
  });

  @override
  State<HelpDocumentationPage> createState() => _HelpDocumentationPageState();
}

class _HelpDocumentationPageState extends State<HelpDocumentationPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String currentTitle = '';
  String url = '';

  @override
  void initState() {
    super.initState();


    url = _getHelpDocumentationUrl();

    // initEnhancedLogic();
  }


  /// 获取帮助文档URL
  String _getHelpDocumentationUrl() {
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.currentLocale.value;

    final docLanguage = _mapLanguageCodeForDocs(
      currentLocale.languageCode,
      currentLocale.countryCode ?? '',
    );

    // 直接使用重定向后的 URL，避免重定向问题
    return 'https://docs.guanshangyun.com/$docLanguage/docs/intro/';
    // https://docstest.guanshangyun.com/zh/docs/intro/
    // return "http://docstest.guanshangyun.com/";
    // return "https://docstest.guanshangyun.com/docs/intro";
  }

  /// 将应用的语言代码映射到文档URL的语言代码
  String _mapLanguageCodeForDocs(String languageCode, String countryCode) {
    // 根据语言代码和国家代码映射到文档支持的语言
    switch (languageCode) {
      case 'zh':
        return countryCode == 'TW' ? 'tw' : 'zh'; // 繁体中文使用 tw，简体中文使用 zh
      case 'en':
        return 'en';
      case 'ja':
        return 'ja';
      case 'ko':
        return 'ko';
      case 'fr':
        return 'fr';
      case 'de':
        return 'de';
      case 'es':
        return 'es';
      case 'ru':
        return 'ru';
      case 'ar':
        return 'ar';
      case 'pt':
        return 'pt';
      case 'it':
        return 'it';
      case 'nl':
        return 'nl';
      case 'th':
        return 'th';
      case 'vi':
        return 'vi';
      default:
        return 'en'; // 默认使用英文
    }
  }


  @override
  Widget build(BuildContext context) {
    getLogger().i('链接：$url');

    return Scaffold(
      appBar: AppBar(
        title:
            Text(currentTitle.isEmpty ? 'help_documentation'.tr : currentTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url), headers: WebViewSettings.getPlatformOptimizedHeaders()),
        initialSettings: WebViewSettings.getWebViewSettings(),  // 【初始化设置】: WebView的各项详细配置，通过下面的 _getWebViewSettings 方法统一定义。
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          // setState(() {
          //   isLoading = true;
          // });
          getLogger().i('开始加载: $url');
        },
        onLoadStop: (controller, url) async {
          setState(() {
            isLoading = false;
          });
          getLogger().i('加载完成: $url');

          // 获取页面标题
          // final title = await controller.getTitle();
          // if (title != null && title.isNotEmpty) {
          //   setState(() {
          //     currentTitle = title;
          //   });
          // }

          // 等待一下确保所有资源加载完成，然后检查页面状态
          // await Future.delayed(const Duration(milliseconds: 500));

        },
        onReceivedError: (controller, request, error) {
          // setState(() {
          //   isLoading = false;
          // });
          getLogger().e('WebView加载错误: ${error.description}');
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          getLogger().e(
              'HTTP错误: ${errorResponse.statusCode} - ${errorResponse.reasonPhrase}');
        },
        // shouldOverrideUrlLoading: (controller, navigationAction) async {
        //   // final url = navigationAction.request.url;
        //   // getLogger().i('URL导航: $url');
        //   //
        //   // // 允许所有导航
        //   // return NavigationActionPolicy.ALLOW;
        // },
        shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
        onProgressChanged: (controller, progress) {
          // if (progress == 100) {
          //   setState(() {
          //     isLoading = false;
          //   });
          // }
        },
      ),
    );
  }


  /// 优化的URL导航处理
  Future<NavigationActionPolicy> _handleOptimizedUrlNavigation(
      InAppWebViewController controller,
      NavigationAction navigationAction
      ) async {
    final uri = navigationAction.request.url!;
    final url = uri.toString();

    getLogger().d('🌐 URL跳转拦截: $url');

    // 检查是否是自定义scheme（非http/https）
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      getLogger().w('⚠️ 拦截自定义scheme跳转: ${uri.scheme}://');
      return NavigationActionPolicy.CANCEL;
    }

    // 检查是否是应用内跳转scheme
    if (url.startsWith('snssdk') ||
        url.startsWith('sslocal') ||
        url.startsWith('toutiao') ||
        url.startsWith('newsarticle') ||
        url.startsWith('zhihu')) { // 明确拦截知乎的App拉起协议
      getLogger().w('⚠️ 拦截应用跳转scheme: $url');
      return NavigationActionPolicy.CANCEL;
    }

    // 允许正常的HTTP/HTTPS链接
    getLogger().d('✅ 允许正常HTTP跳转: $url');
    return NavigationActionPolicy.ALLOW;
  }

}

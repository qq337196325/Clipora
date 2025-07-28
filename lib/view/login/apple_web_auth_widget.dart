// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../basics/logger.dart';

class AppleWebAuthWidget extends StatefulWidget {
  final String clientId;
  final String redirectUri;
  final Function(Map<String, String>) onSuccess;
  final Function(String) onError;

  const AppleWebAuthWidget({
    super.key,
    required this.clientId,
    required this.redirectUri,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<AppleWebAuthWidget> createState() => _AppleWebAuthWidgetState();
}

class _AppleWebAuthWidgetState extends State<AppleWebAuthWidget> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  String get _authUrl {
    final state = DateTime.now().millisecondsSinceEpoch.toString();
    final params = {
      'response_type': 'code id_token',
      'response_mode': 'form_post',
      'client_id': widget.clientId,
      'redirect_uri': widget.redirectUri,
      'scope': 'email name',
      'state': state,
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://appleid.apple.com/auth/authorize?$queryString';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'i18n_login_Apple登录认证'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_authUrl)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              useOnLoadResource: true,
              allowsInlineMediaPlayback: true,
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              clearCache: false,
              userAgent: _getUserAgent(),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              getLogger().i('Apple Web认证WebView已创建');
            },
            onLoadStart: (controller, url) {
              getLogger().i('开始加载URL: $url');
              _handleUrlChange(url);
            },
            onLoadStop: (controller, url) {
              getLogger().i('加载完成URL: $url');
              setState(() {
                _isLoading = false;
              });
              _handleUrlChange(url);
            },
            onLoadError: (controller, url, code, message) {
              getLogger().e('WebView加载错误: $code - $message, URL: $url');
              setState(() {
                _isLoading = false;
              });
              widget.onError('i18n_login_Web认证窗口加载失败'.tr + ': $message');
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              // 允许Apple的SSL证书
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url;
              getLogger().i('URL导航: $url');
              
              if (_handleUrlChange(url)) {
                return NavigationActionPolicy.CANCEL;
              }
              
              return NavigationActionPolicy.ALLOW;
            },
            onConsoleMessage: (controller, consoleMessage) {
              getLogger().i('Console: ${consoleMessage.message}');
              
              // 检查是否是我们注入的JavaScript返回的数据
              if (consoleMessage.message.startsWith('APPLE_AUTH_DATA:')) {
                try {
                  final dataString = consoleMessage.message.substring('APPLE_AUTH_DATA:'.length);
                  getLogger().i('原始数据字符串: $dataString');
                  
                  // 尝试解析JSON
                  final jsonData = Uri.splitQueryString(dataString);
                  final data = Map<String, String>.from(jsonData);
                  
                  getLogger().i('从JavaScript获取到认证数据: $data');
                  
                  if (data.containsKey('code') || data.containsKey('id_token')) {
                    widget.onSuccess(data);
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  getLogger().e('解析JavaScript数据失败: $e');
                  // 如果解析失败，尝试其他方式
                  _tryAlternativeDataExtraction();
                }
              }
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return HttpAuthResponse(action: HttpAuthResponseAction.PROCEED);
            },
            onUpdateVisitedHistory: (controller, url, isReload) async {
              getLogger().i('访问历史更新: $url');
              _handleUrlChange(url);
            },
            onReceivedHttpError: (controller, request, errorResponse) async {
              getLogger().e('HTTP错误: ${errorResponse.statusCode}');
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在加载Apple登录页面...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getUserAgent() {
    // 使用真实的移动浏览器User-Agent，避免被检测为桌面浏览器
    return 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';
  }

  bool _handleUrlChange(WebUri? url) {
    if (url == null) return false;

    final urlString = url.toString();
    getLogger().i('处理URL变化: $urlString');

    // 检查是否是回调URL
    if (urlString.startsWith(widget.redirectUri)) {
      getLogger().i('检测到回调URL，开始处理认证结果');
      _handleCallback(urlString);
      return true;
    }

    // 检查是否是取消操作
    if (urlString.contains('cancel') || urlString.contains('error')) {
      getLogger().i('用户取消或发生错误');
      Navigator.of(context).pop();
      return true;
    }

    // 检查是否到达了成功页面但还没有被处理
    if (urlString.contains('appleid.apple.com') && urlString.contains('success')) {
      getLogger().i('检测到Apple认证成功页面');
      _tryExtractDataFromPage();
      return false;
    }

    return false;
  }

  // 尝试从页面中提取数据
  void _tryExtractDataFromPage() async {
    if (_webViewController == null) return;
    
    try {
      // 注入JavaScript来获取页面数据
      await _webViewController!.evaluateJavascript(source: '''
        (function() {
          // 检查是否有form数据
          const forms = document.querySelectorAll('form');
          for (let form of forms) {
            const formData = new FormData(form);
            const data = {};
            for (let [key, value] of formData.entries()) {
              data[key] = value;
            }
            if (data.code || data.id_token) {
              console.log('APPLE_AUTH_DATA:' + JSON.stringify(data));
              return data;
            }
          }
          
          // 检查URL参数
          const urlParams = new URLSearchParams(window.location.search);
          const hashParams = new URLSearchParams(window.location.hash.substring(1));
          
          const data = {};
          for (let [key, value] of urlParams.entries()) {
            data[key] = value;
          }
          for (let [key, value] of hashParams.entries()) {
            data[key] = value;
          }
          
          if (data.code || data.id_token) {
            console.log('APPLE_AUTH_DATA:' + JSON.stringify(data));
            return data;
          }
          
          return null;
        })();
      ''');
      
      getLogger().i('已注入JavaScript用于数据提取');
    } catch (e) {
      getLogger().e('JavaScript注入失败: $e');
    }
  }

  // 备用数据提取方法
  void _tryAlternativeDataExtraction() async {
    if (_webViewController == null) return;
    
    try {
      // 直接从当前页面的URL获取数据
      final currentUrl = await _webViewController!.getUrl();
      if (currentUrl != null) {
        final urlString = currentUrl.toString();
        getLogger().i('当前页面URL: $urlString');
        
        if (urlString.startsWith(widget.redirectUri)) {
          _handleCallback(urlString);
        }
      }
    } catch (e) {
      getLogger().e('备用数据提取失败: $e');
    }
  }

  void _handleCallback(String callbackUrl) {
    try {
      final uri = Uri.parse(callbackUrl);
      final params = <String, String>{};

      // 处理URL参数
      uri.queryParameters.forEach((key, value) {
        params[key] = value;
      });

      // 处理fragment参数（如果有）
      if (uri.fragment.isNotEmpty) {
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        params.addAll(fragmentParams);
      }

      getLogger().i('解析到的参数: $params');

      // 检查是否有错误
      if (params.containsKey('error')) {
        final error = params['error'] ?? 'unknown_error';
        final errorDescription = params['error_description'] ?? error;
        getLogger().e('Apple认证错误: $error - $errorDescription');
        widget.onError('i18n_login_Apple认证失败'.tr + ': $errorDescription');
        Navigator.of(context).pop();
        return;
      }

      // 检查是否有授权码
      if (params.containsKey('code')) {
        getLogger().i('✅ 成功获取授权码');
        widget.onSuccess(params);
        Navigator.of(context).pop();
        return;
      }

      // 如果没有code也没有error，可能是其他问题
      getLogger().w('回调URL中没有找到授权码或错误信息');
      widget.onError('i18n_login_Web认证响应无效'.tr);
      Navigator.of(context).pop();

    } catch (e) {
      getLogger().e('处理回调URL时发生异常: $e');
      widget.onError('i18n_login_Web认证失败请重试'.tr);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
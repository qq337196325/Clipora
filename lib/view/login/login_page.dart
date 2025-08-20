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


import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluwx/fluwx.dart';
import 'dart:async';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../basics/app_config_interface.dart';
import '../../basics/ui.dart';
import '../../components/ui_border_radius_widget.dart';
import '../../basics/translations/select_language_widget.dart';
import '../../basics/translations/language_controller.dart';
import '../../private/api/user_api.dart';
import 'phone_login_page.dart';
import 'email_login_page.dart';
import 'apple_web_auth_widget.dart';
import '../../route/route_name.dart';
import '../../basics/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginPageBLoC {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // 顶部语言选择按钮
                _buildLanguageSelector(),
                
                const Spacer(flex: 2),
                
                // Logo部分
                _buildLogo(),
                
                const SizedBox(height: 48),
                
                // 欢迎文本
                _buildWelcomeText(),
                
                const Spacer(flex: 3),
                
                // 登录按钮组
                _buildLoginButtons(),
                
                const SizedBox(height: 32),
                
                // 用户协议和隐私政策
                _buildPrivacyText(),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'i18n_login_欢迎使用Clipora'.tr,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3C3C3C),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'i18n_login_您的专属剪藏与阅读助手'.tr,
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF5A5A5A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        // 社交登录按钮区域
        _buildSocialLoginSection(),
        
        const SizedBox(height: 32),
        
        // 分割线
        _buildDivider(),
        
        const SizedBox(height: 24),
        
        // 图标登录区域
        _buildIconLoginSection(),
        
        const SizedBox(height: 16),
        
        // 提示文本
        _buildNoticeText(),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        // Apple登录按钮
        _buildLoginButton(
          icon: Icons.apple,
          text: 'i18n_login_使用Apple登录'.tr,
          backgroundColor: const Color(0xFF000000),
          textColor: Colors.white,
          onPressed: onAppleLogin,
        ),
        const SizedBox(height: 16),
        
        // 微信登录按钮
        if (_showWeChatLogin) ...[
          _buildLoginButton(
            icon: Icons.wechat,
            text: 'i18n_login_使用微信登录'.tr,
            backgroundColor: const Color(0xFF07C160),
            textColor: Colors.white,
            onPressed: onWechatLogin,
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '或',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildIconLoginSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 手机号登录图标
        _buildIconLoginButton(
          icon: Icons.phone_android,
          color: const Color(0xFF3B82F6),
          onPressed: onPhoneLogin,
          tooltip: 'i18n_login_使用手机号登录'.tr,
        ),
        
        const SizedBox(width: 32),
        
        // 邮箱登录图标
        _buildIconLoginButton(
          icon: Icons.email_outlined,
          color: const Color(0xFF722ED1),
          onPressed: onEmailLogin,
          tooltip: '使用邮箱登录',
        ),
      ],
    );
  }

  Widget _buildIconLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeText() {
    return Text(
      'i18n_login_没有账号将自动创建账号'.tr,
      style: TextStyle(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // 占位：邮箱登录
  void onEmailLogin() {
    if (!isAgreePrivacyAgreement) {
      openSmartDialog();
      BotToast.showText(
        textStyle: TextStyle(color: UiColour.neutral_11),
        text: 'i18n_login_请阅读并勾选我们的隐私政策与用户协议'.tr,
        contentColor: UiColour.neutral_5,
        align: Alignment(0, 0),
      );
      return;
    }
    prefs.setBool("privacy", true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmailLoginPage(),
      ),
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: textColor,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final languageController = Get.find<LanguageController>();
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            final currentLanguage = languageController.supportedLanguages.firstWhere(
              (lang) => languageController.isCurrentLanguage(lang.languageCode, lang.countryCode),
              orElse: () => languageController.supportedLanguages.first,
            );
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SelectLanguageWidget.show(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              currentLanguage.flag,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentLanguage.languageCode.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C3C3C),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF8C8C8C),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrivacyText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              side: BorderSide(width: 1, color: UiColour.neutral_6),
              value: isAgreePrivacyAgreement,
              activeColor: UiColour.primary,
              onChanged: (value) {
                setState(() {
                  isAgreePrivacyAgreement = value!;
                });
              },
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                isAgreePrivacyAgreement = !isAgreePrivacyAgreement;
              });
            },
            child: Text("i18n_login_我已阅读并同意".tr,
                style: TextStyle(color: UiColour.neutral_6, fontSize: 13)),
          ),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8C8C8C),
                height: 1.4,
              ),
              children: [
                // const TextSpan(text: '我已阅读并同意'),
                // TextSpan(
                //     text: '我已阅读并同意',
                //     recognizer: TapGestureRecognizer()
                //       ..onTap = () {
                //         setState(() {
                //           isAgreePrivacyAgreement = !isAgreePrivacyAgreement;
                //         });
                //       }
                // ),

                TextSpan(
                    text: 'i18n_login_用户协议'.tr,
                    style: TextStyle(
                      color: const Color(0xFF005A9C),
                      fontWeight: FontWeight.w500,
                    ), recognizer: TapGestureRecognizer()
                  ..onTap = () {

                    final config = Get.find<IConfig>();
                    final Uri _url = Uri.parse(config.urlPrivacy);
                    goLaunchUrl(_url);
                  }
                ),
                TextSpan(text: 'i18n_login_和'.tr),
                TextSpan(
                    text: 'i18n_login_隐私政策链接'.tr,
                    style: TextStyle(
                      color: const Color(0xFF005A9C),
                      fontWeight: FontWeight.w500,
                    ), recognizer: TapGestureRecognizer()
                  ..onTap = () {

                    final config = Get.find<IConfig>();
                    final Uri _url = Uri.parse(config.urlAgreement);
                    goLaunchUrl(_url);
                  }
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

mixin LoginPageBLoC on State<LoginPage> {
  
  // Fluwx实例
  final Fluwx _fluwx = Fluwx();
  
  // 微信授权响应流订阅
  StreamSubscription<WeChatAuthResponse>? _authSubscription;
  bool isAgreePrivacyAgreement = false;
  late SharedPreferences prefs;
  bool _showWeChatLogin = !Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    // 初始化登录页面
    // 可以在这里添加一些初始化逻辑，比如检查登录状态等
    
    if (Platform.isIOS) {
      _fluwx.isWeChatInstalled.then((installed) {
        if (mounted) {
          setState(() {
            _showWeChatLogin = installed;
          });
        }
      });

    }
    // 监听微信授权响应
    _listenWeChatAuthResponse();

    prefs = await SharedPreferences.getInstance();
    final privacy = prefs.getBool('privacy');
    if(privacy == null || privacy == false){
      // TODO: 发布华为版注释下面两行

      final config = Get.find<IConfig>();
      if(!config.isHuawei){
        openSmartDialog();
      }
    }
  }

  // Apple登录
  void onAppleLogin() async {
    if (!isAgreePrivacyAgreement) {
      openSmartDialog();
      BotToast.showText(
        textStyle: TextStyle(color: UiColour.neutral_11),
        text: 'i18n_login_请阅读并勾选我们的隐私政策与用户协议'.tr,
        contentColor: UiColour.neutral_5,
        align: Alignment(0, 0),
      );
      return;
    }

    prefs.setBool("privacy", true);
    getLogger().i('用户点击Apple登录按钮');
    
    try {
      // 安卓平台使用自定义Web认证
      if (Platform.isAndroid) {
        getLogger().i('安卓平台：使用应用内Web认证方式进行Apple登录');
        await _showAppleWebAuth();
        return;
      }
      
      // iOS平台使用原生认证
      // 显示登录中的加载状态
      _showLoadingDialog('i18n_login_正在登录中'.tr);
      
      // iOS平台检查Apple登录是否可用
      if (!await SignInWithApple.isAvailable()) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        _showErrorDialog('i18n_login_Apple登录不可用'.tr, 'i18n_login_当前设备不支持Apple登录'.tr);
        return;
      }

      // 发起Apple登录请求 (iOS原生)
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      getLogger().i('Apple登录成功获取凭证');
      getLogger().i('Apple ID: ${credential.userIdentifier}');
      getLogger().i('邮箱: ${credential.email}');
      getLogger().i('姓名: ${credential.givenName} ${credential.familyName}');
      
      // 处理Apple登录
      await _processAppleLogin(credential);
      
    } catch (e) {
      getLogger().e('Apple登录失败: $e');
      
      // 关闭可能存在的加载对话框
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // 处理特定错误
      String errorMessage = 'i18n_login_Apple登录失败'.tr;
      if (e is SignInWithAppleAuthorizationException) {
        switch (e.code) {
          case AuthorizationErrorCode.canceled:
            getLogger().i('用户取消Apple登录');
            return; // 用户取消时不显示错误
          case AuthorizationErrorCode.failed:
            errorMessage = 'i18n_login_Apple授权失败'.tr;
            break;
          case AuthorizationErrorCode.invalidResponse:
            errorMessage = 'i18n_login_Apple服务器响应无效'.tr;
            break;
          case AuthorizationErrorCode.notHandled:
            errorMessage = 'i18n_login_Apple登录请求未被处理'.tr;
            break;
          case AuthorizationErrorCode.unknown:
            errorMessage = 'i18n_login_Apple登录发生未知错误'.tr;
            getLogger().e('Apple登录未知错误详情: ${e.toString()}');
            break;
          case AuthorizationErrorCode.notInteractive:
            errorMessage = 'i18n_login_Apple登录发生未知错误'.tr;
            break;
        }
      }
      
      _showErrorDialog('i18n_login_Apple登录失败'.tr, errorMessage);
    }
  }

  // 显示Apple Web认证窗口
  Future<void> _showAppleWebAuth() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppleWebAuthWidget(
            clientId: 'com.guanshangyun.clipora.service',
            redirectUri: 'https://clipora-api.guanshangyun.com/auth/apple/callback',
            onSuccess: (params) async {
              getLogger().i('Web认证成功，参数: $params');
              await _processAppleWebAuthResult(params);
            },
            onError: (error) {
              getLogger().e('Web认证失败: $error');
              _showErrorDialog('i18n_login_Apple登录失败'.tr, error);
            },
          ),
        ),
      );
    } catch (e) {
      getLogger().e('显示Apple Web认证窗口失败: $e');
      _showErrorDialog('i18n_login_Apple登录失败'.tr, 'i18n_login_Web认证窗口加载失败'.tr);
    }
  }

  // 处理Apple Web认证结果
  Future<void> _processAppleWebAuthResult(Map<String, String> params) async {
    try {
      // 显示登录中的加载状态
      _showLoadingDialog('i18n_login_正在登录中'.tr);
      
      // 准备请求参数
      final loginParams = {
        'code': params['code'],
        'state': params['state'],
        'id_token': params['id_token'],
        'platform': 'android',
        'auth_type': 'web',
      };
      
      // 调用Apple登录API
      final res = await UserApi.appleLoginApi(loginParams);
      
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      getLogger().i('Apple Web认证API响应: $res');
      
      // 检查响应结果
      if (res["code"] != 0) {
        getLogger().e('Apple Web认证失败: ${res["message"]}');
        _showErrorDialog('i18n_login_Apple登录失败'.tr, res['message'] ?? 'i18n_login_登录失败请重试'.tr);
        return;
      }
      
      // 获取token
      final String? token = res['data']?['token'];

      globalBoxStorage.write('user_id', res['data']["id"]);
      globalBoxStorage.write('user_name', res['data']["name"]);
      globalBoxStorage.write('token', res['data']["token"]);

      globalBoxStorage.write('is_not_login', res['data']["is_not_login"]);
      globalBoxStorage.write('member_type', res['data']["member_type"]);
      globalBoxStorage.write('member_expire_time', res['data']["member_expire_time"]);

      if (token == null || token.isEmpty) {
        getLogger().e('Apple Web认证成功但未获取到token');
        _showErrorDialog('i18n_login_登录失败'.tr, 'i18n_login_服务器未返回有效的登录凭证'.tr);
        return;
      }
      
      // 保存token到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      getLogger().i('✅ Apple Web认证登录成功，token已保存');
      
      // 登录成功，跳转到首页
      if (mounted) {
        // 清空导航栈并跳转到首页
        context.go('/${RouteName.index}');
      }
      
    } catch (e) {
      getLogger().e('Apple Web认证处理过程中发生异常: $e');
      
      // 关闭可能存在的加载对话框
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // 显示错误信息
      _showErrorDialog('i18n_login_Apple登录失败'.tr, 'i18n_login_网络连接异常'.tr);
    }
  }

  // 微信登录
  void onWechatLogin() async {
    try {

      if (!isAgreePrivacyAgreement) {
        openSmartDialog();
        BotToast.showText(
          textStyle: TextStyle(color: UiColour.neutral_11),
          text: 'i18n_login_请阅读并勾选我们的隐私政策与用户协议'.tr,
          contentColor: UiColour.neutral_5,
          align: Alignment(0, 0),
        );
        return;
      }

      prefs.setBool("privacy", true);
      getLogger().i('用户点击微信登录按钮');
      
      // 检查微信是否已安装
      bool isInstalled = await _fluwx.isWeChatInstalled;
      if (!isInstalled) {
        getLogger().w('i18n_login_微信未安装'.tr);
        _showErrorDialog('i18n_login_微信未安装'.tr, 'i18n_login_请先安装微信客户端后再试'.tr);
        return;
      }

      getLogger().i('微信已安装，准备发起授权请求');

      // 发起微信授权请求
      await _fluwx.authBy(which: NormalAuth(scope: "snsapi_userinfo", state: "clipora_login"));
      getLogger().i('📱 已发起微信授权请求，等待用户确认...');
      
    } catch (e) {
      getLogger().e('❌ 发起微信授权失败: $e');
      _showErrorDialog('微信登录失败', '发起授权请求失败，请重试');
    }
  }

  // 手机号登录
  void onPhoneLogin() {

    if (!isAgreePrivacyAgreement) {
      openSmartDialog();
      BotToast.showText(
        textStyle: TextStyle(color: UiColour.neutral_11),
        text: "请阅读并勾选我们的隐私政策与用户协议",
        contentColor: UiColour.neutral_5,
        align: Alignment(0, 0),
      );
      return;
    }
    prefs.setBool("privacy", true);

    // 跳转到手机号输入页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhoneLoginPage()),
    );
  }

  /// 监听微信授权响应
  void _listenWeChatAuthResponse() {
    _fluwx.addSubscriber((response) {
      if (response is WeChatAuthResponse) {
        _handleWeChatAuthResponse(response);
      }
    });
  }

  /// 处理微信授权响应
  void _handleWeChatAuthResponse(WeChatAuthResponse response) {
    getLogger().i('🔄 收到微信授权响应: ${response.toString()}');
    getLogger().i('🔍 响应详情 - isSuccessful: ${response.isSuccessful}, code: ${response.code}, state: ${response.state}, errCode: ${response.errCode}, errStr: ${response.errStr}');
    
    if (response.isSuccessful) {
      // 授权成功，获取到code
      final String? code = response.code;
      final String? state = response.state;
      if (code != null && code.isNotEmpty) {
        getLogger().i('📱 获取到code: $code');
        getLogger().i('📱 state参数: $state');
        _processWeChatLogin(code);
      } else {
        getLogger().e('❌ 微信授权成功但未获取到code');
        _showErrorDialog('i18n_login_授权失败'.tr, 'i18n_login_未能获取到有效的授权码'.tr);
      }
    } else {
      // 授权失败
      getLogger().w('❌ 微信授权失败: ${response.errCode} - ${response.errStr}');
      String errorMessage = 'i18n_login_授权失败'.tr;
      
      // 根据错误码显示具体错误信息
      if (response.errCode != null) {
        switch (response.errCode) {
          case -4:
            errorMessage = 'i18n_login_用户拒绝授权'.tr;
            break;
          case -2:
            errorMessage = 'i18n_login_用户取消授权'.tr;
            break;
          case -1:
            errorMessage = 'i18n_login_发送授权请求失败'.tr;
            break;
          case -3:
            errorMessage = 'i18n_login_微信版本不支持'.tr;
            break;
          default:
            errorMessage = 'i18n_login_未知错误'.tr + '(${response.errCode})，' + 'i18n_login_登录失败请重试'.tr;
            break;
        }
        
        // 用户取消时不显示错误提示，只记录日志
        if (response.errCode != -2) {
          _showErrorDialog('i18n_login_微信登录失败'.tr, errorMessage);
        } else {
          getLogger().i('i18n_login_用户取消授权'.tr);
        }
      } else {
        _showErrorDialog('i18n_login_微信登录失败'.tr, errorMessage);
      }
    }
  }


  /// 处理Apple登录
  Future<void> _processAppleLogin(AuthorizationCredentialAppleID credential) async {
    getLogger().i('开始处理Apple登录');
    
    try {
      // 显示登录中的加载状态
      _showLoadingDialog('i18n_login_正在登录中'.tr);
      
      // 准备请求参数
      final params = {
        'user_identifier': credential.userIdentifier,
        'identity_token': credential.identityToken,
        'authorization_code': credential.authorizationCode,
        'email': credential.email,
        'given_name': credential.givenName,
        'family_name': credential.familyName,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };
      
      // 调用Apple登录API
      final res = await UserApi.appleLoginApi(params);
      
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      getLogger().i('Apple登录API响应: $res');
      
      // 检查响应结果
      if (res["code"] != 0) {
        getLogger().e('i18n_login_Apple登录失败'.tr + ': ${res["message"]}');
        _showErrorDialog('i18n_login_Apple登录失败'.tr, res['message'] ?? 'i18n_login_登录失败请重试'.tr);
        return;
      }
      
      // 获取token
      final String? token = res['data']?['token'];

      globalBoxStorage.write('user_id', res['data']["id"]);
      globalBoxStorage.write('user_name', res['data']["name"]);
      globalBoxStorage.write('token', res['data']["token"]);

      globalBoxStorage.write('is_not_login', res['data']["is_not_login"]);
      globalBoxStorage.write('member_type', res['data']["member_type"]);
      globalBoxStorage.write('member_expire_time', res['data']["member_expire_time"]);

      if (token == null || token.isEmpty) {
        getLogger().e('i18n_login_Apple登录成功但未获取到token'.tr);
        _showErrorDialog('i18n_login_登录失败'.tr, 'i18n_login_服务器未返回有效的登录凭证'.tr);
        return;
      }
      
      // 保存token到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      getLogger().i('✅ Apple登录成功，token已保存');
      
      // 登录成功，跳转到首页
      if (mounted) {
        // 清空导航栈并跳转到首页
        context.go('/${RouteName.index}');
      }
      
    } catch (e) {
      getLogger().e('Apple登录过程中发生异常: $e');
      
      // 关闭可能存在的加载对话框
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // 显示错误信息
      _showErrorDialog('i18n_login_Apple登录失败'.tr, 'i18n_login_网络连接异常'.tr);
    }
  }

  /// 处理微信登录
  void _processWeChatLogin(String code) async {
    getLogger().i('开始处理微信登录，code: $code');
    
    try {
      // 显示登录中的加载状态
      _showLoadingDialog('i18n_login_正在登录中'.tr);
      
      // 准备请求参数
      final params = {
        'code': code,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };
      
      // 调用微信登录API
      final res = await UserApi.wechatLoginApi(params);
      
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      getLogger().i('微信登录API响应: $res');
      
      // 检查响应结果
      if (res["code"] != 0) {
        getLogger().e('i18n_login_微信登录失败'.tr + ': ${res["message"]}');
        _showErrorDialog('i18n_login_微信登录失败'.tr, res['message'] ?? 'i18n_login_登录失败请重试'.tr);
        return;
      }
      
      // 获取token
      final String? token = res['data']?['token'];

      globalBoxStorage.write('user_id', res['data']["id"]);
      globalBoxStorage.write('user_name', res['data']["name"]);
      globalBoxStorage.write('token', res['data']["token"]);

      globalBoxStorage.write('is_not_login', res['data']["is_not_login"]);
      globalBoxStorage.write('member_type', res['data']["member_type"]);
      globalBoxStorage.write('member_expire_time', res['data']["member_expire_time"]);

      if (token == null || token.isEmpty) {
        getLogger().e('i18n_login_微信登录成功但未获取到token'.tr);
        _showErrorDialog('i18n_login_登录失败'.tr, 'i18n_login_服务器未返回有效的登录凭证'.tr);
        return;
      }
      
      // 保存token到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      getLogger().i('✅ 微信登录成功，token已保存');
      
      // 登录成功，跳转到首页
      if (mounted) {
        // 清空导航栈并跳转到首页
        context.go('/${RouteName.index}');
        
        // 可选：显示欢迎消息
        // _showSuccessDialog('登录成功', '欢迎使用 Clipora！');
      }
      
    } catch (e) {
      getLogger().e('微信登录过程中发生异常: $e');
      
      // 关闭可能存在的加载对话框
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // 显示错误信息
      _showErrorDialog('i18n_login_微信登录失败'.tr, 'i18n_login_网络连接异常'.tr);
    }
  }

  /// 显示错误对话框
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFEFDF8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A5A5A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'i18n_login_知道了'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示加载对话框
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // 防止用户点击外部关闭
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFEFDF8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005A9C)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3C3C3C),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    // 清理微信授权响应订阅
    _authSubscription?.cancel();
    super.dispose();
  }


  openSmartDialog(){
    SmartDialog.show(
      builder: (fcontext) => UiBorderRadiusWidget(
        width: 300,
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('i18n_login_隐私政策'.tr, style: TextStyle(fontWeight: FontWeight.w600, color: UiColour.neutral_3, fontSize: 16)),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: 'i18n_login_隐私政策内容'.tr, style: TextStyle(color: UiColour.neutral_3)),
                    TextSpan(text: 'i18n_login_隐私政策链接'.tr, style: TextStyle(color: UiColour.primary),recognizer: TapGestureRecognizer()
                      ..onTap = () {

                        final config = Get.find<IConfig>();
                        final Uri _url = Uri.parse(config.urlAgreement);
                        goLaunchUrl(_url);
                      }),
                  ],
                ),
              ),
              Container(
                width: 400,
                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(40))),
                padding: const EdgeInsets.only(top: 28.0, left: 20, right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: UiColour.primary,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(40))),
                    // padding: const EdgeInsets.all(8.0),
                    child: Text('i18n_login_同意'.tr, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  onPressed: () async {
                    setState(() {
                      isAgreePrivacyAgreement = true;
                    });
                    // ClientLog.instance.getDeviceInfo();
                    SmartDialog.dismiss();
                  },
                ),
              ),
              Container(
                width: 400,
                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(40))),
                padding: const EdgeInsets.only(top: 28.0, left: 20, right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: UiColour.funFF6600,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(40))),
                    // padding: const EdgeInsets.all(8.0),
                    child: Text('i18n_login_不同意并退出APP'.tr, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  onPressed: () async {
                    SystemNavigator.pop();
                  },
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
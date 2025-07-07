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
import '../../basics/config.dart';
import '../../basics/ui.dart';
import '../../components/ui_border_radius_widget.dart';
import 'phone_login_page.dart';
import '../../api/user_api.dart';
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
          '欢迎使用 Clipora',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3C3C3C),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '您的专属剪藏与阅读助手',
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
        // Apple登录按钮
        // _buildLoginButton(
        //   icon: Icons.apple,
        //   text: '使用 Apple 登录',
        //   backgroundColor: const Color(0xFF000000),
        //   textColor: Colors.white,
        //   onPressed: onAppleLogin,
        // ),
        //
        // const SizedBox(height: 16),
        
        // 微信登录按钮
        _buildLoginButton(
          icon: Icons.wechat,
          text: '使用微信登录',
          backgroundColor: const Color(0xFF07C160),
          textColor: Colors.white,
          onPressed: onWechatLogin,
        ),
        
        const SizedBox(height: 16),
        
        // 手机号登录按钮
        _buildLoginButton(
          icon: Icons.phone_android,
          text: '使用手机号登录',
          backgroundColor: const Color(0xFF005A9C),
          textColor: Colors.white,
          onPressed: onPhoneLogin,
        ),
      ],
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
            child: Text("我已阅读并同意",
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
                    text: '《用户协议》',
                    style: TextStyle(
                      color: const Color(0xFF005A9C),
                      fontWeight: FontWeight.w500,
                    ), recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final Uri _url = Uri.parse(urlPrivacy);
                    goLaunchUrl(_url);
                  }
                ),
                const TextSpan(text: '和'),
                TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(
                      color: const Color(0xFF005A9C),
                      fontWeight: FontWeight.w500,
                    ), recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final Uri _url = Uri.parse(urlAgreement);
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
  
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    // 初始化登录页面
    // 可以在这里添加一些初始化逻辑，比如检查登录状态等
    
    // 监听微信授权响应
    _listenWeChatAuthResponse();

    prefs = await SharedPreferences.getInstance();
    final privacy = prefs.getBool('privacy');
    if(privacy == null || privacy == false){
      // TODO: 发布华为版注释下面两行
      openSmartDialog();
    }
  }

  // Apple登录
  void onAppleLogin() {
    // TODO: 实现Apple登录逻辑
    print('Apple登录');
    _showComingSoonDialog('Apple登录');
  }

  // 微信登录
  void onWechatLogin() async {
    try {

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
      getLogger().i('用户点击微信登录按钮');
      
      // 检查微信是否已安装
      bool isInstalled = await _fluwx.isWeChatInstalled;
      if (!isInstalled) {
        getLogger().w('微信未安装');
        _showErrorDialog('微信未安装', '请先安装微信客户端后再试');
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
    // _fluwx.addSubscriber((response) {
    //   if (mounted) {
    //     _handleWeChatAuthResponse(response);
    //   }
    // });
    _fluwx.addSubscriber((response) {
      if (response is WeChatAuthResponse) {
        _handleWeChatAuthResponse(response);
        // setState(() {
        //   _result = 'state :${response.state} \n code:${response.code}';
        // });
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
        _showErrorDialog('授权失败', '未能获取到有效的授权码，请重试');
      }
    } else {
      // 授权失败
      getLogger().w('❌ 微信授权失败: ${response.errCode} - ${response.errStr}');
      String errorMessage = '授权失败';
      
      // 根据错误码显示具体错误信息
      if (response.errCode != null) {
        switch (response.errCode) {
          case -4:
            errorMessage = '用户拒绝授权';
            break;
          case -2:
            errorMessage = '用户取消授权';
            break;
          case -1:
            errorMessage = '发送授权请求失败';
            break;
          case -3:
            errorMessage = '微信版本不支持';
            break;
          default:
            errorMessage = '未知错误(${response.errCode})，请重试';
            break;
        }
        
        // 用户取消时不显示错误提示，只记录日志
        if (response.errCode != -2) {
          _showErrorDialog('微信登录失败', errorMessage);
        } else {
          getLogger().i('用户取消了微信授权');
        }
      } else {
        _showErrorDialog('微信登录失败', errorMessage);
      }
    }
  }

  /// 处理微信登录
  void _processWeChatLogin(String code) async {
    getLogger().i('开始处理微信登录，code: $code');
    
    try {
      // 显示登录中的加载状态
      _showLoadingDialog('正在登录中...');
      
      // 准备请求参数
      final params = {
        'code': code,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };
      
      getLogger().i('🚀 调用微信登录API');
      getLogger().i('📤 请求参数: $params');
      getLogger().i('🔑 客户端使用的AppID: wx629011ac595bee08');
      getLogger().i('⏰ 当前时间: ${DateTime.now().toIso8601String()}');
      
      // 调用微信登录API
      final res = await UserApi.wechatLoginApi(params);
      
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      getLogger().i('微信登录API响应: $res');
      
      // 检查响应结果
      if (res["code"] != 0) {
        getLogger().e('微信登录失败: ${res["message"]}');
        _showErrorDialog('微信登录失败', res['message'] ?? '登录失败，请重试');
        return;
      }
      
      // 获取token
      final String? token = res['data']?['token'];
      if (token == null || token.isEmpty) {
        getLogger().e('微信登录成功但未获取到token');
        _showErrorDialog('登录失败', '服务器未返回有效的登录凭证');
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
      _showErrorDialog('微信登录失败', '网络连接异常，请检查网络后重试');
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
                    child: const Text(
                      '知道了',
                      style: TextStyle(
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


  // 显示即将推出的对话框
  void _showComingSoonDialog(String loginType) {
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
                    color: const Color(0xFF005A9C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF005A9C),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$loginType功能',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '该功能正在开发中，敬请期待！',
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
                      backgroundColor: const Color(0xFF005A9C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '知道了',
                      style: TextStyle(
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
              Text("隐私政策", style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: '本应用尊重并保护所有用户的个人隐私权。为了给您提供更准确、更有个性化的服务，本应用会按照隐私政策的规定使用和披露您的个人信息。可阅读我们的'),
                    TextSpan(text: '隐私政策', style: TextStyle(color: UiColour.primary),recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        final Uri _url = Uri.parse(urlAgreement);
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
                    padding: const EdgeInsets.all(8.0),
                    child: const Text("同意", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
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
                    padding: const EdgeInsets.all(8.0),
                    child: const Text("不同意并退出APP", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
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

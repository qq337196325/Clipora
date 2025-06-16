import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'phone_login_page.dart';

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
        _buildLoginButton(
          icon: Icons.apple,
          text: '使用 Apple 登录',
          backgroundColor: const Color(0xFF000000),
          textColor: Colors.white,
          onPressed: onAppleLogin,
        ),
        
        const SizedBox(height: 16),
        
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8C8C8C),
            height: 1.4,
          ),
          children: [
            const TextSpan(text: '登录即表示您同意我们的'),
            TextSpan(
              text: '《用户协议》',
              style: TextStyle(
                color: const Color(0xFF005A9C),
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: '和'),
            TextSpan(
              text: '《隐私政策》',
              style: TextStyle(
                color: const Color(0xFF005A9C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

mixin LoginPageBLoC on State<LoginPage> {
  
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    // 初始化登录页面
    // 可以在这里添加一些初始化逻辑，比如检查登录状态等
  }

  // Apple登录
  void onAppleLogin() {
    // TODO: 实现Apple登录逻辑
    print('Apple登录');
    _showComingSoonDialog('Apple登录');
  }

  // 微信登录
  void onWechatLogin() {
    // TODO: 实现微信登录逻辑
    print('微信登录');
    _showComingSoonDialog('微信登录');
  }

  // 手机号登录
  void onPhoneLogin() {
    // 跳转到手机号输入页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhoneLoginPage()),
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
    super.dispose();
  }
}

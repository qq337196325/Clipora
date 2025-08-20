// Copyright (c) 2025 Clipora.
// See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../private/api/user_api.dart';
import 'email_verify_page.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> with EmailLoginPageBLoC {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF3C3C3C),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'i18n_login_邮箱登录'.tr,
          style: const TextStyle(
            color: Color(0xFF3C3C3C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // 标题
              Text(
                'i18n_login_输入邮箱'.tr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'i18n_login_我们将向您的邮箱发送验证码'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A5A5A),
                ),
              ),
              const SizedBox(height: 48),
              _buildEmailInputField(),
              const SizedBox(height: 32),
              _buildSendCodeButton(),
              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emailError.isNotEmpty
              ? const Color(0xFFB00020)
              : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          LengthLimitingTextInputFormatter(100),
        ],
        onChanged: onEmailChanged,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF3C3C3C),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'i18n_login_请输入邮箱'.tr,
          hintStyle: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF3C3C3C)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          errorText: emailError.isNotEmpty ? emailError : null,
          errorStyle: const TextStyle(
            color: Color(0xFFB00020),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSendCodeButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEmailValid
            ? [
                BoxShadow(
                  color: const Color(0xFF005A9C).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: isEmailValid ? const Color(0xFF005A9C) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isEmailValid && !isLoading ? onSendCode : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'i18n_login_发送验证码'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEmailValid ? Colors.white : const Color(0xFF8C8C8C),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

mixin EmailLoginPageBLoC on State<EmailLoginPage> {
  late TextEditingController emailController;
  String emailError = '';
  bool isEmailValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  void onEmailChanged(String value) {
    setState(() {
      emailError = '';
      isEmailValid = _validateEmail(value);
    });
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    return emailRegex.hasMatch(email);
  }

  void onSendCode() async {
    if (!isEmailValid) return;

    final email = emailController.text.trim();

    if (!_validateEmail(email)) {
      setState(() {
        emailError = 'i18n_login_请输入正确的邮箱地址'.tr;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final params = {
        'mail': email, 
        'mailtype': 'login',
      };

      final res = await UserApi.mailCodeApi(params);

      if (res['code'] == 0) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerifyPage(email: email),
            ),
          );
        }
      } else {
        setState(() {
          emailError = res['message'] ?? 'i18n_login_发送失败请稍后重试'.tr;
        });
      }
    } catch (e) {
      setState(() {
        emailError = 'i18n_login_发送验证码失败请检查网络'.tr;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
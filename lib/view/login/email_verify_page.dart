// Copyright (c) 2025 Clipora.
// See LICENSE for details.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../private/api/user_api.dart';
import '../../route/route_name.dart';

class EmailVerifyPage extends StatefulWidget {
  final String email;

  const EmailVerifyPage({super.key, required this.email});

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> with EmailVerifyPageBLoC {
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
          'i18n_login_验证邮箱'.tr,
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
              Text(
                'i18n_login_输入验证码'.tr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'i18n_login_我们已向您的邮箱发送验证码'.tr + ' ${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A5A5A),
                ),
              ),
              const SizedBox(height: 48),
              _buildCodeInputField(),
              const SizedBox(height: 24),
              _buildResendButton(),
              const SizedBox(height: 32),
              _buildVerifyButton(),
              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: codeError.isNotEmpty ? const Color(0xFFB00020) : const Color(0xFFE0E0E0),
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
        controller: codeController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        onChanged: onCodeChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFF3C3C3C),
          fontWeight: FontWeight.w600,
          letterSpacing: 8,
        ),
        decoration: InputDecoration(
          hintText: 'i18n_login_验证码'.tr,
          hintStyle: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 16,
            letterSpacing: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          errorText: codeError.isNotEmpty ? codeError : null,
          errorStyle: const TextStyle(
            color: Color(0xFFB00020),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'i18n_login_没有收到验证码'.tr,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5A5A5A),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: canResend ? onResendCode : null,
          child: Text(
            canResend ? 'i18n_login_重新发送'.tr : 'i18n_login_重新发送'.tr + '(${countDown}s)',
            style: TextStyle(
              fontSize: 14,
              color: canResend ? const Color(0xFF005A9C) : const Color(0xFF8C8C8C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isCodeValid
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
        color: isCodeValid ? const Color(0xFF005A9C) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isCodeValid && !isVerifying ? onVerifyCode : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isVerifying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'i18n_login_验证并登录'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCodeValid ? Colors.white : const Color(0xFF8C8C8C),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

mixin EmailVerifyPageBLoC on State<EmailVerifyPage> {
  late TextEditingController codeController;
  String codeError = '';
  bool isCodeValid = false;
  bool isVerifying = false;

  int countDown = 60;
  bool canResend = false;
  Timer? _timer;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
    _startCountDown();
  }

  void _startCountDown() {
    canResend = false;
    countDown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (countDown > 0) {
          countDown--;
        }
        if (countDown == 0) {
          canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void onCodeChanged(String value) {
    setState(() {
      codeError = '';
      isCodeValid = value.trim().length == 4;
    });
  }

  void onResendCode() async {
    if (!canResend) return;

    try {
      final params = {
        'email': widget.email,
        'mailtype': 'login',
      };
      final res = await UserApi.mailCodeApi(params);
      if (res['code'] == 0) {
        _startCountDown();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('i18n_login_验证码已重新发送'.tr),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        setState(() {
          codeError = res['message'] ?? 'i18n_login_重新发送失败'.tr;
        });
      }
    } catch (e) {
      setState(() {
        codeError = 'i18n_login_重新发送失败请检查网络'.tr;
      });
    }
  }

  void onVerifyCode() async {
    if (!isCodeValid) return;

    final code = codeController.text.trim();

    setState(() {
      isVerifying = true;
      codeError = '';
    });

    try {
      final params = {
        'account': widget.email,
        'code': code,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'login_type': 2, // 邮箱登录
      };

      final res = await UserApi.accountLoginApi(params);
      if (res['code'] != 0) {
        setState(() {
          codeError = res['message'] ?? 'i18n_login_验证失败请重试'.tr;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', res['data']["token"]);
      box.write('user_id', res['data']["id"]);
      box.write('user_name', res['data']["name"]);
      box.write('token', res['data']["token"]);

      box.write('is_not_login', res['data']["is_not_login"]);
      box.write('member_type', res['data']["member_type"]);
      box.write('member_expire_time', res['data']["member_expire_time"]);

      if (mounted) {
        context.go('/${RouteName.index}');
      }
    } catch (e) {
      setState(() {
        codeError = 'i18n_login_登录失败请检查网络'.tr;
      });
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
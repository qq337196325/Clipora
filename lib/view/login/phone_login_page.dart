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


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../private/api/user_api.dart';
import 'phone_verify_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> with PhoneLoginPageBLoC {
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
          'i18n_login_手机号登录'.tr,
          style: TextStyle(
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
                'i18n_login_输入手机号'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'i18n_login_我们将向您的手机发送验证码'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A5A5A),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 手机号输入框
              _buildPhoneInputField(),
              
              const SizedBox(height: 32),
              
              // 发送验证码按钮
              _buildSendCodeButton(),
              
              const Spacer(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: phoneError.isNotEmpty 
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
        controller: phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        onChanged: onPhoneChanged,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF3C3C3C),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'i18n_login_请输入手机号'.tr,
          hintStyle: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '+86',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF3C3C3C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          errorText: phoneError.isNotEmpty ? phoneError : null,
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
        boxShadow: isPhoneValid
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
        color: isPhoneValid 
            ? const Color(0xFF005A9C) 
            : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isPhoneValid && !isLoading ? onSendCode : null,
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
                      color: isPhoneValid ? Colors.white : const Color(0xFF8C8C8C),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

mixin PhoneLoginPageBLoC on State<PhoneLoginPage> {
  late TextEditingController phoneController;
  String phoneError = '';
  bool isPhoneValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
  }

  void onPhoneChanged(String value) {
    setState(() {
      phoneError = '';
      isPhoneValid = _validatePhone(value);
    });
  }

  bool _validatePhone(String phone) {
    // 简单的手机号验证（以1开头的11位数字）
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  void onSendCode() async {
    if (!isPhoneValid) return;

    final phone = phoneController.text.trim();
    
    // 再次验证手机号
    if (!_validatePhone(phone)) {
      setState(() {
        phoneError = 'i18n_login_请输入正确的手机号'.tr;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final params = {
        'phone': phone,
        'smstype': 'login',
      };
      
      final res = await UserApi.smsCodeApi(params);
      
      if (res['code'] == 0) {
        // 跳转到验证码页面
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneVerifyPage(phone: phone),
            ),
          );
        }
      } else {
        setState(() {
          phoneError = res['message'] ?? 'i18n_login_发送失败请稍后重试'.tr;
        });
      }
    } catch (e) {
      setState(() {
        phoneError = 'i18n_login_发送验证码失败请检查网络'.tr;
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
    phoneController.dispose();
    super.dispose();
  }
}
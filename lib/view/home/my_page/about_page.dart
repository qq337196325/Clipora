import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../basics/config.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: Text(
          'i18n_my_关于我们页面标题'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1D1D1F),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 应用Logo和基本信息
            _buildAppInfo(),
            
            const SizedBox(height: 40),
            
            // 版本信息
            _buildVersionInfo(),
            
            const SizedBox(height: 30),
            
            // 应用介绍
            _buildAppDescription(),
            
            const SizedBox(height: 30),
            
            // 联系我们
            _buildContactInfo(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Name
          const Text(
            'Clipora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // App Tagline
          Text(
            'i18n_my_智能剪藏与笔记管理'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'i18n_my_版本信息'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow('i18n_my_版本号'.tr, version),
          const SizedBox(height: 12),
          _buildInfoRow('i18n_my_构建号'.tr, clientVersion.toString()),
          const SizedBox(height: 12),
          _buildInfoRow('i18n_my_备案号'.tr, "粤ICP备2021048632号-5A"),
          // const SizedBox(height: 12),
          // _buildInfoRow('发布日期', '2024年3月'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E93),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1D1F),
          ),
        ),
      ],
    );
  }

  Widget _buildAppDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF45B7D1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: Color(0xFF45B7D1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'i18n_my_应用介绍'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'i18n_my_应用介绍内容'.tr,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF3C3C3C),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'i18n_my_主要功能'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildFeatureItem('i18n_my_网页内容快速剪藏'.tr),
          _buildFeatureItem('i18n_my_智能笔记分类管理'.tr),
          _buildFeatureItem('i18n_my_全文搜索与标签系统'.tr),
          _buildFeatureItem('i18n_my_跨平台同步与分享'.tr),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF45B7D1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            feature,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3C3C3C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_mail_outlined,
                  size: 16,
                  color: Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'i18n_my_联系我们'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'i18n_my_邮箱'.tr,
            content: '337196325@qq.com',
            onTap: () => _copyToClipboard('337196325@qq.com', 'i18n_my_邮箱地址已复制到剪贴板'.tr),
          ),
          
          const SizedBox(height: 12),
          
          _buildContactItem(
            icon: Icons.web_outlined,
            title: 'i18n_my_官网'.tr,
            content: 'clipora.guanshangyun.com',
            onTap: () => _copyToClipboard('clipora.guanshangyun.com', 'i18n_my_官网地址已复制到剪贴板'.tr),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'i18n_my_感谢您使用Clipora'.tr,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E93),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF8E8E93),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.copy,
                size: 16,
                color: Color(0xFF8E8E93),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 
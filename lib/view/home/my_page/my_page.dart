import 'package:clipora/basics/ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../route/route_name.dart';
import '../../../basics/logger.dart';
import 'about_page.dart';
import 'rating_dialog.dart';
import 'app_store_test_page.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageModalState();
} 

class _MyPageModalState extends State<MyPage> with MyPageBLoC {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFAFBFC),
            Color(0xFFF5F7FA),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // 优化的顶部区域
          _buildHeader(),
          
          // 可滚动内容区域
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  
                  // 隐私与安全
                  _buildSectionHeader('信息', Icons.security),
                  const SizedBox(height: 12),
                  _buildPrivacySection(),
                  
                  const SizedBox(height: 24),
                  
                  // 应用功能
                  _buildSectionHeader('应用功能', Icons.apps),
                  const SizedBox(height: 12),
                  _buildFunctionSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 退出登录按钮
                  _buildLogoutButton(),
                  
                  const SizedBox(height: 24),
                  
                  // 注销账号
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '注销账号',
                      style: TextStyle(
                        fontSize: 15,
                        color: UiColour.neutral_6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 优化的头部设计
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部横杠
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // 标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '设置',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 现代化的章节标题
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF667eea),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3C3C3C),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernSettingItem(
            icon: Icons.policy_outlined,
            title: '用户协议',
            subtitle: '了解我们的用户协议',
            iconColor: const Color(0xFFFF6B6B),
            iconBgColor: const Color(0xFFFF6B6B).withOpacity(0.1),
            onTap: () => _handleThirdPartyInfo(),
            isFirst: true,
            isExternalLink: true,
          ),
          _buildDivider(),
          _buildModernSettingItem(
            icon: Icons.verified_user_outlined,
            title: '隐私协议',
            subtitle: '保护您的隐私权益',
            iconColor: const Color(0xFF4ECDC4),
            iconBgColor: const Color(0xFF4ECDC4).withOpacity(0.1),
            onTap: () => _handlePrivacyPolicy(),
            isLast: true,
            isExternalLink: true,
          ),
          _buildDivider(),
          _buildModernSettingItem(
            icon: Icons.info_outline,
            title: '关于我们',
            subtitle: '了解更多应用信息',
            iconColor: const Color(0xFF9B59B6),
            iconBgColor: const Color(0xFF9B59B6).withOpacity(0.1),
            onTap: () => _handleAboutUs(),
            isExternalLink: false,
          ),
          _buildDivider(),
          _buildModernSettingItem(
            icon: Icons.bug_report,
            title: '应用商店测试',
            subtitle: '测试应用商店跳转功能',
            iconColor: const Color(0xFFFF9500),
            iconBgColor: const Color(0xFFFF9500).withOpacity(0.1),
            onTap: () => _handleAppStoreTest(),
            isLast: true,
            isExternalLink: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [

          _buildModernSettingItem(
            icon: Icons.help_center_outlined,
            title: '使用帮助',
            subtitle: '常见问题与解答',
            iconColor: const Color(0xFF45B7D1),
            iconBgColor: const Color(0xFF45B7D1).withOpacity(0.1),
            onTap: () => _handleHelp(),
          ),
          _buildDivider(),

          _buildModernSettingItem(
            icon: Icons.star_rate_outlined,
            title: '评价一下',
            subtitle: '您的评价是我们前进的动力',
            iconColor: const Color(0xFFFFD93D),
            iconBgColor: const Color(0xFFFFD93D).withOpacity(0.1),
            onTap: () => _handleRating(),
          ),

        ],
      ),
    );
  }

  Widget _buildModernSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    bool isExternalLink = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(14) : Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  isExternalLink ? Icons.open_in_new : Icons.chevron_right,
                  size: 14,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 68),
      height: 1,
      color: const Color(0xFFF2F2F7),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _handleLogout();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  '退出登录',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

// BLoC Mixin for business logic
mixin MyPageBLoC on State<MyPage> {
  String cacheSize = '0.0MB';

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  void _loadCacheSize() async {
    // TODO: 实际计算缓存大小
    setState(() {
      cacheSize = '0.0MB';
    });
  }

  void _handleThirdPartyInfo() {
    getLogger().i('第三方信息共享清单');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('跳转到第三方信息共享清单页面')),
    );
  }

  void _handlePrivacyPolicy() {
    getLogger().i('隐私公约');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('跳转到隐私公约页面')),
    );
  }

  void _handleClearCache() async {
    getLogger().i('清除缓存');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这将删除已下载的文章及笔记数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      // TODO: 执行清除缓存操作
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存已清除')),
      );
      _loadCacheSize();
    }
  }

  void _handleHelp() {
    getLogger().i('使用帮助');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('跳转到使用帮助页面')),
    );
  }

  void _handleCommunity() {
    getLogger().i('用户社区');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('跳转到用户社区页面')),
    );
  }

  void _handleRating() async {
    getLogger().i('评价一下');
    
    // 显示评价对话框
    await RatingDialog.show(context);
  }

  void _handleAbout() {
    getLogger().i('关于新枝');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('跳转到关于页面')),
    );
  }

  void _handleAboutUs() {
    getLogger().i('关于我们');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  void _handleAppStoreTest() {
    getLogger().i('应用商店测试');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppStoreTestPage(),
      ),
    );
  }

  void _handleLogout() async {
    getLogger().i('退出登录');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '退出',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 先关闭弹窗，然后跳转到登录页
      Navigator.of(context).pop(); // 关闭设置弹窗
      context.go('/${RouteName.login}');
    }
  }

  void _handleDeleteAccount() async {
    getLogger().i('注销账号');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('注销账号'),
        content: const Text('确定要注销当前账号吗？这将删除所有数据并无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '注销',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      // TODO: 执行注销账号操作
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        context.go('/login');
      }
    }
  }
} 
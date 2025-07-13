import 'package:clipora/basics/ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../api/user_api.dart';
import '../../../basics/config.dart';
import '../../../basics/translations/select_language_widget.dart';
import '../../../basics/translations/language_controller.dart';
import '../../../basics/theme/app_theme.dart';
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

                  // 应用功能
                  _buildSectionHeader('i18n_my_应用功能'.tr, Icons.apps),
                  const SizedBox(height: 12),
                  _buildFunctionSection(),
                  const SizedBox(height: 12),
                  // 隐私与安全
                  _buildSectionHeader('i18n_my_信息'.tr, Icons.security), 
                  const SizedBox(height: 12),
                  _buildPrivacySection(),

                  const SizedBox(height: 54),
                  
                  // 退出登录按钮
                  _buildLogoutButton(),
                  
                  const SizedBox(height: 24),
                  
                  // 注销账号
                  InkWell(
                    onTap: ()=>_handleDeleteAccount(),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'i18n_my_注销账号'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: UiColour.neutral_6,
                          letterSpacing: 0.3,
                        ),
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
              Text(
                'i18n_my_设置'.tr,
                style: const TextStyle(
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
            title: 'i18n_my_用户协议'.tr,
            subtitle: 'i18n_my_了解我们的用户协议'.tr,
            iconColor: const Color(0xFFFF6B6B),
            iconBgColor: const Color(0xFFFF6B6B).withOpacity(0.1),
            onTap: () => _handleThirdPartyInfo(),
            isFirst: true,
            isExternalLink: true,
          ),
          _buildDivider(),
          _buildModernSettingItem(
            icon: Icons.verified_user_outlined,
            title: 'i18n_my_隐私协议'.tr,
            subtitle: 'i18n_my_保护您的隐私权益'.tr,
            iconColor: const Color(0xFF4ECDC4),
            iconBgColor: const Color(0xFF4ECDC4).withOpacity(0.1),
            onTap: () => _handlePrivacyPolicy(),
            isLast: true,
            isExternalLink: true,
          ),
          _buildDivider(),
          _buildModernSettingItem(
            icon: Icons.info_outline,
            title: 'i18n_my_关于我们'.tr,
            subtitle: 'i18n_my_了解更多应用信息'.tr,
            iconColor: const Color(0xFF9B59B6),
            iconBgColor: const Color(0xFF9B59B6).withOpacity(0.1),
            onTap: () => _handleAboutUs(),
            isExternalLink: false,
          ),
          // _buildDivider(),
          // _buildModernSettingItem(
          //   icon: Icons.bug_report,
          //   title: '应用商店测试',
          //   subtitle: '测试应用商店跳转功能',
          //   iconColor: const Color(0xFFFF9500),
          //   iconBgColor: const Color(0xFFFF9500).withOpacity(0.1),
          //   onTap: () => _handleAppStoreTest(),
          //   isLast: true,
          //   isExternalLink: false,
          // ),
        ],
      ),
    );
  }

  Widget _buildFunctionSection() {
    return Column(
      children: [
        _buildAiTranslationCard(),
        const SizedBox(height: 12),
        Container(
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
              _buildLanguageSetting(),
              _buildDivider(),
              _buildThemeSetting(),
              // _buildModernSettingItem(
              //   icon: Icons.help_center_outlined,
              //   title: '使用帮助',
              //   subtitle: '常见问题与解答',
              //   iconColor: const Color(0xFF45B7D1),
              //   iconBgColor: const Color(0xFF45B7D1).withOpacity(0.1),
              //   onTap: () => _handleHelp(),
              //   isFirst: true,
              // ),
              // _buildDivider(),
              // _buildModernSettingItem(
              //   icon: Icons.star_rate_outlined,
              //   title: '评价一下',
              //   subtitle: '您的评价是我们前进的动力',
              //   iconColor: const Color(0xFFFFD93D),
              //   iconBgColor: const Color(0xFFFFD93D).withOpacity(0.1),
              //   onTap: () => _handleRating(),
              //   isLast: true,
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSetting() {
    final languageController = Get.find<LanguageController>();
    return Obx(() {
      final currentLanguage = languageController.supportedLanguages.firstWhere(
        (lang) => languageController.isCurrentLanguage(
            lang.languageCode, lang.countryCode),
        orElse: () => languageController.supportedLanguages.first,
      );
      return _buildModernSettingItem(
        icon: Icons.language_outlined,
        title: 'i18n_my_语言设置'.tr,
        subtitle: 'i18n_my_当前语言'.trParams({'language': currentLanguage.languageName}),
        iconColor: const Color(0xFF34C759),
        iconBgColor: const Color(0xFF34C759).withOpacity(0.1),
        onTap: () => SelectLanguageWidget.show(context),
        isFirst: true,
        isLast: false,
      );
    });
  }

  Widget _buildThemeSetting() {
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      final currentTheme = themeController.supportedThemes.firstWhere(
        (theme) => theme.type == themeController.currentTheme.value,
        orElse: () => themeController.supportedThemes.first,
      );
      return _buildModernSettingItem(
        icon: Icons.palette_outlined,
        title: 'i18n_theme_主题设置'.tr,
        subtitle: 'i18n_theme_当前主题'.trParams({'theme': currentTheme.name.tr}),
        iconColor: const Color(0xFF667eea),
        iconBgColor: const Color(0xFF667eea).withOpacity(0.1),
        onTap: () => ThemeSelectorWidget.show(context),
        isFirst: false,
        isLast: true,
      );
    });
  }

  Widget _buildAiTranslationCard() {
    return GestureDetector(
      onTap: () {
        if (!_isLoadingQuantity && _remainingTranslateQuantity == null) {
          setState(() {
            _isLoadingQuantity = true;
          });
          _loadTranslateQuantity();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: _isLoadingQuantity
            ? _buildAiCardLoading()
            : (_remainingTranslateQuantity == null
                ? _buildAiCardError()
                : _buildAiCardData()),
      ),
    );
  }

  Widget _buildAiCardLoading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF667eea))),
        const SizedBox(width: 12),
        Text('i18n_my_正在获取AI翻译余量'.tr, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
      ],
    );
  }

  Widget _buildAiCardError() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 20),
        const SizedBox(width: 8),
        Text('i18n_my_加载失败请点击重试'.tr,
            style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAiCardData() {
    double progress = 0;
    if (_totalTranslateQuantity != null && _totalTranslateQuantity! > 0) {
      progress = (_totalTranslateQuantity! - _remainingTranslateQuantity!) /
          _totalTranslateQuantity!;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'i18n_my_AI翻译请求'.tr,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'i18n_my_让阅读更智能翻译更流畅'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                context.push('/${RouteName.aiOrderPage}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text('i18n_my_购买'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF0F2F5),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'i18n_my_已用'.trParams({'used': '${_totalTranslateQuantity! - _remainingTranslateQuantity!}'}),
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
            ),
            Text(
              'i18n_my_剩余'.trParams({
                'remaining': '$_remainingTranslateQuantity',
                'total': '$_totalTranslateQuantity'
              }),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C3C3C),
              ),
            ),
          ],
        )
      ],
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
          // Navigator.pop(context);
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
            // 先关闭弹窗
            Navigator.of(context).pop();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'i18n_my_退出登录'.tr,
                  style: const TextStyle(
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
  int? _remainingTranslateQuantity;
  int? _totalTranslateQuantity;
  bool _isLoadingQuantity = true;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
    _loadTranslateQuantity();
  }

  void _loadCacheSize() async {
    // TODO: 实际计算缓存大小
    setState(() {
      cacheSize = '0.0MB';
    });
  }

  void _loadTranslateQuantity() async {
    try {
      final res = await UserApi.getTranslateRequestQuantityApi({});
      if (!mounted) return;

      if (res['code'] == 0 && res['data'] != null) {
        setState(() {
          _totalTranslateQuantity = res['data']['total_translate_quantity'];
          _remainingTranslateQuantity =
              res['data']['remaining_translate_quantity'];
          _isLoadingQuantity = false;
        });
      } else {
        setState(() {
          _isLoadingQuantity = false;
        });
        getLogger().w('Failed to load translate quantity: ${res["msg"]}');
      }
    } catch (e) {
      getLogger().e('Failed to load translate quantity: $e');
      if (mounted) {
        setState(() {
          _isLoadingQuantity = false;
        });
      }
    }
  }

  void _handleAiTranslation() {
    if (_isLoadingQuantity) return; 

    if (_remainingTranslateQuantity == null) {
      setState(() {
        _isLoadingQuantity = true;
      });
      _loadTranslateQuantity();
    } else {
      context.push('/${RouteName.aiOrderPage}');
    }
  }

  void _handleThirdPartyInfo() { // 用户协议
    getLogger().i('第三方信息共享清单');
    final Uri _url = Uri.parse(urlPrivacy);
    goLaunchUrl(_url);
  }

  void _handlePrivacyPolicy() {
    getLogger().i('隐私公约');
    final Uri _url = Uri.parse(urlAgreement);
    goLaunchUrl(_url);
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
        title: Text('i18n_my_退出登录'.tr),
        content: Text('i18n_my_确定要退出当前账号吗'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('i18n_my_取消'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'i18n_my_退出'.tr,
              style: const TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 先关闭弹窗，然后跳转到登录页
      // Navigator.of(context).pop(); // 关闭设置弹窗
      context.go('/${RouteName.login}');
    }
  }

  void _handleDeleteAccount() async {
    getLogger().i('注销账号');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('i18n_my_注销账号'.tr),
        content: Text('i18n_my_确定要注销当前账号吗'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('i18n_my_取消'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'i18n_my_注销'.tr,
              style: const TextStyle(color: Color(0xFFFF3B30)),
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
        // 先关闭弹窗
        Navigator.of(context).pop();
        context.go('/login');
      }
    }
  }
} 
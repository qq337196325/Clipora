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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/basics/ui.dart';
import '/basics/api_services_interface.dart';
import '/basics/app_config_interface.dart';
import '/basics/translations/select_language_widget.dart';
import '/basics/translations/language_controller.dart';
import '/basics/theme/app_theme.dart';
import '/route/route_name.dart';
import '/basics/logger.dart';
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.background,
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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

                  if(!config.isCommunityEdition)
                    Column(
                      children: [
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
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),
                      ],
                    ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            offset: const Offset(0, 1),
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
              color: Theme.of(context).dividerColor,
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
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'i18n_my_设置'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [


          _buildModernSettingItem(
            icon: Icons.help_outline,
            title: 'i18n_my_使用帮助'.tr,
            subtitle: 'i18n_my_常见问题与解答'.tr,
            iconColor: const Color(0xFF45B7D1),
            iconBgColor: const Color(0xFF45B7D1).withOpacity(0.1),
            onTap: () => _handleHelp(),
            isLast: true,
            isExternalLink: false,
          ),

          if(!config.isCommunityEdition)
            Column(
              children: [
                _buildDivider(),
                _buildModernSettingItem(
                  icon: Icons.policy_outlined,
                  title: 'i18n_my_用户协议'.tr,
                  subtitle: 'i18n_my_了解我们的用户协议'.tr,
                  iconColor: Theme.of(context).colorScheme.error,
                  iconBgColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  onTap: () => _handleThirdPartyInfo(),
                  isFirst: true,
                  isExternalLink: true,
                ),
                _buildDivider(),
                _buildModernSettingItem(
                  icon: Icons.verified_user_outlined,
                  title: 'i18n_my_隐私协议'.tr,
                  subtitle: 'i18n_my_保护您的隐私权益'.tr,
                  iconColor: Theme.of(context).colorScheme.secondary,
                  iconBgColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  onTap: () => _handlePrivacyPolicy(),
                  isLast: true,
                  isExternalLink: true,
                ),
                _buildDivider(),
                _buildModernSettingItem(
                  icon: Icons.info_outline,
                  title: 'i18n_my_关于我们'.tr,
                  subtitle: 'i18n_my_了解更多应用信息'.tr,
                  iconColor: Theme.of(context).primaryColor,
                  iconBgColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () => _handleAboutUs(),
                  isExternalLink: false,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFunctionSection() {
    return Column(
      children: [
        if(!config.isCommunityEdition)
          Column(
            children: [

              const SizedBox(height: 12),
            ],
          ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.04),
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
              _buildDivider(),
              _buildDataSyncSetting(),
              _buildDivider(),
              _buildMembershipCard(),
              _buildDivider(),
              _buildAiTranslationCard(),
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
        iconColor: Theme.of(context).colorScheme.secondary,
        iconBgColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
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
        iconColor: Theme.of(context).primaryColor,
        iconBgColor: Theme.of(context).primaryColor.withOpacity(0.1),
        onTap: () => ThemeSelectorWidget.show(context),
        isFirst: false,
        isLast: false,
      );
    });
  }

  Widget _buildDataSyncSetting() {
    return _buildModernSettingItem(
      icon: Icons.sync_outlined,
      title: '数据同步',
      subtitle: '与其他设备同步数据和文件',
      iconColor: const Color(0xFF007AFF),
      iconBgColor: const Color(0xFF007AFF).withOpacity(0.1),
      onTap: () => context.push('/${RouteName.dataSync}'),
      isFirst: false,
      isLast: false,
    );
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
      child: _buildAiCardData(),
    );
  }


  Widget _buildAiCardData() {
    final remainingText = 'i18n_my_剩余'.trParams({
      'remaining': '$_remainingTranslateQuantity',
      'total': '$_totalTranslateQuantity'
    });
    
    return _buildModernSettingItem(
      icon: Icons.translate,
      title: 'i18n_my_AI翻译请求'.tr,
      subtitle: remainingText,
      iconColor: const Color(0xFF667eea),
      iconBgColor: const Color(0xFF667eea).withOpacity(0.1),
      onTap: () {
        context.push('/${RouteName.aiOrderPage}');
      },
      isExternalLink: false,
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.error.withOpacity(0.15),
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
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.error,
                  Theme.of(context).colorScheme.error.withOpacity(0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onError,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'i18n_my_退出登录'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onError,
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
  int? _remainingTranslateQuantity;
  int? _totalTranslateQuantity;
  bool _isLoadingQuantity = true;

  IApiServices apiServices = Get.find<IApiServices>();
  IConfig config = Get.find<IConfig>();

  @override
  void initState() {
    super.initState();
    _loadTranslateQuantity();
  }


  bool getAutoParseEnabled() {
    return globalBoxStorage.read('auto_parse_enabled') ?? true;
  }

  void setAutoParseEnabled(bool enabled) {
    globalBoxStorage.write('auto_parse_enabled', enabled);
  }

  void _loadTranslateQuantity() async {

    try {

      final apiServices = Get.find<IApiServices>();
      final res = await apiServices.getTranslateRequestQuantity({});


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

  void _handleThirdPartyInfo() { // 用户协议
    getLogger().i('第三方信息共享清单');
    final Uri _url = Uri.parse(config.urlPrivacy);
    goLaunchUrl(_url);
  }

  void _handlePrivacyPolicy() {
    getLogger().i('隐私公约');
    final Uri _url = Uri.parse(config.urlAgreement);
    goLaunchUrl(_url);
  }

  void _handleRating() async {
    getLogger().i('评价一下');
    
    // 显示评价对话框
    await RatingDialog.show(context);
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

  void _handleHelp() {
    getLogger().i('使用帮助');

    context.push('/${RouteName.helpDocumentation}');
    // final helpWidget = HelpWidget();
    // helpWidget.openHelpDocumentation(context);
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

      if (mounted) {
        // 先关闭弹窗
        Navigator.of(context).pop();
        context.go('/${RouteName.login}');
      }
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
        context.go('/${RouteName.login}');
      }
    }
  }

  /// 会员卡片
  Widget _buildMembershipCard() {
    final memberType = globalBoxStorage.read('member_type') ?? 0;
    
    switch (memberType) {
      case 0:
        return _buildModernSettingItem(
          icon: Icons.diamond,
          title: 'i18n_member_高级会员'.tr,
          subtitle: 'i18n_member_解锁全部功能潜力'.tr,
          iconColor: Theme.of(context).primaryColor,
          iconBgColor: Theme.of(context).primaryColor.withOpacity(0.1),
          onTap: () {
            context.push('/${RouteName.memberOrderPage}');
          },
          isExternalLink: false,
        );
      case 1:
        return _buildModernSettingItem(
          icon: Icons.workspace_premium,
          title: 'i18n_member_终身会员'.tr,
          subtitle: 'i18n_member_正在享受高级会员特权'.tr,
          iconColor: const Color(0xFFFFD700),
          iconBgColor: const Color(0xFFFFD700).withOpacity(0.1),
          onTap: () {},
          isExternalLink: false,
        );
      case 2:
        final memberExpireTime = globalBoxStorage.read('member_expire_time') ?? 0;
        final expireDate = DateTime.fromMillisecondsSinceEpoch(memberExpireTime * 1000);
        final formattedDate = '${expireDate.year}-${expireDate.month.toString().padLeft(2, '0')}-${expireDate.day.toString().padLeft(2, '0')}';
        return _buildModernSettingItem(
          icon: Icons.card_membership,
          title: 'i18n_member_订阅会员'.tr,
          subtitle: 'i18n_member_到期时间'.trParams({'date': formattedDate}),
          iconColor: Theme.of(context).primaryColor,
          iconBgColor: Theme.of(context).primaryColor.withOpacity(0.1),
          onTap: () {
            context.push('/${RouteName.memberOrderPage}');
          },
          isExternalLink: false,
        );
      default:
        return _buildModernSettingItem(
          icon: Icons.diamond,
          title: 'i18n_member_高级会员'.tr,
          subtitle: 'i18n_member_解锁全部功能潜力'.tr,
          iconColor: Theme.of(context).primaryColor,
          iconBgColor: Theme.of(context).primaryColor.withOpacity(0.1),
          onTap: () {
            context.push('/${RouteName.memberOrderPage}');
          },
          isExternalLink: false,
        );
    } 
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
          onTap();
        },
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(14) : Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isExternalLink ? Icons.open_in_new : Icons.chevron_right,
                  size: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
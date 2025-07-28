// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


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
                    )

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
        if(!config.isCommunityEdition)
          Column(
            children: [
              _buildMembershipCard(),
              const SizedBox(height: 12),
              _buildAiTranslationCard(),
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
              _buildAutoParseSettings(),

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

  Widget _buildAutoParseSettings() {
    return _buildModernSettingSwitchItem(
      icon: Icons.auto_fix_high_outlined,
      title: 'i18n_my_自动解析'.tr,
      subtitle: 'i18n_my_自动解析网页内容并提取文本'.tr,
      iconColor: const Color(0xFF34C759),
      iconBgColor: const Color(0xFF34C759).withOpacity(0.1),
      value: _autoParseEnabled,
      onChanged: (bool value) {
        setState(() {
          _autoParseEnabled = value;
          setAutoParseEnabled(value);
        });
      },
      isFirst: false,
      isLast: true,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
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
        Text('i18n_my_正在获取AI翻译余量'.tr, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
      ],
    );
  }

  Widget _buildAiCardError() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
        const SizedBox(width: 8),
        Text('i18n_my_加载失败请点击重试'.tr,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error,
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
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'i18n_my_让阅读更智能翻译更流畅'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
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
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'i18n_my_已用'.trParams({'used': '${_totalTranslateQuantity! - _remainingTranslateQuantity!}'}),
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            Text(
              'i18n_my_剩余'.trParams({
                'remaining': '$_remainingTranslateQuantity',
                'total': '$_totalTranslateQuantity'
              }),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleSmall?.color,
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

  Widget _buildModernSettingSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
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
          _buildCustomSwitch(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: value
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ],
                ),
          boxShadow: [
            BoxShadow(
              color: value 
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: value ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 24 : 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: value
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      )
                    : Icon(
                        Icons.close,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
              ),
            ),
          ],
        ),
      ),
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
  bool _autoParseEnabled = true; // 添加自动解析状态变量

  IApiServices apiServices = Get.find<IApiServices>();
  IConfig config = Get.find<IConfig>();

  @override
  void initState() {
    super.initState();
    _loadTranslateQuantity();
    _loadAutoParseSettings(); // 加载自动解析设置
  }

  // 加载自动解析设置
  void _loadAutoParseSettings() {
    setState(() {
      _autoParseEnabled = getAutoParseEnabled();
    });
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
      getLogger().i('退出登录11111');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      getLogger().i('退出登录22222');
      // 先关闭弹窗，然后跳转到登录页
      // Navigator.of(context).pop(); // 关闭设置弹窗
      if (mounted) {
        getLogger().i('退出登录33333');
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
        return _buildPurchaseCard(); // 非会员显示购买卡片
      case 1:
        return _buildLifetimeMemberCard(); // 买断制会员卡片
      case 2:
        return _buildSubscriptionMemberCard(); // 订阅会员卡片
      default:
        return _buildPurchaseCard();
    } 
  }

  /// 购买会员卡片（非会员状态）
  Widget _buildPurchaseCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.diamond,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'i18n_member_高级会员'.tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'i18n_member_解锁全部功能潜力'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  context.push('/${RouteName.memberOrderPage}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text('i18n_member_upgrade'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'i18n_member_限时买断'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'i18n_member_一次性购买'.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 买断制会员卡片
  Widget _buildLifetimeMemberCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.15),
            const Color(0xFFFFD700).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFD700),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'i18n_member_终身会员'.tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'VIP',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'i18n_member_正在享受高级会员特权'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'i18n_member_会员已激活'.tr,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.all_inclusive,
                  size: 16,
                  color: Color(0xFFFFD700),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'i18n_member_永久访问权限'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'i18n_member_感谢您的支持'.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 订阅制会员卡片
  Widget _buildSubscriptionMemberCard() {
    final memberExpireTime = globalBoxStorage.read('member_expire_time') ?? 0;
    final expireDate = DateTime.fromMillisecondsSinceEpoch(memberExpireTime * 1000);
    final formattedDate = '${expireDate.year}-${expireDate.month.toString().padLeft(2, '0')}-${expireDate.day.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.15),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.card_membership,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'i18n_member_订阅会员'.tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'i18n_member_正在享受高级会员特权'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  context.push('/${RouteName.memberOrderPage}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text('i18n_member_续费'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'i18n_member_到期时间'.trParams({'date': formattedDate}),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'i18n_member_会员已激活'.tr,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
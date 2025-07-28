// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'dart:async';

import '../../basics/app_config_interface.dart';
import '../../basics/logger.dart';
import '../../basics/ui.dart';
import '../../private/api/user_api.dart';

/// 会员购买页面
class MemberOrderPage extends StatefulWidget {
  const MemberOrderPage({super.key});

  @override
  State<MemberOrderPage> createState() => _MemberOrderPageState();
}

class _MemberOrderPageState extends State<MemberOrderPage>
    with TickerProviderStateMixin, MemberOrderPageBLoC {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部导航栏
            _buildTopBar(),

            // 可滚动内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // 会员介绍卡片
                      _buildMemberIntroCard(),

                      const SizedBox(height: 24),

                      // 限时买断说明卡片
                      _buildLimitedTimeCard(),

                      const SizedBox(height: 24),

                      // 会员特权列表
                      _buildMemberFeaturesList(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // 底部购买按钮区域
            _buildBottomPurchaseArea(),
          ],
        ),
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // 返回按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 标题
          Flexible(
            child: Text(
              'i18n_member_高级会员'.tr,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineMedium?.color,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  /// 会员介绍卡片
  Widget _buildMemberIntroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryFixed,
            Theme.of(context).colorScheme.primaryFixed.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.diamond,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'i18n_member_Clipora高级版'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'i18n_member_解锁全部功能潜力'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'i18n_member_享受高级功能'.tr,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 限时买断说明卡片
  Widget _buildLimitedTimeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 限时买断标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'i18n_member_限时买断'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time_filled,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 价格展示
          _buildPriceDisplay(),

          const SizedBox(height: 16),

          // 限时说明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: _buildLimitedTimeDescription(),
          ),
        ],
      ),
    );
  }

  /// 价格显示组件
  Widget _buildPriceDisplay() {
    if (Platform.isIOS) {
      if (products.isNotEmpty) {
        // iOS使用App Store价格
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              productMember.price,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'i18n_member_一次性购买'.tr,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        );
      } else {
        // iOS价格加载中
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 80,
              height: 36,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'i18n_member_一次性购买'.tr,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        );
      }
    } else {
      // Android使用默认价格
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '¥',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Text(
            '98',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'i18n_member_一次性购买'.tr,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      );
    }
  }

  /// 限时说明
  Widget _buildLimitedTimeDescription() {
    final features = [
      {
        'icon': Icons.schedule,
        'text': 'i18n_member_未来订阅计划'.tr,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'icon': Icons.security,
        'text': 'i18n_member_现有数据保证'.tr,
        'color': const Color(0xFF52c41a),
      },
      {
        'icon': Icons.update,
        'text': 'i18n_member_终身更新'.tr,
        'color': const Color(0xFF1890ff),
      },
      {
        'icon': Icons.block,
        'text': 'i18n_member_无广告保证'.tr,
        'color': const Color(0xFFff4d4f),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              'i18n_member_重要说明'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 特性列表
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (feature['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  size: 14,
                  color: feature['color'] as Color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature['text'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// 会员特权列表
  Widget _buildMemberFeaturesList() {
    final features = [
      {
        'icon': Icons.cloud_sync,
        'title': 'i18n_member_无限同步'.tr,
        'subtitle': 'i18n_member_无限同步描述'.tr,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'icon': Icons.storage,
        'title': 'i18n_member_无限存储'.tr,
        'subtitle': 'i18n_member_无限存储描述'.tr,
        'color': const Color(0xFF667eea),
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'i18n_member_高级功能'.tr,
        'subtitle': 'i18n_member_高级功能描述'.tr,
        'color': const Color(0xFF9B59B6),
      },
      {
        'icon': Icons.support_agent,
        'title': 'i18n_member_优先支持'.tr,
        'subtitle': 'i18n_member_优先支持描述'.tr,
        'color': const Color(0xFFFF9500),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'i18n_member_高级特权'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFeatureItem(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            subtitle: feature['subtitle'] as String,
            color: feature['color'] as Color,
          ),
        )),
      ],
    );
  }

  /// 功能特性项
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 20,
            color: color,
          ),
        ],
      ),
    );
  }

  /// 底部购买区域
  Widget _buildBottomPurchaseArea() {
    // 根据平台显示不同的支付方式
    final bool isAndroid = Platform.isAndroid;
    
    // 获取价格字符串
    String priceString;
    if (Platform.isIOS) {
      if (products.isNotEmpty) {
        priceString = productMember.price;
      } else {
        priceString = '...'; // 价格加载中
      }
    } else {
      priceString = '¥98';
    }
    
    final String buttonText = isAndroid
        ? 'i18n_member_微信支付'.trParams({'price': priceString})
        : 'i18n_member_立即购买'.trParams({'price': priceString});
    final IconData buttonIcon = isAndroid ? Icons.payment : Icons.shopping_cart;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            offset: const Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 协议条款
          _buildAgreementSection(),
          const SizedBox(height: 16),
          // 购买按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (isLoading || (Platform.isIOS && products.isEmpty)) ? null : handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Theme.of(context).primaryColor.withOpacity(0.5);
                  }
                  return Theme.of(context).primaryColor;
                }),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isLoading ? null : LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              buttonIcon,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                buttonText,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 协议条款区域
  Widget _buildAgreementSection() {
    return Column(
      children: [
        // 协议勾选
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isAgreedToTerms = !isAgreedToTerms;
                });
              },
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: isAgreedToTerms ? Theme.of(context).primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isAgreedToTerms ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isAgreedToTerms
                    ? Icon(
                        Icons.check,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: InkWell(
                onTap: (){
                  setState(() {
                    isAgreedToTerms = !isAgreedToTerms;
                  });
                },
                child: Text('i18n_member_购买前请阅读并同意'.tr, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _handleUserAgreement(),
                        child: Text(
                          'i18n_member_购买协议'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 业务逻辑 Mixin
mixin MemberOrderPageBLoC on State<MemberOrderPage> {
  bool isLoading = false;
  bool isAgreedToTerms = false;
  Fluwx fluwx = Fluwx();

  // 支付结果监听订阅
  StreamSubscription? _paymentSubscription;

  /// IOS支付
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  List<ProductDetails> products = <ProductDetails>[];
  late ProductDetails productMember;

  @override
  void initState() {
    super.initState();
    // 页面初始化

    // 监听微信支付结果
    if(Platform.isAndroid){
      _setupPaymentListener();
    }

    /// 监听IOS支付
    if (Platform.isIOS) {
      _iosPayInit();
      final Stream<List<PurchaseDetails>> purchaseUpdated = inAppPurchase.purchaseStream;
      subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
      });
    }
  }

  _iosPayInit() async {
    /// 获取IOS支付价格
    if (Platform.isIOS) {
      const Set<String> kIds = {'buy_outmembers'};
      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(kIds);

      if (mounted) {
        setState(() {
          response.productDetails.forEach((value) {
            switch (value.id) {
              case "buy_outmembers":
                productMember = value;
                break;
            }
          });
          products = response.productDetails;
        });
      }
    }
  }

  @override
  void dispose() {
    // 取消支付结果监听
    _paymentSubscription?.cancel();

    // 取消iOS支付监听
    if (Platform.isIOS) {
      subscription.cancel();
    }

    // 资源清理
    super.dispose();
  }

  /// 设置支付结果监听
  void _setupPaymentListener() {
    fluwx.addSubscriber((response){
      getLogger().i('💰 微信支付结果: ${response.errCode} - ${response.errStr}');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _handlePaymentResult(response);
    });
  }

  /// 处理支付结果
  void _handlePaymentResult(WeChatResponse response) {
    if (!mounted) return;

    switch (response.errCode) {
      case 0:
        // 支付成功
        getLogger().i('✅ 微信支付：支付成功');
        _showSuccessDialog();
        break;
      case -1:
        // 支付错误 - 可能有具体的原因
        getLogger().e('❌ 微信支付：支付错误 - ${response.errStr}');
        _showErrorDialog('i18n_member_payment_failed_retry'.tr);
        break;
      case -2:
        // 用户取消支付
        getLogger().w('⚠️ 微信支付：用户取消支付');
        BotToast.showText(text: "i18n_member_payment_cancelled".tr);
        break;
      default:
        // 其他错误
        getLogger().e(
            '❌ 微信支付：未知错误 - 错误码: ${response.errCode}, 错误信息: ${response.errStr}');
        _showErrorDialog('i18n_member_payment_error_retry_later'.tr);
        break;
    }
  }

  /// 处理购买请求
  Future<void> handlePurchase() async {
    // 检查是否同意协议
    if (!isAgreedToTerms) {
      _showErrorDialog('i18n_member_please_agree_to_terms'.tr);
      return;
    }

    // 添加触觉反馈
    HapticFeedback.lightImpact();

    setState(() {
      isLoading = true;
    });

    try {
      // 调用支付API获取支付参数
      if(Platform.isAndroid){
        final res = await UserApi.createTranslatePayOrderApi({
          "pay_type": 1,
          "platform": "app",
          "order_type": 1,
        });
        if(res["code"] != 0){
          _showErrorDialog('i18n_member_failed_to_initiate_payment'.tr);
          return;
        }

        final config = Get.find<IConfig>();

        // 发起微信支付
        final payStatus = await fluwx.pay(
          which: Payment(
            appId: config.wxAppId,
            partnerId: res["data"]["data"]["partnerId"].toString(),
            prepayId: res["data"]["data"]["prepayId"].toString(),
            packageValue: res["data"]["data"]["package"].toString(),
            nonceStr: res["data"]["data"]["nonceStr"].toString(),
            timestamp: int.parse(res["data"]["data"]["timeStamp"]),
            sign: res["data"]["data"]["sign"].toString(),
          ),
        );

        if (!payStatus) {
          // 调起支付失败
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            _showErrorDialog('i18n_member_failed_to_initiate_payment'.tr);
          }
        }
      } else if (Platform.isIOS) {
        // iOS App Store 支付
        await buyProduct();
      }

    } catch (e) {
      getLogger().e('❌ 支付API调用异常: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('i18n_member_failed_to_create_order'.tr);
      }
    }
  }

  /// 发起Ios支付
  Future<void> buyProduct() async {
    ProductDetails prod = productMember;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// IOS支付监听
  Future<void> listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (!mounted) return;

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          getLogger().d('⏳ iOS支付：等待支付中');
          break;

        case PurchaseStatus.error:
          getLogger().e('❌ iOS支付错误：${purchaseDetails.error?.message}');

          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }

          String errorMessage = 'i18n_member_payment_failed'.tr;
          if (purchaseDetails.error != null) {
            switch (purchaseDetails.error!.code) {
              case 'purchase_canceled':
                errorMessage = 'i18n_member_payment_cancelled'.tr;
                BotToast.showText(text: errorMessage);
                break;
              case 'item_unavailable':
                errorMessage = 'i18n_member_item_unavailable'.tr;
                _showErrorDialog(errorMessage);
                break;
              case 'network_error':
                errorMessage = 'i18n_member_network_error'.tr;
                _showErrorDialog(errorMessage);
                break;
              default:
                errorMessage = 'i18n_member_payment_exception'
                    .trParams({'message': purchaseDetails.error!.message});
                _showErrorDialog(errorMessage);
                break;
            }
          } else {
            _showErrorDialog(errorMessage);
          }
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          getLogger().i('✅ iOS支付：支付成功，开始后台验证');
          await _handlePaymentVerification(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          getLogger().w('⚠️ iOS支付：支付已取消');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          BotToast.showText(text: "i18n_member_payment_cancelled".tr);
          break;

        default:
          getLogger().w('⚠️ iOS支付：未知状态 - ${purchaseDetails.status}');
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        getLogger().i('✅ iOS支付：完成支付流程');
        try {
          await inAppPurchase.completePurchase(purchaseDetails);
        } catch (e) {
          getLogger().e('❌ iOS支付：完成支付流程失败 - $e');
        }
      }
    }
  }

  /// 处理支付验证
  Future<void> _handlePaymentVerification(PurchaseDetails purchaseDetails) async {
    try {
      Map<String, dynamic> param = {
        "order_type": 1,
        "platform": "ios",
        "pay_type": 3,
        "local_verification_data": purchaseDetails.verificationData.localVerificationData,
        "server_verification_data": purchaseDetails.verificationData.serverVerificationData,
        "source": purchaseDetails.verificationData.source,
      };

      final res = await UserApi.iosPayTranslateOrderApi(param);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (res["code"] == 0) {
        getLogger().i('✅ iOS支付：后台验证成功');
        _showSuccessDialog();
      } else {
        String errorMessage =
            res["message"] ?? 'i18n_member_verification_failed_contact_support'.tr;
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showErrorDialog("i18n_member_verification_exception_contact_support".tr);
    }
  }

  /// 处理用户协议点击
  void _handleUserAgreement() {
    final Uri _url = Uri.parse("https://clipora.guanshangyun.com/payment_agreement");
    goLaunchUrl(_url);
  }

  /// 显示成功对话框
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF52c41a), Color(0xFF73d13d)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'i18n_member_upgrade_successful'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'i18n_member_premium_activated'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C8C8C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'i18n_member_confirm'.tr,
                      style: const TextStyle(
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

  /// 显示错误对话框
  void _showErrorDialog(String message) {
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
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF6B6B),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'i18n_member_upgrade_failed'.tr,
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
                    color: Color(0xFF8C8C8C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'i18n_member_confirm'.tr,
                      style: const TextStyle(
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
}
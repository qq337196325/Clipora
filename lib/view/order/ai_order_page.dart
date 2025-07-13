import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'dart:async';

import '../../api/user_api.dart';
import '../../basics/config.dart';
import '../../basics/logger.dart';
import '../../basics/ui.dart';

/// AI请求包购买页面
class AIOrderPage extends StatefulWidget {
  const AIOrderPage({super.key});

  @override
  State<AIOrderPage> createState() => _AIOrderPageState();
}

class _AIOrderPageState extends State<AIOrderPage>
    with TickerProviderStateMixin, AIOrderPageBLoC {
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

                      // AI助手介绍卡片
                      _buildAIIntroCard(),

                      const SizedBox(height: 24),

                      // 套餐详情卡片
                      _buildPackageCard(),

                      const SizedBox(height: 24),

                      // 功能优势列表
                      _buildFeaturesList(),

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
          Text(
            'i18n_order_ai_translation_request_package'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.headlineMedium?.color,
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(),

        ],
      ),
    );
  }

  /// AI助手介绍卡片
  Widget _buildAIIntroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
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
                  Icons.auto_awesome,
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
                      'i18n_order_ai_translation_assistant'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'i18n_order_smarter_reading_efficient_learning'.tr,
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
            'i18n_order_translate_articles_with_ai'.tr,
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

  /// 套餐详情卡片
  Widget _buildPackageCard() {
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
          // 套餐标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'i18n_order_limited_time_offer'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.stars,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 价格展示
          Row(
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
                '12',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'i18n_order_original_price'.trParams({'price': '20'}),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 套餐详情
          _buildPackageDetailItem(
            icon: Icons.flash_on,
            title: 'i18n_order_requests'.trParams({'count': '320'}),
            subtitle: 'i18n_order_enough_for_deep_reading'.tr,
            iconColor: const Color(0xFFFF9500),
          ),

          const SizedBox(height: 12),

          _buildPackageDetailItem(
            icon: Icons.access_time,
            title: 'i18n_order_validity'.trParams({'days': '30'}),
            subtitle: 'i18n_order_effective_immediately'.tr,
            iconColor: const Color(0xFF4ECDC4),
          ),

          const SizedBox(height: 12),

          _buildPackageDetailItem(
            icon: Icons.trending_up,
            title: 'i18n_order_intelligent_and_powerful'.tr,
            subtitle: 'i18n_order_translate_with_ai_models'.tr,
            iconColor: const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }

  /// 套餐详情项
  Widget _buildPackageDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 功能优势列表
  Widget _buildFeaturesList() {
    final features = [
      // {
      //   'icon': Icons.summarize,
      //   'title': '智能总结',
      //   'subtitle': '一键提取文章核心要点',
      //   'color': const Color(0xFF667eea),
      // },
      // {
      //   'icon': Icons.edit_note,
      //   'title': '笔记生成',
      //   'subtitle': '自动生成结构化读书笔记',
      //   'color': const Color(0xFF4ECDC4),
      // },
      // {
      //   'icon': Icons.quiz,
      //   'title': '智能问答',
      //   'subtitle': '针对阅读内容提问和解答',
      //   'color': const Color(0xFF9B59B6),
      // },
      {
        'icon': Icons.translate,
        'title': 'i18n_order_multilingual_support'.tr,
        'subtitle': 'i18n_order_support_translation_and_understanding'.tr,
        'color': const Color(0xFFFF9500),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'i18n_order_core_features'.tr,
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
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  /// 底部购买区域
  Widget _buildBottomPurchaseArea() {
    // 根据平台显示不同的支付方式
    final bool isAndroid = Platform.isAndroid;
    final String buttonText = isAndroid
        ? 'i18n_order_wechat_pay'.trParams({'price': '12'})
        : 'i18n_order_buy_now'.trParams({'price': '12'});
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
              onPressed: isLoading ? null : handlePurchase,
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
                            Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
            InkWell(
              onTap: (){
                setState(() {
                  isAgreedToTerms = !isAgreedToTerms;
                });
              },
              child: Text('i18n_order_please_read_and_agree'.tr, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
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
                          'i18n_order_purchase_agreement'.tr,
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
mixin AIOrderPageBLoC on State<AIOrderPage> {
  bool isLoading = false;
  bool isAgreedToTerms = false; // 默认同意，符合用户体验
  Fluwx fluwx = Fluwx();

  // 支付结果监听订阅
  StreamSubscription? _paymentSubscription;

  /// IOS支付
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  List<ProductDetails> products = <ProductDetails>[];
  late ProductDetails productAiRequest;

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
      // final bool isAvailable = await inAppPurchase.isAvailable();
      const Set<String> kIds = {'ai_request'};
      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(kIds);

      setState(() {
        // isAvailable = isAvailable;
        response.productDetails.forEach((value) {
          switch (value.id) {
            case "ai_request":
              productAiRequest = value;
              break;
          }
        });
        products = response.productDetails;
      });
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
        _showErrorDialog('i18n_order_payment_failed_retry'.tr);
        break;
      case -2:
        // 用户取消支付
        getLogger().w('⚠️ 微信支付：用户取消支付');
        // 用户主动取消，通常不需要显示错误提示
        // 可以选择显示轻提示或者不处理
        BotToast.showText(text: "i18n_order_payment_cancelled".tr);
        break;
      default:
        // 其他错误
        getLogger().e(
            '❌ 微信支付：未知错误 - 错误码: ${response.errCode}, 错误信息: ${response.errStr}');
        _showErrorDialog('i18n_order_payment_error_retry_later'.tr);
        break;
    }
  }

  /// 处理购买请求
  Future<void> handlePurchase() async {
    // 检查是否同意协议
    if (!isAgreedToTerms) {
      _showErrorDialog('i18n_order_please_agree_to_terms'.tr);
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
        });

        // 发起微信支付
        final payStatus = await fluwx.pay(
          which: Payment(
            appId: wxAppId,
            partnerId: res["data"]["data"]["partnerId"].toString(),
            prepayId: res["data"]["data"]["prepayId"].toString(),
            packageValue: res["data"]["data"]["package"].toString(),
            nonceStr: res["data"]["data"]["nonceStr"].toString(),
            timestamp: int.parse(res["data"]["data"]["timeStamp"]),
            sign: res["data"]["data"]["sign"].toString(),
          ),
        );

        // 注意：这里的 payStatus 只是表示调起支付是否成功
        // 真正的支付结果需要通过 responseFromPayment 流来监听
        if (!payStatus) {
          // 调起支付失败
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            _showErrorDialog('i18n_order_failed_to_initiate_payment'.tr);
          }
        }
        // 如果调起成功，等待支付结果通过 responseFromPayment 流返回
      } else if (Platform.isIOS) {
        // iOS App Store 支付
        await buyProduct();
        // loading状态将在支付流程回调中处理
      }


    } catch (e) {
      getLogger().e('❌ 支付API调用异常: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        // 错误处理
        _showErrorDialog('i18n_order_failed_to_create_order'.tr);
      }
    }
  }


  /// 发起Ios支付
  Future<void> buyProduct() async {
    ProductDetails prod = productAiRequest;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// IOS支付监听
  Future<void> listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      // 检查Widget是否还存在
      if (!mounted) return;

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // 等待支付中
          getLogger().d('⏳ iOS支付：等待支付中');
          // 可以在这里显示等待UI
          break;

        case PurchaseStatus.error:
          // 支付错误处理
          getLogger().e('❌ iOS支付错误：${purchaseDetails.error?.message}');

          // 重置loading状态
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }

          // 显示错误提示
          String errorMessage = 'i18n_order_payment_failed'.tr;
          if (purchaseDetails.error != null) {
            switch (purchaseDetails.error!.code) {
              case 'purchase_canceled':
                errorMessage = 'i18n_order_payment_cancelled'.tr;
                // 用户取消支付，使用轻提示
                BotToast.showText(text: errorMessage);
                break;
              case 'item_unavailable':
                errorMessage = 'i18n_order_item_unavailable'.tr;
                _showErrorDialog(errorMessage);
                break;
              case 'network_error':
                errorMessage = 'i18n_order_network_error'.tr;
                _showErrorDialog(errorMessage);
                break;
              default:
                errorMessage = 'i18n_order_payment_exception'
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
          // 支付成功，进行后台验证
          getLogger().i('✅ iOS支付：支付成功，开始后台验证');
          await _handlePaymentVerification(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          // 支付取消
          getLogger().w('⚠️ iOS支付：支付已取消');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          BotToast.showText(text: "i18n_order_payment_cancelled".tr);
          break;

        default:
          getLogger().w('⚠️ iOS支付：未知状态 - ${purchaseDetails.status}');
          break;
      }

      // 完成支付流程
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
      // 构建验证参数
      Map<String, dynamic> param = {
        "platform": "ios",
        "pay_type": 3,
        "local_verification_data": purchaseDetails.verificationData.localVerificationData,
        "server_verification_data": purchaseDetails.verificationData.serverVerificationData,
        "source": purchaseDetails.verificationData.source,
      };

      // 调用后台验证API
      final res = await UserApi.iosPayTranslateOrderApi(param);

      // 检查Widget是否还存在
      if (!mounted) return;

      // 重置loading状态
      setState(() {
        isLoading = false;
      });

      if (res["code"] == 0) {
        // 验证成功
        getLogger().i('✅ iOS支付：后台验证成功');
        _showSuccessDialog();
      } else {
        // 验证失败
        print("iOS支付：后台验证失败 - ${res["message"] ?? "未知错误"}");
        String errorMessage =
            res["message"] ?? 'i18n_order_verification_failed_contact_support'.tr;
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      print("iOS支付：验证异常 - $e");

      // 检查Widget是否还存在
      if (!mounted) return;

      // 重置loading状态
      setState(() {
        isLoading = false;
      });

      // 显示错误提示
      _showErrorDialog("i18n_order_verification_exception_contact_support".tr);
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
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'i18n_order_purchase_successful'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'i18n_order_ai_assistant_activated'.tr,
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
                      'i18n_order_confirm'.tr,
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
                  'i18n_order_purchase_failed'.tr,
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
                      'i18n_order_confirm'.tr,
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

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
import 'components/show_dialog.dart';

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
                      const SizedBox(height: 16),

                      // 会员介绍卡片
                      buildMemberIntroCard(context),

                      const SizedBox(height: 16),

                      // 功能对比表
                      buildFeatureComparison(context),


                      const SizedBox(height: 16),

                      // 订阅计划选择
                      _buildSubscriptionPlans(),

                      const SizedBox(height: 32),
                      // 底部购买按钮区域
                      _buildBottomPurchaseArea(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 标题
          Flexible(
            child: Text(
              'Clipora 高级会员',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineMedium?.color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// 订阅计划选择
  Widget _buildSubscriptionPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择订阅计划',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        
        // 月度计划
        buildPlanCard(
          title: '月度会员',
          duration: '1个月',
          price: _getLocalizedPrice('monthly'),
          originalPrice: null,
          isSelected: selectedPlan == 'monthly',
          onTap: () => setState(() => selectedPlan = 'monthly'),
          badge: null,
          context: context
        ),
        
        const SizedBox(height: 10),
        
        // 半年计划
        buildPlanCard(
          title: '半年会员',
          duration: '6个月',
          price: _getLocalizedPrice('halfyear'),
          originalPrice: null,
          isSelected: selectedPlan == 'halfyear',
          onTap: () => setState(() => selectedPlan = 'halfyear'),
          badge: null,
          context: context
        ),
        
        const SizedBox(height: 10),
        
        // 年度计划
        buildPlanCard(
          title: '年度会员',
          duration: '12个月',
          price: _getLocalizedPrice('yearly'),
          originalPrice: null,
          isSelected: selectedPlan == 'yearly',
          onTap: () => setState(() => selectedPlan = 'yearly'),
          badge: null,
          isRecommended: true,
          context: context
        ),
      ],
    );
  }



  /// 底部购买区域
  Widget _buildBottomPurchaseArea() {
    // 根据平台显示不同的支付方式
    final bool isAndroid = Platform.isAndroid;
    
    // 获取价格字符串
    String priceString = _getLocalizedPrice(selectedPlan);
    
    final String buttonText = isAndroid
        ? '微信支付 $priceString'
        : '立即购买 $priceString';
    final IconData buttonIcon = isAndroid ? Icons.payment : Icons.shopping_cart;

    return Column(
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
    );
  }

  /// 协议条款区域
  Widget _buildAgreementSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       isAgreedToTerms = !isAgreedToTerms;
        //     });
        //   },
        //   child: Container(
        //     width: 18,
        //     height: 18,
        //     margin: const EdgeInsets.only(top: 1),
        //     decoration: BoxDecoration(
        //       color: isAgreedToTerms ? Theme.of(context).primaryColor : Colors.transparent,
        //       border: Border.all(
        //         color: isAgreedToTerms ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
        //         width: 1.5,
        //       ),
        //       borderRadius: BorderRadius.circular(4),
        //     ),
        //     child: isAgreedToTerms
        //         ? Icon(
        //             Icons.check,
        //             size: 12,
        //             color: Theme.of(context).colorScheme.onPrimary,
        //           )
        //         : null,
        //   ),
        // ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                // isAgreedToTerms = !isAgreedToTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: '购买前请阅读 '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _handleUserAgreement(),
                      child: Text(
                        '《购买协议》',
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
        ),
      ],
    );
  }

  /// 获取本地化价格
  String _getLocalizedPrice(String plan) {
    if (Platform.isIOS && products.isNotEmpty) {
      // iOS使用App Store价格
      switch (plan) {
        case 'monthly':
          return productMonthly?.price ?? '¥12';
        case 'halfyear':
          return productHalfYear?.price ?? '¥49';
        case 'yearly':
          return productYearly?.price ?? '¥88';
        case 'monthly_x6':
          return '¥72'; // 月度价格 x 6
        case 'monthly_x12':
          return '¥144'; // 月度价格 x 12
        default:
          return '¥12';
      }
    } else {
      // Android或iOS价格未加载时使用默认价格
      switch (plan) {
        case 'monthly':
          return '¥12';
        case 'halfyear':
          return '¥49';
        case 'yearly':
          return '¥88';
        case 'monthly_x6':
          return '¥72';
        case 'monthly_x12':
          return '¥144';
        default:
          return '¥12';
      }
    }
  }

}

/// 业务逻辑 Mixin
mixin MemberOrderPageBLoC on State<MemberOrderPage> {
  bool isLoading = false;
  bool isAgreedToTerms = true;
  String selectedPlan = 'yearly'; // 默认选择年度计划
  Fluwx fluwx = Fluwx();

  // 支付结果监听订阅
  StreamSubscription? _paymentSubscription;

  /// IOS支付
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  List<ProductDetails> products = <ProductDetails>[];
  ProductDetails? productMonthly;
  ProductDetails? productHalfYear;
  ProductDetails? productYearly;

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
      const Set<String> kIds = {'monthly_member', 'halfyear_member', 'yearly_member'};
      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(kIds);

      if (mounted) {
        setState(() {
          response.productDetails.forEach((value) {
            switch (value.id) {
              case "monthly_member":
                productMonthly = value;
                break;
              case "halfyear_member":
                productHalfYear = value;
                break;
              case "yearly_member":
                productYearly = value;
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
        showSuccessDialog(context);
        break;
      case -1:
        // 支付错误 - 可能有具体的原因
        getLogger().e('❌ 微信支付：支付错误 - ${response.errStr}');
        showErrorDialog('支付失败，请重试',context);
        break;
      case -2:
        // 用户取消支付
        getLogger().w('⚠️ 微信支付：用户取消支付');
        BotToast.showText(text: "支付已取消");
        break;
      default:
        // 其他错误
        getLogger().e(
            '❌ 微信支付：未知错误 - 错误码: ${response.errCode}, 错误信息: ${response.errStr}');
        showErrorDialog('支付出现错误，请稍后重试',context);
        break;
    }
  }

  /// 处理购买请求
  Future<void> handlePurchase() async {
    // 检查是否同意协议
    if (!isAgreedToTerms) {
      showErrorDialog('请先阅读并同意购买协议',context);
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
        // 根据选择的计划确定订单类型
        int memberType;
        switch (selectedPlan) {
          case 'monthly':
            memberType = 2; // 月度订阅
            break;
          case 'halfyear':
            memberType = 3; // 半年订阅
            break;
          case 'yearly':
            memberType = 4; // 年度订阅
            break;
          default:
            memberType = 4; // 默认年度
        }
        
        final res = await UserApi.createTranslatePayOrderApi({
          "pay_type": 1,
          "platform": "app",
          "order_type": 1,
          "member_type": memberType,
        });
        if(res["code"] != 0){
          showErrorDialog('发起支付失败', context);
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
            showErrorDialog('发起支付失败',context);
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
        showErrorDialog('创建订单失败',context);
      }
    }
  }

  /// 发起Ios支付
  Future<void> buyProduct() async {
    ProductDetails? prod;
    switch (selectedPlan) {
      case 'monthly':
        prod = productMonthly;
        break;
      case 'halfyear':
        prod = productHalfYear;
        break;
      case 'yearly':
        prod = productYearly;
        break;
      default:
        prod = productYearly;
    }
    
    if (prod == null) {
      showErrorDialog('产品信息加载失败', context);
      return;
    }
    
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

          String errorMessage = '支付失败';
          if (purchaseDetails.error != null) {
            switch (purchaseDetails.error!.code) {
              case 'purchase_canceled':
                errorMessage = '支付已取消';
                BotToast.showText(text: errorMessage);
                break;
              case 'item_unavailable':
                errorMessage = '商品不可用';
                showErrorDialog(errorMessage,context);
                break;
              case 'network_error':
                errorMessage = '网络错误';
                showErrorDialog(errorMessage,context);
                break;
              default:
                errorMessage = '支付异常：${purchaseDetails.error!.message}';
                showErrorDialog(errorMessage,context);
                break;
            }
          } else {
            showErrorDialog(errorMessage,context);
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
          BotToast.showText(text: "支付已取消");
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
      // 根据选择的计划确定订单类型
      int memberType;
      switch (selectedPlan) {
        case 'monthly':
          memberType = 2; // 月度订阅
          break;
        case 'halfyear':
          memberType = 3; // 半年订阅
          break;
        case 'yearly':
          memberType = 4; // 年度订阅
          break;
        default:
          memberType = 4; // 默认年度
      }
      
      Map<String, dynamic> param = {
        "order_type": 1,
        "platform": "ios",
        "pay_type": 3,
        "member_type": memberType,
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
        showSuccessDialog(context);
      } else {
        String errorMessage =
            res["message"] ?? '验证失败，请联系客服';
        showErrorDialog(errorMessage,context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showErrorDialog("验证异常，请联系客服",context);
    }
  }

  /// 处理用户协议点击
  void _handleUserAgreement() {
    final Uri _url = Uri.parse("https://clipora.guanshangyun.com/payment_agreement");
    goLaunchUrl(_url);
  }
}
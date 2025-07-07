import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluwx/fluwx.dart';
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
      backgroundColor: const Color(0xFFF8F5EC),
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
      decoration: const BoxDecoration(
        color: Color(0xFFFEFDF8),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
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
                  color: Colors.grey.shade100.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 标题
          const Text(
            'AI翻译请求包',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C3C3C),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI翻译助手',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '让阅读更智能，让学习更高效',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            '通过AI翻译助手，您可以文章翻译成多国语言。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
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
        color: const Color(0xFFFEFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.1),
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
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '限时优惠',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.stars,
                color: Color(0xFFFFD93D),
                size: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 价格展示
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const Text(
                '12',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '原价¥20',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF6B6B),
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
            title: '320次AI请求',
            subtitle: '足够一个月的深度阅读使用',
            iconColor: const Color(0xFFFF9500),
          ),
          
          const SizedBox(height: 12),
          
          _buildPackageDetailItem(
            icon: Icons.access_time,
            title: '30天有效期',
            subtitle: '购买后立即生效，充足时间体验',
            iconColor: const Color(0xFF4ECDC4),
          ),
          
          const SizedBox(height: 12),
          
          _buildPackageDetailItem(
            icon: Icons.trending_up,
            title: '智能强大',
            subtitle: '利用AI大模型将您的内容翻译成多国语言',
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8C8C8C),
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
        'title': '多国语言支持',
        'subtitle': '支持翻译和多语言理解',
        'color': const Color(0xFFFF9500),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '核心功能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3C3C3C),
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
        color: const Color(0xFFFEFDF8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3C3C3C),
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
    final String buttonText = isAndroid ? '微信支付 ¥12' : '立即购买 ¥12';
    final IconData buttonIcon = isAndroid ? Icons.payment : Icons.shopping_cart;
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFDF8),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          
          // 购买按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAndroid ? const Color(0xFF07C160) : const Color(0xFF667eea),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return (isAndroid ? const Color(0xFF07C160) : const Color(0xFF667eea)).withOpacity(0.5);
                  }
                  return isAndroid ? const Color(0xFF07C160) : const Color(0xFF667eea);
                }),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isLoading ? null : LinearGradient(
                    colors: isAndroid 
                        ? [const Color(0xFF07C160), const Color(0xFF00A850)]
                        : [const Color(0xFF667eea), const Color(0xFF764ba2)],
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
          
          const SizedBox(height: 16),
          
          // 协议条款
          _buildAgreementSection(),
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
                  color: isAgreedToTerms ? const Color(0xFF667eea) : Colors.transparent,
                  border: Border.all(
                    color: isAgreedToTerms ? const Color(0xFF667eea) : const Color(0xFFD1D5DB),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isAgreedToTerms
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8C8C8C),
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: '购买前请阅读'),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _handleUserAgreement(),
                        child: const Text(
                          '《购买协议》',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667eea),
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
  bool isAgreedToTerms = true; // 默认同意，符合用户体验
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
        _showErrorDialog('支付失败，请重试');
        break;
      case -2:
        // 用户取消支付
        getLogger().w('⚠️ 微信支付：用户取消支付');
        // 用户主动取消，通常不需要显示错误提示
        // 可以选择显示轻提示或者不处理
        BotToast.showText(text: "支付已取消");
        break;
      default:
        // 其他错误
        getLogger().e('❌ 微信支付：未知错误 - 错误码: ${response.errCode}, 错误信息: ${response.errStr}');
        _showErrorDialog('支付异常，请稍后重试');
        break;
    }
  }

  /// 处理购买请求
  Future<void> handlePurchase() async {
    // 检查是否同意协议
    if (!isAgreedToTerms) {
      _showErrorDialog('请先阅读并同意用户协议和隐私政策');
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
            _showErrorDialog('调起支付失败，请检查微信是否已安装');
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
        _showErrorDialog('创建支付订单失败，请稍后重试');
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
          String errorMessage = '支付失败';
          if (purchaseDetails.error != null) {
            switch (purchaseDetails.error!.code) {
              case 'purchase_canceled':
                errorMessage = '支付已取消';
                // 用户取消支付，使用轻提示
                BotToast.showText(text: errorMessage);
                break;
              case 'item_unavailable':
                errorMessage = '商品不可用，请稍后重试';
                _showErrorDialog(errorMessage);
                break;
              case 'network_error':
                errorMessage = '网络连接失败，请检查网络后重试';
                _showErrorDialog(errorMessage);
                break;
              default:
                errorMessage = '支付异常：${purchaseDetails.error!.message}';
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
          BotToast.showText(text: "支付已取消");
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
        String errorMessage = res["message"] ?? "支付验证失败，请联系客服";
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
      _showErrorDialog("支付验证异常，请联系客服处理");
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
                const Text(
                  '购买成功！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI助手已激活，可以开始使用了！',
                  style: TextStyle(
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
                    child: const Text(
                      '确定',
                      style: TextStyle(
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
                const Text(
                  '购买失败',
                  style: TextStyle(
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
                    child: const Text(
                      '确定',
                      style: TextStyle(
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

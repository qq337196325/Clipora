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



const Map<String, String> orderI18n = {
  // ai_order_page.dart
  'i18n_order_AI翻译请求包': 'AI Translation Request Package',
  'i18n_order_AI翻译助手': 'AI Translation Assistant',
  'i18n_order_让阅读更智能': 'Make reading smarter and learning more efficient',
  'i18n_order_通过AI翻译助手': 'With the AI Translation Assistant, you can translate articles into multiple languages.',
  'i18n_order_限时优惠': 'Limited Time Offer',
  'i18n_order_原价': 'Original Price ¥@price',
  'i18n_order_AI请求次数': '@count AI Requests',
  'i18n_order_足够深度阅读': 'Sufficient for a month of deep reading',
  'i18n_order_有效期': '@days-day Validity',
  'i18n_order_立即生效': 'Effective immediately after purchase, with ample time to experience',
  'i18n_order_智能强大': 'Intelligent and Powerful',
  'i18n_order_AI大模型翻译': 'Translate your content into multiple languages using large AI models',
  'i18n_order_核心功能': 'Core Features',
  'i18n_order_多国语言支持': 'Multilingual Support',
  'i18n_order_支持翻译和理解': 'Supports translation and multilingual understanding',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Buy Now @price',
  'i18n_order_购买前请阅读并同意': 'Please read and agree before purchasing',
  'i18n_order_购买协议': '《Purchase Agreement》',
  'i18n_order_payment_failed_retry': 'Payment failed, please try again',
  'i18n_order_payment_cancelled': 'Payment cancelled',
  'i18n_order_payment_error_retry_later': 'Payment error, please try again later',
  'i18n_order_please_agree_to_terms': 'Please read and agree to the user agreement and privacy policy first',
  'i18n_order_failed_to_initiate_payment': 'Failed to initiate payment, please check if WeChat is installed',
  'i18n_order_failed_to_create_order': 'Failed to create payment order, please try again later',
  'i18n_order_payment_failed': 'Payment Failed',
  'i18n_order_item_unavailable': 'Item unavailable, please try again later',
  'i18n_order_network_error': 'Network connection failed, please check your network and try again',
  'i18n_order_payment_exception': 'Payment exception: @message',
  'i18n_order_verification_failed_contact_support': 'Payment verification failed, please contact customer support',
  'i18n_order_verification_exception_contact_support': 'Payment verification exception, please contact customer support for assistance',
  'i18n_order_purchase_successful': 'Purchase Successful!',
  'i18n_order_ai_assistant_activated': 'AI assistant has been activated and is ready to use!',
  'i18n_order_confirm': 'Confirm',
  'i18n_order_purchase_failed': 'Purchase Failed',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Premium Membership',
  'i18n_member_Clipora高级版': 'Clipora Premium',
  'i18n_member_解锁全部功能潜力': 'Unlock Full Potential',
  'i18n_member_享受高级功能': 'Enjoy advanced features for more efficient reading and knowledge management',
  'i18n_member_限时买断': 'Limited Time Buyout',
  'i18n_member_一次性购买': 'One-time purchase, become a permanent member',
  'i18n_member_未来订阅计划': 'We plan to charge by annual and monthly subscriptions in the future. Currently, it is a limited-time one-time buyout.',
  'i18n_member_现有数据保证': 'For non-members, we guarantee that you can always use your existing data for free.',
  'i18n_member_终身更新': 'Supports future permanent free updates.',
  'i18n_member_无广告保证': 'Clipora guarantees to never add advertising business to ensure your user experience. The membership system is our only source of income.',
  'i18n_member_高级特权': 'Premium Features',
  'i18n_member_无限同步': 'Unlimited Sync',
  'i18n_member_无限同步描述': 'Unlimited synchronization of your data to the cloud',
  'i18n_member_无限存储': 'Unlimited Storage',
  'i18n_member_无限存储描述': 'Unlimited storage for your articles and notes',
  'i18n_member_高级功能': 'Advanced Features',
  'i18n_member_高级功能描述': 'Enjoy all advanced features and priority access',
  'i18n_member_优先支持': 'Priority Support',
  'i18n_member_优先支持描述': 'Enjoy priority customer support and technical assistance',
  'i18n_member_微信支付': 'WeChat Pay @price',
  'i18n_member_立即购买': 'Buy Now @price',
  'i18n_member_购买前请阅读并同意': 'Please read and agree before purchasing',
  'i18n_member_购买协议': '《Purchase Agreement》',
  'i18n_member_payment_failed_retry': 'Payment failed, please retry',
  'i18n_member_payment_cancelled': 'Payment cancelled',
  'i18n_member_payment_error_retry_later': 'Payment error, please try again later',
  'i18n_member_please_agree_to_terms': 'Please read and agree to the user agreement and privacy policy first',
  'i18n_member_failed_to_initiate_payment': 'Failed to initiate payment, please check if WeChat is installed',
  'i18n_member_failed_to_create_order': 'Failed to create payment order, please try again later',
  'i18n_member_payment_failed': 'Payment Failed',
  'i18n_member_item_unavailable': 'Item unavailable, please try again later',
  'i18n_member_network_error': 'Network connection failed, please check network and retry',
  'i18n_member_payment_exception': 'Payment exception: @message',
  'i18n_member_verification_failed_contact_support': 'Payment verification failed, please contact customer service',
  'i18n_member_verification_exception_contact_support': 'Payment verification exception, please contact customer service',
  'i18n_member_upgrade_successful': 'Upgrade Successful!',
  'i18n_member_premium_activated': 'Premium membership activated, enjoy all features!',
  'i18n_member_confirm': 'Confirm',
  'i18n_member_upgrade_failed': 'Upgrade Failed',
  'i18n_member_upgrade': 'Upgrade',
  'i18n_member_重要说明': 'Important Notice',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Lifetime Member',
  'i18n_member_订阅会员': 'Subscription Member',
  'i18n_member_会员已激活': 'Membership Activated',
  'i18n_member_到期时间': 'Expiry Time: @date',
  'i18n_member_续费': 'Renew',
  'i18n_member_感谢您的支持': 'Thank you for your support',
  'i18n_member_正在享受高级会员特权': 'Enjoying premium membership privileges',
  'i18n_member_永久访问权限': 'Permanent access rights',
};

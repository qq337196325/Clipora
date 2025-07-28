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
  'i18n_order_AI翻译请求包': 'AI翻譯請求包',
  'i18n_order_AI翻译助手': 'AI翻譯助手',
  'i18n_order_让阅读更智能': '讓閱讀更智能，讓學習更高效',
  'i18n_order_通过AI翻译助手': '通過AI翻譯助手，您可以將文章翻譯成多國語言。',
  'i18n_order_限时优惠': '限時優惠',
  'i18n_order_原价': '原價¥@price',
  'i18n_order_AI请求次数': '@count次AI請求',
  'i18n_order_足够深度阅读': '足夠一個月的深度閱讀使用',
  'i18n_order_有效期': '@days天有效期',
  'i18n_order_立即生效': '購買後立即生效，充足時間體驗',
  'i18n_order_智能强大': '智能強大',
  'i18n_order_AI大模型翻译': '利用AI大模型將您的內容翻譯成多國語言',
  'i18n_order_核心功能': '核心功能',
  'i18n_order_多国语言支持': '多國語言支援',
  'i18n_order_支持翻译和理解': '支援翻譯和多語言理解',
  'i18n_order_微信支付': '微信支付 @price',
  'i18n_order_立即购买': '立即購買 @price',
  'i18n_order_购买前请阅读并同意': '購買前請閱讀並同意',
  'i18n_order_购买协议': '《購買協議》',
  'i18n_order_payment_failed_retry': '支付失敗，請重試',
  'i18n_order_payment_cancelled': '支付已取消',
  'i18n_order_payment_error_retry_later': '支付異常，請稍後重試',
  'i18n_order_please_agree_to_terms': '請先閱讀並同意用戶協議和隱私政策',
  'i18n_order_failed_to_initiate_payment': '調起支付失敗，請檢查微信是否已安裝',
  'i18n_order_failed_to_create_order': '創建支付訂單失敗，請稍後重試',
  'i18n_order_payment_failed': '支付失敗',
  'i18n_order_item_unavailable': '商品不可用，請稍後重試',
  'i18n_order_network_error': '網絡連接失敗，請檢查網絡後重試',
  'i18n_order_payment_exception': '支付異常：@message',
  'i18n_order_verification_failed_contact_support': '支付驗證失敗，請聯繫客服',
  'i18n_order_verification_exception_contact_support': '支付驗證異常，請聯繫客服處理',
  'i18n_order_purchase_successful': '購買成功！',
  'i18n_order_ai_assistant_activated': 'AI助手已啟動，可以開始使用了！',
  'i18n_order_confirm': '確定',
  'i18n_order_purchase_failed': '購買失敗',
  
  // member_order_page.dart
  'i18n_member_高级会员': '高級會員',
  'i18n_member_Clipora高级版': 'Clipora 高級版',
  'i18n_member_解锁全部功能潜力': '解鎖全部功能潛力',
  'i18n_member_享受高级功能': '享受高級功能，讓您的閱讀和知識管理更高效',
  'i18n_member_限时买断': '限時買斷',
  'i18n_member_一次性购买': '一次性購買，成為永久會員',
  'i18n_member_未来订阅计划': '我們未來計劃按年、月訂閱付費，目前限時一次性買斷。',
  'i18n_member_现有数据保证': '非會員我們保證已有的數據，您都可以一直免費使用。',
  'i18n_member_终身更新': '支援未來永久免費更新。',
  'i18n_member_无广告保证': 'Clipora保證永不加入廣告業務，保證您的使用體驗，會員制是我們的唯一收入來源。',
  'i18n_member_高级特权': '高級特權',
  'i18n_member_无限同步': '無限同步',
  'i18n_member_无限同步描述': '無限制同步您的數據到雲端',
  'i18n_member_无限存储': '無限存儲',
  'i18n_member_无限存储描述': '無限量存儲您的文章和筆記',
  'i18n_member_高级功能': '高級功能',
  'i18n_member_高级功能描述': '享受所有高級功能和優先體驗',
  'i18n_member_优先支持': '優先支援',
  'i18n_member_优先支持描述': '享受優先客服支援和技術援助',
  'i18n_member_微信支付': '微信支付 @price',
  'i18n_member_立即购买': '立即購買 @price',
  'i18n_member_购买前请阅读并同意': '購買前請閱讀並同意',
  'i18n_member_购买协议': '《購買協議》',
  'i18n_member_payment_failed_retry': '支付失敗，請重試',
  'i18n_member_payment_cancelled': '支付已取消',
  'i18n_member_payment_error_retry_later': '支付異常，請稍後重試',
  'i18n_member_please_agree_to_terms': '請先閱讀並同意用戶協議和隱私政策',
  'i18n_member_failed_to_initiate_payment': '調起支付失敗，請檢查微信是否已安裝',
  'i18n_member_failed_to_create_order': '創建支付訂單失敗，請稍後重試',
  'i18n_member_payment_failed': '支付失敗',
  'i18n_member_item_unavailable': '商品不可用，請稍後重試',
  'i18n_member_network_error': '網絡連接失敗，請檢查網絡後重試',
  'i18n_member_payment_exception': '支付異常：@message',
  'i18n_member_verification_failed_contact_support': '支付驗證失敗，請聯繫客服',
  'i18n_member_verification_exception_contact_support': '支付驗證異常，請聯繫客服處理',
  'i18n_member_upgrade_successful': '升級成功！',
  'i18n_member_premium_activated': '高級會員已啟動，享受全部功能！',
  'i18n_member_confirm': '確定',
  'i18n_member_upgrade_failed': '升級失敗',
  'i18n_member_upgrade': '升級',
  'i18n_member_重要说明': '重要說明',
  
  // 會員狀態顯示
  'i18n_member_终身会员': '終身會員',
  'i18n_member_订阅会员': '訂閱會員',
  'i18n_member_会员已激活': '會員已啟動',
  'i18n_member_到期时间': '到期時間：@date',
  'i18n_member_续费': '續費',
  'i18n_member_感谢您的支持': '感謝您的支持',
  'i18n_member_正在享受高级会员特权': '正在享受高級會員特權',
  'i18n_member_永久访问权限': '永久訪問權限',
};
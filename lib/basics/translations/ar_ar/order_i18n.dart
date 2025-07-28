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
  'i18n_order_AI翻译请求包': 'حزمة طلبات الترجمة بالذكاء الاصطناعي',
  'i18n_order_AI翻译助手': 'مساعد الترجمة بالذكاء الاصطناعي',
  'i18n_order_让阅读更智能': 'لجعل القراءة أذكى والتعلم أكثر كفاءة',
  'i18n_order_通过AI翻译助手': 'باستخدام مساعد الترجمة بالذكاء الاصطناعي، يمكنك ترجمة المقالات إلى لغات متعددة.',
  'i18n_order_限时优惠': 'عرض محدود الوقت',
  'i18n_order_原价': 'السعر الأصلي ¥@price',
  'i18n_order_AI请求次数': '@count طلبات ذكاء اصطناعي',
  'i18n_order_足够深度阅读': 'كافية للاستخدام في القراءة المعمقة لمدة شهر',
  'i18n_order_有效期': 'صالحة لمدة @days يوم',
  'i18n_order_立即生效': 'فعال فوراً بعد الشراء، وقت كافٍ للتجربة',
  'i18n_order_智能强大': 'ذكي وقوي',
  'i18n_order_AI大模型翻译': 'ترجم محتواك إلى عدة لغات باستخدام نماذج الذكاء الاصطناعي الكبيرة',
  'i18n_order_核心功能': 'الميزات الأساسية',
  'i18n_order_多国语言支持': 'دعم متعدد اللغات',
  'i18n_order_支持翻译和理解': 'دعم الترجمة والفهم متعدد اللغات',
  'i18n_order_微信支付': 'دفع WeChat @price',
  'i18n_order_立即购买': 'اشتر الآن @price',
  'i18n_order_购买前请阅读并同意': 'يرجى القراءة والموافقة قبل الشراء',
  'i18n_order_购买协议': '《اتفاقية الشراء》',
  'i18n_order_payment_failed_retry': 'فشل الدفع، يرجى المحاولة مرة أخرى',
  'i18n_order_payment_cancelled': 'تم إلغاء الدفع',
  'i18n_order_payment_error_retry_later': 'خطأ في الدفع، يرجى المحاولة لاحقاً',
  'i18n_order_please_agree_to_terms': 'يرجى قراءة والموافقة على شروط الاستخدام وسياسة الخصوصية أولاً',
  'i18n_order_failed_to_initiate_payment': 'فشل في بدء الدفع، يرجى التحقق من تثبيت WeChat',
  'i18n_order_failed_to_create_order': 'فشل في إنشاء طلب الدفع، يرجى المحاولة لاحقاً',
  'i18n_order_payment_failed': 'فشل الدفع',
  'i18n_order_item_unavailable': 'العنصر غير متاح، يرجى المحاولة لاحقاً',
  'i18n_order_network_error': 'فشل الاتصال بالشبكة، يرجى التحقق من الشبكة والمحاولة مرة أخرى',
  'i18n_order_payment_exception': 'استثناء الدفع: @message',
  'i18n_order_verification_failed_contact_support': 'فشل التحقق من الدفع، يرجى الاتصال بدعم العملاء',
  'i18n_order_verification_exception_contact_support': 'استثناء التحقق من الدفع، يرجى الاتصال بدعم العملاء',
  'i18n_order_purchase_successful': 'نجح الشراء!',
  'i18n_order_ai_assistant_activated': 'تم تفعيل مساعد الذكاء الاصطناعي وهو جاهز للاستخدام!',
  'i18n_order_confirm': 'تأكيد',
  'i18n_order_purchase_failed': 'فشل الشراء',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'عضوية متقدمة',
  'i18n_member_Clipora高级版': 'Clipora الإصدار المتقدم',
  'i18n_member_解锁全部功能潜力': 'فتح إمكانات جميع الوظائف',
  'i18n_member_享受高级功能': 'استمتع بالوظائف المتقدمة، واجعل قراءتك وإدارة المعرفة أكثر كفاءة',
  'i18n_member_限时买断': 'شراء محدود الوقت',
  'i18n_member_一次性购买': 'شراء لمرة واحدة، كن عضواً دائماً',
  'i18n_member_未来订阅计划': 'نحن نخطط للفوترة عن طريق الاشتراكات السنوية والشهرية في المستقبل. حاليًا، هو شراء لمرة واحدة لفترة محدودة.',
  'i18n_member_现有数据保证': 'لغير الأعضاء، نضمن أنه يمكنك دائمًا استخدام بياناتك الحالية مجانًا.',
  'i18n_member_终身更新': 'يدعم التحديثات المجانية الدائمة في المستقبل.',
  'i18n_member_无广告保证': 'تضمن Clipora عدم إضافة أعمال إعلانية أبدًا لضمان تجربة المستخدم الخاصة بك. نظام العضوية هو مصدر دخلنا الوحيد.',
  'i18n_member_高级特权': 'امتيازات متقدمة',
  'i18n_member_无限同步': 'مزامنة غير محدودة',
  'i18n_member_无限同步描述': 'مزامنة بياناتك إلى السحابة بلا حدود',
  'i18n_member_无限存储': 'تخزين غير محدود',
  'i18n_member_无限存储描述': 'تخزين مقالاتك وملاحظاتك بلا حدود',
  'i18n_member_高级功能': 'وظائف متقدمة',
  'i18n_member_高级功能描述': 'استمتع بجميع الوظائف المتقدمة والتجربة المسبقة',
  'i18n_member_优先支持': 'دعم أولوي',
  'i18n_member_优先支持描述': 'استمتع بدعم العملاء الأولوي والمساعدة التقنية',
  'i18n_member_微信支付': 'دفع WeChat @price',
  'i18n_member_立即购买': 'اشتر الآن @price',
  'i18n_member_购买前请阅读并同意': 'يرجى القراءة والموافقة قبل الشراء',
  'i18n_member_购买协议': '《اتفاقية الشراء》',
  'i18n_member_payment_failed_retry': 'فشل الدفع، يرجى المحاولة مرة أخرى',
  'i18n_member_payment_cancelled': 'تم إلغاء الدفع',
  'i18n_member_payment_error_retry_later': 'خطأ في الدفع، يرجى المحاولة لاحقاً',
  'i18n_member_please_agree_to_terms': 'يرجى قراءة والموافقة على شروط الاستخدام وسياسة الخصوصية أولاً',
  'i18n_member_failed_to_initiate_payment': 'فشل في بدء الدفع، يرجى التحقق من تثبيت WeChat',
  'i18n_member_failed_to_create_order': 'فشل في إنشاء طلب الدفع، يرجى المحاولة لاحقاً',
  'i18n_member_payment_failed': 'فشل الدفع',
  'i18n_member_item_unavailable': 'العنصر غير متاح، يرجى المحاولة لاحقاً',
  'i18n_member_network_error': 'فشل الاتصال بالشبكة، يرجى التحقق من الشبكة والمحاولة مرة أخرى',
  'i18n_member_payment_exception': 'استثناء الدفع: @message',
  'i18n_member_verification_failed_contact_support': 'فشل التحقق من الدفع، يرجى الاتصال بدعم العملاء',
  'i18n_member_verification_exception_contact_support': 'استثناء التحقق من الدفع، يرجى الاتصال بدعم العملاء',
  'i18n_member_upgrade_successful': 'نجح الترقية!',
  'i18n_member_premium_activated': 'تم تفعيل العضوية المتقدمة، استمتع بجميع الوظائف!',
  'i18n_member_confirm': 'تأكيد',
  'i18n_member_upgrade_failed': 'فشل الترقية',
  'i18n_member_upgrade': 'ترقية',
  'i18n_member_重要说明': 'ملاحظة مهمة',
  
  // 会员状态显示
  'i18n_member_终身会员': 'عضو مدى الحياة',
  'i18n_member_订阅会员': 'عضو مشترك',
  'i18n_member_会员已激活': 'تم تفعيل العضوية',
  'i18n_member_到期时间': 'وقت انتهاء الصلاحية: @date',
  'i18n_member_续费': 'تجديد',
  'i18n_member_感谢您的支持': 'شكراً لدعمكم',
  'i18n_member_正在享受高级会员特权': 'تستمتع بامتيازات العضوية المتقدمة',
  'i18n_member_永久访问权限': 'حقوق الوصول الدائمة',
};
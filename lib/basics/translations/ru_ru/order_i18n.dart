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
  'i18n_order_AI翻译请求包': 'Пакет запросов ИИ-перевода',
  'i18n_order_AI翻译助手': 'Помощник ИИ-перевода',
  'i18n_order_让阅读更智能': 'Сделать чтение умнее, обучение эффективнее',
  'i18n_order_通过AI翻译助手': 'С помощью помощника ИИ-перевода вы можете переводить статьи на несколько языков.',
  'i18n_order_限时优惠': 'Ограниченное по времени предложение',
  'i18n_order_原价': 'Первоначальная цена ¥@price',
  'i18n_order_AI请求次数': '@count запросов ИИ',
  'i18n_order_足够深度阅读': 'Достаточно для месяца глубокого чтения',
  'i18n_order_有效期': '@days дней действия',
  'i18n_order_立即生效': 'Действует сразу после покупки, достаточно времени для опыта',
  'i18n_order_智能强大': 'Умный и мощный',
  'i18n_order_AI大模型翻译': 'Переводите ваш контент на несколько языков с помощью больших ИИ-моделей',
  'i18n_order_核心功能': 'Основные функции',
  'i18n_order_多国语言支持': 'Многоязычная поддержка',
  'i18n_order_支持翻译和理解': 'Поддержка перевода и многоязычного понимания',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Купить сейчас @price',
  'i18n_order_购买前请阅读并同意': 'Пожалуйста, прочитайте и согласитесь перед покупкой',
  'i18n_order_购买协议': '《Договор покупки》',
  'i18n_order_payment_failed_retry': 'Платеж не удался, пожалуйста, попробуйте снова',
  'i18n_order_payment_cancelled': 'Платеж отменен',
  'i18n_order_payment_error_retry_later': 'Ошибка платежа, пожалуйста, попробуйте позже',
  'i18n_order_please_agree_to_terms': 'Пожалуйста, сначала прочитайте и согласитесь с условиями использования и политикой конфиденциальности',
  'i18n_order_failed_to_initiate_payment': 'Не удалось инициировать платеж, пожалуйста, проверьте, установлен ли WeChat',
  'i18n_order_failed_to_create_order': 'Не удалось создать заказ на оплату, пожалуйста, попробуйте позже',
  'i18n_order_payment_failed': 'Платеж не удался',
  'i18n_order_item_unavailable': 'Товар недоступен, пожалуйста, попробуйте позже',
  'i18n_order_network_error': 'Ошибка сетевого соединения, пожалуйста, проверьте сеть и попробуйте снова',
  'i18n_order_payment_exception': 'Исключение платежа: @message',
  'i18n_order_verification_failed_contact_support': 'Проверка платежа не удалась, пожалуйста, обратитесь в службу поддержки',
  'i18n_order_verification_exception_contact_support': 'Исключение проверки платежа, пожалуйста, обратитесь в службу поддержки',
  'i18n_order_purchase_successful': 'Покупка успешна!',
  'i18n_order_ai_assistant_activated': 'ИИ-помощник активирован и готов к использованию!',
  'i18n_order_confirm': 'Подтвердить',
  'i18n_order_purchase_failed': 'Покупка не удалась',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Премиум-членство',
  'i18n_member_Clipora高级版': 'Clipora Премиум',
  'i18n_member_解锁全部功能潜力': 'Разблокировать весь потенциал функций',
  'i18n_member_享受高级功能': 'Наслаждайтесь расширенными функциями для более эффективного чтения и управления знаниями',
  'i18n_member_限时买断': 'Ограниченная по времени единовременная покупка',
  'i18n_member_一次性购买': 'Единовременная покупка, станьте постоянным членом',
  'i18n_member_未来订阅计划': 'Мы планируем взимать плату за годовые и месячные подписки в будущем. В настоящее время это единовременная покупка на ограниченный срок.',
  'i18n_member_现有数据保证': 'Для не-членов мы гарантируем, что вы всегда можете использовать свои существующие данные бесплатно.',
  'i18n_member_终身更新': 'Поддерживает будущие постоянные бесплатные обновления.',
  'i18n_member_无广告保证': 'Clipora гарантирует, что никогда не будет добавлять рекламный бизнес, чтобы обеспечить ваш пользовательский опыт. Система членства - наш единственный источник дохода.',
  'i18n_member_高级特权': 'Премиум-привилегии',
  'i18n_member_无限同步': 'Неограниченная синхронизация',
  'i18n_member_无限同步描述': 'Неограниченная синхронизация ваших данных в облако',
  'i18n_member_无限存储': 'Неограниченное хранилище',
  'i18n_member_无限存储描述': 'Неограниченное хранение ваших статей и заметок',
  'i18n_member_高级功能': 'Расширенные функции',
  'i18n_member_高级功能描述': 'Наслаждайтесь всеми расширенными функциями и приоритетным доступом',
  'i18n_member_优先支持': 'Приоритетная поддержка',
  'i18n_member_优先支持描述': 'Наслаждайтесь приоритетной поддержкой клиентов и технической помощью',
  'i18n_member_微信支付': 'WeChat Pay @price',
  'i18n_member_立即购买': 'Купить сейчас @price',
  'i18n_member_购买前请阅读并同意': 'Пожалуйста, прочитайте и согласитесь перед покупкой',
  'i18n_member_购买协议': '《Договор покупки》',
  'i18n_member_payment_failed_retry': 'Платеж не удался, пожалуйста, попробуйте снова',
  'i18n_member_payment_cancelled': 'Платеж отменен',
  'i18n_member_payment_error_retry_later': 'Ошибка платежа, пожалуйста, попробуйте позже',
  'i18n_member_please_agree_to_terms': 'Пожалуйста, сначала прочитайте и согласитесь с условиями использования и политикой конфиденциальности',
  'i18n_member_failed_to_initiate_payment': 'Не удалось инициировать платеж, пожалуйста, проверьте, установлен ли WeChat',
  'i18n_member_failed_to_create_order': 'Не удалось создать заказ на оплату, пожалуйста, попробуйте позже',
  'i18n_member_payment_failed': 'Платеж не удался',
  'i18n_member_item_unavailable': 'Товар недоступен, пожалуйста, попробуйте позже',
  'i18n_member_network_error': 'Ошибка сетевого соединения, пожалуйста, проверьте сеть и попробуйте снова',
  'i18n_member_payment_exception': 'Исключение платежа: @message',
  'i18n_member_verification_failed_contact_support': 'Проверка платежа не удалась, пожалуйста, обратитесь в службу поддержки',
  'i18n_member_verification_exception_contact_support': 'Исключение проверки платежа, пожалуйста, обратитесь в службу поддержки',
  'i18n_member_upgrade_successful': 'Обновление успешно!',
  'i18n_member_premium_activated': 'Премиум-членство активировано, наслаждайтесь всеми функциями!',
  'i18n_member_confirm': 'Подтвердить',
  'i18n_member_upgrade_failed': 'Обновление не удалось',
  'i18n_member_upgrade': 'Обновить',
  'i18n_member_重要说明': 'Важное уведомление',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Пожизненный член',
  'i18n_member_订阅会员': 'Подписчик',
  'i18n_member_会员已激活': 'Членство активировано',
  'i18n_member_到期时间': 'Время истечения: @date',
  'i18n_member_续费': 'Продлить',
  'i18n_member_感谢您的支持': 'Спасибо за вашу поддержку',
  'i18n_member_正在享受高级会员特权': 'Наслаждаетесь привилегиями премиум-членства',
  'i18n_member_永久访问权限': 'Постоянные права доступа',
};
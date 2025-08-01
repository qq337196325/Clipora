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
  'i18n_order_AI翻译请求包': 'AI-vertaalverzoekpakket',
  'i18n_order_AI翻译助手': 'AI-vertaalassistent',
  'i18n_order_让阅读更智能': 'Lezen slimmer maken, leren efficiënter maken',
  'i18n_order_通过AI翻译助手': 'Met de AI-vertaalassistent kunt u artikelen naar meerdere talen vertalen.',
  'i18n_order_限时优惠': 'Beperkte tijdaanbieding',
  'i18n_order_原价': 'Oorspronkelijke prijs ¥@price',
  'i18n_order_AI请求次数': '@count AI-verzoeken',
  'i18n_order_足够深度阅读': 'Genoeg voor een maand diep lezen',
  'i18n_order_有效期': '@days dagen geldigheid',
  'i18n_order_立即生效': 'Onmiddellijk effectief na aankoop, voldoende tijd om te ervaren',
  'i18n_order_智能强大': 'Intelligent en krachtig',
  'i18n_order_AI大模型翻译': 'Vertaal uw inhoud naar meerdere talen met grote AI-modellen',
  'i18n_order_核心功能': 'Kernfuncties',
  'i18n_order_多国语言支持': 'Meertalige ondersteuning',
  'i18n_order_支持翻译和理解': 'Ondersteuning voor vertaling en meertalig begrip',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Nu kopen @price',
  'i18n_order_购买前请阅读并同意': 'Lees en ga akkoord voor aankoop',
  'i18n_order_购买协议': '《Koopovereenkomst》',
  'i18n_order_payment_failed_retry': 'Betaling mislukt, probeer opnieuw',
  'i18n_order_payment_cancelled': 'Betaling geannuleerd',
  'i18n_order_payment_error_retry_later': 'Betalingsfout, probeer later opnieuw',
  'i18n_order_please_agree_to_terms': 'Lees en ga eerst akkoord met de gebruiksvoorwaarden en privacybeleid',
  'i18n_order_failed_to_initiate_payment': 'Betaling starten mislukt, controleer of WeChat is geïnstalleerd',
  'i18n_order_failed_to_create_order': 'Betalingsorder maken mislukt, probeer later opnieuw',
  'i18n_order_payment_failed': 'Betaling mislukt',
  'i18n_order_item_unavailable': 'Item niet beschikbaar, probeer later opnieuw',
  'i18n_order_network_error': 'Netwerkverbinding mislukt, controleer uw netwerk en probeer opnieuw',
  'i18n_order_payment_exception': 'Betalingsuitzondering: @message',
  'i18n_order_verification_failed_contact_support': 'Betalingsverificatie mislukt, neem contact op met klantenservice',
  'i18n_order_verification_exception_contact_support': 'Betalingsverificatie-uitzondering, neem contact op met klantenservice',
  'i18n_order_purchase_successful': 'Aankoop succesvol!',
  'i18n_order_ai_assistant_activated': 'AI-assistent is geactiveerd en klaar voor gebruik!',
  'i18n_order_confirm': 'Bevestigen',
  'i18n_order_purchase_failed': 'Aankoop mislukt',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Premium Lidmaatschap',
  'i18n_member_Clipora高级版': 'Clipora Premium',
  'i18n_member_解锁全部功能潜力': 'Ontgrendel het volledige functiepotentieel',
  'i18n_member_享受高级功能': 'Geniet van geavanceerde functies voor efficiënter lezen en kennisbeheer',
  'i18n_member_限时买断': 'Beperkte tijd eenmalige aankoop',
  'i18n_member_一次性购买': 'Eenmalige aankoop, word permanent lid',
  'i18n_member_未来订阅计划': 'We zijn van plan om in de toekomst jaarlijkse en maandelijkse abonnementen aan te bieden. Momenteel is het een eenmalige aankoop voor beperkte tijd.',
  'i18n_member_现有数据保证': 'Voor niet-leden garanderen we dat u uw bestaande gegevens altijd gratis kunt gebruiken.',
  'i18n_member_终身更新': 'Ondersteunt toekomstige permanente gratis updates.',
  'i18n_member_无广告保证': 'Clipora garandeert dat er nooit reclameactiviteiten worden toegevoegd om uw gebruikerservaring te waarborgen. Het lidmaatschapssysteem is onze enige bron van inkomsten.',
  'i18n_member_高级特权': 'Premium Privileges',
  'i18n_member_无限同步': 'Onbeperkte Synchronisatie',
  'i18n_member_无限同步描述': 'Onbeperkte synchronisatie van uw gegevens naar de cloud',
  'i18n_member_无限存储': 'Onbeperkte Opslag',
  'i18n_member_无限存储描述': 'Onbeperkte opslag voor uw artikelen en notities',
  'i18n_member_高级功能': 'Geavanceerde Functies',
  'i18n_member_高级功能描述': 'Geniet van alle geavanceerde functies en prioritaire toegang',
  'i18n_member_优先支持': 'Prioritaire Ondersteuning',
  'i18n_member_优先支持描述': 'Geniet van prioritaire klantenservice en technische ondersteuning',
  'i18n_member_微信支付': 'WeChat Pay @price',
  'i18n_member_立即购买': 'Nu kopen @price',
  'i18n_member_购买前请阅读并同意': 'Lees en ga akkoord voor aankoop',
  'i18n_member_购买协议': '《Koopovereenkomst》',
  'i18n_member_payment_failed_retry': 'Betaling mislukt, probeer opnieuw',
  'i18n_member_payment_cancelled': 'Betaling geannuleerd',
  'i18n_member_payment_error_retry_later': 'Betalingsfout, probeer later opnieuw',
  'i18n_member_please_agree_to_terms': 'Lees en ga eerst akkoord met de gebruiksvoorwaarden en privacybeleid',
  'i18n_member_failed_to_initiate_payment': 'Betaling starten mislukt, controleer of WeChat is geïnstalleerd',
  'i18n_member_failed_to_create_order': 'Betalingsorder maken mislukt, probeer later opnieuw',
  'i18n_member_payment_failed': 'Betaling mislukt',
  'i18n_member_item_unavailable': 'Item niet beschikbaar, probeer later opnieuw',
  'i18n_member_network_error': 'Netwerkverbinding mislukt, controleer uw netwerk en probeer opnieuw',
  'i18n_member_payment_exception': 'Betalingsuitzondering: @message',
  'i18n_member_verification_failed_contact_support': 'Betalingsverificatie mislukt, neem contact op met klantenservice',
  'i18n_member_verification_exception_contact_support': 'Betalingsverificatie-uitzondering, neem contact op met klantenservice',
  'i18n_member_upgrade_successful': 'Upgrade succesvol!',
  'i18n_member_premium_activated': 'Premium lidmaatschap geactiveerd, geniet van alle functies!',
  'i18n_member_confirm': 'Bevestigen',
  'i18n_member_upgrade_failed': 'Upgrade mislukt',
  'i18n_member_upgrade': 'Upgraden',
  'i18n_member_重要说明': 'Belangrijke Mededeling',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Levenslang Lid',
  'i18n_member_订阅会员': 'Abonnement Lid',
  'i18n_member_会员已激活': 'Lidmaatschap Geactiveerd',
  'i18n_member_到期时间': 'Vervaltijd: @date',
  'i18n_member_续费': 'Verlengen',
  'i18n_member_感谢您的支持': 'Dank voor uw steun',
  'i18n_member_正在享受高级会员特权': 'Genietend van premium lidmaatschapsprivileges',
  'i18n_member_永久访问权限': 'Permanente toegangsrechten',
};
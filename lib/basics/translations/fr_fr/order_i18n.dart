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
  'i18n_order_AI翻译请求包': 'Package de demandes de traduction IA',
  'i18n_order_AI翻译助手': 'Assistant de traduction IA',
  'i18n_order_让阅读更智能': 'Rendre la lecture plus intelligente, l\'apprentissage plus efficace',
  'i18n_order_通过AI翻译助手': 'Avec l\'assistant de traduction IA, vous pouvez traduire des articles en plusieurs langues.',
  'i18n_order_限时优惠': 'Offre limitée',
  'i18n_order_原价': 'Prix original ¥@price',
  'i18n_order_AI请求次数': '@count demandes IA',
  'i18n_order_足够深度阅读': 'Suffisant pour un mois de lecture approfondie',
  'i18n_order_有效期': '@days jours de validité',
  'i18n_order_立即生效': 'Effectif immédiatement après l\'achat, temps d\'expérience suffisant',
  'i18n_order_智能强大': 'Intelligent et puissant',
  'i18n_order_AI大模型翻译': 'Traduire votre contenu en plusieurs langues avec des modèles IA avancés',
  'i18n_order_核心功能': 'Fonctionnalités principales',
  'i18n_order_多国语言支持': 'Support multilingue',
  'i18n_order_支持翻译和理解': 'Support de traduction et compréhension multilingue',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Acheter maintenant @price',
  'i18n_order_购买前请阅读并同意': 'Veuillez lire et accepter avant l\'achat',
  'i18n_order_购买协议': '《Contrat d\'achat》',
  'i18n_order_payment_failed_retry': 'Échec du paiement, veuillez réessayer',
  'i18n_order_payment_cancelled': 'Paiement annulé',
  'i18n_order_payment_error_retry_later': 'Erreur de paiement, veuillez réessayer plus tard',
  'i18n_order_please_agree_to_terms': 'Veuillez d\'abord lire et accepter les conditions d\'utilisation et la politique de confidentialité',
  'i18n_order_failed_to_initiate_payment': 'Échec du lancement du paiement, veuillez vérifier si WeChat est installé',
  'i18n_order_failed_to_create_order': 'Échec de la création de la commande, veuillez réessayer plus tard',
  'i18n_order_payment_failed': 'Échec du paiement',
  'i18n_order_item_unavailable': 'Article indisponible, veuillez réessayer plus tard',
  'i18n_order_network_error': 'Échec de la connexion réseau, veuillez vérifier votre réseau et réessayer',
  'i18n_order_payment_exception': 'Exception de paiement : @message',
  'i18n_order_verification_failed_contact_support': 'Échec de la vérification du paiement, veuillez contacter le support client',
  'i18n_order_verification_exception_contact_support': 'Exception de vérification du paiement, veuillez contacter le support client',
  'i18n_order_purchase_successful': 'Achat réussi !',
  'i18n_order_ai_assistant_activated': 'Assistant IA activé, vous pouvez commencer à l\'utiliser !',
  'i18n_order_confirm': 'Confirmer',
  'i18n_order_purchase_failed': 'Échec de l\'achat',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Adhésion Premium',
  'i18n_member_Clipora高级版': 'Clipora Premium',
  'i18n_member_解锁全部功能潜力': 'Débloquer tout le potentiel des fonctionnalités',
  'i18n_member_享受高级功能': 'Profitez de fonctionnalités avancées pour une lecture et une gestion des connaissances plus efficaces',
  'i18n_member_限时买断': 'Achat unique à durée limitée',
  'i18n_member_一次性购买': 'Achat unique, devenez membre permanent',
  'i18n_member_未来订阅计划': 'Nous prévoyons de facturer par abonnements annuels et mensuels à l\'avenir. Actuellement, il s\'agit d\'un achat unique à durée limitée.',
  'i18n_member_现有数据保证': 'Pour les non-membres, nous garantissons que vous pouvez toujours utiliser vos données existantes gratuitement.',
  'i18n_member_终身更新': 'Prend en charge les futures mises à jour gratuites permanentes.',
  'i18n_member_无广告保证': 'Clipora garantit de ne jamais ajouter d\'activités publicitaires pour assurer votre expérience utilisateur. Le système d\'adhésion est notre seule source de revenus.',
  'i18n_member_高级特权': 'Privilèges Premium',
  'i18n_member_无限同步': 'Synchronisation Illimitée',
  'i18n_member_无限同步描述': 'Synchronisation illimitée de vos données vers le cloud',
  'i18n_member_无限存储': 'Stockage Illimité',
  'i18n_member_无限存储描述': 'Stockage illimité pour vos articles et notes',
  'i18n_member_高级功能': 'Fonctionnalités Avancées',
  'i18n_member_高级功能描述': 'Profitez de toutes les fonctionnalités avancées et de l\'accès prioritaire',
  'i18n_member_优先支持': 'Support Prioritaire',
  'i18n_member_优先支持描述': 'Profitez du support client prioritaire et de l\'assistance technique',
  'i18n_member_微信支付': 'WeChat Pay @price',
  'i18n_member_立即购买': 'Acheter maintenant @price',
  'i18n_member_购买前请阅读并同意': 'Veuillez lire et accepter avant l\'achat',
  'i18n_member_购买协议': '《Contrat d\'achat》',
  'i18n_member_payment_failed_retry': 'Échec du paiement, veuillez réessayer',
  'i18n_member_payment_cancelled': 'Paiement annulé',
  'i18n_member_payment_error_retry_later': 'Erreur de paiement, veuillez réessayer plus tard',
  'i18n_member_please_agree_to_terms': 'Veuillez d\'abord lire et accepter les conditions d\'utilisation et la politique de confidentialité',
  'i18n_member_failed_to_initiate_payment': 'Échec du lancement du paiement, veuillez vérifier si WeChat est installé',
  'i18n_member_failed_to_create_order': 'Échec de la création de la commande, veuillez réessayer plus tard',
  'i18n_member_payment_failed': 'Échec du paiement',
  'i18n_member_item_unavailable': 'Article indisponible, veuillez réessayer plus tard',
  'i18n_member_network_error': 'Échec de la connexion réseau, veuillez vérifier votre réseau et réessayer',
  'i18n_member_payment_exception': 'Exception de paiement : @message',
  'i18n_member_verification_failed_contact_support': 'Échec de la vérification du paiement, veuillez contacter le support client',
  'i18n_member_verification_exception_contact_support': 'Exception de vérification du paiement, veuillez contacter le support client',
  'i18n_member_upgrade_successful': 'Mise à niveau réussie !',
  'i18n_member_premium_activated': 'Adhésion premium activée, profitez de toutes les fonctionnalités !',
  'i18n_member_confirm': 'Confirmer',
  'i18n_member_upgrade_failed': 'Échec de la mise à niveau',
  'i18n_member_upgrade': 'Mettre à niveau',
  'i18n_member_重要说明': 'Avis Important',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Membre à Vie',
  'i18n_member_订阅会员': 'Membre Abonné',
  'i18n_member_会员已激活': 'Adhésion Activée',
  'i18n_member_到期时间': 'Date d\'expiration : @date',
  'i18n_member_续费': 'Renouveler',
  'i18n_member_感谢您的支持': 'Merci pour votre soutien',
  'i18n_member_正在享受高级会员特权': 'Profitant des privilèges d\'adhésion premium',
  'i18n_member_永久访问权限': 'Droits d\'accès permanents',
};
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
  'i18n_order_AI翻译请求包': 'Pacote de solicitações de tradução IA',
  'i18n_order_AI翻译助手': 'Assistente de tradução IA',
  'i18n_order_让阅读更智能': 'Tornar a leitura mais inteligente, a aprendizagem mais eficiente',
  'i18n_order_通过AI翻译助手': 'Com o assistente de tradução IA, você pode traduzir artigos para vários idiomas.',
  'i18n_order_限时优惠': 'Oferta por tempo limitado',
  'i18n_order_原价': 'Preço original ¥@price',
  'i18n_order_AI请求次数': '@count solicitações IA',
  'i18n_order_足够深度阅读': 'Suficiente para um mês de leitura profunda',
  'i18n_order_有效期': '@days dias de validade',
  'i18n_order_立即生效': 'Efetivo imediatamente após a compra, tempo suficiente para experiência',
  'i18n_order_智能强大': 'Inteligente e poderoso',
  'i18n_order_AI大模型翻译': 'Traduza seu conteúdo para vários idiomas usando grandes modelos IA',
  'i18n_order_核心功能': 'Recursos principais',
  'i18n_order_多国语言支持': 'Suporte multilíngue',
  'i18n_order_支持翻译和理解': 'Suporte para tradução e compreensão multilíngue',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Comprar agora @price',
  'i18n_order_购买前请阅读并同意': 'Por favor, leia e concorde antes de comprar',
  'i18n_order_购买协议': '《Acordo de compra》',
  'i18n_order_payment_failed_retry': 'Pagamento falhou, tente novamente',
  'i18n_order_payment_cancelled': 'Pagamento cancelado',
  'i18n_order_payment_error_retry_later': 'Erro no pagamento, tente novamente mais tarde',
  'i18n_order_please_agree_to_terms': 'Por favor, leia e concorde primeiro com os termos de uso e política de privacidade',
  'i18n_order_failed_to_initiate_payment': 'Falha ao iniciar pagamento, verifique se o WeChat está instalado',
  'i18n_order_failed_to_create_order': 'Falha ao criar pedido de pagamento, tente novamente mais tarde',
  'i18n_order_payment_failed': 'Pagamento falhou',
  'i18n_order_item_unavailable': 'Item indisponível, tente novamente mais tarde',
  'i18n_order_network_error': 'Falha na conexão de rede, verifique sua rede e tente novamente',
  'i18n_order_payment_exception': 'Exceção de pagamento: @message',
  'i18n_order_verification_failed_contact_support': 'Falha na verificação do pagamento, entre em contato com o suporte',
  'i18n_order_verification_exception_contact_support': 'Exceção na verificação do pagamento, entre em contato com o suporte',
  'i18n_order_purchase_successful': 'Compra bem-sucedida!',
  'i18n_order_ai_assistant_activated': 'Assistente IA foi ativado e está pronto para uso!',
  'i18n_order_confirm': 'Confirmar',
  'i18n_order_purchase_failed': 'Compra falhou',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Membro Premium',
  'i18n_member_Clipora高级版': 'Clipora Premium',
  'i18n_member_解锁全部功能潜力': 'Desbloqueie todo o potencial das funcionalidades',
  'i18n_member_享受高级功能': 'Desfrute de recursos avançados para leitura e gestão de conhecimento mais eficientes',
  'i18n_member_限时买断': 'Compra única por tempo limitado',
  'i18n_member_一次性购买': 'Compra única, torne-se membro permanente',
  'i18n_member_未来订阅计划': 'Planejamos cobrar por assinaturas anuais e mensais no futuro. Atualmente, é uma compra única por tempo limitado.',
  'i18n_member_现有数据保证': 'Para não membros, garantimos que você sempre pode usar seus dados existentes gratuitamente.',
  'i18n_member_终身更新': 'Suporta futuras atualizações gratuitas permanentes.',
  'i18n_member_无广告保证': 'A Clipora garante que nunca adicionará negócios de publicidade para garantir sua experiência de usuário. O sistema de associação é nossa única fonte de receita.',
  'i18n_member_高级特权': 'Privilégios Premium',
  'i18n_member_无限同步': 'Sincronização Ilimitada',
  'i18n_member_无限同步描述': 'Sincronização ilimitada de seus dados para a nuvem',
  'i18n_member_无限存储': 'Armazenamento Ilimitado',
  'i18n_member_无限存储描述': 'Armazenamento ilimitado para seus artigos e notas',
  'i18n_member_高级功能': 'Recursos Avançados',
  'i18n_member_高级功能描述': 'Desfrute de todos os recursos avançados e acesso prioritário',
  'i18n_member_优先支持': 'Suporte Prioritário',
  'i18n_member_优先支持描述': 'Desfrute de suporte ao cliente prioritário e assistência técnica',
  'i18n_member_微信支付': 'WeChat Pay @price',
  'i18n_member_立即购买': 'Comprar agora @price',
  'i18n_member_购买前请阅读并同意': 'Por favor, leia e concorde antes de comprar',
  'i18n_member_购买协议': '《Acordo de compra》',
  'i18n_member_payment_failed_retry': 'Pagamento falhou, tente novamente',
  'i18n_member_payment_cancelled': 'Pagamento cancelado',
  'i18n_member_payment_error_retry_later': 'Erro no pagamento, tente novamente mais tarde',
  'i18n_member_please_agree_to_terms': 'Por favor, leia e concorde primeiro com os termos de uso e política de privacidade',
  'i18n_member_failed_to_initiate_payment': 'Falha ao iniciar pagamento, verifique se o WeChat está instalado',
  'i18n_member_failed_to_create_order': 'Falha ao criar pedido de pagamento, tente novamente mais tarde',
  'i18n_member_payment_failed': 'Pagamento falhou',
  'i18n_member_item_unavailable': 'Item indisponível, tente novamente mais tarde',
  'i18n_member_network_error': 'Falha na conexão de rede, verifique sua rede e tente novamente',
  'i18n_member_payment_exception': 'Exceção de pagamento: @message',
  'i18n_member_verification_failed_contact_support': 'Falha na verificação do pagamento, entre em contato com o suporte',
  'i18n_member_verification_exception_contact_support': 'Exceção na verificação do pagamento, entre em contato com o suporte',
  'i18n_member_upgrade_successful': 'Upgrade bem-sucedido!',
  'i18n_member_premium_activated': 'Membro premium ativado, desfrute de todas as funcionalidades!',
  'i18n_member_confirm': 'Confirmar',
  'i18n_member_upgrade_failed': 'Upgrade falhou',
  'i18n_member_upgrade': 'Upgrade',
  'i18n_member_重要说明': 'Aviso Importante',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Membro Vitalício',
  'i18n_member_订阅会员': 'Membro Assinante',
  'i18n_member_会员已激活': 'Membro Ativado',
  'i18n_member_到期时间': 'Tempo de expiração: @date',
  'i18n_member_续费': 'Renovar',
  'i18n_member_感谢您的支持': 'Obrigado pelo seu apoio',
  'i18n_member_正在享受高级会员特权': 'Desfrutando de privilégios de membro premium',
  'i18n_member_永久访问权限': 'Direitos de acesso permanente',
};
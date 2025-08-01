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
  'i18n_order_AI翻译请求包': 'Pacchetto richieste traduzione IA',
  'i18n_order_AI翻译助手': 'Assistente traduzione IA',
  'i18n_order_让阅读更智能': 'Rendere la lettura più intelligente, l\'apprendimento più efficiente',
  'i18n_order_通过AI翻译助手': 'Con l\'assistente di traduzione IA, puoi tradurre articoli in più lingue.',
  'i18n_order_限时优惠': 'Offerta a tempo limitato',
  'i18n_order_原价': 'Prezzo originale ¥@price',
  'i18n_order_AI请求次数': '@count richieste IA',
  'i18n_order_足够深度阅读': 'Sufficiente per un mese di lettura approfondita',
  'i18n_order_有效期': '@days giorni di validità',
  'i18n_order_立即生效': 'Efficace immediatamente dopo l\'acquisto, tempo sufficiente per l\'esperienza',
  'i18n_order_智能强大': 'Intelligente e potente',
  'i18n_order_AI大模型翻译': 'Traduci i tuoi contenuti in più lingue usando grandi modelli IA',
  'i18n_order_核心功能': 'Funzionalità principali',
  'i18n_order_多国语言支持': 'Supporto multilingue',
  'i18n_order_支持翻译和理解': 'Supporto per traduzione e comprensione multilingue',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Acquista ora @price',
  'i18n_order_购买前请阅读并同意': 'Si prega di leggere e accettare prima dell\'acquisto',
  'i18n_order_购买协议': '《Accordo di acquisto》',
  'i18n_order_payment_failed_retry': 'Pagamento fallito, riprova',
  'i18n_order_payment_cancelled': 'Pagamento annullato',
  'i18n_order_payment_error_retry_later': 'Errore di pagamento, riprova più tardi',
  'i18n_order_please_agree_to_terms': 'Si prega di leggere e accettare prima i termini di utilizzo e la politica sulla privacy',
  'i18n_order_failed_to_initiate_payment': 'Impossibile avviare il pagamento, verifica se WeChat è installato',
  'i18n_order_failed_to_create_order': 'Impossibile creare l\'ordine di pagamento, riprova più tardi',
  'i18n_order_payment_failed': 'Pagamento fallito',
  'i18n_order_item_unavailable': 'Articolo non disponibile, riprova più tardi',
  'i18n_order_network_error': 'Connessione di rete fallita, controlla la rete e riprova',
  'i18n_order_payment_exception': 'Eccezione pagamento: @message',
  'i18n_order_verification_failed_contact_support': 'Verifica pagamento fallita, contatta il supporto clienti',
  'i18n_order_verification_exception_contact_support': 'Eccezione verifica pagamento, contatta il supporto clienti',
  'i18n_order_purchase_successful': 'Acquisto riuscito!',
  'i18n_order_ai_assistant_activated': 'Assistente IA è stato attivato ed è pronto per l\'uso!',
  'i18n_order_confirm': 'Conferma',
  'i18n_order_purchase_failed': 'Acquisto fallito',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Abbonamento Premium',
  'i18n_member_Clipora高级版': 'Clipora Premium',
  'i18n_member_解锁全部功能潜力': 'Sblocca tutto il potenziale delle funzionalità',
  'i18n_member_享受高级功能': 'Goditi funzionalità avanzate per una lettura e gestione della conoscenza più efficienti',
  'i18n_member_限时买断': 'Acquisto unico a tempo limitato',
  'i18n_member_一次性购买': 'Acquisto unico, diventa membro permanente',
  'i18n_member_未来订阅计划': 'Prevediamo di fatturare tramite abbonamenti annuali e mensili in futuro. Attualmente, si tratta di un acquisto unico a tempo limitato.',
  'i18n_member_现有数据保证': 'Per i non membri, garantiamo che potrete sempre utilizzare gratuitamente i vostri dati esistenti.',
  'i18n_member_终身更新': 'Supporta futuri aggiornamenti gratuiti permanenti.',
  'i18n_member_无广告保证': 'Clipora garantisce di non aggiungere mai attività pubblicitarie per garantire la vostra esperienza utente. Il sistema di abbonamento è la nostra unica fonte di reddito.',
  'i18n_member_高级特权': 'Privilegi Premium',
  'i18n_member_无限同步': 'Sincronizzazione Illimitata',
  'i18n_member_无限同步描述': 'Sincronizzazione illimitata dei tuoi dati nel cloud',
  'i18n_member_无限存储': 'Archiviazione Illimitata',
  'i18n_member_无限存储描述': 'Archiviazione illimitata per i tuoi articoli e note',
  'i18n_member_高级功能': 'Funzionalità Avanzate',
  'i18n_member_高级功能描述': 'Goditi tutte le funzionalità avanzate e l\'accesso prioritario',
  'i18n_member_优先支持': 'Supporto Prioritario',
  'i18n_member_优先支持描述': 'Goditi supporto clienti prioritario e assistenza tecnica',
  'i18n_member_微信支付': 'WeChat Pay @price',
  'i18n_member_立即购买': 'Acquista ora @price',
  'i18n_member_购买前请阅读并同意': 'Si prega di leggere e accettare prima dell\'acquisto',
  'i18n_member_购买协议': '《Accordo di acquisto》',
  'i18n_member_payment_failed_retry': 'Pagamento fallito, riprova',
  'i18n_member_payment_cancelled': 'Pagamento annullato',
  'i18n_member_payment_error_retry_later': 'Errore di pagamento, riprova più tardi',
  'i18n_member_please_agree_to_terms': 'Si prega di leggere e accettare prima i termini di utilizzo e la politica sulla privacy',
  'i18n_member_failed_to_initiate_payment': 'Impossibile avviare il pagamento, verifica se WeChat è installato',
  'i18n_member_failed_to_create_order': 'Impossibile creare l\'ordine di pagamento, riprova più tardi',
  'i18n_member_payment_failed': 'Pagamento fallito',
  'i18n_member_item_unavailable': 'Articolo non disponibile, riprova più tardi',
  'i18n_member_network_error': 'Connessione di rete fallita, controlla la rete e riprova',
  'i18n_member_payment_exception': 'Eccezione pagamento: @message',
  'i18n_member_verification_failed_contact_support': 'Verifica pagamento fallita, contatta il supporto clienti',
  'i18n_member_verification_exception_contact_support': 'Eccezione verifica pagamento, contatta il supporto clienti',
  'i18n_member_upgrade_successful': 'Aggiornamento riuscito!',
  'i18n_member_premium_activated': 'Abbonamento premium attivato, goditi tutte le funzionalità!',
  'i18n_member_confirm': 'Conferma',
  'i18n_member_upgrade_failed': 'Aggiornamento fallito',
  'i18n_member_upgrade': 'Aggiorna',
  'i18n_member_重要说明': 'Avviso Importante',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Membro a Vita',
  'i18n_member_订阅会员': 'Membro in Abbonamento',
  'i18n_member_会员已激活': 'Abbonamento Attivato',
  'i18n_member_到期时间': 'Data di scadenza: @date',
  'i18n_member_续费': 'Rinnova',
  'i18n_member_感谢您的支持': 'Grazie per il tuo supporto',
  'i18n_member_正在享受高级会员特权': 'Godendo dei privilegi dell\'abbonamento premium',
  'i18n_member_永久访问权限': 'Diritti di accesso permanenti'
};
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


const Map<String, String> loginI18n = {
  'i18n_login_登录': 'Accedi',
  'i18n_login_立即登录': 'Accedi ora',
  'i18n_login_请输入用户名': 'Inserisci il nome utente',
  'i18n_login_请输入密码': 'Inserisci la password',
  'i18n_login_记住我': 'Ricordami',
  'i18n_login_忘记密码': 'Password dimenticata?',
  'i18n_login_欢迎使用Clipora': 'Benvenuto su Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'Il tuo assistente personale per ritagli e lettura',
  'i18n_login_使用微信登录': 'Accedi con WeChat',
  'i18n_login_使用手机号登录': 'Accedi con numero di telefono',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Leggi e accetta la nostra politica sulla privacy e i termini di utilizzo',
  'i18n_login_微信未安装': 'WeChat non è installato',
  'i18n_login_请先安装微信客户端后再试': 'Installa prima il client WeChat e riprova',
  'i18n_login_授权失败': 'Autorizzazione fallita',
  'i18n_login_未能获取到有效的授权码': 'Impossibile ottenere un codice di autorizzazione valido, riprova',
  'i18n_login_用户拒绝授权': 'L\'utente ha rifiutato l\'autorizzazione',
  'i18n_login_用户取消授权': 'L\'utente ha annullato l\'autorizzazione',
  'i18n_login_发送授权请求失败': 'Invio della richiesta di autorizzazione fallito',
  'i18n_login_微信版本不支持': 'Versione WeChat non supportata',
  'i18n_login_未知错误': 'Errore sconosciuto',
  'i18n_login_正在登录中': 'Accesso in corso...',
  'i18n_login_微信登录失败': 'Accesso WeChat fallito',
  'i18n_login_登录失败请重试': 'Accesso fallito, riprova',
  'i18n_login_微信登录成功但未获取到token': 'Accesso WeChat riuscito ma token non ottenuto',
  'i18n_login_服务器未返回有效的登录凭证': 'Il server non ha restituito credenziali di accesso valide',
  'i18n_login_网络连接异常': 'Connessione di rete anomala, controlla la tua rete e riprova',
  'i18n_login_知道了': 'Capito',
  'i18n_login_该功能正在开发中敬请期待': 'Questa funzionalità è in sviluppo, resta sintonizzato!',
  'i18n_login_隐私政策': 'Politica sulla privacy',
  'i18n_login_隐私政策内容': 'Questa applicazione rispetta e protegge i diritti di privacy personale di tutti gli utenti. Per fornirti servizi più precisi e personalizzati, questa applicazione utilizzerà e divulgherà le tue informazioni personali secondo le disposizioni della politica sulla privacy. Puoi leggere la nostra',
  'i18n_login_同意': 'Accetta',
  'i18n_login_不同意并退出APP': 'Non accettare ed esci dall\'app',
  'i18n_login_我已阅读并同意': 'Ho letto e accetto',
  'i18n_login_用户协议': 'Termini di utilizzo',
  'i18n_login_和': 'e',
  'i18n_login_隐私政策链接': 'Politica sulla privacy',
  'i18n_login_手机号登录': 'Accesso con telefono',
  'i18n_login_输入手机号': 'Inserisci numero di telefono',
  'i18n_login_我们将向您的手机发送验证码': 'Invieremo un codice di verifica al tuo telefono',
  'i18n_login_请输入手机号': 'Inserisci il numero di telefono',
  'i18n_login_发送验证码': 'Invia codice di verifica',
  'i18n_login_请输入正确的手机号': 'Inserisci un numero di telefono valido',
  'i18n_login_发送失败请稍后重试': 'Invio fallito, riprova più tardi',
  'i18n_login_发送验证码失败请检查网络': 'Invio del codice di verifica fallito, controlla la rete',
  'i18n_login_输入验证码': 'Inserisci codice di verifica',
  'i18n_login_我们已向您的手机发送验证码': 'Abbiamo inviato un codice di verifica al tuo telefono',
  'i18n_login_验证码': 'Codice di verifica',
  'i18n_login_秒后重新发送': 's per reinviare',
  'i18n_login_重新发送': 'Reinvia',
  'i18n_login_验证并登录': 'Verifica e accedi',
  'i18n_login_验证码错误请重新输入': 'Codice di verifica errato, inserisci di nuovo',
  'i18n_login_验证码已过期请重新发送': 'Codice di verifica scaduto, reinvia',
  'i18n_login_登录成功': 'Accesso riuscito',
  'i18n_login_登录失败': 'Accesso fallito',
  'i18n_login_验证码发送频繁请稍后再试': 'Codice di verifica inviato troppo frequentemente, riprova più tardi',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Accedi con Apple',
  'i18n_login_Apple登录认证': 'Autenticazione accesso Apple',
  'i18n_login_Apple登录失败': 'Accesso Apple fallito',
  'i18n_login_Apple授权失败': 'Autorizzazione Apple fallita',
  'i18n_login_Apple认证失败': 'Autenticazione Apple fallita',
  'i18n_login_Apple登录不可用': 'Accesso Apple non disponibile',
  'i18n_login_当前设备不支持Apple登录': 'Il dispositivo attuale non supporta l\'accesso Apple',
  'i18n_login_Apple登录发生未知错误': 'Errore sconosciuto nell\'accesso Apple',
  'i18n_login_Apple登录成功但未获取到token': 'Accesso Apple riuscito ma token non ottenuto',
  'i18n_login_Apple服务器响应无效': 'Risposta server Apple non valida',
  'i18n_login_Apple登录请求未被处理': 'Richiesta di accesso Apple non elaborata',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'Apertura finestra autenticazione web',
  'i18n_login_Web认证失败请重试': 'Autenticazione web fallita, riprova',
  'i18n_login_Web认证失败请检查网络连接': 'Autenticazione web fallita, controlla la connessione di rete',
  'i18n_login_Web认证发生未知错误': 'Errore sconosciuto nell\'autenticazione web',
  'i18n_login_Web认证响应无效': 'Risposta autenticazione web non valida',
  'i18n_login_Web认证窗口加载失败': 'Caricamento finestra autenticazione web fallito',
  'i18n_login_Web认证超时请重试': 'Timeout autenticazione web, riprova',
  'i18n_login_网络连接异常请检查网络': 'Connessione di rete anomala, controlla la rete',

  // 0727
  'i18n_login_没有收到验证码': 'Non ho ricevuto il codice di verifica',
  'i18n_login_验证手机号': 'Verifica numero di telefono',
}; 
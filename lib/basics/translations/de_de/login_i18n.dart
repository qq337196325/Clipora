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
  'i18n_login_登录': 'Anmelden',
  'i18n_login_立即登录': 'Jetzt anmelden',
  'i18n_login_请输入用户名': 'Bitte Benutzername eingeben',
  'i18n_login_请输入密码': 'Bitte Passwort eingeben',
  'i18n_login_记住我': 'Angemeldet bleiben',
  'i18n_login_忘记密码': 'Passwort vergessen?',
  'i18n_login_欢迎使用Clipora': 'Willkommen bei Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'Ihr persönlicher Clip- und Lese-Assistent',
  'i18n_login_使用微信登录': 'Mit WeChat anmelden',
  'i18n_login_使用手机号登录': 'Mit Telefonnummer anmelden',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Bitte lesen und akzeptieren Sie unsere Datenschutzrichtlinie und Nutzungsbedingungen',
  'i18n_login_微信未安装': 'WeChat ist nicht installiert',
  'i18n_login_请先安装微信客户端后再试': 'Bitte installieren Sie zuerst den WeChat-Client und versuchen Sie es erneut',
  'i18n_login_授权失败': 'Autorisierung fehlgeschlagen',
  'i18n_login_未能获取到有效的授权码': 'Konnte keinen gültigen Autorisierungscode erhalten, bitte versuchen Sie es erneut',
  'i18n_login_用户拒绝授权': 'Benutzer hat die Autorisierung verweigert',
  'i18n_login_用户取消授权': 'Benutzer hat die Autorisierung abgebrochen',
  'i18n_login_发送授权请求失败': 'Senden der Autorisierungsanfrage fehlgeschlagen',
  'i18n_login_微信版本不支持': 'WeChat-Version wird nicht unterstützt',
  'i18n_login_未知错误': 'Unbekannter Fehler',
  'i18n_login_正在登录中': 'Anmeldung läuft...',
  'i18n_login_微信登录失败': 'WeChat-Anmeldung fehlgeschlagen',
  'i18n_login_登录失败请重试': 'Anmeldung fehlgeschlagen, bitte versuchen Sie es erneut',
  'i18n_login_微信登录成功但未获取到token': 'WeChat-Anmeldung erfolgreich, aber kein Token erhalten',
  'i18n_login_服务器未返回有效的登录凭证': 'Server hat keine gültigen Anmeldedaten zurückgegeben',
  'i18n_login_网络连接异常': 'Netzwerkverbindung abnormal, bitte überprüfen Sie Ihr Netzwerk und versuchen Sie es erneut',
  'i18n_login_知道了': 'Verstanden',
  'i18n_login_该功能正在开发中敬请期待': 'Diese Funktion ist in Entwicklung, bleiben Sie dran!',
  'i18n_login_隐私政策': 'Datenschutzrichtlinie',
  'i18n_login_隐私政策内容': 'Diese Anwendung respektiert und schützt die Privatsphäre aller Benutzer. Um Ihnen genauere und personalisiertere Dienste zu bieten, wird diese Anwendung Ihre persönlichen Informationen gemäß den Bestimmungen der Datenschutzrichtlinie verwenden und offenlegen. Sie können unsere',
  'i18n_login_同意': 'Zustimmen',
  'i18n_login_不同意并退出APP': 'Nicht zustimmen und App beenden',
  'i18n_login_我已阅读并同意': 'Ich habe gelesen und stimme zu',
  'i18n_login_用户协议': 'Nutzungsbedingungen',
  'i18n_login_和': 'und',
  'i18n_login_隐私政策链接': 'Datenschutzrichtlinie',
  'i18n_login_手机号登录': 'Telefon-Anmeldung',
  'i18n_login_输入手机号': 'Telefonnummer eingeben',
  'i18n_login_我们将向您的手机发送验证码': 'Wir senden einen Bestätigungscode an Ihr Telefon',
  'i18n_login_请输入手机号': 'Bitte Telefonnummer eingeben',
  'i18n_login_发送验证码': 'Bestätigungscode senden',
  'i18n_login_请输入正确的手机号': 'Bitte geben Sie eine gültige Telefonnummer ein',
  'i18n_login_发送失败请稍后重试': 'Senden fehlgeschlagen, bitte versuchen Sie es später erneut',
  'i18n_login_发送验证码失败请检查网络': 'Senden des Bestätigungscodes fehlgeschlagen, bitte überprüfen Sie das Netzwerk',
  'i18n_login_输入验证码': 'Bestätigungscode eingeben',
  'i18n_login_我们已向您的手机发送验证码': 'Wir haben einen Bestätigungscode an Ihr Telefon gesendet',
  'i18n_login_验证码': 'Bestätigungscode',
  'i18n_login_秒后重新发送': 's bis zum erneuten Senden',
  'i18n_login_重新发送': 'Erneut senden',
  'i18n_login_验证并登录': 'Bestätigen und anmelden',
  'i18n_login_验证码错误请重新输入': 'Bestätigungscode falsch, bitte erneut eingeben',
  'i18n_login_验证码已过期请重新发送': 'Bestätigungscode abgelaufen, bitte erneut senden',
  'i18n_login_登录成功': 'Anmeldung erfolgreich',
  'i18n_login_登录失败': 'Anmeldung fehlgeschlagen',
  'i18n_login_验证码发送频繁请稍后再试': 'Bestätigungscode zu häufig gesendet, bitte versuchen Sie es später erneut',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Mit Apple anmelden',
  'i18n_login_Apple登录认证': 'Apple-Anmeldung Authentifizierung',
  'i18n_login_Apple登录失败': 'Apple-Anmeldung fehlgeschlagen',
  'i18n_login_Apple授权失败': 'Apple-Autorisierung fehlgeschlagen',
  'i18n_login_Apple认证失败': 'Apple-Authentifizierung fehlgeschlagen',
  'i18n_login_Apple登录不可用': 'Apple-Anmeldung nicht verfügbar',
  'i18n_login_当前设备不支持Apple登录': 'Aktuelles Gerät unterstützt Apple-Anmeldung nicht',
  'i18n_login_Apple登录发生未知错误': 'Unbekannter Fehler bei Apple-Anmeldung aufgetreten',
  'i18n_login_Apple登录成功但未获取到token': 'Apple-Anmeldung erfolgreich, aber kein Token erhalten',
  'i18n_login_Apple服务器响应无效': 'Ungültige Apple-Server-Antwort',
  'i18n_login_Apple登录请求未被处理': 'Apple-Anmeldungsanfrage wurde nicht verarbeitet',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'Web-Authentifizierungsfenster wird geöffnet',
  'i18n_login_Web认证失败请重试': 'Web-Authentifizierung fehlgeschlagen, bitte versuchen Sie es erneut',
  'i18n_login_Web认证失败请检查网络连接': 'Web-Authentifizierung fehlgeschlagen, bitte überprüfen Sie die Netzwerkverbindung',
  'i18n_login_Web认证发生未知错误': 'Unbekannter Fehler bei Web-Authentifizierung aufgetreten',
  'i18n_login_Web认证响应无效': 'Ungültige Web-Authentifizierungsantwort',
  'i18n_login_Web认证窗口加载失败': 'Laden des Web-Authentifizierungsfensters fehlgeschlagen',
  'i18n_login_Web认证超时请重试': 'Web-Authentifizierung Timeout, bitte versuchen Sie es erneut',
  'i18n_login_网络连接异常请检查网络': 'Netzwerkverbindung abnormal, bitte überprüfen Sie das Netzwerk',

  // 0727
  'i18n_login_没有收到验证码': 'Keinen Verifizierungscode erhalten',
  'i18n_login_验证手机号': 'Telefonnummer verifizieren',
}; 
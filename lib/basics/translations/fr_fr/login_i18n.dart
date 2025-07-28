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
  'i18n_login_登录': 'Connexion',
  'i18n_login_立即登录': 'Se connecter maintenant',
  'i18n_login_请输入用户名': 'Veuillez saisir le nom d\'utilisateur',
  'i18n_login_请输入密码': 'Veuillez saisir le mot de passe',
  'i18n_login_记住我': 'Se souvenir de moi',
  'i18n_login_忘记密码': 'Mot de passe oublié ?',
  'i18n_login_欢迎使用Clipora': 'Bienvenue sur Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'Votre assistant personnel de découpage et de lecture',
  'i18n_login_使用微信登录': 'Se connecter avec WeChat',
  'i18n_login_使用手机号登录': 'Se connecter avec le numéro de téléphone',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Veuillez lire et accepter notre politique de confidentialité et nos conditions d\'utilisation',
  'i18n_login_微信未安装': 'WeChat n\'est pas installé',
  'i18n_login_请先安装微信客户端后再试': 'Veuillez d\'abord installer le client WeChat puis réessayer',
  'i18n_login_授权失败': 'Échec de l\'autorisation',
  'i18n_login_未能获取到有效的授权码': 'Impossible d\'obtenir un code d\'autorisation valide, veuillez réessayer',
  'i18n_login_用户拒绝授权': 'L\'utilisateur a refusé l\'autorisation',
  'i18n_login_用户取消授权': 'L\'utilisateur a annulé l\'autorisation',
  'i18n_login_发送授权请求失败': 'Échec de l\'envoi de la demande d\'autorisation',
  'i18n_login_微信版本不支持': 'Version WeChat non prise en charge',
  'i18n_login_未知错误': 'Erreur inconnue',
  'i18n_login_正在登录中': 'Connexion en cours...',
  'i18n_login_微信登录失败': 'Échec de la connexion WeChat',
  'i18n_login_登录失败请重试': 'Échec de la connexion, veuillez réessayer',
  'i18n_login_微信登录成功但未获取到token': 'Connexion WeChat réussie mais aucun token obtenu',
  'i18n_login_服务器未返回有效的登录凭证': 'Le serveur n\'a pas retourné d\'identifiants de connexion valides',
  'i18n_login_网络连接异常': 'Connexion réseau anormale, veuillez vérifier votre réseau et réessayer',
  'i18n_login_知道了': 'Compris',
  'i18n_login_该功能正在开发中敬请期待': 'Cette fonctionnalité est en développement, restez à l\'écoute !',
  'i18n_login_隐私政策': 'Politique de confidentialité',
  'i18n_login_隐私政策内容': 'Cette application respecte et protège les droits de confidentialité personnelle de tous les utilisateurs. Pour vous fournir des services plus précis et personnalisés, cette application utilisera et divulguera vos informations personnelles conformément aux dispositions de la politique de confidentialité. Vous pouvez lire notre',
  'i18n_login_同意': 'Accepter',
  'i18n_login_不同意并退出APP': 'Refuser et quitter l\'application',
  'i18n_login_我已阅读并同意': 'J\'ai lu et j\'accepte',
  'i18n_login_用户协议': 'Conditions d\'utilisation',
  'i18n_login_和': 'et',
  'i18n_login_隐私政策链接': 'Politique de confidentialité',
  'i18n_login_手机号登录': 'Connexion par téléphone',
  'i18n_login_输入手机号': 'Saisir le numéro de téléphone',
  'i18n_login_我们将向您的手机发送验证码': 'Nous enverrons un code de vérification à votre téléphone',
  'i18n_login_请输入手机号': 'Veuillez saisir le numéro de téléphone',
  'i18n_login_发送验证码': 'Envoyer le code de vérification',
  'i18n_login_请输入正确的手机号': 'Veuillez saisir un numéro de téléphone valide',
  'i18n_login_发送失败请稍后重试': 'Échec de l\'envoi, veuillez réessayer plus tard',
  'i18n_login_发送验证码失败请检查网络': 'Échec de l\'envoi du code de vérification, veuillez vérifier le réseau',
  'i18n_login_输入验证码': 'Saisir le code de vérification',
  'i18n_login_我们已向您的手机发送验证码': 'Nous avons envoyé un code de vérification à votre téléphone',
  'i18n_login_验证码': 'Code de vérification',
  'i18n_login_秒后重新发送': 's avant de renvoyer',
  'i18n_login_重新发送': 'Renvoyer',
  'i18n_login_验证并登录': 'Vérifier et se connecter',
  'i18n_login_验证码错误请重新输入': 'Code de vérification incorrect, veuillez ressaisir',
  'i18n_login_验证码已过期请重新发送': 'Code de vérification expiré, veuillez renvoyer',
  'i18n_login_登录成功': 'Connexion réussie',
  'i18n_login_登录失败': 'Échec de la connexion',
  'i18n_login_验证码发送频繁请稍后再试': 'Code de vérification envoyé trop fréquemment, veuillez réessayer plus tard',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Se connecter avec Apple',
  'i18n_login_Apple登录认证': 'Authentification de connexion Apple',
  'i18n_login_Apple登录失败': 'Échec de la connexion Apple',
  'i18n_login_Apple授权失败': 'Échec de l\'autorisation Apple',
  'i18n_login_Apple认证失败': 'Échec de l\'authentification Apple',
  'i18n_login_Apple登录不可用': 'Connexion Apple non disponible',
  'i18n_login_当前设备不支持Apple登录': 'L\'appareil actuel ne prend pas en charge la connexion Apple',
  'i18n_login_Apple登录发生未知错误': 'Erreur inconnue lors de la connexion Apple',
  'i18n_login_Apple登录成功但未获取到token': 'Connexion Apple réussie mais aucun token obtenu',
  'i18n_login_Apple服务器响应无效': 'Réponse du serveur Apple invalide',
  'i18n_login_Apple登录请求未被处理': 'La demande de connexion Apple n\'a pas été traitée',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'Ouverture de la fenêtre d\'authentification web',
  'i18n_login_Web认证失败请重试': 'Échec de l\'authentification web, veuillez réessayer',
  'i18n_login_Web认证失败请检查网络连接': 'Échec de l\'authentification web, veuillez vérifier la connexion réseau',
  'i18n_login_Web认证发生未知错误': 'Erreur inconnue lors de l\'authentification web',
  'i18n_login_Web认证响应无效': 'Réponse d\'authentification web invalide',
  'i18n_login_Web认证窗口加载失败': 'Échec du chargement de la fenêtre d\'authentification web',
  'i18n_login_Web认证超时请重试': 'Timeout de l\'authentification web, veuillez réessayer',
  'i18n_login_网络连接异常请检查网络': 'Connexion réseau anormale, veuillez vérifier le réseau',

  // 0727
  'i18n_login_没有收到验证码': 'Code de vérification non reçu',
  'i18n_login_验证手机号': 'Vérifier le numéro de téléphone',
}; 
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
  'i18n_login_登录': 'Iniciar sesión',
  'i18n_login_立即登录': 'Iniciar sesión ahora',
  'i18n_login_请输入用户名': 'Por favor, introduce el nombre de usuario',
  'i18n_login_请输入密码': 'Por favor, introduce la contraseña',
  'i18n_login_记住我': 'Recordarme',
  'i18n_login_忘记密码': '¿Olvidaste la contraseña?',
  'i18n_login_欢迎使用Clipora': 'Bienvenido a Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'Tu asistente personal de recortes y lectura',
  'i18n_login_使用微信登录': 'Iniciar sesión con WeChat',
  'i18n_login_使用手机号登录': 'Iniciar sesión con número de teléfono',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Por favor, lee y acepta nuestra política de privacidad y acuerdo de usuario',
  'i18n_login_微信未安装': 'WeChat no está instalado',
  'i18n_login_请先安装微信客户端后再试': 'Por favor, instala primero el cliente de WeChat y vuelve a intentarlo',
  'i18n_login_授权失败': 'Autorización fallida',
  'i18n_login_未能获取到有效的授权码': 'No se pudo obtener un código de autorización válido, por favor inténtalo de nuevo',
  'i18n_login_用户拒绝授权': 'El usuario denegó la autorización',
  'i18n_login_用户取消授权': 'El usuario canceló la autorización',
  'i18n_login_发送授权请求失败': 'Error al enviar la solicitud de autorización',
  'i18n_login_微信版本不支持': 'Versión de WeChat no compatible',
  'i18n_login_未知错误': 'Error desconocido',
  'i18n_login_正在登录中': 'Iniciando sesión...',
  'i18n_login_微信登录失败': 'Error al iniciar sesión con WeChat',
  'i18n_login_登录失败请重试': 'Error al iniciar sesión, por favor inténtalo de nuevo',
  'i18n_login_微信登录成功但未获取到token': 'Inicio de sesión con WeChat exitoso pero no se obtuvo el token',
  'i18n_login_服务器未返回有效的登录凭证': 'El servidor no devolvió credenciales de inicio de sesión válidas',
  'i18n_login_网络连接异常': 'Conexión de red anómala, por favor comprueba tu red e inténtalo de nuevo',
  'i18n_login_知道了': 'Entendido',
  'i18n_login_该功能正在开发中敬请期待': 'Esta función está en desarrollo, ¡mantente atento!',
  'i18n_login_隐私政策': 'Política de privacidad',
  'i18n_login_隐私政策内容': 'Esta aplicación respeta y protege los derechos de privacidad personal de todos los usuarios. Para proporcionarte servicios más precisos y personalizados, esta aplicación utilizará y divulgará tu información personal de acuerdo con las disposiciones de esta política de privacidad. Puedes leer nuestra',
  'i18n_login_同意': 'Aceptar',
  'i18n_login_不同意并退出APP': 'No aceptar y salir de la aplicación',
  'i18n_login_我已阅读并同意': 'He leído y acepto',
  'i18n_login_用户协议': 'Acuerdo de usuario',
  'i18n_login_和': 'y',
  'i18n_login_隐私政策链接': 'Política de privacidad',
  'i18n_login_手机号登录': 'Iniciar sesión con teléfono',
  'i18n_login_输入手机号': 'Introduce el número de teléfono',
  'i18n_login_我们将向您的手机发送验证码': 'Te enviaremos un código de verificación a tu teléfono',
  'i18n_login_请输入手机号': 'Por favor, introduce el número de teléfono',
  'i18n_login_发送验证码': 'Enviar código de verificación',
  'i18n_login_请输入正确的手机号': 'Por favor, introduce un número de teléfono válido',
  'i18n_login_发送失败请稍后重试': 'Envío fallido, por favor inténtalo de nuevo más tarde',
  'i18n_login_发送验证码失败请检查网络': 'Error al enviar el código de verificación, por favor comprueba la red',
  'i18n_login_输入验证码': 'Introduce el código de verificación',
  'i18n_login_我们已向您的手机发送验证码': 'Hemos enviado un código de verificación a tu teléfono',
  'i18n_login_验证码': 'Código de verificación',
  'i18n_login_秒后重新发送': 's para reenviar',
  'i18n_login_重新发送': 'Reenviar',
  'i18n_login_验证并登录': 'Verificar e iniciar sesión',
  'i18n_login_验证码错误请重新输入': 'Código de verificación incorrecto, por favor introdúcelo de nuevo',
  'i18n_login_验证码已过期请重新发送': 'El código de verificación ha caducado, por favor reenvíalo',
  'i18n_login_登录成功': 'Inicio de sesión exitoso',
  'i18n_login_登录失败': 'Error al iniciar sesión',
  'i18n_login_验证码发送频繁请稍后再试': 'Envío de código de verificación demasiado frecuente, por favor inténtalo de nuevo más tarde',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Iniciar sesión con Apple',
  'i18n_login_Apple登录认证': 'Autenticación de inicio de sesión de Apple',
  'i18n_login_Apple登录失败': 'Error al iniciar sesión con Apple',
  'i18n_login_Apple授权失败': 'Autorización de Apple fallida',
  'i18n_login_Apple认证失败': 'Autenticación de Apple fallida',
  'i18n_login_Apple登录不可用': 'Inicio de sesión con Apple no disponible',
  'i18n_login_当前设备不支持Apple登录': 'El dispositivo actual no admite el inicio de sesión con Apple',
  'i18n_login_Apple登录发生未知错误': 'Error desconocido al iniciar sesión con Apple',
  'i18n_login_Apple登录成功但未获取到token': 'Inicio de sesión con Apple exitoso pero no se obtuvo el token',
  'i18n_login_Apple服务器响应无效': 'Respuesta del servidor de Apple no válida',
  'i18n_login_Apple登录请求未被处理': 'Solicitud de inicio de sesión de Apple no procesada',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'Abriendo ventana de autenticación web',
  'i18n_login_Web认证失败请重试': 'Autenticación web fallida, por favor inténtalo de nuevo',
  'i18n_login_Web认证失败请检查网络连接': 'Autenticación web fallida, por favor comprueba la conexión de red',
  'i18n_login_Web认证发生未知错误': 'Error desconocido en la autenticación web',
  'i18n_login_Web认证响应无效': 'Respuesta de autenticación web no válida',
  'i18n_login_Web认证窗口加载失败': 'Error al cargar la ventana de autenticación web',
  'i18n_login_Web认证超时请重试': 'Tiempo de espera de autenticación web, por favor inténtalo de nuevo',
  'i18n_login_网络连接异常请检查网络': 'Conexión de red anómala, por favor comprueba la red',

  // 0727
  'i18n_login_没有收到验证码': 'No se recibió el código de verificación',
  'i18n_login_验证手机号': 'Verificar número de teléfono',
};
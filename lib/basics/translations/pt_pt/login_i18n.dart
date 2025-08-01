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
  'i18n_login_登录': 'Iniciar sessão',
  'i18n_login_立即登录': 'Iniciar sessão agora',
  'i18n_login_请输入用户名': 'Por favor, insira o nome de utilizador',
  'i18n_login_请输入密码': 'Por favor, insira a palavra-passe',
  'i18n_login_记住我': 'Lembrar-me',
  'i18n_login_忘记密码': 'Esqueceu a palavra-passe?',
  'i18n_login_欢迎使用Clipora': 'Bem-vindo ao Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'O seu assistente pessoal de recortes e leitura',
  'i18n_login_使用微信登录': 'Iniciar sessão com WeChat',
  'i18n_login_使用手机号登录': 'Iniciar sessão com número de telemóvel',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Por favor, leia e aceite a nossa política de privacidade e termos de utilização',
  'i18n_login_微信未安装': 'WeChat não está instalado',
  'i18n_login_请先安装微信客户端后再试': 'Por favor, instale primeiro o cliente WeChat e tente novamente',
  'i18n_login_授权失败': 'Falha na autorização',
  'i18n_login_未能获取到有效的授权码': 'Não foi possível obter um código de autorização válido, por favor tente novamente',
  'i18n_login_用户拒绝授权': 'O utilizador recusou a autorização',
  'i18n_login_用户取消授权': 'O utilizador cancelou a autorização',
  'i18n_login_发送授权请求失败': 'Falha ao enviar pedido de autorização',
  'i18n_login_微信版本不支持': 'Versão do WeChat não suportada',
  'i18n_login_未知错误': 'Erro desconhecido',
  'i18n_login_正在登录中': 'A iniciar sessão...',
  'i18n_login_微信登录失败': 'Falha no início de sessão com WeChat',
  'i18n_login_登录失败请重试': 'Falha no início de sessão, por favor tente novamente',
  'i18n_login_微信登录成功但未获取到token': 'Início de sessão com WeChat bem-sucedido, mas não foi obtido token',
  'i18n_login_服务器未返回有效的登录凭证': 'O servidor não devolveu credenciais de início de sessão válidas',
  'i18n_login_网络连接异常': 'Ligação de rede anormal, por favor verifique a sua rede e tente novamente',
  'i18n_login_知道了': 'Entendido',
  'i18n_login_该功能正在开发中敬请期待': 'Esta funcionalidade está em desenvolvimento, fique atento!',
  'i18n_login_隐私政策': 'Política de privacidade',
  'i18n_login_隐私政策内容': 'Esta aplicação respeita e protege os direitos de privacidade pessoal de todos os utilizadores. Para fornecer serviços mais precisos e personalizados, esta aplicação utilizará e divulgará as suas informações pessoais de acordo com as disposições da política de privacidade. Pode ler a nossa',
  'i18n_login_同意': 'Aceitar',
  'i18n_login_不同意并退出APP': 'Não aceitar e sair da aplicação',
  'i18n_login_我已阅读并同意': 'Li e aceito',
  'i18n_login_用户协议': 'Termos de utilização',
  'i18n_login_和': 'e',
  'i18n_login_隐私政策链接': 'Política de privacidade',
  'i18n_login_手机号登录': 'Início de sessão por telemóvel',
  'i18n_login_输入手机号': 'Inserir número de telemóvel',
  'i18n_login_我们将向您的手机发送验证码': 'Enviaremos um código de verificação para o seu telemóvel',
  'i18n_login_请输入手机号': 'Por favor, insira o número de telemóvel',
  'i18n_login_发送验证码': 'Enviar código de verificação',
  'i18n_login_请输入正确的手机号': 'Por favor, insira um número de telemóvel válido',
  'i18n_login_发送失败请稍后重试': 'Falha no envio, por favor tente mais tarde',
  'i18n_login_发送验证码失败请检查网络': 'Falha no envio do código de verificação, por favor verifique a rede',
  'i18n_login_输入验证码': 'Inserir código de verificação',
  'i18n_login_我们已向您的手机发送验证码': 'Enviámos um código de verificação para o seu telemóvel',
  'i18n_login_验证码': 'Código de verificação',
  'i18n_login_秒后重新发送': 's para reenviar',
  'i18n_login_重新发送': 'Reenviar',
  'i18n_login_验证并登录': 'Verificar e iniciar sessão',
  'i18n_login_验证码错误请重新输入': 'Código de verificação incorreto, por favor insira novamente',
  'i18n_login_验证码已过期请重新发送': 'Código de verificação expirado, por favor reenvie',
  'i18n_login_登录成功': 'Início de sessão bem-sucedido',
  'i18n_login_登录失败': 'Falha no início de sessão',
  'i18n_login_验证码发送频繁请稍后再试': 'Código de verificação enviado com demasiada frequência, por favor tente mais tarde',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Iniciar sessão com Apple',
  'i18n_login_Apple登录认证': 'Autenticação de início de sessão Apple',
  'i18n_login_Apple登录失败': 'Falha no início de sessão Apple',
  'i18n_login_Apple授权失败': 'Falha na autorização Apple',
  'i18n_login_Apple认证失败': 'Falha na autenticação Apple',
  'i18n_login_Apple登录不可用': 'Início de sessão Apple não disponível',
  'i18n_login_当前设备不支持Apple登录': 'O dispositivo atual não suporta início de sessão Apple',
  'i18n_login_Apple登录发生未知错误': 'Erro desconhecido no início de sessão Apple',
  'i18n_login_Apple登录成功但未获取到token': 'Início de sessão Apple bem-sucedido mas token não obtido',
  'i18n_login_Apple服务器响应无效': 'Resposta do servidor Apple inválida',
  'i18n_login_Apple登录请求未被处理': 'Pedido de início de sessão Apple não processado',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'A abrir janela de autenticação web',
  'i18n_login_Web认证失败请重试': 'Falha na autenticação web, por favor tente novamente',
  'i18n_login_Web认证失败请检查网络连接': 'Falha na autenticação web, por favor verifique a ligação de rede',
  'i18n_login_Web认证发生未知错误': 'Erro desconhecido na autenticação web',
  'i18n_login_Web认证响应无效': 'Resposta de autenticação web inválida',
  'i18n_login_Web认证窗口加载失败': 'Falha no carregamento da janela de autenticação web',
  'i18n_login_Web认证超时请重试': 'Timeout da autenticação web, por favor tente novamente',
  'i18n_login_网络连接异常请检查网络': 'Ligação de rede anormal, por favor verifique a rede',

  // 0727
  'i18n_login_没有收到验证码': 'Não recebi o código de verificação',
  'i18n_login_验证手机号': 'Verificar número de telemóvel',
}; 
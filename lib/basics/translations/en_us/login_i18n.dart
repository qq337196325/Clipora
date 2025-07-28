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
  'i18n_login_登录': 'Login',
  'i18n_login_立即登录': 'Log In Now',
  'i18n_login_请输入用户名': 'Please enter username',
  'i18n_login_请输入密码': 'Please enter password',
  'i18n_login_登录成功': 'Login successful!',
  'i18n_login_登录失败': 'Login failed, please check your credentials.',
  'i18n_login_记住我': 'Remember me',
  'i18n_login_忘记密码': 'Forgot password?',
  'i18n_login_欢迎使用Clipora': 'Welcome to Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'Your exclusive clipping and reading assistant',
  'i18n_login_使用微信登录': 'Log in with WeChat',
  'i18n_login_使用手机号登录': 'Log in with Phone Number',
  'i18n_login_使用Apple登录': 'Sign in with Apple',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Please read and agree to our Privacy Policy and User Agreement',
  'i18n_login_微信未安装': 'WeChat not installed',
  'i18n_login_请先安装微信客户端后再试': 'Please install WeChat client and try again',
  'i18n_login_授权失败': 'Authorization failed',
  'i18n_login_未能获取到有效的授权码': 'Failed to get a valid authorization code, please try again',
  'i18n_login_用户拒绝授权': 'User denied authorization',
  'i18n_login_用户取消授权': 'User cancelled authorization',
  'i18n_login_发送授权请求失败': 'Failed to send authorization request',
  'i18n_login_微信版本不支持': 'WeChat version not supported',
  'i18n_login_未知错误': 'Unknown error',
  'i18n_login_正在登录中': 'Logging in...',
  'i18n_login_微信登录失败': 'WeChat login failed',
  'i18n_login_登录失败请重试': 'Login failed, please try again',
  'i18n_login_微信登录成功但未获取到token': 'WeChat login successful but no token obtained',
  'i18n_login_服务器未返回有效的登录凭证': 'Server did not return valid login credentials',
  'i18n_login_网络连接异常': 'Network connection abnormal, please check your network and try again',
  'i18n_login_知道了': 'Got it',
  'i18n_login_该功能正在开发中敬请期待': 'This feature is under development, please stay tuned!',
  'i18n_login_隐私政策': 'Privacy Policy',
  'i18n_login_隐私政策内容': 'This application respects and protects the personal privacy of all users. To provide you with more accurate and personalized services, this application will use and disclose your personal information in accordance with the Privacy Policy. You can read our',
  'i18n_login_同意': 'Agree',
  'i18n_login_不同意并退出APP': 'Disagree and Exit App',
  'i18n_login_我已阅读并同意': 'I have read and agree to',
  'i18n_login_用户协议': 'User Agreement',
  'i18n_login_和': 'and',
  'i18n_login_隐私政策链接': 'Privacy Policy',
  'i18n_login_手机号登录': 'Phone Login',
  'i18n_login_输入手机号': 'Enter Phone Number',
  'i18n_login_我们将向您的手机发送验证码': 'We will send a verification code to your phone',
  'i18n_login_请输入手机号': 'Please enter phone number',
  'i18n_login_发送验证码': 'Send Verification Code',
  'i18n_login_请输入正确的手机号': 'Please enter a valid phone number',
  'i18n_login_发送失败请稍后重试': 'Failed to send, please try again later',
  'i18n_login_发送验证码失败请检查网络': 'Failed to send verification code, please check network',
  'i18n_login_输入验证码': 'Enter Verification Code',
  'i18n_login_我们已向您的手机发送验证码': 'We have sent a verification code to your phone',
  'i18n_login_验证码': 'Verification Code',
  'i18n_login_秒后重新发送': 's to resend',
  'i18n_login_重新发送': 'Resend',
  'i18n_login_验证并登录': 'Verify and Log In',
  'i18n_login_验证码错误请重新输入': 'Incorrect verification code, please re-enter',
  'i18n_login_验证码已过期请重新发送': 'Verification code expired, please resend',
  'i18n_login_验证码发送频繁请稍后再试': 'Verification code sent too frequently, please try again later',
  
  // Apple登录相关
  'i18n_login_Apple登录不可用': 'Apple Sign In not available',
  'i18n_login_当前设备不支持Apple登录': 'Current device does not support Apple Sign In',
  'i18n_login_Apple登录失败': 'Apple Sign In failed',
  'i18n_login_Apple授权失败': 'Apple authorization failed',
  'i18n_login_Apple服务器响应无效': 'Apple server response invalid',
  'i18n_login_Apple登录请求未被处理': 'Apple Sign In request not handled',
  'i18n_login_Apple登录发生未知错误': 'Apple Sign In unknown error occurred',
  'i18n_login_Apple登录成功但未获取到token': 'Apple Sign In successful but no token obtained',
  
  // Android Web认证相关
  'i18n_login_正在打开Web认证窗口': 'Opening web authentication window...',
  'i18n_login_Web认证失败请检查网络连接': 'Web authentication failed, please check network connection',
  'i18n_login_Web认证响应无效': 'Web authentication response invalid',
  'i18n_login_Web认证发生未知错误': 'Web authentication unknown error occurred',
  'i18n_login_Web认证超时请重试': 'Web authentication timeout, please retry',
  'i18n_login_网络连接异常请检查网络': 'Network connection abnormal, please check network',
  'i18n_login_Web认证窗口加载失败': 'Web authentication window loading failed',
  'i18n_login_Web认证失败请重试': 'Web authentication failed, please retry',
  'i18n_login_Apple登录认证': 'Apple Sign In Authentication',
  'i18n_login_Apple认证失败': 'Apple Authentication Failed',

  // 0727
  'i18n_login_没有收到验证码': 'Didn\'t receive verification code',
  'i18n_login_验证手机号': 'Verify phone number',
};
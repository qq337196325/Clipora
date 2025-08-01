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
  'i18n_login_登录': '登录',
  'i18n_login_立即登录': '立即登录',
  'i18n_login_请输入用户名': '请输入用户名',
  'i18n_login_请输入密码': '请输入密码',
  // 'i18n_login_登录成功': '登录成功！',
  // 'i18n_login_登录失败': '登录失败，请检查您的凭据。',
  'i18n_login_记住我': '记住我',
  'i18n_login_忘记密码': '忘记密码？',
  'i18n_login_欢迎使用Clipora': '欢迎使用 Clipora',
  'i18n_login_您的专属剪藏与阅读助手': '您的专属剪藏与阅读助手',
  'i18n_login_使用微信登录': '使用微信登录',
  'i18n_login_使用手机号登录': '使用手机号登录',
  'i18n_login_使用Apple登录': '使用 Apple 登录',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': '请阅读并勾选我们的隐私政策与用户协议',
  'i18n_login_微信未安装': '微信未安装',
  'i18n_login_请先安装微信客户端后再试': '请先安装微信客户端后再试',
  'i18n_login_授权失败': '授权失败',
  'i18n_login_未能获取到有效的授权码': '未能获取到有效的授权码，请重试',
  'i18n_login_用户拒绝授权': '用户拒绝授权',
  'i18n_login_用户取消授权': '用户取消授权',
  'i18n_login_发送授权请求失败': '发送授权请求失败',
  'i18n_login_微信版本不支持': '微信版本不支持',
  'i18n_login_未知错误': '未知错误',
  'i18n_login_正在登录中': '正在登录中...',
  'i18n_login_微信登录失败': '微信登录失败',
  'i18n_login_登录失败请重试': '登录失败，请重试',
  'i18n_login_微信登录成功但未获取到token': '微信登录成功但未获取到token',
  'i18n_login_服务器未返回有效的登录凭证': '服务器未返回有效的登录凭证',
  'i18n_login_网络连接异常': '网络连接异常，请检查网络后重试',
  'i18n_login_知道了': '知道了',
  'i18n_login_该功能正在开发中敬请期待': '该功能正在开发中，敬请期待！',
  'i18n_login_隐私政策': '隐私政策',
  'i18n_login_隐私政策内容': '本应用尊重并保护所有用户的个人隐私权。为了给您提供更准确、更有个性化的服务，本应用会按照隐私政策的规定使用和披露您的个人信息。可阅读我们的',
  'i18n_login_同意': '同意',
  'i18n_login_不同意并退出APP': '不同意并退出APP',
  'i18n_login_我已阅读并同意': '我已阅读并同意',
  'i18n_login_用户协议': '《用户协议》',
  'i18n_login_和': '和',
  'i18n_login_隐私政策链接': '《隐私政策》', // 区分标题和链接文本
  'i18n_login_手机号登录': '手机号登录',
  'i18n_login_输入手机号': '输入手机号',
  'i18n_login_我们将向您的手机发送验证码': '我们将向您的手机发送验证码',
  'i18n_login_请输入手机号': '请输入手机号',
  'i18n_login_发送验证码': '发送验证码',
  'i18n_login_请输入正确的手机号': '请输入正确的手机号',
  'i18n_login_发送失败请稍后重试': '发送失败，请稍后重试',
  'i18n_login_发送验证码失败请检查网络': '发送验证码失败，请检查网络',
  'i18n_login_输入验证码': '输入验证码',
  'i18n_login_我们已向您的手机发送验证码': '我们已向您的手机发送验证码',
  'i18n_login_验证码': '验证码',
  'i18n_login_秒后重新发送': '秒后重新发送',
  'i18n_login_重新发送': '重新发送',
  'i18n_login_验证并登录': '验证并登录',
  'i18n_login_验证码错误请重新输入': '验证码错误，请重新输入',
  'i18n_login_验证码已过期请重新发送': '验证码已过期，请重新发送',
  'i18n_login_登录成功': '登录成功',
  'i18n_login_登录失败': '登录失败',
  'i18n_login_验证码发送频繁请稍后再试': '验证码发送频繁，请稍后再试',
  
  // Apple登录相关
  'i18n_login_Apple登录不可用': 'Apple登录不可用',
  'i18n_login_当前设备不支持Apple登录': '当前设备不支持Apple登录',
  'i18n_login_Apple登录失败': 'Apple登录失败',
  'i18n_login_Apple授权失败': 'Apple授权失败',
  'i18n_login_Apple服务器响应无效': 'Apple服务器响应无效',
  'i18n_login_Apple登录请求未被处理': 'Apple登录请求未被处理',
  'i18n_login_Apple登录发生未知错误': 'Apple登录发生未知错误',
  'i18n_login_Apple登录成功但未获取到token': 'Apple登录成功但未获取到token',
  
  // Android Web认证相关
  'i18n_login_正在打开Web认证窗口': '正在打开Web认证窗口...',
  'i18n_login_Web认证失败请检查网络连接': 'Web认证失败，请检查网络连接',
  'i18n_login_Web认证响应无效': 'Web认证响应无效',
  'i18n_login_Web认证发生未知错误': 'Web认证发生未知错误',
  'i18n_login_Web认证超时请重试': 'Web认证超时，请重试',
  'i18n_login_网络连接异常请检查网络': '网络连接异常，请检查网络',
  'i18n_login_Web认证窗口加载失败': 'Web认证窗口加载失败',
  'i18n_login_Web认证失败请重试': 'Web认证失败，请重试',
  'i18n_login_Apple登录认证': 'Apple登录认证',
  'i18n_login_Apple认证失败': 'Apple认证失败',


  // 0727
  'i18n_login_没有收到验证码': '没有收到验证码',
  'i18n_login_验证手机号': '验证手机号',

};

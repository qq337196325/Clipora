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
  'i18n_login_登录': '登入',
  'i18n_login_立即登录': '立即登入',
  'i18n_login_请输入用户名': '請輸入用戶名',
  'i18n_login_请输入密码': '請輸入密碼',
  'i18n_login_记住我': '記住我',
  'i18n_login_忘记密码': '忘記密碼？',
  'i18n_login_欢迎使用Clipora': '歡迎使用 Clipora',
  'i18n_login_您的专属剪藏与阅读助手': '您的專屬剪藏與閱讀助手',
  'i18n_login_使用微信登录': '使用微信登入',
  'i18n_login_使用手机号登录': '使用手機號登入',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': '請閱讀並勾選我們的隱私政策與用戶協議',
  'i18n_login_微信未安装': '微信未安裝',
  'i18n_login_请先安装微信客户端后再试': '請先安裝微信客戶端後再試',
  'i18n_login_授权失败': '授權失敗',
  'i18n_login_未能获取到有效的授权码': '未能獲取到有效的授權碼，請重試',
  'i18n_login_用户拒绝授权': '用戶拒絕授權',
  'i18n_login_用户取消授权': '用戶取消授權',
  'i18n_login_发送授权请求失败': '發送授權請求失敗',
  'i18n_login_微信版本不支持': '微信版本不支援',
  'i18n_login_未知错误': '未知錯誤',
  'i18n_login_正在登录中': '正在登入中...',
  'i18n_login_微信登录失败': '微信登入失敗',
  'i18n_login_登录失败请重试': '登入失敗，請重試',
  'i18n_login_微信登录成功但未获取到token': '微信登入成功但未獲取到token',
  'i18n_login_服务器未返回有效的登录凭证': '服務器未返回有效的登入憑證',
  'i18n_login_网络连接异常': '網絡連接異常，請檢查網絡後重試',
  'i18n_login_知道了': '知道了',
  'i18n_login_该功能正在开发中敬请期待': '該功能正在開發中，敬請期待！',
  'i18n_login_隐私政策': '隱私政策',
  'i18n_login_隐私政策内容': '本應用尊重並保護所有用戶的個人隱私權。為了給您提供更準確、更有個性化的服務，本應用會按照隱私政策的規定使用和披露您的個人信息。可閱讀我們的',
  'i18n_login_同意': '同意',
  'i18n_login_不同意并退出APP': '不同意並退出APP',
  'i18n_login_我已阅读并同意': '我已閱讀並同意',
  'i18n_login_用户协议': '《用戶協議》',
  'i18n_login_和': '和',
  'i18n_login_隐私政策链接': '《隱私政策》',
  'i18n_login_手机号登录': '手機號登入',
  'i18n_login_输入手机号': '輸入手機號',
  'i18n_login_我们将向您的手机发送验证码': '我們將向您的手機發送驗證碼',
  'i18n_login_请输入手机号': '請輸入手機號',
  'i18n_login_发送验证码': '發送驗證碼',
  'i18n_login_请输入正确的手机号': '請輸入正確的手機號',
  'i18n_login_发送失败请稍后重试': '發送失敗，請稍後重試',
  'i18n_login_发送验证码失败请检查网络': '發送驗證碼失敗，請檢查網絡',
  'i18n_login_输入验证码': '輸入驗證碼',
  'i18n_login_我们已向您的手机发送验证码': '我們已向您的手機發送驗證碼',
  'i18n_login_验证码': '驗證碼',
  'i18n_login_秒后重新发送': '秒後重新發送',
  'i18n_login_重新发送': '重新發送',
  'i18n_login_验证并登录': '驗證並登入',
  'i18n_login_验证码错误请重新输入': '驗證碼錯誤，請重新輸入',
  'i18n_login_验证码已过期请重新发送': '驗證碼已過期，請重新發送',
  'i18n_login_登录成功': '登入成功',
  'i18n_login_登录失败': '登入失敗',
  'i18n_login_验证码发送频繁请稍后再试': '驗證碼發送頻繁，請稍後再試',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': '使用 Apple 登入',
  'i18n_login_Apple登录认证': 'Apple 登入認證',
  'i18n_login_Apple登录失败': 'Apple 登入失敗',
  'i18n_login_Apple授权失败': 'Apple 授權失敗',
  'i18n_login_Apple认证失败': 'Apple 認證失敗',
  'i18n_login_Apple登录不可用': 'Apple 登入不可用',
  'i18n_login_当前设备不支持Apple登录': '目前設備不支援 Apple 登入',
  'i18n_login_Apple登录发生未知错误': 'Apple 登入發生未知錯誤',
  'i18n_login_Apple登录成功但未获取到token': 'Apple 登入成功但未獲取到 token',
  'i18n_login_Apple服务器响应无效': 'Apple 伺服器回應無效',
  'i18n_login_Apple登录请求未被处理': 'Apple 登入請求未被處理',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': '正在開啟 Web 認證視窗',
  'i18n_login_Web认证失败请重试': 'Web 認證失敗，請重試',
  'i18n_login_Web认证失败请检查网络连接': 'Web 認證失敗，請檢查網絡連接',
  'i18n_login_Web认证发生未知错误': 'Web 認證發生未知錯誤',
  'i18n_login_Web认证响应无效': 'Web 認證回應無效',
  'i18n_login_Web认证窗口加载失败': 'Web 認證視窗載入失敗',
  'i18n_login_Web认证超时请重试': 'Web 認證逾時，請重試',
  'i18n_login_网络连接异常请检查网络': '網絡連接異常，請檢查網絡',

  // 0727
  'i18n_login_没有收到验证码': '沒有收到驗證碼',
  'i18n_login_验证手机号': '驗證手機號',
}; 
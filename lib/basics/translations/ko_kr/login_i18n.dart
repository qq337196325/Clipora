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
  'i18n_login_登录': '로그인',
  'i18n_login_立即登录': '지금 로그인',
  'i18n_login_请输入用户名': '사용자명을 입력해주세요',
  'i18n_login_请输入密码': '비밀번호를 입력해주세요',
  'i18n_login_记住我': '로그인 상태 유지',
  'i18n_login_忘记密码': '비밀번호를 잊으셨나요?',
  'i18n_login_欢迎使用Clipora': 'Clipora에 오신 것을 환영합니다',
  'i18n_login_您的专属剪藏与阅读助手': '당신만의 클립 및 독서 도우미',
  'i18n_login_使用微信登录': '위챗으로 로그인',
  'i18n_login_使用手机号登录': '휴대폰 번호로 로그인',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': '개인정보 처리방침과 이용약관을 읽고 동의해주세요',
  'i18n_login_微信未安装': '위챗이 설치되지 않았습니다',
  'i18n_login_请先安装微信客户端后再试': '위챗 클라이언트를 먼저 설치한 후 다시 시도해주세요',
  'i18n_login_授权失败': '인증 실패',
  'i18n_login_未能获取到有效的授权码': '유효한 인증 코드를 가져올 수 없습니다. 다시 시도해주세요',
  'i18n_login_用户拒绝授权': '사용자가 인증을 거부했습니다',
  'i18n_login_用户取消授权': '사용자가 인증을 취소했습니다',
  'i18n_login_发送授权请求失败': '인증 요청 전송에 실패했습니다',
  'i18n_login_微信版本不支持': '위챗 버전이 지원되지 않습니다',
  'i18n_login_未知错误': '알 수 없는 오류',
  'i18n_login_正在登录中': '로그인 중...',
  'i18n_login_微信登录失败': '위챗 로그인에 실패했습니다',
  'i18n_login_登录失败请重试': '로그인에 실패했습니다. 다시 시도해주세요',
  'i18n_login_微信登录成功但未获取到token': '위챗 로그인은 성공했지만 토큰을 가져오지 못했습니다',
  'i18n_login_服务器未返回有效的登录凭证': '서버에서 유효한 로그인 자격 증명을 반환하지 않았습니다',
  'i18n_login_网络连接异常': '네트워크 연결에 이상이 있습니다. 네트워크를 확인한 후 다시 시도해주세요',
  'i18n_login_知道了': '알겠습니다',
  'i18n_login_该功能正在开发中敬请期待': '이 기능은 개발 중입니다. 조금만 기다려주세요!',
  'i18n_login_隐私政策': '개인정보 처리방침',
  'i18n_login_隐私政策内容': '이 애플리케이션은 모든 사용자의 개인 정보 권리를 존중하고 보호합니다. 더 정확하고 개인화된 서비스를 제공하기 위해 이 애플리케이션은 개인정보 처리방침 규정에 따라 귀하의 개인 정보를 사용하고 공개합니다. 당사의',
  'i18n_login_同意': '동의',
  'i18n_login_不同意并退出APP': '동의하지 않고 앱 종료',
  'i18n_login_我已阅读并同意': '저는 읽고 동의합니다',
  'i18n_login_用户协议': '이용약관',
  'i18n_login_和': '및',
  'i18n_login_隐私政策链接': '개인정보 처리방침',
  'i18n_login_手机号登录': '휴대폰 번호 로그인',
  'i18n_login_输入手机号': '휴대폰 번호 입력',
  'i18n_login_我们将向您的手机发送验证码': '귀하의 휴대폰으로 인증번호를 보내드립니다',
  'i18n_login_请输入手机号': '휴대폰 번호를 입력해주세요',
  'i18n_login_发送验证码': '인증번호 전송',
  'i18n_login_请输入正确的手机号': '올바른 휴대폰 번호를 입력해주세요',
  'i18n_login_发送失败请稍后重试': '전송에 실패했습니다. 잠시 후 다시 시도해주세요',
  'i18n_login_发送验证码失败请检查网络': '인증번호 전송에 실패했습니다. 네트워크를 확인해주세요',
  'i18n_login_输入验证码': '인증번호 입력',
  'i18n_login_我们已向您的手机发送验证码': '귀하의 휴대폰으로 인증번호를 보내드렸습니다',
  'i18n_login_验证码': '인증번호',
  'i18n_login_秒后重新发送': '초 후 재전송',
  'i18n_login_重新发送': '재전송',
  'i18n_login_验证并登录': '인증 후 로그인',
  'i18n_login_验证码错误请重新输入': '인증번호가 잘못되었습니다. 다시 입력해주세요',
  'i18n_login_验证码已过期请重新发送': '인증번호가 만료되었습니다. 다시 전송해주세요',
  'i18n_login_登录成功': '로그인 성공',
  'i18n_login_登录失败': '로그인 실패',
  'i18n_login_验证码发送频繁请稍后再试': '인증번호 전송이 너무 빈번합니다. 잠시 후 다시 시도해주세요',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Apple로 로그인',
  'i18n_login_Apple登录认证': 'Apple 로그인 인증',
  'i18n_login_Apple登录失败': 'Apple 로그인에 실패했습니다',
  'i18n_login_Apple授权失败': 'Apple 인증에 실패했습니다',
  'i18n_login_Apple认证失败': 'Apple 인증에 실패했습니다',
  'i18n_login_Apple登录不可用': 'Apple 로그인을 사용할 수 없습니다',
  'i18n_login_当前设备不支持Apple登录': '현재 기기는 Apple 로그인을 지원하지 않습니다',
  'i18n_login_Apple登录发生未知错误': 'Apple 로그인에서 알 수 없는 오류가 발생했습니다',
  'i18n_login_Apple登录成功但未获取到token': 'Apple 로그인은 성공했지만 토큰을 가져오지 못했습니다',
  'i18n_login_Apple服务器响应无效': 'Apple 서버 응답이 유효하지 않습니다',
  'i18n_login_Apple登录请求未被处理': 'Apple 로그인 요청이 처리되지 않았습니다',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'Web 인증 창을 열고 있습니다',
  'i18n_login_Web认证失败请重试': 'Web 인증에 실패했습니다. 다시 시도해주세요',
  'i18n_login_Web认证失败请检查网络连接': 'Web 인증에 실패했습니다. 네트워크 연결을 확인해주세요',
  'i18n_login_Web认证发生未知错误': 'Web 인증에서 알 수 없는 오류가 발생했습니다',
  'i18n_login_Web认证响应无效': 'Web 인증 응답이 유효하지 않습니다',
  'i18n_login_Web认证窗口加载失败': 'Web 인증 창 로드에 실패했습니다',
  'i18n_login_Web认证超时请重试': 'Web 인증이 시간 초과되었습니다. 다시 시도해주세요',
  'i18n_login_网络连接异常请检查网络': '네트워크 연결에 이상이 있습니다. 네트워크를 확인해주세요',

  // 0727
  'i18n_login_没有收到验证码': '인증번호를 받지 못했습니다',
  'i18n_login_验证手机号': '휴대폰 번호 인증',
}; 
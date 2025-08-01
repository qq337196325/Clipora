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
  'i18n_login_登录': 'Đăng nhập',
  'i18n_login_立即登录': 'Đăng nhập ngay',
  'i18n_login_请输入用户名': 'Vui lòng nhập tên người dùng',
  'i18n_login_请输入密码': 'Vui lòng nhập mật khẩu',
  'i18n_login_记住我': 'Ghi nhớ tôi',
  'i18n_login_忘记密码': 'Quên mật khẩu?',
  'i18n_login_欢迎使用Clipora': 'Chào mừng đến với Clipora',
  'i18n_login_您的专属剪藏与阅读助手': 'Trợ lý cá nhân cho việc lưu trữ và đọc',
  'i18n_login_使用微信登录': 'Đăng nhập bằng WeChat',
  'i18n_login_使用手机号登录': 'Đăng nhập bằng số điện thoại',
  'i18n_login_请阅读并勾选我们的隐私政策与用户协议': 'Vui lòng đọc và đồng ý với chính sách bảo mật và điều khoản sử dụng',
  'i18n_login_微信未安装': 'WeChat chưa được cài đặt',
  'i18n_login_请先安装微信客户端后再试': 'Vui lòng cài đặt ứng dụng WeChat trước và thử lại',
  'i18n_login_授权失败': 'Ủy quyền thất bại',
  'i18n_login_未能获取到有效的授权码': 'Không thể nhận được mã ủy quyền hợp lệ, vui lòng thử lại',
  'i18n_login_用户拒绝授权': 'Người dùng từ chối ủy quyền',
  'i18n_login_用户取消授权': 'Người dùng hủy ủy quyền',
  'i18n_login_发送授权请求失败': 'Gửi yêu cầu ủy quyền thất bại',
  'i18n_login_微信版本不支持': 'Phiên bản WeChat không được hỗ trợ',
  'i18n_login_未知错误': 'Lỗi không xác định',
  'i18n_login_正在登录中': 'Đang đăng nhập...',
  'i18n_login_微信登录失败': 'Đăng nhập WeChat thất bại',
  'i18n_login_登录失败请重试': 'Đăng nhập thất bại, vui lòng thử lại',
  'i18n_login_微信登录成功但未获取到token': 'Đăng nhập WeChat thành công nhưng không nhận được token',
  'i18n_login_服务器未返回有效的登录凭证': 'Máy chủ không trả về thông tin đăng nhập hợp lệ',
  'i18n_login_网络连接异常': 'Kết nối mạng bất thường, vui lòng kiểm tra mạng và thử lại',
  'i18n_login_知道了': 'Đã hiểu',
  'i18n_login_该功能正在开发中敬请期待': 'Tính năng này đang trong quá trình phát triển, hãy theo dõi!',
  'i18n_login_隐私政策': 'Chính sách bảo mật',
  'i18n_login_隐私政策内容': 'Ứng dụng này tôn trọng và bảo vệ quyền riêng tư cá nhân của tất cả người dùng. Để cung cấp dịch vụ chính xác và cá nhân hóa hơn, ứng dụng này sẽ sử dụng và tiết lộ thông tin cá nhân của bạn theo quy định của chính sách bảo mật. Bạn có thể đọc',
  'i18n_login_同意': 'Đồng ý',
  'i18n_login_不同意并退出APP': 'Không đồng ý và thoát ứng dụng',
  'i18n_login_我已阅读并同意': 'Tôi đã đọc và đồng ý',
  'i18n_login_用户协议': 'Điều khoản sử dụng',
  'i18n_login_和': 'và',
  'i18n_login_隐私政策链接': 'Chính sách bảo mật',
  'i18n_login_手机号登录': 'Đăng nhập bằng điện thoại',
  'i18n_login_输入手机号': 'Nhập số điện thoại',
  'i18n_login_我们将向您的手机发送验证码': 'Chúng tôi sẽ gửi mã xác minh đến điện thoại của bạn',
  'i18n_login_请输入手机号': 'Vui lòng nhập số điện thoại',
  'i18n_login_发送验证码': 'Gửi mã xác minh',
  'i18n_login_请输入正确的手机号': 'Vui lòng nhập số điện thoại hợp lệ',
  'i18n_login_发送失败请稍后重试': 'Gửi thất bại, vui lòng thử lại sau',
  'i18n_login_发送验证码失败请检查网络': 'Gửi mã xác minh thất bại, vui lòng kiểm tra mạng',
  'i18n_login_输入验证码': 'Nhập mã xác minh',
  'i18n_login_我们已向您的手机发送验证码': 'Chúng tôi đã gửi mã xác minh đến điện thoại của bạn',
  'i18n_login_验证码': 'Mã xác minh',
  'i18n_login_秒后重新发送': 'giây để gửi lại',
  'i18n_login_重新发送': 'Gửi lại',
  'i18n_login_验证并登录': 'Xác minh và đăng nhập',
  'i18n_login_验证码错误请重新输入': 'Mã xác minh sai, vui lòng nhập lại',
  'i18n_login_验证码已过期请重新发送': 'Mã xác minh đã hết hạn, vui lòng gửi lại',
  'i18n_login_登录成功': 'Đăng nhập thành công',
  'i18n_login_登录失败': 'Đăng nhập thất bại',
  'i18n_login_验证码发送频繁请稍后再试': 'Gửi mã xác minh quá thường xuyên, vui lòng thử lại sau',
  
  // Apple 登录相关
  'i18n_login_使用Apple登录': 'Đăng nhập bằng Apple',
  'i18n_login_Apple登录认证': 'Xác thực đăng nhập Apple',
  'i18n_login_Apple登录失败': 'Đăng nhập Apple thất bại',
  'i18n_login_Apple授权失败': 'Ủy quyền Apple thất bại',
  'i18n_login_Apple认证失败': 'Xác thực Apple thất bại',
  'i18n_login_Apple登录不可用': 'Đăng nhập Apple không khả dụng',
  'i18n_login_当前设备不支持Apple登录': 'Thiết bị hiện tại không hỗ trợ đăng nhập Apple',
  'i18n_login_Apple登录发生未知错误': 'Lỗi không xác định xảy ra khi đăng nhập Apple',
  'i18n_login_Apple登录成功但未获取到token': 'Đăng nhập Apple thành công nhưng không nhận được token',
  'i18n_login_Apple服务器响应无效': 'Phản hồi máy chủ Apple không hợp lệ',
  'i18n_login_Apple登录请求未被处理': 'Yêu cầu đăng nhập Apple không được xử lý',
  
  // Web 认证相关
  'i18n_login_正在打开Web认证窗口': 'Đang mở cửa sổ xác thực web',
  'i18n_login_Web认证失败请重试': 'Xác thực web thất bại, vui lòng thử lại',
  'i18n_login_Web认证失败请检查网络连接': 'Xác thực web thất bại, vui lòng kiểm tra kết nối mạng',
  'i18n_login_Web认证发生未知错误': 'Lỗi không xác định xảy ra trong xác thực web',
  'i18n_login_Web认证响应无效': 'Phản hồi xác thực web không hợp lệ',
  'i18n_login_Web认证窗口加载失败': 'Tải cửa sổ xác thực web thất bại',
  'i18n_login_Web认证超时请重试': 'Xác thực web hết thời gian, vui lòng thử lại',
  'i18n_login_网络连接异常请检查网络': 'Kết nối mạng bất thường, vui lòng kiểm tra mạng',

  // 0727
  'i18n_login_没有收到验证码': 'Không nhận được mã xác minh',
  'i18n_login_验证手机号': 'Xác minh số điện thoại',
}; 
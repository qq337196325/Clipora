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


const Map<String, String> orderI18n = {
  // ai_order_page.dart
  'i18n_order_AI翻译请求包': 'Gói yêu cầu dịch thuật AI',
  'i18n_order_AI翻译助手': 'Trợ lý dịch thuật AI',
  'i18n_order_让阅读更智能': 'Làm cho việc đọc thông minh hơn, học tập hiệu quả hơn',
  'i18n_order_通过AI翻译助手': 'Với trợ lý dịch thuật AI, bạn có thể dịch bài viết sang nhiều ngôn ngữ.',
  'i18n_order_限时优惠': 'Ưu đãi có thời hạn',
  'i18n_order_原价': 'Giá gốc ¥@price',
  'i18n_order_AI请求次数': '@count yêu cầu AI',
  'i18n_order_足够深度阅读': 'Đủ cho một tháng đọc sâu',
  'i18n_order_有效期': '@days ngày có hiệu lực',
  'i18n_order_立即生效': 'Có hiệu lực ngay sau khi mua, thời gian đủ để trải nghiệm',
  'i18n_order_智能强大': 'Thông minh và mạnh mẽ',
  'i18n_order_AI大模型翻译': 'Dịch nội dung của bạn sang nhiều ngôn ngữ bằng các mô hình AI lớn',
  'i18n_order_核心功能': 'Tính năng cốt lõi',
  'i18n_order_多国语言支持': 'Hỗ trợ đa ngôn ngữ',
  'i18n_order_支持翻译和理解': 'Hỗ trợ dịch thuật và hiểu đa ngôn ngữ',
  'i18n_order_微信支付': 'WeChat Pay @price',
  'i18n_order_立即购买': 'Mua ngay @price',
  'i18n_order_购买前请阅读并同意': 'Vui lòng đọc và đồng ý trước khi mua',
  'i18n_order_购买协议': '《Thỏa thuận mua hàng》',
  'i18n_order_payment_failed_retry': 'Thanh toán thất bại, vui lòng thử lại',
  'i18n_order_payment_cancelled': 'Thanh toán đã bị hủy',
  'i18n_order_payment_error_retry_later': 'Lỗi thanh toán, vui lòng thử lại sau',
  'i18n_order_please_agree_to_terms': 'Vui lòng đọc và đồng ý với điều khoản sử dụng và chính sách bảo mật trước',
  'i18n_order_failed_to_initiate_payment': 'Không thể khởi tạo thanh toán, vui lòng kiểm tra WeChat đã được cài đặt',
  'i18n_order_failed_to_create_order': 'Không thể tạo đơn thanh toán, vui lòng thử lại sau',
  'i18n_order_payment_failed': 'Thanh toán thất bại',
  'i18n_order_item_unavailable': 'Mục không khả dụng, vui lòng thử lại sau',
  'i18n_order_network_error': 'Kết nối mạng thất bại, vui lòng kiểm tra mạng và thử lại',
  'i18n_order_payment_exception': 'Lỗi thanh toán: @message',
  'i18n_order_verification_failed_contact_support': 'Xác minh thanh toán thất bại, vui lòng liên hệ hỗ trợ khách hàng',
  'i18n_order_verification_exception_contact_support': 'Lỗi xác minh thanh toán, vui lòng liên hệ hỗ trợ khách hàng',
  'i18n_order_purchase_successful': 'Mua hàng thành công!',
  'i18n_order_ai_assistant_activated': 'Trợ lý AI đã được kích hoạt và sẵn sàng sử dụng!',
  'i18n_order_confirm': 'Xác nhận',
  'i18n_order_purchase_failed': 'Mua hàng thất bại',
  
  // member_order_page.dart
  'i18n_member_高级会员': 'Thành viên Cao cấp',
  'i18n_member_Clipora高级版': 'Clipora Cao cấp',
  'i18n_member_解锁全部功能潜力': 'Mở khóa toàn bộ tiềm năng tính năng',
  'i18n_member_享受高级功能': 'Tận hưởng các tính năng nâng cao, giúp việc đọc và quản lý kiến thức của bạn hiệu quả hơn',
  'i18n_member_限时买断': 'Mua đứt có thời hạn',
  'i18n_member_一次性购买': 'Mua một lần, trở thành thành viên vĩnh viễn',
  'i18n_member_未来订阅计划': 'Chúng tôi dự định tính phí theo thuê bao hàng năm và hàng tháng trong tương lai. Hiện tại, đây là hình thức mua một lần có giới hạn thời gian.',
  'i18n_member_现有数据保证': 'Đối với những người không phải là thành viên, chúng tôi đảm bảo rằng bạn luôn có thể sử dụng dữ liệu hiện có của mình miễn phí.',
  'i18n_member_终身更新': 'Hỗ trợ cập nhật miễn phí vĩnh viễn trong tương lai.',
  'i18n_member_无广告保证': 'Clipora đảm bảo không bao giờ thêm hoạt động kinh doanh quảng cáo để đảm bảo trải nghiệm người dùng của bạn. Hệ thống thành viên là nguồn thu nhập duy nhất của chúng tôi.',
  'i18n_member_高级特权': 'Đặc quyền Cao cấp',
  'i18n_member_无限同步': 'Đồng bộ không giới hạn',
  'i18n_member_无限同步描述': 'Đồng bộ hóa không giới hạn dữ liệu của bạn lên đám mây',
  'i18n_member_无限存储': 'Lưu trữ không giới hạn',
  'i18n_member_无限存储描述': 'Lưu trữ không giới hạn các bài viết và ghi chú của bạn',
  'i18n_member_高级功能': 'Tính năng nâng cao',
  'i18n_member_高级功能描述': 'Tận hưởng tất cả các tính năng nâng cao và trải nghiệm ưu tiên',
  'i18n_member_优先支持': 'Hỗ trợ ưu tiên',
  'i18n_member_优先支持描述': 'Tận hưởng hỗ trợ khách hàng và hỗ trợ kỹ thuật ưu tiên',
  'i18n_member_微信支付': 'Thanh toán qua WeChat @price',
  'i18n_member_立即购买': 'Mua ngay @price',
  'i18n_member_购买前请阅读并同意': 'Vui lòng đọc và đồng ý trước khi mua',
  'i18n_member_购买协议': '《Thỏa thuận mua hàng》',
  'i18n_member_payment_failed_retry': 'Thanh toán thất bại, vui lòng thử lại',
  'i18n_member_payment_cancelled': 'Thanh toán đã bị hủy',
  'i18n_member_payment_error_retry_later': 'Lỗi thanh toán, vui lòng thử lại sau',
  'i18n_member_please_agree_to_terms': 'Vui lòng đọc và đồng ý với thỏa thuận người dùng và chính sách bảo mật trước',
  'i18n_member_failed_to_initiate_payment': 'Không thể bắt đầu thanh toán, vui lòng kiểm tra xem WeChat đã được cài đặt chưa',
  'i18n_member_failed_to_create_order': 'Không thể tạo đơn hàng thanh toán, vui lòng thử lại sau',
  'i18n_member_payment_failed': 'Thanh toán thất bại',
  'i18n_member_item_unavailable': 'Mặt hàng không có sẵn, vui lòng thử lại sau',
  'i18n_member_network_error': 'Kết nối mạng không thành công, vui lòng kiểm tra mạng của bạn và thử lại',
  'i18n_member_payment_exception': 'Ngoại lệ thanh toán: @message',
  'i18n_member_verification_failed_contact_support': 'Xác minh thanh toán không thành công, vui lòng liên hệ với bộ phận hỗ trợ khách hàng',
  'i18n_member_verification_exception_contact_support': 'Ngoại lệ xác minh thanh toán, vui lòng liên hệ với bộ phận hỗ trợ khách hàng để được hỗ trợ',
  'i18n_member_upgrade_successful': 'Nâng cấp thành công!',
  'i18n_member_premium_activated': 'Thành viên cao cấp đã được kích hoạt, hãy tận hưởng tất cả các tính năng!',
  'i18n_member_confirm': 'Xác nhận',
  'i18n_member_upgrade_failed': 'Nâng cấp thất bại',
  'i18n_member_upgrade': 'Nâng cấp',
  'i18n_member_重要说明': 'Thông báo quan trọng',
  
  // 会员状态显示
  'i18n_member_终身会员': 'Thành viên trọn đời',
  'i18n_member_订阅会员': 'Thành viên đăng ký',
  'i18n_member_会员已激活': 'Tư cách thành viên đã được kích hoạt',
  'i18n_member_到期时间': 'Thời gian hết hạn: @date',
  'i18n_member_续费': 'Gia hạn',
  'i18n_member_感谢您的支持': 'Cảm ơn sự ủng hộ của bạn',
  'i18n_member_正在享受高级会员特权': 'Đang hưởng các đặc quyền của thành viên cao cấp',
  'i18n_member_永久访问权限': 'Quyền truy cập vĩnh viễn',
};
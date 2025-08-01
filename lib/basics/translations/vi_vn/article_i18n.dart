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




const Map<String, String> articleI18n = {
  'i18n_article_文章链接不存在': 'Liên kết bài viết không tồn tại',
  'i18n_article_无法打开该链接': 'Không thể mở liên kết này',
  'i18n_article_打开链接失败': 'Mở liên kết thất bại: ',
  'i18n_article_返回': 'Quay lại',
  'i18n_article_浏览器打开': 'Mở trong trình duyệt',
  'i18n_article_更多': 'Thêm',
  'i18n_article_正在加载文章': 'Đang tải bài viết...',
  'i18n_article_功能待开发': 'Tính năng đang phát triển',
  'i18n_article_链接已复制到剪贴板': 'Đã sao chép liên kết vào clipboard',
  'i18n_article_复制失败': 'Sao chép thất bại: ',
  'i18n_article_已标记为重要': 'Đã đánh dấu là quan trọng',
  'i18n_article_已取消重要标记': 'Đã bỏ đánh dấu quan trọng',
  'i18n_article_操作失败': 'Thao tác thất bại: ',
  'i18n_article_已归档': 'Đã lưu trữ',
  'i18n_article_已取消归档': 'Đã bỏ lưu trữ',
  'i18n_article_确认删除': 'Xác nhận xóa',
  'i18n_article_确定要删除这篇文章吗': 'Bạn có chắc chắn muốn xóa bài viết này không?',
  'i18n_article_取消': 'Hủy',
  'i18n_article_删除': 'Xóa',
  'i18n_article_文章已删除': 'Đã xóa bài viết',
  'i18n_article_复制链接': 'Sao chép liên kết',
  'i18n_article_AI翻译': 'Dịch AI',
  'i18n_article_标签': 'Thẻ',
  'i18n_article_移动': 'Di chuyển',
  'i18n_article_归档': 'Lưu trữ',
  'i18n_article_未分类': 'Chưa phân loại',
  'i18n_article_编辑标签': 'Chỉnh sửa thẻ',
  'i18n_article_完成': 'Hoàn thành',
  'i18n_article_创建': 'Tạo',
  'i18n_article_翻译': 'Dịch',
  'i18n_article_重试': 'Thử lại',
  'i18n_article_原文': 'Văn bản gốc',
  'i18n_article_英语': 'Tiếng Anh',
  'i18n_article_日语': 'Tiếng Nhật',
  'i18n_article_韩语': 'Tiếng Hàn',
  'i18n_article_法语': 'Tiếng Pháp',
  'i18n_article_德语': 'Tiếng Đức',
  'i18n_article_西班牙语': 'Tiếng Tây Ban Nha',
  'i18n_article_俄语': 'Tiếng Nga',
  'i18n_article_阿拉伯语': 'Tiếng Ả Rập',
  'i18n_article_葡萄牙语': 'Tiếng Bồ Đào Nha',
  'i18n_article_意大利语': 'Tiếng Ý',
  'i18n_article_荷兰语': 'Tiếng Hà Lan',
  'i18n_article_泰语': 'Tiếng Thái',
  'i18n_article_越南语': 'Tiếng Việt',
  'i18n_article_简体中文': 'Tiếng Trung Giản thể',
  'i18n_article_繁体中文': 'Tiếng Trung Phồn thể',
  'i18n_article_图文': 'Văn bản',
  'i18n_article_网页': 'Web',
  'i18n_article_快照': 'Ảnh chụp',
  'i18n_article_加载失败': 'Tải thất bại',
  'i18n_article_内容加载中': 'Đang tải nội dung...',
  'i18n_article_重新加载': 'Tải lại',
  'i18n_article_高亮已添加': 'Đã thêm highlight',
  'i18n_article_笔记已添加': 'Đã thêm ghi chú',
  'i18n_article_已复制': 'Đã sao chép: ',
  'i18n_article_复制': 'Sao chép',
  'i18n_article_高亮': 'Highlight',
  'i18n_article_笔记': 'Ghi chú',
  'i18n_article_选中文字': 'Văn bản đã chọn',
  'i18n_article_笔记内容': 'Nội dung ghi chú',
  'i18n_article_添加笔记': 'Thêm ghi chú',
  'i18n_article_删除标注': 'Xóa chú thích',
  'i18n_article_此操作无法撤销': 'Thao tác này không thể hoàn tác',
  'i18n_article_WebView未初始化': 'WebView chưa được khởi tạo',
  'i18n_article_快照保存成功': 'Lưu ảnh chụp thành công',
  'i18n_article_快照加载失败': 'Tải ảnh chụp thất bại',
  'i18n_article_初始化失败': 'Khởi tạo thất bại: ',

  'i18n_article_标注记录不存在': 'Bản ghi chú thích không tồn tại',
  'i18n_article_颜色已更新': 'Màu đã được cập nhật',
  'i18n_article_颜色更新失败': 'Cập nhật màu thất bại',
  'i18n_article_原文引用': 'Trích dẫn văn bản gốc',
  'i18n_article_查看笔记': 'Xem ghi chú',
  'i18n_article_该标注没有笔记内容': 'Chú thích này không có nội dung ghi chú',
  'i18n_article_查看笔记失败': 'Xem ghi chú thất bại',
  'i18n_article_笔记详情': 'Chi tiết ghi chú',
  'i18n_article_标注颜色': 'Màu chú thích',

  /// v1.3.0
  'i18n_article_阅读主题': 'Chủ đề đọc',
  
  // read_theme_widget
  'i18n_article_阅读设置': 'Cài đặt đọc',
  'i18n_article_字体大小': 'Kích thước phông chữ',
  'i18n_article_减小': 'Giảm',
  'i18n_article_增大': 'Tăng',
  'i18n_article_预览效果': 'Hiệu ứng xem trước',
  'i18n_article_重置为默认大小': 'Đặt lại về kích thước mặc định',
  'i18n_article_字体大小已重置': 'Kích thước phông chữ đã được đặt lại',
  
  // AI翻译相关
  'i18n_article_AI翻译不足': 'Tín dụng dịch AI không đủ',
  'i18n_article_AI翻译额度已用完提示': 'Tín dụng dịch AI đã hết',
  'i18n_article_您的翻译额度已用完': 'Tín dụng dịch của bạn đã hết',
  'i18n_article_前往充值': 'Đi nạp tiền',
  'i18n_article_以后再说': 'Để sau',
  'i18n_article_翻译失败': 'Dịch thất bại',
  'i18n_article_翻译完成': 'Dịch hoàn thành',
  'i18n_article_翻译请求失败': 'Yêu cầu dịch thất bại',
  'i18n_article_翻译请求失败请重试': 'Yêu cầu dịch thất bại, vui lòng thử lại',
  'i18n_article_正在翻译中': 'Đang dịch',
  'i18n_article_重新翻译': 'Dịch lại',
  'i18n_article_选择要翻译的目标语言': 'Chọn ngôn ngữ đích để dịch',
  'i18n_article_待翻译': 'Chờ dịch',
  
  // 快照相关
  'i18n_article_开始生成快照': 'Bắt đầu tạo ảnh chụp nhanh',
  'i18n_article_生成快照失败': 'Tạo ảnh chụp nhanh thất bại',
  'i18n_article_快照已保存路径': 'Ảnh chụp nhanh đã lưu trong đường dẫn',
  'i18n_article_快照文件不存在': 'Tệp ảnh chụp nhanh không tồn tại',
  'i18n_article_快照文件为空': 'Tệp ảnh chụp nhanh trống',
  'i18n_article_快照更新失败': 'Cập nhật ảnh chụp nhanh thất bại',
  'i18n_article_快照更新成功': 'Cập nhật ảnh chụp nhanh thành công',
  'i18n_article_保存快照失败': 'Lưu ảnh chụp nhanh thất bại',
  'i18n_article_保存快照到数据库失败': 'Lưu ảnh chụp nhanh vào cơ sở dữ liệu thất bại',
  'i18n_article_重新生成快照': 'Tạo lại ảnh chụp nhanh',
  'i18n_article_请切换到网页标签页生成快照': 'Vui lòng chuyển sang tab web để tạo ảnh chụp nhanh',
  'i18n_article_请切换到网页标签页进行操作': 'Vui lòng chuyển sang tab web để thao tác',
  
  // Markdown相关
  'i18n_article_Markdown更新失败': 'Cập nhật Markdown thất bại',
  'i18n_article_Markdown生成中请稍后查看': 'Markdown đang được tạo, vui lòng kiểm tra sau',
  'i18n_article_Markdown获取失败': 'Lấy Markdown thất bại',
  
  // 错误和状态
  'i18n_article_HTTP错误': 'Lỗi HTTP',
  'i18n_article_网页加载失败': 'Tải trang web thất bại',
  'i18n_article_网页未加载完成请稍后再试': 'Trang web chưa tải xong, vui lòng thử lại sau',
  'i18n_article_网站访问被限制提示': 'Truy cập trang web bị hạn chế',
  'i18n_article_重新加载失败提示': 'Tải lại thất bại',
  'i18n_article_重新加载时发生错误提示': 'Lỗi xảy ra khi tải lại',
  'i18n_article_重试失败提示': 'Thử lại thất bại',
  'i18n_article_加载错误文件路径': 'Đường dẫn tệp lỗi tải',
  'i18n_article_加载分类失败': 'Tải danh mục thất bại',
  'i18n_article_刷新解析': 'Làm mới phân tích',
  
  // 文章操作
  'i18n_article_删除失败': 'Xóa thất bại',
  'i18n_article_删除失败无法从页面中移除标注': 'Xóa thất bại, không thể xóa chú thích khỏi trang',
  'i18n_article_删除异常建议刷新页面': 'Xóa bất thường, khuyến nghị làm mới trang',
  'i18n_article_删除后的文章可以在回收站中找到': 'Bài viết đã xóa có thể tìm thấy trong thùng rác',
  'i18n_article_移动到分组': 'Di chuyển đến nhóm',
  'i18n_article_移动失败': 'Di chuyển thất bại',
  'i18n_article_成功移动到': 'Di chuyển thành công đến',
  'i18n_article_取消归档': 'Hủy lưu trữ',
  'i18n_article_取消重要': 'Xóa quan trọng',
  'i18n_article_标为重要': 'Đánh dấu là quan trọng',
  'i18n_article_设为未分类': 'Đặt là chưa phân loại',
  
  // 标签和内容
  'i18n_article_搜索或创建标签': 'Tìm kiếm hoặc tạo thẻ',
  'i18n_article_暂无标签': 'Không có thẻ',
  'i18n_article_标注内容': 'Nội dung chú thích',
  'i18n_article_标注已删除': 'Chú thích đã xóa',
  'i18n_article_正在删除标注': 'Đang xóa chú thích',
  'i18n_article_确定要删除以下标注吗': 'Bạn có chắc chắn muốn xóa các chú thích sau?',
  'i18n_article_高亮添加失败': 'Thêm đánh dấu thất bại',
  'i18n_article_笔记添加失败': 'Thêm ghi chú thất bại',
  'i18n_article_记录你的想法感悟或灵感': 'Ghi lại suy nghĩ, cảm nhận hoặc cảm hứng của bạn',
  
  // 其他
  'i18n_article_未找到文章': 'Không tìm thấy bài viết',
  'i18n_article_未知标题': 'Tiêu đề không xác định',
  'i18n_article_未知页面类型': 'Loại trang không xác định',
  'i18n_article_文章信息加载中请稍后重试': 'Đang tải thông tin bài viết, vui lòng thử lại sau',
  'i18n_article_文章信息获取失败': 'Lấy thông tin bài viết thất bại',
  'i18n_article_无法创建笔记文章信息缺失': 'Không thể tạo ghi chú, thiếu thông tin bài viết',
  'i18n_article_无法创建高亮文章信息缺失': 'Không thể tạo đánh dấu, thiếu thông tin bài viết',
  'i18n_article_无法复制内容为空': 'Không thể sao chép, nội dung trống',
  'i18n_article_复制失败请重试': 'Sao chép thất bại, vui lòng thử lại',
  'i18n_article_图文更新成功': 'Cập nhật hình ảnh và văn bản thành công',
  'i18n_article_内容超出字符限制提示': 'Nội dung vượt quá giới hạn ký tự',
  'i18n_article_已可用': 'Có sẵn',
  'i18n_article_查看': 'Xem',
}; 
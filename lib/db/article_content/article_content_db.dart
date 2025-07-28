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



import 'package:isar/isar.dart';

part 'article_content_db.g.dart'; // 用于代码生成

@collection
class ArticleContentDb {

  Id id = Isar.autoIncrement;
  @Index() String serviceId = "";                          // 服务端ID
  @Index() String uuid = ""; /// 服务端与客户端新建数据的时候都必须要有UUID,作为数据同步识别

  // 关联文章
  @Index() int articleId = 0;
  @Index() String serviceArticleId = "";                 // 文章服务端ID

  @Index() String userId = "";

  @Index()
  String languageCode = "";


  @Index() String markdown = "";                  // Markdown文档
  @Index() String textContent = "";               // [考虑是否停用，因为翻译的话是翻译 Markdown文档 ]纯文本、可以用于做搜索

  // 精确定位相关字段
  int markdownScrollY = 0;     // Markdown文档滚动Y位置
  int markdownScrollX = 0;     // Markdown文档滚动X位置
  String currentElementId = "";   // 当前可见元素的ID
  String currentElementText = ""; // 当前可见元素的文本片段(前100字符，用于备用定位)
  int currentElementOffset = 0;   // 当前元素在页面中的偏移量
  int viewportHeight = 0;         // 视窗高度(用于计算相对位置)
  int contentHeight = 0;          // 内容总高度
  DateTime? lastReadTime;         // 最后阅读时间

  bool isOriginal = true;     // 是否是源语言

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();
  DateTime? deletedAt;                         // 删除日期

  /// 版本号（用于冲突解决）
  @Index() int version = 1;
  @Index() int updateTimestamp = 0;
}

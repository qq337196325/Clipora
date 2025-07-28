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
import '../article/article_db.dart';

part 'tag_db.g.dart';

@collection
class TagDb {
  Id id = Isar.autoIncrement;
  @Index() String userId = "";
  @Index() String serviceId = "";
  @Index() String uuid = ""; /// 服务端与客户端新建数据的时候都必须要有UUID,作为数据同步识别

  @Index(caseSensitive: false)
  late String name;

  @Backlink(to: 'tags')
  final articles = IsarLinks<ArticleDb>();

  /// 版本号（用于冲突解决）
  @Index() int version = 1;
  @Index() int updateTimestamp = 0;

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();
  DateTime? deletedAt;                         // 删除日期
} 
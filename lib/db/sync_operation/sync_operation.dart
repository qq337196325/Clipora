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

part 'sync_operation.g.dart';

/// 代表一个需要与服务器同步的数据操作
@Collection()
class SyncOperation {
  /// Isar 数据库的本地自增ID
  Id id = Isar.autoIncrement;

  /// 操作类型 (create, update, delete)
  @Enumerated(EnumType.name)
  late SyncOp operation;

  /// 被操作的数据集合名称 (例如: "Note", "Bookmark")
  /// 这可以帮助我们定位到正确的API端点和本地表
  late String collectionName;

  /// 被操作实体的全局唯一ID
  /// - 对于新创建的离线数据, 这是一个客户端生成的临时UUID
  /// - 对于已同步的数据, 这是服务端的数据库ID (如 MongoDB ObjectID)
  @Index()
  late String entityId;

  /// 操作的数据负载，以JSON字符串形式存储
  /// - 'create' 和 'update' 操作需要
  /// - 'delete' 操作时可以为 null
  String? data;

  /// 操作发生时的时间戳，用于保证操作顺序
  late DateTime timestamp;

  /// 当前的同步状态
  @Enumerated(EnumType.name)
  @Index()
  late SyncStatus status;
}

/// 同步操作的类型
enum SyncOp {
  create,
  update,
  delete,
}

/// 同步操作的状态
enum SyncStatus {
  /// 待同步
  pending,
  /// 已同步
  synced,
  /// 同步失败
  failed,
} 




import '../../../../basics/utils/user_utils.dart';
import '../../../../db/tag/tag_db.dart';
import '../models/tag_model.dart';

/// 从TagModel创建TagDb
TagDb createTagFromModel(TagModel model) {
  final now = DateTime.now();
  return TagDb()
    ..userId = model.userId
    ..serviceId = model.id
    ..name = model.name
    ..uuid = model.uuid
    ..version = model.version
    ..updateTimestamp = model.updateTimestamp
    ..createdAt = parseDateTime(model.createTime) ?? now
    ..updatedAt = parseDateTime(model.updateTime) ?? now;
}

/// 更新TagDb从TagModel
void updateTagFromModel(TagDb tag, TagModel model) {
  tag.userId = model.userId;
  tag.serviceId = model.id;
  tag.name = model.name;
  tag.version = model.version;
  tag.updateTimestamp = model.updateTimestamp;
  tag.updatedAt = parseDateTime(model.updateTime) ?? DateTime.now();
}


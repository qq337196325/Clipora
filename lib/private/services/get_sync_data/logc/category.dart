


import '../../../../db/category/category_db.dart';
import '../models/category_model.dart';

/// 从CategoryModel创建CategoryDb
CategoryDb createCategoryFromModel(CategoryModel model) {
  final now = DateTime.now();
  return CategoryDb()
    ..userId = model.userId
    ..serverId = model.id
    ..name = model.name
    ..description = model.description.isNotEmpty ? model.description : null
    ..icon = model.icon.isNotEmpty ? model.icon : null
    ..color = model.color.isNotEmpty ? model.color : null
    ..sortOrder = model.sortOrder
    ..isEnabled = model.isEnabled
    ..isDeleted = model.isDeleted
    ..parentId = model.parentId > 0 ? model.parentId : null
    ..level = model.level
    ..path = model.path
    ..version = model.version
    ..uuid = model.uuid
    ..updateTimestamp = model.updateTimestamp
    ..isSynced = true
    ..createdAt = now
    ..updatedAt = now;
}

/// 更新CategoryDb从CategoryModel
void updateCategoryFromModel(CategoryDb category, CategoryModel model) {
  category.userId = model.userId;
  category.serverId = model.id;
  category.name = model.name;
  category.description = model.description.isNotEmpty ? model.description : null;
  category.icon = model.icon.isNotEmpty ? model.icon : null;
  category.color = model.color.isNotEmpty ? model.color : null;
  category.sortOrder = model.sortOrder;
  category.isEnabled = model.isEnabled;
  category.isDeleted = model.isDeleted;
  category.parentId = model.parentId > 0 ? model.parentId : null;
  category.level = model.level;
  category.path = model.path;
  category.version = model.version;
  category.updateTimestamp = model.updateTimestamp;
  category.isSynced = true;
  category.updatedAt = DateTime.now();
}




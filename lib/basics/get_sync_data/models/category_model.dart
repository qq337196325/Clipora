class CategoryModel {
  final String id;
  final String userId;
  final String createById;
  final String updateById;
  final String deleteById;
  final String createTime;
  final String updateTime;
  final int clientId;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isEnabled;
  final bool isDeleted;
  final int parentId;
  final int level;
  final String path;
  final int version;
  final int updateTimestamp;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.createById,
    required this.updateById,
    required this.deleteById,
    required this.createTime,
    required this.updateTime,
    required this.clientId,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.isEnabled,
    required this.isDeleted,
    required this.parentId,
    required this.level,
    required this.path,
    required this.version,
    required this.updateTimestamp,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      createById: json['create_by_id'] ?? '',
      updateById: json['update_by_id'] ?? '',
      deleteById: json['delete_by_id'] ?? '',
      createTime: json['create_time'] ?? '',
      updateTime: json['update_time'] ?? '',
      clientId: json['client_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      isEnabled: json['is_enabled'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      parentId: json['parent_id'] ?? 0,
      level: json['level'] ?? 0,
      path: json['path'] ?? '',
      version: json['version'] ?? 0,
      updateTimestamp: json['update_timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'create_by_id': createById,
      'update_by_id': updateById,
      'delete_by_id': deleteById,
      'create_time': createTime,
      'update_time': updateTime,
      'client_id': clientId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'is_enabled': isEnabled,
      'is_deleted': isDeleted,
      'parent_id': parentId,
      'level': level,
      'path': path,
      'version': version,
      'update_timestamp': updateTimestamp,
    };
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, description: $description, icon: $icon, isEnabled: $isEnabled}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? createById,
    String? updateById,
    String? deleteById,
    String? createTime,
    String? updateTime,
    int? clientId,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isEnabled,
    bool? isDeleted,
    int? parentId,
    int? level,
    String? path,
    int? version,
    int? updateTimestamp,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createById: createById ?? this.createById,
      updateById: updateById ?? this.updateById,
      deleteById: deleteById ?? this.deleteById,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      isDeleted: isDeleted ?? this.isDeleted,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      path: path ?? this.path,
      version: version ?? this.version,
      updateTimestamp: updateTimestamp ?? this.updateTimestamp,
    );
  }
}




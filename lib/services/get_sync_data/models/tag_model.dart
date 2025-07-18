class TagModel {
  final String id;
  final String userId;
  final String createById;
  final String updateById;
  final String deleteById;
  final String createTime;
  final String updateTime;
  final int clientId;
  final String name;
  final int version;
  final int updateTimestamp;
  final String uuid;

  const TagModel({
    required this.id,
    required this.userId,
    required this.createById,
    required this.updateById,
    required this.deleteById,
    required this.createTime,
    required this.updateTime,
    required this.clientId,
    required this.name,
    required this.version,
    required this.updateTimestamp,
    required this.uuid,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      createById: json['create_by_id'] as String? ?? '',
      updateById: json['update_by_id'] as String? ?? '',
      deleteById: json['delete_by_id'] as String? ?? '',
      createTime: json['create_time'] as String? ?? '',
      updateTime: json['update_time'] as String? ?? '',
      clientId: json['client_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      updateTimestamp: json['update_timestamp'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? "",
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
      'version': version,
      'update_timestamp': updateTimestamp,
      'uuid': uuid,
    };
  }

  TagModel copyWith({
    String? id,
    String? userId,
    String? createById,
    String? updateById,
    String? deleteById,
    String? createTime,
    String? updateTime,
    int? clientId,
    String? name,
    int? version,
    int? updateTimestamp,
    String? uuid,
  }) {
    return TagModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createById: createById ?? this.createById,
      updateById: updateById ?? this.updateById,
      deleteById: deleteById ?? this.deleteById,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      version: version ?? this.version,
      updateTimestamp: updateTimestamp ?? this.updateTimestamp,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  String toString() {
    return 'TagModel(id: $id, name: $name, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 
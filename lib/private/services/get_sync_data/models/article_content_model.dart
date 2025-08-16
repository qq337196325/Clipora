class ArticleContentModel {
  final String id;
  final String userId;
  final String createById;
  final String updateById;
  final String deleteById;
  final String createTime;
  final String updateTime;
  final String serviceArticleId;
  final int articleId;
  final int clientId;
  final String languageCode;
  final String markdown;
  final String textContent;
  final bool isOriginal;
  final String upId;
  final int version;
  final int updateTimestamp;
  final String uuid;
  final String staticFilePath;

  const ArticleContentModel({
    required this.id,
    required this.userId,
    required this.createById,
    required this.updateById,
    required this.deleteById,
    required this.createTime,
    required this.updateTime,
    required this.serviceArticleId,
    required this.articleId,
    required this.clientId,
    required this.languageCode,
    required this.markdown,
    required this.textContent,
    required this.isOriginal,
    required this.upId,
    required this.version,
    required this.updateTimestamp,
    required this.uuid,
    required this.staticFilePath,
  });

  factory ArticleContentModel.fromJson(Map<String, dynamic> json) {
    return ArticleContentModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      createById: json['create_by_id'] as String? ?? '',
      updateById: json['update_by_id'] as String? ?? '',
      deleteById: json['delete_by_id'] as String? ?? '',
      createTime: json['create_time'] as String? ?? '',
      updateTime: json['update_time'] as String? ?? '',
      serviceArticleId: json['service_article_id'] as String? ?? '',
      articleId: json['article_id'] as int? ?? 0,
      clientId: json['client_id'] as int? ?? 0,
      languageCode: json['language_code'] as String? ?? '',
      markdown: json['markdown'] as String? ?? '',
      textContent: json['text_content'] as String? ?? '',
      isOriginal: json['is_original'] as bool? ?? false,
      upId: json['up_id'] as String? ?? '',
      version: json['version'] as int? ?? 0,
      updateTimestamp: json['update_timestamp'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? "",
      staticFilePath: json['static_file_path'] as String? ?? "",
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
      'service_article_id': serviceArticleId,
      'article_id': articleId,
      'client_id': clientId,
      'language_code': languageCode,
      'markdown': markdown,
      'text_content': textContent,
      'is_original': isOriginal,
      'up_id': upId,
      'version': version,
      'update_timestamp': updateTimestamp,
      'uuid': uuid,
      'static_file_path': staticFilePath,
    };
  }

  ArticleContentModel copyWith({
    String? id,
    String? userId,
    String? createById,
    String? updateById,
    String? deleteById,
    String? createTime,
    String? updateTime,
    String? serviceArticleId,
    int? articleId,
    int? clientId,
    String? languageCode,
    String? markdown,
    String? textContent,
    bool? isOriginal,
    String? upId,
    int? version,
    int? updateTimestamp,
    String? uuid,
    String? staticFilePath,
  }) {
    return ArticleContentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createById: createById ?? this.createById,
      updateById: updateById ?? this.updateById,
      deleteById: deleteById ?? this.deleteById,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      serviceArticleId: serviceArticleId ?? this.serviceArticleId,
      articleId: articleId ?? this.articleId,
      clientId: clientId ?? this.clientId,
      languageCode: languageCode ?? this.languageCode,
      markdown: markdown ?? this.markdown,
      textContent: textContent ?? this.textContent,
      isOriginal: isOriginal ?? this.isOriginal,
      upId: upId ?? this.upId,
      version: version ?? this.version,
      updateTimestamp: updateTimestamp ?? this.updateTimestamp,
      uuid: uuid ?? this.uuid,
      staticFilePath: staticFilePath ?? this.staticFilePath,
    );
  }

  @override
  String toString() {
    return 'ArticleContentModel(id: $id, serviceArticleId: $serviceArticleId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleContentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

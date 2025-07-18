class ArticleModel {
  final String id;
  final String userId;
  final String createById;
  final String updateById;
  final String deleteById;
  final String createTime;
  final String updateTime;
  final int clientArticleId;
  final String title;
  final String domain;
  final String author;
  final String articleDate;
  final String url;
  final String shareOriginalContent;
  final String markdownPath;
  final String outputDir;
  final String markdownName;
  final String mhtmlPath;
  final String textContent;
  final String markdown;
  final int markdownStatus;
  final int isRead;
  final int readCount;
  final int readDuration;
  final int readProgress;
  final bool isArchived;
  final bool isImportant;
  final int version;
  final int updateTimestamp;
  final String uuid;
  final List<String> tagServiceIds;
  final List<String> categoryServiceIds;

  const ArticleModel({
    required this.id,
    required this.userId,
    required this.createById,
    required this.updateById,
    required this.deleteById,
    required this.createTime,
    required this.updateTime,
    required this.clientArticleId,
    required this.title,
    required this.domain,
    required this.author,
    required this.articleDate,
    required this.url,
    required this.shareOriginalContent,
    required this.markdownPath,
    required this.outputDir,
    required this.markdownName,
    required this.mhtmlPath,
    required this.textContent,
    required this.markdown,
    required this.markdownStatus,
    required this.isRead,
    required this.readCount,
    required this.readDuration,
    required this.readProgress,
    required this.isArchived,
    required this.isImportant,
    required this.version,
    required this.updateTimestamp,
    required this.uuid,
    required this.tagServiceIds,
    required this.categoryServiceIds,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      createById: json['create_by_id'] as String? ?? '',
      updateById: json['update_by_id'] as String? ?? '',
      deleteById: json['delete_by_id'] as String? ?? '',
      createTime: json['create_time'] as String? ?? '',
      updateTime: json['update_time'] as String? ?? '',
      clientArticleId: json['client_article_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      author: json['author'] as String? ?? '',
      articleDate: json['article_date'] as String? ?? '',
      url: json['url'] as String? ?? '',
      shareOriginalContent: json['share_original_content'] as String? ?? '',
      markdownPath: json['markdown_path'] as String? ?? '',
      outputDir: json['output_dir'] as String? ?? '',
      markdownName: json['markdown_name'] as String? ?? '',
      mhtmlPath: json['mhtml_path'] as String? ?? '',
      textContent: json['text_content'] as String? ?? '',
      markdown: json['markdown'] as String? ?? '',
      markdownStatus: json['markdown_status'] as int? ?? 0,
      isRead: json['is_read'] as int? ?? 0,
      readCount: json['read_count'] as int? ?? 0,
      readDuration: json['read_duration'] as int? ?? 0,
      readProgress: json['read_progress'] as int? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      isImportant: json['is_important'] as bool? ?? false,
      version: json['version'] as int? ?? 0,
      updateTimestamp: json['update_timestamp'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? "",
      tagServiceIds: json['tag_service_ids'] == null ? [] : List<String>.from(json["tag_service_ids"].map((x) => x)),
      categoryServiceIds: json['category_service_ids'] == null ? [] : List<String>.from(json["category_service_ids"].map((x) => x)),
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
      'client_article_id': clientArticleId,
      'title': title,
      'domain': domain,
      'author': author,
      'article_date': articleDate,
      'url': url,
      'share_original_content': shareOriginalContent,
      'markdown_path': markdownPath,
      'output_dir': outputDir,
      'markdown_name': markdownName,
      'mhtml_path': mhtmlPath,
      'text_content': textContent,
      'markdown': markdown,
      'markdown_status': markdownStatus,
      'is_read': isRead,
      'read_count': readCount,
      'read_duration': readDuration,
      'read_progress': readProgress,
      'is_archived': isArchived,
      'is_important': isImportant,
      'version': version,
      'update_timestamp': updateTimestamp,
      'uuid': uuid,
    };
  }

  ArticleModel copyWith({
    String? id,
    String? userId,
    String? createById,
    String? updateById,
    String? deleteById,
    String? createTime,
    String? updateTime,
    int? clientArticleId,
    String? title,
    String? domain,
    String? author,
    String? articleDate,
    String? url,
    String? shareOriginalContent,
    String? markdownPath,
    String? outputDir,
    String? markdownName,
    String? mhtmlPath,
    String? textContent,
    String? markdown,
    int? markdownStatus,
    int? isRead,
    int? readCount,
    int? readDuration,
    int? readProgress,
    bool? isArchived,
    bool? isImportant,
    int? version,
    int? updateTimestamp,
    String? uuid,

    List<String>? tagServiceIds,
    List<String>? categoryServiceIds,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createById: createById ?? this.createById,
      updateById: updateById ?? this.updateById,
      deleteById: deleteById ?? this.deleteById,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      clientArticleId: clientArticleId ?? this.clientArticleId,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      author: author ?? this.author,
      articleDate: articleDate ?? this.articleDate,
      url: url ?? this.url,
      shareOriginalContent: shareOriginalContent ?? this.shareOriginalContent,
      markdownPath: markdownPath ?? this.markdownPath,
      outputDir: outputDir ?? this.outputDir,
      markdownName: markdownName ?? this.markdownName,
      mhtmlPath: mhtmlPath ?? this.mhtmlPath,
      textContent: textContent ?? this.textContent,
      markdown: markdown ?? this.markdown,
      markdownStatus: markdownStatus ?? this.markdownStatus,
      isRead: isRead ?? this.isRead,
      readCount: readCount ?? this.readCount,
      readDuration: readDuration ?? this.readDuration,
      readProgress: readProgress ?? this.readProgress,
      isArchived: isArchived ?? this.isArchived,
      isImportant: isImportant ?? this.isImportant,
      version: version ?? this.version,
      updateTimestamp: updateTimestamp ?? this.updateTimestamp,
      uuid: uuid ?? this.uuid,
      tagServiceIds: tagServiceIds ?? this.tagServiceIds,
      categoryServiceIds: categoryServiceIds ?? this.categoryServiceIds,
    );
  }

  @override
  String toString() {
    return 'ArticleModel(id: $id, title: $title, url: $url, isRead: $isRead, isArchived: $isArchived)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

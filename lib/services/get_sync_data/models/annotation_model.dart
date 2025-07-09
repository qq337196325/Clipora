class AnnotationModel {
  final String id;
  final String userId;
  final String createById;
  final String updateById;
  final String deleteById;
  final String createTime;
  final String updateTime;
  final int clientId;
  final int clientArticleId;
  final int clientArticleContentId;
  final String highlightId;
  final String startXPath;
  final int startOffset;
  final String endXPath;
  final int endOffset;
  final String selectedText;
  final String beforeContext;
  final String afterContext;
  final String annotationType;
  final String colorType;
  final String noteContent;
  final bool crossParagraph;
  final String rangeFingerprint;
  final double boundingX;
  final double boundingY;
  final double boundingWidth;
  final double boundingHeight;
  final int version;
  final int updateTimestamp;

  const AnnotationModel({
    required this.id,
    required this.userId,
    required this.createById,
    required this.updateById,
    required this.deleteById,
    required this.createTime,
    required this.updateTime,
    required this.clientId,
    required this.clientArticleId,
    required this.clientArticleContentId,
    required this.highlightId,
    required this.startXPath,
    required this.startOffset,
    required this.endXPath,
    required this.endOffset,
    required this.selectedText,
    required this.beforeContext,
    required this.afterContext,
    required this.annotationType,
    required this.colorType,
    required this.noteContent,
    required this.crossParagraph,
    required this.rangeFingerprint,
    required this.boundingX,
    required this.boundingY,
    required this.boundingWidth,
    required this.boundingHeight,
    required this.version,
    required this.updateTimestamp,
  });

  factory AnnotationModel.fromJson(Map<String, dynamic> json) {
    return AnnotationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      createById: json['create_by_id'] as String? ?? '',
      updateById: json['update_by_id'] as String? ?? '',
      deleteById: json['delete_by_id'] as String? ?? '',
      createTime: json['create_time'] as String? ?? '',
      updateTime: json['update_time'] as String? ?? '',
      clientId: json['client_id'] as int? ?? 0,
      clientArticleId: json['client_article_id'] as int? ?? 0,
      clientArticleContentId: json['client_article_content_id'] as int? ?? 0,
      highlightId: json['highlight_id'] as String? ?? '',
      startXPath: json['start_x_path'] as String? ?? '',
      startOffset: json['start_offset'] as int? ?? 0,
      endXPath: json['end_x_path'] as String? ?? '',
      endOffset: json['end_offset'] as int? ?? 0,
      selectedText: json['selected_text'] as String? ?? '',
      beforeContext: json['before_context'] as String? ?? '',
      afterContext: json['after_context'] as String? ?? '',
      annotationType: json['annotation_type'] as String? ?? '',
      colorType: json['color_type'] as String? ?? '',
      noteContent: json['note_content'] as String? ?? '',
      crossParagraph: json['cross_paragraph'] as bool? ?? false,
      rangeFingerprint: json['range_fingerprint'] as String? ?? '',
      boundingX: (json['bounding_x'] as num?)?.toDouble() ?? 0.0,
      boundingY: (json['bounding_y'] as num?)?.toDouble() ?? 0.0,
      boundingWidth: (json['bounding_width'] as num?)?.toDouble() ?? 0.0,
      boundingHeight: (json['bounding_height'] as num?)?.toDouble() ?? 0.0,
      version: json['version'] as int? ?? 1,
      updateTimestamp: json['update_timestamp'] as int? ?? 0,
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
      'client_article_id': clientArticleId,
      'client_article_content_id': clientArticleContentId,
      'highlight_id': highlightId,
      'start_x_path': startXPath,
      'start_offset': startOffset,
      'end_x_path': endXPath,
      'end_offset': endOffset,
      'selected_text': selectedText,
      'before_context': beforeContext,
      'after_context': afterContext,
      'annotation_type': annotationType,
      'color_type': colorType,
      'note_content': noteContent,
      'cross_paragraph': crossParagraph,
      'range_fingerprint': rangeFingerprint,
      'bounding_x': boundingX,
      'bounding_y': boundingY,
      'bounding_width': boundingWidth,
      'bounding_height': boundingHeight,
      'version': version,
      'update_timestamp': updateTimestamp,
    };
  }

  AnnotationModel copyWith({
    String? id,
    String? userId,
    String? createById,
    String? updateById,
    String? deleteById,
    String? createTime,
    String? updateTime,
    int? clientId,
    int? clientArticleId,
    int? clientArticleContentId,
    String? highlightId,
    String? startXPath,
    int? startOffset,
    String? endXPath,
    int? endOffset,
    String? selectedText,
    String? beforeContext,
    String? afterContext,
    String? annotationType,
    String? colorType,
    String? noteContent,
    bool? crossParagraph,
    String? rangeFingerprint,
    double? boundingX,
    double? boundingY,
    double? boundingWidth,
    double? boundingHeight,
    int? version,
    int? updateTimestamp,
  }) {
    return AnnotationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createById: createById ?? this.createById,
      updateById: updateById ?? this.updateById,
      deleteById: deleteById ?? this.deleteById,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      clientId: clientId ?? this.clientId,
      clientArticleId: clientArticleId ?? this.clientArticleId,
      clientArticleContentId: clientArticleContentId ?? this.clientArticleContentId,
      highlightId: highlightId ?? this.highlightId,
      startXPath: startXPath ?? this.startXPath,
      startOffset: startOffset ?? this.startOffset,
      endXPath: endXPath ?? this.endXPath,
      endOffset: endOffset ?? this.endOffset,
      selectedText: selectedText ?? this.selectedText,
      beforeContext: beforeContext ?? this.beforeContext,
      afterContext: afterContext ?? this.afterContext,
      annotationType: annotationType ?? this.annotationType,
      colorType: colorType ?? this.colorType,
      noteContent: noteContent ?? this.noteContent,
      crossParagraph: crossParagraph ?? this.crossParagraph,
      rangeFingerprint: rangeFingerprint ?? this.rangeFingerprint,
      boundingX: boundingX ?? this.boundingX,
      boundingY: boundingY ?? this.boundingY,
      boundingWidth: boundingWidth ?? this.boundingWidth,
      boundingHeight: boundingHeight ?? this.boundingHeight,
      version: version ?? this.version,
      updateTimestamp: updateTimestamp ?? this.updateTimestamp,
    );
  }

  @override
  String toString() {
    return 'AnnotationModel(id: $id, highlightId: $highlightId, selectedText: $selectedText, annotationType: $annotationType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnnotationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 
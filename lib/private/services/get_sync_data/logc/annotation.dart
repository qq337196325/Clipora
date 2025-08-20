



import '../../../../basics/logger.dart';
import '../../../../basics/utils/user_utils.dart';
import '../../../../db/annotation/enhanced_annotation_db.dart';
import '../models/annotation_model.dart';

/// 更新EnhancedAnnotationDb从AnnotationModel
void updateAnnotationFromModel(EnhancedAnnotationDb annotation, AnnotationModel model, int localArticleId, int localArticleContentId) {
  annotation.userId = model.userId;
  annotation.articleId = localArticleId;
  annotation.articleContentId = localArticleContentId;
  annotation.highlightId = model.highlightId;
  annotation.startXPath = model.startXPath;
  annotation.startOffset = model.startOffset;
  annotation.endXPath = model.endXPath;
  annotation.endOffset = model.endOffset;
  annotation.selectedText = model.selectedText;
  annotation.beforeContext = model.beforeContext;
  annotation.afterContext = model.afterContext;
  annotation.annotationType = _parseAnnotationType(model.annotationType);
  annotation.colorType = _parseAnnotationColor(model.colorType);
  annotation.noteContent = model.noteContent;
  annotation.crossParagraph = model.crossParagraph;
  annotation.rangeFingerprint = model.rangeFingerprint;
  annotation.boundingX = model.boundingX;
  annotation.boundingY = model.boundingY;
  annotation.boundingWidth = model.boundingWidth;
  annotation.boundingHeight = model.boundingHeight;
  annotation.version = model.version;
  annotation.updateTimestamp = model.updateTimestamp;
  annotation.updatedAt = parseDateTime(model.updateTime) ?? DateTime.now();
  annotation.isSynced = true;
}

/// 从AnnotationModel创建EnhancedAnnotationDb
EnhancedAnnotationDb createAnnotationFromModel(AnnotationModel model, int localArticleId, int localArticleContentId) {
  final now = DateTime.now();
  return EnhancedAnnotationDb()
    ..userId = model.userId
    ..articleId = localArticleId
    ..articleContentId = localArticleContentId
    ..highlightId = model.highlightId
    ..startXPath = model.startXPath
    ..startOffset = model.startOffset
    ..endXPath = model.endXPath
    ..endOffset = model.endOffset
    ..selectedText = model.selectedText
    ..beforeContext = model.beforeContext
    ..afterContext = model.afterContext
    ..annotationType = _parseAnnotationType(model.annotationType)
    ..colorType = _parseAnnotationColor(model.colorType)
    ..noteContent = model.noteContent
    ..crossParagraph = model.crossParagraph
    ..rangeFingerprint = model.rangeFingerprint
    ..boundingX = model.boundingX
    ..boundingY = model.boundingY
    ..boundingWidth = model.boundingWidth
    ..boundingHeight = model.boundingHeight
    ..version = model.version
    ..uuid = model.uuid
    ..updateTimestamp = model.updateTimestamp
    ..createdAt = parseDateTime(model.createTime) ?? now
    ..updatedAt = parseDateTime(model.updateTime) ?? now
    ..isSynced = true;
}



/// 解析标注类型字符串为枚举
AnnotationType _parseAnnotationType(String type) {
  switch (type.toLowerCase()) {
    case 'highlight':
      return AnnotationType.highlight;
    case 'note':
      return AnnotationType.note;
    default:
      getLogger().w('⚠️ 未知的标注类型: $type，使用默认值 highlight');
      return AnnotationType.highlight;
  }
}

/// 解析颜色类型字符串为枚举
AnnotationColor _parseAnnotationColor(String color) {
  switch (color.toLowerCase()) {
    case 'yellow':
      return AnnotationColor.yellow;
    case 'green':
      return AnnotationColor.green;
    case 'blue':
      return AnnotationColor.blue;
    case 'red':
      return AnnotationColor.red;
    case 'purple':
      return AnnotationColor.purple;
    case 'pink':
      return AnnotationColor.pink;
    default:
      getLogger().w('⚠️ 未知的颜色类型: $color，使用默认值 yellow');
      return AnnotationColor.yellow;
  }
}
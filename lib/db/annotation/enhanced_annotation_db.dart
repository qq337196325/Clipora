import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

part 'enhanced_annotation_db.g.dart';

@collection
class EnhancedAnnotationDb {
  Id id = Isar.autoIncrement;
  @Index() String userId = "";

  // 关联文章（旧版，现在改成为 articleContentId）
  @Index()
  int articleId = 0;

  // 关联文章内容 新版
  @Index()
  int articleContentId = 0;
  

  @Index(unique: true, replace: true)
  String highlightId = "";  // 高亮HTML元素的唯一ID

  // === Range精确定位信息 ===
  String startXPath = "";        // 开始节点的XPath路径
  int startOffset = 0;           // 在开始节点中的偏移量
  String endXPath = "";          // 结束节点的XPath路径
  int endOffset = 0;             // 在结束节点中的偏移量

  // === 文本信息 ===
  String selectedText = "";      // 选中的文本内容
  String beforeContext = "";     // 前文（用于容错匹配）
  String afterContext = "";      // 后文（用于容错匹配）
  
  // === 标注属性 ===
  @Index()
  @Enumerated(EnumType.ordinal)
  AnnotationType annotationType = AnnotationType.highlight;  // 标注类型
  
  @Index()
  @Enumerated(EnumType.ordinal)
  AnnotationColor colorType = AnnotationColor.yellow;      // 颜色类型
  
  String noteContent = "";       // 笔记内容

  // === 特殊属性 ===
  bool crossParagraph = false;   // 是否跨段落标注
  String rangeFingerprint = "";  // Range指纹（用于验证）
  
  // === 位置信息（用于菜单显示） ===
  double boundingX = 0.0;        // 边界框X坐标
  double boundingY = 0.0;        // 边界框Y坐标
  double boundingWidth = 0.0;    // 边界框宽度
  double boundingHeight = 0.0;   // 边界框高度

  // === 元数据 ===
  @Index()
  DateTime createdAt = DateTime.now();
  
  @Index()
  DateTime updatedAt = DateTime.now();

  // === 辅助字段 ===
  int version = 1;               // 数据版本（用于迁移）
  String? backupData;            // 备份数据（JSON格式）

  // === 构造函数 ===
  EnhancedAnnotationDb();

  // 工厂方法：从选择数据创建高亮标注
  factory EnhancedAnnotationDb.fromSelectionData(
    Map<String, dynamic> selectionData,
    int articleId,
    AnnotationType annotationType, {
    AnnotationColor colorType = AnnotationColor.yellow,
    String noteContent = '',
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final highlightId = 'highlight_${timestamp}_${selectionData['selectedText']?.hashCode ?? 0}';
    
    final annotation = EnhancedAnnotationDb()
      ..articleId = articleId
      ..highlightId = highlightId
      ..startXPath = selectionData['startXPath'] ?? ''
      ..startOffset = selectionData['startOffset'] ?? 0
      ..endXPath = selectionData['endXPath'] ?? ''
      ..endOffset = selectionData['endOffset'] ?? 0
      ..selectedText = selectionData['selectedText'] ?? ''
      ..beforeContext = selectionData['beforeContext'] ?? ''
      ..afterContext = selectionData['afterContext'] ?? ''
      ..annotationType = annotationType
      ..colorType = colorType
      ..noteContent = noteContent
      ..crossParagraph = selectionData['crossParagraph'] ?? false
      ..rangeFingerprint = _generateFingerprint(selectionData)
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..version = 1;

    // 设置边界框信息
    final boundingRect = selectionData['boundingRect'] as Map<String, dynamic>?;
    if (boundingRect != null) {
      annotation
        ..boundingX = (boundingRect['x'] ?? 0).toDouble()
        ..boundingY = (boundingRect['y'] ?? 0).toDouble()
        ..boundingWidth = (boundingRect['width'] ?? 0).toDouble()
        ..boundingHeight = (boundingRect['height'] ?? 0).toDouble();
    }

    // 创建备份数据
    annotation.backupData = jsonEncode({
      'originalSelectionData': selectionData,
      'createdAt': timestamp,
      'version': 1,
    });

    return annotation;
  }

  // 生成Range指纹
  static String _generateFingerprint(Map<String, dynamic> selectionData) {
    final content = '${selectionData['selectedText']}_${selectionData['beforeContext']}_${selectionData['afterContext']}';
    return content.hashCode.toString();
  }

  // 转换为Range数据格式
  Map<String, dynamic> toRangeData() {
    return {
      'startXPath': startXPath,
      'startOffset': startOffset,
      'endXPath': endXPath,
      'endOffset': endOffset,
      'selectedText': selectedText,
      'beforeContext': beforeContext,
      'afterContext': afterContext,
      'crossParagraph': crossParagraph,
      'highlightId': highlightId,
      'colorType': colorType.cssClass,
      'noteContent': noteContent.isNotEmpty ? noteContent : null,
      'boundingRect': {
        'x': boundingX,
        'y': boundingY,
        'width': boundingWidth,
        'height': boundingHeight,
      },
      'rangeFingerprint': rangeFingerprint,
      'annotationType': annotationType.name,
    };
  }

  // 从备份数据恢复
  static EnhancedAnnotationDb? fromBackupData(String backupData) {
    try {
      final data = jsonDecode(backupData) as Map<String, dynamic>;
      final originalSelectionData = data['originalSelectionData'] as Map<String, dynamic>;
      
      return EnhancedAnnotationDb.fromSelectionData(
        originalSelectionData,
        0, // articleId需要单独设置
        AnnotationType.highlight,
      );
    } catch (e) {
      return null;
    }
  }

  // 验证Range数据完整性
  bool isValidRangeData() {
    return startXPath.isNotEmpty &&
           endXPath.isNotEmpty &&
           selectedText.isNotEmpty &&
           startOffset >= 0 &&
           endOffset >= 0;
  }

  // 获取摘要信息
  String getSummary() {
    final text = selectedText.length > 50 
        ? '${selectedText.substring(0, 50)}...' 
        : selectedText;
    
    final typeLabel = annotationType == AnnotationType.highlight ? '高亮' : '笔记';
    final colorLabel = colorType.label;
    
    return '$typeLabel·$colorLabel: $text';
  }

  // 检查是否需要更新
  bool needsUpdate() {
    final now = DateTime.now();
    return now.difference(updatedAt).inDays > 0;
  }

  // 更新时间戳
  void touch() {
    updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'EnhancedAnnotationDb(id: $id, articleId: $articleId, type: $annotationType, text: "${selectedText.substring(0, selectedText.length < 20 ? selectedText.length : 20)}...")';
  }
}

// 标注类型枚举
enum AnnotationType {
  highlight('高亮'),
  note('笔记');

  const AnnotationType(this.label);
  final String label;

  // 从字符串转换
  static AnnotationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'highlight':
        return AnnotationType.highlight;
      case 'note':
        return AnnotationType.note;
      default:
        return AnnotationType.highlight;
    }
  }
}

// 标注颜色枚举（增强版）
enum AnnotationColor {
  yellow(0, '黄色', 'highlight-yellow', '#FFFF00'),
  green(1, '绿色', 'highlight-green', '#00FF00'),
  blue(2, '蓝色', 'highlight-blue', '#0096FF'),
  pink(3, '粉色', 'highlight-pink', '#FF0096'),
  red(4, '红色', 'highlight-red', '#FF0000'),
  purple(5, '紫色', 'highlight-purple', '#9600FF');

  const AnnotationColor(this.value, this.label, this.cssClass, this.hexColor);
  
  final int value;
  final String label;
  final String cssClass;     // CSS类名
  final String hexColor;     // 十六进制颜色值

  // 从值转换
  static AnnotationColor fromValue(int value) {
    return AnnotationColor.values.firstWhere(
      (color) => color.value == value,
      orElse: () => AnnotationColor.yellow,
    );
  }

  // 从CSS类名转换
  static AnnotationColor fromCssClass(String cssClass) {
    return AnnotationColor.values.firstWhere(
      (color) => color.cssClass == cssClass,
      orElse: () => AnnotationColor.yellow,
    );
  }

  // 获取Flutter颜色
  Color get flutterColor {
    switch (this) {
      case AnnotationColor.yellow:
        return const Color(0xFFFFFF00);
      case AnnotationColor.green:
        return const Color(0xFF00FF00);
      case AnnotationColor.blue:
        return const Color(0xFF0096FF);
      case AnnotationColor.pink:
        return const Color(0xFFFF0096);
      case AnnotationColor.red:
        return const Color(0xFFFF0000);
      case AnnotationColor.purple:
        return const Color(0xFF9600FF);
    }
  }
}

// 标注统计信息
class AnnotationStats {
  final int totalCount;
  final int highlightCount;
  final int noteCount;
  final Map<AnnotationColor, int> colorCounts;
  final int crossParagraphCount;

  const AnnotationStats({
    required this.totalCount,
    required this.highlightCount,
    required this.noteCount,
    required this.colorCounts,
    required this.crossParagraphCount,
  });

  factory AnnotationStats.fromAnnotations(List<EnhancedAnnotationDb> annotations) {
    final colorCounts = <AnnotationColor, int>{};
    int highlightCount = 0;
    int noteCount = 0;
    int crossParagraphCount = 0;

    for (final annotation in annotations) {
      // 统计类型
      if (annotation.annotationType == AnnotationType.highlight) {
        highlightCount++;
      } else {
        noteCount++;
      }

      // 统计颜色
      colorCounts[annotation.colorType] = (colorCounts[annotation.colorType] ?? 0) + 1;

      // 统计跨段落
      if (annotation.crossParagraph) {
        crossParagraphCount++;
      }
    }

    return AnnotationStats(
      totalCount: annotations.length,
      highlightCount: highlightCount,
      noteCount: noteCount,
      colorCounts: colorCounts,
      crossParagraphCount: crossParagraphCount,
    );
  }

  @override
  String toString() {
    return 'AnnotationStats(total: $totalCount, highlights: $highlightCount, notes: $noteCount, crossParagraph: $crossParagraphCount)';
  }
} 
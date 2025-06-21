import 'package:isar/isar.dart';

part 'annotation_db.g.dart';

@collection
class AnnotationDb {
  Id id = Isar.autoIncrement;

  // 关联文章
  @Index()
  int articleId = 0;

  @Index(unique: true, replace: true)
  String highlightId = "";  // JS生成并添加到高亮HTML元素上的唯一ID


  String selectedText = "";   // 标注的文本内容

  // 用于定位的上下文文本（用于容错）
  String beforeContext = "";   // 选中文本前的文本（50字符）
  String afterContext = "";    // 选中文本后的文本（50字符）

  // 标注样式
  @Index()
  int colorType = 0;     // 颜色类型：0-黄色，1-红色，2-绿色，3-蓝色
  String note = "";                   // 备注文字

  // 元数据
  @Index()
  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();
}

// 标注颜色枚举
enum AnnotationColor {
  yellow(0, '黄色'),
  red(1, '红色'),
  green(2, '绿色'),
  blue(3, '蓝色');

  const AnnotationColor(this.value, this.label);
  final int value;
  final String label;

  static AnnotationColor fromValue(int value) {
    return AnnotationColor.values.firstWhere(
      (color) => color.value == value,
      orElse: () => AnnotationColor.yellow,
    );
  }
}
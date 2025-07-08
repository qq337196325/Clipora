import 'package:isar/isar.dart';
import '../article/article_db.dart';

part 'tag_db.g.dart';

@collection
class TagDb {
  Id id = Isar.autoIncrement;
  @Index() String userId = "";
  @Index() String serviceId = "";

  @Index(caseSensitive: false)
  late String name;

  @Backlink(to: 'tags')
  final articles = IsarLinks<ArticleDb>();

  /// 版本号（用于冲突解决）
  @Index() int version = 1;
  @Index() int updateTimestamp = 0;

  @Index()
  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();
} 
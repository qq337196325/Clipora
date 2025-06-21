import 'package:isar/isar.dart';
import '../article/article_db.dart';

part 'tag_db.g.dart';

@collection
class TagDb {
  Id id = Isar.autoIncrement;
  @Index() String userId = "";

  @Index(unique: true, caseSensitive: false)
  late String name;

  @Backlink(to: 'tags')
  final articles = IsarLinks<ArticleDb>();

  @Index()
  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();
} 
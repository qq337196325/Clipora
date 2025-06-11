import 'package:isar/isar.dart';
import '../database_service.dart';
import 'tag_db.dart';

class TagWithCount {
  final TagDb tag;
  final int count;

  TagWithCount({required this.tag, required this.count});
}

class TagService {
  TagService._();
  static final TagService instance = TagService._();

  Isar get isar => DatabaseService.instance.isar;

  Future<List<TagWithCount>> getTagsWithArticleCount() async {
    final tags = await isar.tagDbs.where().findAll();
    final List<TagWithCount> tagsWithCount = [];

    for (final tag in tags) {
      final count = await tag.articles.count();
      if (count > 0) {
        tagsWithCount.add(TagWithCount(tag: tag, count: count));
      }
    }

    // Sort by count descending
    tagsWithCount.sort((a, b) => b.count.compareTo(a.count));

    return tagsWithCount;
  }
} 
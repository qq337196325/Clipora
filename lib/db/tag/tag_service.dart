import 'package:isar/isar.dart';
import '../../basics/utils/user_utils.dart';
import '../database_service.dart';
import 'tag_db.dart';
import '../article/article_db.dart';

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
      // 查询该标签关联的未删除文章数量
      final count = await isar.articleDbs
          .where()
          .userIdEqualTo(getUserId())
          .filter()
          .deletedAtIsNull() // 过滤未删除的文章
          .and()
          .tags((q) => q.idEqualTo(tag.id)) // 过滤包含此标签的文章
          .count();
      
      if (count > 0) {
        tagsWithCount.add(TagWithCount(tag: tag, count: count));
      }
    }

    // Sort by count descending
    tagsWithCount.sort((a, b) => b.count.compareTo(a.count));

    return tagsWithCount;
  }

  /// 获取特定标签的未删除文章列表
  Future<List<ArticleDb>> getArticlesByTag(int tagId, {int limit = 20}) async {
    return await isar.articleDbs
        .where()
        .userIdEqualTo(getUserId())
        .filter()
        .deletedAtIsNull() // 过滤未删除的文章
        .and()
        .tags((q) => q.idEqualTo(tagId)) // 过滤包含此标签的文章
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// 获取特定标签的未删除文章数量
  Future<int> getArticleCountByTag(int tagId) async {
    return await isar.articleDbs
        .where()
        .userIdEqualTo(getUserId())
        .filter()
        .deletedAtIsNull() // 过滤未删除的文章
        .and()
        .tags((q) => q.idEqualTo(tagId)) // 过滤包含此标签的文章
        .count();
  }

  /// 获取所有标签（包括没有文章的标签）
  Future<List<TagDb>> getAllTags() async {
    return await isar.tagDbs.where().userIdEqualTo(getUserId()).sortByName().findAll();
  }

  /// 根据名称查找标签
  Future<TagDb?> findTagByName(String name) async {
    return await isar.tagDbs.where().userIdEqualTo(getUserId()).filter().nameEqualTo(name).findFirst();
  }

  /// 创建新标签
  Future<TagDb> createTag(String name) async {
    final existingTag = await findTagByName(name);
    if (existingTag != null) {
      return existingTag;
    }

    final tag = TagDb()
      ..name = name
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.tagDbs.put(tag);
    });

    return tag;
  }

  /// 删除标签（只有当标签没有关联任何未删除文章时才能删除）
  Future<bool> deleteTag(int tagId) async {
    final articleCount = await getArticleCountByTag(tagId);
    if (articleCount > 0) {
      return false; // 还有文章关联此标签，不能删除
    }

    await isar.writeTxn(() async {
      await isar.tagDbs.delete(tagId);
    });

    return true;
  }
} 
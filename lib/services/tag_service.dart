import 'package:get/get.dart';
import 'package:inkwell/db/article/article_db.dart';
import 'package:inkwell/db/database_service.dart';
import 'package:inkwell/db/tag/tag_db.dart';
import 'package:isar/isar.dart';

class TagService {
  final Isar isar = Get.find<DatabaseService>().isar;

  Future<List<TagDb>> getAllTags() {
    return isar.tagDbs.where().sortByCreatedAtDesc().findAll();
  }

  Stream<List<TagDb>> watchAllTags() {
    return isar.tagDbs.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Future<List<TagDb>> getTagsForArticle(int articleId) async {
    final article = await isar.articleDbs.get(articleId);
    if (article != null) {
      await article.tags.load();
      return article.tags.toList();
    }
    return [];
  }

  Future<void> updateArticleTags(int articleId, Set<int> tagIds) async {
    await isar.writeTxn(() async {
      final article = await isar.articleDbs.get(articleId);
      if (article != null) {
        final tagsToAssign = await isar.tagDbs.getAll(tagIds.toList());
        article.tags.clear();
        article.tags.addAll(tagsToAssign.whereType<TagDb>());
        await article.tags.save();
      }
    });
  }

  Future<void> createTag(String name) async {
    final existingTag = await isar.tagDbs.filter().nameEqualTo(name).findFirst();
    if (existingTag != null) {
      return;
    }

    final newTag = TagDb()
      ..name = name
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.tagDbs.put(newTag);
    });
  }
} 
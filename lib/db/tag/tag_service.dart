// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



import 'package:isar/isar.dart';
import 'package:get/get.dart';

import '../../basics/ui.dart';
import '../../basics/utils/user_utils.dart';
import '../database_service.dart';
import 'tag_db.dart';
import '../article/article_db.dart';

class TagWithCount {
  final TagDb tag;
  final int count;

  TagWithCount({required this.tag, required this.count});
}

class TagService extends GetxService  {
  static TagService get instance => Get.find<TagService>();

  /// 获取数据库实例
  DatabaseService get _dbService => DatabaseService.instance;

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


  Future<List<TagDb>> getAllTags() {
    return isar.tagDbs.where().userIdEqualTo(getUserId()).sortByCreatedAtDesc().findAll();
  }

  Stream<List<TagDb>> watchAllTags() {
    return isar.tagDbs.where().userIdEqualTo(getUserId()).sortByCreatedAtDesc().watch(fireImmediately: true);
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

        article.updateTimestamp = getStorageServiceCurrentTimeAdding();
        await isar.articleDbs.put(article);
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
      ..updateTimestamp = getStorageServiceCurrentTimeAdding()
      ..userId = getUserId()
      ..name = name
      ..uuid = getUuid()
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.tagDbs.put(newTag);
    });
  }



} 
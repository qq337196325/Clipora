// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:isar/isar.dart';
import 'package:get/get.dart';

import '../../../basics/ui.dart';
import '../../../basics/utils/user_utils.dart';
import '../article_db.dart';
import '../../database_service.dart';
import '../../../basics/logger.dart';
import '../../article_content/article_content_db.dart';


/// 文章服务类
class ArticleBaseService extends GetxService {

  /// 获取数据库实例
  DatabaseService get dbService => DatabaseService.instance;


  // /// 记录同步操作
  // Future<void> logSyncOperation(SyncOp op, ArticleDb article) async {
  //   final syncOp = SyncOperation()
  //     ..operation = op
  //     ..collectionName = 'ArticleDb'
  //     ..entityId = article.serviceId
  //     ..timestamp = DateTime.now()
  //     ..status = SyncStatus.pending;
  //
  //   // 对于非删除操作，我们存储文章的完整数据
  //   if (op != SyncOp.delete) {
  //     // 注意：这里需要一个方法将 ArticleDb 转换为 Map<String, dynamic>
  //     // 暂时我们先假设有一个 toJson 方法，后续需要实现它
  //     syncOp.data = jsonEncode(article.toJson());
  //   }
  //
  //   await dbService.syncOperations.put(syncOp);
  //   getLogger().i('📝 记录同步操作: ${op.name} for Article ${article.serviceId}');
  // }


  /// 软删除文章（设置deletedAt字段）
  Future<bool> softDeleteArticle(int articleId) async {

    try {
      await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          // 设置删除时间
          article.deletedAt = DateTime.now();
          article.updatedAt = DateTime.now();
          article.updateTimestamp = getStorageServiceCurrentTimeAdding();

          await dbService.articles.put(article);

          getLogger().i('🗑️ 软删除文章: ${article.title}');
        } else {
          throw Exception('未找到文章');
        }
      });

      return true;
    } catch (e) {
      getLogger().e('❌ 软删除文章失败: $e');
      rethrow;
    }
  }

  /// 清空回收站（永久删除所有已删除的文章）
  Future<int> clearRecycleBin() async {

    try {
      int deletedCount = 0;

      await dbService.isar.writeTxn(() async {
        // 获取所有已删除的文章
        final deletedArticles = await dbService.articles
            .where()
            .userIdEqualTo(getUserId())
            .filter()
            .deletedAtIsNotNull()
            .findAll();

        // 批量删除
        final articleIds = deletedArticles.map((article) => article.id).toList();
        deletedCount = await dbService.articles.deleteAll(articleIds);

        getLogger().i('🗑️ 清空回收站，永久删除 $deletedCount 篇文章');
      });

      return deletedCount;
    } catch (e) {
      getLogger().e('❌ 清空回收站失败: $e');
      rethrow;
    }
  }


  /// 删除文章的所有内容
  Future<int> deleteAllArticleContents(int articleId) async {
    try {
      final deletedCount = await dbService.isar.writeTxn(() async {
        return await dbService.articleContent
            .where()
            .userIdEqualTo(getUserId())
            .filter()
            .articleIdEqualTo(articleId)
            .deleteAll();
      });

      getLogger().i('🗑️ 删除文章($articleId)的所有内容，共 $deletedCount 条');
      return deletedCount;
    } catch (e) {
      getLogger().e('❌ 删除文章内容失败: $e');
      return 0;
    }
  }
}
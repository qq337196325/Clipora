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



import 'package:clipora/basics/ui.dart';
import 'package:clipora/basics/utils/user_utils.dart';
import 'package:isar/isar.dart';

import 'article_base_service.dart';
import '../article_db.dart';
import '../../category/category_db.dart';
import '../../../basics/logger.dart';


/// 文章服务类
class ArticleUpdateService extends ArticleBaseService {

  /// 保存文章
  Future<ArticleDb> saveArticle(ArticleDb article) async {
    try {

      final now = DateTime.now();
      article.updatedAt = now;
      article.userId = getUserId();
      article.updateTimestamp = getStorageServiceCurrentTimeAdding();

      final isCreating = article.id == Isar.autoIncrement;

      // 如果是新文章，设置创建时间并生成唯一ID
      if (isCreating) {
        article.createdAt = now;
        article.uuid = getUuid();
        // 如果没有服务端ID (代表是本地新建的), 则生成一个客户端唯一ID
        if (article.serviceId.isEmpty) {
          article.serviceId = "";
        }
      }

      await dbService.isar.writeTxn(() async {
        await dbService.articles.put(article);
      });

      getLogger().i('✅ 文章保存成功，ID: ${article.id}');
      return article;
    } catch (e) {
      getLogger().e('❌ 保存文章失败: $e');
      rethrow;
    }
  }


  /// 更新文章分类
  Future<void> updateArticleCategory(int articleId, CategoryDb? category) async {

    try {
      getLogger().i('📝 更新文章分类，文章ID: $articleId, 分类: ${category?.name ?? "未分类"}');

      await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          // 设置新的分类关系
          article.category.value = category;
          article.updatedAt = DateTime.now();
          article.updateTimestamp = getStorageServiceCurrentTimeAdding();

          // 保存文章和关系
          await dbService.articles.put(article);
          await article.category.save();

          getLogger().i('✅ 文章分类更新成功: ${article.title} -> ${category?.name ?? "未分类"}');
        } else {
          getLogger().w('⚠️ 未找到ID为 $articleId 的文章');
          throw Exception('未找到文章');
        }
      });
    } catch (e) {
      getLogger().e('❌ 更新文章分类失败: $e');
      rethrow;
    }
  }


  /// 更新文章阅读状态
  Future<void> updateReadStatus(int articleId, {
    bool isRead = true,
    int? readDuration,
    double? readProgress,
  }) async {

    try {
      await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          article.isRead = isRead ? 1 : 0;
          article.readCount += 1;
          article.updatedAt = DateTime.now();
          article.updateTimestamp = getStorageServiceCurrentTimeAdding();

          if (readDuration != null) {
            article.readDuration += readDuration;
          }

          if (readProgress != null) {
            article.readProgress = readProgress;
          }

          await dbService.articles.put(article);
          getLogger().i('📖 更新文章阅读状态: ${article.title}');
        }
      });
    } catch (e) {
      getLogger().e('❌ 更新阅读状态失败: $e');
    }
  }


  /// 切换文章重要状态
  Future<bool> toggleImportantStatus(int articleId) async {

    try {
      bool newImportantStatus = false;

      await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          // 切换重要状态
          article.isImportant = !article.isImportant;
          newImportantStatus = article.isImportant;
          article.updatedAt = DateTime.now();
          article.updateTimestamp = getStorageServiceCurrentTimeAdding();

          await dbService.articles.put(article);

          getLogger().i('⭐ 切换文章重要状态: ${article.title} -> ${newImportantStatus ? '重要' : '普通'}');
        } else {
          throw Exception('未找到文章');
        }
      });

      return newImportantStatus;
    } catch (e) {
      getLogger().e('❌ 切换重要状态失败: $e');
      rethrow;
    }
  }


  /// 切换文章归档状态
  Future<bool> toggleArchiveStatus(int articleId) async {

    try {
      bool newArchiveStatus = false;

      await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          // 切换归档状态
          article.isArchived = !article.isArchived;
          newArchiveStatus = article.isArchived;
          article.updatedAt = DateTime.now();
          article.updateTimestamp = getStorageServiceCurrentTimeAdding();

          await dbService.articles.put(article);

          getLogger().i('📦 切换文章归档状态: ${article.title} -> ${newArchiveStatus ? '已归档' : '未归档'}');
        } else {
          throw Exception('未找到文章');
        }
      });

      return newArchiveStatus;
    } catch (e) {
      getLogger().e('❌ 切换归档状态失败: $e');
      rethrow;
    }
  }



  /// 标记文章已同步到服务端
  Future<bool> markArticleAsSynced(int articleId, String serviceId) async {
    try {
      return await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          article.serviceId = serviceId;
          article.isCreateService = true;
          article.updatedAt = DateTime.now();
          await dbService.articles.put(article);
          getLogger().i('✅ 成功标记文章为已同步: ID $articleId, ServiceID: $serviceId');
          return true;
        }
        getLogger().w('⚠️ 标记同步失败：未找到文章 ID $articleId');
        return false;
      });
    } catch (e) {
      getLogger().e('❌ 标记文章为已同步时出错: $e');
      return false;
    }
  }

  /// 更新文章的Markdown状态
  /// markdownStatus: 0=待生成  1=已生成   2=生成失败     3=正在生成
  Future<bool> updateArticleMarkdownStatus(int articleId, int markdownStatus) async {
    try {
      return await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          final now = DateTime.now();
          article.markdownStatus = markdownStatus;
          article.updatedAt = now;

          // 当状态设为3（正在生成）时，记录开始处理时间
          if (markdownStatus == 3) {
            article.markdownProcessingStartTime = now;
            getLogger().i('⏰ 记录Markdown处理开始时间: $now');
          }
          // 当状态设为1（已生成）或2（生成失败）时，清除开始处理时间
          else if (markdownStatus == 1 || markdownStatus == 2) {
            article.markdownProcessingStartTime = null;
          }

          await dbService.articles.put(article);

          String statusText = '';
          switch (markdownStatus) {
            case 0:
              statusText = '待生成';
              break;
            case 1:
              statusText = '已生成';
              break;
            case 2:
              statusText = '生成失败';
              break;
            case 3:
              statusText = '正在生成';
              break;
            default:
              statusText = '未知状态($markdownStatus)';
          }

          getLogger().i('✅ 成功更新文章Markdown状态: ID $articleId -> $statusText');
          return true;
        }
        getLogger().w('⚠️ 更新Markdown状态失败：未找到文章 ID $articleId');
        return false;
      });
    } catch (e) {
      getLogger().e('❌ 更新文章Markdown状态时出错: $e');
      return false;
    }
  }

}
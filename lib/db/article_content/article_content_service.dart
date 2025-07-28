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



import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../basics/utils/user_utils.dart';
import '../database_service.dart';
import '../../basics/logger.dart';
import 'article_content_db.dart';


/// 文章服务类
class ArticleContentService extends GetxService {
  static ArticleContentService get instance => Get.find<ArticleContentService>();

  /// 获取数据库实例
  DatabaseService get _dbService => DatabaseService.instance;


  /// 创建文章内容
  Future<ArticleContentDb> createArticleContent({
    required int articleId,
    required String markdown,
    String textContent = '',
    String languageCode = "",
    bool isOriginal = true,
    String serviceId = '',
    String uuid = '',
  }) async {
    try {
      getLogger().i('📝 保存文章内容到 ArticleContentDb，文章ID: $articleId，语言: ${languageCode}');

      final now = DateTime.now();

      // 首先查询是否已存在该文章的内容（根据 articleId 和 languageCode）
      final existingContent = await _dbService.articleContent.isar.writeTxn(() async {
        final existing = await _dbService.articleContent
            .where()
            .userIdEqualTo(getUserId())
            .filter()
            .articleIdEqualTo(articleId)
            .and()
            .languageCodeEqualTo(languageCode)
            .findFirst();

        if (existing != null) {
          // 更新现有内容
          existing.markdown = markdown;
          existing.textContent = textContent;
          existing.updatedAt = now;
          if (serviceId.isNotEmpty) {
            existing.serviceId = serviceId;
          }
          await _dbService.articleContent.put(existing);
          getLogger().i('✅ 更新现有文章内容成功，ArticleContentDb ID: ${existing.id}');
          return existing;
        } else {
          // 创建新内容
          final newContent = ArticleContentDb()
            ..userId = getUserId()
            ..articleId = articleId
            ..markdown = markdown
            ..textContent = textContent
            ..languageCode = languageCode
            ..isOriginal = isOriginal
            ..serviceId = serviceId
            ..createdAt = now
            ..uuid= uuid
            ..updatedAt = now;

          await _dbService.articleContent.put(newContent);
          getLogger().i('✅ 创建新文章内容成功，ArticleContentDb ID: ${newContent.id}');
          return newContent;
        }
      });

      return existingContent;
    } catch (e) {
      getLogger().e('❌ 保存文章内容失败: $e');
      rethrow;
    }
  }

  Future<bool> saveMarkdownScroll(int id, int currentScrollY,int currentScrollX) async {
    try {
      final success = await _dbService.isar.writeTxn(() async {
        // 在删除前先记录操作
        final articleContent = await _dbService.articleContent.get(id);
        if (articleContent != null) {


          articleContent.markdownScrollX = currentScrollX;
          articleContent.markdownScrollY = currentScrollY;

          articleContent.updatedAt = DateTime.now();
          articleContent.lastReadTime = DateTime.now();

          return await  _dbService.articleContent.put(articleContent);
        }
        return false;
      });

      return false;
    } catch (e) {
      getLogger().e('❌ 保存文章位置失败: $e');
      return false;
    }
  }

}
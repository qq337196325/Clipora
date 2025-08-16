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
import 'dart:async';

import 'package:get/get.dart';

import 'package:isar/isar.dart';
import '../../api/user_api.dart';
import '../../../basics/logger.dart';
import '../../../basics/ui.dart';
import '../../../db/database_service.dart';
import '../../../db/category/category_db.dart';
import '../../../db/article/article_db.dart';
import '../../../db/article_content/article_content_db.dart';
import '../../../db/tag/tag_db.dart';
import '../../../db/annotation/enhanced_annotation_db.dart';
import '../update_data_sync/data_sync_service.dart';
import 'logc/annotation.dart';
import 'logc/article.dart';
import 'logc/article_content.dart';
import 'logc/category.dart';
import 'logc/tag.dart';
import 'models/category_model.dart';
import 'models/tag_model.dart';
import 'models/article_model.dart';
import 'models/article_content_model.dart';
import 'models/annotation_model.dart';

// class IncrementSyncData extends GetxService {
//
//   static IncrementSyncData get instance => Get.find<IncrementSyncData>();

/// 获取同步数据
class GetSyncData extends GetxService{
  // static CategoryService _categoryService = CategoryService();
  static GetSyncData get instance => Get.find<GetSyncData>();

  List<String> dbList = [
    "category",
    "tag",
    "article",
    "article_content",
    "annotation",
  ];

  // 进度回调函数
  Function(String message, double progress)? onProgress;
  Timer? _timer;
  bool isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    getLogger().i('IncrementSyncData Initialized');

    // 每30秒触发一次增量同步检查
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {

      await completeSyncAllData(); // 先获取服务器数据，服务器数据将更新相同ID的数据，本地数据将不再更新到服务端

      /// 获取服务器时间
      final serviceCurrentTime = await getServiceCurrentTime();
      globalBoxStorage.write('serviceCurrentTime', serviceCurrentTime);

      await Get.find<DataSyncService>().run();

    });
  }

  /// 获取全部数据
  Future<Map<String, dynamic>?> fetchAllTablesData() async {
    try {
      int page = 0;
      const limit = 100;
      bool hasMoreData = true;

      // 初始化所有表的数据容器
      final allTablesData = {
        'categories': {'records': <Map<String, dynamic>>[], 'total': 0, 'has_more': false},
        'tags': {'records': <Map<String, dynamic>>[], 'total': 0, 'has_more': false},
        'articles': {'records': <Map<String, dynamic>>[], 'total': 0, 'has_more': false},
        'article_contents': {'records': <Map<String, dynamic>>[], 'total': 0, 'has_more': false},
        'annotations': {'records': <Map<String, dynamic>>[], 'total': 0, 'has_more': false},
      };

      // 分页获取数据直到获取完所有数据
      while (hasMoreData) {
        final serviceCurrentTime = getStorageServiceCurrentTime();
        // 构建请求参数
        final requestParams = {
          "complete_sync": serviceCurrentTime == 0,
          "current_time": serviceCurrentTime,
          "page": page,
          "limit": limit,
        };

        getLogger().i('📥 获取第${page + 1}页数据...');
        // 调用同步接口
        final response = await UserApi.getSyncAllDataApi(requestParams);

        if (response['code'] != 0) {
          getLogger().e('❌ 获取同步数据失败: ${response['msg']}');
          return null;
        }

        final data = response['data'];

        // 合并各表数据
        if (data['categories'] != null && data['categories']['records'] != null) {
          (allTablesData['categories']!['records'] as List<Map<String, dynamic>>).addAll(List<Map<String, dynamic>>.from(data['categories']['records']));
        }
        if (data['tags'] != null && data['tags']['records'] != null) {
          (allTablesData['tags']!['records'] as List<Map<String, dynamic>>).addAll(List<Map<String, dynamic>>.from(data['tags']['records']));
        }
        if (data['articles'] != null && data['articles']['records'] != null) {
          (allTablesData['articles']!['records'] as List<Map<String, dynamic>>).addAll(List<Map<String, dynamic>>.from(data['articles']['records']));
        }
        if (data['article_contents'] != null && data['article_contents']['records'] != null) {
          (allTablesData['article_contents']!['records'] as List<Map<String, dynamic>>).addAll(List<Map<String, dynamic>>.from(data['article_contents']['records']));
        }
        if (data['annotations'] != null && data['annotations']['records'] != null) {
          (allTablesData['annotations']!['records'] as List<Map<String, dynamic>>).addAll(List<Map<String, dynamic>>.from(data['annotations']['records']));
        }

        // 更新总数和是否有更多数据的标志
        if (page == 0) {
          allTablesData['categories']!['total'] = data['categories']?['total'] ?? 0;
          allTablesData['tags']!['total'] = data['tags']?['total'] ?? 0;
          allTablesData['articles']!['total'] = data['articles']?['total'] ?? 0;
          allTablesData['article_contents']!['total'] = data['article_contents']?['total'] ?? 0;
          allTablesData['annotations']!['total'] = data['annotations']?['total'] ?? 0;
        }

        // 检查是否还有更多数据 - 任何一个表还有数据就继续
        hasMoreData = (data['categories']?['has_more'] ?? false) ||
            (data['tags']?['has_more'] ?? false) ||
            (data['articles']?['has_more'] ?? false) ||
            (data['article_contents']?['has_more'] ?? false) ||
            (data['annotations']?['has_more'] ?? false);

        page++;
      }

      return allTablesData;
    } catch (e) {
      getLogger().e('❌ 获取所有表数据失败: $e');
      return null;
    }
  }


  /// 全量同步 - 优化版本，一次性获取所有表数据
  Future<bool> completeSyncAllData() async {
    try {
      getLogger().i('🔄 开始全量同步所有数据...');

      // 一次性获取所有表的数据
      final allData = await fetchAllTablesData();
      if (allData == null) {
        getLogger().e('❌ 获取同步数据失败');
        return false;
      }

      // 按依赖关系顺序串行处理数据：categories -> tags -> articles -> article_contents -> annotations
      getLogger().i('📋 按依赖关系顺序处理数据...');

      bool allSuccess = true;

      try {
        // 1. 先处理分类数据（基础数据，无依赖）
        getLogger().i('1️⃣ 处理分类数据...');
        if (allData['categories'] != null && allData['categories']['records'] != null) {
          final categoryRecords = List<Map<String, dynamic>>.from(allData['categories']['records']);
          final categories = categoryRecords.map((record) => CategoryModel.fromJson(record)).toList();
          final success = await _saveCategoryDataToLocal(categories);
          if (!success) {
            getLogger().e('❌ 分类数据处理失败');
            allSuccess = false;
          }
        }

        // 2. 处理标签数据（基础数据，无依赖）
        getLogger().i('2️⃣ 处理标签数据...');
        if (allData['tags'] != null && allData['tags']['records'] != null) {
          final tagRecords = List<Map<String, dynamic>>.from(allData['tags']['records']);
          final tags = tagRecords.map((record) => TagModel.fromJson(record)).toList();
          final success = await _saveTagDataToLocal(tags);
          if (!success) {
            getLogger().e('❌ 标签数据处理失败');
            allSuccess = false;
          }
        }

        // 3. 处理文章数据（依赖分类和标签）
        getLogger().i('3️⃣ 处理文章数据...');
        if (allData['articles'] != null && allData['articles']['records'] != null) {
          final articleRecords = List<Map<String, dynamic>>.from(allData['articles']['records']);
          final articles = articleRecords.map((record) => ArticleModel.fromJson(record)).toList();
          final success = await _saveArticleDataToLocal(articles);
          if (!success) {
            getLogger().e('❌ 文章数据处理失败');
            allSuccess = false;
          }
        }

        // 4. 处理文章内容数据（依赖文章）
        getLogger().i('4️⃣ 处理文章内容数据...');
        if (allData['article_contents'] != null && allData['article_contents']['records'] != null) {
          final contentRecords = List<Map<String, dynamic>>.from(allData['article_contents']['records']);
          final contents = contentRecords.map((record) => ArticleContentModel.fromJson(record)).toList();
          final success = await _saveArticleContentDataToLocal(contents);
          if (!success) {
            getLogger().e('❌ 文章内容数据处理失败');
            allSuccess = false;
          }
        }

        // 5. 处理标注数据（依赖文章和文章内容）
        getLogger().i('5️⃣ 处理标注数据...');
        if (allData['annotations'] != null && allData['annotations']['records'] != null) {
          final annotationRecords = List<Map<String, dynamic>>.from(allData['annotations']['records']);
          final annotations = annotationRecords.map((record) => AnnotationModel.fromJson(record)).toList();
          final success = await _saveAnnotationDataToLocal(annotations);
          if (!success) {
            getLogger().e('❌ 标注数据处理失败');
            allSuccess = false;
          }
        }

      } catch (e) {
        getLogger().e('❌ 数据处理过程中发生异常: $e');
        allSuccess = false;
      }

      if (allSuccess) {
        getLogger().i('✅ 全量同步完成');
        // 标记全量同步完成
        globalBoxStorage.write('completeSyncStatus', true);
      } else {
        getLogger().e('❌ 全量同步失败，部分数据同步出错');
      }

      return allSuccess;

    } catch (e) {
      getLogger().e('❌ 全量同步发生异常: $e');
      return false;
    }
  }


  /// 保存标签数据到本地数据库
  Future<bool> _saveTagDataToLocal(List<TagModel> tags) async {
    try {
      getLogger().i('💾 开始保存 ${tags.length} 条标签数据到本地数据库...');

      final dbService = DatabaseService.instance;

      int successCount = 0;

      await dbService.isar.writeTxn(() async {
        for (final tagModel in tags) {
          try {
            // 检查本地是否已存在该标签（通过serviceId查找）
            final existingTag = await dbService.tags
                .where()
                .uuidEqualTo(tagModel.uuid)
                .findFirst();

            if (existingTag != null) {
              // 更新现有标签
              if (tagModel.version > existingTag.version) {
                updateTagFromModel(existingTag, tagModel);
                await dbService.tags.put(existingTag);
                getLogger().d('🔄 更新标签: ${tagModel.name} (serviceId: ${tagModel.id})');
              } else {
                getLogger().d('⏭️ 跳过标签（本地数据较新）: ${tagModel.name}');
              }
            } else {
              // 创建新标签
              final newTag = createTagFromModel(tagModel);
              await dbService.tags.put(newTag);
              getLogger().d('✨ 创建标签: ${tagModel.name} (serviceId: ${tagModel.id})');
            }

            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存标签失败: ${tagModel.name}, 错误: $e');
          }
        }
      });

      return successCount == tags.length;

    } catch (e) {
      getLogger().e('❌ 保存标签数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 保存分类数据到本地数据库
  Future<bool> _saveCategoryDataToLocal(List<CategoryModel> categories) async {
    try {
      getLogger().i('💾 开始保存 ${categories.length} 条分类数据到本地数据库...');

      final dbService = DatabaseService.instance;
      int successCount = 0;

      await dbService.isar.writeTxn(() async {
        for (final categoryModel in categories) {
          try {
            // 检查本地是否已存在该分类（通过serverId查找）
            final existingCategory = await dbService.categories
                .where()
                .uuidEqualTo(categoryModel.uuid)
                .findFirst();

            if (existingCategory != null) {
              // 更新现有分类
              if (categoryModel.version > existingCategory.version) {
                updateCategoryFromModel(existingCategory, categoryModel);
                await dbService.categories.put(existingCategory);
                getLogger().d('🔄 更新分类: ${categoryModel.name} (serverId: ${categoryModel.id})');
              } else {
                getLogger().d('⏭️ 跳过分类（本地数据较新）: ${categoryModel.name}');
              }
            } else {
              // 创建新分类
              final newCategory = createCategoryFromModel(categoryModel);
              await dbService.categories.put(newCategory);
              getLogger().d('✨ 创建分类: ${categoryModel.name} (serverId: ${categoryModel.id})');
            }

            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存分类失败: ${categoryModel.name}, 错误: $e');
          }
        }
      });

      return successCount == categories.length;

    } catch (e) {
      getLogger().e('❌ 保存分类数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 保存文章数据到本地数据库
  Future<bool> _saveArticleDataToLocal(List<ArticleModel> articles) async {
    try {
      final dbService = DatabaseService.instance;

      int successCount = 0;

      await dbService.isar.writeTxn(() async {
        for (final articleModel in articles) {
          try {
            // 检查本地是否已存在该文章（通过serverId查找）
            final existingArticle = await dbService.articles
                .where()
                .filter()
                .serviceIdEqualTo(articleModel.id)
                .findFirst();

            if (existingArticle != null) {
              // 更新现有文章
              if (articleModel.version > existingArticle.version) {
                updateArticleFromModel(existingArticle, articleModel);
                await dbService.articles.put(existingArticle);

                // 更新文章内容
                await _saveOrUpdateArticleContent(existingArticle.id, articleModel);

                // 更新文章的标签和分类关联
                await _updateArticleAssociations(existingArticle, articleModel);

                getLogger().d('🔄 更新文章: ${articleModel.title} (serverId: ${articleModel.id})');
              } else {
                getLogger().d('⏭️ 跳过文章（本地数据较新）: ${articleModel.title}');
              }
            } else {
              // 创建新文章
              final newArticle = createArticleFromModel(articleModel);
              await dbService.articles.put(newArticle);

              // 保存文章内容
              await _saveOrUpdateArticleContent(newArticle.id, articleModel);

              // 设置文章的标签和分类关联
              await _updateArticleAssociations(newArticle, articleModel);
              getLogger().d('✨ 创建文章: ${articleModel.title} (serverId: ${articleModel.id})');
            }

            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存文章失败: ${articleModel.title}, 错误: $e');
          }
        }
      });

      return successCount == articles.length;

    } catch (e) {
      getLogger().e('❌ 保存文章数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 更新文章的标签和分类关联关系
  Future<void> _updateArticleAssociations(ArticleDb article, ArticleModel model) async {
    try {
      final dbService = DatabaseService.instance;

      // 处理标签关联
      if (model.tagUuids.isNotEmpty) {
        // 根据serviceId查找对应的本地标签
        final localTags = <TagDb>[];
        for (final tagUuid in model.tagUuids) {
          final tag = await dbService.tags
              .where()
              .uuidEqualTo(tagUuid)
              .findFirst();
          if (tag != null) {
            localTags.add(tag);
          }
        }

        if (localTags.isNotEmpty) {
          // 清除现有标签关联并设置新的关联
          article.tags.clear();
          article.tags.addAll(localTags);
          await article.tags.save();
          getLogger().d('🏷️ 为文章 ${article.title} 关联了 ${localTags.length} 个标签');
        } else {
          getLogger().w('⚠️ 未找到对应的本地标签: ${model.tagUuids}');
        }
      } else {
        // 清除所有标签关联
        article.tags.clear();
        await article.tags.save();
      }

      // 处理分类关联
      if (model.categoryUuids.isNotEmpty) {
        // 取第一个分类ID（文章只能属于一个分类）
        final categoryUuid = model.categoryUuids.first;

        // 根据serverId查找对应的本地分类
        final localCategory = await dbService.categories
            .where()
            .uuidEqualTo(categoryUuid)
            .findFirst();

        if (localCategory != null) {
          article.category.value = localCategory;
          await article.category.save();
          getLogger().d('📁 为文章 ${article.title} 关联了分类: ${localCategory.name}');
        } else {
          getLogger().w('⚠️ 未找到对应的本地分类，serverId: $categoryUuid');
        }
      } else {
        // 清除分类关联
        article.category.value = null;
        await article.category.save();
      }

    } catch (e) {
      getLogger().e('❌ 更新文章关联关系失败: ${article.title}, 错误: $e');
    }
  }

  /// 保存或更新文章内容（在当前事务中执行，避免嵌套事务）
  Future<void> _saveOrUpdateArticleContent(int articleId, ArticleModel model) async {
    try {
      // 如果有markdown内容，保存原文内容
      if (model.markdown.isNotEmpty) {
        final dbService = DatabaseService.instance;
        final now = DateTime.now();

        // 查询是否已存在该文章的内容（根据 articleId 和 languageCode）
        final existing = await dbService.articleContent
            .where()
            .filter()
            .articleIdEqualTo(articleId)
            .and()
            .languageCodeEqualTo("original")
            .findFirst();

        if (existing != null) {
          // 更新现有内容
          existing.markdown = model.markdown;
          existing.serviceArticleId = model.id;
          existing.textContent = model.textContent;
          existing.updatedAt = now;
          if (model.id.isNotEmpty) {
            existing.serviceId = model.id;
          }
          await dbService.articleContent.put(existing);
          getLogger().d('🔄 更新文章内容: ${model.title}');
        } else {
          // 创建新内容
          final newContent = ArticleContentDb()
            ..userId = model.userId
            ..articleId = articleId
            ..markdown = model.markdown
            ..textContent = model.textContent
            ..languageCode = "original"
            ..isOriginal = true
            ..serviceId = model.id
            ..createdAt = now
            ..updatedAt = now;

          await dbService.articleContent.put(newContent);
          getLogger().d('✨ 创建文章内容: ${model.title}');
        }
      }
    } catch (e) {
      getLogger().e('❌ 保存文章内容失败: ${model.title}, 错误: $e');
    }
  }

  /// 保存标注数据到本地数据库
  Future<bool> _saveAnnotationDataToLocal(List<AnnotationModel> annotations) async {
    try {
      final dbService = DatabaseService.instance;

      int successCount = 0;
      int skipCount = 0;

      await dbService.isar.writeTxn(() async {
        for (final annotationModel in annotations) {
          try {
            // 查找对应的本地文章
            final localArticle = await dbService.articles
                .where()
                .serviceIdEqualTo(annotationModel.serviceArticleId)
                .findFirst();

            if (localArticle == null) {
              getLogger().w('⚠️ 未找到标注对应的本地文章，客户端文章ID: ${annotationModel.clientArticleId}。跳过此条标注。');
              skipCount++;
              continue;
            }

            // 查找对应的本地文章内容
            final localArticleContent = await dbService.articleContent
                .where()
                .serviceIdEqualTo(annotationModel.serviceArticleContentId)
                .findFirst();

            if (localArticleContent == null) {
              getLogger().w('⚠️ 未找到标注对应的本地文章内容，文章ID: ${localArticle.id}。跳过此条标注。');
              skipCount++;
              continue;
            }

            // 检查本地是否已存在该标注（通过highlightId查找）
            final existingAnnotation = await dbService.enhancedAnnotation
                .where()
                .highlightIdEqualTo(annotationModel.highlightId)
                .findFirst();

            if (existingAnnotation != null) {
              // 更新现有标注
              if (annotationModel.version > existingAnnotation.version) {
                updateAnnotationFromModel(existingAnnotation, annotationModel, localArticle.id, localArticleContent.id);
                await dbService.enhancedAnnotation.put(existingAnnotation);
                getLogger().d('🔄 更新标注: ${annotationModel.highlightId}');
              } else {
                getLogger().d('⏭️ 跳过标注（本地数据较新）: ${annotationModel.highlightId}');
              }
            } else {
              // 创建新标注
              final newAnnotation = createAnnotationFromModel(annotationModel, localArticle.id, localArticleContent.id);
              await dbService.enhancedAnnotation.put(newAnnotation);
              getLogger().d('✨ 创建标注: ${annotationModel.highlightId}');
            }

            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存标注失败: ${annotationModel.highlightId}, 错误: $e');
          }
        }
      });

      return successCount == (annotations.length - skipCount);

    } catch (e) {
      getLogger().e('❌ 保存标注数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 保存文章内容数据到本地数据库
  Future<bool> _saveArticleContentDataToLocal(List<ArticleContentModel> contents) async {
    try {
      final dbService = DatabaseService.instance;

      final serviceArticleIds = contents.map((c) => c.serviceArticleId).toSet().toList();
      final localArticles = await dbService.articles
          .where()
          .anyOf(serviceArticleIds, (q, id) => q.serviceIdEqualTo(id))
          .findAll();
      final articleMap = {for (var article in localArticles) article.serviceId: article};

      final contentServerIds = contents.map((c) => c.id).toSet().toList();
      final existingContents = await dbService.articleContent
          .filter()
          .anyOf(contentServerIds, (q, id) => q.serviceIdEqualTo(id))
          .findAll();
      final contentMap = {for (var content in existingContents) content.serviceId: content};


      int successCount = 0;
      int skipCount = 0;

      await dbService.isar.writeTxn(() async {
        for (final contentModel in contents) {
          try {
            final localArticle = articleMap[contentModel.serviceArticleId];

            if (localArticle == null) {
              getLogger().w('⚠️ 未找到文章内容对应的本地文章，服务端文章ID: ${contentModel.serviceArticleId}。跳过此条内容。');
              skipCount++;
              continue;
            }

            final existingContent = contentMap[contentModel.id];

            if (existingContent != null) {
              if (contentModel.version > existingContent.version) {
                updateArticleContentFromModel(existingContent, contentModel, localArticle.id);
                await dbService.articleContent.put(existingContent);
                getLogger().d('🔄 更新文章内容: (serverId: ${contentModel.id})');
              }
            } else {
              final newContent = createArticleContentFromModel(contentModel, localArticle.id);
              await dbService.articleContent.put(newContent);
              getLogger().d('✨ 创建文章内容: (serverId: ${contentModel.id})');
            }
            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存文章内容失败: (serverId: ${contentModel.id}), 错误: $e');
          }
        }
      });

      return successCount == (contents.length - skipCount);
    } catch (e) {
      getLogger().e('❌ 保存文章内容数据到本地数据库失败: $e');
      return false;
    }
  }

}
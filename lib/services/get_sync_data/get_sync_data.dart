import 'package:isar/isar.dart';
import '../../api/user_api.dart';
import '../../basics/logger.dart';
import '../../basics/ui.dart';
import '../../db/database_service.dart';
import '../../db/category/category_db.dart';
import '../../db/category/category_service.dart';
import '../../db/article/article_db.dart';
import '../../db/article/service/article_service.dart';
import '../../db/article_content/article_content_db.dart';
import '../../db/tag/tag_db.dart';
import '../../db/annotation/enhanced_annotation_db.dart';
import 'models/category_model.dart';
import 'models/tag_model.dart';
import 'models/article_model.dart';
import 'models/article_content_model.dart';
import 'models/annotation_model.dart';

/// 获取同步数据
class GetSyncData {
  final CategoryService _categoryService = CategoryService();
  final ArticleService _articleService = ArticleService.instance;


  List<String> dbList = [
    "category",
    "tag",
    "article",
    "article_content",
    "annotation",
  ];

  // 进度回调函数
  Function(String message, double progress)? onProgress;

  /// 全量同步
  Future<bool> completeSyncAllData({Function(String message, double progress)? progressCallback}) async {
    try {
      getLogger().i('🔄 开始全量同步所有数据...');
      onProgress = progressCallback;
      
      _updateProgress('正在获取服务端时间...', 0.1);
      
      bool allSuccess = true;
      final totalSteps = dbList.length;
      
      // 逐个同步各个数据库
      for (int i = 0; i < dbList.length; i++) {
        final dbName = dbList[i];
        final currentProgress = 0.2 + (i / totalSteps) * 0.7;
        
        try {
          getLogger().i('🔄 开始同步 $dbName 数据...');
          _updateProgress('正在同步 $dbName 数据...', currentProgress);
          
          bool success = false;
          switch (dbName) {
            case "category":
              success = await _syncCategoryData(dbName);
              break;
            case "tag":
              success = await _syncTagData(dbName);
              break;
            case "article":
              success = await _syncArticleData(dbName);
              break;
            case "article_content":
              success = await _syncArticleContentData(dbName);
              break;

            case "annotation":
              success = await _syncAnnotationData(dbName);
              break;
            default:
              getLogger().w('⚠️ 未知的数据库类型: $dbName');
              success = true;
          }
          
          if (success) {
            getLogger().i('✅ $dbName 数据同步成功');
            _updateProgress('$dbName 数据同步成功', 0.2 + ((i + 1) / totalSteps) * 0.7);
          } else {
            getLogger().e('❌ $dbName 数据同步失败');
            allSuccess = false;
          }
          
        } catch (e) {
          getLogger().e('❌ 同步 $dbName 数据时发生异常: $e');
          allSuccess = false;
        }
      }
      
      if (allSuccess) {
        getLogger().i('✅ 全量同步完成');
        _updateProgress('全量同步完成', 0.95);
        // 标记全量同步完成
        globalBoxStorage.write('completeSyncStatus', true);
      } else {
        getLogger().e('❌ 全量同步失败，部分数据同步出错');
        _updateProgress('同步失败，部分数据出错', 0.0);
      }
      
      return allSuccess;
      
    } catch (e) {
      getLogger().e('❌ 全量同步发生异常: $e');
      _updateProgress('同步异常: $e', 0.0);
      return false;
    }
  }

  /// 更新进度
  void _updateProgress(String message, double progress) {
    onProgress?.call(message, progress);
  }

  /// 通用数据同步方法
  Future<bool> _syncDataGeneric<T>({
    required String dbName,
    required String dataTypeName,
    required bool isCompleteSync,
    required int currentTime,
    required T Function(dynamic) parseRecord,
    required Future<bool> Function(List<T>) saveDataToLocal,
    required double progressOffset,
  }) async {
    try {
      final syncType = isCompleteSync ? '全量' : '增量';
      // getLogger().i('🔄 开始${dataTypeName}数据${syncType}同步...');
      _updateProgress('初始化${dataTypeName}数据同步...', progressOffset);
      
      // 获取数据库服务实例
      final dbService = DatabaseService.instance;
      if (!dbService.isInitialized) {
        getLogger().e('❌ 数据库未初始化');
        _updateProgress('数据库未初始化', 0.0);
        return false;
      }
      
      // 分页获取数据
      int page = 0;
      const int limit = 100; // 每页100条
      bool hasMoreData = true;
      
      List<T> allData = [];
      while (hasMoreData) {
        try {
          // getLogger().i('📄 获取第 ${page + 1} 页${dataTypeName}数据 (每页 $limit 条)...');
          _updateProgress('获取第 ${page + 1} 页${dataTypeName}数据...', progressOffset + 0.05 + (page * 0.1));
          
          // 构建请求参数
          final requestParams = {
            "complete_sync": isCompleteSync,
            "current_time": currentTime,
            "db_name": dbName,
            "page": page,
            "limit": limit,
          };
          
          // 调用同步接口
          final response = await UserApi.getSyncAllDataApi(requestParams);
          
          if (response['code'] != 0) {
            getLogger().e('❌ 获取${dataTypeName}数据失败: ${response['msg']}');
            _updateProgress('获取${dataTypeName}数据失败: ${response['msg']}', 0.0);
            return false;
          }
          
          final data = response['data'];
          final records = data['records'] as List<dynamic>? ?? [];
          final total = data['total'] as int? ?? 0;
          
          // getLogger().i('📋 第 ${page + 1} 页获取到 ${records.length} 条${dataTypeName}数据，总计 $total 条');
          
          // 转换为Model
          for (final record in records) {
            try {
              final model = parseRecord(record);
              allData.add(model);
            } catch (e) {
              getLogger().e('❌ 解析${dataTypeName}数据失败: $e, 数据: $record');
            }
          }
          
          // 检查是否还有更多数据
          hasMoreData = records.length == limit && allData.length < total;
          page++;
          
        } catch (e) {
          getLogger().e('❌ 获取第 ${page + 1} 页${dataTypeName}数据时发生异常: $e');
          _updateProgress('获取${dataTypeName}数据异常: $e', 0.0);
          return false;
        }
      }
      
      // getLogger().i('📊 总共获取到 ${allData.length} 条${dataTypeName}数据');
      _updateProgress('获取到 ${allData.length} 条${dataTypeName}数据，开始保存到本地...', progressOffset + 0.3);
      
      if (allData.isEmpty) {
        // getLogger().i('✅ 服务端暂无${dataTypeName}数据');
        _updateProgress('服务端暂无${dataTypeName}数据', progressOffset + 0.35);
        return true;
      }
      
      // 保存数据到本地数据库
      return await saveDataToLocal(allData);
      
    } catch (e) {
      getLogger().e('❌ ${dataTypeName}数据同步发生异常: $e');
      return false;
    }
  }

  /// 同步标签数据
  Future<bool> _syncTagData(String dbName) async {
    return await _syncDataGeneric<TagModel>(
      dbName: dbName,
      dataTypeName: '标签',
      isCompleteSync: true,
      currentTime: 0,
      parseRecord: (record) => TagModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveTagDataToLocal,
      progressOffset: 0.3,
    );
  }

  /// 同步标注数据
  Future<bool> _syncAnnotationData(String dbName) async {
    return await _syncDataGeneric<AnnotationModel>(
      dbName: dbName,
      dataTypeName: '标注',
      isCompleteSync: true,
      currentTime: 0,
      parseRecord: (record) => AnnotationModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveAnnotationDataToLocal,
      progressOffset: 0.8,
    );
  }

  /// 同步分类数据
  Future<bool> _syncCategoryData(String dbName) async {
    final result = await _syncDataGeneric<CategoryModel>(
      dbName: dbName,
      dataTypeName: '分类',
      isCompleteSync: true,
      currentTime: 0,
      parseRecord: (record) => CategoryModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveCategoryDataToLocal,
      progressOffset: 0.3,
    );
    
    // 如果是空数据，创建默认分类
    if (result) {
      final dbService = DatabaseService.instance;
      final categories = await dbService.categories.count();
      if (categories == 0) {
        getLogger().i('📁 服务端暂无分类数据，创建默认分类');
        await createCategory();
      }
    }
    
    return result;
  }

  /// 保存标签数据到本地数据库
  Future<bool> _saveTagDataToLocal(List<TagModel> tags) async {
    try {
      getLogger().i('💾 开始保存 ${tags.length} 条标签数据到本地数据库...');
      _updateProgress('正在保存标签数据到本地数据库...', 0.65);
      
      final dbService = DatabaseService.instance;

      int successCount = 0;
      int updateCount = 0;
      int createCount = 0;
      
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
              if (tagModel.updateTimestamp > existingTag.updateTimestamp) {
                _updateTagFromModel(existingTag, tagModel);
                await dbService.tags.put(existingTag);
                updateCount++;
                getLogger().d('🔄 更新标签: ${tagModel.name} (serviceId: ${tagModel.id})');
              } else {
                getLogger().d('⏭️ 跳过标签（本地数据较新）: ${tagModel.name}');
              }
            } else {
              // 创建新标签
              final newTag = _createTagFromModel(tagModel);
              await dbService.tags.put(newTag);
              createCount++;
              getLogger().d('✨ 创建标签: ${tagModel.name} (serviceId: ${tagModel.id})');
            }
            
            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存标签失败: ${tagModel.name}, 错误: $e');
          }
        }
      });
      
      getLogger().i('✅ 标签数据保存完成: 总计 $successCount 条，新建 $createCount 条，更新 $updateCount 条');
      _updateProgress('标签数据保存完成: 新建 $createCount 条，更新 $updateCount 条', 0.7);
      return successCount == tags.length;
      
    } catch (e) {
      getLogger().e('❌ 保存标签数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 从TagModel创建TagDb
  TagDb _createTagFromModel(TagModel model) {
    final now = DateTime.now();
    return TagDb()
      ..userId = model.userId
      ..serviceId = model.id
      ..name = model.name
      ..version = model.version
      ..updateTimestamp = model.updateTimestamp
      ..createdAt = _parseDateTime(model.createTime) ?? now
      ..updatedAt = _parseDateTime(model.updateTime) ?? now;
  }

  /// 更新TagDb从TagModel
  void _updateTagFromModel(TagDb tag, TagModel model) {
    tag.userId = model.userId;
    tag.serviceId = model.id;
    tag.name = model.name;
    tag.version = model.version;
    tag.updateTimestamp = model.updateTimestamp;
    tag.updatedAt = _parseDateTime(model.updateTime) ?? DateTime.now();
  }

  /// 保存分类数据到本地数据库
  Future<bool> _saveCategoryDataToLocal(List<CategoryModel> categories) async {
    try {
      getLogger().i('💾 开始保存 ${categories.length} 条分类数据到本地数据库...');
      _updateProgress('正在保存分类数据到本地数据库...', 0.65);
      
      final dbService = DatabaseService.instance;
      final categoryService = CategoryService.instance;

      int successCount = 0;
      int updateCount = 0;
      int createCount = 0;
      
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
              if (categoryModel.updateTimestamp > existingCategory.updateTimestamp) {
                _updateCategoryFromModel(existingCategory, categoryModel);
                await dbService.categories.put(existingCategory);
                updateCount++;
                getLogger().d('🔄 更新分类: ${categoryModel.name} (serverId: ${categoryModel.id})');
              } else {
                getLogger().d('⏭️ 跳过分类（本地数据较新）: ${categoryModel.name}');
              }
            } else {
              // 创建新分类
              final newCategory = _createCategoryFromModel(categoryModel);
              await dbService.categories.put(newCategory);
              createCount++;
              getLogger().d('✨ 创建分类: ${categoryModel.name} (serverId: ${categoryModel.id})');
            }
            
            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存分类失败: ${categoryModel.name}, 错误: $e');
          }
        }
      });
      
      getLogger().i('✅ 分类数据保存完成: 总计 $successCount 条，新建 $createCount 条，更新 $updateCount 条');
      _updateProgress('分类数据保存完成: 新建 $createCount 条，更新 $updateCount 条', 0.7);
      return successCount == categories.length;
      
    } catch (e) {
      getLogger().e('❌ 保存分类数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 从CategoryModel创建CategoryDb
  CategoryDb _createCategoryFromModel(CategoryModel model) {
    final now = DateTime.now();
    return CategoryDb()
      ..userId = model.userId
      ..serverId = model.id
      ..name = model.name
      ..description = model.description.isNotEmpty ? model.description : null
      ..icon = model.icon.isNotEmpty ? model.icon : null
      ..color = model.color.isNotEmpty ? model.color : null
      ..sortOrder = model.sortOrder
      ..isEnabled = model.isEnabled
      ..isDeleted = model.isDeleted
      ..parentId = model.parentId > 0 ? model.parentId : null
      ..level = model.level
      ..path = model.path
      ..version = model.version
      ..uuid = model.uuid
      ..updateTimestamp = model.updateTimestamp
      ..isSynced = true
      ..createdAt = now
      ..updatedAt = now;
  }

  /// 更新CategoryDb从CategoryModel
  void _updateCategoryFromModel(CategoryDb category, CategoryModel model) {
    category.userId = model.userId;
    category.serverId = model.id;
    category.name = model.name;
    category.description = model.description.isNotEmpty ? model.description : null;
    category.icon = model.icon.isNotEmpty ? model.icon : null;
    category.color = model.color.isNotEmpty ? model.color : null;
    category.sortOrder = model.sortOrder;
    category.isEnabled = model.isEnabled;
    category.isDeleted = model.isDeleted;
    category.parentId = model.parentId > 0 ? model.parentId : null;
    category.level = model.level;
    category.path = model.path;
    category.version = model.version;
    category.updateTimestamp = model.updateTimestamp;
    category.isSynced = true;
    category.updatedAt = DateTime.now();
  }

  /// 同步文章数据
  Future<bool> _syncArticleData(String dbName) async {
    return await _syncDataGeneric<ArticleModel>(
      dbName: dbName,
      dataTypeName: '文章',
      isCompleteSync: true,
      currentTime: 0,
      parseRecord: (record) => ArticleModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveArticleDataToLocal,
      progressOffset: 0.3,
    );
  }

  /// 保存文章数据到本地数据库
  Future<bool> _saveArticleDataToLocal(List<ArticleModel> articles) async {
    try {
      getLogger().i('💾 开始保存 ${articles.length} 条文章数据到本地数据库...');
      _updateProgress('正在保存文章数据到本地数据库...', 0.65);
      
      final dbService = DatabaseService.instance;

      int successCount = 0;
      int updateCount = 0;
      int createCount = 0;
      
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
              if (articleModel.updateTimestamp > existingArticle.updateTimestamp) {
                _updateArticleFromModel(existingArticle, articleModel);
                await dbService.articles.put(existingArticle);
                
                // 更新文章内容
                await _saveOrUpdateArticleContent(existingArticle.id, articleModel);
                
                // 更新文章的标签和分类关联
                await _updateArticleAssociations(existingArticle, articleModel);
                
                updateCount++;
                getLogger().d('🔄 更新文章: ${articleModel.title} (serverId: ${articleModel.id})');
              } else {
                getLogger().d('⏭️ 跳过文章（本地数据较新）: ${articleModel.title}');
              }
            } else {
              // 创建新文章
              final newArticle = _createArticleFromModel(articleModel);
              await dbService.articles.put(newArticle);
              
              // 保存文章内容
              await _saveOrUpdateArticleContent(newArticle.id, articleModel);
              
              // 设置文章的标签和分类关联
              await _updateArticleAssociations(newArticle, articleModel);
              
              createCount++;
              getLogger().d('✨ 创建文章: ${articleModel.title} (serverId: ${articleModel.id})');
            }
            
            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存文章失败: ${articleModel.title}, 错误: $e');
          }
        }
      });
      
      getLogger().i('✅ 文章数据保存完成: 总计 $successCount 条，新建 $createCount 条，更新 $updateCount 条');
      _updateProgress('文章数据保存完成: 新建 $createCount 条，更新 $updateCount 条', 0.7);
      return successCount == articles.length;
      
    } catch (e) {
      getLogger().e('❌ 保存文章数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 从ArticleModel创建ArticleDb
  ArticleDb _createArticleFromModel(ArticleModel model) {
    final now = DateTime.now();
    return ArticleDb()
      ..serviceId = model.id
      ..userId = model.userId
      ..title = model.title
      ..excerpt = model.textContent.isNotEmpty ? _truncateText(model.textContent, 200) : null
      ..content = model.textContent
      ..domain = model.domain
      ..author = model.author
      ..articleDate = _parseDateTime(model.articleDate)
      ..url = model.url
      ..shareOriginalContent = model.shareOriginalContent
      // ..mhtmlPath = ""//model.mhtmlPath
      // ..isGenerateMhtml = false//model.mhtmlPath.isNotEmpty
      ..markdownStatus = model.markdownStatus
      ..isRead = model.isRead
      ..readCount = model.readCount
      ..readDuration = model.readDuration
      ..readProgress = model.readProgress.toDouble()
      ..isArchived = model.isArchived
      ..isImportant = model.isImportant
      ..isCreateService = true
      ..isGenerateMarkdown = model.markdownStatus == 1
      ..version = model.version
      ..updateTimestamp = model.updateTimestamp
      ..createdAt = _parseDateTime(model.createTime) ?? now
      ..updatedAt = _parseDateTime(model.updateTime) ?? now;
  }

  /// 更新ArticleDb从ArticleModel
  void _updateArticleFromModel(ArticleDb article, ArticleModel model) {
    article.serviceId = model.id;
    article.userId = model.userId;
    article.title = model.title;
    article.excerpt = model.textContent.isNotEmpty ? _truncateText(model.textContent, 200) : null;
    article.content = model.textContent;
    article.domain = model.domain;
    article.author = model.author;
    article.articleDate = _parseDateTime(model.articleDate);
    article.url = model.url;
    article.shareOriginalContent = model.shareOriginalContent;
    article.mhtmlPath = "";//model.mhtmlPath;
    article.isGenerateMhtml = false;//model.mhtmlPath.isNotEmpty;
    article.markdownStatus = model.markdownStatus;
    article.isRead = model.isRead;
    article.readCount = model.readCount;
    article.readDuration = model.readDuration;
    article.readProgress = model.readProgress.toDouble();
    article.isArchived = model.isArchived;
    article.isImportant = model.isImportant;
    article.isCreateService = true;
    article.isGenerateMarkdown = model.markdownStatus == 1;
    article.version = model.version;
    article.updateTimestamp = model.updateTimestamp;
    article.updatedAt = _parseDateTime(model.updateTime) ?? DateTime.now();
  }

  /// 解析日期时间字符串
  DateTime? _parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return null;
    }
    
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      getLogger().e('❌ 解析日期时间失败: $dateTimeStr, 错误: $e');
      return null;
    }
  }

  /// 截取文本到指定长度
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
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

  /// 同步文章内容数据
  Future<bool> _syncArticleContentData(String dbName) async {
    return await _syncDataGeneric<ArticleContentModel>(
      dbName: dbName,
      dataTypeName: '文章内容',
      isCompleteSync: true,
      currentTime: 0,
      parseRecord: (record) => ArticleContentModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveArticleContentDataToLocal,
      progressOffset: 0.7,
    );
  }

  /// 保存标注数据到本地数据库
  Future<bool> _saveAnnotationDataToLocal(List<AnnotationModel> annotations) async {
    try {
      getLogger().i('💾 开始保存 ${annotations.length} 条标注数据到本地数据库...');
      _updateProgress('正在保存标注数据到本地数据库...', 0.85);
      
      final dbService = DatabaseService.instance;

      // 预加载所有需要的文章和文章内容映射
      // final clientArticleIds = annotations.map((a) => a.clientArticleId).toSet().toList();
      // final clientArticleContentIds = annotations.map((a) => a.clientArticleContentId).toSet().toList();
      
      // 查找本地文章ID映射（通过serviceId查找，因为clientArticleId可能不匹配）
      // final localArticles = await dbService.articles.where().findAll();
      // final articleMap = <int, int>{}; // clientArticleId -> localArticleId
      
      // final localArticleContents = await dbService.articleContent.where().findAll();
      // final articleContentMap = <int, int>{}; // clientArticleContentId -> localArticleContentId
      //
      // // 建立映射关系
      // for (final article in localArticles) {
      //   // 这里可能需要根据实际情况调整映射逻辑
      //   // 暂时假设直接通过ID匹配
      // }

      int successCount = 0;
      int updateCount = 0;
      int createCount = 0;
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
              if (annotationModel.updateTimestamp > existingAnnotation.updateTimestamp) {
                _updateAnnotationFromModel(existingAnnotation, annotationModel, localArticle.id, localArticleContent.id);
                await dbService.enhancedAnnotation.put(existingAnnotation);
                updateCount++;
                getLogger().d('🔄 更新标注: ${annotationModel.highlightId}');
              } else {
                getLogger().d('⏭️ 跳过标注（本地数据较新）: ${annotationModel.highlightId}');
              }
            } else {
              // 创建新标注
              final newAnnotation = _createAnnotationFromModel(annotationModel, localArticle.id, localArticleContent.id);
              await dbService.enhancedAnnotation.put(newAnnotation);
              createCount++;
              getLogger().d('✨ 创建标注: ${annotationModel.highlightId}');
            }
            
            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存标注失败: ${annotationModel.highlightId}, 错误: $e');
          }
        }
      });
      
      getLogger().i('✅ 标注数据保存完成: 总计 $successCount 条，新建 $createCount 条，更新 $updateCount 条, 跳过 $skipCount 条');
      _updateProgress('标注数据保存完成: 新建 $createCount 条，更新 $updateCount 条', 0.9);
      return successCount == (annotations.length - skipCount);
      
    } catch (e) {
      getLogger().e('❌ 保存标注数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 保存文章内容数据到本地数据库
  Future<bool> _saveArticleContentDataToLocal(List<ArticleContentModel> contents) async {
    try {
      getLogger().i('💾 开始保存 ${contents.length} 条文章内容数据到本地数据库...');
      _updateProgress('正在保存文章内容数据到本地数据库...', 0.85);

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
      int updateCount = 0;
      int createCount = 0;
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
              if (contentModel.updateTimestamp > existingContent.updateTimestamp) {
                _updateArticleContentFromModel(existingContent, contentModel, localArticle.id);
                await dbService.articleContent.put(existingContent);
                updateCount++;
                getLogger().d('🔄 更新文章内容: (serverId: ${contentModel.id})');
              }
            } else {
              final newContent = _createArticleContentFromModel(contentModel, localArticle.id);
              await dbService.articleContent.put(newContent);
              createCount++;
              getLogger().d('✨ 创建文章内容: (serverId: ${contentModel.id})');
            }
            successCount++;
          } catch (e) {
            getLogger().e('❌ 保存文章内容失败: (serverId: ${contentModel.id}), 错误: $e');
          }
        }
      });

      getLogger().i('✅ 文章内容数据保存完成: 总计 $successCount 条，新建 $createCount 条，更新 $updateCount 条, 跳过 $skipCount 条');
      _updateProgress('文章内容数据保存完成: 新建 $createCount 条，更新 $updateCount 条', 0.9);
      return successCount == (contents.length - skipCount);
    } catch (e) {
      getLogger().e('❌ 保存文章内容数据到本地数据库失败: $e');
      return false;
    }
  }

  /// 从ArticleContentModel创建ArticleContentDb
  ArticleContentDb _createArticleContentFromModel(ArticleContentModel model, int localArticleId) {
    final now = DateTime.now();
    return ArticleContentDb()
      ..userId = model.userId
      ..articleId = localArticleId
      ..serviceId = model.id
      ..languageCode = model.languageCode
      ..markdown = model.markdown
      ..textContent = model.textContent
      ..isOriginal = model.isOriginal
      ..version = model.version
      ..updateTimestamp = model.updateTimestamp
      ..createdAt = _parseDateTime(model.createTime) ?? now
      ..updatedAt = _parseDateTime(model.updateTime) ?? now;
  }

  /// 更新ArticleContentDb从ArticleContentModel
  void _updateArticleContentFromModel(ArticleContentDb content, ArticleContentModel model, int localArticleId) {
    content.articleId = localArticleId;
    content.serviceId = model.id;
    content.languageCode = model.languageCode;
    content.markdown = model.markdown;
    content.textContent = model.textContent;
    content.isOriginal = model.isOriginal;
    content.version = model.version;
    content.updateTimestamp = model.updateTimestamp;
    content.updatedAt = _parseDateTime(model.updateTime) ?? DateTime.now();
  }

  /// 从AnnotationModel创建EnhancedAnnotationDb
  EnhancedAnnotationDb _createAnnotationFromModel(AnnotationModel model, int localArticleId, int localArticleContentId) {
    final now = DateTime.now();
    return EnhancedAnnotationDb()
      ..userId = model.userId
      ..articleId = localArticleId
      ..articleContentId = localArticleContentId
      ..highlightId = model.highlightId
      ..startXPath = model.startXPath
      ..startOffset = model.startOffset
      ..endXPath = model.endXPath
      ..endOffset = model.endOffset
      ..selectedText = model.selectedText
      ..beforeContext = model.beforeContext
      ..afterContext = model.afterContext
      ..annotationType = _parseAnnotationType(model.annotationType)
      ..colorType = _parseAnnotationColor(model.colorType)
      ..noteContent = model.noteContent
      ..crossParagraph = model.crossParagraph
      ..rangeFingerprint = model.rangeFingerprint
      ..boundingX = model.boundingX
      ..boundingY = model.boundingY
      ..boundingWidth = model.boundingWidth
      ..boundingHeight = model.boundingHeight
      ..version = model.version
      ..updateTimestamp = model.updateTimestamp
      ..createdAt = _parseDateTime(model.createTime) ?? now
      ..updatedAt = _parseDateTime(model.updateTime) ?? now
      ..isSynced = true;
  }

  /// 更新EnhancedAnnotationDb从AnnotationModel
  void _updateAnnotationFromModel(EnhancedAnnotationDb annotation, AnnotationModel model, int localArticleId, int localArticleContentId) {
    annotation.userId = model.userId;
    annotation.articleId = localArticleId;
    annotation.articleContentId = localArticleContentId;
    annotation.highlightId = model.highlightId;
    annotation.startXPath = model.startXPath;
    annotation.startOffset = model.startOffset;
    annotation.endXPath = model.endXPath;
    annotation.endOffset = model.endOffset;
    annotation.selectedText = model.selectedText;
    annotation.beforeContext = model.beforeContext;
    annotation.afterContext = model.afterContext;
    annotation.annotationType = _parseAnnotationType(model.annotationType);
    annotation.colorType = _parseAnnotationColor(model.colorType);
    annotation.noteContent = model.noteContent;
    annotation.crossParagraph = model.crossParagraph;
    annotation.rangeFingerprint = model.rangeFingerprint;
    annotation.boundingX = model.boundingX;
    annotation.boundingY = model.boundingY;
    annotation.boundingWidth = model.boundingWidth;
    annotation.boundingHeight = model.boundingHeight;
    annotation.version = model.version;
    annotation.updateTimestamp = model.updateTimestamp;
    annotation.updatedAt = _parseDateTime(model.updateTime) ?? DateTime.now();
    annotation.isSynced = true;
  }

  /// 解析标注类型字符串为枚举
  AnnotationType _parseAnnotationType(String type) {
    switch (type.toLowerCase()) {
      case 'highlight':
        return AnnotationType.highlight;
      case 'note':
        return AnnotationType.note;
      default:
        getLogger().w('⚠️ 未知的标注类型: $type，使用默认值 highlight');
        return AnnotationType.highlight;
    }
  }

  /// 解析颜色类型字符串为枚举
  AnnotationColor _parseAnnotationColor(String color) {
    switch (color.toLowerCase()) {
      case 'yellow':
        return AnnotationColor.yellow;
      case 'green':
        return AnnotationColor.green;
      case 'blue':
        return AnnotationColor.blue;
      case 'red':
        return AnnotationColor.red;
      case 'purple':
        return AnnotationColor.purple;
      case 'pink':
        return AnnotationColor.pink;
      default:
        getLogger().w('⚠️ 未知的颜色类型: $color，使用默认值 yellow');
        return AnnotationColor.yellow;
    }
  }

  /// 增量同步分类数据
  Future<bool> incrementSyncCategoryData(String dbName, int currentTime) async {
    return await _syncDataGeneric<CategoryModel>(
      dbName: dbName,
      dataTypeName: '分类',
      isCompleteSync: false,
      currentTime: currentTime,
      parseRecord: (record) => CategoryModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveCategoryDataToLocal,
      progressOffset: 0.1,
    );
  }

  /// 增量同步标签数据
  Future<bool> incrementSyncTagData(String dbName, int currentTime) async {
    return await _syncDataGeneric<TagModel>(
      dbName: dbName,
      dataTypeName: '标签',
      isCompleteSync: false,
      currentTime: currentTime,
      parseRecord: (record) => TagModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveTagDataToLocal,
      progressOffset: 0.3,
    );
  }

  /// 增量同步文章数据
  Future<bool> incrementSyncArticleData(String dbName, int currentTime) async {
    return await _syncDataGeneric<ArticleModel>(
      dbName: dbName,
      dataTypeName: '文章',
      isCompleteSync: false,
      currentTime: currentTime,
      parseRecord: (record) => ArticleModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveArticleDataToLocal,
      progressOffset: 0.5,
    );
  }

  /// 增量同步文章内容数据
  Future<bool> incrementSyncArticleContentData(String dbName, int currentTime) async {
    return await _syncDataGeneric<ArticleContentModel>(
      dbName: dbName,
      dataTypeName: '文章内容',
      isCompleteSync: false,
      currentTime: currentTime,
      parseRecord: (record) => ArticleContentModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveArticleContentDataToLocal,
      progressOffset: 0.7,
    );
  }

  /// 增量同步标注数据
  Future<bool> incrementSyncAnnotationData(String dbName, int currentTime) async {
    return await _syncDataGeneric<AnnotationModel>(
      dbName: dbName,
      dataTypeName: '标注',
      isCompleteSync: false,
      currentTime: currentTime,
      parseRecord: (record) => AnnotationModel.fromJson(record as Map<String, dynamic>),
      saveDataToLocal: _saveAnnotationDataToLocal,
      progressOffset: 0.8,
    );
  }

  createCategory() async {
    var allCategories = await _categoryService.getAllCategories();
    if (allCategories.isEmpty) {

      // final serviceCurrentTime = await getServiceCurrentTime();
      // globalBoxStorage.write('serviceCurrentTime', serviceCurrentTime + 1000);
      // getLogger().i('📅 服务端时间已更新: $serviceCurrentTime');

      await _categoryService.createCategory(name: '默认分组', icon: '👋');
      allCategories = await _categoryService.getAllCategories();
    }
  }
}
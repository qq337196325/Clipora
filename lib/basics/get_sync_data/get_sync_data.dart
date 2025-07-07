import 'package:isar/isar.dart';
import '../logger.dart';
import '../ui.dart';
import '../../api/user_api.dart';
import '../../db/database_service.dart';
import '../../db/category/category_db.dart';
import '../../db/category/category_service.dart';
import '../../db/article/article_db.dart';
import '../../db/article/service/article_service.dart';
import '../../db/article_content/article_content_db.dart';
import 'models/category_model.dart';
import 'models/article_model.dart';
import 'models/article_content_model.dart';

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
            case "article":
              success = await _syncArticleData(dbName);
              break;
            case "article_content":
              success = await _syncArticleContentData(dbName);
              break;
            case "tag":
              // TODO: 实现标签同步
              getLogger().i('⏭️ 跳过标签同步（待实现）');
              success = true;
              break;
            case "annotation":
              // TODO: 实现标注同步
              getLogger().i('⏭️ 跳过标注同步（待实现）');
              success = true;
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
        box.write('completeSyncStatus', true);
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

  /// 同步分类数据
  Future<bool> _syncCategoryData(String dbName) async {
    try {
      getLogger().i('🔄 开始分类数据全量同步...');
      _updateProgress('初始化分类数据同步...', 0.3);
      
      // 获取数据库服务实例
      final dbService = DatabaseService.instance;
      if (!dbService.isInitialized) {
        getLogger().e('❌ 数据库未初始化');
        _updateProgress('数据库未初始化', 0.0);
        return false;
      }
      
      // 分页获取所有分类数据
      int page = 0;
      const int limit = 100; // 每页100条
      bool hasMoreData = true;
      
      List<CategoryModel> allCategories = [];
      while (hasMoreData) {
        try {
          getLogger().i('📄 获取第 ${page + 1} 页分类数据 (每页 $limit 条)...');
          _updateProgress('获取第 ${page + 1} 页分类数据...', 0.35 + (page * 0.1));
          
          // 构建请求参数
          final requestParams = {
            "complete_sync": true,
            "current_time": 0,
            "db_name": dbName,
            "page": page,
            "limit": limit,
          };
          
          // 调用同步接口
          final response = await UserApi.getSyncAllDataApi(requestParams);
          
          if (response['code'] != 0) {
            getLogger().e('❌ 获取分类数据失败: ${response['msg']}');
            _updateProgress('获取分类数据失败: ${response['msg']}', 0.0);
            return false;
          }
          
          final data = response['data'];
          final records = data['records'] as List<dynamic>? ?? [];
          final total = data['total'] as int? ?? 0;
          
          getLogger().i('📋 第 ${page + 1} 页获取到 ${records.length} 条分类数据，总计 $total 条');
          
          // 转换为CategoryModel
          for (final record in records) {
            try {
              final categoryModel = CategoryModel.fromJson(record as Map<String, dynamic>);
              allCategories.add(categoryModel);
            } catch (e) {
              getLogger().e('❌ 解析分类数据失败: $e, 数据: $record');
            }
          }
          
          // 检查是否还有更多数据
          hasMoreData = records.length == limit && allCategories.length < total;
          page++;
          
        } catch (e) {
          getLogger().e('❌ 获取第 ${page + 1} 页分类数据时发生异常: $e');
          _updateProgress('获取分类数据异常: $e', 0.0);
          return false;
        }
      }
      
      getLogger().i('📊 总共获取到 ${allCategories.length} 条分类数据');
      _updateProgress('获取到 ${allCategories.length} 条分类数据，开始保存到本地...', 0.6);
      
      if (allCategories.isEmpty) {
        getLogger().i('✅ 服务端暂无分类数据');
        _updateProgress('服务端暂无分类数据', 0.65);

        /// 表示新用户，添加分组
        createCategory();
        return true;
      }
      
      // 保存分类数据到本地数据库
      return await _saveCategoryDataToLocal(allCategories);
      
    } catch (e) {
      getLogger().e('❌ 分类数据同步发生异常: $e');
      return false;
    }
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
                .filter()
                .serverIdEqualTo(categoryModel.id)
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
    try {
      getLogger().i('🔄 开始文章数据全量同步...');
      _updateProgress('初始化文章数据同步...', 0.3);
      
      // 获取数据库服务实例
      final dbService = DatabaseService.instance;
      if (!dbService.isInitialized) {
        getLogger().e('❌ 数据库未初始化');
        _updateProgress('数据库未初始化', 0.0);
        return false;
      }
      
      // 分页获取所有文章数据
      int page = 0;
      const int limit = 100; // 每页100条
      bool hasMoreData = true;
      
      List<ArticleModel> allArticles = [];
      while (hasMoreData) {
        try {
          getLogger().i('📄 获取第 ${page + 1} 页文章数据 (每页 $limit 条)...');
          _updateProgress('获取第 ${page + 1} 页文章数据...', 0.35 + (page * 0.1));
          
          // 构建请求参数
          final requestParams = {
            "complete_sync": true,
            "current_time": 0,
            "db_name": dbName,
            "page": page,
            "limit": limit,
          };
          
          // 调用同步接口
          final response = await UserApi.getSyncAllDataApi(requestParams);
          
          if (response['code'] != 0) {
            getLogger().e('❌ 获取文章数据失败: ${response['msg']}');
            _updateProgress('获取文章数据失败: ${response['msg']}', 0.0);
            return false;
          }
          
          final data = response['data'];
          final records = data['records'] as List<dynamic>? ?? [];
          final total = data['total'] as int? ?? 0;
          
          getLogger().i('📋 第 ${page + 1} 页获取到 ${records.length} 条文章数据，总计 $total 条');
          
          // 转换为ArticleModel
          for (final record in records) {
            try {
              final articleModel = ArticleModel.fromJson(record as Map<String, dynamic>);
              allArticles.add(articleModel);
            } catch (e) {
              getLogger().e('❌ 解析文章数据失败: $e, 数据: $record');
            }
          }
          
          // 检查是否还有更多数据
          hasMoreData = records.length == limit && allArticles.length < total;
          page++;
          
        } catch (e) {
          getLogger().e('❌ 获取第 ${page + 1} 页文章数据时发生异常: $e');
          _updateProgress('获取文章数据异常: $e', 0.0);
          return false;
        }
      }
      
      getLogger().i('📊 总共获取到 ${allArticles.length} 条文章数据');
      _updateProgress('获取到 ${allArticles.length} 条文章数据，开始保存到本地...', 0.6);
      
      if (allArticles.isEmpty) {
        getLogger().i('✅ 服务端暂无文章数据');
        _updateProgress('服务端暂无文章数据', 0.65);
        return true;
      }
      
      // 保存文章数据到本地数据库
      return await _saveArticleDataToLocal(allArticles);
      
    } catch (e) {
      getLogger().e('❌ 文章数据同步发生异常: $e');
      return false;
    }
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
      ..mhtmlPath = ""//model.mhtmlPath
      ..isGenerateMhtml = false//model.mhtmlPath.isNotEmpty
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
    try {
      getLogger().i('🔄 开始文章内容数据全量同步...');
      _updateProgress('初始化文章内容数据同步...', 0.7);

      final dbService = DatabaseService.instance;
      if (!dbService.isInitialized) {
        getLogger().e('❌ 数据库未初始化');
        _updateProgress('数据库未初始化', 0.0);
        return false;
      }

      int page = 0;
      const int limit = 100;
      bool hasMoreData = true;

      List<ArticleContentModel> allArticleContents = [];
      while (hasMoreData) {
        try {
          getLogger().i('📄 获取第 ${page + 1} 页文章内容数据 (每页 $limit 条)...');
          _updateProgress('获取第 ${page + 1} 页文章内容数据...', 0.7 + (page * 0.05));

          final requestParams = {
            "complete_sync": true,
            "current_time": 0,
            "db_name": dbName,
            "page": page,
            "limit": limit,
          };

          final response = await UserApi.getSyncAllDataApi(requestParams);

          if (response['code'] != 0) {
            getLogger().e('❌ 获取文章内容数据失败: ${response['msg']}');
            _updateProgress('获取文章内容数据失败: ${response['msg']}', 0.0);
            return false;
          }

          final data = response['data'];
          final records = data['records'] as List<dynamic>? ?? [];
          final total = data['total'] as int? ?? 0;

          getLogger().i('📋 第 ${page + 1} 页获取到 ${records.length} 条文章内容数据，总计 $total 条');

          for (final record in records) {
            try {
              final contentModel = ArticleContentModel.fromJson(record as Map<String, dynamic>);
              allArticleContents.add(contentModel);
            } catch (e) {
              getLogger().e('❌ 解析文章内容数据失败: $e, 数据: $record');
            }
          }

          hasMoreData = records.length == limit && allArticleContents.length < total;
          page++;

        } catch (e) {
          getLogger().e('❌ 获取第 ${page + 1} 页文章内容数据时发生异常: $e');
          _updateProgress('获取文章内容数据异常: $e', 0.0);
          return false;
        }
      }

      getLogger().i('📊 总共获取到 ${allArticleContents.length} 条文章内容数据');
      _updateProgress('获取到 ${allArticleContents.length} 条文章内容数据，开始保存到本地...', 0.8);

      if (allArticleContents.isEmpty) {
        getLogger().i('✅ 服务端暂无文章内容数据');
        _updateProgress('服务端暂无文章内容数据', 0.85);
        return true;
      }

      return await _saveArticleContentDataToLocal(allArticleContents);

    } catch (e) {
      getLogger().e('❌ 文章内容数据同步发生异常: $e');
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

  createCategory() async {
    var allCategories = await _categoryService.getAllCategories();
    if (allCategories.isEmpty) {

      final serviceCurrentTime = await getServiceCurrentTime();
      box.write('serviceCurrentTime', serviceCurrentTime + 1000);
      getLogger().i('📅 服务端时间已更新: $serviceCurrentTime');

      await _categoryService.createCategory(name: '默认分组', icon: '👋');
      allCategories = await _categoryService.getAllCategories();
    }
  }
}
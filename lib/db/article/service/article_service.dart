import 'package:clipora/db/article_content/article_content_db.dart';
import 'package:clipora/db/category/category_db.dart';
import 'package:isar/isar.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../../basics/logger.dart';
import '../../../basics/ui.dart';
import '../../sync_operation/sync_operation.dart';
import '../article_db.dart';
import 'article_create_service.dart';



/// 文章服务类
class ArticleService extends ArticleCreateService {

  static ArticleService get instance => Get.find<ArticleService>();


  /// 根据URL查找文章
  Future<ArticleDb?> findArticleByUrl(String url) async {

    try {
      final article = await dbService.articles
          .filter()
          .urlEqualTo(url)
          .findFirst();
      
      if (article != null) {
        getLogger().i('🔍 找到重复文章: ${article.title}');
      }
      
      return article;
    } catch (e) {
      getLogger().e('❌ 查找文章失败: $e');
      return null;
    }
  }

  /// 获取所有文章
  Future<List<ArticleDb>> getAllArticles() async {

    try {
      return await dbService.articles
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取文章列表失败: $e');
      return [];
    }
  }

  /// 获取未读文章
  Future<List<ArticleDb>> getUnreadArticles({int limit = 5}) async {

    try {
      return await dbService.articles
          .where()
          .filter()
          .isReadEqualTo(0)
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取未读文章列表失败: $e');
      return [];
    }
  }

  /// 获取未读文章总数量
  Future<int> getUnreadArticlesCount() async {

    try {
      return await dbService.articles
          .where()
          .filter()
          .isReadEqualTo(0)
          .count();
    } catch (e) {
      getLogger().e('❌ 获取未读文章数量失败: $e');
      return 0;
    }
  }

  /// 获取最近阅读的文章
  Future<List<ArticleDb>> getRecentlyReadArticles({int limit = 5}) async {

    try {
      return await dbService.articles
          .where()
          .filter()
          .deletedAtIsNull() // 过滤未删除的文章
          .isReadEqualTo(1)
          .sortByLastReadTimeDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取最近阅读文章列表失败: $e');
      return [];
    }
  }

  /// 根据ID获取文章
  Future<ArticleDb?> getArticleById(int articleId) async {
    try {
      return await dbService.articles.get(articleId);
    } catch (e) {
      getLogger().e('❌ 获取文章失败，ID: $articleId, error: $e');
      return null;
    }
  }

  /// 根据服务端ID查找文章
  Future<ArticleDb?> findArticleByServiceId(String serviceId) async {

    try {
      // serviceId 字段需要有 @Index() 才能有效查询
      return await dbService.articles
          .where()
          .serviceIdEqualTo(serviceId)
          .findFirst();
    } catch (e) {
      getLogger().e('❌ 根据服务端ID查找文章失败: $e');
      return null;
    }
  }

  /// 更新文章的服务端ID
  Future<bool> updateServiceId(int articleId, String serviceId) async {

    try {
      getLogger().i('🔄 更新文章服务端ID，本地ID: $articleId, 服务端ID: $serviceId');
      
      // 添加调试：先查询一下文章是否存在
      getLogger().i('🔍 [调试] 开始查询文章是否存在...');
      final testArticle = await dbService.articles.get(articleId);
      if (testArticle == null) {
        getLogger().e('❌ [调试] 在事务外查询：文章不存在，ID: $articleId');
        // 尝试查询所有文章，看看数据库中有什么
        final allArticles = await dbService.articles.where().findAll();
        getLogger().i('🔍 [调试] 数据库中共有 ${allArticles.length} 篇文章');
        for (final article in allArticles) {
          getLogger().i('🔍 [调试] 存在的文章ID: ${article.id}, 标题: ${article.title}');
        }
        return false;
      } else {
        getLogger().i('✅ [调试] 在事务外查询：找到文章 ${testArticle.title}');
      }
      
      // 检查数据库是否正确初始化
      getLogger().i('🔍 [调试] 检查数据库状态...');
      if (dbService.isar == null) {
        getLogger().e('❌ [调试] 数据库实例为null');
        return false;
      }
      getLogger().i('✅ [调试] 数据库实例正常');
      
      bool success = false;
      
      getLogger().i('🔄 [调试] 准备进入数据库事务...');
      await dbService.isar.writeTxn(() async {
        getLogger().i('🔄 [调试] 已进入数据库事务内部');
        
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          getLogger().i('📝 更新前的serviceId: "${article.serviceId}"');
          article.serviceId = serviceId;
          article.updatedAt = DateTime.now();
          article.updateTimestamp = getStorageServiceCurrentTime();
          await dbService.articles.put(article);
          
          // 验证更新是否成功
          final updatedArticle = await dbService.articles.get(articleId);
          if (updatedArticle != null) {
            getLogger().i('📝 更新后的serviceId: "${updatedArticle.serviceId}"');
            if (updatedArticle.serviceId == serviceId) {
              success = true;
              getLogger().i('✅ 服务端ID更新成功: ${article.title}');
            } else {
              getLogger().e('❌ 服务端ID更新验证失败，期望: "$serviceId", 实际: "${updatedArticle.serviceId}"');
            }
          } else {
            getLogger().e('❌ 更新后重新查询文章失败');
          }
        } else {
          getLogger().w('⚠️ 未找到ID为 $articleId 的文章');
        }
        
        getLogger().i('🔄 [调试] 即将退出数据库事务');
      });
      
      getLogger().i('✅ [调试] 数据库事务执行完成，success: $success');
      
      return success;
    } catch (e) {
      getLogger().e('❌ 更新服务端ID失败: $e');
      return false;
    }
  }



  /// 获取所有未同步到服务端的文章
  Future<List<ArticleDb>> getUnsyncedArticles() async {
    try {
      // 使用 isar 索引查询 isCreateService == false 的数据
      return await dbService.articles
          .filter()
          .isCreateServiceEqualTo(false)
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取未同步文章列表失败: $e');
      return [];
    }
  }


  /// 获取所有需要生成快照的文章
  Future<List<ArticleDb>> getUnsnapshottedArticles() async {
    try {
      return await dbService.articles
          .filter()
          .isGenerateMhtmlEqualTo(false)
          .deletedAtIsNull() // 过滤未删除的文章
          .serviceIdIsNotEmpty() // 服务器ID不能为空
          .markdownStatusEqualTo(0)
          .and()
          .urlIsNotEmpty()
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取待快照文章列表失败: $e');
      return [];
    }
  }


  /// 获取处理超时的文章（状态为3且超过指定时间）
  Future<List<ArticleDb>> getTimeoutProcessingArticles({int timeoutSeconds = 50}) async {
    try {
      final now = DateTime.now();
      final timeoutThreshold = now.subtract(Duration(seconds: timeoutSeconds));
      
      // 先获取所有状态为3的文章
      final articles = await dbService.articles
          .filter()
          .markdownStatusEqualTo(3) // 正在生成状态
          .findAll();
      
      // 在代码中筛选出超时的文章
      final timeoutArticles = articles.where((article) {
        return article.markdownProcessingStartTime != null &&
               article.markdownProcessingStartTime!.isBefore(timeoutThreshold);
      }).toList();
      
      getLogger().d('🔍 检查到 ${articles.length} 篇正在生成Markdown的文章，其中 ${timeoutArticles.length} 篇超时');
      return timeoutArticles;
    } catch (e) {
      getLogger().e('❌ 获取超时处理文章失败: $e');
      return [];
    }
  }



  /// 搜索文章（模糊搜索标题和内容）
  Future<List<ArticleDb>> searchArticles(String query, {int limit = 50}) async {

    try {
      if (query.trim().isEmpty) {
        return [];
      }
      
      final cleanQuery = query.trim();
      getLogger().d('🔍 搜索文章: $cleanQuery');
      
      // 搜索标题匹配的文章
      final titleResults = await dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .titleContains(cleanQuery, caseSensitive: false)
          .sortByCreatedAtDesc()
          .findAll();
      
      // 搜索内容匹配的文章ID
      final contentResults = await dbService.articleContent
          .filter()
          .group((q) => q
              .textContentContains(cleanQuery, caseSensitive: false)
              .or()
              .markdownContains(cleanQuery, caseSensitive: false))
          .findAll();
      
      // 获取内容匹配的文章ID列表
      final contentArticleIds = contentResults
          .map((content) => content.articleId)
          .toSet()
          .toList();
      
      // 根据内容匹配的ID获取文章
      final contentArticles = <ArticleDb>[];
      for (final articleId in contentArticleIds) {
        final article = await dbService.articles.get(articleId);
        if (article != null && article.deletedAt == null) {
          contentArticles.add(article);
        }
      }
      
      // 合并结果并去重
      final allResults = <int, ArticleDb>{};
      
      // 添加标题匹配的结果
      for (final article in titleResults) {
        allResults[article.id] = article;
      }
      
      // 添加内容匹配的结果
      for (final article in contentArticles) {
        allResults[article.id] = article;
      }
      
      final results = allResults.values.toList();
      
      // 对结果进行排序优化：标题匹配的排在前面
      results.sort((a, b) {
        final aInTitle = a.title.toLowerCase().contains(cleanQuery.toLowerCase());
        final bInTitle = b.title.toLowerCase().contains(cleanQuery.toLowerCase());
        
        if (aInTitle && !bInTitle) return -1;
        if (!aInTitle && bInTitle) return 1;
        
        // 如果都在标题中或都不在标题中，按创建时间排序
        return b.createdAt.compareTo(a.createdAt);
      });
      
      // 限制结果数量
      final limitedResults = results.take(limit).toList();
      
      getLogger().d('🔍 搜索完成，找到 ${limitedResults.length} 篇文章');
      return limitedResults;
    } catch (e) {
      getLogger().e('❌ 搜索文章失败: $e');
      return [];
    }
  }

  /// 快速搜索（实时搜索使用，同样搜索标题和内容）
  Future<List<ArticleDb>> fastSearchArticles(String query, {int limit = 20}) async {

    try {
      if (query.trim().isEmpty) {
        return [];
      }
      
      final cleanQuery = query.trim();
      
      // 搜索标题匹配的文章（限制数量以保持响应速度）
      final titleResults = await dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .titleContains(cleanQuery, caseSensitive: false)
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
      
      // 搜索内容匹配的文章ID（限制数量）
      final contentResults = await dbService.articleContent
          .filter()
          .group((q) => q
              .textContentContains(cleanQuery, caseSensitive: false)
              .or()
              .markdownContains(cleanQuery, caseSensitive: false))
          .limit(limit)
          .findAll();
      
      // 获取内容匹配的文章ID列表
      final contentArticleIds = contentResults
          .map((content) => content.articleId)
          .toSet()
          .toList();
      
      // 根据内容匹配的ID获取文章（快速搜索，减少查询次数）
      final contentArticles = <ArticleDb>[];
      if (contentArticleIds.isNotEmpty) {
        final articles = await dbService.articles
            .filter()
            .deletedAtIsNull()
            .and()
            .anyOf(contentArticleIds, (q, articleId) => q.idEqualTo(articleId))
            .findAll();
        contentArticles.addAll(articles);
      }
      
      // 合并结果并去重
      final allResults = <int, ArticleDb>{};
      
      // 添加标题匹配的结果
      for (final article in titleResults) {
        allResults[article.id] = article;
      }
      
      // 添加内容匹配的结果
      for (final article in contentArticles) {
        allResults[article.id] = article;
      }
      
      final results = allResults.values.toList();
      
      // 对结果进行排序优化：标题匹配的排在前面
      results.sort((a, b) {
        final aInTitle = a.title.toLowerCase().contains(cleanQuery.toLowerCase());
        final bInTitle = b.title.toLowerCase().contains(cleanQuery.toLowerCase());
        
        if (aInTitle && !bInTitle) return -1;
        if (!aInTitle && bInTitle) return 1;
        
        // 如果都在标题中或都不在标题中，按创建时间排序
        return b.createdAt.compareTo(a.createdAt);
      });
      
      // 限制结果数量
      final limitedResults = results.take(limit).toList();
      
      return limitedResults;
    } catch (e) {
      getLogger().e('❌ 快速搜索失败: $e');
      return [];
    }
  }

  // ==================== 分页查询方法 ====================

  /// 应用排序逻辑到Isar查询
  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> _applySorting(
    QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> query,
    String? sortBy,
    bool isDescending, {
    bool isForDeleted = false,
  }) {
    switch (sortBy) {
      case 'createTime':
        return isDescending ? query.sortByCreatedAtDesc() : query.sortByCreatedAt();
      case 'modifyTime':
        return isDescending ? query.sortByUpdatedAtDesc() : query.sortByUpdatedAt();
      case 'name':
        return isDescending ? query.sortByTitleDesc() : query.sortByTitle();
      case 'deleteTime':
        if (isForDeleted) {
          return isDescending ? query.sortByDeletedAtDesc() : query.sortByDeletedAt();
        }
        // 对于非删除文章，如果错误地传入deleteTime，则回退到默认排序
        return isDescending ? query.sortByCreatedAtDesc() : query.sortByCreatedAt();
      default:
        // 为已删除文章和非已删除文章设置不同的默认排序
        if (isForDeleted) {
          return query.sortByDeletedAtDesc();
        }
        return query.sortByCreatedAtDesc();
    }
  }

  /// 从已排序的查询中获取分页数据
  Future<List<ArticleDb>> _fetchPaginatedArticles(
    QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortedQuery,
    int offset,
    int limit,
  ) async {
    return await sortedQuery.offset(offset).limit(limit).findAll();
  }

  /// 为内存中的文章列表获取比较器
  Comparator<ArticleDb> _getArticleInMemoryComparator(String? sortBy, bool isDescending) {
    switch (sortBy) {
      case 'createTime':
        return (a, b) => isDescending ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt);
      case 'modifyTime':
        return (a, b) => isDescending ? b.updatedAt.compareTo(a.updatedAt) : a.updatedAt.compareTo(b.updatedAt);
      case 'name':
        return (a, b) => isDescending ? b.title.compareTo(a.title) : a.title.compareTo(b.title);
      default:
        // 默认按创建时间降序排序
        return (a, b) => b.createdAt.compareTo(a.createdAt);
    }
  }

  /// 分页获取所有文章
  Future<List<ArticleDb>> getArticlesWithPaging({
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      final query = dbService.articles.filter().deletedAtIsNull();
      final sortedQuery = _applySorting(query, sortBy, isDescending);
      return await _fetchPaginatedArticles(sortedQuery, offset, limit);
    } catch (e) {
      getLogger().e('❌ 分页获取文章失败: $e');
      return [];
    }
  }

  /// 分页获取未读文章（稍后阅读）
  Future<List<ArticleDb>> getUnreadArticlesWithPaging({
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      final query = dbService.articles.filter().deletedAtIsNull().and().isReadEqualTo(0);
      final sortedQuery = _applySorting(query, sortBy, isDescending);
      return await _fetchPaginatedArticles(sortedQuery, offset, limit);
    } catch (e) {
      getLogger().e('❌ 分页获取未读文章失败: $e');
      return [];
    }
  }

  /// 分页获取重要文章（收藏）
  Future<List<ArticleDb>> getImportantArticlesWithPaging({
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      final query = dbService.articles.filter().deletedAtIsNull().and().isImportantEqualTo(true);
      final sortedQuery = _applySorting(query, sortBy, isDescending);
      return await _fetchPaginatedArticles(sortedQuery, offset, limit);
    } catch (e) {
      getLogger().e('❌ 分页获取重要文章失败: $e');
      return [];
    }
  }

  /// 分页获取分类文章
  Future<List<ArticleDb>> getCategoryArticlesWithPaging({
    required int categoryId,
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      // 日志和检查逻辑保持不变
      final categoryExists = await dbService.categories.filter().idEqualTo(categoryId).findFirst();
      print('🔍 [ArticleService] 分类是否存在: ${categoryExists != null ? '是' : '否'}');
      if (categoryExists != null) {
        print('🔍 [ArticleService] 分类名称: ${categoryExists.name}');
      }
      
      final totalArticlesInCategory = await dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .category((q) => q.idEqualTo(categoryId))
          .count();
      print('🔍 [ArticleService] 该分类下未删除文章总数: $totalArticlesInCategory');
      
      // 使用重构的逻辑
      final query = dbService.articles.filter().deletedAtIsNull().and().category((q) => q.idEqualTo(categoryId));
      final sortedQuery = _applySorting(query, sortBy, isDescending);
      final results = await _fetchPaginatedArticles(sortedQuery, offset, limit);
      
      print('🔍 [ArticleService] 查询结果: ${results.length} 篇未删除文章');
      if (results.isNotEmpty) {
        print('🔍 [ArticleService] 第一篇文章: ${results.first.title}');
        await results.first.category.load();
        print('🔍 [ArticleService] 第一篇文章的分类: ${results.first.category.value?.name ?? '未设置'}');
      }
      
      return results;
    } catch (e) {
      getLogger().e('❌ 分页获取分类文章失败: $e');
      print('❌ [ArticleService] 分页获取分类文章失败: $e');
      return [];
    }
  }

  /// 分页获取归档文章
  Future<List<ArticleDb>> getArchivedArticlesWithPaging({
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      final query = dbService.articles.filter().deletedAtIsNull().and().isArchivedEqualTo(true);
      final sortedQuery = _applySorting(query, sortBy, isDescending);
      return await _fetchPaginatedArticles(sortedQuery, offset, limit);
    } catch (e) {
      getLogger().e('❌ 分页获取归档文章失败: $e');
      return [];
    }
  }

  /// 分页搜索文章
  Future<List<ArticleDb>> searchArticlesWithPaging({
    required String query,
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      if (query.trim().isEmpty) {
        return [];
      }
      
      final cleanQuery = query.trim();
      
      // 先搜索所有匹配的文章，然后在内存中排序和分页
      // 这是因为跨表搜索难以在数据库层面直接排序
      
      // 搜索标题匹配的文章
      final titleResults = await dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .titleContains(cleanQuery, caseSensitive: false)
          .findAll();
      
      // 搜索内容匹配的文章ID
      final contentResults = await dbService.articleContent
          .filter()
          .group((q) => q
              .textContentContains(cleanQuery, caseSensitive: false)
              .or()
              .markdownContains(cleanQuery, caseSensitive: false))
          .findAll();
      
      // 获取内容匹配的文章ID列表
      final contentArticleIds = contentResults
          .map((content) => content.articleId)
          .toSet()
          .toList();
      
      // 根据内容匹配的ID获取文章
      final contentArticles = <ArticleDb>[];
      if (contentArticleIds.isNotEmpty) {
        final articles = await dbService.articles
            .filter()
            .deletedAtIsNull()
            .and()
            .anyOf(contentArticleIds, (q, articleId) => q.idEqualTo(articleId))
            .findAll();
        contentArticles.addAll(articles);
      }
      
      // 合并结果并去重
      final allResults = <int, ArticleDb>{};
      
      // 添加标题匹配的结果
      for (final article in titleResults) {
        allResults[article.id] = article;
      }
      
      // 添加内容匹配的结果
      for (final article in contentArticles) {
        allResults[article.id] = article;
      }
      
      final List<ArticleDb> allArticles = allResults.values.toList();
      
      // 根据排序类型排序
      if (sortBy == 'createTime' || sortBy == 'modifyTime' || sortBy == 'name') {
        allArticles.sort(_getArticleInMemoryComparator(sortBy, isDescending));
      } else {
        // 默认排序优化：标题匹配的排在前面
        allArticles.sort((a, b) {
          final aInTitle = a.title.toLowerCase().contains(cleanQuery.toLowerCase());
          final bInTitle = b.title.toLowerCase().contains(cleanQuery.toLowerCase());
          
          if (aInTitle && !bInTitle) return -1;
          if (!aInTitle && bInTitle) return 1;
          
          // 如果都在标题中或都不在标题中，按创建时间排序
          return isDescending 
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt);
        });
      }
      
      // 应用分页
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, allArticles.length);
      
      if (startIndex >= allArticles.length) {
        return [];
      }
      
      final results = allArticles.sublist(startIndex, endIndex);
      
      return results;
    } catch (e) {
      getLogger().e('❌ 分页搜索文章失败: $e');
      return [];
    }
  }

  /// 分页获取标签文章
  Future<List<ArticleDb>> getTagArticlesWithPaging({
    required int tagId,
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      // 首先获取标签
      final tag = await dbService.tags.get(tagId);
      if (tag == null) {
        print('❌ [ArticleService] 标签不存在: $tagId');
        return [];
      }
      
      // 加载标签关联的所有文章
      await tag.articles.load();
      final allTagArticles = tag.articles.toList();
      
      // 过滤未删除的文章
      final undeleted = allTagArticles.where((article) => article.deletedAt == null).toList();
      
      print('🔍 [ArticleService] 标签 "${tag.name}" 下共有 ${allTagArticles.length} 篇文章，其中 ${undeleted.length} 篇未删除');
      
      // 根据排序类型排序
      final List<ArticleDb> sortedArticles = List.from(undeleted);
      sortedArticles.sort(_getArticleInMemoryComparator(sortBy, isDescending));
      
      // 应用分页
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, sortedArticles.length);
      
      if (startIndex >= sortedArticles.length) {
        return [];
      }
      
      final results = sortedArticles.sublist(startIndex, endIndex);
      
      print('🔍 [ArticleService] 分页后返回 ${results.length} 篇未删除文章 (offset: $offset, limit: $limit)');
      if (results.isNotEmpty) {
        print('🔍 [ArticleService] 第一篇文章: ${results.first.title}');
      }
      
      return results;
    } catch (e) {
      getLogger().e('❌ 分页获取标签文章失败: $e');
      print('❌ [ArticleService] 分页获取标签文章失败: $e');
      return [];
    }
  }

  /// 分页获取已删除文章（回收站）
  Future<List<ArticleDb>> getDeletedArticlesWithPaging({
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      final query = dbService.articles.filter().deletedAtIsNotNull();
      final sortedQuery = _applySorting(query, sortBy, isDescending, isForDeleted: true);
      return await _fetchPaginatedArticles(sortedQuery, offset, limit);
    } catch (e) {
      getLogger().e('❌ 分页获取已删除文章失败: $e');
      return [];
    }
  }

  /// 恢复已删除的文章
  Future<bool> restoreDeletedArticle(int articleId) async {

    try {
      await dbService.isar.writeTxn(() async {
        final article = await dbService.articles.get(articleId);
        if (article != null) {
          // 清除删除时间，恢复文章
          article.deletedAt = null;
          article.updatedAt = DateTime.now();
          
          await dbService.articles.put(article);
          await logSyncOperation(SyncOp.update, article);
          
          getLogger().i('♻️ 恢复已删除文章: ${article.title}');
        } else {
          throw Exception('未找到文章');
        }
      });
      
      return true;
    } catch (e) {
      getLogger().e('❌ 恢复文章失败: $e');
      rethrow;
    }
  }



  /// 保存或更新文章内容到 ArticleContentDb
  Future<ArticleContentDb> saveOrUpdateArticleContent({
    required int articleId,
    required String markdown,
    String textContent = '',
    String languageCode = "",
    bool isOriginal = true,
    String serviceId = '',
  }) async {
    try {
      getLogger().i('📝 保存文章内容到 ArticleContentDb，文章ID: $articleId，语言: ${languageCode}');
      
      final now = DateTime.now();
      
      // 首先查询是否已存在该文章的内容（根据 articleId 和 languageCode）
      final existingContent = await dbService.isar.writeTxn(() async {
        final existing = await dbService.articleContent
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
          await dbService.articleContent.put(existing);
          getLogger().i('✅ 更新现有文章内容成功，ArticleContentDb ID: ${existing.id}');
          return existing;
        } else {
          // 创建新内容
          final newContent = ArticleContentDb()
            ..articleId = articleId
            ..markdown = markdown
            ..textContent = textContent
            ..languageCode = languageCode
            ..isOriginal = isOriginal
            ..serviceId = serviceId
            ..createdAt = now
            ..updatedAt = now;
          
          await dbService.articleContent.put(newContent);
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

  /// 获取文章的原文内容
  Future<ArticleContentDb?> getOriginalArticleContent(int articleId) async {
    try {
      return await dbService.articleContent
          .filter()
          .articleIdEqualTo(articleId)
          .and()
          .languageCodeEqualTo("original")
          .findFirst();
    } catch (e) {
      getLogger().e('❌ 获取文章原文内容失败: $e');
      return null;
    }
  }

  /// 获取文章的所有内容（所有语言版本）
  Future<List<ArticleContentDb>> getAllArticleContents(int articleId) async {
    try {
      return await dbService.articleContent
          .filter()
          .articleIdEqualTo(articleId)
          .sortByLanguageCode()
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取文章所有内容失败: $e');
      return [];
    }
  }

  /// 获取文章指定语言的内容
  Future<ArticleContentDb?> getArticleContentByLanguage(int articleId, String language) async {
    try {
      return await dbService.articleContent
          .filter()
          .articleIdEqualTo(articleId)
          .and()
          .languageCodeEqualTo(language)
          .findFirst();
    } catch (e) {
      getLogger().e('❌ 获取文章指定语言内容失败: $e');
      return null;
    }
  }



}

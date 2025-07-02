import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:get/get.dart';

import '../../api/user_api.dart';
import 'article_db.dart';
import '../database_service.dart';
import '../category/category_db.dart';
import '../../basics/logger.dart';
import '../sync_operation.dart';
import '../article_content/article_content_db.dart';

/// 文章服务类
class ArticleService extends GetxService {
  static ArticleService get instance => Get.find<ArticleService>();

  /// 获取数据库实例
  DatabaseService get _dbService => DatabaseService.instance;


  /// 保存文章
  Future<ArticleDb> saveArticle(ArticleDb article) async {
    try {

      final now = DateTime.now();
      article.updatedAt = now;
      
      final isCreating = article.id == Isar.autoIncrement;
      
      // 如果是新文章，设置创建时间并生成唯一ID
      if (isCreating) {
        article.createdAt = now;
        // 如果没有服务端ID (代表是本地新建的), 则生成一个客户端唯一ID
        if (article.serviceId.isEmpty) {
          article.serviceId = "";
        }
      }

      await _dbService.isar.writeTxn(() async {
        await _dbService.articles.put(article);
        await _logSyncOperation(
          isCreating ? SyncOp.create : SyncOp.update,
          article,
        );
      });

      getLogger().i('✅ 文章保存成功，ID: ${article.id}');
      return article;
    } catch (e) {
      getLogger().e('❌ 保存文章失败: $e');
      rethrow;
    }
  }

  /// 从分享内容创建文章
  Future<ArticleDb> createArticleFromShare({
    required String title,
    required String url,
    required String originalContent,
    String? excerpt,
    List<String>? tags,
  }) async {

    try {
      getLogger().i('📝 从分享内容创建文章: $title');

      final article = ArticleDb()
        ..title = title
        ..url = url
        ..shareOriginalContent = originalContent
        ..excerpt = excerpt
        ..isRead = 0
        ..readCount = 0
        ..readDuration = 0
        ..readProgress = 0.0;

      final savedArticle = await saveArticle(article);

      /// 将数据保存到服务端
      final param = {
        'client_article_id': savedArticle.id,
        'title': savedArticle.title,
        'url': savedArticle.url,
        'share_original_content': savedArticle.shareOriginalContent,
      };
      final response = await UserApi.createArticleApi(param);
      if (response['code'] == 0) {
        final serviceIdData = response['data'];
        String serviceId = '';

        if (serviceIdData != null) {
          serviceId = serviceIdData.toString();
        }

        if (serviceId.isNotEmpty) {
          // 假设 article_service 中有 markArticleAsSynced 方法
          await ArticleService.instance.markArticleAsSynced(article.id, serviceId);
          getLogger().i('✅ 文章同步成功。 服务端ID: $serviceId');
          // 触发Markdown生成
          // MarkdownService.instance.triggerMarkdownProcessing();
        } else {
          getLogger().e('❌ 后端返回了无效的服务端ID: "$serviceId" (本地ID: ${article.id})');
        }
      }

      getLogger().i('📝 文章已创建，serviceId将在后端同步完成后设置');
      return savedArticle;
    } catch (e) {
      getLogger().e('❌ 从分享内容创建文章失败: $e');
      rethrow;
    }
  }

  /// 根据URL查找文章
  Future<ArticleDb?> findArticleByUrl(String url) async {

    try {
      final article = await _dbService.articles
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
      return await _dbService.articles
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
      return await _dbService.articles
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
      return await _dbService.articles
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
      return await _dbService.articles
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
      return await _dbService.articles.get(articleId);
    } catch (e) {
      getLogger().e('❌ 获取文章失败，ID: $articleId, error: $e');
      return null;
    }
  }

  /// 删除文章
  Future<bool> deleteArticle(int articleId) async {

    try {
      getLogger().i('🗑️ 删除文章，ID: $articleId');
      
      final success = await _dbService.isar.writeTxn(() async {
        // 在删除前先记录操作
        final articleToDelete = await _dbService.articles.get(articleId);
        if (articleToDelete != null) {
          await _logSyncOperation(SyncOp.delete, articleToDelete);
          return await _dbService.articles.delete(articleId);
        }
        return false;
      });

      if (success) {
        getLogger().i('✅ 文章删除成功');
      } else {
        getLogger().w('⚠️ 文章不存在或删除失败');
      }
      
      return success;
    } catch (e) {
      getLogger().e('❌ 删除文章失败: $e');
      return false;
    }
  }

  /// 记录同步操作
  Future<void> _logSyncOperation(SyncOp op, ArticleDb article) async {
    final syncOp = SyncOperation()
      ..operation = op
      ..collectionName = 'ArticleDb' 
      ..entityId = article.serviceId
      ..timestamp = DateTime.now()
      ..status = SyncStatus.pending;

    // 对于非删除操作，我们存储文章的完整数据
    if (op != SyncOp.delete) {
      // 注意：这里需要一个方法将 ArticleDb 转换为 Map<String, dynamic>
      // 暂时我们先假设有一个 toJson 方法，后续需要实现它
      syncOp.data = jsonEncode(article.toJson());
    }
    
    await _dbService.syncOperations.put(syncOp);
    getLogger().i('📝 记录同步操作: ${op.name} for Article ${article.serviceId}');
  }

  /// 更新文章分类
  Future<void> updateArticleCategory(int articleId, CategoryDb? category) async {

    try {
      getLogger().i('📝 更新文章分类，文章ID: $articleId, 分类: ${category?.name ?? "未分类"}');
      
      await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          // 设置新的分类关系
          article.category.value = category;
          article.updatedAt = DateTime.now();
          
          // 保存文章和关系
          await _dbService.articles.put(article);
          await article.category.save();
          
          await _logSyncOperation(SyncOp.update, article);
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
      await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          article.isRead = isRead ? 1 : 0;
          article.readCount += 1;
          article.updatedAt = DateTime.now();
          
          if (readDuration != null) {
            article.readDuration += readDuration;
          }
          
          if (readProgress != null) {
            article.readProgress = readProgress;
          }
          
          await _dbService.articles.put(article);
          await _logSyncOperation(SyncOp.update, article);
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
      
      await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          // 切换重要状态
          article.isImportant = !article.isImportant;
          newImportantStatus = article.isImportant;
          article.updatedAt = DateTime.now();
          
          await _dbService.articles.put(article);
          await _logSyncOperation(SyncOp.update, article);
          
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
      
      await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          // 切换归档状态
          article.isArchived = !article.isArchived;
          newArchiveStatus = article.isArchived;
          article.updatedAt = DateTime.now();
          
          await _dbService.articles.put(article);
          await _logSyncOperation(SyncOp.update, article);
          
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

  /// 软删除文章（设置deletedAt字段）
  Future<bool> softDeleteArticle(int articleId) async {

    try {
      await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          // 设置删除时间
          article.deletedAt = DateTime.now();
          article.updatedAt = DateTime.now();
          
          await _dbService.articles.put(article);
          await _logSyncOperation(SyncOp.update, article);
          
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

  /// 根据服务端ID查找文章
  Future<ArticleDb?> findArticleByServiceId(String serviceId) async {

    try {
      // serviceId 字段需要有 @Index() 才能有效查询
      return await _dbService.articles
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
      final testArticle = await _dbService.articles.get(articleId);
      if (testArticle == null) {
        getLogger().e('❌ [调试] 在事务外查询：文章不存在，ID: $articleId');
        // 尝试查询所有文章，看看数据库中有什么
        final allArticles = await _dbService.articles.where().findAll();
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
      if (_dbService.isar == null) {
        getLogger().e('❌ [调试] 数据库实例为null');
        return false;
      }
      getLogger().i('✅ [调试] 数据库实例正常');
      
      bool success = false;
      
      getLogger().i('🔄 [调试] 准备进入数据库事务...');
      await _dbService.isar.writeTxn(() async {
        getLogger().i('🔄 [调试] 已进入数据库事务内部');
        
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          getLogger().i('📝 更新前的serviceId: "${article.serviceId}"');
          article.serviceId = serviceId;
          article.updatedAt = DateTime.now();
          await _dbService.articles.put(article);
          
          // 验证更新是否成功
          final updatedArticle = await _dbService.articles.get(articleId);
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
      return await _dbService.articles
          .filter()
          .isCreateServiceEqualTo(false)
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取未同步文章列表失败: $e');
      return [];
    }
  }

  /// 标记文章已同步到服务端
  Future<bool> markArticleAsSynced(int articleId, String serviceId) async {
    try {
      return await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          article.serviceId = serviceId;
          article.isCreateService = true;
          article.updatedAt = DateTime.now();
          await _dbService.articles.put(article);
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

  /// 获取所有需要生成快照的文章
  Future<List<ArticleDb>> getUnsnapshottedArticles() async {
    try {
      return await _dbService.articles
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

  /// 更新文章的快照信息
  Future<bool> updateArticleSnapshotInfo(int articleId, String mhtmlPath) async {
    try {
      return await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          article.mhtmlPath = mhtmlPath;
          article.isGenerateMhtml = true;
          article.updatedAt = DateTime.now();
          await _dbService.articles.put(article);
          getLogger().i('✅ 成功更新文章快照信息: ID $articleId');
          return true;
        }
        getLogger().w('⚠️ 更新快照信息失败：未找到文章 ID $articleId');
        return false;
      });
    } catch (e) {
      getLogger().e('❌ 更新文章快照信息时出错: $e');
      return false;
    }
  }

  /// 获取所有需要生成Markdown的文章
  Future<List<ArticleDb>> getArticlesToGenerateMarkdown() async {
    try {
      // 查询 isGenerateMhtml == true 且 isGenerateMarkdown == false 且 serviceId 不为空的数据
      return await _dbService.articles
          .filter()
          .isGenerateMhtmlEqualTo(true)
          .and()
          .isGenerateMarkdownEqualTo(false)
          .and()
          .serviceIdIsNotEmpty()
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取待生成Markdown文章列表失败: $e');
      return [];
    }
  }

  /// 更新文章的Markdown内容和状态
  // Future<bool> updateArticleMarkdown(int articleId, String markdown, String title) async {
  //   try {
  //     return await _dbService.isar.writeTxn(() async {
  //       final article = await _dbService.articles.get(articleId);
  //       if (article != null) {
  //         article.markdown = markdown;
  //         article.isGenerateMarkdown = true;
  //         article.markdownStatus = 1;
  //         article.updatedAt = DateTime.now();
  //         article.title = title;
  //         await _dbService.articles.put(article);
  //         getLogger().i('✅ 成功更新文章Markdown内容: ID $articleId');
  //         return true;
  //       }
  //       getLogger().w('⚠️ 更新Markdown内容失败：未找到文章 ID $articleId');
  //       return false;
  //     });
  //   } catch (e) {
  //     getLogger().e('❌ 更新文章Markdown内容时出错: $e');
  //     return false;
  //   }
  // }

  /// 获取处理超时的文章（状态为3且超过指定时间）
  Future<List<ArticleDb>> getTimeoutProcessingArticles({int timeoutSeconds = 50}) async {
    try {
      final now = DateTime.now();
      final timeoutThreshold = now.subtract(Duration(seconds: timeoutSeconds));
      
      // 先获取所有状态为3的文章
      final articles = await _dbService.articles
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

  /// 更新文章的Markdown状态
  /// markdownStatus: 0=待生成  1=已生成   2=生成失败     3=正在生成
  Future<bool> updateArticleMarkdownStatus(int articleId, int markdownStatus) async {
    try {
      return await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
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
          
          await _dbService.articles.put(article);
          
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

  /// 搜索文章（模糊搜索标题和内容）
  Future<List<ArticleDb>> searchArticles(String query, {int limit = 50}) async {

    try {
      if (query.trim().isEmpty) {
        return [];
      }
      
      final cleanQuery = query.trim();
      getLogger().d('🔍 搜索文章: $cleanQuery');
      
      // 搜索标题匹配的文章
      final titleResults = await _dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .titleContains(cleanQuery, caseSensitive: false)
          .sortByCreatedAtDesc()
          .findAll();
      
      // 搜索内容匹配的文章ID
      final contentResults = await _dbService.articleContent
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
        final article = await _dbService.articles.get(articleId);
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
      final titleResults = await _dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .titleContains(cleanQuery, caseSensitive: false)
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
      
      // 搜索内容匹配的文章ID（限制数量）
      final contentResults = await _dbService.articleContent
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
        final articles = await _dbService.articles
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

  /// 分页获取所有文章
  Future<List<ArticleDb>> getArticlesWithPaging({
    required int offset,
    required int limit,
    String? sortBy,
    bool isDescending = true,
  }) async {

    try {
      // 根据排序类型排序，过滤未删除的文章
      switch (sortBy) {
        case 'createTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .sortByCreatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'modifyTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .sortByUpdatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'name':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .sortByTitle()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        default:
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .sortByCreatedAtDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
      }
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
      // 根据排序类型排序，过滤未删除和未读的文章
      switch (sortBy) {
        case 'createTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isReadEqualTo(0)
              .sortByCreatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'modifyTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isReadEqualTo(0)
              .sortByUpdatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'name':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isReadEqualTo(0)
              .sortByTitle()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        default:
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isReadEqualTo(0)
              .sortByCreatedAtDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
      }
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
      // 根据排序类型排序，过滤未删除和重要的文章
      switch (sortBy) {
        case 'createTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isImportantEqualTo(true)
              .sortByCreatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'modifyTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isImportantEqualTo(true)
              .sortByUpdatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'name':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isImportantEqualTo(true)
              .sortByTitle()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        default:
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isImportantEqualTo(true)
              .sortByCreatedAtDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
      }
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
      // 先检查该分类是否存在
      final categoryExists = await _dbService.categories.filter().idEqualTo(categoryId).findFirst();
      print('🔍 [ArticleService] 分类是否存在: ${categoryExists != null ? '是' : '否'}');
      if (categoryExists != null) {
        print('🔍 [ArticleService] 分类名称: ${categoryExists.name}');
      }
      
      // 检查有多少文章关联了这个分类且未删除
      final totalArticlesInCategory = await _dbService.articles
          .filter()
          .deletedAtIsNull() // 过滤未删除的文章
          .and()
          .category((q) => q.idEqualTo(categoryId))
          .count();
      print('🔍 [ArticleService] 该分类下未删除文章总数: $totalArticlesInCategory');
      
      // 根据排序类型排序，过滤未删除和分类的文章
      List<ArticleDb> results;
      switch (sortBy) {
        case 'createTime':
          results = await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .category((q) => q.idEqualTo(categoryId))
              .sortByCreatedAt()
              .offset(offset)
              .limit(limit)
              .findAll();
          if (isDescending) results = results.reversed.toList();
          break;
        case 'modifyTime':
          results = await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .category((q) => q.idEqualTo(categoryId))
              .sortByUpdatedAt()
              .offset(offset)
              .limit(limit)
              .findAll();
          if (isDescending) results = results.reversed.toList();
          break;
        case 'name':
          results = await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .category((q) => q.idEqualTo(categoryId))
              .sortByTitle()
              .offset(offset)
              .limit(limit)
              .findAll();
          if (isDescending) results = results.reversed.toList();
          break;
        default:
          results = await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .category((q) => q.idEqualTo(categoryId))
              .sortByCreatedAtDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
      }
      
      print('🔍 [ArticleService] 查询结果: ${results.length} 篇未删除文章');
      if (results.isNotEmpty) {
        print('🔍 [ArticleService] 第一篇文章: ${results.first.title}');
        // 检查第一篇文章的分类信息
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
      // 根据排序类型排序，过滤未删除且归档的文章
      switch (sortBy) {
        case 'createTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isArchivedEqualTo(true)
              .sortByCreatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'modifyTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isArchivedEqualTo(true)
              .sortByUpdatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'name':
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isArchivedEqualTo(true)
              .sortByTitle()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        default:
          return await _dbService.articles
              .filter()
              .deletedAtIsNull() // 过滤未删除的文章
              .and()
              .isArchivedEqualTo(true)
              .sortByCreatedAtDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
      }
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
      final titleResults = await _dbService.articles
          .filter()
          .deletedAtIsNull()
          .and()
          .titleContains(cleanQuery, caseSensitive: false)
          .findAll();
      
      // 搜索内容匹配的文章ID
      final contentResults = await _dbService.articleContent
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
        final articles = await _dbService.articles
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
      
      final allArticles = allResults.values.toList();
      
      // 根据排序类型排序
      switch (sortBy) {
        case 'createTime':
          allArticles.sort((a, b) => isDescending 
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt));
          break;
        case 'modifyTime':
          allArticles.sort((a, b) => isDescending 
              ? b.updatedAt.compareTo(a.updatedAt)
              : a.updatedAt.compareTo(b.updatedAt));
          break;
        case 'name':
          allArticles.sort((a, b) => isDescending 
              ? b.title.compareTo(a.title)
              : a.title.compareTo(b.title));
          break;
        default:
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
      final tag = await _dbService.tags.get(tagId);
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
      List<ArticleDb> sortedArticles = List.from(undeleted);
      switch (sortBy) {
        case 'createTime':
          sortedArticles.sort((a, b) => isDescending 
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt));
          break;
        case 'modifyTime':
          sortedArticles.sort((a, b) => isDescending 
              ? b.updatedAt.compareTo(a.updatedAt)
              : a.updatedAt.compareTo(b.updatedAt));
          break;
        case 'name':
          sortedArticles.sort((a, b) => isDescending 
              ? b.title.compareTo(a.title)
              : a.title.compareTo(b.title));
          break;
        default:
          sortedArticles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
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
      // 根据排序类型排序，只查询已删除的文章
      switch (sortBy) {
        case 'createTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNotNull() // 只查询已删除的文章
              .sortByCreatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'modifyTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNotNull() // 只查询已删除的文章
              .sortByUpdatedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'deleteTime':
          return await _dbService.articles
              .filter()
              .deletedAtIsNotNull() // 只查询已删除的文章
              .sortByDeletedAt()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        case 'name':
          return await _dbService.articles
              .filter()
              .deletedAtIsNotNull() // 只查询已删除的文章
              .sortByTitle()
              .offset(offset)
              .limit(limit)
              .findAll()
              .then((list) => isDescending ? list.reversed.toList() : list);
        default:
          // 默认按删除时间排序
          return await _dbService.articles
              .filter()
              .deletedAtIsNotNull() // 只查询已删除的文章
              .sortByDeletedAtDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
      }
    } catch (e) {
      getLogger().e('❌ 分页获取已删除文章失败: $e');
      return [];
    }
  }

  /// 恢复已删除的文章
  Future<bool> restoreDeletedArticle(int articleId) async {

    try {
      await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          // 清除删除时间，恢复文章
          article.deletedAt = null;
          article.updatedAt = DateTime.now();
          
          await _dbService.articles.put(article);
          await _logSyncOperation(SyncOp.update, article);
          
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

  /// 清空回收站（永久删除所有已删除的文章）
  Future<int> clearRecycleBin() async {

    try {
      int deletedCount = 0;
      
      await _dbService.isar.writeTxn(() async {
        // 获取所有已删除的文章
        final deletedArticles = await _dbService.articles
            .filter()
            .deletedAtIsNotNull()
            .findAll();
        
        // 记录删除操作
        for (final article in deletedArticles) {
          await _logSyncOperation(SyncOp.delete, article);
        }
        
        // 批量删除
        final articleIds = deletedArticles.map((article) => article.id).toList();
        deletedCount = await _dbService.articles.deleteAll(articleIds);
        
        getLogger().i('🗑️ 清空回收站，永久删除 $deletedCount 篇文章');
      });
      
      return deletedCount;
    } catch (e) {
      getLogger().e('❌ 清空回收站失败: $e');
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
      final existingContent = await _dbService.isar.writeTxn(() async {
        final existing = await _dbService.articleContent
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
            ..articleId = articleId
            ..markdown = markdown
            ..textContent = textContent
            ..languageCode = languageCode
            ..isOriginal = isOriginal
            ..serviceId = serviceId
            ..createdAt = now
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

  /// 获取文章的原文内容
  Future<ArticleContentDb?> getOriginalArticleContent(int articleId) async {
    try {
      return await _dbService.articleContent
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
      return await _dbService.articleContent
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
      return await _dbService.articleContent
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

  /// 删除文章的所有内容
  Future<int> deleteAllArticleContents(int articleId) async {
    try {
      final deletedCount = await _dbService.isar.writeTxn(() async {
        return await _dbService.articleContent
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

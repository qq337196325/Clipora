import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'article_db.dart';
import '../database_service.dart';
import '../../basics/logger.dart';
import '../sync_operation.dart';

/// 文章服务类
class ArticleService extends GetxService {
  static ArticleService get instance => Get.find<ArticleService>();

  /// 获取数据库实例
  DatabaseService get _dbService => DatabaseService.instance;

  /// 确保数据库已初始化
  Future<void> _ensureDatabaseInitialized() async {
    if (!_dbService.isInitialized) {
      getLogger().i('⏳ 等待数据库初始化...');
      // await _dbService.onInit();
    }
  }

  /// 保存文章
  Future<ArticleDb> saveArticle(ArticleDb article) async {
    await _ensureDatabaseInitialized();
    
    try {
      getLogger().i('💾 保存文章: ${article.title}');
      
      final now = DateTime.now();
      article.updatedAt = now;
      
      final isCreating = article.id == Isar.autoIncrement;
      
      // 如果是新文章，设置创建时间并生成唯一ID
      if (isCreating) {
        article.createdAt = now;
        // 如果没有服务端ID (代表是本地新建的), 则生成一个客户端唯一ID
        if (article.serviceId.isEmpty) {
          article.serviceId = const Uuid().v4();
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
    await _ensureDatabaseInitialized();
    
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
      getLogger().i('📝 文章已创建，serviceId将在后端同步完成后设置');
      return savedArticle;
    } catch (e) {
      getLogger().e('❌ 从分享内容创建文章失败: $e');
      rethrow;
    }
  }

  /// 根据URL查找文章
  Future<ArticleDb?> findArticleByUrl(String url) async {
    await _ensureDatabaseInitialized();
    
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
    await _ensureDatabaseInitialized();
    
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
    await _ensureDatabaseInitialized();
    
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

  /// 获取最近阅读的文章
  Future<List<ArticleDb>> getRecentlyReadArticles({int limit = 5}) async {
    await _ensureDatabaseInitialized();
    
    try {
      return await _dbService.articles
          .where()
          .filter()
          .isReadEqualTo(1)
          .sortByLastReadTimeDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      getLogger().e('❌ 获取最近阅读文章列表失败: $e');
      return [];
    }
  }

  /// 删除文章
  Future<bool> deleteArticle(int articleId) async {
    await _ensureDatabaseInitialized();
    
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

  /// 更新文章阅读状态
  Future<void> updateReadStatus(int articleId, {
    bool isRead = true,
    int? readDuration,
    double? readProgress,
  }) async {
    await _ensureDatabaseInitialized();
    
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

  /// 根据ID获取单个文章
  Future<ArticleDb?> getArticleById(int articleId) async {
    await _ensureDatabaseInitialized();
    
    try {
      getLogger().i('🔍 查询文章，ID: $articleId');
      
      final article = await _dbService.articles.get(articleId);
      
      if (article != null) {
        final serviceIdInfo = article.serviceId.isEmpty ? '(未同步)' : article.serviceId;
        getLogger().i('✅ 找到文章: ${article.title}, 服务端ID: $serviceIdInfo');
      } else {
        getLogger().w('⚠️ 未找到ID为 $articleId 的文章');
      }
      
      return article;
    } catch (e) {
      getLogger().e('❌ 根据ID获取文章失败: $e');
      return null;
    }
  }

  /// 根据服务端ID查找文章
  Future<ArticleDb?> findArticleByServiceId(String serviceId) async {
    await _ensureDatabaseInitialized();
    
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
    await _ensureDatabaseInitialized();
    
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

  /// 调试方法：检查文章的serviceId字段
  Future<void> debugCheckServiceId(int articleId) async {
    await _ensureDatabaseInitialized();
    
    try {
      getLogger().i('🔍 [调试] 检查文章serviceId，ID: $articleId');
      
      final article = await _dbService.articles.get(articleId);
      if (article != null) {
        getLogger().i('🔍 [调试] 文章信息:');
        getLogger().i('  - 标题: ${article.title}');
        getLogger().i('  - serviceId: "${article.serviceId}"');
        getLogger().i('  - serviceId.length: ${article.serviceId.length}');
        getLogger().i('  - serviceId.isEmpty: ${article.serviceId.isEmpty}');
        getLogger().i('  - 更新时间: ${article.updatedAt}');
        
        // 直接从数据库查询所有字段
        final rawQuery = await _dbService.articles
            .filter()
            .idEqualTo(articleId)
            .findAll();
        
        if (rawQuery.isNotEmpty) {
          final rawArticle = rawQuery.first;
          getLogger().i('🔍 [调试] 原始查询结果: serviceId="${rawArticle.serviceId}"');
        }
      } else {
        getLogger().w('⚠️ [调试] 未找到ID为 $articleId 的文章');
      }
    } catch (e) {
      getLogger().e('❌ [调试] 检查serviceId失败: $e');
    }
  }

  /// 数据库迁移：修复serviceId字段
  Future<void> migrateServiceIdField() async {
    await _ensureDatabaseInitialized();
    
    try {
      getLogger().i('🔄 开始数据库迁移：修复serviceId字段');
      
      // 查找所有文章
      final allArticles = await _dbService.articles.where().findAll();
      getLogger().i('📊 共找到 ${allArticles.length} 篇文章需要检查');
      
      int migratedCount = 0;
      
      await _dbService.isar.writeTxn(() async {
        for (final article in allArticles) {
          // 检查serviceId是否为null或需要初始化
          // 注意：在Dart中，如果字段后加入且有默认值，旧记录可能仍然有问题
          bool needsMigration = false;
          
          try {
            // 尝试访问serviceId，如果有问题会抛出异常
            final currentServiceId = article.serviceId;
            if (currentServiceId == null) {
              needsMigration = true;
            }
          } catch (e) {
            // 如果访问serviceId出错，说明字段确实有问题
            needsMigration = true;
            getLogger().w('⚠️ 文章 ${article.id} 的serviceId字段有问题: $e');
          }
          
          if (needsMigration) {
            article.serviceId = ""; // 设置为空字符串默认值
            article.updatedAt = DateTime.now();
            await _dbService.articles.put(article);
            migratedCount++;
            getLogger().i('✅ 已修复文章 ${article.id}: ${article.title}');
          }
        }
      });
      
      getLogger().i('✅ 数据库迁移完成，共修复 $migratedCount 篇文章');
      
      if (migratedCount > 0) {
        // 验证迁移结果
        getLogger().i('🔍 验证迁移结果...');
        final verifyArticles = await _dbService.articles.where().findAll();
        int validCount = 0;
        
        for (final article in verifyArticles) {
          try {
            final serviceId = article.serviceId;
            if (serviceId != null) {
              validCount++;
            }
          } catch (e) {
            getLogger().e('❌ 验证失败，文章 ${article.id} 仍有问题: $e');
          }
        }
        
        getLogger().i('📊 验证结果: ${validCount}/${verifyArticles.length} 篇文章serviceId字段正常');
      }
      
    } catch (e) {
      getLogger().e('❌ 数据库迁移失败: $e');
    }
  }

  /// 获取所有未同步到服务端的文章
  Future<List<ArticleDb>> getUnsyncedArticles() async {
    await _ensureDatabaseInitialized();
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
    await _ensureDatabaseInitialized();
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
    await _ensureDatabaseInitialized();
    try {
      // 查询 isGenerateMhtml == false 且 url 不为空的数据
      return await _dbService.articles
          .filter()
          .isGenerateMhtmlEqualTo(false)
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
    await _ensureDatabaseInitialized();
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
    await _ensureDatabaseInitialized();
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
  Future<bool> updateArticleMarkdown(int articleId, String markdown) async {
    await _ensureDatabaseInitialized();
    try {
      return await _dbService.isar.writeTxn(() async {
        final article = await _dbService.articles.get(articleId);
        if (article != null) {
          article.markdown = markdown;
          article.isGenerateMarkdown = true;
          article.updatedAt = DateTime.now();
          await _dbService.articles.put(article);
          getLogger().i('✅ 成功更新文章Markdown内容: ID $articleId');
          return true;
        }
        getLogger().w('⚠️ 更新Markdown内容失败：未找到文章 ID $articleId');
        return false;
      });
    } catch (e) {
      getLogger().e('❌ 更新文章Markdown内容时出错: $e');
      return false;
    }
  }

  /// 清空所有文章数据（慎用！）
  Future<void> clearAllArticles() async {
    await _ensureDatabaseInitialized();
    
    try {
      getLogger().w('⚠️ 开始清空所有文章数据...');
      
      await _dbService.isar.writeTxn(() async {
        await _dbService.articles.clear();
      });
      
      getLogger().i('✅ 所有文章数据已清空');
    } catch (e) {
      getLogger().e('❌ 清空文章数据失败: $e');
    }
  }
}

import 'package:isar/isar.dart';
import 'package:get/get.dart';

import 'article_db.dart';
import '../database_service.dart';
import '../../basics/logger.dart';

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
      
      // 如果是新文章，设置创建时间
      if (article.id == Isar.autoIncrement) {
        article.createdAt = now;
      }

      await _dbService.isar.writeTxn(() async {
        await _dbService.articles.put(article);
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
        ..tags = tags ?? []
        ..isRead = 0
        ..readCount = 0
        ..readDuration = 0
        ..readProgress = 0.0;

      return await saveArticle(article);
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

  /// 删除文章
  Future<bool> deleteArticle(int articleId) async {
    await _ensureDatabaseInitialized();
    
    try {
      getLogger().i('🗑️ 删除文章，ID: $articleId');
      
      final success = await _dbService.isar.writeTxn(() async {
        return await _dbService.articles.delete(articleId);
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
          getLogger().i('📖 更新文章阅读状态: ${article.title}');
        }
      });
    } catch (e) {
      getLogger().e('❌ 更新阅读状态失败: $e');
    }
  }
}

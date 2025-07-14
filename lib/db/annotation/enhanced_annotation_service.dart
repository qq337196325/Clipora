import 'package:clipora/basics/utils/user_utils.dart';
import 'package:isar/isar.dart';

import 'package:get/get.dart';
import '../../basics/ui.dart';
import '../database_service.dart';
import 'enhanced_annotation_db.dart';
import '../../basics/logger.dart';

/// 增强版标注服务
/// 处理基于Range API的精确文本标注数据
class EnhancedAnnotationService {
  static EnhancedAnnotationService get instance => Get.find<EnhancedAnnotationService>();

  final _isar = Get.find<DatabaseService>().isar;

  DatabaseService get _dbService => DatabaseService.instance;


  /// 保存标注
  Future<void> saveAnnotation(EnhancedAnnotationDb annotation) async {
    try {
      await _isar.writeTxn(() async {
        annotation.userId = getUserId();
        await _isar.enhancedAnnotationDbs.put(annotation);
      });
      
      getLogger().i('✅ 增强标注保存成功: ${annotation.highlightId}');
    } catch (e) {
      getLogger().e('❌ 保存增强标注失败: $e');
      rethrow;
    }
  }


  /// 获取文章的所有标注（旧方法，基于articleId）
  Future<List<EnhancedAnnotationDb>> getAnnotationsForArticle(int articleId) async {
    try {
      // final isar = _databaseService.isar;
      final annotations = await _isar.enhancedAnnotationDbs
          .where()
          .userIdEqualTo(getUserId())
          .filter()
          .articleIdEqualTo(articleId)
          .sortByCreatedAt()
          .findAll();
      
      getLogger().d('📊 获取文章($articleId)标注: ${annotations.length}个');
      return annotations;
    } catch (e) {
      getLogger().e('❌ 获取文章标注失败: $e');
      return [];
    }
  }

  /// 获取指定语言版本的标注（新方法，基于articleContentId）
  Future<List<EnhancedAnnotationDb>> getAnnotationsForArticleContent(int articleContentId) async {
    try {
      final annotations = await _isar.enhancedAnnotationDbs
          .filter()
          .articleContentIdEqualTo(articleContentId)
          .sortByCreatedAt()
          .findAll();
      
      getLogger().d('📊 获取文章内容($articleContentId)标注: ${annotations.length}个');
      return annotations;
    } catch (e) {
      getLogger().e('❌ 获取文章内容标注失败: $e');
      return [];
    }
  }


  /// 删除标注
  Future<void> deleteAnnotation(EnhancedAnnotationDb annotation) async {
    try {
      // final isar = _databaseService.isar;
      annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();
      await _isar.writeTxn(() async {
        await _isar.enhancedAnnotationDbs.delete(annotation.id);
      });
      
      getLogger().i('✅ 标注删除成功: ${annotation.highlightId}');
    } catch (e) {
      getLogger().e('❌ 删除标注失败: $e');
      rethrow;
    }
  }

  /// 通过高亮ID删除标注
  Future<bool> deleteAnnotationByHighlightId(String highlightId) async {
    try {
      // final isar = _databaseService.isar;
      final count = await _isar.writeTxn(() async {
        return await _isar.enhancedAnnotationDbs
            .filter()
            .highlightIdEqualTo(highlightId)
            .deleteAll();
      });
      
      final success = count > 0;
      if (success) {
        getLogger().i('✅ 通过高亮ID删除标注成功: $highlightId');
      } else {
        getLogger().w('⚠️ 未找到要删除的标注: $highlightId');
      }
      
      return success;
    } catch (e) {
      getLogger().e('❌ 通过高亮ID删除标注失败: $e');
      return false;
    }
  }


  /// 清理基于 ArticleContentDb 的所有标注（新架构）
  Future<int> clearArticleContentAnnotations(int articleContentId) async {
    try {
      final count = await _isar.writeTxn(() async {
        return await _isar.enhancedAnnotationDbs
            .filter()
            .articleContentIdEqualTo(articleContentId)
            .deleteAll();
      });
      
      getLogger().i('✅ 清理文章内容($articleContentId)标注: $count个');
      return count;
    } catch (e) {
      getLogger().e('❌ 清理文章内容标注失败: $e');
      return 0;
    }
  }

  /// 通过高亮ID获取标注
  Future<EnhancedAnnotationDb?> getAnnotationByHighlightId(String highlightId) async {
    try {
      final annotation = await _isar.enhancedAnnotationDbs
          .filter()
          .highlightIdEqualTo(highlightId)
          .findFirst();
      
      if (annotation != null) {
        getLogger().d('✅ 通过高亮ID获取标注成功: $highlightId');
      } else {
        getLogger().w('⚠️ 未找到标注: $highlightId');
      }
      
      return annotation;
    } catch (e) {
      getLogger().e('❌ 通过高亮ID获取标注失败: $e');
      return null;
    }
  }

  /// 更新标注
  Future<void> updateAnnotation(EnhancedAnnotationDb annotation) async {
    try {
      await _isar.writeTxn(() async {
        annotation.updateTimestamp = getStorageServiceCurrentTimeAdding();
        await _isar.enhancedAnnotationDbs.put(annotation);
      });
      
      getLogger().i('✅ 标注更新成功: ${annotation.highlightId}');
    } catch (e) {
      getLogger().e('❌ 更新标注失败: $e');
      rethrow;
    }
  }

} 
import 'package:isar/isar.dart';

import 'package:get/get.dart';
import '../database_service.dart';
import 'enhanced_annotation_db.dart';
import '../../basics/logger.dart';

/// 增强版标注服务
/// 处理基于Range API的精确文本标注数据
class EnhancedAnnotationService {
  static EnhancedAnnotationService get instance => Get.find<EnhancedAnnotationService>();
  
  // late final DatabaseService _databaseService;
  final _isar = Get.find<DatabaseService>().isar;

  DatabaseService get _dbService => DatabaseService.instance;


  // EnhancedAnnotationService() {
  //   _databaseService = Get.find<DatabaseService>();
  // }

  /// 保存标注
  Future<void> saveAnnotation(EnhancedAnnotationDb annotation) async {
    try {

      await _isar.writeTxn(() async {
        await _isar.enhancedAnnotationDbs.put(annotation);
      });
      
      getLogger().i('✅ 增强标注保存成功: ${annotation.highlightId}');
    } catch (e) {
      getLogger().e('❌ 保存增强标注失败: $e');
      rethrow;
    }
  }

  /// 批量保存标注
  Future<void> saveAnnotations(List<EnhancedAnnotationDb> annotations) async {
    try {
      // final isar = _databaseService.isar;
      await _isar.writeTxn(() async {
        await _isar.enhancedAnnotationDbs.putAll(annotations);
      });
      
      getLogger().i('✅ 批量保存 ${annotations.length} 个增强标注成功');
    } catch (e) {
      getLogger().e('❌ 批量保存增强标注失败: $e');
      rethrow;
    }
  }

  /// 获取文章的所有标注（旧方法，基于articleId）
  Future<List<EnhancedAnnotationDb>> getAnnotationsForArticle(int articleId) async {
    try {
      // final isar = _databaseService.isar;
      final annotations = await _isar.enhancedAnnotationDbs
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

  /// 通过高亮ID获取标注
  Future<EnhancedAnnotationDb?> getAnnotationByHighlightId(String highlightId) async {
    try {
      // final isar = _databaseService.isar;
      final annotation = await _isar.enhancedAnnotationDbs
          .filter()
          .highlightIdEqualTo(highlightId)
          .findFirst();
      
      return annotation;
    } catch (e) {
      getLogger().e('❌ 通过高亮ID获取标注失败: $e');
      return null;
    }
  }

  /// 更新标注
  Future<void> updateAnnotation(EnhancedAnnotationDb annotation) async {
    try {
      annotation.touch(); // 更新时间戳
      
      // final isar = _databaseService.isar;
      await _isar.writeTxn(() async {
        await _isar.enhancedAnnotationDbs.put(annotation);
      });
      
      getLogger().i('✅ 标注更新成功: ${annotation.highlightId}');
    } catch (e) {
      getLogger().e('❌ 更新标注失败: $e');
      rethrow;
    }
  }

  /// 删除标注
  Future<void> deleteAnnotation(EnhancedAnnotationDb annotation) async {
    try {
      // final isar = _databaseService.isar;
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

  /// 获取标注统计信息
  Future<AnnotationStats> getAnnotationStats(int articleId) async {
    try {
      final annotations = await getAnnotationsForArticle(articleId);
      return AnnotationStats.fromAnnotations(annotations);
    } catch (e) {
      getLogger().e('❌ 获取标注统计失败: $e');
      return const AnnotationStats(
        totalCount: 0,
        highlightCount: 0,
        noteCount: 0,
        colorCounts: {},
        crossParagraphCount: 0,
      );
    }
  }

  /// 搜索标注
  Future<List<EnhancedAnnotationDb>> searchAnnotations({
    int? articleId,
    String? keyword,
    AnnotationType? type,
    AnnotationColor? color,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      // final isar = _databaseService.isar;
      
      // 获取所有标注然后在内存中过滤（简化实现）
      var annotations = await _isar.enhancedAnnotationDbs
          .where()
          .sortByCreatedAtDesc()
          .findAll();

      // 应用筛选条件
      if (articleId != null) {
        annotations = annotations.where((a) => a.articleId == articleId).toList();
      }

      if (keyword != null && keyword.isNotEmpty) {
        annotations = annotations.where((a) => 
          a.selectedText.toLowerCase().contains(keyword.toLowerCase()) ||
          a.noteContent.toLowerCase().contains(keyword.toLowerCase())
        ).toList();
      }

      if (type != null) {
        annotations = annotations.where((a) => a.annotationType == type).toList();
      }

      if (color != null) {
        annotations = annotations.where((a) => a.colorType == color).toList();
      }

      if (startDate != null) {
        annotations = annotations.where((a) => a.createdAt.isAfter(startDate)).toList();
      }

      if (endDate != null) {
        annotations = annotations.where((a) => a.createdAt.isBefore(endDate)).toList();
      }

      // 应用限制
      if (limit != null && limit > 0 && annotations.length > limit) {
        annotations = annotations.take(limit).toList();
      }

      return annotations;
    } catch (e) {
      getLogger().e('❌ 搜索标注失败: $e');
      return [];
    }
  }

  /// 获取最近的标注
  Future<List<EnhancedAnnotationDb>> getRecentAnnotations({int limit = 20}) async {
    try {
      // final isar = _databaseService.isar;
      final annotations = await _isar.enhancedAnnotationDbs
          .where()
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
      
      return annotations;
    } catch (e) {
      getLogger().e('❌ 获取最近标注失败: $e');
      return [];
    }
  }

  /// 验证标注数据完整性
  Future<List<EnhancedAnnotationDb>> validateAnnotations(int articleId) async {
    try {
      final annotations = await getAnnotationsForArticle(articleId);
      final invalidAnnotations = <EnhancedAnnotationDb>[];

      for (final annotation in annotations) {
        if (!annotation.isValidRangeData()) {
          invalidAnnotations.add(annotation);
          getLogger().w('⚠️ 发现无效标注数据: ${annotation.highlightId}');
        }
      }

      if (invalidAnnotations.isNotEmpty) {
        getLogger().w('⚠️ 文章($articleId)有 ${invalidAnnotations.length} 个无效标注');
      }

      return invalidAnnotations;
    } catch (e) {
      getLogger().e('❌ 验证标注数据失败: $e');
      return [];
    }
  }

  /// 修复损坏的标注
  Future<int> repairCorruptedAnnotations(int articleId) async {
    try {
      final invalidAnnotations = await validateAnnotations(articleId);
      int repairedCount = 0;

      for (final annotation in invalidAnnotations) {
        try {
          // 尝试从备份数据恢复
          if (annotation.backupData != null) {
            final restoredAnnotation = EnhancedAnnotationDb.fromBackupData(annotation.backupData!);
            if (restoredAnnotation != null) {
              restoredAnnotation.id = annotation.id;
              restoredAnnotation.articleId = articleId;
              await updateAnnotation(restoredAnnotation);
              repairedCount++;
              getLogger().i('✅ 修复标注: ${annotation.highlightId}');
            }
          }
        } catch (e) {
          getLogger().e('❌ 修复标注失败: ${annotation.highlightId}, $e');
        }
      }

      if (repairedCount > 0) {
        getLogger().i('✅ 成功修复 $repairedCount 个损坏的标注');
      }

      return repairedCount;
    } catch (e) {
      getLogger().e('❌ 修复损坏标注失败: $e');
      return 0;
    }
  }

  /// 清理文章的所有标注
  Future<int> clearArticleAnnotations(int articleId) async {
    try {
      // final isar = _databaseService.isar;
      final count = await _isar.writeTxn(() async {
        return await _isar.enhancedAnnotationDbs
            .filter()
            .articleIdEqualTo(articleId)
            .deleteAll();
      });
      
      getLogger().i('✅ 清理文章($articleId)标注: $count个');
      return count;
    } catch (e) {
      getLogger().e('❌ 清理文章标注失败: $e');
      return 0;
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

  /// 导出标注数据
  Future<List<Map<String, dynamic>>> exportAnnotations(int articleId) async {
    try {
      final annotations = await getAnnotationsForArticle(articleId);
      return annotations.map((annotation) => annotation.toRangeData()).toList();
    } catch (e) {
      getLogger().e('❌ 导出标注数据失败: $e');
      return [];
    }
  }

  /// 导入标注数据
  Future<int> importAnnotations(int articleId, List<Map<String, dynamic>> annotationDataList) async {
    try {
      final annotations = <EnhancedAnnotationDb>[];
      
      for (final data in annotationDataList) {
        try {
          final annotation = EnhancedAnnotationDb.fromSelectionData(
            data,
            articleId,
            AnnotationType.fromString(data['annotationType'] ?? 'highlight'),
            colorType: AnnotationColor.fromCssClass(data['colorType'] ?? 'highlight-yellow'),
            noteContent: data['noteContent'] ?? '',
          );
          annotations.add(annotation);
        } catch (e) {
          getLogger().w('⚠️ 跳过无效的导入数据: $e');
        }
      }
      
      if (annotations.isNotEmpty) {
        await saveAnnotations(annotations);
        getLogger().i('✅ 导入 ${annotations.length} 个标注成功');
      }
      
      return annotations.length;
    } catch (e) {
      getLogger().e('❌ 导入标注数据失败: $e');
      return 0;
    }
  }

  /// 获取标注数量
  Future<int> getAnnotationCount(int articleId) async {
    try {
      // final isar = _databaseService.isar;
      final count = await _isar.enhancedAnnotationDbs
          .filter()
          .articleIdEqualTo(articleId)
          .count();
      
      return count;
    } catch (e) {
      getLogger().e('❌ 获取标注数量失败: $e');
      return 0;
    }
  }

  /// 检查标注是否存在
  Future<bool> annotationExists(String highlightId) async {
    try {
      final annotation = await getAnnotationByHighlightId(highlightId);
      return annotation != null;
    } catch (e) {
      getLogger().e('❌ 检查标注存在性失败: $e');
      return false;
    }
  }
} 
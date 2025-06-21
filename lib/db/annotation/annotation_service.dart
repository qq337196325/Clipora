import 'package:isar/isar.dart';

import '../database_service.dart';
import 'annotation_db.dart';
import 'package:get/get.dart';

class AnnotationService {

  // static final AnnotationService instance = AnnotationService._();
  static AnnotationService get instance => Get.find<AnnotationService>();

  final _isar = Get.find<DatabaseService>().isar;

  DatabaseService get _dbService => DatabaseService.instance;

  /// 保存或更新一个标注
  Future<void> saveAnnotation(AnnotationDb annotation) async {
    annotation.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.annotationDbs.put(annotation);
    });
  }

  /// 获取一篇文章的所有标注
  Future<List<AnnotationDb>> getAnnotationsForArticle(int articleId) async {
    return await _dbService.annotations
        .where()
        .filter()
        .articleIdEqualTo(articleId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// 根据highlightId删除标注
  Future<void> deleteAnnotationByHighlightId(String highlightId) async {
    await _isar.writeTxn(() async {
      await _dbService.annotations
          .filter()
          .highlightIdEqualTo(highlightId)
          .deleteAll();
    });
  }
} 
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import 'article/article_db.dart';
import 'annotation/annotation_db.dart';
import 'tag/tag_db.dart';
import 'category/category_db.dart';
import 'sync_operation.dart';
import '../basics/logger.dart';

/// 数据库服务类
class DatabaseService extends GetxService {
  static DatabaseService get instance => Get.find<DatabaseService>();
  
  late Isar _isar;
  Isar get isar => _isar;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initDb() async {
    super.onInit();
    if (!_isInitialized) {
      await _initDatabase();
    }
  }

  /// 初始化数据库
  Future<void> _initDatabase() async {
    if (_isInitialized) {
      return; // 已经初始化过了，直接返回
    }
    
    try {
      getLogger().i('🗄️ 开始初始化数据库...');
      
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open(
        [ArticleDbSchema, AnnotationDbSchema, TagDbSchema, CategoryDbSchema, SyncOperationSchema],
        directory: dir.path,
        name: 'inkwell_db',
      );
      
      _isInitialized = true;
      getLogger().i('✅ 数据库初始化成功，路径: ${dir.path}');
    } catch (e) {
      getLogger().e('❌ 数据库初始化失败: $e');
      rethrow;
    }
  }

  /// 获取文章集合
  IsarCollection<ArticleDb> get articles => _isar.articleDbs;

  /// 获取标注集合
  IsarCollection<AnnotationDb> get annotations => _isar.annotationDbs;

  /// 获取标签集合
  IsarCollection<TagDb> get tags => _isar.tagDbs;

  /// 获取分类集合
  IsarCollection<CategoryDb> get categories => _isar.categoryDbs;

  /// 获取同步操作集合
  IsarCollection<SyncOperation> get syncOperations => _isar.syncOperations;


  @override
  void onClose() {
    if (_isInitialized) {
      _isar.close();
    }
    super.onClose();
  }
} 
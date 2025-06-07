import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import 'article/article_db.dart';
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
        [ArticleDbSchema],
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

  @override
  void onClose() {
    if (_isInitialized) {
      _isar.close();
    }
    super.onClose();
  }
} 
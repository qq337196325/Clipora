// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import 'annotation/enhanced_annotation_db.dart';
import 'article/article_db.dart';
import 'article_content/article_content_db.dart';
import 'flutter_logger/flutter_logger_db.dart';
import 'tag/tag_db.dart';
import 'category/category_db.dart';
import 'sync_operation/sync_operation.dart';
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
        [ArticleDbSchema, ArticleContentDbSchema, EnhancedAnnotationDbSchema, TagDbSchema,FlutterLoggerSchema, CategoryDbSchema, SyncOperationSchema],
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
  IsarCollection<ArticleContentDb> get articleContent => _isar.articleContentDbs;

  /// 获取标注集合
  IsarCollection<EnhancedAnnotationDb> get enhancedAnnotation => _isar.enhancedAnnotationDbs;

  /// 获取标签集合
  IsarCollection<TagDb> get tags => _isar.tagDbs;

  /// 获取分类集合
  IsarCollection<CategoryDb> get categories => _isar.categoryDbs;

  /// 获取同步操作集合
  IsarCollection<SyncOperation> get syncOperations => _isar.syncOperations;

  IsarCollection<FlutterLogger> get flutterLoggers => _isar.flutterLoggers;

  @override
  void onClose() {
    if (_isInitialized) {
      _isar.close();
    }
    super.onClose();
  }
} 
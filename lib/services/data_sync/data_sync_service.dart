import 'dart:async';
import 'package:clipora/db/annotation/enhanced_annotation_db.dart';
import 'package:clipora/db/tag/tag_db.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';

import '../../basics/logger.dart';
import '../../basics/ui.dart';
import '../../db/database_service.dart';
import '../../db/category/category_db.dart';
import '../../api/user_api.dart';

/// 负责处理数据同步到后台服务
class DataSyncService extends GetxService {
  static DataSyncService get instance => Get.find<DataSyncService>();
  final box = GetStorage();

  Timer? _timer;
  bool isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    getLogger().i('SyncService Initialized');

    // 每30秒触发一次同步检查
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      triggerSync();

      /// 获取服务器时间
      final serviceCurrentTime = await getServiceCurrentTime();
      box.write('serviceCurrentTime', serviceCurrentTime);
    });
  }


  /// 触发同步流程
  void triggerSync() async {
    if (isSyncing) {
      getLogger().i('当前同步任务在执行....');
      return;
    }
    getLogger().i('Triggering periodic sync...');

    // 获取数据库实例
    final dbService = DatabaseService.instance;
    if (!dbService.isInitialized) {
      getLogger().w('⚠️ 数据库未初始化，跳过同步');
      return;
    }

    isSyncing = true;
    
    try {
      List<String> dbList = [
        "category",
        "tag",
        "article",
        "article_content",
        "annotation",
      ];

      for (var dbName in dbList) {
          switch(dbName){
            case "category":
              await updateSyncCategoryData(dbName);
              break;
            case "tag":
              await updateSyncTagData(dbName);
              break;
            case "annotation":
              await updateSyncAnnotationData(dbName);
              break;
          }
      }
    } catch (e) {
      getLogger().e('❌ 数据同步异常: $e');
    } finally {
      isSyncing = false;
      getLogger().i('🔄 同步流程结束');
    }
  }


  // 同步标签数据
  updateSyncTagData(String dbName) async {
    try {
      getLogger().i('🔄 开始同步标签数据...');

      // 获取服务端当前时间
      int serviceCurrentTime = box.read('serviceCurrentTime') ?? 0;
      getLogger().i('📅 服务端当前时间: $serviceCurrentTime');

      // 查询需要同步的分类数据（updateTimestamp > serviceCurrentTime）
      final categoriesToSync = await DatabaseService.instance.tags
          .where()
          .filter()
          .updateTimestampGreaterThan(serviceCurrentTime)
          .findAll();
      if (categoriesToSync.isEmpty) {
        getLogger().i('✅ 没有需要同步的标签数据');
        return;
      }
      getLogger().i('📋 找到 ${categoriesToSync.length} 个需要同步的标签');

      // 将分类数据转换为服务端接口格式
      final List<Map<String, dynamic>> categoryDataList = [];

      for (final category in categoriesToSync) {
        final categoryData = {
          'client_id': category.id,
          'service_id': category.serviceId,
          'name': category.name,
          'version': category.version,
        };

        categoryDataList.add(categoryData);
        getLogger().d('📝 准备同步分类: ${category.name} (ID: ${category.id})');
      }

      // 构建请求参数
      final requestData = {
        'db_name': dbName,
        'category': categoryDataList,
      };
      getLogger().i('🚀 开始调用同步接口...');

      // 调用同步接口
      final response = await UserApi.updateSyncDataApi(requestData);
      // 处理响应
      if (response['code'] == 0) {
        getLogger().i('✅ 本地同步状态更新完成');
      } else {
        getLogger().e('❌ 分类数据同步失败: ${response['message']}');
        throw Exception('同步失败: ${response['message']}');
      }

    } catch (e) {
      getLogger().e('❌ 同步分类数据异常: $e');
    } finally {
      getLogger().i('🔄 分类数据同步流程结束');
    }
  }

  // 同步高亮（annotation）数据
  updateSyncAnnotationData(String dbName) async {
    try {
      getLogger().i('🔄 开始同步标注数据...');
      
      int serviceCurrentTime = box.read('serviceCurrentTime') ?? 0;
      final dbService = DatabaseService.instance;

      final annotationsToSync = await dbService.enhancedAnnotation
        .filter()
        .updateTimestampGreaterThan(serviceCurrentTime)
        .findAll();
      
      if (annotationsToSync.isEmpty) {
        getLogger().i('✅ 没有需要同步的标注数据');
        return;
      }
      
      getLogger().i('📋 找到 ${annotationsToSync.length} 个需要同步的标注');
      
      final List<Map<String, dynamic>> annotationDataList = annotationsToSync.map((annotation) {
        return {
            'client_id': annotation.id,
            'article_id': annotation.articleId,
            'article_content_id': annotation.articleContentId,
            'highlight_id': annotation.highlightId,
            'start_x_path': annotation.startXPath,
            'start_offset': annotation.startOffset,
            'end_x_path': annotation.endXPath,
            'end_offset': annotation.endOffset,
            'selected_text': annotation.selectedText,
            'before_context': annotation.beforeContext,
            'after_context': annotation.afterContext,
            'annotation_type': annotation.annotationType.name,
            'color_type': annotation.colorType.name,
            'note_content': annotation.noteContent,
            'cross_paragraph': annotation.crossParagraph,
            'range_fingerprint': annotation.rangeFingerprint,
            'bounding_x': annotation.boundingX,
            'bounding_y': annotation.boundingY,
            'bounding_width': annotation.boundingWidth,
            'bounding_height': annotation.boundingHeight,
            'version': annotation.version,
        };
      }).toList();
      
      final requestData = {
        'db_name': dbName,
        'annotation': annotationDataList,
      };
      
      final response = await UserApi.updateSyncDataApi(requestData);
      
      if (response['code'] == 0) {
        getLogger().i('✅ 标注数据同步成功');
        
        await dbService.isar.writeTxn(() async {
          for (final annotation in annotationsToSync) {
            annotation.isSynced = true;
            await dbService.enhancedAnnotation.put(annotation);
          }
        });
        
        getLogger().i('✅ 本地标注同步状态更新完成');
      } else {
        getLogger().e('❌ 标注数据同步失败: ${response['message']}');
        throw Exception('同步失败: ${response['message']}');
      }
      
    } catch (e) {
      getLogger().e('❌ 同步标注数据异常: $e');
    } finally {
      getLogger().i('🔄 标注数据同步流程结束');
    }
  }

  // 同步分类数据
  updateSyncCategoryData(String dbName) async {
    try {
      getLogger().i('🔄 开始同步分类数据...');
      
      // 获取服务端当前时间
      int serviceCurrentTime = box.read('serviceCurrentTime') ?? 0;
      getLogger().i('📅 服务端当前时间: $serviceCurrentTime');
      
      // 查询需要同步的分类数据（updateTimestamp > serviceCurrentTime）
      final categoriesToSync = await DatabaseService.instance.categories
          .where()
          .filter()
          .updateTimestampGreaterThan(serviceCurrentTime)
          .findAll();
      
      if (categoriesToSync.isEmpty) {
        getLogger().i('✅ 没有需要同步的分类数据');
        return;
      }
      
      getLogger().i('📋 找到 ${categoriesToSync.length} 个需要同步的分类');
      
      // 将分类数据转换为服务端接口格式
      final List<Map<String, dynamic>> categoryDataList = [];
      
      for (final category in categoriesToSync) {
        final categoryData = {
          'client_id': category.id,
          'name': category.name,
          'description': category.description ?? '',
          'icon': category.icon ?? '',
          'color': category.color ?? '',
          'sort_order': category.sortOrder,
          'is_enabled': category.isEnabled,
          'is_deleted': category.isDeleted,
          'parent_id': category.parentId ?? 0,
          'level': category.level,
          'path': category.path,
        };
        
        categoryDataList.add(categoryData);
        getLogger().d('📝 准备同步分类: ${category.name} (ID: ${category.id})');
      }
      
      // 构建请求参数
      final requestData = {
        'db_name': dbName,
        'category': categoryDataList,
      };
      
      getLogger().i('🚀 开始调用同步接口...');
      
      // 调用同步接口
      final response = await UserApi.updateSyncDataApi(requestData);
      
      // 处理响应
      if (response['code'] == 0) {
        getLogger().i('✅ 分类数据同步成功');
        
        // 更新本地数据的同步状态
        await DatabaseService.instance.isar.writeTxn(() async {
          for (final category in categoriesToSync) {
            category.isSynced = true;
            category.lastModified = DateTime.now().millisecondsSinceEpoch;
            await DatabaseService.instance.categories.put(category);
          }
        });
        
        getLogger().i('✅ 本地同步状态更新完成');
      } else {
        getLogger().e('❌ 分类数据同步失败: ${response['message']}');
        throw Exception('同步失败: ${response['message']}');
      }
      
    } catch (e) {
      getLogger().e('❌ 同步分类数据异常: $e');
    } finally {
      getLogger().i('🔄 分类数据同步流程结束');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

}
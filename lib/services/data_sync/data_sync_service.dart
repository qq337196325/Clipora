import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';

import '../../basics/logger.dart';
import '../../db/database_service.dart';
import '../../db/category/category_db.dart';
import '../../api/user_api.dart';

/// 负责处理数据同步的后台服务
class DataSyncService extends GetxService {
  static DataSyncService get instance => Get.find<DataSyncService>();
  final box = GetStorage();

  Timer? _timer;
  bool isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    getLogger().i('SyncService Initialized');

    // 初始化服务端时间
    _initServiceTime();

    // 每30秒触发一次同步检查
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      triggerSync();
    });
  }

  /// 初始化服务端时间
  Future<void> _initServiceTime() async {
    try {

    } catch (e) {
      getLogger().e('❌ 获取服务端时间失败: $e');
    }
  }

  /// 触发同步流程
  void triggerSync() async {
    if (isSyncing) {
      getLogger().i('当前同步任务在执行....');
      return;
    }
    getLogger().i('Triggering periodic sync...');

    isSyncing = true;
    
    try {
      List<String> dbList = [
        "article",
        "article_content",
        "category",
        "tag",
        "annotation",
      ];

      for (var dbName in dbList) {
          switch(dbName){
            case "category":
              await updateSyncCategoryData(dbName);
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
  updateSyncTagData(){

  }

  // 同步分类数据
  updateSyncCategoryData(String dbName) async {
    try {
      getLogger().i('🔄 开始同步分类数据...');
      
      // 获取服务端当前时间
      int serviceCurrentTime = box.read('serviceCurrentTime') ?? 0;
      getLogger().i('📅 服务端当前时间: $serviceCurrentTime');
      
      // 获取数据库实例
      final dbService = DatabaseService.instance;
      if (!dbService.isInitialized) {
        getLogger().w('⚠️ 数据库未初始化，跳过同步');
        return;
      }
      
      // 查询需要同步的分类数据（updateTimestamp > serviceCurrentTime）
      final categoriesToSync = await dbService.categories
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
        await dbService.isar.writeTxn(() async {
          for (final category in categoriesToSync) {
            category.isSynced = true;
            category.lastModified = DateTime.now().millisecondsSinceEpoch;
            await dbService.categories.put(category);
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
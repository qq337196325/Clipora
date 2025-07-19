import 'dart:async';
import 'package:get/get.dart';

import '../../basics/logger.dart';
import '../../basics/ui.dart';
import '../../db/database_service.dart';
import '../update_data_sync/data_sync_service.dart';
import 'get_sync_data.dart';


/// 定时增量同步数据
class IncrementSyncData extends GetxService {

  static IncrementSyncData get instance => Get.find<IncrementSyncData>();

  Timer? _timer;
  bool isSyncing = false;
  final GetSyncData _getSyncData = GetSyncData();

  @override
  void onInit() {
    super.onInit();
    getLogger().i('IncrementSyncData Initialized');

    // 每30秒触发一次增量同步检查
    _timer = Timer.periodic(const Duration(seconds: 45), (timer) async {


      await Get.find<DataSyncService>().run();

      await triggerIncrementSync();



      /// 获取服务器时间
      final serviceCurrentTime = getStorageServiceCurrentTime();
      if(serviceCurrentTime != 0){
        globalBoxStorage.write('IncrementSyncDataTime', serviceCurrentTime);
      }
    });
  }

  /// 触发增量同步流程
  Future<void> triggerIncrementSync() async {
    if (isSyncing) {
      getLogger().i('当前增量同步任务在执行....');
      return;
    }
    
    // getLogger().i('🔄 开始增量同步检查...');

    // 获取数据库实例
    final dbService = DatabaseService.instance;
    if (!dbService.isInitialized) {
      getLogger().w('⚠️ 数据库未初始化，跳过增量同步');
      return;
    }

    // 检查是否需要增量同步
    final lastIncrementSyncTime = globalBoxStorage.read('IncrementSyncDataTime') ?? 0;
    if (lastIncrementSyncTime == 0) {
      getLogger().i('⏭️ 未找到上次增量同步时间，跳过此次同步');
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

      bool allSuccess = true;
      for (var dbName in dbList) {
        try {
          bool success = false;
          switch(dbName) {
            case "category":
              success = await _incrementSyncCategoryData(dbName, lastIncrementSyncTime);
              break;
            case "tag":
              success = await _incrementSyncTagData(dbName, lastIncrementSyncTime);
              break;
            case "article":
              success = await _incrementSyncArticleData(dbName, lastIncrementSyncTime);
              break;
            case "article_content":
              success = await _incrementSyncArticleContentData(dbName, lastIncrementSyncTime);
              break;
            case "annotation":
              success = await _incrementSyncAnnotationData(dbName, lastIncrementSyncTime);
              break;
          }
          
          if (!success) {
            getLogger().e('❌ ${dbName} 增量同步失败');
            allSuccess = false;
          }
        } catch (e) {
          getLogger().e('❌ ${dbName} 增量同步异常: $e');
          allSuccess = false;
        }
      }

      if (allSuccess) {
        // 更新增量同步时间为当前服务器时间
        final currentServiceTime = getStorageServiceCurrentTime();
        if (currentServiceTime > 0) {
          globalBoxStorage.write('IncrementSyncDataTime', currentServiceTime);
          // getLogger().i('✅ 增量同步完成，更新同步时间: $currentServiceTime');
        }
      } else {
        getLogger().e('❌ 增量同步部分失败，不更新同步时间');
      }

    } catch (e) {
      getLogger().e('❌ 增量同步异常: $e');
    } finally {
      isSyncing = false;
      // getLogger().i('🔄 增量同步流程结束');
    }
  }

  /// 增量同步分类数据
  Future<bool> _incrementSyncCategoryData(String dbName, int currentTime) async {
    try {
      // getLogger().i('🔄 开始分类数据增量同步，时间戳: $currentTime');
      return await _getSyncData.incrementSyncCategoryData(dbName, currentTime);
    } catch (e) {
      getLogger().e('❌ 分类数据增量同步异常: $e');
      return false;
    }
  }

  /// 增量同步标签数据
  Future<bool> _incrementSyncTagData(String dbName, int currentTime) async {
    try {
      // getLogger().i('🔄 开始标签数据增量同步，时间戳: $currentTime');
      return await _getSyncData.incrementSyncTagData(dbName, currentTime);
    } catch (e) {
      getLogger().e('❌ 标签数据增量同步异常: $e');
      return false;
    }
  }

  /// 增量同步文章数据
  Future<bool> _incrementSyncArticleData(String dbName, int currentTime) async {
    try {
      // getLogger().i('🔄 开始文章数据增量同步，时间戳: $currentTime');
      return await _getSyncData.incrementSyncArticleData(dbName, currentTime);
    } catch (e) {
      getLogger().e('❌ 文章数据增量同步异常: $e');
      return false;
    }
  }

  /// 增量同步文章内容数据
  Future<bool> _incrementSyncArticleContentData(String dbName, int currentTime) async {
    try {
      // getLogger().i('🔄 开始文章内容数据增量同步，时间戳: $currentTime');
      return await _getSyncData.incrementSyncArticleContentData(dbName, currentTime);
    } catch (e) {
      getLogger().e('❌ 文章内容数据增量同步异常: $e');
      return false;
    }
  }

  /// 增量同步标注数据
  Future<bool> _incrementSyncAnnotationData(String dbName, int currentTime) async {
    try {
      // getLogger().i('🔄 开始标注数据增量同步，时间戳: $currentTime');
      return await _getSyncData.incrementSyncAnnotationData(dbName, currentTime);
    } catch (e) {
      getLogger().e('❌ 标注数据增量同步异常: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
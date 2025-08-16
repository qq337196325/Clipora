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





import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../basics/app_config_interface.dart';
import '../../../basics/logger.dart';
import '../../../basics/ui.dart';
import '../../../basics/utils/user_utils.dart';
import '../../../db/article/service/article_service.dart';
import '../../../view/home/index_service_interface.dart';
import '../../api/user_api.dart';
import '../../basics/upgrade_service.dart';
import '../../services/get_sync_data/get_sync_data.dart';
import '../../services/update_data_sync/data_sync_service.dart';

class IndexService implements IIndexService {

  late BuildContext indexContext;

  @override
  Future<bool> initRun(BuildContext context) async {

    indexContext = context;


    await _checkAppVersion(); // 在这里调用版本检查

    final config = Get.find<IConfig>();
    if (config.isHuawei) {
      bool? huaweiStoragePermission =
      globalBoxStorage.read('huaweiStoragePermission');
      if (huaweiStoragePermission == null) {
        await handleAndroidPermission();
      }
    }


    // 登录过的用户显示同步数据
    bool? isNotLogin = globalBoxStorage.read('is_not_login');
    if (isNotLogin == null || isNotLogin == false) {
      checkCompleteSync();
    }

    if (isNotLogin != null && isNotLogin == true) {
      // 首次登录的用户，添加介绍文章
      // 调用上传接口
      final response = await UserApi.getInitDataApi({});
      // 检查响应结果
      if (response['code'] != 0) {
        return false;
      }

      if (response['data']["init_article"].length <= 0) {
        return false;
      }

      try {
        for (int i = 0; response['data']["init_article"].length > i; i++) {
          Map<String, dynamic> initArticle =
          response['data']["init_article"][i];

          ArticleService.instance.createArticleFromShare(
            title: initArticle["title"]!,
            url: initArticle["url"]!,
            originalContent: initArticle["title"]!,
            excerpt: initArticle["title"]!,
            tags: [], // 可以根据内容类型添加不同标签
          );
        }

        globalBoxStorage.write('is_not_login', false); // 将状态设为登录过
      } catch (e) {
        getLogger().e('❌ 添加初始化文章失败: $e');
        return false;
      }
    }

    return true;
  }



  /// 新用户检查全量更新
  checkCompleteSync() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // box.write('completeSyncStatus', false);  /// 测试用
    bool? completeSyncStatus = GetStorage().read('completeSyncStatus');
    // getLogger().i('更新预热URL列表222');

    // 如果需要全量同步，显示对话框
    if (completeSyncStatus == null || completeSyncStatus == false) {
      showDialog<bool>(
        context: indexContext,
        barrierDismissible: false, // 防止用户意外关闭同步对话框
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return buildSyncDialogWithProgress(
              context,
              "",
              0.9,
            );
          },
        ),
      );

      // 开始同步过程
      _startSyncProcess();
    } else {
      /// 只有全量更新完或者不需要全量更新的时候初始化
      Get.put(DataSyncService(), permanent: true);
      Get.put(GetSyncData(), permanent: true);
      // Get.put(IncrementSyncData(), permanent: true);
    }
  }

  /// 开始同步过程
  void _startSyncProcess() async {
    try {
      getLogger().i('🔄 开始执行全量同步...');

      // 更新同步状态显示
      // _updateSyncProgress('i18n_home_正在初始化同步'.tr, 0.1);

      // 导入全量同步类
      // final getSyncData = GetSyncData();

      // 执行全量同步，传递进度回调
      // final syncResult = await getSyncData.completeSyncAllData(
      //   progressCallback: (message, progress) {
      //     // _updateSyncProgress(message, progress);
      //   },
      // );

      // if (syncResult) {
      //   getLogger().i('✅ 全量同步成功完成');
      //
      //   // _updateSyncProgress('i18n_home_正在完成同步'.tr, 0.9);
      //   await Future.delayed(const Duration(milliseconds: 500));
      //
      //   // 更新同步状态显示
      //   // _updateSyncProgress('i18n_home_同步完成'.tr, 1.0);
      //
      //   // 等待一下让用户看到完成状态
      //   await Future.delayed(const Duration(milliseconds: 1000));
      //
      //   // 保存同步完成状态并关闭对话框
      //   GetStorage().write('completeSyncStatus', true);
      // } else {
      //   getLogger().e('❌ 全量同步失败');
      //
      //   // // 更新同步状态显示
      //   // _updateSyncProgress('i18n_home_同步失败请检查网络连接后重试'.tr, 0.0);
      //
      //   // 等待一下然后关闭对话框
      //   await Future.delayed(const Duration(milliseconds: 1000));
      // }
    } catch (e) {
      getLogger().e('❌ 同步过程发生异常: $e');

      // // 更新同步状态显示
      // _updateSyncProgress(
      //     'i18n_home_同步异常'.tr +
      //         (e.toString().length > 50
      //             ? e.toString().substring(0, 50) + '...'
      //             : e.toString()),
      //     0.0);
    } finally {
      // final serviceCurrentTime = await getServiceCurrentTime();
      // GetStorage().write('serviceCurrentTime', serviceCurrentTime);

      /// 只有全量更新完或者不需要全量更新的时候初始化
      Get.put(DataSyncService(), permanent: true);
      Get.put(GetSyncData(), permanent: true);

      // 等待一下然后关闭对话框
      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.of(indexContext).pop(false);
    }
  }


  /// 检查应用版本
  Future<void> _checkAppVersion() async {
    // 创建服务实例并调用检查方法
    await UpgradeService().checkAndShowUpgradeDialog(indexContext);
  }

}
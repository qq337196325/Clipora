import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';


import '../../basics/config.dart';
import '../../basics/logger.dart';
import '../../components/upgrade_dialog.dart';
import '../../view/home/utils/app_store_helper.dart';
import '../api/user_api.dart';

class UpgradeService {

  /// 检查更新并根据需要显示升级对话框
  Future<void> checkAndShowUpgradeDialog(BuildContext context) async {
    try {

      final platform = Platform.isAndroid ? 'android' : 'ios';
      final res = await UserApi.getVersionUpdateApi({
        "platform": platform,
        "client_version": clientVersion,
      });
      if(res["code"] != 0){
        BotToast.showText(text: res["msg"]);
        return;
      }


      if (res["data"]["version"] > clientVersion) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: res["data"]["is_force_upgrade"],
          builder: (dialogContext) => UpgradeDialog(
            version: res["data"]["version"].toString(),
            releaseNotes: res["data"]["release_notes"],
            isForceUpgrade: res["data"]["is_force_upgrade"],
            onUpgrade: () {
              // 跳转到应用商店
              AppStoreHelper.openAppStoreForUpdate();
              // 关闭对话框
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      }
    } catch (e) {
      getLogger().e('检查更新时发生错误: $e');
    }
  }


} 
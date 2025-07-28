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
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


import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_config_interface.dart';
import '../logger.dart';
import '../ui.dart';


String getUserId(){
  final config = Get.find<IConfig>();
  if(config.isCommunityEdition){
    return "";
  }
  return globalBoxStorage.read('user_id');
}


/// 获取存储权限
Future<void> initializePermissions() async {
  try {
    final status = await Permission.storage.request();
    getLogger().i('存储权限状态: $status');
  } catch (e) {
    getLogger().e('❌ 请求存储权限失败: $e');
  }
}


// 处理Android权限请求
Future<void> handleAndroidPermission() async {
  PermissionStatus status = await Permission.storage.status;
  if (status != PermissionStatus.granted) {
    await SmartDialog.show(
      tag: "permission_dialog",
      builder: (fcontext) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("i18n_permission_请求存储文件权限".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            SizedBox(height: 16),
            Text("i18n_permission_存储文件权限说明".tr,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  ),
                  child: Text("i18n_permission_不同意".tr, style: TextStyle(color: Colors.black87)),
                  onPressed: () {
                    globalBoxStorage.write('huaweiStoragePermission', false);
                    SmartDialog.dismiss(tag: "permission_dialog");
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  ),
                  child: Text("i18n_permission_同意".tr, style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    globalBoxStorage.write('huaweiStoragePermission', true);
                    SmartDialog.dismiss(tag: "permission_dialog");
                    initializePermissions();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


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
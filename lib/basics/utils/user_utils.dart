import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import '../logger.dart';
import '../ui.dart';


String getUserId(){
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
Future<void> handleAndroidPermission(BuildContext context) async {
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
            Text("请求存储文件权限", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            SizedBox(height: 16),
            Text("在使用过程中，我们需要获取您的存储存储文件权限，我们会将网页缓存到您本地存储中。",
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
                  child: Text("不同意", style: TextStyle(color: Colors.black87)),
                  onPressed: () {
                    SmartDialog.dismiss(tag: "permission_dialog");
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  ),
                  child: Text("同意", style: TextStyle(color: Colors.white)),
                  onPressed: () {
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
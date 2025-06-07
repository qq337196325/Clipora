

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import '../../api/user_api.dart';


// 上传快照文件到服务端
import 'dart:io';

import 'logger.dart';

Future<void> uploadSnapshotToServer(String filePath) async {
  if (filePath.isEmpty) {
    getLogger().e('上传失败：文件路径为空');
    return;
  }

  try {
    // 检查文件是否存在
    final File file = File(filePath);
    if (!await file.exists()) {
      getLogger().e('🗄️ 快照文件不存在...');
      throw Exception('快照文件不存在');
    }

    // 准备上传参数
    final fileName = filePath.split('/').last;
    final FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    // 调用上传接口
    final response = await UserApi.uploadMhtmlApi(formData);
    // 检查响应结果
    if (response['code'] == 0) {
      getLogger().i('快照上传成功！');
    } else {
      getLogger().e('🗄️ 上传失败...');
      throw Exception(response['message'] ?? '上传失败');
    }

  } catch (e) {
    getLogger().e('🗄️ 上传失败...');
  } finally {
    getLogger().e('🗄️ 上传失败...');
  }
}
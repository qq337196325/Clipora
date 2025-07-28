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
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;



import 'api_services_interface.dart';
import 'logger.dart';

Future<void> uploadSnapshotToServer(String filePath, String serviceArticleId) async {
  if (filePath.isEmpty) {
    getLogger().e('上传失败：文件路径为空');
    return;
  }

  // 检查服务端文章ID是否有效
  if (serviceArticleId.isEmpty) {
    getLogger().e('上传失败：文章尚未同步到服务器，请先等待文章同步完成');
    return;
  }

  // 验证MongoDB ObjectID格式
  if (!_isValidObjectId(serviceArticleId)) {
    getLogger().e('上传失败：无效的文章ID格式，serviceArticleId: "$serviceArticleId"');
    return;
  }
  getLogger().i('ID格式，serviceArticleId: "$serviceArticleId"');
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
      "service_article_id": serviceArticleId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    // 调用上传接口
    final apiServices = getx.Get.find<IApiServices>();
    final response = await apiServices.uploadMhtml(formData);
    // 检查响应结果
    if (response['code'] == 0) {
      getLogger().i('快照上传成功！');
    } else {
      getLogger().e('🗄️ 上传失败...');
      throw Exception(response['message'] ?? '上传失败');
    }
  } catch (e) {
    getLogger().e('🗄️ 上传失败: $e');
  } finally {
    getLogger().i('🗄️ 上传操作完成');
  }
}

/// 验证MongoDB ObjectID格式
/// ObjectID应该是24位十六进制字符串，且不能是全0
bool _isValidObjectId(String id) {
  // 检查长度
  if (id.length != 24) {
    getLogger().w('ObjectID长度错误: ${id.length}, 期望: 24');
    return false;
  }

  // 检查是否为十六进制字符串
  final hexPattern = RegExp(r'^[0-9a-fA-F]{24}$');
  if (!hexPattern.hasMatch(id)) {
    getLogger().w('ObjectID格式错误，应为24位十六进制字符串: "$id"');
    return false;
  }

  // 检查是否为全0（无效的ObjectID）
  if (id == '000000000000000000000000') {
    getLogger().w('ObjectID不能为全0: "$id"');
    return false;
  }

  getLogger().i('ObjectID格式验证通过: "$id"');
  return true;
}
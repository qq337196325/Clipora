

import 'dart:io';
import 'package:dio/dio.dart' as dio;

import 'package:bot_toast/bot_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../api/user_api.dart';
import '../../../db/article/service/article_service.dart';
import '/basics/logger.dart';


///********
/// 生成快照的一些通用方法封装
class SnapshotBaseUtils {

  InAppWebViewController? webViewController; // 生成快照的 webView


  /// 生成快照
  Future<String> generateSnapshot() async {
    if (webViewController == null) {
      getLogger().w('WebView控制器未初始化');
      BotToast.showText(text: 'WebView未初始化');
      return "";
    }

    try {
      // 获取应用文档目录
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String snapshotDir = '${appDir.path}/snapshots';

      // 创建快照目录
      final Directory snapshotDirectory = Directory(snapshotDir);
      if (!await snapshotDirectory.exists()) {
        await snapshotDirectory.create(recursive: true);
      }

      // 生成文件名
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName;

      // 根据平台设置文件扩展名
      if (Platform.isAndroid) {
        fileName = 'snapshot_$timestamp.mht';
      } else if (Platform.isIOS || Platform.isMacOS) {
        fileName = 'snapshot_$timestamp.webarchive';
      } else {
        fileName = 'snapshot_$timestamp.mht';
      }

      final String filePath = '$snapshotDir/$fileName';
      // 使用saveWebArchive方法保存网页快照
      final String? savedPath = await webViewController?.saveWebArchive(
        filePath: filePath,
        autoname: false,
      );

      if (savedPath != null && savedPath.isNotEmpty) {
        getLogger().i('✅ 网页快照保存成功: $savedPath');

        return filePath;
      } else {
        throw Exception('saveWebArchive返回空路径');
      }

    }catch (e) {
      getLogger().e('❌ 生成网页快照失败: $e');
      return "";
    }

    return "";
  }

  /// 实现上传快照到服务器的逻辑
  Future<bool> uploadSnapshotToServer(String snapshotPath,int articleId) async {
    try {
      getLogger().i('🔄 开始上传快照到服务器: $snapshotPath');

      // 1. 从文件路径中提取文章ID
      // final fileName = snapshotPath.split('/').last;
      // final parts = fileName.split('_');
      // if (parts.length < 2 || parts[0] != 'snapshot') {
      //   getLogger().e('上传失败：无效的快照文件名格式: $fileName');
      //   return false;
      // }

      // 2. 根据ID从数据库获取文章信息
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article == null) {
        getLogger().e('上传失败：未找到ID为 $articleId 的文章');
        return false;
      }

      final serviceArticleId = article.serviceId;

      // 3. 检查文件和文章服务器ID的有效性
      if (snapshotPath.isEmpty) {
        getLogger().e('上传失败：文件路径为空');
        return false;
      }

      if (serviceArticleId.isEmpty) {
        getLogger().e('上传失败：文章尚未同步到服务器，无法上传快照');
        return false;
      }

      // 4. 准备并执行上传
      final File file = File(snapshotPath);
      if (!await file.exists()) {
        getLogger().e('上传失败：快照文件不存在于 $snapshotPath');
        return false;
      }

      final uploadFileName = snapshotPath.split('/').last;
      final dio.FormData formData = dio.FormData.fromMap({
        "service_article_id": serviceArticleId,
        'file': await dio.MultipartFile.fromFile(
          snapshotPath,
          filename: uploadFileName,
        ),
      });

      final response = await UserApi.uploadMhtmlApi(formData);

      if (response['code'] == 0) {
        getLogger().i('✅ 快照上传成功！');
        return true;
      } else {
        getLogger().e('❌ 快照上传失败: ${response['message'] ?? '未知错误'}');
        return false;
      }
    } catch (e) {
      getLogger().e('❌ 快照上传过程中发生异常: $e');
      return false;
    }
  }


  /// 更新文章快照信息到数据库
  Future<bool> updateArticleSnapshot(String mhtmlPath, int? articleId) async {
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，无法更新快照信息');
      return false;
    }

    try {

      // 获取文章记录
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        // 更新MHTML路径
        article.mhtmlPath = mhtmlPath;
        article.updatedAt = DateTime.now();
        article.isGenerateMhtml = true;

        // 保存到数据库
        await ArticleService.instance.saveArticle(article);
        return true;
      } else {
        getLogger().e('❌ 未找到ID为 $articleId 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 更新文章快照信息失败: $e');
    }
    return false;
  }


}
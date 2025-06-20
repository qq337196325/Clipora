import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/basics/logger.dart';
import '/services/snapshot_service.dart';
import '/db/article/article_service.dart';

class SnapshotUtils {


  // 生成和处理快照
  static Future<void> generateAndProcessSnapshot({
    required InAppWebViewController? webViewController,
    required int? articleId,
    Function(String)? onSnapshotCreated,
    required Function(bool) onLoadingStateChanged,
    required Function(bool) onSuccess,
  }) async {
    if (webViewController == null) {
      getLogger().w('WebView控制器未初始化');
      BotToast.showText(text: 'WebView未初始化');
      return;
    }

    onLoadingStateChanged(true);
    BotToast.showText(text: '开始生成快照...');

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
      final String? savedPath = await webViewController.saveWebArchive(
        filePath: filePath,
        autoname: false,
      );

      if (savedPath != null && savedPath.isNotEmpty) {
        getLogger().i('✅ 网页快照保存成功: $savedPath');
        BotToast.showText(text: '快照保存成功');

        // 使用统一的处理器
        await _handleSnapshotGenerated(savedPath, articleId, onSnapshotCreated);

        onSuccess(true);
      } else {
        throw Exception('saveWebArchive返回空路径');
      }
    } catch (e) {
      getLogger().e('❌ 生成网页快照失败: $e');
      BotToast.showText(text: '生成快照失败: $e');
    } finally {
      onLoadingStateChanged(false);
    }
  }


  // 处理快照生成后的逻辑
  static Future<void> _handleSnapshotGenerated(String filePath, int? articleId, Function(String)? onSnapshotCreated) async {
    bool uploadSuccess = false;
    try {
      // 调用上传服务
      uploadSuccess = await SnapshotService.instance.uploadSnapshotToServer(filePath);
    } catch (e) {
      getLogger().e('❌ 快照上传服务调用失败: $e');
      uploadSuccess = false;
    }

    if (uploadSuccess) {
      getLogger().i('✅ 快照上传成功: $filePath');
      BotToast.showText(text: '快照上传成功!');
      // 上传成功后更新数据库，标记isGenerateMhtml为true
      await _updateArticleSnapshot(filePath, articleId, markAsUploaded: true);
    } else {
      getLogger().w('⚠️ 快照上传失败, 只保存本地路径: $filePath');
      BotToast.showText(text: '快照上传失败, 已保存到本地');
      // 上传失败，仍按旧逻辑保存本地路径
      await _updateArticleSnapshot(filePath, articleId);
    }

    // 通过回调返回文件路径给父组件
    onSnapshotCreated?.call(filePath);
  }
  
  /// 更新文章快照信息到数据库
  static Future<void> _updateArticleSnapshot(String mhtmlPath, int? articleId, {bool markAsUploaded = false}) async {
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，无法更新快照信息');
      return;
    }

    try {
      final String action = markAsUploaded ? '上传状态' : 'MHTML路径';
      getLogger().i('📝 更新文章$action，ID: $articleId, 路径: $mhtmlPath');
      
      // 获取文章记录
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        // 更新MHTML路径
        article.mhtmlPath = mhtmlPath;
        article.updatedAt = DateTime.now();
        
        // 如果标记为已上传，则设置相应标志
        if (markAsUploaded) {
          article.isGenerateMhtml = true;
        }
        
        // 保存到数据库
        await ArticleService.instance.saveArticle(article);
        
        getLogger().i('✅ 文章快照${action}更新成功: ${article.title}');
      } else {
        getLogger().e('❌ 未找到ID为 $articleId 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 更新文章快照信息失败: $e');
    }
  }
} 
import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/basics/web_view/snapshot/snapshot_base_utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/basics/logger.dart';


class SnapshotUtils extends SnapshotBaseUtils {


  // 生成和处理快照
   Future<void> generateAndProcessSnapshot({
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
      final savedPath = await generateSnapshot();

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
    // try {
    //   // 调用上传服务
    //   uploadSuccess = await SnapshotService.instance.uploadSnapshotToServer(filePath);
    // } catch (e) {
    //   getLogger().e('❌ 快照上传服务调用失败: $e');
    //   uploadSuccess = false;
    // }
    //
    // if (uploadSuccess) {
    //   getLogger().i('✅ 快照上传成功: $filePath');
    //   BotToast.showText(text: '快照上传成功!');
    //   // 上传成功后更新数据库，标记isGenerateMhtml为true
    //   await _updateArticleSnapshot(filePath, articleId, markAsUploaded: true);
    // } else {
    //   getLogger().w('⚠️ 快照上传失败, 只保存本地路径: $filePath');
    //   BotToast.showText(text: '快照上传失败, 已保存到本地');
    //   // 上传失败，仍按旧逻辑保存本地路径
    //   await _updateArticleSnapshot(filePath, articleId);
    // }

    // 通过回调返回文件路径给父组件
    onSnapshotCreated?.call(filePath);
  }
  

} 
// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:bot_toast/bot_toast.dart';
import 'package:clipora/basics/web_view/snapshot/snapshot_base_utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
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
      BotToast.showText(text: 'i18n_article_WebView未初始化'.tr);
      return;
    }

    onLoadingStateChanged(true);
    BotToast.showText(text: 'i18n_article_开始生成快照'.tr);

    try {
      // 获取应用文档目录
      final savedPath = await generateSnapshot();

      if (savedPath != null && savedPath.isNotEmpty) {
        getLogger().i('✅ 网页快照保存成功: $savedPath');
        BotToast.showText(text: 'i18n_article_快照保存成功'.tr);

        // 使用统一的处理器
        await _handleSnapshotGenerated(savedPath, articleId, onSnapshotCreated);

        onSuccess(true);
      } else {
        throw Exception('saveWebArchive返回空路径');
      }
    } catch (e) {
      getLogger().e('❌ 生成网页快照失败: $e');
      BotToast.showText(text: '${'i18n_article_生成快照失败'.tr}$e');
    } finally {
      onLoadingStateChanged(false);
    }
  }


  // 处理快照生成后的逻辑
  static Future<void> _handleSnapshotGenerated(String filePath, int? articleId, Function(String)? onSnapshotCreated) async {

    // 通过回调返回文件路径给父组件
    onSnapshotCreated?.call(filePath);
  }
  

} 
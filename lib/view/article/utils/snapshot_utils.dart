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
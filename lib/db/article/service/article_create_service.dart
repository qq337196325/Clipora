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


import 'package:clipora/basics/utils/user_utils.dart';

import '../../../basics/api_services_interface.dart';
import '../../../basics/app_config_interface.dart';
import '../../../basics/ui.dart';
import '../article_db.dart';
import '../../../basics/logger.dart';
import 'article_service.dart';
import 'article_update_service.dart';
import 'package:get/get.dart';


/// 文章服务类
class ArticleCreateService extends ArticleUpdateService {



  /// 从分享内容创建文章
  Future<ArticleDb> createArticleFromShare({
    required String title,
    required String url,
    required String originalContent,
    String? excerpt,
    List<String>? tags,
  }) async {

    try {
      getLogger().i('📝 从分享内容创建文章: $title');
      getLogger().i('📝 从分享内容创建文章: ${getUserId()}');

      final article = ArticleDb()
        ..title = title
        ..url = url
        ..shareOriginalContent = originalContent
        ..excerpt = excerpt
        ..isRead = 0
        ..readCount = 0
        ..readDuration = 0
        ..uuid = getUuid()
        ..updateTimestamp = getStorageServiceCurrentTimeAdding()
        ..readProgress = 0.0;

      final savedArticle = await saveArticle(article);

      final config = Get.find<IConfig>();

      if(config.isCommunityEdition){
        return savedArticle;
      }

      /// 将数据保存到服务端
      final param = {
        'client_article_id': savedArticle.id,
        'title': savedArticle.title,
        'url': savedArticle.url,
        "uuid": article.uuid,
        'share_original_content': savedArticle.shareOriginalContent,
      };

      final apiServices = Get.find<IApiServices>();
      final response = await apiServices.createArticle(param);
      if (response['code'] == 0) {
        final serviceIdData = response['data'];
        String serviceId = '';

        if (serviceIdData != null) {
          serviceId = serviceIdData.toString();
        }

        if (serviceId.isNotEmpty) {
          await ArticleService.instance.markArticleAsSynced(article.id, serviceId);
          getLogger().i('✅ 文章同步成功。 服务端ID: $serviceId');
        } else {
          getLogger().e('❌ 后端返回了无效的服务端ID: "$serviceId" (本地ID: ${article.id})');
        }
      }

      getLogger().i('📝 文章已创建，serviceId将在后端同步完成后设置');
      return savedArticle;
    } catch (e) {
      getLogger().e('❌ 从分享内容创建文章失败: $e');
      rethrow;
    }
  }


}
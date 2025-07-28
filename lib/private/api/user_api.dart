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


import 'dart:async';

import 'request.dart';
import "/basics/config.dart";

class UserApi {


  static Future<Map> getVersionUpdateApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/get_version_update", data:param);
  }
  static Future<Map> smsCodeApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/sms_code", data:param);
  }
  static Future<Map> accountLoginApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/account_login", data:param);
  }
  static Future<Map> wechatLoginApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/wechat_login", data:param);
  }
  static Future<Map> appleLoginApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/apple_login", data:param);
  }
  static Future<Map> getInitDataApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/get_init_data", data:param);
  }

  static Future<Map> uploadMhtmlApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/upload_mhtml", data:param);
  }
  static Future<Map> createArticleApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/create_article", data:param);
  }
  static Future<Map> getArticleApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/get_article", data:param);
  }
  static Future<Map> translateApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/translate", data:param);
  }
  static Future<Map> getTranslateContentApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/get_translate_content", data:param);
  }
  static Future<Map> createTranslatePayOrderApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/create_translate_pay_order", data:param);
  }
  static Future<Map> iosPayTranslateOrderApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/ios_pay_translate_order", data:param);
  }
  static Future<Map> getTranslateRequestQuantityApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/get_translate_request_quantity", data:param);
  }

  // ------------------------  数据同步  -----------------------------
  static Future<Map> getCurrentTimeApi() async {
    return await Request().post("$apiVersion/api/user/get_current_time");
  }
  static Future<Map> getSyncAllDataApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/get_sync_all_data", data:param);
  }
  static Future<Map> updateSyncDataApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/update_sync_data", data:param);
  }
  static Future<Map> createFlutterLoggerApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/create_flutter_logger", data:param);
  }


}
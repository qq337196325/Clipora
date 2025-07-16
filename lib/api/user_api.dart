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
  static Future<Map> createTranslatePayOrderApi(Map<String, dynamic> param) async {
    return await Request().post("$apiVersion/api/user/create_translate_pay_order", data:param);
  }
  static Future<Map> iosPayTranslateOrderApi(Map<String, dynamic> param) async {
    return await Request().post("$apiVersion/api/user/ios_pay_translate_order", data:param);
  }
  static Future<Map> getTranslateRequestQuantityApi(Map<String, dynamic> param) async {
    return await Request().post("$apiVersion/api/user/get_translate_request_quantity", data:param);
  }

  // ------------------------  数据同步  -----------------------------
  static Future<Map> getCurrentTimeApi() async {
    return await Request().post("$apiVersion/api/user/get_current_time");
  }
  static Future<Map> getSyncAllDataApi(Map<String, dynamic> param) async {
    return await Request().post("$apiVersion/api/user/get_sync_all_data", data:param);
  }
  static Future<Map> updateSyncDataApi(Map<String, dynamic> param) async {
    return await Request().post("$apiVersion/api/user/update_sync_data", data:param);
  }
  static Future<Map> createFlutterLoggerApi(Map<String, dynamic> param) async {
    return await Request().post("$apiVersion/api/user/create_flutter_logger", data:param);
  }


}
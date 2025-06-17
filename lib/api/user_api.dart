import 'dart:async';

import 'request.dart';
import "/basics/config.dart";

class UserApi {

  static Future<Map> smsCodeApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/sms_code", data:param);
  }
  static Future<Map> accountLoginApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/account_login", data:param);
  }
  static Future<Map> wechatLoginApi(dynamic param) async {
    return await Request().post("$apiVersion/api/user/wechat_login", data:param);
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

}
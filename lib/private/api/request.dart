// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response;

import '../../basics/logger.dart';
import '../../basics/translations/language_controller.dart';
import '/private/basics/config.dart';


/// 将 Dio 实例化和拦截器注册的操作放到单独的方法中，方便管理
Dio initDio(String _apiHost) {
  BaseOptions options = BaseOptions(
    baseUrl: _apiHost,
    connectTimeout: const Duration(milliseconds: 80000), // 5秒连接超时
    receiveTimeout: const Duration(milliseconds: 80000), // 5秒接收超时
  );
  Dio dio = Dio(options);

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      return handler.next(options);
    },
    onResponse: (response, handler) {
      if(
          response.requestOptions.uri.path != "$apiVersion/api/user/get_sync_all_data" &&
          response.requestOptions.uri.path != "$apiVersion/api/user/get_current_time"
      ){
        getLogger().i({
          "请求地址：": response.requestOptions.uri.toString(),
          "请求地址2：":response.requestOptions.uri.path,
          "请求数据：": response.requestOptions.data,
          "请求头：":response.requestOptions.headers,
          "type": "响应数据",
          "响应数据：": response.data,
          "响应头：": response.headers,
        });
      }
      return handler.next(response);
    },
    onError: (e, handler) {
      /// 请求出错后，关闭加载提示
      getLogger().e({
        "请求地址：": e.requestOptions.uri.toString(),
        "请求数据：": e.requestOptions.data,
        "请求头：":e.requestOptions.headers,
        "type": "错误响应数据",
        "错误信息：": e.message,
        "错误类型：": e.type,
      });
      return handler.next(e);
    },
  ));
  return dio;
}

class Request {
  static final Request _singleton = Request._init();
  static Dio dio = initDio(apiHost);

  factory Request() {
    return _singleton;
  }

  Request._init();

  /// 获取当前语言代码
  String _getCurrentLanguage() {
    try {
      final languageController = Get.find<LanguageController>();
      final locale = languageController.currentLocale.value;
      return '${locale.languageCode}_${locale.countryCode}';
    } catch (e) {
      // 如果获取失败，返回默认语言
      return 'zh_CN';
    }
  }

  /// get 请求
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? param,
    Map<String, dynamic>? headers,
  }) async {
    String hToken = "";
    int tokenType = 0;
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (headers != null) {
      headers.addAll({
        "token": token,
        "X-Language": _getCurrentLanguage(),
      });
    } else {
      headers = {
        "token": token,
        "X-Language": _getCurrentLanguage(),
      };
    }

    Response response = await dio.get(
      path,
      queryParameters: param,
      options: Options(
        headers: headers,
      ),
    );
    return _handleResponse(response);
  }

  /// post 请求
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    String hToken = "";
    int tokenType = 0;
    final prefs = await SharedPreferences.getInstance();
    String? temporary_token = prefs.getString('temporary_token');
    String? token = prefs.getString('token');
    if (token != null) {
      hToken = token;
      tokenType = 1;
    } else if (temporary_token != null) {
      hToken = temporary_token;
    } else {
      hToken = "";
    }

    if (headers != null) {
      headers.addAll({
        "token": hToken,
        "X-Language": _getCurrentLanguage(),
      });
    } else {
      headers = {
        "token": hToken,
        "X-Language": _getCurrentLanguage(),
      };
    }

    Response response = await dio.post(
      path,
      data: data,
      options: Options(
        headers: headers,
      ),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200) {
      try {
        return response.data;
      } catch (e) {
        getLogger().e({
          "type": "错误",
          "服务端返回的数据：": response,
        });
      }
    } else {
      getLogger().e({
        "type": "错误",
        "服务端返回的数据：": response,
      });
    }
  }
}
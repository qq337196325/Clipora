import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../basics/logger.dart';
import '/basics/config.dart';

// 参考来源： https://blog.csdn.net/UserNamezhangxi/article/details/112576483
// 官方文档： https://github.com/flutterchina/dio/blob/master/README-ZH.md
// https://www.liujunmin.com/flutter/dio_encapsulation.html

/// 将 Dio 实例化和拦截器注册的操作放到单独的方法中，方便管理
Dio initDio(String _apiHost) {
  BaseOptions options = BaseOptions(
    baseUrl: _apiHost,
    connectTimeout: const Duration(milliseconds: 5000), // 5秒连接超时
    receiveTimeout: const Duration(milliseconds: 5000), // 5秒接收超时
  );
  Dio dio = Dio(options);

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      return handler.next(options);
    },
    onResponse: (response, handler) {
      if(
      response.requestOptions.uri.path != "$apiVersion/api/base/supplier_list" &&
          response.requestOptions.uri.path != "$apiVersion/api/base/customer_condition_list"
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
      });
    } else {
      headers = {
        "token": token,
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
      headers.addAll({"token": hToken});
    } else {
      headers = {"token": hToken};
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

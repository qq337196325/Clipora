// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:clipora/private/api/user_api.dart';

import '../../basics/api_services_interface.dart';

class ApiServices implements IApiServices {


  @override
  Future<Map<dynamic, dynamic>> getCurrentTime() async {
    return UserApi.getCurrentTimeApi();
  }

  @override
  Future<Map<dynamic, dynamic>> uploadMhtml(dynamic param) async {
    return UserApi.uploadMhtmlApi(param);
  }

  @override
  Future<Map<dynamic, dynamic>> createArticle(dynamic param) async {
    return UserApi.createArticleApi(param);
  }

  @override
  Future<Map<dynamic, dynamic>> getArticle(dynamic param) async {
    return UserApi.createArticleApi(param);
  }

  @override
  Future<Map<dynamic, dynamic>> translate(dynamic param) async {
    return UserApi.translateApi(param);
  }

  @override
  Future<Map<dynamic, dynamic>> getTranslateContent(dynamic param) async {
    return UserApi.getTranslateContentApi(param);
  }

  @override
  Future<Map<dynamic, dynamic>> getTranslateRequestQuantity(dynamic param) async {
    return UserApi.getTranslateRequestQuantityApi(param);
  }

}
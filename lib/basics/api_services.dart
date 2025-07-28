// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/





import 'api_services_interface.dart';

class ApiServices implements IApiServices {


  @override
  Future<Map> getCurrentTime() async {
    return {
      "code": 0,
    };
  }

  @override
  Future<Map> uploadMhtml(dynamic param) async {
    return {
      "code": 0,
    };
  }

  @override
  Future<Map> createArticle(dynamic param) async {
    return {
      "code": 0,
    };
  }

  @override
  Future<Map> getArticle(dynamic param) async {
    return {
      "code": 0,
    };
  }

  @override
  Future<Map> translate(dynamic param) async {
    return {
      "code": 0,
    };
  }

  @override
  Future<Map> getTranslateContent(dynamic param) async {
    return {
      "code": 0,
    };
  }

  @override
  Future<Map> getTranslateRequestQuantity(dynamic param) async {
    return {
      "code": 0,
    };
  }

}
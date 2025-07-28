


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
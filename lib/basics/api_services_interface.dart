


abstract class IApiServices {

  Future<Map<dynamic, dynamic>> getCurrentTime();
  Future<Map<dynamic, dynamic>> uploadMhtml(dynamic param);
  Future<Map<dynamic, dynamic>> createArticle(dynamic param);
  Future<Map<dynamic, dynamic>> getArticle(dynamic param);
  Future<Map<dynamic, dynamic>> translate(dynamic param);
  Future<Map<dynamic, dynamic>> getTranslateContent(dynamic param);
  Future<Map<dynamic, dynamic>> getTranslateRequestQuantity(dynamic param);


}
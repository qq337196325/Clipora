// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/





abstract class IApiServices {

  Future<Map<dynamic, dynamic>> getCurrentTime();
  Future<Map<dynamic, dynamic>> uploadMhtml(dynamic param);
  Future<Map<dynamic, dynamic>> createArticle(dynamic param);
  Future<Map<dynamic, dynamic>> getArticle(dynamic param);
  Future<Map<dynamic, dynamic>> translate(dynamic param);
  Future<Map<dynamic, dynamic>> getTranslateContent(dynamic param);
  Future<Map<dynamic, dynamic>> getTranslateRequestQuantity(dynamic param);


}
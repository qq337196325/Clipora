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
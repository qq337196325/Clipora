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
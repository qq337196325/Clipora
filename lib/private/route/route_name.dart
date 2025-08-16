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


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteInfo{
  final String path;
  final String name;
  Widget Function(BuildContext, GoRouterState)? builder;

  RouteInfo( {
    required this.path,
    required this.name,
    this.builder,
  });
}



class RouteName {

  static String splash = "splash";
  static String transferRoute = "transfer_route";
  static String index = "index";
  static String screenshotGallery = "screenshot_gallery"; 
  static String shareReceive = "share_receive";
  static String articlePage = "article_page";
  static String search = "search";
  static String login = "login";
  static String guide = "guide";
  static String sharePage = "share_page";
  static String phoneLogin = "phone_login";
  static String phoneVerify = "phone_verify";
  static String articleList = "article_list";
  static String aiOrderPage = "ai_order_page";
  static String memberOrderPage = "member_order_page";
  static String helpDocumentation = "help_documentation";
  static String dataSync = "data_sync";
}
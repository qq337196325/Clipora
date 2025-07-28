// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


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

}
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
  static String articlePage2 = "article_page2";
  static String search = "search";
  static String login = "login";
  static String phoneLogin = "phone_login";
  static String phoneVerify = "phone_verify";


}
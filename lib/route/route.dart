import 'package:go_router/go_router.dart';
import 'package:bot_toast/bot_toast.dart';

import '../view/home/search/search_page.dart';
import '../view/login/login_page.dart';
import '/route/route_name.dart';
import '../view/article/article_page/article_page.dart';
import '/view/demo/article_web.dart';
import '../view/home/index_page.dart';
import '../view/demo/screenshot_gallery_page.dart';
import '../view/transfer_route.dart';


getQueryParam(String param, GoRouterState state){
  String value = "";
  if(state.uri.queryParametersAll.containsKey(param)) {
    value = state.uri.queryParametersAll[param]!.first;
  }
  return value;
}

List<RouteInfo> routeInfos = [

  RouteInfo(path: "/${RouteName.transferRoute}", name: RouteName.transferRoute, builder: (context, state) => TransferRoute()),

  RouteInfo(path: "/${RouteName.index}", name: RouteName.index, builder: (context, state) => IndexPage()),

  RouteInfo(path: "/${RouteName.screenshotGallery}", name: RouteName.screenshotGallery, builder: (context, state) => ScreenshotGalleryPage()),

  RouteInfo(path: "/${RouteName.search}", name: RouteName.search, builder: (context, state) => SearchPage()),

  RouteInfo(path: "/${RouteName.login}", name: RouteName.login, builder: (context, state) => LoginPage()),

  // RouteInfo(path: "/${RouteName.articlePage}", name: RouteName.articlePage, builder: (context, state) => ArticlePage()),
  RouteInfo(path: "/${RouteName.articlePage}", name: RouteName.articlePage, builder: (context, state){
    final idStr = getQueryParam("id", state);
    final id = int.tryParse(idStr) ?? 0;
    return ArticlePage(id: id);
  }),

  RouteInfo(path: "/${RouteName.articlePage2}", name: RouteName.articlePage2, builder: (context, state) => ArticlePage2()), 

];


final GoRouter router = GoRouter(
  initialLocation: "/${RouteName.transferRoute}",
  debugLogDiagnostics: true,
  observers: [BotToastNavigatorObserver()],
  routes: <RouteBase>[

    ...routeInfos.map((value)=>GoRoute(
      path: value.path,
      name: value.name,
      builder: value.builder,
    )),

  ]
);

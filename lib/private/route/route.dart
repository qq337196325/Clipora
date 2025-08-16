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


import 'package:go_router/go_router.dart';
import 'package:bot_toast/bot_toast.dart';

import '../../view/data_sync/data_sync_page.dart';
import 'route_name.dart';
import '../../view/article/article_page/article_page.dart';
import '../../view/article_list/article_list_page.dart';
import '../../view/guide/guide_page.dart';
import '../../view/home/index_page.dart';
import '../../view/home/my_page/help_widget.dart';
import '../../view/home/search/search_page.dart';
import '../../view/login/login_page.dart';
import '../../view/order/ai_order_page.dart';
import '../../view/order/member_order_page.dart';
import '../../view/share/share_page.dart';
import '../../view/transfer_route.dart';



getQueryParam(String param, GoRouterState state){
  String value = "";
  if(state.uri.queryParametersAll.containsKey(param)) {
    value = state.uri.queryParametersAll[param]!.first;
  }
  return value;
}

List<RouteInfo> routeInfos = [

  RouteInfo(path: "/${RouteName.sharePage}", name: RouteName.sharePage, builder: (context, state) => SharePage()),

  RouteInfo(path: "/${RouteName.transferRoute}", name: RouteName.transferRoute, builder: (context, state) => TransferRoute()),

  RouteInfo(path: "/${RouteName.index}", name: RouteName.index, builder: (context, state) => IndexPage()),

  RouteInfo(path: "/${RouteName.search}", name: RouteName.search, builder: (context, state) => SearchPage()),

  RouteInfo(path: "/${RouteName.login}", name: RouteName.login, builder: (context, state) => LoginPage()),
  RouteInfo(path: "/${RouteName.guide}", name: RouteName.guide, builder: (context, state) => GuidePage()),


  RouteInfo(path: "/${RouteName.aiOrderPage}", name: RouteName.aiOrderPage, builder: (context, state) => AIOrderPage()),
  RouteInfo(path: "/${RouteName.memberOrderPage}", name: RouteName.memberOrderPage, builder: (context, state) => MemberOrderPage()),
  
  // 帮助文档页面路由
  RouteInfo(path: "/${RouteName.helpDocumentation}", name: RouteName.helpDocumentation, builder: (context, state) => HelpDocumentationPage()),

  // 数据同步页面路由
  RouteInfo(path: "/${RouteName.dataSync}", name: RouteName.dataSync, builder: (context, state) => DataSyncPage()),

  RouteInfo(path: "/${RouteName.articlePage}", name: RouteName.articlePage, builder: (context, state){
    final idStr = getQueryParam("id", state);
    final id = int.tryParse(idStr) ?? 0;
    return ArticlePage(id: id);
  }),

  // 文章列表页路由
  RouteInfo(path: "/${RouteName.articleList}", name: RouteName.articleList, builder: (context, state) {
    final typeStr = getQueryParam("type", state);
    final title = getQueryParam("title", state);
    final categoryIdStr = getQueryParam("categoryId", state);
    final categoryName = getQueryParam("categoryName", state);
    final tagIdStr = getQueryParam("tagId", state);
    final tagName = getQueryParam("tagName", state);
    
    final categoryId = categoryIdStr.isNotEmpty ? int.tryParse(categoryIdStr) : null;
    final tagId = tagIdStr.isNotEmpty ? int.tryParse(tagIdStr) : null;
    
    return ArticleListPage(
      type: typeStr.isNotEmpty ? typeStr : 'all',
      title: title.isNotEmpty ? title : '文章列表',
      categoryId: categoryId,
      categoryName: categoryName.isNotEmpty ? categoryName : null,
      tagId: tagId,
      tagName: tagName.isNotEmpty ? tagName : null,
    );
  }),

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
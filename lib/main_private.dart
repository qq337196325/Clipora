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


import 'package:clipora/view/home/index_service_interface.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/private/route/route.dart';
import '/services/share_service.dart';
import '/db/database_service.dart';
import '/basics/translations/app_translations.dart';
import '/private/api/api_services.dart';
import 'basics/api_services_interface.dart';
import 'basics/app_config_interface.dart';
import 'basics/translations/language_controller.dart';
import 'basics/theme/app_theme.dart';
import 'basics/apps_state.dart';
import 'db/article/service/article_service.dart';
import 'db/article_content/article_content_service.dart';
import 'db/tag/tag_service.dart';
import 'private/basics/app_config.dart';
import 'private/view/home/index_service.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Get.put<IConfig>(AppConfig());
  Get.put<IApiServices>(ApiServices());
  Get.put<IIndexService>(IndexService());

  // 初始化GetStorage，确保后续服务可用
  await GetStorage.init();

  // 注册数据库服务（必须第一个初始化并等待完成）
  final dbService = Get.put(DatabaseService(), permanent: true);
  // 确保数据库初始化完成，这对于后续操作至关重要
  await dbService.initDb();

  // 注册分享服务
  Get.put(ShareService(), permanent: true);

  // 注册文章服务
  Get.put(ArticleService(), permanent: true);
  Get.put(ArticleContentService(), permanent: true);
  Get.put(TagService(), permanent: true);

  // 注册语言控制器
  Get.put(LanguageController(), permanent: true);

  // 注册主题控制器
  Get.put(ThemeController(), permanent: true);

  runApp(AppsState(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取主题控制器和语言控制器
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    // 从 LanguageController 获取支持的语言列表
    final supportedLocales = languageController
        .supportedLanguages
        .map((lang) => lang.locale)
        .toList();

    return Obx(() => GetMaterialApp.router(
      title: "Clipora",
      debugShowCheckedModeBanner: false,
      // 使用主题控制器动态获取主题
      theme: themeController.currentThemeData,
      // 多语言配置
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),

      // 新增以下内容以支持Flutter内置组件的国际化
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,

      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      // 推荐使用官方推荐的简洁方式来初始化 BotToast
      builder: (context, child) {
        final botToastBuilder = BotToastInit(); //1.调用BotToastInit
        final flutterSmartDialog = FlutterSmartDialog.init();

        child = botToastBuilder(context, child);
        child = flutterSmartDialog(context, child);
        return child;
      },
      // builder: BotToastInit(),
    ));
  }
}
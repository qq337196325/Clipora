import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inkwell/route/route.dart';
import 'package:inkwell/controller/share_service.dart';
import 'package:inkwell/db/database_service.dart';
import 'package:inkwell/db/article/article_service.dart';
import 'package:inkwell/basics/translations/app_translations.dart';
import 'package:inkwell/controller/language_controller.dart';

import 'basics/apps_state.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides(); // 忽略证书
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化GetStorage
  GetStorage.init();
  _initServices();

  runApp(AppsState(child: MyApp()));
}

/// 异步初始化服务
Future<void> _initServices() async {
  // 注册数据库服务（必须第一个初始化并等待完成）
  final dbService = Get.put(DatabaseService(), permanent: true);
  // 等待数据库服务完全初始化
  dbService.initDb();
  
  // 注册文章服务
  Get.put(ArticleService(), permanent: true);
  
  // 注册分享服务
  Get.put(ShareService(), permanent: true);
  
  // 注册语言控制器
  Get.put(LanguageController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData();
    return GetMaterialApp.router(
      title: "Clipora",
      debugShowCheckedModeBanner: false,
      
      // 多语言配置
      translations: AppTranslations(),
      locale: Get.find<LanguageController>().currentLocale.value,
      fallbackLocale: const Locale('zh', 'CN'),
      
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      // 添加 BotToast 配置
      // builder: BotToastInit(),
       builder: (context, child) {
        final botToastBuilder = BotToastInit();  
        child = botToastBuilder(context, child);
        return child;
      },
    );

  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inkwell/route/route.dart';
import 'package:inkwell/api/share_service.dart';
import 'package:inkwell/basics/translations/app_translations.dart';
import 'package:inkwell/controller/language_controller.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides(); // 忽略证书
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化GetStorage
  await GetStorage.init();
  
  // 初始化GetX服务
  _initServices();

  runApp(MyApp());
}

/// 初始化服务
void _initServices() {
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
    // ThemeData light = lightTheme;

    // ClientLog.instance.getDeviceInfo();

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
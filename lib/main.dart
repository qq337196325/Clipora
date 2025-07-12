import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/route/route.dart';
import '/services/share_service.dart';
import '/db/database_service.dart';
import '/basics/translations/app_translations.dart';
import 'basics/translations/language_controller.dart';

import 'basics/app_theme.dart';
import 'basics/apps_state.dart';
import 'db/article/service/article_service.dart';
import 'db/article_content/article_content_service.dart';
import 'db/tag/tag_service.dart';


void main() async {
  // HttpOverrides.global = MyHttpOverrides(); // 忽略证书
  WidgetsFlutterBinding.ensureInitialized();
  
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

  // 注册标注服务  已经放到 AppsState 处理
  // Get.put(AnnotationService(), permanent: true);

  // 注册语言控制器
  Get.put(LanguageController(), permanent: true);



  runApp(AppsState(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 从 LanguageController 获取支持的语言列表
    final supportedLocales = Get.find<LanguageController>()
        .supportedLanguages
        .map((lang) => lang.locale)
        .toList();

    return GetMaterialApp.router(
      title: "Clipora",
      debugShowCheckedModeBanner: false,
      // 应用我们自定义的护眼主题
      theme: readingTheme,
      // 多语言配置
      translations: AppTranslations(),
      fallbackLocale: const Locale('zh', 'CN'),
      
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
    );
  }
}


// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

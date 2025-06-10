import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inkwell/route/route.dart';
import 'package:inkwell/controller/share_service.dart';
import 'package:inkwell/controller/sync_service.dart';
import 'package:inkwell/controller/snapshot_service.dart';
import 'package:inkwell/db/database_service.dart';
import 'package:inkwell/db/article/article_service.dart';
import 'package:inkwell/basics/translations/app_translations.dart';
import 'package:inkwell/controller/language_controller.dart';
import 'package:inkwell/view/article/components/markdown_webview_pool_manager.dart' as MarkdownPool;
import 'package:inkwell/view/article/components/web_webview_pool_manager.dart';
import 'package:inkwell/basics/logger.dart';
import 'package:inkwell/controller/markdown_service.dart';

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
  
  // 注册同步服务
  Get.put(SyncService(), permanent: true);
  
  // 注册快照服务
  Get.put(SnapshotService(), permanent: true);
  
  // 注册Markdown生成服务
  Get.put(MarkdownService(), permanent: true);
  
  // 注册语言控制器
  Get.put(LanguageController(), permanent: true);
  
  // 🚀 初始化WebView优化器 - 异步预热，提升页面性能
  _initWebViewOptimizers();
}

/// 初始化所有WebView优化器（异步，不阻塞应用启动）
void _initWebViewOptimizers() {
  getLogger().i('🔥 开始应用启动时预热所有WebView优化器...');
  
  // 并行初始化两个优化器
  final futures = [
    // Markdown页面优化器
    MarkdownPool.WebViewPoolManager().initialize().then((_) {
      getLogger().i('✅ Markdown WebView优化器预热完成');
    }).catchError((e) {
      getLogger().e('❌ Markdown WebView优化器预热失败: $e');
    }),
    
    // Web页面优化器
    WebWebViewPoolManager().initialize().then((_) {
      getLogger().i('✅ Web页面优化器预热完成');
    }).catchError((e) {
      getLogger().e('❌ Web页面优化器预热失败: $e');
    }),
  ];
  
  Future.wait(futures).then((_) {
    getLogger().i('🎉 所有WebView优化器预热完成，页面加载性能将显著提升');
  }).catchError((e) {
    getLogger().e('❌ WebView优化器预热过程中出错: $e');
  });
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
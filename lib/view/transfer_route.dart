import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../basics/logger.dart';
import '../db/flutter_logger/flutter_logger_service.dart';
import '../route/route_name.dart';


/// 页面初始时跳转
/// 用户首先进入登陆页面，判断是否是PC端，如果是PC端跳转到该页面
/// Date: 2023-03-24
class TransferRoute extends StatefulWidget {
  @override
  _TransferRouteState createState() => _TransferRouteState();
}

class _TransferRouteState extends State<TransferRoute> {

  @override
  void initState() {
    _init();
    super.initState();
  }

  // final SnapshotService snapshotService = Get.find<SnapshotService>();

  void _init() async {

    // 初始化微信SDK
    await _initFluwx();


    // 检查本地是否存储了token
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // 检查是否从分享启动，这是优化启动速度的关键
    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    final isShareLaunch = initialMedia.isNotEmpty;

    // 如果是从分享启动，立即处理分享内容
    if (isShareLaunch) {
      // ShareService 已被初始化，可以直接找到并调用
      if (mounted) {
        context.go('/${RouteName.sharePage}');
        return;
      }
    }

    // SnapshotService

    Get.put(FlutterLoggerService(), permanent: true);

    if (token == null || token.isEmpty) {
      getLogger().i('📱 未找到本地token，跳转到登录页面');
      if (mounted) {
        // context.go('/${RouteName.login}');
        context.go('/${RouteName.guide}');
      }
      return;
    }

    if (mounted) {
      // Get.put(CategoryService(), permanent: true);

      context.go('/${RouteName.index}');
    }
  }


  /// 初始化微信SDK
  Future<void> _initFluwx() async {
    try {
      // 创建Fluwx实例
      Fluwx fluwx = Fluwx();
      // 从pubspec.yaml中读取的app_id: wx629011ac595bee08
      await fluwx.registerApi(
        appId: "wx629011ac595bee08",
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: "https://clipora-api.guanshangyun.com/wechat/app/", // 与pubspec.yaml保持一致
      );
      getLogger().i('✅ 微信SDK初始化成功');
    } catch (e) {
      getLogger().e('❌ 微信SDK初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(8),
      ),
      child: UnconstrainedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset("assets/logo.png", width: 100, height: 100),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



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

  void _init() async {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox();
  }
}

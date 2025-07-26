import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../basics/logger.dart';
import '../../../db/article/article_db.dart';


class ArticleTabController extends GetxController with GetTickerProviderStateMixin {

  // 标签页状态
  final List<String> tabs = <String>[];
  final List<Widget> tabWidgets = <Widget>[];
  late TabController tabController;

  // 用于控制UI显隐的状态
  bool isBottomBarVisible = true;


  @override
  void onInit() {
    super.onInit();

    // 初始化一个临时的空控制器
    tabController = TabController(
      length: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 350),
    );
  }



}
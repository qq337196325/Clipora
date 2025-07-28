import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../db/annotation/enhanced_annotation_service.dart';
import '../db/category/category_service.dart';
import '../view/article/controller/article_controller.dart';
import 'package:clipora/basics/translations/language_controller.dart';


class AppsState extends StatefulWidget {

  final Widget child;

  const AppsState({
    super.key,
    required this.child,
  });

  @override
  State<AppsState> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AppsState> {


  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {


    Get.lazyPut(() => CategoryService());
    Get.lazyPut(() => EnhancedAnnotationService());
    Get.lazyPut(() => LanguageController());

    Get.lazyPut(() => ArticleController());

  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../db/annotation/enhanced_annotation_service.dart';
import '../view/article/controller/article_controller.dart';


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




    Get.lazyPut(() => ArticleController());
    // Get.lazyPut(() => ArticleMarkdownController());
    // Get.lazyPut(() => SnapshotService());
    Get.lazyPut(() => EnhancedAnnotationService());
    // Get.lazyPut(() => FullCommodityCategoryController());
    // Get.lazyPut(() => FullCommodityUtilController());
    // Get.lazyPut(() => UserController());
    // Get.lazyPut(() => WarehouseController());
    // Get.lazyPut(() => SupplierController());
    // Get.lazyPut(() => CustomerController());
    // Get.lazyPut(() => IncomeController());
    // Get.lazyPut(() => PaymentController());
    // Get.lazyPut(() => TransferRouteController());
    // Get.lazyPut(() => IndexController());

  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}
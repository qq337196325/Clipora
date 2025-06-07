import 'package:flutter/material.dart';
import 'package:get/get.dart';



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
    // Get.lazyPut(() => BankAccountController());
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

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}
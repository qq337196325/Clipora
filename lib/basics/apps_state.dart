// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.


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
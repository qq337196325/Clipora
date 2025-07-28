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


import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../db/article/article_db.dart';
import '../../../db/article/service/article_service.dart';
import '../../../db/article_content/article_content_db.dart';


/// 文章控制器
class ArticleBaseController extends GetxController {


  late BuildContext context;

  int articleId = 0;

  // 获取文章服务实例
  final ArticleService articleService = ArticleService.instance;

  // 当前文章数据
  final Rx<ArticleDb?> currentArticleRx = Rx<ArticleDb?>(null);
  ArticleDb? get currentArticle => currentArticleRx.value;

  // 当前语言文章
  final Rx<ArticleContentDb?> currentArticleContentRx = Rx<ArticleContentDb?>(null);
  ArticleContentDb? get currentArticleContent => currentArticleContentRx.value;

  // 当前语言的 Markdown 内容
  final RxString currentMarkdownContentRx = ''.obs;
  String get currentMarkdownContent => currentMarkdownContentRx.value;

  // 当前显示的语言代码
  final RxString currentLanguageCodeRx = 'original'.obs;
  String get currentLanguageCode => currentLanguageCodeRx.value;




}
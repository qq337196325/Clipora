import 'package:get/get.dart';

import '../../../db/article/article_db.dart';
import '../../../db/article/service/article_service.dart';
import '../../../db/article_content/article_content_db.dart';


/// 文章控制器
class ArticleBaseController extends GetxController {

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
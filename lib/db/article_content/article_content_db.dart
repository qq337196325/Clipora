

import 'package:isar/isar.dart';

part 'article_content_db.g.dart'; // 用于代码生成

@collection
class ArticleContentDb {

  Id id = Isar.autoIncrement;

  // 关联文章
  @Index()
  int articleId = 0;

  @Index()
  String languageCode = "";

  @Index() String markdown = "";                  // Markdown文档
  @Index() String textContent = "";               // 纯文本、可以用于做搜索

  bool isOriginal = true;     // 是否是源语言

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();
  DateTime? deletedAt;                         // 删除日期

}
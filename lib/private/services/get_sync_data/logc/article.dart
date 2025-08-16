



import '../../../../basics/utils/user_utils.dart';
import '../../../../db/article/article_db.dart';
import '../models/article_model.dart';

/// 从ArticleModel创建ArticleDb
ArticleDb createArticleFromModel(ArticleModel model) {
  final now = DateTime.now();
  return ArticleDb()
    ..serviceId = model.id
    ..userId = model.userId
    ..title = model.title
    ..excerpt = model.description
    ..content = model.textContent
    ..domain = model.domain
    ..author = model.author
    ..articleDate = parseDateTime(model.articleDate)
    ..url = model.url
    ..shareOriginalContent = model.shareOriginalContent
  // ..mhtmlPath = ""//model.mhtmlPath
  // ..isGenerateMhtml = false//model.mhtmlPath.isNotEmpty
    ..markdownStatus = model.markdownStatus
    ..isRead = model.isRead
    ..readCount = model.readCount
    ..readDuration = model.readDuration
    ..readProgress = model.readProgress.toDouble()
    ..isArchived = model.isArchived
    ..isImportant = model.isImportant
    ..isCreateService = true
    ..isGenerateMarkdown = model.markdownStatus == 1
    ..version = model.version
    ..updateTimestamp = model.updateTimestamp
    ..createdAt = parseDateTime(model.createTime) ?? now
    ..updatedAt = parseDateTime(model.updateTime) ?? now;
}

/// 更新ArticleDb从ArticleModel
void updateArticleFromModel(ArticleDb article, ArticleModel model) {
  article.serviceId = model.id;
  article.userId = model.userId;
  article.title = model.title;
  article.excerpt = model.description;
  article.content = model.textContent;
  article.domain = model.domain;
  article.author = model.author;
  article.articleDate = parseDateTime(model.articleDate);
  article.url = model.url;
  article.shareOriginalContent = model.shareOriginalContent;
  // article.mhtmlPath = "";//model.mhtmlPath;
  // article.isGenerateMhtml = false;//model.mhtmlPath.isNotEmpty;
  article.markdownStatus = model.markdownStatus;
  article.isRead = model.isRead;
  article.readCount = model.readCount;
  article.readDuration = model.readDuration;
  article.readProgress = model.readProgress.toDouble();
  article.isArchived = model.isArchived;
  article.isImportant = model.isImportant;
  article.isCreateService = true;
  article.isGenerateMarkdown = model.markdownStatus == 1;
  article.version = model.version;
  article.updateTimestamp = model.updateTimestamp;
  article.updatedAt = parseDateTime(model.updateTime) ?? DateTime.now();
}


// /// 截取文本到指定长度
// String _truncateText(String text, int maxLength) {
//   if (text.length <= maxLength) {
//     return text;
//   }
//   return '${text.substring(0, maxLength)}...';
// }





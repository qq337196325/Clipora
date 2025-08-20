




import '../../../../basics/utils/user_utils.dart';
import '../../../../db/article_content/article_content_db.dart';
import '../models/article_content_model.dart';

/// 从ArticleContentModel创建ArticleContentDb
ArticleContentDb createArticleContentFromModel(ArticleContentModel model, int localArticleId) {
  final now = DateTime.now();
  return ArticleContentDb()
    ..userId = model.userId
    ..articleId = localArticleId
    ..serviceId = model.id
    ..languageCode = model.languageCode
    ..markdown = model.markdown
    ..textContent = model.textContent
    ..isOriginal = model.isOriginal
    ..version = model.version
    ..uuid = model.uuid
    ..updateTimestamp = model.updateTimestamp
    ..createdAt = parseDateTime(model.createTime) ?? now
    ..updatedAt = parseDateTime(model.updateTime) ?? now;
}

/// 更新ArticleContentDb从ArticleContentModel
void updateArticleContentFromModel(ArticleContentDb content, ArticleContentModel model, int localArticleId) {
  content.articleId = localArticleId;
  content.serviceId = model.id;
  content.languageCode = model.languageCode;
  content.markdown = model.markdown;
  content.textContent = model.textContent;
  content.isOriginal = model.isOriginal;
  content.version = model.version;
  content.updateTimestamp = model.updateTimestamp;
  content.updatedAt = parseDateTime(model.updateTime) ?? DateTime.now();
}




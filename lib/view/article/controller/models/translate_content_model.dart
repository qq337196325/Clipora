


/// 翻译内容模型
class TranslateContentModel {
  final String id;
  final String userId;
  final String serviceArticleId;
  final int articleId;
  final String languageCode;
  final String markdown;
  final String upId;

  TranslateContentModel({
    required this.id,
    required this.userId,
    required this.serviceArticleId,
    required this.articleId,
    required this.languageCode,
    required this.markdown,
    required this.upId,
  });

  factory TranslateContentModel.fromJson(Map<String, dynamic> json) {
    return TranslateContentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      serviceArticleId: json['service_article_id'] ?? '',
      articleId: json['article_id'] ?? 0,
      languageCode: json['language_code'] ?? '',
      markdown: json['markdown'] ?? '',
      upId: json['up_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_article_id': serviceArticleId,
      'article_id': articleId,
      'language_code': languageCode,
      'markdown': markdown,
      'up_id': upId,
    };
  }
}




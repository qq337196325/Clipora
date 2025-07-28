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






/// 翻译内容模型
class TranslateContentModel {
  final String id;
  final String userId;
  final String serviceArticleId;
  final int articleId;
  final String languageCode;
  final String markdown;
  final String upId;
  final String uuid;

  TranslateContentModel({
    required this.id,
    required this.userId,
    required this.serviceArticleId,
    required this.articleId,
    required this.languageCode,
    required this.markdown,
    required this.upId,
    required this.uuid,
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
      uuid: json['uuid'] ?? '',
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
      'uuid': uuid,
    };
  }
}




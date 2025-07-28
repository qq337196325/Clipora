// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:get/get.dart';

/// 文章列表类型枚举
enum ArticleListType {
  readLater('read-later'),
  category('category'),
  bookmark('bookmark'),
  search('search'),
  tag('tag'),
  archived('archived'),
  deleted('deleted'),
  all('all');

  const ArticleListType(this.value);
  final String value;

  String get title {
    switch (this) {
      case ArticleListType.readLater:
        return 'i18n_article_list_read_later'.tr;
      case ArticleListType.category:
        return 'i18n_article_list_category_articles'.tr;
      case ArticleListType.bookmark:
        return 'i18n_article_list_my_bookmarks'.tr;
      case ArticleListType.search:
        return 'i18n_article_list_search_results'.tr;
      case ArticleListType.tag:
        return 'i18n_article_list_tag_articles'.tr;
      case ArticleListType.archived:
        return 'i18n_article_list_archived_articles'.tr;
      case ArticleListType.deleted:
        return 'i18n_article_list_recycle_bin'.tr;
      case ArticleListType.all:
        return 'i18n_article_list_all_articles'.tr;
    }
  }

  static ArticleListType fromValue(String value) {
    return ArticleListType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ArticleListType.all,
    );
  }
}

/// 文章列表配置类
class ArticleListConfig {
  final ArticleListType type;
  final String title;
  final int? categoryId;
  final String? categoryName;
  final int? tagId;
  final String? tagName;
  final Map<String, dynamic> filters;

  const ArticleListConfig({
    required this.type,
    required this.title,
    this.categoryId,
    this.categoryName,
    this.tagId,
    this.tagName,
    this.filters = const {},
  });

  /// 工厂构造函数：稍后阅读
  factory ArticleListConfig.readLater() {
    return ArticleListConfig(
      type: ArticleListType.readLater,
      title: ArticleListType.readLater.title,
    );
  }

  /// 工厂构造函数：分类文章
  factory ArticleListConfig.category(int categoryId, String categoryName) {
    return ArticleListConfig(
      type: ArticleListType.category,
      title: categoryName,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  /// 工厂构造函数：标签文章
  factory ArticleListConfig.tag(int tagId, String tagName) {
    return ArticleListConfig(
      type: ArticleListType.tag,
      title: 'i18n_article_list_tag_title'.trParams({'tagName': tagName}),
      tagId: tagId,
      tagName: tagName,
    );
  }

  /// 工厂构造函数：收藏文章
  factory ArticleListConfig.bookmark() {
    return ArticleListConfig(
      type: ArticleListType.bookmark,
      title: ArticleListType.bookmark.title,
    );
  }

  /// 工厂构造函数：归档文章
  factory ArticleListConfig.archived() {
    return ArticleListConfig(
      type: ArticleListType.archived,
      title: ArticleListType.archived.title,
    );
  }

  /// 工厂构造函数：回收站
  factory ArticleListConfig.deleted() {
    return ArticleListConfig(
      type: ArticleListType.deleted,
      title: ArticleListType.deleted.title,
    );
  }

  /// 工厂构造函数：搜索结果
  factory ArticleListConfig.search(String keyword) {
    return ArticleListConfig(
      type: ArticleListType.search,
      title: 'i18n_article_list_search_title'.trParams({'keyword': keyword}),
      filters: {'keyword': keyword},
    );
  }

  /// 工厂构造函数：全部文章
  factory ArticleListConfig.all() {
    return ArticleListConfig(
      type: ArticleListType.all,
      title: ArticleListType.all.title,
    );
  }

  /// 从路由参数创建配置
  factory ArticleListConfig.fromRouteParams({
    required String typeValue,
    String? title,
    int? categoryId,
    String? categoryName,
    int? tagId,
    String? tagName,
    Map<String, dynamic>? filters,
  }) {
    final type = ArticleListType.fromValue(typeValue);
    
    return ArticleListConfig(
      type: type,
      title: title ?? type.title,
      categoryId: categoryId,
      categoryName: categoryName,
      tagId: tagId,
      tagName: tagName,
      filters: filters ?? {},
    );
  }

  /// 转换为路由参数
  Map<String, String> toRouteParams() {
    final params = <String, String>{
      'type': type.value,
      'title': title,
    };

    if (categoryId != null) {
      params['categoryId'] = categoryId.toString();
    }
    if (categoryName != null) {
      params['categoryName'] = categoryName!;
    }
    if (tagId != null) {
      params['tagId'] = tagId.toString();
    }
    if (tagName != null) {
      params['tagName'] = tagName!;
    }

    // 添加其他过滤条件
    filters.forEach((key, value) {
      if (value != null) {
        params[key] = value.toString();
      }
    });

    return params;
  }

  /// 复制并修改配置
  ArticleListConfig copyWith({
    ArticleListType? type,
    String? title,
    int? categoryId,
    String? categoryName,
    int? tagId,
    String? tagName,
    Map<String, dynamic>? filters,
  }) {
    return ArticleListConfig(
      type: type ?? this.type,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      tagId: tagId ?? this.tagId,
      tagName: tagName ?? this.tagName,
      filters: filters ?? this.filters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleListConfig &&
        other.type == type &&
        other.title == title &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.tagId == tagId &&
        other.tagName == tagName;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        title.hashCode ^
        categoryId.hashCode ^
        categoryName.hashCode ^
        tagId.hashCode ^
        tagName.hashCode;
  }

  @override
  String toString() {
    return 'ArticleListConfig(type: $type, title: $title, categoryId: $categoryId, categoryName: $categoryName, tagId: $tagId, tagName: $tagName)';
  }
} 
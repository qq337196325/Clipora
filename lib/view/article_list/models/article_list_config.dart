/// 文章列表类型枚举
enum ArticleListType {
  readLater('read-later', '稍后阅读'),
  category('category', '分类文章'),
  bookmark('bookmark', '我的收藏'),
  search('search', '搜索结果'),
  tag('tag', '标签文章'),
  all('all', '全部文章');

  const ArticleListType(this.value, this.title);
  
  final String value;
  final String title;

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
    return const ArticleListConfig(
      type: ArticleListType.readLater,
      title: '稍后阅读',
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
      title: '标签: $tagName',
      tagId: tagId,
      tagName: tagName,
    );
  }

  /// 工厂构造函数：收藏文章
  factory ArticleListConfig.bookmark() {
    return const ArticleListConfig(
      type: ArticleListType.bookmark,
      title: '我的收藏',
    );
  }

  /// 工厂构造函数：搜索结果
  factory ArticleListConfig.search(String keyword) {
    return ArticleListConfig(
      type: ArticleListType.search,
      title: '搜索: $keyword',
      filters: {'keyword': keyword},
    );
  }

  /// 工厂构造函数：全部文章
  factory ArticleListConfig.all() {
    return const ArticleListConfig(
      type: ArticleListType.all,
      title: '全部文章',
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
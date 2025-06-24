import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../db/article/article_db.dart';
import '../../../db/article/article_service.dart';
import '../models/article_list_config.dart';
import '../models/sort_option.dart';

mixin ArticleListPageBLoC<T extends StatefulWidget> on State<T> {
  late ArticleListConfig config;
  SortOption currentSort = const SortOption(type: SortType.createTime);
  
  // 分页控制器
  late PagingController<int, ArticleDb> pagingController;
  
  // 分页配置
  static const int pageSize = 20;
  
  @override
  void initState() {
    super.initState();
    pagingController = PagingController(
      getNextPageKey: (state) {
        // 如果最后一页为空（没有数据），返回null表示没有更多数据
        if (state.lastPageIsEmpty) {
          return null;
        }
        // 计算下一页的offset：当前已有数据的数量
        return state.items?.length ?? 0;
      },
      fetchPage: (pageKey) => _fetchPage(pageKey),
    );
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  /// 获取页面数据
  Future<List<ArticleDb>> _fetchPage(int pageKey) async {
    final newItems = await _getArticlesByType(
      offset: pageKey,
      limit: pageSize,
    );
    return newItems;
  }

  /// 根据类型获取文章数据（支持分页）
  Future<List<ArticleDb>> _getArticlesByType({
    required int offset,
    required int limit,
  }) async {
    final sortBy = currentSort.type.value;
    final isDescending = currentSort.isDescending;

    print('📱 [ArticleList] 开始获取数据 - type: ${config.type}, offset: $offset, limit: $limit');
    print('📱 [ArticleList] 配置信息 - categoryId: ${config.categoryId}, categoryName: ${config.categoryName}');

    // 特殊情况：如果是分类查询，先做一些数据库状态检查
    if (config.type == ArticleListType.category && config.categoryId != null) {
      await _debugDatabaseStatus(config.categoryId!);
    }

    List<ArticleDb> result = [];
    
    switch (config.type) {
      case ArticleListType.readLater:
        print('📱 [ArticleList] 获取稍后阅读文章...');
        result = await ArticleService.instance.getUnreadArticlesWithPaging(
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          isDescending: isDescending,
        );
        break;

      case ArticleListType.category:
        if (config.categoryId == null) {
          print('❌ [ArticleList] 分类ID为空!');
          throw Exception('分类ID不能为空');
        }
        print('📱 [ArticleList] 获取分类文章，categoryId: ${config.categoryId}');
        result = await ArticleService.instance.getCategoryArticlesWithPaging(
          categoryId: config.categoryId!,
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          isDescending: isDescending,
        );
        break;

      case ArticleListType.bookmark:
        print('📱 [ArticleList] 获取收藏文章...');
        result = await ArticleService.instance.getImportantArticlesWithPaging(
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          isDescending: isDescending,
        );
        break;

      case ArticleListType.search:
        final keyword = config.filters['keyword'] as String?;
        if (keyword == null || keyword.isEmpty) {
          print('📱 [ArticleList] 搜索关键词为空');
          return [];
        }
        print('📱 [ArticleList] 搜索文章，关键词: $keyword');
        result = await ArticleService.instance.searchArticlesWithPaging(
          query: keyword,
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          isDescending: isDescending,
        );
        break;

      case ArticleListType.all:
        print('📱 [ArticleList] 获取全部文章...');
        result = await ArticleService.instance.getArticlesWithPaging(
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          isDescending: isDescending,
        );
        break;
    }
    
    print('📱 [ArticleList] 获取到 ${result.length} 篇文章');
    if (result.isNotEmpty) {
      print('📱 [ArticleList] 第一篇文章标题: ${result.first.title}');
    }
    
    return result;
  }

  /// 调试数据库状态（临时方法）
  Future<void> _debugDatabaseStatus(int categoryId) async {
    try {
      print('🔍 [Debug] 正在检查分类ID: $categoryId 的数据状态...');
      
      // 使用现有的方法来获取一些基本信息
      final articles = await ArticleService.instance.getArticlesWithPaging(
        offset: 0,
        limit: 10,
      );
      print('🔍 [Debug] 能获取到的文章总数（前10条）: ${articles.length}');
      
      if (articles.isNotEmpty) {
        // 检查第一篇文章的分类信息
        final firstArticle = articles.first;
        await firstArticle.category.load();
        print('🔍 [Debug] 第一篇文章: ${firstArticle.title}');
        print('🔍 [Debug] 第一篇文章的分类: ${firstArticle.category.value?.name ?? '未设置分类'} (id: ${firstArticle.category.value?.id ?? '无'})');
      }
      
    } catch (e) {
      print('❌ [Debug] 数据库状态检查失败: $e');
    }
  }

  /// 刷新列表
  void refreshList() {
    pagingController.refresh();
  }

  /// 更改排序方式
  void changeSortOption(SortOption newSort) {
    if (currentSort != newSort) {
      setState(() {
        currentSort = newSort;
      });
      // 排序变化时需要重新加载数据
      refreshList();
    }
  }

  /// 获取当前文章列表
  List<ArticleDb> get articles {
    return pagingController.items ?? [];
  }

  /// 是否正在加载
  bool get isLoading {
    return pagingController.isLoading;
  }

  /// 错误信息
  String? get errorMessage {
    final error = pagingController.error;
    return error?.toString();
  }

  /// 更新搜索关键词（仅用于搜索类型）
  void updateSearchKeyword(String keyword) {
    if (config.type == ArticleListType.search) {
      config = config.copyWith(
        filters: {...config.filters, 'keyword': keyword},
      );
      refreshList();
    }
  }

  /// 检查是否有数据
  bool get hasData {
    return articles.isNotEmpty;
  }

  /// 检查是否为空状态
  bool get isEmpty {
    return !isLoading && 
           errorMessage == null && 
           articles.isEmpty;
  }

  /// 检查是否有错误
  bool get hasError {
    return errorMessage != null;
  }
} 
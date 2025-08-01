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



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../db/article/article_db.dart';
import '../../../db/article/service/article_service.dart';
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
    print('📱 [ArticleList] 配置信息 - categoryId: ${config.categoryId}, categoryName: ${config.categoryName}, tagId: ${config.tagId}, tagName: ${config.tagName}');

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
          throw Exception('i18n_article_list_category_id_cannot_be_null'.tr);
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

      case ArticleListType.tag:
        if (config.tagId == null) {
          print('❌ [ArticleList] 标签ID为空!');
          throw Exception('i18n_article_list_tag_id_cannot_be_null'.tr);
        }
        print('📱 [ArticleList] 获取标签文章，tagId: ${config.tagId}');
        result = await ArticleService.instance.getTagArticlesWithPaging(
          tagId: config.tagId!,
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

      case ArticleListType.archived:
        print('📱 [ArticleList] 获取归档文章...');
        result = await ArticleService.instance.getArchivedArticlesWithPaging(
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          isDescending: isDescending,
        );
        break;

      case ArticleListType.deleted:
        print('📱 [ArticleList] 获取回收站文章...');
        result = await ArticleService.instance.getDeletedArticlesWithPaging(
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

  /// 清空回收站
  Future<bool> clearRecycleBin() async {
    try {
      final deletedCount = await ArticleService.instance.clearRecycleBin();
      if (deletedCount > 0) {
        // 刷新列表
        refreshList();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [ArticleList] 清空回收站失败: $e');
      return false;
    }
  }
} 
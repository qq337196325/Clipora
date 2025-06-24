import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../db/article/article_db.dart';
import 'models/article_list_config.dart';
import 'widgets/article_list_bottom_bar.dart';
import 'widgets/article_list_item.dart';
import 'mixins/article_list_page_bloc.dart';

class ArticleListPage extends StatefulWidget {
  final String type;
  final String title;
  final int? categoryId;
  final String? categoryName;
  final int? tagId;
  final String? tagName;

  const ArticleListPage({
    super.key,
    required this.type,
    required this.title,
    this.categoryId,
    this.categoryName,
    this.tagId,
    this.tagName,
  });

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> 
    with ArticleListPageBLoC {
  bool _isBottomBarVisible = true;

  @override
  void initState() {
    config = ArticleListConfig.fromRouteParams(
      typeValue: widget.type,
      title: widget.title,
      categoryId: widget.categoryId,
      categoryName: widget.categoryName,
      tagId: widget.tagId,
      tagName: widget.tagName,
    );
    
    print('📱 [ArticleListPage] 页面初始化，配置: $config');
    print('📱 [ArticleListPage] type: ${widget.type}, categoryId: ${widget.categoryId}');
    
    super.initState();
  }

  IconData _getListTypeIcon() {
    switch (config.type) {
      case ArticleListType.readLater:
        return Icons.bookmark_rounded;
      case ArticleListType.category:
        return Icons.folder_rounded;
      case ArticleListType.tag:
        return Icons.label_rounded;
      case ArticleListType.bookmark:
        return Icons.favorite_rounded;
      case ArticleListType.archived:
        return Icons.archive_rounded;
      case ArticleListType.deleted:
        return Icons.delete_rounded;
      case ArticleListType.search:
        return Icons.search_rounded;
      case ArticleListType.all:
        return Icons.article_rounded;
    }
  }

  String _getSubtitle() {
    switch (config.type) {
      case ArticleListType.readLater:
        return '待阅读的文章';
      case ArticleListType.category:
        return '分类文章';
      case ArticleListType.tag:
        return '标签文章';
      case ArticleListType.bookmark:
        return '标为重要';
      case ArticleListType.archived:
        return '已归档的文章';
      case ArticleListType.deleted:
        return '已删除的文章';
      case ArticleListType.search:
        return '搜索结果';
      case ArticleListType.all:
        return '全部文章';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 添加渐变背景和阴影效果
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 主要内容区域
            CustomScrollView(
              slivers: [
                // 顶部标题区域
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getListTypeIcon(),
                            size: 24,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getSubtitle(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 回收站清空按钮
                        if (config.type == ArticleListType.deleted) ...[
                          const SizedBox(width: 12),
                          _buildClearRecycleBinButton(context),
                        ],
                      ],
                    ),
                  ),
                ),
                // 文章列表内容
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: PagingListener(
                    controller: pagingController,
                    builder: (context, state, fetchNextPage) => PagedSliverList<int, ArticleDb>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<ArticleDb>(
                        // animateTransitions: false, // 禁用状态切换动画

                        itemBuilder: (context, article, index) {
                          return ArticleListItem(
                            article: article,
                          );
                        },
                        firstPageProgressIndicatorBuilder: (context)=>Container(), // 禁用首页加载指示器
                        newPageProgressIndicatorBuilder: (context)=>Container(), // 禁用新页面加载指示器
                        firstPageErrorIndicatorBuilder: (context) => Container(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            '加载失败',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        noItemsFoundIndicatorBuilder: (context) => Container(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 80),
                              // 空状态插画容器
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Icon(
                                  Icons.auto_stories_outlined,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // 标题
                              Text(
                                '暂无文章',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 副标题
                              Text(
                                '这里还没有任何文章，快去收藏一些精彩内容吧',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
     
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 底部间距，避免被底部栏遮挡
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: 100 + MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ],
            ),

            // 底部操作栏
            ArticleListBottomBar(
              isVisible: _isBottomBarVisible,
              onBack: () {
                Navigator.of(context).pop();
              },
              currentSort: currentSort,
              onSortChanged: changeSortOption,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建清空回收站按钮
  Widget _buildClearRecycleBinButton(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showClearRecycleBinDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
                  '清空回收站',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
      );
  }

  /// 显示清空回收站确认对话框
  void _showClearRecycleBinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清空回收站'),
          content: const Text('确定要永久删除回收站中的所有文章吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => _confirmClearRecycleBin(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('确定删除'),
            ),
          ],
        );
      },
    );
  }

  /// 确认清空回收站
  Future<void> _confirmClearRecycleBin(BuildContext context) async {
    Navigator.of(context).pop(); // 关闭对话框
    
    try {
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在清空回收站...')),
      );
      
      final success = await clearRecycleBin();
      
      if (success) {
        // 显示成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('回收站已清空'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 显示失败提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('回收站为空或清空失败'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清空失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

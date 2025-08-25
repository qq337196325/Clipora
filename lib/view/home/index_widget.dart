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



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../route/route_name.dart';
import '../../basics/utils/user_utils.dart';
import '../../db/article/service/article_service.dart';
import '../../db/article/article_db.dart';
import '../article_list/widgets/sort_bottom_sheet.dart';
import '../article_list/models/sort_option.dart';


class IndexWidget extends StatefulWidget {
  const IndexWidget({super.key});

  @override
  State<IndexWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<IndexWidget> with IndexWidgetBLoC {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).cardColor,
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _refreshArticles,
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        child: _buildContent(),
      ),
    );
  }

  /// 构建页面内容
  Widget _buildContent() {
    return StreamBuilder<List<ArticleDb>>(
      stream: _articlesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 首次加载显示加载动画
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        if (snapshot.hasError) {
          // 加载失败显示错误信息
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 100),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _initializeStream();
                        });
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final articles = snapshot.data ?? [];
        
        // 显示文章列表
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: articles.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              // 页面头部
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // 排序按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '我的收藏',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: _showSortBottomSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sort_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '排序',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            final article = articles[index - 1];
            return _buildArticleItem(article);
          },
        );
      },
    );
  }

  /// 构建文章项
  Widget _buildArticleItem(ArticleDb article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/${RouteName.articlePage}?id=${article.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文章标题
              Text(
                article.title ?? '无标题',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 文章摘要
              if (article.excerpt?.isNotEmpty == true)
                Text(
                  article.excerpt!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              // 文章信息
              Row(
                children: [
                  
                  // 域名信息
                  if (article.domain.isNotEmpty) ...[
                    // 网站图标
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(
                        getFavicon(article.domain), //'https://cn.cravatar.com/favicon/api/index.php?url=${article.domain}',
                        width: 14,
                        height: 14,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.language,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    // 域名文本
                    Text(
                      article.domain,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                  const Spacer(),

                  // 创建时间
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(article.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ), 
                  // 收藏状态
                  if (article.isImportant == true)
                    Icon(
                      Icons.bookmark,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 显示排序底部弹窗
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(
        currentSort: currentSort,
        onSortChanged: _onSortChanged,
      ),
    );
  }

  /// 处理排序变化
  void _onSortChanged(SortOption newSort) {
    setState(() {
      currentSort = newSort;
    });
    Navigator.of(context).pop();
    _applySorting();
  }






}

mixin IndexWidgetBLoC on State<IndexWidget> {
  // 排序相关
  SortOption currentSort = const SortOption(type: SortType.createTime, isDescending: true);
  
  // 文章流
  Stream<List<ArticleDb>>? _articlesStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 初始化文章流
   void _initializeStream() {
     // 将排序参数传递给watchArticles，让数据库层面处理排序
     String sortBy;
     switch (currentSort.type) {
       case SortType.createTime:
         sortBy = 'createTime';
         break;
       case SortType.modifyTime:
         sortBy = 'modifyTime';
         break;
       case SortType.name:
         sortBy = 'name';
         break;
     }
     
     _articlesStream = ArticleService.instance.watchArticles(
       sortBy: sortBy,
       isDescending: currentSort.isDescending,
       limit: 20, // 首页显示前20篇文章
     );
   }

  /// 刷新文章列表
   Future<void> _refreshArticles() async {
     try {
       // StreamBuilder会自动响应数据变化，这里可以触发数据刷新
       await ArticleService.instance.refreshArticles();
     } catch (e) {
       // 错误处理，但不阻止刷新完成
       print('❌ [IndexWidget] 刷新失败: $e');
     }
   }
 
   /// 应用排序
   void _applySorting() {
     setState(() {
       // 重新初始化流以应用新的排序
       _initializeStream();
     });
   }
}

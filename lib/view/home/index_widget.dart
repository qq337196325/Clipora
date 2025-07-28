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
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';

import '../../../route/route_name.dart';
import '../../basics/logger.dart';
import '../../db/article/service/article_service.dart';
import '../../db/tag/tag_service.dart';
import '../../db/article/article_db.dart';
import 'components/auto_parse_tip_widget.dart'; // 添加导入


class IndexWidget extends StatefulWidget {
  const IndexWidget({super.key});

  @override
  State<IndexWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<IndexWidget> with IndexWidgetBLoC, TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 调用AutomaticKeepAliveClientMixin的build方法
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
        onRefresh: _loadArticles,
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 8),
            _buildUnreadSection(),
            _buildRecentlyReadSection(),
            _buildTagsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  /// 构建最近阅读文章区域
  Widget _buildRecentlyReadSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'i18n_home_最近阅读'.tr,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: recentlyReadArticles.isEmpty
                ?  Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 32,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'i18n_home_暂无最近阅读记录'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recentlyReadArticles.expand((article) {
                final index = recentlyReadArticles.indexOf(article);
                return [
                  if (index > 0)
                    Container(
                      // margin: const EdgeInsets.symmetric(vertical: 14),
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            theme.dividerColor.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final routeStatus = await context.push('/${RouteName.articlePage}?id=${article.id}');
                        if(routeStatus == true) {
                          _loadArticles();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: colorScheme.tertiary.withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                article.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: theme.disabledColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签区域
  Widget _buildTagsSection() {
    if (tagsWithCount.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  size: 20,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'i18n_home_我的标签'.tr,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: tagsWithCount.map((tagWithCount) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 跳转到标签文章列表页面
                    context.push('/${RouteName.articleList}?type=tag&title=${Uri.encodeComponent('i18n_home_标签'.tr + tagWithCount.tag.name)}&tagId=${tagWithCount.tag.id}&tagName=${Uri.encodeComponent(tagWithCount.tag.name)}');
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: colorScheme.secondary.withOpacity(0.2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.secondary.withOpacity(0.1),
                          colorScheme.secondary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.secondary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tagWithCount.tag.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${tagWithCount.count}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建未读文章区域
  Widget _buildUnreadSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              context.push('/${RouteName.articleList}?type=read-later&title=${'i18n_home_稍后阅读'.tr}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.bookmark_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'i18n_home_稍后阅读'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (unreadArticlesCount > 0)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(unreadArticlesCount),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'i18n_home_共count篇'.trParams({'count': unreadArticlesCount.toString()}),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 添加自动解析提示组件
          const AutoParseTipWidget(),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: unreadArticles.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 32,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'i18n_home_暂无需要稍后阅读的文章'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: unreadArticles.expand((article) {
                final index = unreadArticles.indexOf(article);
                return [
                  if (index > 0)
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            theme.dividerColor.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: article.markdownStatus == 3 ? null : () async {
                      final routeStatus = await context.push('/${RouteName.articlePage}?id=${article.id}');
                      if(routeStatus == true) {
                        _loadArticles();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    splashColor: colorScheme.primary.withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: article.markdownStatus == 3
                                  ? colorScheme.secondary // 正在生成时使用橙色
                                  : colorScheme.primary, // 正常状态使用蓝色
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              article.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: article.markdownStatus == 3
                                    ? theme.disabledColor // 正在生成时使用灰色
                                    : theme.textTheme.bodyLarge?.color, // 正常状态使用黑色
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 根据文章状态显示不同的图标
                          article.markdownStatus == 3
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: colorScheme.secondary,
                                  size: 16,
                                )
                              : Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: theme.disabledColor,
                                ),
                        ],
                      ),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }



}

mixin IndexWidgetBLoC on State<IndexWidget> {

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  // 文章列表相关变量
  List<ArticleDb> articles = [];
  List<ArticleDb> unreadArticles = [];
  List<ArticleDb> recentlyReadArticles = [];
  List<TagWithCount> tagsWithCount = [];
  int unreadArticlesCount = 0; // 未读文章总数量

  // 数据缓存时间戳，用于智能刷新
  DateTime? _lastLoadTime;

  // 定时器，用于定时刷新文章列表
  Timer? _refreshTimer;


  @override
  void initState() {
    super.initState();

    // 确保UI完全初始化后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 添加额外延迟确保GetX服务完全就绪
      _loadArticles();
      // Future.delayed(const Duration(milliseconds: 200), () {
      //   print('🚀 开始加载文章列表 (延迟后)');
      //
      // });
      
      // 启动定时器，每6秒刷新一次文章列表
      _startRefreshTimer();


    });
  }

  @override
  void dispose() {
    // 清理定时器
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  /// 启动定时刷新定时器 
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadArticles();
    });
  }



  /// 获取文章列表
  Future<void> _loadArticles() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      // 执行正常的查询
      final results = await Future.wait([
        ArticleService.instance.getUnreadArticles(limit: 5),
        ArticleService.instance.getRecentlyReadArticles(limit: 5),
        TagService.instance.getTagsWithArticleCount(),
        ArticleService.instance.getUnreadArticlesCount(), // 获取未读文章总数量
      ]);
      final unreadList = results[0] as List<ArticleDb>;
      final recentlyReadList = results[1] as List<ArticleDb>;
      final tagsList = results[2] as List<TagWithCount>;
      final unreadCount = results[3] as int;


      setState(() {
        unreadArticles = unreadList;
        recentlyReadArticles = recentlyReadList;
        tagsWithCount = tagsList;
        unreadArticlesCount = unreadCount; // 使用真实的未读文章总数量
        isLoading = false;
        _lastLoadTime = DateTime.now(); // 更新缓存时间
      });

    } catch (e, stackTrace) {
      getLogger().e('❌ 获取文章列表失败: $e   堆栈跟踪: $stackTrace');
    }
  }

}
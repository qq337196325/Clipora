import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../basics/logger.dart';
import '../../../db/article/article_db.dart';
import '../../../db/article/service/article_service.dart';
import '../../../db/article_content/article_content_db.dart';
import '../../../route/route_name.dart';
import 'components/highlight_text.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SearchPageBLoC {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 搜索头部
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 返回按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 搜索输入框
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSearchFocused 
                              ? const Color(0xFF00BCF6) 
                              : Colors.grey.shade200,
                          width: isSearchFocused ? 1.5 : 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: '搜索内容...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isSearchFocused 
                                ? const Color(0xFF00BCF6) 
                                : Colors.grey.shade500,
                            size: 20,
                          ),
                          suffixIcon: searchText.isNotEmpty
                              ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: _clearSearch,
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey.shade500,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 搜索按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _performSearch,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: searchText.isNotEmpty
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF00BCF6),
                                    Color(0xFF0099CC),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: searchText.isEmpty ? Colors.grey.shade200 : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '搜索',
                          style: TextStyle(
                            color: searchText.isNotEmpty 
                                ? Colors.white 
                                : Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 搜索内容区域
            Expanded(
              child: _buildSearchContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCF6)),
        ),
      );
    }


    if (searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return _buildSearchResults();
  }


  Widget _buildEmptyResults() {
    final bool hasSearched = searchText.isNotEmpty;
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            
            // 动画图标容器
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.cyan.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        hasSearched ? Icons.search_off_rounded : Icons.search_rounded,
                        size: 48,
                        color: const Color(0xFF00BCF6),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // 主标题
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      hasSearched ? '没有找到相关内容' : '开始搜索',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // 副标题
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 15 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      hasSearched 
                          ? '试试调整关键词或使用其他搜索词'
                          : '输入关键词搜索文章、标题',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // 搜索建议
            // if (hasSearched) ...[
            //   TweenAnimationBuilder<double>(
            //     duration: const Duration(milliseconds: 1000),
            //     tween: Tween(begin: 0.0, end: 1.0),
            //     builder: (context, value, child) {
            //       return Transform.translate(
            //         offset: Offset(0, 20 * (1 - value)),
            //         child: Opacity(
            //           opacity: value,
            //           child: Container(
            //             padding: const EdgeInsets.all(20),
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(16),
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.05),
            //                   blurRadius: 10,
            //                   spreadRadius: 0,
            //                   offset: const Offset(0, 4),
            //                 ),
            //               ],
            //             ),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   children: [
            //                     Icon(
            //                       Icons.lightbulb_outline_rounded,
            //                       color: Colors.amber.shade600,
            //                       size: 20,
            //                     ),
            //                     const SizedBox(width: 8),
            //                     Text(
            //                       '搜索建议',
            //                       style: TextStyle(
            //                         fontSize: 16,
            //                         fontWeight: FontWeight.w600,
            //                         color: Colors.grey.shade700,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 const SizedBox(height: 16),
            //                 _buildSearchSuggestions(),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ] else ...[
            //   // // 快速搜索标签
            //   // TweenAnimationBuilder<double>(
            //   //   duration: const Duration(milliseconds: 1000),
            //   //   tween: Tween(begin: 0.0, end: 1.0),
            //   //   builder: (context, value, child) {
            //   //     return Transform.translate(
            //   //       offset: Offset(0, 20 * (1 - value)),
            //   //       child: Opacity(
            //   //         opacity: value,
            //   //         child: Container(
            //   //           padding: const EdgeInsets.all(20),
            //   //           decoration: BoxDecoration(
            //   //             color: Colors.white,
            //   //             borderRadius: BorderRadius.circular(16),
            //   //             boxShadow: [
            //   //               BoxShadow(
            //   //                 color: Colors.black.withOpacity(0.05),
            //   //                 blurRadius: 10,
            //   //                 spreadRadius: 0,
            //   //                 offset: const Offset(0, 4),
            //   //               ),
            //   //             ],
            //   //           ),
            //   //           child: Column(
            //   //             children: [
            //   //               Row(
            //   //                 children: [
            //   //                   Icon(
            //   //                     Icons.flash_on_rounded,
            //   //                     color: Colors.orange.shade600,
            //   //                     size: 20,
            //   //                   ),
            //   //                   const SizedBox(width: 8),
            //   //                   Text(
            //   //                     '快速搜索',
            //   //                     style: TextStyle(
            //   //                       fontSize: 16,
            //   //                       fontWeight: FontWeight.w600,
            //   //                       color: Colors.grey.shade700,
            //   //                     ),
            //   //                   ),
            //   //                 ],
            //   //               ),
            //   //               const SizedBox(height: 16),
            //   //               _buildQuickSearchTags(),
            //   //             ],
            //   //           ),
            //   //         ),
            //   //       ),
            //   //     );
            //   //   },
            //   // ),
            // ],
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // 性能指示器
        if (_lastSearchDuration != null && searchResults.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '找到 ${searchResults.length} 条结果 (${_lastSearchDuration}ms)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                if (_lastSearchDuration! < 50)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '极快',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else if (_lastSearchDuration! < 150)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '快速',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '较慢',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        
        // 搜索结果列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: (){
                    context.push('/${RouteName.articlePage}?id=${result.id}');
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: HighlightTextBuilder.buildTitle(
                      text: result.title,
                      searchQuery: searchText,
                    ),
                    subtitle: HighlightTextBuilder.buildContent(
                      text: _getDisplayContent(result),
                      searchQuery: searchText,
                    ),
                    onTap: () => _onResultTap(result),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

mixin SearchPageBLoC on State<SearchPage> {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  
  String searchText = '';
  bool isSearchFocused = false;
  bool isLoading = false;
  
  List<String> searchSuggestions = [];
  List<ArticleDb> searchResults = [];
  
  // 文章内容缓存 - 存储文章ID到内容的映射
  Map<int, ArticleContentDb?> articleContentCache = {};
  
  // 防抖相关
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  
  // 性能统计
  DateTime? _searchStartTime;
  int? _lastSearchDuration;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    
    searchFocusNode.addListener(() {
      setState(() {
        isSearchFocused = searchFocusNode.hasFocus;
      });
    });

    // 自动聚焦到搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
    
    // 实时搜索：使用防抖避免过频繁的查询
    _debounceTimer?.cancel();
    
    if (value.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      return;
    }
    
    // 显示加载状态
    setState(() {
      isLoading = true;
    });
    
    _debounceTimer = Timer(_debounceDuration, () {
      _performRealTimeSearch(value);
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      searchText = '';
      searchResults = [];
    });
  }

  /// 实时搜索（搜索标题和内容）
  Future<void> _performRealTimeSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // 记录搜索开始时间
    _searchStartTime = DateTime.now();
    
    try {
      // 实时搜索：搜索标题和内容，限制结果数量保持响应速度
      final results = await ArticleService.instance.fastSearchArticles(query);
      
      // 预加载文章内容
      await _preloadArticleContents(results);
      
      // 计算搜索耗时
      final duration = DateTime.now().difference(_searchStartTime!).inMilliseconds;
      
      // 检查搜索词是否仍然匹配（避免过期的搜索结果覆盖新的搜索）
      if (searchText == query) {
        setState(() {
          isLoading = false;
          searchResults = results;
          _lastSearchDuration = duration;
        });
      }
      
      getLogger().d('实时搜索完成: "$query" -> ${results.length} 结果 (${duration}ms)');
    } catch (e) {
      getLogger().e('实时搜索失败: $e');
      if (searchText == query) {
        setState(() {
          isLoading = false;
          searchResults = [];
          _lastSearchDuration = null;
        });
      }
    }
  }

  /// 完整搜索（点击搜索按钮时使用，搜索标题和内容）
  Future<void> _performSearch() async {
    if (searchText.trim().isEmpty) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // 使用完整搜索功能（搜索标题和内容，更多结果）
      final results = await ArticleService.instance.searchArticles(searchText);
      
      // 预加载文章内容
      await _preloadArticleContents(results);
      
      setState(() {
        isLoading = false;
        searchResults = results;
      });
      
      getLogger().i('完整搜索完成，找到 ${results.length} 篇文章');
    } catch (e) {
      getLogger().e('搜索失败: $e');
      setState(() {
        isLoading = false;
        searchResults = [];
      });
    }
    
    // 收起键盘
    searchFocusNode.unfocus();
  }

  /// 预加载文章内容到缓存
  Future<void> _preloadArticleContents(List<ArticleDb> articles) async {
    try {
      for (final article in articles) {
        // 如果缓存中没有该文章的内容，则获取
        if (!articleContentCache.containsKey(article.id)) {
          final content = await ArticleService.instance.getOriginalArticleContent(article.id);
          articleContentCache[article.id] = content;
        }
      }
    } catch (e) {
      getLogger().e('预加载文章内容失败: $e');
    }
  }

  void _onResultTap(ArticleDb result) {
    context.push('/${RouteName.articlePage}?id=${result.id}');
  }



  /// 获取文章显示内容（优先显示包含搜索词的相关片段）
  String _getDisplayContent(ArticleDb article) {
    final String searchQuery = searchText.trim();
    
    // 如果有摘要，优先使用摘要
    if (article.excerpt != null && article.excerpt!.isNotEmpty) {
      if (searchQuery.isEmpty) {
        return article.excerpt!;
      }

      // 检查摘要是否包含搜索词
      if (article.excerpt!.toLowerCase().contains(searchQuery.toLowerCase())) {
        return article.excerpt!;
      }
    }
    
    // 从缓存中获取文章内容
    final articleContent = articleContentCache[article.id];
    
    // 如果有markdown内容
    if (articleContent?.markdown != null && articleContent!.markdown.isNotEmpty) {
      if (searchQuery.isEmpty) {
        return articleContent.markdown.length > 100 
            ? '${articleContent.markdown.substring(0, 100)}...'
            : articleContent.markdown;
      }
      
      // 提取包含搜索词的相关片段
      return HighlightTextBuilder.extractRelevantContent(
        fullContent: articleContent.markdown,
        searchQuery: searchQuery,
        maxLength: 120,
        contextLength: 40,
      );
    }
    
    // 如果有文本内容
    if (articleContent?.textContent != null && articleContent!.textContent.isNotEmpty) {
      if (searchQuery.isEmpty) {
        return articleContent.textContent.length > 100 
            ? '${articleContent.textContent.substring(0, 100)}...'
            : articleContent.textContent;
      }
      
      // 提取包含搜索词的相关片段
      return HighlightTextBuilder.extractRelevantContent(
        fullContent: articleContent.textContent,
        searchQuery: searchQuery,
        maxLength: 120,
        contextLength: 40,
      );
    }
    
    return '无内容';
  }



} 
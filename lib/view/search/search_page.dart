import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../db/article/article_service.dart';
import '../../db/article/article_db.dart';
import '../../basics/logger.dart';
import '../../route/route_name.dart';
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
                            horizontal: 16,
                            vertical: 12,
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
                          horizontal: 16,
                          vertical: 10,
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

    if (searchText.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索建议',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              // 测试按钮
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _showTestMenu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '测试',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 热门搜索
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searchSuggestions.map((suggestion) => 
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _selectSuggestion(suggestion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: searchText.isNotEmpty 
                        ? HighlightText(
                            text: suggestion,
                            searchQuery: searchText,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            highlightStyle: TextStyle(
                              color: const Color(0xFF00BCF6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              backgroundColor: const Color(0xFF00BCF6).withOpacity(0.1),
                            ),
                          )
                        : Text(
                            suggestion,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到相关内容',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
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
                    trailing: result.isRead == 1
                        ? Icon(
                      Icons.check_circle,
                      color: Colors.green.shade400,
                      size: 20,
                    )
                        : Icon(
                      Icons.circle_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
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
    
    // 加载搜索建议
    _loadSearchSuggestions();
    
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

  void _selectSuggestion(String suggestion) {
    searchController.text = suggestion;
    setState(() {
      searchText = suggestion;
    });
    _performSearch();
  }

  /// 加载搜索建议
  Future<void> _loadSearchSuggestions() async {
    try {
      // 优先使用热门搜索词，如果没有再使用基于文章的建议
      final hotKeywords = await ArticleService.instance.getHotSearchKeywords();
      final suggestions = await ArticleService.instance.getSearchSuggestions();
      
      // 合并热门搜索词和智能建议
      final allSuggestions = <String>{...hotKeywords, ...suggestions}.toList();
      
      setState(() {
        searchSuggestions = allSuggestions.take(10).toList();
      });
    } catch (e) {
      getLogger().e('加载搜索建议失败: $e');
      // 使用默认建议
      setState(() {
        searchSuggestions = [
          'Flutter',
          '前端开发',
          '移动应用',
          '设计模式',
          '编程学习',
          '技术分享',
        ];
      });
    }
  }

  /// 实时搜索（搜索标题和内容）
  Future<void> _performRealTimeSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // 记录搜索开始时间
    _searchStartTime = DateTime.now();
    
    try {
      // 实时搜索：搜索标题和内容，限制结果数量保持响应速度
      final results = await ArticleService.instance.fastSearchArticles(query);
      
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

  void _onResultTap(ArticleDb result) {
    // TODO: 跳转到文章详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('点击了: ${result.title}'),
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showTestMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              '测试功能',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            
            // 创建测试数据按钮
            _buildTestButton(
              '创建测试文章',
              Icons.add_circle_outline,
              Colors.blue,
              () async {
                Navigator.pop(context);
                await _createTestData();
              },
            ),
            
            const SizedBox(height: 12),
            
            // 测试搜索按钮
            _buildTestButton(
              '测试搜索功能',
              Icons.search,
              Colors.green,
              () async {
                Navigator.pop(context);
                await _testSearchFunction();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTestData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在创建测试文章...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // 直接在这里创建测试文章
      final articleService = ArticleService.instance;
      
      // 创建测试文章
      final testArticles = [
        ArticleDb()
          ..title = 'Flutter开发实战指南'
          ..markdown = 'Flutter是Google开发的跨平台移动应用开发框架。本文将详细介绍Flutter的基础知识和实战技巧。'
          ..excerpt = 'Flutter跨平台开发框架介绍'
          ..author = '张三'
          ..url = 'https://example.com/flutter-guide'
          ..domain = 'example.com'
          ..createdAt = DateTime.now(),
        
        ArticleDb()
          ..title = '前端技术趋势分析'
          ..markdown = '随着Web技术的快速发展，前端开发技术也在不断演进。本文分析了当前前端技术的发展趋势。'
          ..excerpt = '前端技术发展趋势分析'
          ..author = '李四'
          ..url = 'https://example.com/frontend-trends'
          ..domain = 'example.com'
          ..createdAt = DateTime.now(),
        
        ArticleDb()
          ..title = '移动应用设计原则'
          ..markdown = '移动应用设计需要考虑用户体验、界面设计和交互设计等多个方面。本文总结了移动应用设计的核心原则。'
          ..excerpt = '移动应用设计核心原则'
          ..author = '王五'
          ..url = 'https://example.com/mobile-design'
          ..domain = 'example.com'
          ..createdAt = DateTime.now(),
      ];
      
      // 保存测试文章
      for (final article in testArticles) {
        await articleService.saveArticle(article);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('测试文章创建成功！'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 重新加载搜索建议
      await _loadSearchSuggestions();
      
    } catch (e) {
      getLogger().e('创建测试数据失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建测试文章失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testSearchFunction() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在测试搜索功能...'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // 直接在这里测试搜索功能
      final articleService = ArticleService.instance;
      
      // 测试搜索关键词
      final searchQueries = ['Flutter', '前端', '设计'];
      
      for (final query in searchQueries) {
        getLogger().i('🔍 搜索关键词: $query');
        
        final results = await articleService.searchArticles(query);
        
        getLogger().i('📊 搜索结果数量: ${results.length}');
        for (final article in results) {
          getLogger().i('  - ${article.title}');
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('搜索功能测试完成，查看控制台日志'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      getLogger().e('测试搜索功能失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('搜索功能测试失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    
    // 如果有markdown内容
    if (article.markdown.isNotEmpty) {
      if (searchQuery.isEmpty) {
        return article.markdown.length > 100 
            ? '${article.markdown.substring(0, 100)}...'
            : article.markdown;
      }
      
      // 提取包含搜索词的相关片段
      return HighlightTextBuilder.extractRelevantContent(
        fullContent: article.markdown,
        searchQuery: searchQuery,
        maxLength: 120,
        contextLength: 40,
      );
    }
    
    return '无内容';
  }
} 
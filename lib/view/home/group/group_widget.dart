import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../route/route_name.dart';
import '../../../db/category/category_db.dart';
import '../../../db/category/category_service.dart';
import 'components/add_category_dialog.dart';
import 'components/group_loading_widget.dart';
import 'components/group_empty_widget.dart';
import 'components/category_item_widget.dart';
import 'components/category_action_sheet.dart';
import 'components/delete_category_dialog.dart';
import 'utils/group_constants.dart';
import 'utils/group_utils.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> 
    with GroupPageBLoC, TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GroupConstants.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // _buildCustomAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: const Color(0xFF007AFF),
                  backgroundColor: Colors.white,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildQuickEntries(),
                      ),
                      SliverToBoxAdapter(
                        child: _buildCustomAppBar(),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: GroupConstants.pagePadding,
                          child: isLoading
                              ? const GroupLoadingWidget()
                              : _buildCategoriesCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickEntries() {
    return Container(
      padding: GroupConstants.appBarPadding,
      child: Row(
        children: [
          Expanded(
            child: _buildQuickEntryItem(
              icon: Icons.library_books_rounded,
              title: '全部',
              subtitle: '所有内容',
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                // 跳转到全部文章列表页面
                context.push('/${RouteName.articleList}?type=all&title=${Uri.encodeComponent('全部文章')}');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickEntryItem(
              icon: Icons.star_rounded,
              title: '重要',
              subtitle: '标记重要',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                // 跳转到重要文章列表页面
                context.push('/${RouteName.articleList}?type=bookmark&title=${Uri.encodeComponent('重要文章')}');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEntryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GroupConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GroupConstants.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: GroupConstants.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GroupConstants.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: GroupConstants.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: GroupConstants.appBarPadding,
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '分组管理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GroupConstants.primaryText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '管理你的内容分类',
                  style: TextStyle(
                    fontSize: 12,
                    color: GroupConstants.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: GroupConstants.primaryGradient,
        borderRadius: BorderRadius.circular(GroupConstants.buttonRadius),
        boxShadow: [GroupConstants.buttonShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GroupConstants.buttonRadius),
          onTap: () {
            _showAddCategoryDialog();
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GroupConstants.cardRadius),
        boxShadow: [GroupConstants.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GroupConstants.cardRadius),
        child: Column(
          children: [
            ..._buildCategoryWidgets(),
          ],
        ),
      ),
    );
  }

  /// 处理下拉刷新
  Future<void> _handleRefresh() async {
    try {
      // 清除所有缓存
      _refreshCategoryCount();
      
      // 重新加载分类数据
      await _loadCategories(forceRefresh: true);
      
      // 显示刷新成功提示
      if (mounted) {
        GroupUtils.showSuccessMessage('刷新成功');
      }
    } catch (e) {
      // 显示刷新失败提示
      if (mounted) {
        GroupUtils.showErrorMessage('刷新失败: $e');
      }
    }
  }
}

mixin GroupPageBLoC on State<GroupPage> {
  final CategoryService _categoryService = CategoryService();
  Map<int?, List<CategoryDb>> _categoriesByParentId = {};
  final Map<int, bool> _expandedState = {};
  final Map<int, AnimationController> _animationControllers = {};
  bool isLoading = true;

  // 数据缓存时间戳，用于智能刷新
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5); // 缓存有效期5分钟

  // 分类文章数量缓存
  final Map<int, int> _categoryCountCache = {};
  DateTime? _countCacheTime;
  static const Duration _countCacheValidDuration = Duration(seconds: 30); // 计数缓存30秒

  // 定时刷新相关
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 启动定时刷新
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(_countCacheValidDuration, (timer) {
      if (mounted) {
        _refreshCategoryCount();
      }
    });
  }

  /// 刷新分类文章数量缓存
  void _refreshCategoryCount() {
    setState(() {
      _categoryCountCache.clear();
      _countCacheTime = null;
    });
  }

  /// 显示添加顶级分类对话框
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddCategoryDialog(
        onConfirm: (name, icon) async {
          await _createCategory(name, icon);
        },
      ),
    );
  }

  /// 显示添加子分类对话框
  void _showAddSubCategoryDialog(CategoryDb parentCategory) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddCategoryDialog(
        parentCategory: parentCategory,
        onConfirm: (name, icon) async {
          await _createSubCategory(parentCategory, name, icon);
        },
      ),
    );
  }

  /// 显示编辑分类对话框
  void _showEditCategoryDialog(CategoryDb category) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddCategoryDialog(
        editCategory: category,
        onConfirm: (name, icon) async {
          await _updateCategory(category, name, icon);
        },
      ),
    );
  }

  /// 创建顶级分类
  Future<void> _createCategory(String name, String icon) async {
    try {
      // 显示加载状态
      setState(() => isLoading = true);

      // 获取当前最大的sortOrder
      final topLevelCategories = _categoriesByParentId[null] ?? [];
      final maxSortOrder = topLevelCategories.isEmpty 
          ? 0 
          : topLevelCategories.map((cat) => cat.sortOrder).reduce((a, b) => a > b ? a : b);

      // 创建新分类
      await _categoryService.createCategory(
        name: name,
        icon: icon,
        sortOrder: maxSortOrder + 1,
      );

      // 强制刷新数据
      await _loadCategories(forceRefresh: true);

      // 显示成功消息
      if (mounted) {
        GroupUtils.showSuccessMessage('分类 "$name" 创建成功');
      }
    } catch (e) {
      setState(() => isLoading = false);
      
      // 显示错误消息
      if (mounted) {
        GroupUtils.showErrorMessage('创建分类失败: $e');
      }
    }
  }

  /// 创建子分类
  Future<void> _createSubCategory(CategoryDb parentCategory, String name, String icon) async {
    try {
      // 显示加载状态
      setState(() => isLoading = true);

      // 获取当前父分类下最大的sortOrder
      final siblingCategories = _categoriesByParentId[parentCategory.id] ?? [];
      final maxSortOrder = siblingCategories.isEmpty 
          ? 0 
          : siblingCategories.map((cat) => cat.sortOrder).reduce((a, b) => a > b ? a : b);

      // 创建新子分类
      await _categoryService.createCategory(
        name: name,
        icon: icon,
        parentId: parentCategory.id,
        sortOrder: maxSortOrder + 1,
      );

      // 强制刷新数据
      await _loadCategories(forceRefresh: true);

      // 自动展开父分类
      _expandParentCategory(parentCategory);

      // 显示成功消息
      if (mounted) {
        GroupUtils.showSuccessMessage('子分类 "$name" 创建成功');
      }
    } catch (e) {
      setState(() => isLoading = false);
      
      // 显示错误消息
      if (mounted) {
        GroupUtils.showErrorMessage('创建子分类失败: $e');
      }
    }
  }

  /// 自动展开父分类
  void _expandParentCategory(CategoryDb parentCategory) {
    setState(() {
      _expandedState[parentCategory.id] = true;
    });
    
    // 创建动画控制器并播放展开动画
    if (_animationControllers[parentCategory.id] == null) {
      _animationControllers[parentCategory.id] = AnimationController(
        duration: GroupConstants.expandAnimationDuration,
        vsync: this as TickerProvider,
      );
    }
    _animationControllers[parentCategory.id]!.forward();
  }

  /// 更新分类
  Future<void> _updateCategory(CategoryDb category, String name, String icon) async {
    try {
      // 显示加载状态
      setState(() => isLoading = true);

      // 更新分类信息
      category.name = name;
      category.icon = icon;
      category.updatedAt = DateTime.now();

      // 调用服务更新数据库
      final success = await _categoryService.updateCategory(category);
      
      if (!success) {
        throw Exception('更新分类失败');
      }

      // 强制刷新数据
      await _loadCategories(forceRefresh: true);

      // 显示成功消息
      if (mounted) {
        GroupUtils.showSuccessMessage('分类 "$name" 更新成功');
      }
    } catch (e) {
      setState(() => isLoading = false);
      
      // 显示错误消息
      if (mounted) {
        GroupUtils.showErrorMessage('更新分类失败: $e');
      }
    }
  }

  /// 显示删除分类确认对话框
  Future<void> _showDeleteCategoryDialog(CategoryDb category) async {
    try {
      // 获取该分类下的文章数量
      final articleCount = await _categoryService.getArticleCountByCategory(category.id);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DeleteCategoryDialog(
          category: category,
          articleCount: articleCount,
          onConfirm: () async {
            await _deleteCategory(category);
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        GroupUtils.showErrorMessage('获取分类信息失败: $e');
      }
    }
  }

  /// 删除分类
  Future<void> _deleteCategory(CategoryDb category) async {
    try {
      // 显示加载状态
      setState(() => isLoading = true);

      // 调用删除分类的服务方法
      final success = await _categoryService.deleteCategoryWithArticleHandling(
        category.id,
        moveArticlesToUncategorized: true,
      );

      if (success) {
        // 强制刷新数据
        await _loadCategories(forceRefresh: true);

        // 显示成功消息
        if (mounted) {
          GroupUtils.showSuccessMessage('分类 "${category.name}" 删除成功');
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      
      // 显示错误消息
      if (mounted) {
        GroupUtils.showErrorMessage('删除分类失败: $e');
      }
    }
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    // 如果不是强制刷新且缓存仍然有效，则跳过加载
    if (!forceRefresh && _lastLoadTime != null) {
      final cacheAge = DateTime.now().difference(_lastLoadTime!);
      if (cacheAge < _cacheValidDuration) {
        print('📁 使用缓存数据，缓存时间: ${cacheAge.inMinutes}分钟');
        return;
      }
    }

    setState(() => isLoading = true);
    var allCategories = await _categoryService.getAllCategories();

    if (allCategories.isEmpty) {
      await _createSampleData();
      allCategories = await _categoryService.getAllCategories();
    }
    
    _categoriesByParentId = {};
    for (var cat in allCategories) {
      (_categoriesByParentId[cat.parentId] ??= []).add(cat);
    }

    _categoriesByParentId.forEach((key, value) {
      value.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });

    setState(() {
      isLoading = false;
      _lastLoadTime = DateTime.now(); // 更新缓存时间
    });
  }

  Future<void> _createSampleData() async {
    final mobile = await _categoryService.createCategory(name: '默认分组', icon: '👋');
    // await _categoryService.createCategory(name: 'Flutter', icon: '🐦', parentId: mobile.id);
    // await _categoryService.createCategory(name: 'React Native', icon: '⚛️', parentId: mobile.id, sortOrder: 1);
    // await _categoryService.createCategory(name: '空军建军节', icon: '📄', sortOrder: 1);
    // await _categoryService.createCategory(name: '紧急集合', icon: '📄', sortOrder: 2);
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      _expandedState[categoryId] = !(_expandedState[categoryId] ?? false);
    });

    // 创建动画控制器
    if (_animationControllers[categoryId] == null) {
      _animationControllers[categoryId] = AnimationController(
        duration: GroupConstants.expandAnimationDuration,
        vsync: this as TickerProvider,
      );
    }

    final controller = _animationControllers[categoryId]!;
    if (_expandedState[categoryId] ?? false) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  
  List<CategoryDb> _getVisibleCategories() {
    final List<CategoryDb> visible = [];
    final topLevelCategories = _categoriesByParentId[null] ?? [];

    for (final category in topLevelCategories) {
      visible.add(category);
      if (_expandedState[category.id] ?? false) {
        final children = _categoriesByParentId[category.id] ?? [];
        visible.addAll(children);
      }
    }
    return visible;
  }

  List<Widget> _buildCategoryWidgets() {
    final visibleCategories = _getVisibleCategories();
    if (visibleCategories.isEmpty) {
      return [const GroupEmptyWidget()];
    }

    final List<Widget> widgets = [];
    for (int i = 0; i < visibleCategories.length; i++) {
      final category = visibleCategories[i];
      final hasChildren = (_categoriesByParentId[category.id] ?? []).isNotEmpty;
      final isExpanded = _expandedState[category.id] ?? false;

      widgets.add(
        CategoryItemWidget(
          category: category,
          hasChildren: hasChildren,
          isExpanded: isExpanded,
          getCategoryItemCount: _getCategoryItemCount,
          onTap: () => _handleCategoryTap(category),
          onExpandTap: () => _toggleCategory(category.id),
          onMoreTap: () => _showMoreActions(context, category),
        ),
      );

      if (i < visibleCategories.length - 1) {
        final nextCategory = visibleCategories[i+1];
        if (nextCategory.level <= category.level) {
          widgets.add(GroupUtils.buildDivider(category.level));
        }
      }
    }
    return widgets;
  }

  void _handleCategoryTap(CategoryDb category) {
    // 导航到分类文章列表页
    context.push('/${RouteName.articleList}?type=category&title=${Uri.encodeComponent(category.name)}&categoryId=${category.id}&categoryName=${Uri.encodeComponent(category.name)}');
  }

  Future<int> _getCategoryItemCount(int categoryId) async {
    // 检查缓存是否有效
    if (_categoryCountCache.containsKey(categoryId) && _isCacheValid()) {
      return _categoryCountCache[categoryId]!;
    }

    try {
      // 获取分类信息，判断是否有子分类
      final hasChildren = (_categoriesByParentId[categoryId] ?? []).isNotEmpty;
      
      int totalCount;
      if (hasChildren) {
        // 如果有子分类，计算包含所有子分类的文章总数
        totalCount = await _calculateTotalArticleCount(categoryId);
      } else {
        // 如果没有子分类，只获取直接文章数量
        totalCount = await _categoryService.getArticleCountByCategory(categoryId);
      }
      
      // 更新缓存
      _categoryCountCache[categoryId] = totalCount;
      _countCacheTime = DateTime.now();
      
      return totalCount;
    } catch (e) {
      // 查询失败时返回缓存值或0
      return _categoryCountCache[categoryId] ?? 0;
    }
  }

  /// 计算分类及其所有子分类的文章总数
  Future<int> _calculateTotalArticleCount(int categoryId) async {
    // 获取该分类及其所有子分类的ID列表
    final allCategoryIds = _getAllChildCategoryIds(categoryId);
    allCategoryIds.insert(0, categoryId); // 包含自己
    
    // 批量获取所有分类的直接文章数量
    final countMap = await _categoryService.getBatchArticleCountsByCategories(allCategoryIds);
    
    // 计算总数
    int totalCount = 0;
    for (final id in allCategoryIds) {
      totalCount += countMap[id] ?? 0;
    }
    
    return totalCount;
  }

  /// 获取分类的所有子分类ID（包括嵌套子分类）
  List<int> _getAllChildCategoryIds(int categoryId) {
    final List<int> allChildIds = [];
    
    void collectChildren(int parentId) {
      final children = _categoriesByParentId[parentId] ?? [];
      for (final child in children) {
        allChildIds.add(child.id);
        collectChildren(child.id); // 递归收集子分类
      }
    }
    
    collectChildren(categoryId);
    return allChildIds;
  }

  /// 检查计数缓存是否有效
  bool _isCacheValid() {
    if (_countCacheTime == null) return false;
    return DateTime.now().difference(_countCacheTime!) < _countCacheValidDuration;
  }

  void _showMoreActions(BuildContext context, CategoryDb category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CategoryActionSheet(
        category: category,
        onAddSubCategory: () => _showAddSubCategoryDialog(category),
        onEdit: () => _showEditCategoryDialog(category),
        onDelete: () => _showDeleteCategoryDialog(category),
      ),
    );
  }
}

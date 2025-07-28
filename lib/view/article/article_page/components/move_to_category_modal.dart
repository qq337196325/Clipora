// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../db/article/service/article_service.dart';
import '/basics/logger.dart';
import '/db/category/category_db.dart';
import '/db/category/category_service.dart';

class MoveToCategoryModal extends StatefulWidget { 
  final int articleId;

  const MoveToCategoryModal({super.key, required this.articleId});

  @override
  State<MoveToCategoryModal> createState() => _MoveToCategoryModalState();
}

class _MoveToCategoryModalState extends State<MoveToCategoryModal> {
  final CategoryService _categoryService = CategoryService();
  final ArticleService _articleService = ArticleService.instance;
  Map<int?, List<CategoryDb>> _categoriesByParentId = {};
  bool _isLoading = true;
  CategoryDb? _currentCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final article = await _articleService.getArticleById(widget.articleId);
      if (article != null) {
        await article.category.load();
      }

      var allCategories = await _categoryService.getAllCategories();
      _categoriesByParentId = {};
      for (var cat in allCategories) {
        (_categoriesByParentId[cat.parentId] ??= []).add(cat);
      }
      _categoriesByParentId.forEach((key, value) {
        value.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      });

      if (mounted) {
        setState(() {
          _currentCategory = article?.category.value;
          _isLoading = false;
        });
      }
    } catch (e) {
      BotToast.showText(text: "${'i18n_article_加载分类失败'.tr}$e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _moveArticleToCategory(CategoryDb? category) async {
    try {
      final categoryName = category?.name ?? 'i18n_article_未分类'.tr;
      getLogger().i("开始移动文章到分类: $categoryName");
      
      final article = await _articleService.getArticleById(widget.articleId);
      if (article != null) {
        getLogger().i("找到文章: ${article.title}");
        
        // 使用ArticleService提供的专门方法来更新分类关系
        await _articleService.updateArticleCategory(widget.articleId, category);
        
        getLogger().i("文章分类更新完成");

        if (mounted) {
          // Pop the modal
          Navigator.of(context).pop();
          BotToast.showText(text: "${'i18n_article_成功移动到'.tr}$categoryName");
        }
      } else {
        getLogger().w("未找到文章，ID: ${widget.articleId}");
        BotToast.showText(text: 'i18n_article_未找到文章'.tr);
      }
    } catch (e) {
      getLogger().e("移动失败: ${e.toString()}"); 
      BotToast.showText(text: "${'i18n_article_移动失败'.tr}${e.toString()}");
    }
  }

  List<Widget> _buildCategoryList(BuildContext context) {
    final List<Widget> widgets = [];
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    void buildCategoryWidgets(List<CategoryDb> categories, int level) {
      for (var category in categories) {
        final isSelected = _currentCategory?.id == category.id;
        widgets.add(
          _buildCategoryTile(
            context: context,
            title: category.name,
            icon: Text(category.icon ?? '📁', style: const TextStyle(fontSize: 22)),
            level: level,
            isSelected: isSelected,
            onTap: () => _moveArticleToCategory(category),
          )
        );

        final children = _categoriesByParentId[category.id] ?? [];
        if (children.isNotEmpty) {
          buildCategoryWidgets(children, level + 1);
        }
      }
    }
    
    // "Uncategorized" option
    final isUncategorized = _currentCategory == null;
     widgets.add(
      _buildCategoryTile(
        context: context,
        title: 'i18n_article_设为未分类'.tr,
        icon: Icon(Icons.folder_off_outlined, color: isUncategorized ? selectedColor: theme.iconTheme.color),
        level: 0,
        isSelected: isUncategorized,
        onTap: () => _moveArticleToCategory(null),
      )
    );

    final topLevelCategories = _categoriesByParentId[null] ?? [];
    buildCategoryWidgets(topLevelCategories, 0);
    return widgets;
  }
  
  Widget _buildCategoryTile({
    required BuildContext context,
    required String title,
    required Widget icon,
    required int level,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final selectedBackgroundColor = selectedColor.withOpacity(0.1);

    return Material(
      color: isSelected ? selectedBackgroundColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0 + level * 20.0,
            right: 16.0,
            top: 12.0,
            bottom: 12.0,
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? selectedColor : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: selectedColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'i18n_article_移动到分组'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color?.withOpacity(0.7)),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            // const Divider(height: 1),
            // Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildCategoryList(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 

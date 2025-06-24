import 'package:isar/isar.dart';
import 'package:get/get.dart';

import 'category_db.dart';
import '../database_service.dart';
import '../article/article_db.dart';
import '../../basics/logger.dart';

/// 分类服务类
class CategoryService extends GetxService {
  static CategoryService get instance => Get.find<CategoryService>();

  /// 获取数据库实例
  DatabaseService get _dbService => DatabaseService.instance;

  /// 确保数据库已初始化
  Future<void> _ensureDatabaseInitialized() async {
    if (!_dbService.isInitialized) {
      getLogger().i('⏳ 等待数据库初始化...');
    }
  }

  /// 创建分类
  Future<CategoryDb> createCategory({
    required String name,
    String? description,
    String? icon,
    String? color,
    int? parentId,
    int sortOrder = 0,
  }) async {
    await _ensureDatabaseInitialized();

    try {
      getLogger().i('📁 创建分类: $name');

      final category = CategoryDb()
        ..name = name
        ..description = description
        ..icon = icon
        ..color = color
        ..parentId = parentId
        ..sortOrder = sortOrder
        ..isEnabled = true;

      // 计算层级和路径
      if (parentId != null) {
        final parent = await getCategoryById(parentId);
        if (parent != null) {
          category.level = parent.level + 1;
          category.path = parent.path.isEmpty ? '$parentId' : '${parent.path}/$parentId';
        }
      } else {
        category.level = 0;
        category.path = '';
      }

      await _dbService.isar.writeTxn(() async {
        await _dbService.categories.put(category);
      });

      getLogger().i('✅ 分类创建成功，ID: ${category.id}');
      return category;
    } catch (e) {
      getLogger().e('❌ 创建分类失败: $e');
      rethrow;
    }
  }

  /// 更新分类
  Future<bool> updateCategory(CategoryDb category) async {
    await _ensureDatabaseInitialized();

    try {
      getLogger().i('📝 更新分类: ${category.name}');

      category.updatedAt = DateTime.now();

      await _dbService.isar.writeTxn(() async {
        await _dbService.categories.put(category);
      });

      getLogger().i('✅ 分类更新成功');
      return true;
    } catch (e) {
      getLogger().e('❌ 更新分类失败: $e');
      return false;
    }
  }

  /// 删除分类并处理文章关联关系
  Future<bool> deleteCategoryWithArticleHandling(
    int categoryId, {
    bool moveArticlesToUncategorized = true,
  }) async {
    await _ensureDatabaseInitialized();

    try {
      final category = await getCategoryById(categoryId);
      if (category == null) {
        getLogger().w('⚠️ 分类不存在: $categoryId');
        return false;
      }

      getLogger().i('🗑️ 删除分类并处理文章: ${category.name}');

      // 检查是否有子分类
      final children = await getChildCategories(categoryId);
      if (children.isNotEmpty) {
        getLogger().w('⚠️ 分类下有子分类，无法删除: ${category.name}');
        throw Exception('该分类下还有子分类，请先删除子分类');
      }

      // 获取该分类下的所有文章
      final articlesInCategory = await _dbService.articles
          .where()
          .filter()
          .category((q) => q.idEqualTo(categoryId))
          .findAll();

      // 在事务中处理删除操作
      await _dbService.isar.writeTxn(() async {
        // 如果需要将文章移到未分类状态
        if (moveArticlesToUncategorized && articlesInCategory.isNotEmpty) {
          getLogger().i('📄 将 ${articlesInCategory.length} 篇文章移到未分类状态');
          
          for (final article in articlesInCategory) {
            // 取消文章与分类的关联
            await article.category.reset();
            article.updatedAt = DateTime.now();
            await _dbService.articles.put(article);
          }
        }

        // 删除分类
        await _dbService.categories.delete(categoryId);
      });

      getLogger().i('✅ 分类删除成功，${articlesInCategory.length} 篇文章已移到未分类');
      return true;
    } catch (e) {
      getLogger().e('❌ 删除分类失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取分类
  Future<CategoryDb?> getCategoryById(int id) async {
    await _ensureDatabaseInitialized();
    return await _dbService.categories.get(id);
  }

  /// 获取所有分类
  Future<List<CategoryDb>> getAllCategories({bool includeDisabled = false}) async {
    await _ensureDatabaseInitialized();

    final query = _dbService.categories.where();
    if (!includeDisabled) {
      return await query.filter().isEnabledEqualTo(true).findAll();
    }
    return await query.findAll();
  }

  /// 获取根分类（顶级分类）
  Future<List<CategoryDb>> getRootCategories() async {
    await _ensureDatabaseInitialized();

    return await _dbService.categories
        .where()
        .filter()
        .parentIdIsNull()
        .and()
        .isEnabledEqualTo(true)
        .sortBySortOrder()
        .thenByName()
        .findAll();
  }

  /// 获取子分类
  Future<List<CategoryDb>> getChildCategories(int parentId) async {
    await _ensureDatabaseInitialized();

    return await _dbService.categories
        .where()
        .filter()
        .parentIdEqualTo(parentId)
        .and()
        .isEnabledEqualTo(true)
        .sortBySortOrder()
        .thenByName()
        .findAll();
  }

  /// 获取分类树
  Future<List<CategoryTreeNode>> getCategoryTree() async {
    final allCategories = await getAllCategories();
    final rootCategories = allCategories.where((cat) => cat.parentId == null).toList();

    Future<CategoryTreeNode> buildNode(CategoryDb category) async {
      final children = allCategories.where((cat) => cat.parentId == category.id).toList();
      final childNodes = await Future.wait(children.map(buildNode));
      final articleCount = await getArticleCountByCategory(category.id);

      return CategoryTreeNode(
        category: category,
        children: childNodes,
        articleCount: articleCount,
      );
    }

    return await Future.wait(rootCategories.map(buildNode));
  }

  /// 获取分类的文章数量
  Future<int> getArticleCountByCategory(int categoryId) async {
    await _ensureDatabaseInitialized();

    final category = await getCategoryById(categoryId);
    if (category == null) return 0;

    return await category.articles.count();
  }

  /// 批量获取多个分类的文章数量
  Future<Map<int, int>> getBatchArticleCountsByCategories(List<int> categoryIds) async {
    await _ensureDatabaseInitialized();

    final Map<int, int> result = {};
    
    for (final categoryId in categoryIds) {
      final count = await getArticleCountByCategory(categoryId);
      result[categoryId] = count;
    }
    
    return result;
  }

  /// 获取分类统计信息
  Future<CategoryStats> getCategoryStats(int categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category == null) {
      throw Exception('分类不存在: $categoryId');
    }

    final directArticleCount = await getArticleCountByCategory(categoryId);
    final childCategories = await getChildCategories(categoryId);
    
    int totalArticleCount = directArticleCount;
    for (final child in childCategories) {
      final childStats = await getCategoryStats(child.id);
      totalArticleCount += childStats.totalArticleCount;
    }

    return CategoryStats(
      category: category,
      directArticleCount: directArticleCount,
      totalArticleCount: totalArticleCount,
      childCategoryCount: childCategories.length,
    );
  }

  /// 移动分类到新的父分类下
  Future<bool> moveCategory(int categoryId, int? newParentId) async {
    await _ensureDatabaseInitialized();

    try {
      final category = await getCategoryById(categoryId);
      if (category == null) return false;

      // 检查是否会形成循环引用
      if (newParentId != null) {
        final newParent = await getCategoryById(newParentId);
        if (newParent == null) return false;

        // 检查新父分类是否是当前分类的后代
        final allCategories = await getAllCategories();
        final childIds = category.getAllChildIds(allCategories);
        if (childIds.contains(newParentId)) {
          getLogger().w('⚠️ 无法移动，会形成循环引用');
          return false;
        }
      }

      getLogger().i('📦 移动分类: ${category.name}');

      // 更新分类信息
      category.parentId = newParentId;
      
      if (newParentId != null) {
        final newParent = await getCategoryById(newParentId);
        if (newParent != null) {
          category.level = newParent.level + 1;
          category.path = newParent.path.isEmpty ? '$newParentId' : '${newParent.path}/$newParentId';
        }
      } else {
        category.level = 0;
        category.path = '';
      }

      await updateCategory(category);

      // 递归更新所有子分类的层级和路径
      await _updateChildrenLevelAndPath(categoryId);

      getLogger().i('✅ 分类移动成功');
      return true;
    } catch (e) {
      getLogger().e('❌ 移动分类失败: $e');
      return false;
    }
  }

  /// 递归更新子分类的层级和路径
  Future<void> _updateChildrenLevelAndPath(int parentId) async {
    final children = await getChildCategories(parentId);
    final parent = await getCategoryById(parentId);
    if (parent == null) return;

    for (final child in children) {
      child.level = parent.level + 1;
      child.path = parent.path.isEmpty ? '$parentId' : '${parent.path}/$parentId';
      await updateCategory(child);
      
      // 递归更新子分类的子分类
      await _updateChildrenLevelAndPath(child.id);
    }
  }

  /// 更新分类的文章数量缓存
  Future<void> updateCategoryArticleCount() async {
    final allCategories = await getAllCategories();

    for (final category in allCategories) {
      final directCount = await getArticleCountByCategory(category.id);
      
      // 计算包含子分类的总文章数
      int totalCount = directCount;
      final childIds = category.getAllChildIds(allCategories);
      for (final childId in childIds) {
        totalCount += await getArticleCountByCategory(childId);
      }

      category.articleCount = directCount;
      category.totalArticleCount = totalCount;
      await updateCategory(category);
    }
  }

  /// 根据名称搜索分类
  Future<List<CategoryDb>> searchCategories(String keyword) async {
    await _ensureDatabaseInitialized();

    return await _dbService.categories
        .where()
        .filter()
        .nameContains(keyword, caseSensitive: false)
        .and()
        .isEnabledEqualTo(true)
        .findAll();
  }

  /// 获取分类的面包屑导航
  Future<List<CategoryDb>> getBreadcrumb(int categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category == null) return [];

    final allCategories = await getAllCategories();
    return category.getParentChain(allCategories);
  }

  /// 批量创建默认分类
  Future<void> createDefaultCategories() async {
    getLogger().i('📚 创建默认分类...');

    try {
      // 检查是否已有分类
      final existingCategories = await getAllCategories();
      if (existingCategories.isNotEmpty) {
        getLogger().i('⚠️ 已存在分类，跳过创建默认分类');
        return;
      }

      // 创建默认分类结构
      final techCategory = await createCategory(
        name: '技术',
        description: '技术相关文章',
        icon: 'code',
        color: '#2196F3',
        sortOrder: 1,
      );

      final lifeCategory = await createCategory(
        name: '生活',
        description: '生活相关文章',
        icon: 'home',
        color: '#4CAF50',
        sortOrder: 2,
      );

      final workCategory = await createCategory(
        name: '工作',
        description: '工作相关文章',
        icon: 'work',
        color: '#FF9800',
        sortOrder: 3,
      );

      // 创建技术子分类
      await createCategory(
        name: '前端开发',
        description: '前端技术相关',
        parentId: techCategory.id,
        sortOrder: 1,
      );

      await createCategory(
        name: '后端开发',
        description: '后端技术相关',
        parentId: techCategory.id,
        sortOrder: 2,
      );

      await createCategory(
        name: '移动开发',
        description: '移动端开发技术',
        parentId: techCategory.id,
        sortOrder: 3,
      );

      getLogger().i('✅ 默认分类创建完成');
    } catch (e) {
      getLogger().e('❌ 创建默认分类失败: $e');
    }
  }

  Future<void> createSampleCategories() async {
    await _ensureDatabaseInitialized();
    final hasData = await _dbService.categories.count() > 0;
    if (hasData) {
      getLogger().i('Sample categories already exist.');
      return;
    }

    getLogger().i('Creating sample categories...');
    await _dbService.isar.writeTxn(() async {
      final mobile = CategoryDb()
        ..name = '从移动端开始吧'
        ..icon = '👋'
        ..sortOrder = 0
        ..level = 0;
      await _dbService.categories.put(mobile);

      final flutter = CategoryDb()
        ..name = 'Flutter'
        ..icon = '🐦'
        ..sortOrder = 0
        ..level = 1
        ..parentId = mobile.id;
      await _dbService.categories.put(flutter);

      final reactNative = CategoryDb()
        ..name = 'React Native'
        ..icon = '⚛️'
        ..sortOrder = 1
        ..level = 1
        ..parentId = mobile.id;
      await _dbService.categories.put(reactNative);

      final airforce = CategoryDb()
        ..name = '空军建军节'
        ..icon = '📄'
        ..sortOrder = 1
        ..level = 0;
      await _dbService.categories.put(airforce);

      final emergency = CategoryDb()
        ..name = '紧急集合'
        ..icon = '📄'
        ..sortOrder = 2
        ..level = 0;
      await _dbService.categories.put(emergency);
    });
    getLogger().i('✅ Sample categories created.');
  }
} 
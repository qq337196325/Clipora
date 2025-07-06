import 'package:isar/isar.dart';
import 'package:get/get.dart';

import '../../basics/ui.dart';
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
        ..updateTimestamp = getStorageServiceCurrentTime()
        ..isEnabled = true; // getStorageServiceCurrentTime()


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
      category.updateTimestamp = getStorageServiceCurrentTimeAdding();

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
            category.updateTimestamp = getStorageServiceCurrentTimeAdding();
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









} 
import 'package:isar/isar.dart';
import '../article/article_db.dart';

part 'category_db.g.dart';

@collection
class CategoryDb {
  Id id = Isar.autoIncrement;
  @Index() String userId = "";
  @Index() String? serverId; /// 服务器端ID（同步后存储）


  /// 历史：新建分类的时候，客户端没有服务端ID，客户端同步数据的时候又是以服务端ID判断本地是否存在，判断的时候本地数据一直不存在，所以一直是新增
  @Index() String uuid = ""; /// 服务端与客户端新建数据的时候都必须要有UUID,作为数据同步识别

  @Index(unique: false, caseSensitive: false) late String name; /// 分类名称
  String? description;   /// 分类描述

  /// 分类图标
  String? icon;

  /// 分类颜色（十六进制色值，如 #FF5722）
  String? color;

  /// 排序权重（数字越小越靠前）
  @Index()
  int sortOrder = 0;

  /// 是否启用（软删除）
  @Index()
  bool isEnabled = true;

  /// 父分类ID（为null表示顶级分类）
  @Index()
  int? parentId;

  /// 父分类服务器ID
  String? parentServerId;

  /// 分类层级（0=顶级，1=二级，2=三级...）
  @Index()
  int level = 0;

  /// 分类路径（如：1/3/5，便于查询所有子分类）
  @Index()
  String path = '';

  // /// 文章数量缓存（避免实时计算）
  // int articleCount = 0;
  //
  // /// 总文章数量（包含子分类的文章数量）
  // int totalArticleCount = 0;

  /// 最后修改时间戳（用于同步判断）
  @Index()
  int lastModified = 0;

  /// 设备ID（标识最后修改的设备）
  String? deviceId;

  /// 是否已同步到服务器
  @Index()
  bool isSynced = false;

  /// 是否已删除（软删除标记）
  @Index()
  bool isDeleted = false;

  /// 反向链接：属于此分类的文章
  @Backlink(to: 'category')
  final articles = IsarLinks<ArticleDb>();

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();
  DateTime? deletedAt;                         // 删除日期

  /// 版本号（用于冲突解决）
  @Index() int version = 1;
  @Index() int updateTimestamp = 0;

  /// 获取分类的完整路径名称（如：技术 > 前端 > Vue）
  String getFullPath(List<CategoryDb> allCategories) {
    if (parentId == null) {
      return name;
    }
    
    final parent = allCategories.firstWhere(
      (cat) => cat.id == parentId,
      orElse: () => CategoryDb()..name = '未知',
    );
    
    return '${parent.getFullPath(allCategories)} > $name';
  }

  /// 判断是否为根分类
  bool get isRoot => parentId == null;

  /// 判断是否为叶子分类（没有子分类）
  bool isLeaf(List<CategoryDb> allCategories) {
    return !allCategories.any((cat) => cat.parentId == id);
  }

  /// 获取所有子分类ID（包括嵌套子分类）
  List<int> getAllChildIds(List<CategoryDb> allCategories) {
    final List<int> childIds = [];
    
    void findChildren(int currentId) {
      for (final cat in allCategories) {
        if (cat.parentId == currentId) {
          childIds.add(cat.id);
          findChildren(cat.id); // 递归查找
        }
      }
    }
    
    findChildren(id);
    return childIds;
  }

  /// 获取直接子分类
  List<CategoryDb> getDirectChildren(List<CategoryDb> allCategories) {
    return allCategories.where((cat) => cat.parentId == id).toList();
  }

  /// 获取父分类链（从根到当前分类）
  List<CategoryDb> getParentChain(List<CategoryDb> allCategories) {
    final List<CategoryDb> chain = [];
    CategoryDb? current = this;
    
    while (current != null) {
      chain.insert(0, current);
      if (current.parentId == null) break;
      
      current = allCategories.firstWhere(
        (cat) => cat.id == current!.parentId,
        orElse: () => CategoryDb()..name = '未知',
      );
      
      if (current.name == '未知') break;
    }
    
    return chain;
  }

  @override
  String toString() {
    return 'CategoryDb{id: $id, name: $name, level: $level, parentId: $parentId, serverId: $serverId, isSynced: $isSynced}';
  }
}

/// 分类统计信息
class CategoryStats {
  final CategoryDb category;
  final int directArticleCount;    // 直接属于此分类的文章数
  final int totalArticleCount;     // 包含子分类的总文章数
  final int childCategoryCount;    // 子分类数量

  CategoryStats({
    required this.category,
    required this.directArticleCount,
    required this.totalArticleCount,
    required this.childCategoryCount,
  });
}

/// 分类树节点
class CategoryTreeNode {
  final CategoryDb category;
  final List<CategoryTreeNode> children;
  final int articleCount;

  CategoryTreeNode({
    required this.category,
    this.children = const [],
    this.articleCount = 0,
  });
} 
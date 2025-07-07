import 'package:isar/isar.dart';
import '../tag/tag_db.dart';
import '../category/category_db.dart';

part 'article_db.g.dart'; // 用于代码生成

@collection
class ArticleDb {

  // 客户端数据有个问题，如果是登录不同账号的时候应该怎么处理数据；【前期可以预留相关的字段，暂时不处理功能】

  Id id = Isar.autoIncrement;
  @Index() String serviceId = "";              // 对应服务端ID
  
  @Index() String title = "";
  String? excerpt;                  // 摘要/简介
  String? content;

  /// 标签
  final tags = IsarLinks<TagDb>();

  /// 文章分类关联
  final category = IsarLink<CategoryDb>();

  String url = "";
  @Index() String userId = "";
  @Index() String domain = "";                 // 域名
  @Index() String author = "";                 // 作者
  @Index() DateTime? articleDate;              // 文章日期 - 第三方平台创建日期
  
  @Index() bool isCreateService = false;       // 是否在服务端添加
  @Index() bool isGenerateMhtml = false;       // 是否生成了Mhtml文件
  String mhtmlPath = "";                       // mhtml快照路径【因为跨平台、这个要考虑下怎么保存】
  @Index() bool isGenerateMarkdown = false;    // 是否生成了Markdown文档
  int markdownStatus = 0;                      // markdown状态    0=待生成  1=已生成   2=生成失败     3=正在生成
  DateTime? markdownProcessingStartTime;       // markdown开始处理时间（状态为3时记录）
  String shareOriginalContent = "";            // 分享接收到的原始内容

  // 用户行为数据
  int isRead = 0;                 // 是否阅读   0=未读    1= 已读
  int readCount = 0;              // 阅读次数
  int readDuration = 0;           // 阅读时长(秒)
  double readProgress = 0.0;      // 阅读进度(0-1)
  DateTime? lastReadTime;         // 最后阅读时间
  
  // 阅读会话信息
  String readingSessionId = "";   // 阅读会话ID(用于区分不同的阅读会话)
  int readingStartTime = 0;       // 本次阅读开始时间戳

  // 文章状态管理
  @Index() bool isArchived = false;            // 是否归档
  @Index() bool isImportant = false;           // 是否标为重要
  DateTime? deletedAt;                         // 删除日期

  int serviceUpdatedAt = 0;

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();

  /// 版本号（用于冲突解决）
  @Index() int version = 1;
  @Index() int updateTimestamp = 0;

  /// 将 ArticleDb 对象转换为可以被 jsonEncode 的 Map
  Map<String, dynamic> toJson() {
    return {
      // Isar 本地 id 不需要同步
      // 'id': id, 
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'url': url,
      'domain': domain,
      'author': author,
      'articleDate': articleDate?.toIso8601String(),
      'isCreateService': isCreateService,
      'isGenerateMhtml': isGenerateMhtml,
      'mhtmlPath': mhtmlPath,
      'isGenerateMarkdown': isGenerateMarkdown,
      'markdownProcessingStartTime': markdownProcessingStartTime?.toIso8601String(),
      'shareOriginalContent': shareOriginalContent,
      'serviceId': serviceId,
      'isRead': isRead,
      'readCount': readCount,
      'readDuration': readDuration,
      'readProgress': readProgress,
      'lastReadTime': lastReadTime?.toIso8601String(),
      'readingSessionId': readingSessionId,
      'readingStartTime': readingStartTime,
      'isArchived': isArchived,
      'isImportant': isImportant,
      'deletedAt': deletedAt?.toIso8601String(),
      'serviceUpdatedAt': serviceUpdatedAt,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// 每次新增或修改模型后，一定要重新运行代码生成命令：
// flutter pub run build_runner build --delete-conflicting-outputs
// import 'package:isar/isar.dart';  // 记得在文件中插入
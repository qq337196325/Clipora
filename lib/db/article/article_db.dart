import 'package:isar/isar.dart';

part 'article_db.g.dart'; // 用于代码生成

@collection
class ArticleDb {

  Id id = Isar.autoIncrement;

  // 客户端数据有个问题，如果是登录不同账号的时候应该怎么处理数据；【前期可以预留相关的字段，暂时不处理功能】

  
  @Index() late String title;
  String? excerpt;          // 摘要/简介
  String? content;
  @Index() List<String> tags = [];


  String url = "";
  String mhtmlPath = "";              // mhtml快照路径【因为跨平台、这个要考虑下怎么保存】
  String markdown = "";               // Markdown文档
  String shareOriginalContent = "";   // 分享接收到的原始内容
  String serviceId = ""; 

  // 用户行为数据
  int isRead = 0;            // 是否阅读   0=未读    1= 已读
  int readCount = 0;         // 阅读次数
  int readDuration = 0;      // 阅读时长(秒)
  double readProgress = 0.0; // 阅读进度(0-1)

  int serviceUpdatedAt = 0;

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();
}


// | 类型             | 建议用途          |
// | -------------- | ------------- |
// | `String`       | 标题、内容、链接等文本   |
// | `int`/`double` | 计数、数值评分、价格等   |
// | `DateTime`     | 时间戳、创建时间、到期时间 |
// | `bool`         | 标记状态（是否已读等）   |
// | `List<String>` | 标签、关键词        |

// 每次新增或修改模型后，一定要重新运行代码生成命令：
// flutter pub run build_runner build --delete-conflicting-outputs
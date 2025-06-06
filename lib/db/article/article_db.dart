import 'package:isar/isar.dart';

part 'article_db.g.dart'; // 用于代码生成

@collection
class ArticleDb {

  Id id = Isar.autoIncrement;

  
  @Index() late String title;
  String? url;
  String? excerpt;          // 摘要/简介
  String? content;
  @Index() List<String> tags = []; 

  // 用户行为数据
  int readCount = 0;        // 阅读次数
  int readDuration = 0;     // 阅读时长(秒)
  double readProgress = 0.0; // 阅读进度(0-1)


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
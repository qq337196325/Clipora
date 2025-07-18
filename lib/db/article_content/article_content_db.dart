import 'package:isar/isar.dart';

part 'article_content_db.g.dart'; // 用于代码生成

@collection
class ArticleContentDb {

  Id id = Isar.autoIncrement;
  @Index() String serviceId = "";                          // 服务端ID

  // 关联文章
  @Index() int articleId = 0;
  @Index() String serviceArticleId = "";                 // 文章服务端ID



  @Index() String userId = "";

  @Index()
  String languageCode = "";


  @Index() String markdown = "";                  // Markdown文档
  @Index() String textContent = "";               // [考虑是否停用，因为翻译的话是翻译 Markdown文档 ]纯文本、可以用于做搜索

  // 精确定位相关字段
  int markdownScrollY = 0;     // Markdown文档滚动Y位置
  int markdownScrollX = 0;     // Markdown文档滚动X位置
  String currentElementId = "";   // 当前可见元素的ID
  String currentElementText = ""; // 当前可见元素的文本片段(前100字符，用于备用定位)
  int currentElementOffset = 0;   // 当前元素在页面中的偏移量
  int viewportHeight = 0;         // 视窗高度(用于计算相对位置)
  int contentHeight = 0;          // 内容总高度
  DateTime? lastReadTime;         // 最后阅读时间

  bool isOriginal = true;     // 是否是源语言

  @Index() DateTime createdAt = DateTime.now();
  @Index() DateTime updatedAt = DateTime.now();
  DateTime? deletedAt;                         // 删除日期

  /// 版本号（用于冲突解决）
  @Index() int version = 1;
  @Index() int updateTimestamp = 0;
}

// // 语言枚举
// enum ContentLanguage {
//   original('original'),
//   zhCN('zh-CN'),
//   zhTW('zh-TW'),
//   enUS('en-US'),
//   jaJP('ja-JP'),
//   koKR('ko-KR'),
//   frFR('fr-FR'),
//   deDE('de-DE'),
//   esES('es-ES'),
//   ruRU('ru-RU'),
//   arAR('ar-AR'),
//   ptPT('pt-PT'),
//   itIT('it-IT'),
//   nlNL('nl-NL'),
//   thTH('th-TH'),
//   viVN('vi-VN');
//
//   const ContentLanguage(this.code);
//
//   final String code;        // 语言代码（ISO 639-1 + 国家代码）
//
//   // 获取多语言标签（使用翻译键）
//   String get label {
//     switch (this) {
//       case ContentLanguage.original:
//         return '内容语言_原文'.tr;
//       case ContentLanguage.zhCN:
//         return '内容语言_中文'.tr;
//       case ContentLanguage.zhTW:
//         return '内容语言_繁体中文'.tr;
//       case ContentLanguage.enUS:
//         return '内容语言_英文'.tr;
//       case ContentLanguage.jaJP:
//         return '内容语言_日文'.tr;
//       case ContentLanguage.koKR:
//         return '内容语言_韩文'.tr;
//       case ContentLanguage.frFR:
//         return '内容语言_法文'.tr;
//       case ContentLanguage.deDE:
//         return '内容语言_德文'.tr;
//       case ContentLanguage.esES:
//         return '内容语言_西班牙文'.tr;
//       case ContentLanguage.ruRU:
//         return '内容语言_俄文'.tr;
//       case ContentLanguage.arAR:
//         return '内容语言_阿拉伯文'.tr;
//       case ContentLanguage.ptPT:
//         return '内容语言_葡萄牙文'.tr;
//       case ContentLanguage.itIT:
//         return '内容语言_意大利文'.tr;
//       case ContentLanguage.nlNL:
//         return '内容语言_荷兰文'.tr;
//       case ContentLanguage.thTH:
//         return '内容语言_泰文'.tr;
//       case ContentLanguage.viVN:
//         return '内容语言_越南文'.tr;
//     }
//   }
//
//   // 获取完整名称（使用翻译键）
//   String get fullName {
//     switch (this) {
//       case ContentLanguage.original:
//         return '内容语言_原文_完整'.tr;
//       case ContentLanguage.zhCN:
//         return '内容语言_中文_完整'.tr;
//       case ContentLanguage.zhTW:
//         return '内容语言_繁体中文_完整'.tr;
//       case ContentLanguage.enUS:
//         return '内容语言_英文_完整'.tr;
//       case ContentLanguage.jaJP:
//         return '内容语言_日文_完整'.tr;
//       case ContentLanguage.koKR:
//         return '内容语言_韩文_完整'.tr;
//       case ContentLanguage.frFR:
//         return '内容语言_法文_完整'.tr;
//       case ContentLanguage.deDE:
//         return '内容语言_德文_完整'.tr;
//       case ContentLanguage.esES:
//         return '内容语言_西班牙文_完整'.tr;
//       case ContentLanguage.ruRU:
//         return '内容语言_俄文_完整'.tr;
//       case ContentLanguage.arAR:
//         return '内容语言_阿拉伯文_完整'.tr;
//       case ContentLanguage.ptPT:
//         return '内容语言_葡萄牙文_完整'.tr;
//       case ContentLanguage.itIT:
//         return '内容语言_意大利文_完整'.tr;
//       case ContentLanguage.nlNL:
//         return '内容语言_荷兰文_完整'.tr;
//       case ContentLanguage.thTH:
//         return '内容语言_泰文_完整'.tr;
//       case ContentLanguage.viVN:
//         return '内容语言_越南文_完整'.tr;
//     }
//   }
//
//   // 从语言代码转换
//   static ContentLanguage fromCode(String code) {
//     return ContentLanguage.values.firstWhere(
//       (lang) => lang.code == code,
//       orElse: () => ContentLanguage.original,
//     );
//   }
//
//   // 从标签转换（现在需要传入当前的翻译标签）
//   static ContentLanguage? fromLabel(String label) {
//     for (final lang in ContentLanguage.values) {
//       if (lang.label == label) {
//         return lang;
//       }
//     }
//     return null;
//   }
//
//   // 获取所有支持的语言
//   static List<ContentLanguage> get supportedLanguages => ContentLanguage.values;
//
//   // 获取翻译语言（除原文外）
//   static List<ContentLanguage> get translationLanguages {
//     return ContentLanguage.values.where((lang) => lang != ContentLanguage.original).toList();
//   }
//
//   // 是否为原文
//   bool get isOriginal => this == ContentLanguage.original;
//
//   // 是否为中文系列
//   bool get isChinese => code.startsWith('zh');
//
//   // 是否为欧洲语言
//   bool get isEuropean {
//     const europeanCodes = ['en-US', 'fr-FR', 'de-DE', 'es-ES', 'ru-RU', 'pt-PT', 'it-IT', 'nl-NL'];
//     return europeanCodes.contains(code);
//   }
//
//   // 是否为亚洲语言
//   bool get isAsian {
//     const asianCodes = ['zh-CN', 'zh-TW', 'ja-JP', 'ko-KR', 'th-TH', 'vi-VN'];
//     return asianCodes.contains(code);
//   }
//
//   @override
//   String toString() => label;
// }
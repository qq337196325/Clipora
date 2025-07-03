import 'package:get/get.dart';

import '../database_service.dart';
import '../../basics/logger.dart';


/// 文章服务类
class ArticleContentService extends GetxService {
  static ArticleContentService get instance => Get.find<ArticleContentService>();

  /// 获取数据库实例
  DatabaseService get _dbService => DatabaseService.instance;


  Future<bool> saveMarkdownScroll(int id, int currentScrollY,int currentScrollX) async {
    try {
      final success = await _dbService.isar.writeTxn(() async {
        // 在删除前先记录操作
        final articleContent = await _dbService.articleContent.get(id);
        if (articleContent != null) {


          articleContent.markdownScrollX = currentScrollX;
          articleContent.markdownScrollY = currentScrollY;

          articleContent.updatedAt = DateTime.now();
          articleContent.lastReadTime = DateTime.now();

          return await  _dbService.articleContent.put(articleContent);
        }
        return false;
      });

      return false;
    } catch (e) {
      getLogger().e('❌ 保存文章位置失败: $e');
      return false;
    }
  }

}
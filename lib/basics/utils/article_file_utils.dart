
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import '../../db/article/service/article_service.dart';
import '../../private/api/user_api.dart';

/// 下载文章文件并保存到本地
/// [serviceArticleId] 服务端文章ID
/// 返回保存的文件路径，如果失败返回null
Future<String?> articleFileDownload(String serviceArticleId) async {
  try {
    final res = await UserApi.getArticleFileDownloadApi({
      "service_article_id": serviceArticleId,
    });
    
    // 检查请求是否成功
    if (res["success"] != true || res["isFile"] != true) {
      print('文件下载失败: ${res["error"] ?? "未知错误"}');
      return null;
    }
    
    // 获取二进制数据
    final Uint8List fileData = res["data"];
    if (fileData.isEmpty) {
      print('文件数据为空');
      return null;
    }
    
    // 获取应用专属目录
    // 优先使用应用支持目录（iOS）或应用数据目录（Android）
    Directory appDir;
    try {
      // 尝试获取应用支持目录（推荐用于应用数据存储）
      appDir = await getApplicationSupportDirectory();
    } catch (e) {
      // 如果不支持，回退到应用文档目录
      appDir = await getApplicationDocumentsDirectory();
    }
    
    final String downloadsPath = path.join(appDir.path, 'article_files');
    
    // 创建article_files目录（如果不存在）
    final Directory articleFilesDir = Directory(downloadsPath);
    if (!await articleFilesDir.exists()) {
      await articleFilesDir.create(recursive: true);
    }
    
    // 生成文件名
    String fileName = res["fileName"] ?? 'article_${serviceArticleId}';
    
    // 如果没有扩展名，根据Content-Type添加
     if (!fileName.contains('.')) {
       final String contentType = res["contentType"] ?? '';
       if (contentType.contains('zip') || contentType.contains('application/zip')) {
         fileName += '.zip';
       } else if (contentType.contains('pdf')) {
         fileName += '.pdf';
       } else if (contentType.contains('html')) {
         fileName += '.html';
       } else if (contentType.contains('text')) {
         fileName += '.txt';
       } else {
         // 默认为zip文件，因为接口返回的是zip格式
         fileName += '.zip';
       }
     }
    
    // 构建完整文件路径
    final String filePath = path.join(downloadsPath, fileName);
    
    // 如果文件已存在，添加时间戳避免冲突
    String finalFilePath = filePath;
    if (await File(filePath).exists()) {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String nameWithoutExt = path.basenameWithoutExtension(fileName);
      final String ext = path.extension(fileName);
      finalFilePath = path.join(downloadsPath, '${nameWithoutExt}_$timestamp$ext');
    }
    
    // 写入文件
    final File file = File(finalFilePath);
    await file.writeAsBytes(fileData);
    
    print('文件下载成功: $finalFilePath');
    return finalFilePath;
    
  } catch (e) {
    print('文件下载异常: $e');
    return null;
  }
}

/// 解压文章文件
/// [zipFilePath] zip文件路径
/// 返回解压后的目录路径，如果失败返回null
Future<String?> extractArticleFile(String serviceArticleId) async {

  try {
    final zipFilePath = await articleFileDownload(serviceArticleId);
    if(zipFilePath == null){
      print('zip文件不存在: $zipFilePath');
      return null;
    }

    // 检查zip文件是否存在
    final File zipFile = File(zipFilePath);
    if (!await zipFile.exists()) {
      print('zip文件不存在: $zipFilePath');
      return null;
    }

    // 读取zip文件数据
    final Uint8List zipData = await zipFile.readAsBytes();
    
    // 解码zip文件
    final Archive archive = ZipDecoder().decodeBytes(zipData);
    
    // 创建解压目录
    final String zipFileName = path.basenameWithoutExtension(zipFilePath);
    final String zipDir = path.dirname(zipFilePath);
    final String extractDir = path.join(zipDir, '${zipFileName}_extracted');
    
    // 如果解压目录已存在，添加时间戳避免冲突
    String finalExtractDir = extractDir;
    if (await Directory(extractDir).exists()) {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      finalExtractDir = path.join(zipDir, '${zipFileName}_extracted_$timestamp');
    }
    
    final Directory extractDirectory = Directory(finalExtractDir);
    await extractDirectory.create(recursive: true);
    
    // 解压所有文件
    for (final ArchiveFile file in archive) {
      // 检查是否为目录（目录名以 / 结尾，或者内容为空且不包含文件扩展名）
      final bool isDirectory = file.name.endsWith('/') || 
          (file.content.isEmpty && !file.name.contains('.'));
      
      if (isDirectory) {
        // 创建目录
        String dirName = file.name;
        if (!dirName.endsWith('/')) {
          dirName += '/';
        }
        final String dirPath = path.join(finalExtractDir, dirName);
        final Directory dir = Directory(dirPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        
        print('创建目录: ${file.name}');
      } else {
        // 处理文件
        final String filePath = path.join(finalExtractDir, file.name);
        
        // 确保父目录存在
        final Directory parentDir = Directory(path.dirname(filePath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
        
        // 写入文件
        final File outputFile = File(filePath);
        await outputFile.writeAsBytes(file.content as List<int>);
        
        print('解压文件: ${file.name}');
      }
    }
    
    print('文件解压成功: $finalExtractDir');

    await ArticleService.instance.dbService.isar.writeTxn(() async {
      final articleData = await ArticleService.instance.findArticleByServiceId(serviceArticleId);
      if(articleData != null){
        articleData.localMhtmlPath = finalExtractDir;

        await ArticleService.instance.updateLocalMhtmlPath(articleData);
      }
    });

    return finalExtractDir;
    
  } catch (e) {
    print('文件解压异常: $e');
    return null;
  }
}
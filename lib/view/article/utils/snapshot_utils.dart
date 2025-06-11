import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inkwell/basics/logger.dart';
import 'package:inkwell/controller/snapshot_service.dart';
import 'package:inkwell/db/article/article_service.dart';

class SnapshotUtils {
  // 下载快照到用户可访问的目录
  static Future<void> downloadSnapshot(BuildContext context, String snapshotPath) async {
    if (snapshotPath.isEmpty) {
      BotToast.showText(text: '没有可下载的快照');
      return;
    }

    try {
      // 显示下载开始提示
      BotToast.showText(text: '开始下载快照...');

      // 检查并请求存储权限
      bool hasPermission = await _checkAndRequestPermissions(context,snapshotPath);
      if (!hasPermission) {
        BotToast.showText(text: '需要存储权限才能下载文件');
        return;
      }

      // 获取源文件
      final File sourceFile = File(snapshotPath);
      if (!await sourceFile.exists()) {
        BotToast.showText(text: '快照文件不存在');
        return;
      }

      // 获取下载目录
      Directory? downloadDir;
      if (Platform.isAndroid) {
        // Android: 使用公共下载目录
        downloadDir = Directory('/storage/emulated/0/Download');
        // 如果公共下载目录不存在，使用外部存储目录
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: 使用应用文档目录
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        BotToast.showText(text: '无法获取下载目录');
        return;
      }

      // 确保下载目录存在
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 生成目标文件名
      final String fileName = snapshotPath.split('/').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = fileName.split('.').last;
      final String downloadFileName = 'inkwell_snapshot_$timestamp.$fileExtension';
      final String downloadPath = '${downloadDir.path}/$downloadFileName';

      // 复制文件到下载目录
      await sourceFile.copy(downloadPath);

      print('快照已下载到: $downloadPath');
      
      // 显示下载成功提示
      BotToast.showText(
        text: '快照下载成功\n保存位置: ${Platform.isAndroid ? "Download" : "Documents"}/$downloadFileName',
      );

      // 显示详细的下载信息对话框
      _showDownloadSuccessDialog(context,downloadPath, downloadFileName);

    } catch (e) {
      print('下载快照失败: $e');
      BotToast.showText(text: '下载失败: $e');
    }
  }

  // 检查并请求存储权限
  static Future<bool> _checkAndRequestPermissions(BuildContext context, String snapshotPath) async {
    if (Platform.isIOS) {
      // iOS不需要额外的存储权限
      return true;
    }

    // Android权限检查
    if (Platform.isAndroid) {
      // 对于Android 13 (API 33) 及以上版本，访问公共目录不需要存储权限
      // 但我们仍然可以检查并请求权限以兼容更低版本
      try {
        PermissionStatus status = await Permission.storage.status;
        
        if (status.isGranted) {
          return true;
        }
        
        if (status.isDenied) {
          // 请求权限
          status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          }
        }
        
        if (status.isPermanentlyDenied) {
          // 如果权限被永久拒绝，显示对话框指导用户
          _showPermissionDeniedDialog(context,snapshotPath);
          return false;
        }
        
        // 即使权限被拒绝，在较新的Android版本上仍然可以访问公共目录
        // 所以我们返回true让下载继续尝试
        return true;
        
      } catch (e) {
        print('权限检查失败: $e');
        // 如果权限检查失败，仍然尝试下载
        return true;
      }
    }

    return true;
  }

  // 显示权限被拒绝的对话框
  static void _showPermissionDeniedDialog(BuildContext context, String snapshotPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('需要存储权限'),
        content: const Text(
          '为了将快照保存到下载文件夹，需要授予存储权限。\n\n'
          '您可以在设置中手动开启权限，或者选择继续下载（文件将保存到应用目录）。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('打开设置'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 继续下载到应用目录
              _downloadToAppDirectory(context,snapshotPath);
            },
            child: const Text('继续下载'),
          ),
        ],
      ),
    );
  }

  // 下载到应用目录（备用方案）
  static Future<void> _downloadToAppDirectory(BuildContext context,String snapshotPath) async {
    try {
      final File sourceFile = File(snapshotPath);
      if (!await sourceFile.exists()) {
        BotToast.showText(text: '快照文件不存在');
        return;
      }

      // 使用应用外部存储目录
      final Directory? appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        BotToast.showText(text: '无法获取存储目录');
        return;
      }

      // 创建下载子目录
      final Directory downloadDir = Directory('${appDir.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 生成目标文件名
      final String fileName = snapshotPath.split('/').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = fileName.split('.').last;
      final String downloadFileName = 'inkwell_snapshot_$timestamp.$fileExtension';
      final String downloadPath = '${downloadDir.path}/$downloadFileName';

      // 复制文件
      await sourceFile.copy(downloadPath);

      print('快照已下载到应用目录: $downloadPath');
      
      BotToast.showText(
        text: '快照已保存到应用目录\n$downloadFileName',
      );

      _showDownloadSuccessDialog(context,downloadPath, downloadFileName);

    } catch (e) {
      print('下载到应用目录失败: $e');
      BotToast.showText(text: '下载失败: $e');
    }
  }

  // 显示下载成功对话框
  static void _showDownloadSuccessDialog(BuildContext context,String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.download_done,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('下载成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文件名: $fileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '保存位置: ${Platform.isAndroid ? "Download" : "Documents"} 文件夹',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '完整路径: $filePath',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 生成和处理快照
  static Future<void> generateAndProcessSnapshot({
    required InAppWebViewController? webViewController,
    required int? articleId,
    Function(String)? onSnapshotCreated,
    required Function(bool) onLoadingStateChanged,
  }) async {
    if (webViewController == null) {
      getLogger().w('WebView控制器未初始化');
      BotToast.showText(text: 'WebView未初始化');
      return;
    }

    onLoadingStateChanged(true);
    BotToast.showText(text: '开始生成快照...');

    try {
      // 获取应用文档目录
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String snapshotDir = '${appDir.path}/snapshots';
      
      // 创建快照目录
      final Directory snapshotDirectory = Directory(snapshotDir);
      if (!await snapshotDirectory.exists()) {
        await snapshotDirectory.create(recursive: true);
      }

      // 生成文件名
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName;
      
      // 根据平台设置文件扩展名
      if (Platform.isAndroid) {
        fileName = 'snapshot_$timestamp.mht';
      } else if (Platform.isIOS || Platform.isMacOS) {
        fileName = 'snapshot_$timestamp.webarchive';
      } else {
        fileName = 'snapshot_$timestamp.mht';
      }
      
      final String filePath = '$snapshotDir/$fileName';

      // 使用saveWebArchive方法保存网页快照
      final String? savedPath = await webViewController.saveWebArchive(
        filePath: filePath,
        autoname: false,
      );

      if (savedPath != null && savedPath.isNotEmpty) {
        getLogger().i('✅ 网页快照保存成功: $savedPath');
        BotToast.showText(text: '快照保存成功');

        // 使用统一的处理器
        await _handleSnapshotGenerated(savedPath, articleId, onSnapshotCreated);
      } else {
        throw Exception('saveWebArchive返回空路径');
      }
    } catch (e) {
      getLogger().e('❌ 生成网页快照失败: $e');
      BotToast.showText(text: '生成快照失败: $e');
    } finally {
      onLoadingStateChanged(false);
    }
  }

  // 处理快照生成后的逻辑
  static Future<void> _handleSnapshotGenerated(String filePath, int? articleId, Function(String)? onSnapshotCreated) async {
    const isMhtml = true; // Assuming this is for MHTML
    final snapshotType = isMhtml ? 'MHTML' : '截图';
    getLogger().i('✅ $snapshotType 快照已生成: $filePath');
    BotToast.showText(text: '$snapshotType 快照生成成功, 准备上传...');

    bool uploadSuccess = false;
    try {
      // 调用上传服务
      uploadSuccess = await SnapshotService.instance.uploadSnapshotToServer(filePath);
    } catch (e) {
      getLogger().e('❌ 快照上传服务调用失败: $e');
      uploadSuccess = false;
    }

    if (uploadSuccess) {
      getLogger().i('✅ 快照上传成功: $filePath');
      BotToast.showText(text: '快照上传成功!');
      // 上传成功后更新数据库，标记isGenerateMhtml为true
      await _updateArticleAfterUploadSuccess(filePath, articleId);
    } else {
      getLogger().w('⚠️ 快照上传失败, 只保存本地路径: $filePath');
      BotToast.showText(text: '快照上传失败, 已保存到本地');
      // 上传失败，仍按旧逻辑保存本地路径
      await _updateArticleMhtmlPath(filePath, articleId);
    }

    // 通过回调返回文件路径给父组件
    onSnapshotCreated?.call(filePath);
  }

  // 上传成功后更新数据库
  static Future<void> _updateArticleAfterUploadSuccess(String path, int? articleId) async {
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，无法更新上传状态');
      return;
    }
    try {
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        article.mhtmlPath = path;
        article.isGenerateMhtml = true; // 标记为已生成快照并上传
        article.updatedAt = DateTime.now();
        
        await ArticleService.instance.saveArticle(article);
        
        getLogger().i('✅ 文章快照上传状态更新成功: ${article.title}');
      } else {
        getLogger().e('❌ 未找到ID为 $articleId 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 更新文章快照上传状态失败: $e');
    }
  }

  // 更新文章的MHTML路径到数据库
  static Future<void> _updateArticleMhtmlPath(String mhtmlPath, int? articleId) async {
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，无法更新MHTML路径');
      return;
    }

    try {
      getLogger().i('📝 更新文章MHTML路径，ID: $articleId, 路径: $mhtmlPath');
      
      // 获取文章记录
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        // 更新MHTML路径
        article.mhtmlPath = mhtmlPath;
        article.updatedAt = DateTime.now();
        
        // 保存到数据库
        await ArticleService.instance.saveArticle(article);
        
        getLogger().i('✅ 文章MHTML路径更新成功: ${article.title}');
      } else {
        getLogger().e('❌ 未找到ID为 $articleId 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 更新文章MHTML路径失败: $e');
    }
  }
} 
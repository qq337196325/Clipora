import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


/// 下载快照文件
class DownloadSnapshotUtils {

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



}
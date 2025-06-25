import 'dart:async';
import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../basics/logger.dart';
import '../db/article/article_db.dart';
import '../db/article/article_service.dart';


enum SnapshotType {
  mhtml,
  html,
}

class SnapshotResult {
  final String? filePath;
  final SnapshotType type;
  final bool success;
  final String? error;

  SnapshotResult({
    this.filePath,
    required this.type,
    required this.success,
    this.error,
  });
}

class SnapshotService extends GetxService {
  static SnapshotService get instance => Get.find<SnapshotService>();
  Timer? _snapshotTimer;
  bool _isProcessing = false; // 防止任务重叠

  @override
  void onInit() {
    super.onInit();
    getLogger().i('SnapshotService onInit');
    _initializePermissions();
    // 每1分钟检查一次是否有需要生成快照的文章
    _snapshotTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      getLogger().i('⏰ 定时快照任务触发');
      processUnsnapshottedArticles();
    });
    // 应用启动30秒后也执行一次
    // Future.delayed(const Duration(seconds: 5), () => processUnsnapshottedArticles());
  }

  @override
  void onClose() {
    _snapshotTimer?.cancel();
    super.onClose();
    getLogger().i('SnapshotService onClose');
  }

  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.storage.request();
      getLogger().i('存储权限状态: $status');
    } catch (e) {
      getLogger().e('❌ 请求存储权限失败: $e');
    }
  }

  Future<void> processUnsnapshottedArticles() async {
    if (_isProcessing) {
      getLogger().i('🔄 快照任务正在处理中，跳过此次触发。');
      return;
    }
    _isProcessing = true;

    try {
      getLogger().i('🔄 开始执行快照生成任务...');
      final articlesToProcess = await ArticleService.instance.getUnsnapshottedArticles();

      if (articlesToProcess.isEmpty) {
        getLogger().i('✅ 没有需要生成快照的文章。');
        return;
      }

      getLogger().i('发现 ${articlesToProcess.length} 篇文章需要生成快照，开始处理...');
      for (final article in articlesToProcess) {

        // 一次只处理一个，避免过多资源消耗
        await _generateAndUploadSnapshot(article);
        // 添加间隔，避免资源冲突
        await Future.delayed(const Duration(seconds: 3));
      }
    } catch (e) {
      getLogger().e('❌ 执行快照任务时出错: $e');
    } finally {
      _isProcessing = false;
      getLogger().i('✅ 快照生成任务执行完毕。');
    }
  }

  Future<void> _generateAndUploadSnapshot(ArticleDb article) async {
    if (article.url.isEmpty) {
      getLogger().w('⚠️ 文章 "${article.title}" URL为空，无法生成快照。');
      return;
    }

    getLogger().i('🔄 开始为文章 "${article.title}" 生成快照...');
    
    // 尝试多种快照方式
    SnapshotResult? result;
    
    // 1. 首先尝试MHTML
    result = await _tryMhtmlSnapshot(article);
    
    if (!result.success) {
      getLogger().e('✅ 快照生成失败');
      return;
    }

    // if (result.success && result.filePath != null) {
    //   getLogger().i('✅ 快照已生成 (${result.type.name}): ${result.filePath}');
    //
    //   // 调用上传服务器的逻辑
    //   final uploadSuccess = await uploadSnapshotToServer(result.filePath!);
    //   if (uploadSuccess) {
    //     // 更新数据库
    //     await ArticleService.instance.updateArticleSnapshotInfo(article.id, result.filePath!);
    //     getLogger().i('✅ 文章 "${article.title}" 快照处理完成');
    //   } else {
    //     getLogger().w('⚠️ 快照生成成功但上传失败，文章: "${article.title}"');
    //   }
    // } else {
    //   getLogger().e('❌ 所有快照方式都失败了，文章: "${article.title}", 错误: ${result.error}');
    // }
  }

  Future<SnapshotResult> _tryMhtmlSnapshot(ArticleDb article) async {
    final Completer<SnapshotResult> completer = Completer<SnapshotResult>();
    HeadlessInAppWebView? headlessWebView;
    bool isSaving = false; // 防止onLoadStop重入

    const String userAgent = 'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Mobile Safari/537.36';

    // 设置90秒超时
    final timeout = Timer(const Duration(seconds: 90), () {
      if (!completer.isCompleted) {
        getLogger().e('❌ MHTML快照任务超时 for ${article.url}');
        completer.complete(SnapshotResult(
          type: SnapshotType.mhtml,
          success: false,
          error: 'Timeout after 90 seconds',
        ));
      }
    });

    try {
      // 获取保存目录
      final snapshotDir = await _getSnapshotDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String mhtFileName = 'snapshot_${article.id}_$timestamp.mht';
      final String mhtFilePath = '$snapshotDir/$mhtFileName';

      headlessWebView = HeadlessInAppWebView(
        initialSettings: InAppWebViewSettings(
          userAgent: userAgent,
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          clearSessionCache: false,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          iframeAllowFullscreen: true,
          // 添加更多设置
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          cacheEnabled: true,
        ),
        initialUrlRequest: URLRequest(url: WebUri(article.url)),
        onLoadStop: (controller, url) async {
          // 如果任务已经完成（成功、失败或超时），或者正在保存中，则忽略后续的事件
          if (completer.isCompleted || isSaving) {
            getLogger().d('MHTML快照任务已完成或正在处理中，忽略后续 onLoadStop 事件: $url');
            return;
          }
          isSaving = true; // 标记为正在保存
          getLogger().i('✅ MHTML页面加载完成: $url');
          
          try {
            // 等待页面渲染
            await Future.delayed(const Duration(seconds: 4));
            
            // 滚动页面加载懒加载内容
            await controller.evaluateJavascript(source: '''
              window.scrollTo(0, document.body.scrollHeight);
              setTimeout(() => {
                window.scrollTo(0, 0);
              }, 1000);
            ''');
            
            await Future.delayed(const Duration(seconds: 3));
            
            getLogger().i('🔄 尝试生成MHTML快照: $mhtFilePath');
            
            // 确保目录存在
            final file = File(mhtFilePath);
            await file.parent.create(recursive: true);
            
            final savedPath = await controller.saveWebArchive(
              filePath: mhtFilePath,
              autoname: false,
            ).timeout(const Duration(seconds: 30));

            if (savedPath != null && savedPath.isNotEmpty && await File(savedPath).exists()) {
              final fileSize = await File(savedPath).length();
              getLogger().i('✅ MHTML快照成功生成，大小: $fileSize字节');
              
              if (!completer.isCompleted) {
                completer.complete(SnapshotResult(
                  filePath: savedPath,
                  type: SnapshotType.mhtml,
                  success: true,
                ));
              }
            } else {
              getLogger().e('❌ MHTML快照生成失败或文件不存在');
              if (!completer.isCompleted) {
                completer.complete(SnapshotResult(
                  type: SnapshotType.mhtml,
                  success: false,
                  error: 'MHTML file not generated or empty',
                ));
              }
            }
          } catch (e) {
            getLogger().e('❌ MHTML快照生成过程中出错: $e');
            if (!completer.isCompleted) {
              completer.complete(SnapshotResult(
                type: SnapshotType.mhtml,
                success: false,
                error: e.toString(),
              ));
            }
          }
        },
        onReceivedError: (controller, request, error) {
          getLogger().e('❌ MHTML页面加载错误: ${error.description} (Code: ${error.type}, URL: ${request.url})');
          if (!completer.isCompleted) {
            completer.complete(SnapshotResult(
              type: SnapshotType.mhtml,
              success: false,
              error: 'Load error: ${error.description}',
            ));
          }
        },
      );

      await headlessWebView.run();
      final result = await completer.future;
      
      return result;
    } catch (e) {
      getLogger().e('❌ MHTML快照整体流程出错: $e');
      return SnapshotResult(
        type: SnapshotType.mhtml,
        success: false,
        error: e.toString(),
      );
    } finally {
      timeout.cancel();
      if (headlessWebView != null && headlessWebView.isRunning()) {
        await headlessWebView.dispose();
      }
    }
  }


  Future<String> _getSnapshotDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String snapshotDir = '${appDir.path}/snapshots';
    await Directory(snapshotDir).create(recursive: true);
    return snapshotDir;
  }



} 
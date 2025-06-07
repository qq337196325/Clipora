import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../basics/logger.dart';


class ArticleWebWidget extends StatefulWidget {
  final Function(String)? onSnapshotCreated;
  
  const ArticleWebWidget({
    super.key,
    this.onSnapshotCreated,
  });

  @override
  State<ArticleWebWidget> createState() => _ArticlePageState();
}


class _ArticlePageState extends State<ArticleWebWidget> with ArticlePageBLoC {

  // 公共方法：供外部调用生成快照
  Future<void> createSnapshot() async {
    await generateMHTMLSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 进度条
        if (isLoading)
          LinearProgressIndicator(
            value: loadingProgress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        // 错误信息显示
        if (hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 48),
                const SizedBox(height: 8),
                Text(
                  '网页加载失败',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        // WebView
        if (!hasError)
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
              initialSettings: webViewSettings,
              onWebViewCreated: (controller) {
                webViewController = controller;
                print('WebView创建成功');
              },
              onLoadStart: (controller, url) {
                print('开始加载: $url');
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              },
              onLoadStop: (controller, url) {
                print('加载完成: $url');
                setState(() {
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  loadingProgress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                print('WebView错误: ${error.description}');
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = '错误代码: ${error.type}\n错误描述: ${error.description}';
                });
                // 不在这里显示Toast，因为我们有错误UI
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                print('HTTP错误: ${errorResponse.statusCode}');
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'HTTP错误: ${errorResponse.statusCode}\n${errorResponse.reasonPhrase}';
                });
              },
            ),
          ),
      ],
    );
  }

}



mixin ArticlePageBLoC on State<ArticleWebWidget> {
  // WebView控制器
  InAppWebViewController? webViewController;
  
  // 加载状态
  bool isLoading = true;
  double loadingProgress = 0.0;
  
  // 错误状态
  bool hasError = false;
  String errorMessage = '';
  
  // URL
  String get currentUrl => 'https://juejin.cn/post/7449699023768600627';
  
  // WebView设置 - 使用更简单的配置
  InAppWebViewSettings webViewSettings = InAppWebViewSettings(
    // 基本设置
    javaScriptEnabled: true,
    domStorageEnabled: true,
    
    // 网络设置
    clearCache: false,
    cacheMode: CacheMode.LOAD_DEFAULT,
    
    // 安全设置
    allowFileAccess: true,
    allowContentAccess: true,
    allowUniversalAccessFromFileURLs: true,
    allowFileAccessFromFileURLs: true,
    
    // 混合内容
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    
    // 用户代理 - 使用更通用的
    userAgent: "Mozilla/5.0 (Mobile; rv:124.0) Gecko/124.0 Firefox/124.0",
    
    // 缩放设置
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    
    // 其他设置
    useWideViewPort: true,
    loadWithOverviewMode: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  // 生成MHTML快照并保存到本地
  Future<void> generateMHTMLSnapshot() async {
    if (webViewController == null) {
      print('WebView控制器未初始化');
      BotToast.showText(text: 'WebView未初始化');
      return;
    }

    try {
      // 显示加载提示
      setState(() {
        isLoading = true;
      });

      // 获取应用文档目录
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String snapshotDir = '${appDir.path}/snapshots';
      
      // 创建快照目录
      final Directory snapshotDirectory = Directory(snapshotDir);
      if (!await snapshotDirectory.exists()) {
        await snapshotDirectory.create(recursive: true);
      }

      // 生成文件名（使用时间戳）
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName;
      String filePath;
      
      // 根据平台设置文件扩展名
      if (Platform.isAndroid) {
        fileName = 'snapshot_$timestamp.mht';
      } else if (Platform.isIOS || Platform.isMacOS) {
        fileName = 'snapshot_$timestamp.webarchive';
      } else {
        fileName = 'snapshot_$timestamp.mht';
      }
      
      filePath = '$snapshotDir/$fileName';

      try {
        // 使用saveWebArchive方法保存网页快照
        final String? savedPath = await webViewController!.saveWebArchive(
          filePath: filePath,
          autoname: false,
        );

        if (savedPath != null && savedPath.isNotEmpty) {
          getLogger().i('网页快照保存成功: $savedPath');
          BotToast.showText(text: '快照保存成功');

          // 通过回调返回文件路径给父组件
          if (widget.onSnapshotCreated != null) {
            widget.onSnapshotCreated!(savedPath);
          }
        } else {
          throw Exception('saveWebArchive返回空路径');
        }
      } catch (saveError) {
        print('saveWebArchive失败: $saveError');
        
        // 如果saveWebArchive也失败了，尝试使用截图作为备用方案
        await _fallbackToScreenshot(snapshotDir, timestamp);
      }

    } catch (e) {
      print('生成网页快照失败: $e');
      BotToast.showText(text: '生成快照失败: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 备用方案：使用截图
  Future<void> _fallbackToScreenshot(String snapshotDir, String timestamp) async {
    try {
      print('尝试使用截图作为备用方案...');
      
      // 获取WebView截图
      final Uint8List? screenshot = await webViewController!.takeScreenshot();
      
      if (screenshot != null && screenshot.isNotEmpty) {
        final String fileName = 'screenshot_$timestamp.png';
        final String filePath = '$snapshotDir/$fileName';
        
        // 保存截图文件
        final File file = File(filePath);
        await file.writeAsBytes(screenshot);
        
        print('截图保存成功: $filePath');
        BotToast.showText(text: '已保存为截图快照');
        
        // 通过回调返回文件路径给父组件
        if (widget.onSnapshotCreated != null) {
          widget.onSnapshotCreated!(filePath);
        }
      } else {
        print('截图生成失败');
        BotToast.showText(text: '快照和截图都生成失败');
      }
    } catch (screenshotError) {
      print('截图备用方案也失败: $screenshotError');
      BotToast.showText(text: '所有快照方案都失败了');
    }
  }


}
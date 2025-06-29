import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../basics/logger.dart';
import '../basics/web_view/settings.dart';
import '../basics/web_view/utils.dart';
import '../basics/web_view/warmup_urls.dart';
import '../db/article/article_db.dart';
import '../db/article/article_service.dart';
import '../view/article/article_web/browser_simulation/core/browser_simulation_manager.dart';
import '../view/article/article_web/browser_simulation/utils/js_injector.dart';
import '../view/article/article_web/utils/auto_generate_utils.dart';
import '../view/article/article_web/utils/web_utils.dart';


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

  // 使用常量来管理时间，提高可读性和可维护性
  static const Duration _kPostArticleProcessDelay = Duration(seconds: 3);
  static const Duration _kWarmupTimeout = Duration(seconds: 30);
  static const Duration _kSnapshotTimeout = Duration(seconds: 90);  // 设置访问超时
  static const Duration _kPostWarmupDelay = Duration(seconds: 2); // 预热成功后等待一下再继续

  Timer? _snapshotTimer;
  bool _isProcessing = false; // 防止任务重叠
  WarmupUrls warmupUrls = WarmupUrls();
  InAppWebViewController? webViewController;
  GenerateMhtmlUtils generateMhtmlUtils = GenerateMhtmlUtils();

  // 浏览器仿真管理器
  BrowserSimulationManager? _simulationManager;
  JSInjector? _jsInjector;


  @override
  void onInit() {
    super.onInit();
    getLogger().i('SnapshotService onInit');
    _initializePermissions();
    _initializeBrowserSimulation();
    // 每分钟检查一次是否有需要生成快照的文章
    _snapshotTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      getLogger().i('⏰ 定时快照任务触发');
      processUnsnapshottedArticles();
    });
    // // 应用启动后延迟执行一次
    // Future.delayed(_kInitialSnapshotDelay, () => processUnsnapshottedArticles());
  }

  /// 初始化浏览器仿真功能
  Future<void> _initializeBrowserSimulation() async {
    try {
      // 初始化仿真管理器
      _simulationManager = BrowserSimulationManager();
      Get.put(_simulationManager!);

      // 创建JavaScript注入器
      _jsInjector = JSInjector(_simulationManager!.storageManager);

      getLogger().i('🎯 浏览器仿真功能初始化完成');
    } catch (e) {
      getLogger().e('❌ 浏览器仿真功能初始化失败: $e');
    }
  }

  @override
  void onClose() {
    _snapshotTimer?.cancel();
    super.onClose();
    getLogger().i('SnapshotService onClose');
  }

  /// 获取存储权限
  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.storage.request();
      getLogger().i('存储权限状态: $status');
    } catch (e) {
      getLogger().e('❌ 请求存储权限失败: $e');
    }
  }

  /// 开始进行生成快照
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
        await Future.delayed(_kPostArticleProcessDelay);
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
    
    if (result.success && result.filePath != null) {
      getLogger().i('✅ 快照已生成 (${result.type.name}): ${result.filePath}');
    } else {
      getLogger().e('❌ 所有快照方式都失败了，文章: "${article.title}", 错误: ${result.error}');
    }
  }



  /// 执行预热访问
  Future<bool> _performWarmup(String domain) async {
    final Completer<bool> completer = Completer<bool>();
    HeadlessInAppWebView? warmupWebView;
    
    // 设置预热超时时间
    final timeout = Timer(_kWarmupTimeout, () {
      if (!completer.isCompleted) {
        getLogger().e('❌ 预热访问超时: $domain');
        completer.complete(false);
      }
    });

    try {
      final warmupUrl = 'https://$domain';
      getLogger().i('🔥 开始预热访问: $warmupUrl');

      warmupWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(warmupUrl), headers: WebViewSettings.getPlatformOptimizedHeaders()),
        initialSettings: WebViewSettings.getWebViewSettings(),
        onWebViewCreated: (controller) async {
          getLogger().i('🌐 预热WebView创建成功');
        },
        onLoadStop: (controller, url) async {
          if (completer.isCompleted) {
            return;
          }
          
          getLogger().i('✅ 预热页面加载完成: $url');
          
          try {
            // 等待页面完全渲染
            await Future.delayed(Duration(seconds: 2));
            
            // 更新预热状态
            warmupUrls.updateWarmupStatus(domain, isWarmedUp: true);
            
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          } catch (e) {
            getLogger().e('❌ 预热处理过程出错: $e');
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }
        },
        onReceivedError: (controller, request, error) {
          getLogger().e('❌ 预热页面加载错误: ${error.description} (Code: ${error.type}, URL: ${request.url})');
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      await warmupWebView.run();
      final result = await completer.future;
      
      return result;
    } catch (e) {
      getLogger().e('❌ 预热过程整体出错: $e');
      return false;
    } finally {
      timeout.cancel();
      if (warmupWebView != null && warmupWebView.isRunning()) {
        await warmupWebView.dispose();
      }
    }
  }

  Future<SnapshotResult> _tryMhtmlSnapshot(ArticleDb article) async {
    final Completer<SnapshotResult> completer = Completer<SnapshotResult>();
    HeadlessInAppWebView? headlessWebView;
    bool isSaving = false; // 防止onLoadStop重入

    // 检查是否需要预热
    final domain = _extractDomainFromUrl(article.url);
    if (domain.isNotEmpty) {
      final warmupUrlsMap = warmupUrls.getWarmupUrls();
      // 如果域名在预热列表中且未预热过
      if (warmupUrlsMap.containsKey(domain) && !warmupUrls.isWarmedUp(domain)) {
        getLogger().i('🔥 检测到需要预热的域名: $domain');
        final warmupSuccess = await _performWarmup(domain);
        if (warmupSuccess) {
          getLogger().i('✅ 域名预热成功: $domain');
          // 预热成功后等待一下再继续
          await Future.delayed(_kPostWarmupDelay);
        } else {
          getLogger().w('⚠️ 域名预热失败，继续尝试访问: $domain');
        }
      } else if (warmupUrlsMap.containsKey(domain)) {
        getLogger().d('ℹ️ 域名已预热过: $domain');
      }
    }

    // 设置超时，防止任务卡死
    final timeout = Timer(_kSnapshotTimeout, () {
      if (!completer.isCompleted) {
        getLogger().e('❌ MHTML快照任务超时 for ${article.url}');
        completer.complete(SnapshotResult(
          type: SnapshotType.mhtml,
          success: false,
          error: 'Timeout after ${_kSnapshotTimeout.inSeconds} seconds',
        ));
      }
    });

    try {
      // 获取保存目录

      headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(article.url), headers: WebViewSettings.getPlatformOptimizedHeaders()),
        initialSettings: WebViewSettings.getWebViewSettings(),// 【初始化设置】: 无头WebView的详细配置。
        onWebViewCreated: (controller) async { // 【WebView创建完成回调】: 当WebView实例创建成功后调用，通常在这里获取WebView控制器。
          webViewController = controller;
          getLogger().i('🌐 Web页面WebView创建成功');
        },
        onLoadStop: (controller, url) async {   // 【页面加载完成回调】: 页面加载完成后，在这里执行滚动页面和生成快照的核心逻辑。
          // 如果任务已经完成（成功、失败或超时），或者正在保存中，则忽略后续的事件
          if (completer.isCompleted || isSaving) {
            getLogger().d('MHTML快照任务已完成或正在处理中，忽略后续 onLoadStop 事件: $url');
            return;
          }
          
          isSaving = true; // 标记为正在保存
          getLogger().i('✅ MHTML页面加载完成: $url');

          try {

            // 注入存储仿真代码
            await _jsInjector?.injectStorageSimulation(controller);

            // 注入平台特定的反检测代码
            await WebViewUtils.injectPlatformSpecificAntiDetection(controller);

            // 注入内边距和修复页面宽度
            // 为了模拟真实设备，避免被反爬虫检测，我们使用一个典型的水平内边距。
            const padding = EdgeInsets.symmetric(horizontal: 12.0);
            await WebViewUtils.fixPageWidth(controller, padding);


            // 注入移动端弹窗处理脚本 - 恢复滚动功能
            await WebViewUtils.injectMobilePopupHandler(controller);


            // 页面加载完成后进行优化设置
            finalizeWebPageOptimization(url,webViewController); 


            // 等待页面初步渲染
            await Future.delayed(Duration(seconds: 2));




            // 滚动页面以触发懒加载内容，并等待加载完成
            await controller.evaluateJavascript(source: 'window.scrollTo(0, document.body.scrollHeight);');
            await Future.delayed(Duration(seconds: 2));
            await controller.evaluateJavascript(source: 'window.scrollTo(0, 0);'); // 滚动回顶部
            await Future.delayed(const Duration(milliseconds: 500)); // 等待滚动动画




            // 生成MHTML快照
            generateMhtmlUtils.webViewController = webViewController;
            final filePath = await generateMhtmlUtils.generateSnapshot();
            generateMhtmlUtils.updateArticleSnapshot(filePath,article.id); // 将快照目录更新到数据库
            final uploadStatus = await generateMhtmlUtils.uploadSnapshotToServer(filePath,article.id); // 上传快照到服务器
            if(uploadStatus){
              await generateMhtmlUtils.fetchMarkdownFromServer(
                article: article,
                onMarkdownGenerated: (){

                },
              );
            }

          } catch (e) {
            getLogger().e('❌ MHTML快照保存过程出错: $e');
            if (!completer.isCompleted) {
              completer.complete(SnapshotResult(
                type: SnapshotType.mhtml,
                success: false,
                error: e.toString(),
              ));
            }
          } finally {
            isSaving = false; // 重置标志
          }
        },
        // 【通用错误回调】: 捕获加载过程中发生的任何错误。
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

  /// 从URL中提取域名
  String _extractDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      getLogger().e('❌ 提取域名失败: $e, URL: $url');
      return '';
    }
  }
} 
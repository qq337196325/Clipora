import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:collection';

import '../../basics/logger.dart';
import '../../controller/snapshot_service.dart';
import '../../db/article/article_service.dart';
import 'components/web_webview_pool_manager.dart';


class ArticleWebWidget extends StatefulWidget {
  final Function(String)? onSnapshotCreated;
  final String? url;
  final int? articleId;  // 添加文章ID参数
  
  const ArticleWebWidget({
    super.key,
    this.onSnapshotCreated,
    this.url,
    this.articleId,  // 添加文章ID参数
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
              initialSettings: WebWebViewPoolManager().getOptimizedSettings(),
              initialUserScripts: UnmodifiableListView(WebWebViewPoolManager().getOptimizedUserScripts()),
              onWebViewCreated: (controller) {
                webViewController = controller;
                getLogger().i('🌐 Web页面WebView创建成功');
                
                // 使用优化的WebView配置
                _setupOptimizedWebView(controller);
              },
              onLoadStart: (controller, url) {
                getLogger().i('🌐 开始加载Web页面: $url');
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              },
              onLoadStop: (controller, url) {
                getLogger().i('🌐 Web页面加载完成: $url');
                setState(() {
                  isLoading = false;
                });
                
                // 页面加载完成后进行优化设置
                _finalizeWebPageOptimization();
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  loadingProgress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                getLogger().e('❌ WebView加载错误: ${error.description}', error: {
                  'type': error.type,
                  'url': request.url,
                  'method': request.method,
                  'headers': request.headers,
                });
                
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = '错误代码: ${error.type}\n错误描述: ${error.description}\nURL: ${request.url}';
                });
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                getLogger().e('❌ HTTP错误: ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'HTTP错误: ${errorResponse.statusCode}\n${errorResponse.reasonPhrase}\nURL: ${request.url}';
                });
              },
              // 使用优化的URL跳转处理
              shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
              // 使用优化的资源请求拦截
              shouldInterceptRequest: _handleOptimizedResourceRequest,
            ),
          ),
      ],
    );
  }

  /// 优化的URL导航处理
  Future<NavigationActionPolicy> _handleOptimizedUrlNavigation(
    InAppWebViewController controller, 
    NavigationAction navigationAction
  ) async {
    final uri = navigationAction.request.url!;
    final url = uri.toString();
    
    getLogger().d('🌐 URL跳转拦截: $url');
    
    // 检查是否是自定义scheme（非http/https）
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      getLogger().w('⚠️ 拦截自定义scheme跳转: ${uri.scheme}://');
      return NavigationActionPolicy.CANCEL;
    }
    
    // 检查是否是应用内跳转scheme
    if (url.startsWith('snssdk') || 
        url.startsWith('sslocal') || 
        url.startsWith('toutiao') ||
        url.startsWith('newsarticle')) {
      getLogger().w('⚠️ 拦截应用跳转scheme: $url');
      return NavigationActionPolicy.CANCEL;
    }
    
    // 允许正常的HTTP/HTTPS链接
    getLogger().d('✅ 允许正常HTTP跳转: $url');
    return NavigationActionPolicy.ALLOW;
  }

  /// 优化的资源请求处理
  Future<WebResourceResponse?> _handleOptimizedResourceRequest(
    InAppWebViewController controller, 
    WebResourceRequest request
  ) async {
    final url = request.url.toString();
    
    // 如果是API请求，记录并优化处理
    if (url.contains('api.juejin.cn') || 
        url.contains('api.toutiao.com') ||
        url.contains('api.douban.com')) {
      getLogger().d('🌐 拦截API请求: ${url.substring(0, 100)}...');
      
      // 这里可以添加更多的请求优化逻辑
      // 比如添加缓存、请求去重等
    }
    
    // 返回null表示使用默认处理
    return null;
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
  String get currentUrl => widget.url ?? '';
  
  // 获取文章ID
  int? get articleId => widget.articleId;
  
  // 添加任务状态监听相关变量
  Timer? _pollingTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    // 确保Web页面优化器已初始化
    _ensureWebOptimizer();
  }

  @override
  void dispose() {
    // 清理轮询定时器
    _pollingTimer?.cancel();
    webViewController?.dispose();
    super.dispose();
  }

  /// 确保Web页面优化器已初始化
  void _ensureWebOptimizer() {
    WebWebViewPoolManager().initialize().catchError((e) {
      getLogger().e('❌ Web页面优化器初始化失败: $e');
    });
  }

  /// 设置优化的WebView
  Future<void> _setupOptimizedWebView(InAppWebViewController controller) async {
    try {
      getLogger().i('🎯 开始设置优化的Web页面WebView...');
      
      // 检查优化器是否已准备就绪
      if (WebWebViewPoolManager().isOptimized) {
        getLogger().i('✅ 使用预热的Web页面优化配置');
        await WebWebViewPoolManager().setupOptimizedWebView(controller);
      } else {
        getLogger().w('⚠️ 优化器未准备就绪，使用传统方式设置');
        await _setupTraditionalWebView(controller);
      }
      
      getLogger().i('✅ Web页面WebView设置完成');
    } catch (e) {
      getLogger().e('❌ 设置优化WebView失败: $e');
      // 降级到传统方式
      await _setupTraditionalWebView(controller);
    }
  }

  /// 传统方式设置WebView（备用）
  Future<void> _setupTraditionalWebView(InAppWebViewController controller) async {
    try {
      getLogger().i('🔧 使用传统方式设置WebView...');
      
      // 注入传统CORS处理脚本
      await controller.evaluateJavascript(source: _getTraditionalCorsScript());
      
      getLogger().i('✅ 传统WebView设置完成');
    } catch (e) {
      getLogger().e('❌ 传统WebView设置失败: $e');
    }
  }

  /// 页面加载完成后的最终优化
  Future<void> _finalizeWebPageOptimization() async {
    if (webViewController == null) return;
    
    try {
      getLogger().i('🎨 执行页面加载完成后的优化...');
      
      // 注入页面完成后的优化脚本
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          console.log('🎨 执行页面完成后优化...');
          
          // 延迟执行，确保页面完全渲染
          setTimeout(function() {
            // 强制移除水平滚动条的终极方案
            function eliminateHorizontalScroll() {
              console.log('🔧 开始消除水平滚动条...');
              
              // 1. 强制设置body和html的样式
              document.documentElement.style.overflowX = 'hidden';
              document.documentElement.style.maxWidth = '100%';
              document.body.style.overflowX = 'hidden';
              document.body.style.maxWidth = '100%';
              document.body.style.width = '100%';
              
              // 2. 检查并修复所有可能导致水平滚动的元素
              const allElements = document.querySelectorAll('*');
              let fixedCount = 0;
              
              allElements.forEach(function(el) {
                const rect = el.getBoundingClientRect();
                const computed = window.getComputedStyle(el);
                
                // 检查元素是否超出视口宽度
                if (rect.width > window.innerWidth || 
                    rect.right > window.innerWidth) {
                  
                  // 记录原始宽度用于调试
                  const originalWidth = computed.width;
                  
                  // 应用修复样式
                  el.style.maxWidth = '100%';
                  el.style.boxSizing = 'border-box';
                  
                  // 特殊处理不同类型的元素
                  const tagName = el.tagName.toLowerCase();
                  
                  if (tagName === 'img' || tagName === 'video') {
                    el.style.width = '100%';
                    el.style.height = 'auto';
                  } else if (tagName === 'table') {
                    el.style.width = '100%';
                    el.style.tableLayout = 'fixed';
                  } else if (tagName === 'pre' || tagName === 'code') {
                    el.style.whiteSpace = 'pre-wrap';
                    el.style.wordWrap = 'break-word';
                    el.style.overflowX = 'auto';
                  } else if (computed.position === 'fixed' || computed.position === 'absolute') {
                    // 对于定位元素，确保不超出边界
                    if (rect.right > window.innerWidth) {
                      el.style.right = '0';
                      el.style.left = 'auto';
                      el.style.maxWidth = '100%';
                    }
                  }
                  
                  fixedCount++;
                  console.log('🔧 修复超宽元素:', tagName, '原始宽度:', originalWidth);
                }
              });
              
              // 3. 强制刷新布局
              document.body.offsetHeight; // 触发重排
              
              // 4. 最后检查是否还有水平滚动
              const hasHorizontalScroll = document.documentElement.scrollWidth > document.documentElement.clientWidth;
              
              console.log('📊 优化结果:', {
                '修复元素数量': fixedCount,
                '视口宽度': window.innerWidth,
                '文档宽度': document.documentElement.scrollWidth,
                '是否还有水平滚动': hasHorizontalScroll
              });
              
              if (hasHorizontalScroll) {
                console.warn('⚠️ 仍存在水平滚动，应用强制CSS覆盖');
                // 最后的强制手段
                const forceStyle = document.createElement('style');
                forceStyle.innerHTML = `
                  * { 
                    max-width: 100% !important; 
                    box-sizing: border-box !important; 
                  }
                  html, body { 
                    overflow-x: hidden !important; 
                    width: 100% !important;
                  }
                `;
                document.head.appendChild(forceStyle);
              }
              
              return fixedCount;
            }
            
            // 执行消除水平滚动
            const fixedCount = eliminateHorizontalScroll();
            
            // 优化已加载的图片
            const images = document.querySelectorAll('img');
            let optimizedCount = 0;
            
            images.forEach(function(img) {
              if (!img.style.maxWidth) {
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                optimizedCount++;
              }
            });
            
            console.log('✅ 页面优化完成，修复了 ' + fixedCount + ' 个超宽元素，优化了 ' + optimizedCount + ' 张图片');
            
            // 触发性能统计
            if (window.performance && window.performance.timing) {
              const timing = window.performance.timing;
              const loadTime = timing.loadEventEnd - timing.navigationStart;
              console.log('📊 页面加载耗时: ' + loadTime + 'ms');
            }
          }, 500);
        })();
      ''');
      
      // 输出性能统计
      final stats = WebWebViewPoolManager().getPerformanceStats();
      getLogger().i('📊 Web页面性能统计: $stats');
      
      getLogger().i('✅ 页面最终优化完成');
    } catch (e) {
      getLogger().e('❌ 页面最终优化失败: $e');
    }
  }

  /// 获取传统CORS脚本（备用）
  String _getTraditionalCorsScript() {
    return '''
    (function() {
      console.log('🔧 注入传统CORS处理脚本...');
      
      const originalFetch = window.fetch;
      window.fetch = function(url, options = {}) {
        if (typeof url === 'string' && url.includes('api.juejin.cn')) {
          options.mode = 'no-cors';
          options.credentials = 'include';
        }
        return originalFetch.call(this, url, options).catch(error => {
          console.warn('⚠️ Fetch请求失败:', error);
          return Promise.resolve(new Response('{}', { status: 200 }));
        });
      };
      
      console.log('✅ 传统CORS处理脚本注入完成');
    })();
  ''';
  }

  // 生成MHTML快照并保存到本地
  Future<void> generateMHTMLSnapshot() async {
    if (webViewController == null) {
      getLogger().w('WebView控制器未初始化');
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
          getLogger().i('✅ 网页快照保存成功: $savedPath');
          BotToast.showText(text: '快照保存成功');

          // 使用统一的处理器
          await _handleSnapshotGenerated(savedPath);

        } else {
          throw Exception('saveWebArchive返回空路径');
        }
      } catch (saveError) {
        getLogger().e('saveWebArchive失败: $saveError');
        
        // 如果saveWebArchive失败，尝试使用截图作为备用方案
        await _fallbackToScreenshot(snapshotDir, timestamp);
      }

    } catch (e) {
      getLogger().e('❌ 生成网页快照失败: $e');
      BotToast.showText(text: '生成快照失败: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 处理快照（MHTML或截图）生成后的逻辑
  Future<void> _handleSnapshotGenerated(String filePath, {bool isMhtml = true}) async {
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
      await _updateArticleAfterUploadSuccess(filePath);
    } else {
      getLogger().w('⚠️ 快照上传失败, 只保存本地路径: $filePath');
      BotToast.showText(text: '快照上传失败, 已保存到本地');
      // 上传失败，仍按旧逻辑保存本地路径
      await _updateArticleMhtmlPath(filePath);
    }

    // 通过回调返回文件路径给父组件
    if (widget.onSnapshotCreated != null) {
      widget.onSnapshotCreated!(filePath);
    }
  }

  // 上传成功后更新数据库
  Future<void> _updateArticleAfterUploadSuccess(String path) async {
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，无法更新上传状态');
      return;
    }
    try {
      final article = await ArticleService.instance.getArticleById(articleId!);
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
  Future<void> _updateArticleMhtmlPath(String mhtmlPath) async {
    if (articleId == null) {
      getLogger().w('⚠️ 文章ID为空，无法更新MHTML路径');
      return;
    }

    try {
      getLogger().i('📝 更新文章MHTML路径，ID: $articleId, 路径: $mhtmlPath');
      
      // 获取文章记录
      final article = await ArticleService.instance.getArticleById(articleId!);
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

  // 备用方案：使用截图
  Future<void> _fallbackToScreenshot(String snapshotDir, String timestamp) async {
    try {
      getLogger().i('📸 尝试使用截图作为备用方案...');
      
      // 获取WebView截图
      final Uint8List? screenshot = await webViewController!.takeScreenshot();
      
      if (screenshot != null && screenshot.isNotEmpty) {
        final String fileName = 'screenshot_$timestamp.png';
        final String filePath = '$snapshotDir/$fileName';
        
        // 保存截图文件
        final File file = File(filePath);
        await file.writeAsBytes(screenshot);

        // 使用统一的处理器
        await _handleSnapshotGenerated(filePath, isMhtml: false);

      } else {
        getLogger().e('❌ 截图生成失败');
        BotToast.showText(text: '快照和截图都生成失败');
      }
    } catch (screenshotError) {
      getLogger().e('❌ 截图备用方案也失败: $screenshotError');
      BotToast.showText(text: '所有快照方案都失败了');
    }
  }

  // 上传快照到服务器并开始监听处理状态  
  Future<String?> uploadSnapshotToServer(String snapshotPath) async {
    try {
      // 显示上传进度
      BotToast.showText(text: '正在上传快照...');
      
      // TODO: 实现上传逻辑，这里假设返回任务ID
      // 模拟返回任务ID
      final taskId = 'task_${DateTime.now().millisecondsSinceEpoch}';
      
      BotToast.showText(text: '上传成功，正在处理...');
      
      // 开始轮询监听处理状态
      await _startPollingTaskStatus(taskId);
      
      return taskId;
    } catch (e) {
      getLogger().e('上传快照失败', error: e);
      BotToast.showText(text: '上传失败: $e');
      return null;
    }
  }

  // 智能轮询监听任务状态
  Future<void> _startPollingTaskStatus(String taskId) async {
    if (_isPolling) {
      getLogger().d('已经在轮询中，跳过重复请求');
      return;
    }
    
    _isPolling = true;
    int pollCount = 0;
    const int maxPollCount = 30; // 最多轮询30次（约5分钟）
    
    // 渐进式轮询间隔：前几次快一点，后面慢一点
    List<int> intervals = [1, 2, 3, 3, 5, 5, 5, 8, 8, 10]; // 秒
    
    void poll() async {
      if (!_isPolling || !mounted) return;
      
      try {
        pollCount++;
        getLogger().d('轮询任务状态，第${pollCount}次: $taskId');
        
        // TODO: 实际的状态查询API调用
        // 模拟服务器响应
        final Map<String, dynamic> mockResponse = await _mockServerResponse(taskId, pollCount);
        final String status = mockResponse['status'];
        final String? result = mockResponse['result'];
        final String? error = mockResponse['error'];
        
        switch (status) {
          case 'pending':
          case 'processing':
            // 继续轮询
            getLogger().d('任务处理中... 状态: $status');
            
            // 确定下次轮询间隔
            int intervalIndex = (pollCount - 1).clamp(0, intervals.length - 1);
            int nextInterval = intervals[intervalIndex];
            
            if (pollCount < maxPollCount) {
              _pollingTimer = Timer(Duration(seconds: nextInterval), poll);
            } else {
              _handlePollingTimeout(taskId);
            }
            break;
            
          case 'completed':
            // 处理成功
            getLogger().i('任务处理完成: $result');
            _handleTaskCompleted(taskId, result!);
            break;
            
          case 'failed':
            // 处理失败
            getLogger().e('任务处理失败: $error');
            _handleTaskFailed(taskId, error ?? '未知错误');
            break;
            
          default:
            getLogger().w('未知任务状态: $status');
            _handleTaskFailed(taskId, '未知状态: $status');
        }
        
      } catch (e) {
        getLogger().e('轮询状态查询失败: $e');
        
        // 网络错误时继续重试，但增加间隔
        if (pollCount < maxPollCount) {
          _pollingTimer = Timer(const Duration(seconds: 10), poll);
        } else {
          _handlePollingTimeout(taskId);
        }
      }
    }
    
    // 开始第一次轮询
    poll();
  }

  // 停止轮询
  void _stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // 任务完成处理
  void _handleTaskCompleted(String taskId, String markdownContent) {
    _stopPolling();
    
    getLogger().i('✅ Markdown解析完成，长度: ${markdownContent.length}');
    BotToast.showText(text: '文档解析完成！');
    
    // 处理解析后的Markdown内容
    _onMarkdownReady(markdownContent);
  }

  // 任务失败处理
  void _handleTaskFailed(String taskId, String error) {
    _stopPolling();
    getLogger().e('❌ 任务处理失败: $error');
    BotToast.showText(text: '处理失败: $error');
  }

  // 轮询超时处理
  void _handlePollingTimeout(String taskId) {
    _stopPolling();
    getLogger().w('⚠️ 任务轮询超时: $taskId');
    BotToast.showText(text: '处理超时，请稍后重试');
  }

  // Markdown内容就绪回调
  void _onMarkdownReady(String markdownContent) {
    if (widget.onSnapshotCreated != null) {
      widget.onSnapshotCreated!(markdownContent);
    }
  }

  // 模拟服务器响应（实际使用时删除此方法）
  Future<Map<String, dynamic>> _mockServerResponse(String taskId, int pollCount) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    
    // 模拟不同的处理阶段
    if (pollCount <= 2) {
      return {'status': 'pending'};
    } else if (pollCount <= 6) {
      return {'status': 'processing'};
    } else if (pollCount <= 8) {
      // 80%概率成功
      if (DateTime.now().millisecond % 10 < 8) {
        return {
          'status': 'completed',
          'result': '# 解析结果\n\n这是从MHTML解析出的Markdown内容...\n\n## 章节1\n内容示例...'
        };
      } else {
        return {
          'status': 'failed',
          'error': '解析MHTML文件时出错'
        };
      }
    } else {
      return {
        'status': 'completed',
        'result': '# 最终解析结果\n\n完整的Markdown文档内容...'
      };
    }
  }
}
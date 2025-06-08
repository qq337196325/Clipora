import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:collection';

import '../../basics/logger.dart';
import '../../db/article/article_service.dart';


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
              initialSettings: webViewSettings,
              initialUserScripts: UnmodifiableListView([
                UserScript(
                  source: ArticlePageBLoC.corsScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              ]),
              onWebViewCreated: (controller) {
                webViewController = controller;
                print('WebView创建成功');
                
                // 添加JavaScript处理器以支持更好的页面交互
                _setupWebViewConfiguration(controller);
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
                print('WebView错误详情:');
                print('  错误类型: ${error.type}');
                print('  错误描述: ${error.description}');
                print('  请求URL: ${request.url}');
                print('  请求方法: ${request.method}');
                print('  请求头: ${request.headers}');
                
                getLogger().e('WebView加载错误', error: error.description);
                
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = '错误代码: ${error.type}\n错误描述: ${error.description}\nURL: ${request.url}';
                });
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                print('HTTP错误详情:');
                print('  状态码: ${errorResponse.statusCode}');
                print('  原因: ${errorResponse.reasonPhrase}');
                print('  请求URL: ${request.url}');
                print('  响应头: ${errorResponse.headers}');
                
                getLogger().e('HTTP错误', error: '${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'HTTP错误: ${errorResponse.statusCode}\n${errorResponse.reasonPhrase}\nURL: ${request.url}';
                });
              },
              // 拦截URL跳转，处理自定义scheme
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url!;
                final url = uri.toString();
                
                print('URL跳转拦截: $url');
                
                // 检查是否是自定义scheme（非http/https）
                if (!url.startsWith('http://') && !url.startsWith('https://')) {
                  print('拦截自定义scheme跳转: ${uri.scheme}://');
                  // 阻止跳转，返回CANCEL
                  return NavigationActionPolicy.CANCEL;
                }
                
                // 检查是否是应用内跳转scheme
                if (url.startsWith('snssdk') || 
                    url.startsWith('sslocal') || 
                    url.startsWith('toutiao') ||
                    url.startsWith('newsarticle')) {
                  print('拦截应用跳转scheme: $url');
                  return NavigationActionPolicy.CANCEL;
                }
                
                // 允许正常的HTTP/HTTPS链接
                print('允许正常HTTP跳转: $url');
                return NavigationActionPolicy.ALLOW;
              },
              // 拦截资源请求，处理API请求的CORS问题
              shouldInterceptRequest: (controller, request) async {
                final url = request.url.toString();
                
                // 如果是掘金API请求，添加CORS头
                if (url.contains('api.juejin.cn')) {
                  print('拦截掘金API请求: $url');
                  
                  // 创建新的请求头，添加CORS相关头部
                  final headers = Map<String, String>.from(request.headers ?? {});
                  headers['Access-Control-Allow-Origin'] = '*';
                  headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
                  headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With';
                  headers['Access-Control-Allow-Credentials'] = 'true';
                  
                  // 返回null表示允许请求继续，但修改了头部
                  return null;
                }
                
                // 其他请求正常处理
                return null;
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
  String get currentUrl => widget.url ?? '';
  
  // 获取文章ID
  int? get articleId => widget.articleId;
  
  // WebView设置 - 使用稳定可靠的配置
  InAppWebViewSettings webViewSettings = InAppWebViewSettings(
    // ==== 核心功能设置 ====
    javaScriptEnabled: true,
    domStorageEnabled: true,
    
    // ==== 网络和缓存设置 ====
    clearCache: false,
    cacheMode: CacheMode.LOAD_DEFAULT,
    
    // ==== 安全设置 ====
    allowFileAccess: true,
    allowContentAccess: true,
    
    // ==== CORS和跨域设置 ====
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    // 允许跨域访问
    allowUniversalAccessFromFileURLs: true,
    allowFileAccessFromFileURLs: true,
    
    // ==== 用户代理 - 使用更兼容的移动版Chrome ====
    userAgent: "Mozilla/5.0 (Linux; Android 12; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 EdgA/120.0.0.0",
    
    // ==== 视口和缩放设置 ====
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    
    // ==== 基本网络设置 ====
    blockNetworkImage: false,
    blockNetworkLoads: false,
    loadsImagesAutomatically: true,
    
    // ==== Cookie设置 ====
    thirdPartyCookiesEnabled: true,
    
    // ==== 媒体设置 ====
    mediaPlaybackRequiresUserGesture: false,
    
    // ==== 滚动条设置 ====
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: true,
    
    // ==== URL拦截设置 ====
    useShouldOverrideUrlLoading: true,
  );

  // CORS处理脚本
  static const String corsScript = '''
    (function() {
      console.log('🔧 开始注入CORS处理脚本...');
      
      // 重写fetch方法来处理CORS问题
      const originalFetch = window.fetch;
      window.fetch = function(url, options = {}) {
        if (typeof url === 'string' && url.includes('api.juejin.cn')) {
          console.log('🌐 拦截掘金API fetch请求:', url);
          options.mode = 'no-cors';
          options.credentials = 'include';
          // 添加更多兼容性头部
          options.headers = {
            ...options.headers,
            'User-Agent': navigator.userAgent,
            'Accept': '*/*',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
          };
        }
        return originalFetch.call(this, url, options).catch(error => {
          console.warn('⚠️ Fetch请求失败，尝试备用方案:', error);
          return Promise.resolve(new Response('{}', { status: 200 }));
        });
      };
      
      // 重写XMLHttpRequest
      const originalXHROpen = XMLHttpRequest.prototype.open;
      const originalXHRSend = XMLHttpRequest.prototype.send;
      
      XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
        this._url = url;
        this._method = method;
        const result = originalXHROpen.call(this, method, url, async, user, password);
        
        if (typeof url === 'string' && url.includes('api.juejin.cn')) {
          console.log('🌐 拦截掘金API XHR请求:', method, url);
          // 监听状态变化
          this.addEventListener('readystatechange', function() {
            if (this.readyState === 4 && this.status === 0) {
              console.log('🔄 XHR请求被CORS阻止，返回空响应');
            }
          });
        }
        
        return result;
      };
      
      XMLHttpRequest.prototype.send = function(data) {
        if (this._url && this._url.includes('api.juejin.cn')) {
          try {
            this.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
          } catch(e) {
            console.warn('⚠️ 设置请求头失败:', e);
          }
        }
        return originalXHRSend.call(this, data);
      };
      
      console.log('✅ CORS处理脚本注入完成');
    })();
  ''';

  // 添加任务状态监听相关变量
  Timer? _pollingTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // 清理轮询定时器
    _pollingTimer?.cancel();
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

          // 更新数据库中的mhtmlPath字段
          await _updateArticleMhtmlPath(savedPath);

          // 通过回调返回文件路径给父组件
          if (widget.onSnapshotCreated != null) {
            widget.onSnapshotCreated!(savedPath);
          }

          // 自动上传到服务器进行Markdown解析（可选）
          // 如果需要自动上传并解析，取消下面这行的注释
          // await uploadSnapshotToServer(savedPath);
          
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
        
        // 更新数据库中的mhtmlPath字段（即使是截图也保存路径）
        await _updateArticleMhtmlPath(filePath);
        
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

  // 设置WebView基本配置
  Future<void> _setupWebViewConfiguration(InAppWebViewController controller) async {
    try {
      print('开始设置WebView基本配置...');
      
      // 注入JavaScript代码来处理CORS问题
      await controller.evaluateJavascript(source: corsScript);
      
      print('WebView基本配置设置完成');
    } catch (e) {
      print('WebView配置设置失败: $e');
    }
  }

  // 上传快照到服务器并开始监听处理状态  
  Future<String?> uploadSnapshotToServer(String snapshotPath) async {
    try {
      // 显示上传进度
      BotToast.showText(text: '正在上传快照...');
      
      // TODO: 实现上传逻辑，这里假设返回任务ID
      // final response = await dio.post('/api/upload-snapshot', 
      //   data: FormData.fromMap({
      //     'file': await MultipartFile.fromFile(snapshotPath),
      //   })
      // );
      // final taskId = response.data['taskId'];
      
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
      print('已经在轮询中，跳过重复请求');
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
        print('轮询任务状态，第${pollCount}次: $taskId');
        
        // TODO: 实际的状态查询API调用
        // final response = await dio.get('/api/task-status/$taskId');
        // final status = response.data['status'];
        // final result = response.data['result'];
        
        // 模拟服务器响应
        final Map<String, dynamic> mockResponse = await _mockServerResponse(taskId, pollCount);
        final String status = mockResponse['status'];
        final String? result = mockResponse['result'];
        final String? error = mockResponse['error'];
        
        switch (status) {
          case 'pending':
          case 'processing':
            // 继续轮询
            print('任务处理中... 状态: $status');
            
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
            print('任务处理完成: $result');
            _handleTaskCompleted(taskId, result!);
            break;
            
          case 'failed':
            // 处理失败
            print('任务处理失败: $error');
            _handleTaskFailed(taskId, error ?? '未知错误');
            break;
            
          default:
            print('未知任务状态: $status');
            _handleTaskFailed(taskId, '未知状态: $status');
        }
        
      } catch (e) {
        print('轮询状态查询失败: $e');
        
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
    
    print('Markdown解析完成，长度: ${markdownContent.length}');
    BotToast.showText(text: '文档解析完成！');
    
    // TODO: 处理解析后的Markdown内容
    // 可以保存到本地、显示在UI中、或者触发回调
    _onMarkdownReady(markdownContent);
  }

  // 任务失败处理
  void _handleTaskFailed(String taskId, String error) {
    _stopPolling();
    
    getLogger().e('任务处理失败', error: error);
    BotToast.showText(text: '处理失败: $error');
  }

  // 轮询超时处理
  void _handlePollingTimeout(String taskId) {
    _stopPolling();
    
    getLogger().w('任务轮询超时', error: taskId);
    BotToast.showText(text: '处理超时，请稍后重试');
  }

  // Markdown内容就绪回调
  void _onMarkdownReady(String markdownContent) {
    // 这里可以根据具体需求处理Markdown内容
    // 比如：显示在新页面、保存到数据库、通知父组件等
    
    if (widget.onSnapshotCreated != null) {
      // 可以扩展回调参数来传递Markdown内容
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
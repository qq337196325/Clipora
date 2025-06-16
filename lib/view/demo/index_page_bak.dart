import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import '../../../route/route_name.dart';

/// InAppWebView 功能演示页面
/// 此页面展示了 flutter_inappwebview 库的主要功能：
/// 1. 基本网页加载
/// 2. JavaScript 交互
/// 3. 网页截图（使用screenshot库保存）
/// 4. 页面控制（前进、后退、刷新）
/// 5. URL 拦截
/// 6. Cookie 管理
/// 7. 截图查看
class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  // WebView 控制器，用于控制网页行为
  InAppWebViewController? webViewController;
  
  // 截图控制器
  ScreenshotController screenshotController = ScreenshotController();
  
  // 页面加载进度
  double progress = 0;
  
  // 当前URL
  String currentUrl = "";
  
  // 是否可以后退
  bool canGoBack = false;
  
  // 是否可以前进
  bool canGoForward = false;
  
  // 文本控制器，用于URL输入
  final TextEditingController urlController = TextEditingController();

  // 是否正在执行完整截图
  bool isCapturingFullPage = false;

  // 是否自动隐藏浮动元素
  bool autoHideFloatingElements = true;

  @override
  void initState() {
    super.initState();
    // 设置默认URL - 使用HTTPS
    urlController.text = "https://www.baidu.com";
    // 请求存储权限
    _requestPermissions();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  /// 请求存储权限
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // 请求存储相关权限
        var storageStatus = await Permission.storage.status;
        var photosStatus = await Permission.photos.status;
        
        // 如果权限未授予，则请求权限
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }
        
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
        }
        
        print('存储权限状态: $storageStatus');
        print('照片权限状态: $photosStatus');
        
        // 检查权限是否被永久拒绝
        if (storageStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
          BotToast.showText(
            text: "存储权限被拒绝，请在设置中手动开启",
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('权限请求失败: $e');
      BotToast.showText(text: "权限请求失败: $e");
    }
  }

  /// 获取Android版本（简化实现）
  Future<int> _getAndroidVersion() async {
    // 简化实现，实际项目中可以使用device_info_plus包
    return 33; // 假设为Android 13+
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "InAppWebView Demo",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          // 查看截图按钮
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: () => context.push('/${RouteName.screenshotGallery}'),
            tooltip: "查看截图",
          ),
          // 完整网页截图按钮
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: isCapturingFullPage ? null : _captureFullPageScreenshot,
            tooltip: "完整网页截图",
          ),
          // 普通截图按钮
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _takeWebViewScreenshot,
            tooltip: "当前视图截图",
          ),
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => webViewController?.reload(),
            tooltip: "刷新页面",
          ),
        ],
      ),
      body: Column(
        children: [
          // URL 输入栏
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      hintText: "请输入网址",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (value) => _loadUrl(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _loadUrl(urlController.text),
                  child: const Text("访问"),
                ),
              ],
            ),
          ),
          
          // 导航控制栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: canGoBack ? Colors.blue : Colors.grey,
                  ),
                  onPressed: canGoBack ? () => webViewController?.goBack() : null,
                  tooltip: "后退",
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: canGoForward ? Colors.blue : Colors.grey,
                  ),
                  onPressed: canGoForward ? () => webViewController?.goForward() : null,
                  tooltip: "前进",
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.blue),
                  onPressed: () => _loadUrl("https://www.baidu.com"),
                  tooltip: "首页",
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.deepPurple),
                  onPressed: () => context.push('/${RouteName.shareReceive}'),
                  tooltip: "分享功能",
                ),
                IconButton(
                  icon: const Icon(Icons.code, color: Colors.blue),
                  onPressed: _executeJavaScript,
                  tooltip: "执行JS",
                ),
                IconButton(
                  icon: const Icon(Icons.cookie, color: Colors.blue),
                  onPressed: _manageCookies,
                  tooltip: "Cookie管理",
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report, color: Colors.orange),
                  onPressed: _createTestScreenshot,
                  tooltip: "测试截图",
                ),
                IconButton(
                  icon: const Icon(Icons.photo_size_select_large, color: Colors.green),
                  onPressed: isCapturingFullPage ? null : _captureFullPageScreenshot,
                  tooltip: "完整页面截图",
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                  onPressed: isCapturingFullPage ? null : _captureWithJavaScript,
                  tooltip: "JS增强截图",
                ),
                IconButton(
                  icon: Icon(
                    autoHideFloatingElements ? Icons.visibility_off : Icons.visibility,
                    color: autoHideFloatingElements ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      autoHideFloatingElements = !autoHideFloatingElements;
                    });
                    BotToast.showText(
                      text: autoHideFloatingElements ? "已开启自动隐藏浮动元素" : "已关闭自动隐藏浮动元素",
                    );
                  },
                  tooltip: "浮动元素控制",
                ),
                IconButton(
                  icon: const Icon(Icons.science, color: Colors.orange),
                  onPressed: _testFloatingElementsDetection,
                  tooltip: "测试浮动元素检测",
                ),
              ],
            ),
          ),
          
          // 加载进度条
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          
          // WebView 主体 - 包装在Screenshot widget中
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: InAppWebView(
                // 初始URL设置 - 使用HTTPS
                initialUrlRequest: URLRequest(
                  url: WebUri("https://www.baidu.com"),
                ),
                
                // 初始配置选项
                initialSettings: InAppWebViewSettings(
                  // 启用JavaScript
                  javaScriptEnabled: true,
                  // 启用DOM存储
                  domStorageEnabled: true,
                  // 允许文件访问
                  allowFileAccess: true,
                  // 允许内容访问
                  allowContentAccess: true,
                  // 启用缩放控制
                  builtInZoomControls: true,
                  // 隐藏缩放控制UI
                  displayZoomControls: false,
                  // 支持多点触控缩放
                  supportZoom: true,
                  // 设置用户代理
                  userAgent: "Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Mobile Safari/537.36",
                  // 缓存模式
                  cacheMode: CacheMode.LOAD_DEFAULT,
                  // 允许混合内容（HTTP和HTTPS）
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                ),
                
                // WebView 创建完成回调
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  
                  // 添加JavaScript处理程序
                  controller.addJavaScriptHandler(
                    handlerName: 'flutterHandler',
                    callback: (args) {
                      // 处理来自JavaScript的消息
                      if (mounted) {
                        BotToast.showText(text: "收到JS消息: ${args.first}");
                      }
                      return "Flutter 已收到消息";
                    },
                  );
                },
                
                // 页面开始加载
                onLoadStart: (controller, url) {
                  if (mounted) {
                    setState(() {
                      currentUrl = url.toString();
                      urlController.text = currentUrl;
                    });
                    // 减少提示频率，只在用户主动输入URL时显示
                    print("开始加载: $url");
                  }
                },
                
                // 页面加载完成
                onLoadStop: (controller, url) async {
                  if (mounted) {
                    setState(() {
                      currentUrl = url.toString();
                    });
                    
                    // 更新导航状态
                    _updateNavigationState();
                    
                    print("加载完成: $url");
                  }
                },
                
                // 加载进度回调
                onProgressChanged: (controller, progress) {
                  if (mounted) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  }
                },
                
                // 页面加载错误
                onLoadError: (controller, url, code, message) {
                  if (mounted) {
                    print("加载失败: $message (Code: $code)");
                    BotToast.showText(text: "加载失败: $message");
                  }
                },
                
                // URL 变化监听
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  _updateNavigationState();
                },
                
                // 拦截网络请求
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url!;
                  
                  // 示例：拦截特定域名
                  if (uri.host.contains('example.com')) {
                    if (mounted) {
                      BotToast.showText(text: "拦截了对 example.com 的访问");
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                  
                  return NavigationActionPolicy.ALLOW;
                },
                
                // 处理JavaScript的alert对话框
                onJsAlert: (controller, jsAlertRequest) async {
                  return JsAlertResponse(
                    handledByClient: true,
                    action: JsAlertResponseAction.CONFIRM,
                  );
                },
                
                // 处理JavaScript的confirm对话框
                onJsConfirm: (controller, jsConfirmRequest) async {
                  return JsConfirmResponse(
                    handledByClient: true,
                    action: JsConfirmResponseAction.CONFIRM,
                  );
                },
              ),
            ),
          ),
          
          // 底部信息栏
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text(
                  "当前URL: $currentUrl",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCapturingFullPage)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "正在生成完整网页截图...",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 加载指定URL
  void _loadUrl(String url) {
    if (url.isNotEmpty) {
      // 确保URL包含协议，优先使用HTTPS
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    }
  }

  /// 更新导航状态
  void _updateNavigationState() async {
    if (webViewController != null) {
      final canBack = await webViewController!.canGoBack();
      final canForward = await webViewController!.canGoForward();
      
      setState(() {
        canGoBack = canBack;
        canGoForward = canForward;
      });
    }
  }

  /// 执行JavaScript代码示例
  void _executeJavaScript() async {
    if (webViewController != null) {
      try {
        // 示例1: 获取页面标题
        final title = await webViewController!.evaluateJavascript(
          source: "document.title",
        );
        
        // 示例2: 修改页面内容
        await webViewController!.evaluateJavascript(
          source: """
            // 创建一个提示框
            var div = document.createElement('div');
            div.style.cssText = 'position:fixed;top:10px;right:10px;background:red;color:white;padding:10px;z-index:9999;border-radius:5px;';
            div.innerHTML = 'Hello from Flutter!';
            document.body.appendChild(div);
            
            // 3秒后移除
            setTimeout(function() {
              document.body.removeChild(div);
            }, 3000);
            
            // 调用Flutter处理程序
            window.flutter_inappwebview.callHandler('flutterHandler', '来自JavaScript的问候');
          """,
        );
        
        BotToast.showText(text: "页面标题: $title");
      } catch (e) {
        BotToast.showText(text: "JavaScript执行失败: $e");
      }
    }
  }

  /// 使用Screenshot库保存网页截图
  Future<void> _takeWebViewScreenshot() async {
    try {
      print("开始执行截图操作...");
      BotToast.showText(text: "正在截图...");

      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        final photosStatus = await Permission.photos.status;

        if (!storageStatus.isGranted && !photosStatus.isGranted) {
          BotToast.showText(text: "没有存储权限，请先授权");
          _requestPermissions();
          return;
        }
        print("权限检查通过");
      }

      if (webViewController != null) {
        print("开始使用WebView原生截图...");
        // 添加一个短延迟，确保页面渲染完成
        // 有时这有助于获取正确的 WebView 内容截图
        await Future.delayed(const Duration(milliseconds: 500));
        final Uint8List? screenshotBytes = await webViewController!.takeScreenshot();

        if (screenshotBytes != null && screenshotBytes.isNotEmpty) {
          print("WebView原生截图成功，大小: \${screenshotBytes.length} bytes");
          await _saveScreenshotToFile(screenshotBytes);
        } else {
          print("WebView原生截图失败：返回的截图数据为空或无效");
          BotToast.showText(text: "截图失败：无法从WebView获取图像数据");
        }
      } else {
        print("WebView控制器为空，无法截图");
        BotToast.showText(text: "WebView未初始化，无法截图");
      }
    } catch (e) {
      print("截图过程中发生错误: $e");
      BotToast.showText(text: "截图失败: $e");
    }
  }

  /// 保存截图到文件
  Future<void> _saveScreenshotToFile(Uint8List imageBytes) async {
    try {
      print("开始保存截图文件...");
      
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      print("应用文档目录: ${directory.path}");
      
      final screenshotDir = Directory('${directory.path}/screenshots');
      
      // 创建screenshots目录（如果不存在）
      if (!await screenshotDir.exists()) {
        print("创建screenshots目录...");
        await screenshotDir.create(recursive: true);
      }
      
      print("screenshots目录存在: ${await screenshotDir.exists()}");
      
      // 生成文件名（使用当前时间戳）
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'screenshot_$timestamp.png';
      final file = File('${screenshotDir.path}/$fileName');
      
      print("准备保存文件: ${file.path}");
      
      // 写入文件
      await file.writeAsBytes(imageBytes);
      
      // 验证文件是否成功保存
      final fileExists = await file.exists();
      final fileSize = await file.length();
      
      print("文件保存结果:");
      print("- 文件存在: $fileExists");
      print("- 文件大小: $fileSize bytes");
      print("- 文件路径: ${file.path}");
      
      if (fileExists && fileSize > 0) {
        BotToast.showText(
          text: "截图保存成功！\n文件：$fileName\n大小：${(fileSize / 1024).toStringAsFixed(1)} KB", 
          duration: const Duration(seconds: 3),
        );
        print("截图保存成功: ${file.path}");
      } else {
        throw Exception("文件保存验证失败");
      }
    } catch (e) {
      print("保存截图失败详细错误: $e");
      BotToast.showText(text: "保存截图失败: $e");
    }
  }

  /// Cookie 管理示例
  void _manageCookies() async {
    if (webViewController != null) {
      try {
        final cookieManager = CookieManager.instance();
        
        // 设置Cookie
        await cookieManager.setCookie(
          url: WebUri(currentUrl),
          name: "demo_cookie",
          value: "flutter_demo_value",
          maxAge: 3600, // 1小时过期
        );
        
        // 获取Cookie
        final cookies = await cookieManager.getCookies(url: WebUri(currentUrl));
        
        String cookieInfo = "当前域名的Cookie:\n";
        for (var cookie in cookies) {
          cookieInfo += "${cookie.name}: ${cookie.value}\n";
        }
        
        BotToast.showText(text: cookieInfo.isEmpty ? "没有Cookie" : cookieInfo);
      } catch (e) {
        BotToast.showText(text: "Cookie操作失败: $e");
      }
    }
  }

  /// 创建测试截图
  void _createTestScreenshot() async {
    try {
      print("开始创建测试截图...");
      BotToast.showText(text: "正在创建测试截图...");
      
      // 创建一个简单的测试图片数据（1x1像素的PNG格式）
      // PNG文件头 + 简单的图片数据
      final List<int> pngData = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG签名
        0x00, 0x00, 0x00, 0x0D, // IHDR块长度
        0x49, 0x48, 0x44, 0x52, // IHDR
        0x00, 0x00, 0x00, 0x01, // 宽度：1
        0x00, 0x00, 0x00, 0x01, // 高度：1
        0x08, 0x02, 0x00, 0x00, 0x00, // 位深度、颜色类型等
        0x90, 0x77, 0x53, 0xDE, // CRC
        0x00, 0x00, 0x00, 0x0C, // IDAT块长度
        0x49, 0x44, 0x41, 0x54, // IDAT
        0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, // 图片数据
        0xE2, 0x21, 0xBC, 0x33, // CRC
        0x00, 0x00, 0x00, 0x00, // IEND块长度
        0x49, 0x45, 0x4E, 0x44, // IEND
        0xAE, 0x42, 0x60, 0x82  // CRC
      ];
      
      final Uint8List testImage = Uint8List.fromList(pngData);
      
      // 保存测试截图
      await _saveScreenshotToFile(testImage);
      
      print("测试截图创建完成");
    } catch (e) {
      print("创建测试截图失败: $e");
      BotToast.showText(text: "创建测试截图失败: $e");
    }
  }

  /// 获取页面高度的JavaScript代码
  String get _getPageDimensionsJS => '''
    (function() {
      const body = document.body;
      const html = document.documentElement;
      
      const height = Math.max(
        body.scrollHeight, body.offsetHeight,
        html.clientHeight, html.scrollHeight, html.offsetHeight
      );
      
      const width = Math.max(
        body.scrollWidth, body.offsetWidth,
        html.clientWidth, html.scrollWidth, html.offsetWidth
      );
      
      const viewportHeight = window.innerHeight;
      const viewportWidth = window.innerWidth;
      
      return {
        pageHeight: height,
        pageWidth: width,
        viewportHeight: viewportHeight,
        viewportWidth: viewportWidth
      };
    })();
  ''';

  /// 检测并隐藏浮动元素的JavaScript代码
  String get _hideFloatingElementsJS => '''
    (function() {
      // 记录被隐藏的元素，用于恢复
      window.hiddenFloatingElements = window.hiddenFloatingElements || [];
      
      // 清空之前的记录
      window.hiddenFloatingElements = [];
      
      // 检测固定定位元素
      const fixedElements = [];
      const allElements = document.querySelectorAll('*');
      
      allElements.forEach(element => {
        const style = window.getComputedStyle(element);
        const position = style.position;
        const zIndex = parseInt(style.zIndex) || 0;
        
        // 检测固定定位或粘性定位的元素
        if (position === 'fixed' || position === 'sticky') {
          // 排除一些不应该隐藏的元素
          const tagName = element.tagName.toLowerCase();
          const className = element.className || '';
          const id = element.id || '';
          
          // 常见的浮动元素特征
          const isFloatingElement = 
            // 浮动按钮
            className.includes('float') || 
            className.includes('fab') || 
            className.includes('fixed') ||
            className.includes('sticky') ||
            className.includes('top') ||
            className.includes('bottom') ||
            // 返回顶部按钮
            className.includes('back-to-top') ||
            className.includes('go-top') ||
            className.includes('scroll-top') ||
            // 导航栏
            className.includes('navbar') ||
            className.includes('header') ||
            // 广告
            className.includes('ad') ||
            className.includes('banner') ||
            // 弹窗
            className.includes('modal') ||
            className.includes('popup') ||
            className.includes('dialog') ||
            // 高层级元素
            zIndex > 100;
          
          // 检查元素位置是否在视口边缘（可能是浮动按钮）
          const rect = element.getBoundingClientRect();
          const isAtEdge = rect.right > window.innerWidth - 100 || 
                          rect.bottom > window.innerHeight - 100 ||
                          rect.top < 100 || 
                          rect.left < 100;
          
          if (isFloatingElement || (position === 'fixed' && isAtEdge)) {
            fixedElements.push({
              element: element,
              originalDisplay: style.display,
              originalVisibility: style.visibility,
              reason: isFloatingElement ? 'class/id match' : 'edge position'
            });
          }
        }
      });
      
      // 隐藏检测到的浮动元素
      fixedElements.forEach(item => {
        item.element.style.display = 'none';
        window.hiddenFloatingElements.push(item);
      });
      
      console.log('隐藏了', fixedElements.length, '个浮动元素:', fixedElements.map(item => ({
        tag: item.element.tagName,
        class: item.element.className,
        id: item.element.id,
        reason: item.reason
      })));
      
      return {
        hiddenCount: fixedElements.length,
        elements: fixedElements.map(item => ({
          tag: item.element.tagName,
          className: item.element.className,
          id: item.element.id,
          reason: item.reason
        }))
      };
    })();
  ''';

  /// 恢复浮动元素的JavaScript代码
  String get _restoreFloatingElementsJS => '''
    (function() {
      if (window.hiddenFloatingElements && window.hiddenFloatingElements.length > 0) {
        window.hiddenFloatingElements.forEach(item => {
          item.element.style.display = item.originalDisplay;
          item.element.style.visibility = item.originalVisibility;
        });
        
        const restoredCount = window.hiddenFloatingElements.length;
        window.hiddenFloatingElements = [];
        
        console.log('恢复了', restoredCount, '个浮动元素');
        return { restoredCount: restoredCount };
      }
      return { restoredCount: 0 };
    })();
  ''';

  /// 滚动到指定位置的JavaScript代码
  String _scrollToPositionJS(int y) => '''
    window.scrollTo(0, $y);
    new Promise(resolve => setTimeout(resolve, 800));
  ''';

  /// 重置滚动位置的JavaScript代码
  String get _resetScrollJS => '''
    window.scrollTo(0, 0);
    new Promise(resolve => setTimeout(resolve, 500));
  ''';

  /// 捕获完整网页截图
  Future<void> _captureFullPageScreenshot() async {
    if (webViewController == null || isCapturingFullPage) return;

    setState(() {
      isCapturingFullPage = true;
    });

    try {
      BotToast.showText(text: "开始分析页面结构...");
      
      // 1. 检测并隐藏浮动元素（如果用户开启了此功能）
      int hiddenCount = 0;
      if (autoHideFloatingElements) {
        final hiddenResult = await webViewController!.evaluateJavascript(
          source: _hideFloatingElementsJS,
        );
        
        final hiddenInfo = hiddenResult as Map<String, dynamic>;
        hiddenCount = hiddenInfo['hiddenCount'] as int;
        print("隐藏了 $hiddenCount 个浮动元素");
        
        if (hiddenCount > 0) {
          BotToast.showText(text: "已隐藏 $hiddenCount 个浮动元素，开始截图...");
          // 等待DOM更新
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } else {
        BotToast.showText(text: "保留浮动元素，开始截图...");
      }
      
      // 2. 获取页面尺寸信息
      final dimensionsResult = await webViewController!.evaluateJavascript(
        source: _getPageDimensionsJS,
      );
      
      print("页面尺寸信息: $dimensionsResult");
      
      final dimensions = dimensionsResult as Map<String, dynamic>;
      final pageHeight = (dimensions['pageHeight'] as num).toInt();
      final viewportHeight = (dimensions['viewportHeight'] as num).toInt();
      
      print("页面总高度: $pageHeight, 视口高度: $viewportHeight");
      
      if (pageHeight <= viewportHeight) {
        // 页面内容小于等于视口高度，使用普通截图
        BotToast.showText(text: "页面内容较短，使用普通截图...");
        
        // 等待一下再截图，确保隐藏效果生效
        await Future.delayed(const Duration(milliseconds: 300));
        final screenshot = await webViewController!.takeScreenshot();
        if (screenshot != null) {
          await _saveFullPageScreenshot(screenshot);
        }
        
        // 恢复浮动元素
        await webViewController!.evaluateJavascript(source: _resetScrollJS);
        
        // 9. 恢复浮动元素（如果之前隐藏了）
        if (autoHideFloatingElements && hiddenCount > 0) {
          final restoreResult = await webViewController!.evaluateJavascript(
            source: _restoreFloatingElementsJS,
          );
          final restoreInfo = restoreResult as Map<String, dynamic>;
          print("恢复了 ${restoreInfo['restoredCount']} 个浮动元素");
        }
        
        BotToast.showText(
          text: "完整网页截图保存成功！${hiddenCount > 0 ? '\n已处理 $hiddenCount 个浮动元素' : ''}",
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      // 3. 计算需要截图的段数
      final segmentCount = (pageHeight / viewportHeight).ceil();
      print("需要截图段数: $segmentCount");
      
      BotToast.showText(text: "开始分段截图，共需要 $segmentCount 段...");
      
      // 4. 重置到页面顶部
      await webViewController!.evaluateJavascript(source: _resetScrollJS);
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // 5. 分段截图
      List<Uint8List> screenshots = [];
      
      for (int i = 0; i < segmentCount; i++) {
        final progress = (i + 1) / segmentCount;
        BotToast.showText(
          text: "截图进度: ${(progress * 100).toInt()}% ($i/${segmentCount-1})",
        );
        
        // 滚动到指定位置
        final scrollY = i * viewportHeight;
        print("滚动到位置: $scrollY");
        
        await webViewController!.evaluateJavascript(
          source: _scrollToPositionJS(scrollY),
        );
        await Future.delayed(const Duration(milliseconds: 1200)); // 等待滚动和渲染完成
        
        // 截图当前视图
        final screenshot = await webViewController!.takeScreenshot();
        if (screenshot != null && screenshot.isNotEmpty) {
          screenshots.add(screenshot);
          print("第 ${i+1} 段截图成功，大小: ${screenshot.length} bytes");
        } else {
          print("第 ${i+1} 段截图失败");
        }
      }
      
      print("所有段截图完成，共 ${screenshots.length} 张");
      
      if (screenshots.isEmpty) {
        throw Exception("没有成功截取到任何图片段");
      }
      
      BotToast.showText(text: "正在拼接图片...");
      
      // 6. 拼接图片
      final combinedImage = await _combineScreenshots(screenshots);
      
      // 7. 保存最终图片
      await _saveFullPageScreenshot(combinedImage);
      
      // 8. 重置滚动位置
      await webViewController!.evaluateJavascript(source: _resetScrollJS);
      
      // 9. 恢复浮动元素（如果之前隐藏了）
      if (autoHideFloatingElements && hiddenCount > 0) {
        final restoreResult = await webViewController!.evaluateJavascript(
          source: _restoreFloatingElementsJS,
        );
        final restoreInfo = restoreResult as Map<String, dynamic>;
        print("恢复了 ${restoreInfo['restoredCount']} 个浮动元素");
      }
      
      BotToast.showText(
        text: "完整网页截图保存成功！${hiddenCount > 0 ? '\n已处理 $hiddenCount 个浮动元素' : ''}",
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      print("完整网页截图失败: $e");
      BotToast.showText(text: "完整网页截图失败: $e");
      
      // 确保恢复浮动元素（只在开启自动隐藏时）
      if (autoHideFloatingElements) {
        try {
          await webViewController!.evaluateJavascript(source: _restoreFloatingElementsJS);
        } catch (restoreError) {
          print("恢复浮动元素失败: $restoreError");
        }
      }
      
    } finally {
      setState(() {
        isCapturingFullPage = false;
      });
    }
  }

  /// 拼接多张截图
  Future<Uint8List> _combineScreenshots(List<Uint8List> screenshots) async {
    if (screenshots.isEmpty) {
      throw Exception("没有图片需要拼接");
    }
    
    if (screenshots.length == 1) {
      return screenshots.first;
    }
    
    try {
      print("开始使用image包拼接 ${screenshots.length} 张图片...");
      
      // 解码所有图片
      List<img.Image> images = [];
      for (int i = 0; i < screenshots.length; i++) {
        final image = img.decodeImage(screenshots[i]);
        if (image != null) {
          images.add(image);
          print("成功解码第 ${i+1} 张图片，尺寸: ${image.width}x${image.height}");
        } else {
          print("第 ${i+1} 张图片解码失败");
        }
      }
      
      if (images.isEmpty) {
        throw Exception("没有成功解码的图片");
      }
      
      // 计算最终图片尺寸
      final firstImage = images.first;
      final finalWidth = firstImage.width;
      int finalHeight = 0;
      
      for (var image in images) {
        finalHeight += image.height;
      }
      
      print("最终图片尺寸: ${finalWidth}x${finalHeight}");
      
      // 创建最终图片画布
      final combinedImage = img.Image(
        width: finalWidth,
        height: finalHeight,
      );
      
      // 填充白色背景
      img.fill(combinedImage, color: img.ColorRgb8(255, 255, 255));
      
      // 垂直拼接所有图片
      int currentY = 0;
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        print("拼接第 ${i+1} 张图片到位置 Y: $currentY");
        
        img.compositeImage(
          combinedImage,
          image,
          dstX: 0,
          dstY: currentY,
        );
        
        currentY += image.height;
      }
      
      print("图片拼接完成，开始编码...");
      
      // 编码为PNG格式
      final pngBytes = img.encodePng(combinedImage);
      print("PNG编码完成，最终大小: ${pngBytes.length} bytes");
      
      return Uint8List.fromList(pngBytes);
      
    } catch (e) {
      print("图片拼接失败: $e");
      // 拼接失败时返回第一张图片
      return screenshots.first;
    }
  }

  /// 保存完整网页截图
  Future<void> _saveFullPageScreenshot(Uint8List imageBytes) async {
    try {
      print("开始保存完整网页截图...");
      
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final screenshotDir = Directory('${directory.path}/screenshots');
      
      // 创建目录
      if (!await screenshotDir.exists()) {
        await screenshotDir.create(recursive: true);
      }
      
      // 生成文件名
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'fullpage_screenshot_$timestamp.png';
      final file = File('${screenshotDir.path}/$fileName');
      
      // 写入文件
      await file.writeAsBytes(imageBytes);
      
      // 验证文件
      final fileExists = await file.exists();
      final fileSize = await file.length();
      
      if (fileExists && fileSize > 0) {
        print("完整网页截图保存成功: ${file.path}");
      } else {
        throw Exception("文件保存验证失败");
      }
      
    } catch (e) {
      print("保存完整网页截图失败: $e");
      rethrow;
    }
  }

  /// 使用JavaScript增强的截图方法
  Future<void> _captureWithJavaScript() async {
    if (webViewController == null || isCapturingFullPage) return;

    setState(() {
      isCapturingFullPage = true;
    });

    try {
      BotToast.showText(text: "正在加载截图工具...");
      
      // 如果开启了浮动元素隐藏，先执行隐藏
      int hiddenCount = 0;
      if (autoHideFloatingElements) {
        final hiddenResult = await webViewController!.evaluateJavascript(
          source: _hideFloatingElementsJS,
        );
        final hiddenInfo = hiddenResult as Map<String, dynamic>;
        hiddenCount = hiddenInfo['hiddenCount'] as int;
        
        if (hiddenCount > 0) {
          BotToast.showText(text: "已隐藏 $hiddenCount 个浮动元素");
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      // 注入JavaScript截图工具
      await _injectFullPageCaptureScript();
      
      // 添加JavaScript消息处理器
      await _setupJavaScriptHandlers();
      
      BotToast.showText(text: "开始JavaScript增强截图...");
      
      // 启动JavaScript控制的截图流程
      await webViewController!.evaluateJavascript(
        source: 'window.startFullPageCapture();',
      );
      
    } catch (e) {
      print("JavaScript增强截图失败: $e");
      BotToast.showText(text: "JavaScript增强截图失败: $e");
      
      // 确保恢复浮动元素
      if (autoHideFloatingElements) {
        try {
          await webViewController!.evaluateJavascript(source: _restoreFloatingElementsJS);
        } catch (restoreError) {
          print("恢复浮动元素失败: $restoreError");
        }
      }
      
      setState(() {
        isCapturingFullPage = false;
      });
    }
  }

  /// 注入完整网页截图JavaScript工具
  Future<void> _injectFullPageCaptureScript() async {
    const script = '''
      // 完整网页截图JavaScript工具
      (function() {
        if (window.fullPageCaptureLoaded) return;
        
        // 获取页面尺寸
        function getPageDimensions() {
          const body = document.body;
          const html = document.documentElement;
          return {
            pageHeight: Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight),
            pageWidth: Math.max(body.scrollWidth, body.offsetWidth, html.clientWidth, html.scrollWidth, html.offsetWidth),
            viewportHeight: window.innerHeight,
            viewportWidth: window.innerWidth
          };
        }
        
        // 滚动控制
        function scrollToPosition(y) {
          return new Promise((resolve) => {
            window.scrollTo(0, y);
            setTimeout(() => {
              resolve({
                targetY: y,
                actualY: window.pageYOffset || document.documentElement.scrollTop
              });
            }, 800);
          });
        }
        
        // 启动完整截图流程
        window.startFullPageCapture = async function() {
          try {
            const dimensions = getPageDimensions();
            const segmentCount = Math.ceil(dimensions.pageHeight / dimensions.viewportHeight);
            
            // 通知Flutter开始
            window.flutter_inappwebview.callHandler('onJSCaptureStart', {
              segmentCount: segmentCount,
              dimensions: dimensions
            });
            
            // 重置到顶部
            await scrollToPosition(0);
            
            // 分段处理
            for (let i = 0; i < segmentCount; i++) {
              const y = i * dimensions.viewportHeight;
              await scrollToPosition(y);
              
              // 通知Flutter截图
              window.flutter_inappwebview.callHandler('onJSSegmentReady', {
                segmentIndex: i,
                segmentCount: segmentCount,
                progress: (i + 1) / segmentCount
              });
              
              // 等待Flutter完成
              await new Promise(resolve => setTimeout(resolve, 1000));
            }
            
            // 重置位置
            await scrollToPosition(0);
            
            // 通知完成
            window.flutter_inappwebview.callHandler('onJSCaptureComplete', {
              segmentCount: segmentCount
            });
            
          } catch (error) {
            window.flutter_inappwebview.callHandler('onJSCaptureError', {
              error: error.message
            });
          }
        };
        
        window.fullPageCaptureLoaded = true;
        console.log('完整网页截图工具已注入');
      })();
    ''';
    
    await webViewController!.evaluateJavascript(source: script);
  }

  /// 设置JavaScript消息处理器
  Future<void> _setupJavaScriptHandlers() async {
    // JavaScript开始截图
    webViewController!.addJavaScriptHandler(
      handlerName: 'onJSCaptureStart',
      callback: (args) {
        final data = args.first as Map<String, dynamic>;
        final segmentCount = data['segmentCount'] as int;
        print("JavaScript截图开始，共需要 $segmentCount 段");
        BotToast.showText(text: "JavaScript分析完成，开始分段截图...");
        return "收到开始信号";
      },
    );
    
    // 准备截图当前段
    webViewController!.addJavaScriptHandler(
      handlerName: 'onJSSegmentReady',
      callback: (args) async {
        final data = args.first as Map<String, dynamic>;
        final segmentIndex = data['segmentIndex'] as int;
        final segmentCount = data['segmentCount'] as int;
        final progress = data['progress'] as double;
        
        print("准备截图第 ${segmentIndex + 1}/$segmentCount 段");
        BotToast.showText(text: "截图进度: ${(progress * 100).toInt()}%");
        
        // 执行截图
        await Future.delayed(const Duration(milliseconds: 200));
        final screenshot = await webViewController!.takeScreenshot();
        
        if (screenshot != null) {
          // 这里可以将截图保存到临时列表中
          print("第 ${segmentIndex + 1} 段截图成功");
        }
        
        return "段截图完成";
      },
    );
    
    // JavaScript截图完成
    webViewController!.addJavaScriptHandler(
      handlerName: 'onJSCaptureComplete',
      callback: (args) async {
        final data = args.first as Map<String, dynamic>;
        final segmentCount = data['segmentCount'] as int;
        print("JavaScript截图流程完成，共 $segmentCount 段");
        
        // 恢复浮动元素
        if (autoHideFloatingElements) {
          try {
            final restoreResult = await webViewController!.evaluateJavascript(
              source: _restoreFloatingElementsJS,
            );
            final restoreInfo = restoreResult as Map<String, dynamic>;
            print("恢复了 ${restoreInfo['restoredCount']} 个浮动元素");
          } catch (restoreError) {
            print("恢复浮动元素失败: $restoreError");
          }
        }
        
        BotToast.showText(text: "JavaScript增强截图完成！");
        
        setState(() {
          isCapturingFullPage = false;
        });
        
        return "截图流程完成";
      },
    );
    
    // JavaScript截图错误
    webViewController!.addJavaScriptHandler(
      handlerName: 'onJSCaptureError',
      callback: (args) {
        final data = args.first as Map<String, dynamic>;
        final error = data['error'] as String;
        print("JavaScript截图失败: $error");
        BotToast.showText(text: "JavaScript截图失败: $error");
        
        setState(() {
          isCapturingFullPage = false;
        });
        
        return "收到错误信号";
      },
    );
  }

  /// 测试浮动元素检测
  void _testFloatingElementsDetection() async {
    if (webViewController != null) {
      try {
        print("开始测试浮动元素检测...");
        BotToast.showText(text: "正在检测浮动元素...");
        
        // 执行JavaScript代码
        final result = await webViewController!.evaluateJavascript(
          source: _hideFloatingElementsJS,
        );
        
        if (result is Map<String, dynamic>) {
          final hiddenCount = result['hiddenCount'] as int;
          final hiddenElements = result['elements'] as List<dynamic>;
          
          if (hiddenCount > 0) {
            print("检测到 $hiddenCount 个浮动元素");
            BotToast.showText(text: "检测到 $hiddenCount 个浮动元素");
          } else {
            print("没有检测到浮动元素");
            BotToast.showText(text: "没有检测到浮动元素");
          }
        } else {
          print("检测结果格式错误");
          BotToast.showText(text: "检测结果格式错误");
        }
      } catch (e) {
        print("浮动元素检测失败: $e");
        BotToast.showText(text: "浮动元素检测失败: $e");
      }
    } else {
      print("WebView控制器为空，无法检测浮动元素");
      BotToast.showText(text: "WebView未初始化，无法检测浮动元素");
    }
  }
}
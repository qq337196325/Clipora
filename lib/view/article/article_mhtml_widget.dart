// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';

import '../../basics/logger.dart';
import 'controller/article_controller.dart';

class ArticleMhtmlWidget extends StatefulWidget {
  final String mhtmlPath; // MHTML文件路径
  final String? title; // 可选的标题显示
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final VoidCallback? onTap; // 添加点击回调
  final EdgeInsetsGeometry contentPadding;

  const ArticleMhtmlWidget({
    super.key,
    required this.mhtmlPath,
    this.title,
    this.onScroll,
    this.onTap, // 添加点击回调
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  State<ArticleMhtmlWidget> createState() => ArticleMhtmlWidgetState();
}

class ArticleMhtmlWidgetState extends State<ArticleMhtmlWidget>
    with ArticlePageBLoC {
  double _lastScrollY = 0.0;

  /// 重新加载当前快照
  /// 供外部调用的公开方法
  Future<void> reloadSnapshot() async {
    await _reloadMhtml();
  }

  /// 加载新的快照文件
  /// [newMhtmlPath] 新的MHTML文件路径
  /// 供外部调用的公开方法，用于加载新生成的快照
  Future<void> loadNewSnapshot(String newMhtmlPath) async {
    getLogger().i('🔄 加载新的快照文件: $newMhtmlPath');

    // 重置状态
    setState(() {
      hasError = false;
      errorMessage = '';
      isLoading = true;
    });

    // 先验证新的快照文件
    final isValid = await validateSnapshotFile(newMhtmlPath);
    if (!isValid) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // 如果路径相同，直接重新加载
    if (newMhtmlPath == widget.mhtmlPath) {
      await _reloadMhtml();
      return;
    }

    // 如果路径不同，需要重新加载新的URL
    if (webViewController != null) {
      final newUrl = 'file://$newMhtmlPath';
      getLogger().i('📄 加载新快照URL: $newUrl');
      await webViewController!
          .loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
    } else {
      // 如果WebView控制器不存在，重新初始化
      await _initializeMhtmlView();
    }
  }

  /// 获取当前快照的加载状态
  /// 供外部查询使用
  bool get isSnapshotLoading => isLoading;

  /// 获取当前快照是否有错误
  /// 供外部查询使用
  bool get hasSnapshotError => hasError;

  /// 获取当前快照的错误信息
  /// 供外部查询使用
  String get snapshotErrorMessage => errorMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // 可以选择性地控制哪些边需要安全区域
      top: true, // 避免刘海屏遮挡
      bottom: false, // 如果需要沉浸式底部，可以设为false
      child: Column(
        children: [
          // 加载进度条
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
                    'i18n_article_快照加载失败'.tr,
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
                  ElevatedButton(
                    onPressed: () => _reloadMhtml(),
                    child: Text('i18n_article_重新加载'.tr),
                  ),
                ],
              ),
            ),
          // WebView显示MHTML内容
          if (!hasError)
            Expanded(
              child: InAppWebView(
                // initialUrlRequest: URLRequest(url: WebUri(mhtmlFileUrl)),
                // initialUrlRequest: URLRequest(url: WebUri(mhtmlFileUrl)),
                // initialFile: "${articleController.currentArticle!.localMhtmlPath}/index.html",
                // 尝试多种加载方式
                initialUrlRequest: _getInitialUrlRequest(),
                // initialSettings: WebViewSettings.getWebViewSettings(),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  
                  // 执行详细的路径检查
                  _performDetailedPathCheck();
                  
                  getLogger().i('MHTML WebView创建成功');
                },
                onLoadStart: (controller, url) {
                  getLogger().i('🚀 开始加载MHTML: $url');
                  getLogger().i('🚀 URL类型: ${url?.scheme}');
                  getLogger().i('🚀 URL路径: ${url?.path}');
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                },
                onLoadStop: (controller, url) async {
                  getLogger().i('MHTML加载完成: $url');
                  setState(() {
                    isLoading = false;
                  });

                  // 注入移动端弹窗处理脚本 - 恢复滚动功能
                  // await WebViewUtils.injectMobilePopupHandler(controller);

                  // // 注入页面点击监听器
                  // await _injectPageClickListener();
                  //
                  // // 页面加载完成后进行优化设置
                  // finalizeWebPageOptimization(url,webViewController);
                  //
                  // // 注入内边距
                  // final padding = widget.contentPadding.resolve(Directionality.of(context));
                  // controller.evaluateJavascript(source: '''
                  //   document.body.style.paddingTop = '${padding.top}px';
                  //   document.body.style.paddingBottom = '${padding.bottom}px';
                  //   document.body.style.paddingLeft = '${padding.left}px';
                  //   document.body.style.paddingRight = '${padding.right}px';
                  //   document.documentElement.style.scrollPaddingTop = '${padding.top}px';
                  // ''');
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    loadingProgress = progress / 100;
                  });
                },
                onReceivedError: (controller, request, error) {
                  getLogger().e('MHTML加载错误', error: error.description);
                  getLogger().e('请求URL: ${request.url}');
                  getLogger().e('错误类型: ${error.type}');
                  // getLogger().e('错误代码: ${error.code}');
                  
                  // 添加详细的文件检查信息
                  final localMhtmlPath = articleController.currentArticle?.localMhtmlPath;
                  if (localMhtmlPath != null) {
                    final htmlPath = '$localMhtmlPath/index.html';
                    final htmlFile = File(htmlPath);
                    getLogger().e('HTML文件路径: $htmlPath');
                    getLogger().e('HTML文件存在: ${htmlFile.existsSync()}');
                    
                    final dir = Directory(localMhtmlPath);
                    if (dir.existsSync()) {
                      getLogger().e('目录内容:');
                      try {
                        dir.listSync().forEach((entity) {
                          getLogger().e('  ${entity.path}');
                        });
                      } catch (e) {
                        getLogger().e('无法列出目录内容: $e');
                      }
                    }
                  }

                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'i18n_article_加载错误文件路径'.trParams({
                      'description': error.description ?? '',
                      'path': request.url?.toString() ?? widget.mhtmlPath
                    });
                  });
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  getLogger().e('MHTML HTTP错误',
                      error:
                          '${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');

                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'i18n_article_HTTP错误'.trParams({
                      'statusCode': errorResponse.statusCode.toString(),
                      'reasonPhrase': errorResponse.reasonPhrase ?? ''
                    });
                  });
                },
                onScrollChanged: (controller, x, y) {
                  final scrollY = y.toDouble();
                  // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
                  if ((scrollY - _lastScrollY).abs() > 15) {
                    final direction = scrollY > _lastScrollY
                        ? ScrollDirection.reverse
                        : ScrollDirection.forward;
                    widget.onScroll?.call(direction, scrollY);
                    _lastScrollY = scrollY;
                  }
                },
                shouldOverrideUrlLoading: _handleOptimizedUrlNavigation,
                // 设置控制台消息处理
                onConsoleMessage: (controller, consoleMessage) {
                  getLogger().d('MHTML Console: ${consoleMessage.message}');
                },
              ),
            ),
        ],
      ),
    );
  }
}

mixin ArticlePageBLoC on State<ArticleMhtmlWidget> {

  final ArticleController articleController = Get.find<ArticleController>();

  // WebView控制器
  InAppWebViewController? webViewController;

  // 加载状态
  bool isLoading = true;
  double loadingProgress = 0.0;

  // 错误状态
  bool hasError = false;
  String errorMessage = '';

  // 获取MHTML文件的URL
  String get mhtmlFileUrl {
    final file = File(widget.mhtmlPath);
    if (!file.existsSync()) {
      getLogger().e('MHTML文件不存在: ${widget.mhtmlPath}');
      return '';
    }

    // 使用file协议加载本地文件
    return 'file://${widget.mhtmlPath}';
    // return '${widget.mhtmlPath}';
  }

  // 智能获取初始URL请求
  URLRequest _getInitialUrlRequest() {
    final localMhtmlPath = articleController.currentArticle?.localMhtmlPath;
    
    if (localMhtmlPath != null && localMhtmlPath.isNotEmpty) {
      // 首先尝试加载解压后的HTML文件
      final htmlPath = '$localMhtmlPath/index.html';
      final htmlFile = File(htmlPath);
      
      getLogger().i('🔍 检查HTML文件: $htmlPath');
      
      if (htmlFile.existsSync()) {
        getLogger().i('✅ 使用解压后的HTML文件: $htmlPath');
        // Android使用file://协议，不需要额外的斜杠
        final finalUrl = 'file://$htmlPath';
        getLogger().i('🔗 构建的URL: $finalUrl');
        return URLRequest(url: WebUri(finalUrl));
      } else {
        getLogger().w('⚠️ HTML文件不存在，回退到MHTML: $htmlPath');
      }
    }
    
    // 如果HTML文件不存在，回退到加载原始MHTML文件
    final mhtmlFile = File(widget.mhtmlPath);
    if (mhtmlFile.existsSync()) {
      getLogger().i('📄 使用原始MHTML文件: ${widget.mhtmlPath}');
      final finalUrl = 'file://${widget.mhtmlPath}';
      getLogger().i('🔗 构建的MHTML URL: $finalUrl');
      return URLRequest(url: WebUri(finalUrl));
    }
    
    // 如果都不存在，返回空URL（会触发错误）
    getLogger().e('❌ 没有找到可用的文件进行加载');
    return URLRequest(url: WebUri('about:blank'));
  }
   
   // 执行详细的路径检查
   void _performDetailedPathCheck() {
     getLogger().i('=== 开始详细路径检查 ===');
     
     final localMhtmlPath = articleController.currentArticle?.localMhtmlPath;
     final mhtmlPath = widget.mhtmlPath;
     
     getLogger().i('localMhtmlPath: $localMhtmlPath');
     getLogger().i('mhtmlPath: $mhtmlPath');
     
     // 检查localMhtmlPath目录
     if (localMhtmlPath != null && localMhtmlPath.isNotEmpty) {
       final dir = Directory(localMhtmlPath);
       getLogger().i('检查目录: ${dir.path}');
       getLogger().i('目录存在: ${dir.existsSync()}');
       
       if (dir.existsSync()) {
         try {
           final entities = dir.listSync();
           getLogger().i('目录内容 (${entities.length} 个项目):');
           for (final entity in entities) {
             if (entity is File) {
               final file = entity;
               getLogger().i('  文件: ${file.path} (${file.lengthSync()} bytes)');
             } else if (entity is Directory) {
               getLogger().i('  目录: ${entity.path}');
             }
           }
           
           // 特别检查index.html
           final htmlPath = '$localMhtmlPath/index.html';
           final htmlFile = File(htmlPath);
           getLogger().i('index.html路径: $htmlPath');
           getLogger().i('index.html存在: ${htmlFile.existsSync()}');
           if (htmlFile.existsSync()) {
             getLogger().i('index.html大小: ${htmlFile.lengthSync()} bytes');
             // 读取文件开头内容
             try {
               final content = htmlFile.readAsStringSync();
               final preview = content.length > 200 ? content.substring(0, 200) : content;
               getLogger().i('index.html内容预览: $preview...');
             } catch (e) {
               getLogger().e('无法读取index.html内容: $e');
             }
           }
         } catch (e) {
           getLogger().e('无法列出目录内容: $e');
         }
       }
     }
     
     // 检查原始MHTML文件
     final mhtmlFile = File(mhtmlPath);
     getLogger().i('MHTML文件: $mhtmlPath');
     getLogger().i('MHTML文件存在: ${mhtmlFile.existsSync()}');
     if (mhtmlFile.existsSync()) {
       getLogger().i('MHTML文件大小: ${mhtmlFile.lengthSync()} bytes');
     }
     
     getLogger().i('=== 路径检查完成 ===');
   }


  @override
  void initState() {
    super.initState();


    print("2222222222222222222");
    print(articleController.currentArticle?.localMhtmlPath);
    
    // 调试：检查HTML文件路径
    final htmlPath = "${articleController.currentArticle?.localMhtmlPath}/index.html";
    print("HTML文件路径: $htmlPath");
    final htmlFile = File(htmlPath);
    print("HTML文件是否存在: ${htmlFile.existsSync()}");
    if (htmlFile.existsSync()) {
      print("HTML文件大小: ${htmlFile.lengthSync()} bytes");
    }
    
    // 检查目录内容
    final dir = Directory(articleController.currentArticle?.localMhtmlPath ?? "");
    if (dir.existsSync()) {
      print("目录内容:");
      dir.listSync().forEach((entity) {
        print("  ${entity.path}");
      });
    } else {
      print("目录不存在: ${articleController.currentArticle?.localMhtmlPath}");
    }

    _initializeMhtmlView();
  }


  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  // 初始化MHTML视图
  Future<void> _initializeMhtmlView() async {
    try {
      final localMhtmlPath = articleController.currentArticle?.localMhtmlPath;
      getLogger().i('📄 初始化MHTML视图，localMhtmlPath: $localMhtmlPath');
      getLogger().i('📄 widget.mhtmlPath: ${widget.mhtmlPath}');

      // 优先检查解压后的HTML文件
      if (localMhtmlPath != null && localMhtmlPath.isNotEmpty) {
        final htmlPath = '$localMhtmlPath/index.html';
        final htmlFile = File(htmlPath);
        
        getLogger().i('📄 检查HTML文件: $htmlPath');
        
        if (htmlFile.existsSync()) {
          final fileSize = await htmlFile.length();
          getLogger().i('📄 HTML文件大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');
          getLogger().i('✅ HTML文件检查通过，准备加载');
          return; // HTML文件存在，直接返回
        } else {
          getLogger().w('⚠️ HTML文件不存在: $htmlPath');
        }
      }

      // 回退检查原始MHTML文件
      final file = File(widget.mhtmlPath);
      if (!file.existsSync()) {
        setState(() {
          hasError = true;
          errorMessage =
              'i18n_article_快照文件不存在'.trParams({'path': widget.mhtmlPath});
          isLoading = false;
        });
        return;
      }

      // 检查MHTML文件大小
      final fileSize = await file.length();
      getLogger().i('📄 MHTML文件大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      if (fileSize == 0) {
        setState(() {
          hasError = true;
          errorMessage =
              'i18n_article_快照文件为空'.trParams({'path': widget.mhtmlPath});
          isLoading = false;
        });
        return;
      }

      getLogger().i('✅ MHTML文件检查通过，准备加载');
    } catch (e) {
      getLogger().e('❌ 初始化MHTML视图失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '${'i18n_article_初始化失败'.tr}$e';
        isLoading = false;
      });
    }
  }

  // 重新加载MHTML
  Future<void> _reloadMhtml() async {
    getLogger().i('🔄 重新加载MHTML快照');

    setState(() {
      hasError = false;
      errorMessage = '';
      isLoading = true;
    });

    if (webViewController != null) {

      await webViewController!.reload();
    } else {
      // 如果WebView控制器不存在，重新初始化
      await _initializeMhtmlView();
    }
    setState(() {});
  }

  // 验证快照文件是否有效
  Future<bool> validateSnapshotFile(String filePath) async {
    try {
      final file = File(filePath);

      // 检查文件是否存在
      if (!file.existsSync()) {
        getLogger().e('❌ 快照文件不存在: $filePath');
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件不存在'.trParams({'path': filePath});
        });
        return false;
      }

      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize == 0) {
        getLogger().e('❌ 快照文件为空: $filePath');
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件为空'.trParams({'path': filePath});
        });
        return false;
      }

      getLogger().i(
          '✅ 快照文件验证通过: $filePath (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      return true;
    } catch (e) {
      getLogger().e('❌ 验证快照文件失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '${'i18n_article_初始化失败'.tr}$e';
      });
      return false;
    }
  }

  // 获取当前页面信息（调试用）
  Future<void> getPageInfo() async {
    if (webViewController == null) return;

    try {
      final url = await webViewController!.getUrl();
      final title = await webViewController!.getTitle();

      getLogger().i('📄 当前页面信息:');
      getLogger().i('  URL: $url');
      getLogger().i('  标题: $title');
    } catch (e) {
      getLogger().e('❌ 获取页面信息失败: $e');
    }
  }

  /// 优化的URL导航处理
  Future<NavigationActionPolicy> _handleOptimizedUrlNavigation(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final uri = navigationAction.request.url!;
    final url = uri.toString();

    getLogger().d('🌐 URL跳转拦截: $url');

    // 检查是否是自定义scheme（非http/https）
    if (!url.startsWith('http://') &&
        !url.startsWith('https://') &&
        !url.startsWith('file://')) {
      getLogger().w('⚠️ 拦截自定义scheme跳转: ${uri.scheme}://');
      return NavigationActionPolicy.CANCEL;
    }

    // 检查是否是应用内跳转scheme
    if (url.startsWith('snssdk') ||
        url.startsWith('sslocal') ||
        url.startsWith('toutiao') ||
        url.startsWith('newsarticle') ||
        url.startsWith('zhihu')) {
      // 明确拦截知乎的App拉起协议
      getLogger().w('⚠️ 拦截应用跳转scheme: $url');
      return NavigationActionPolicy.CANCEL;
    }

    // 允许正常的HTTP/HTTPS链接
    getLogger().d('✅ 允许正常HTTP跳转: $url');
    return NavigationActionPolicy.ALLOW;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';

import '../../../../basics/logger.dart';
import '../web/utils/snapshot_style_sync.dart';



/// ArticleMhtmlWidget - 快照文章显示组件
/// 
/// 重构后的组件使用状态驱动的方式，移除了公共方法，通过状态变化和回调函数进行通信。
/// 
/// 主要特性：
/// - 移除了 loadNewSnapshot 和 reloadSnapshot 公共方法
/// - 实现基于状态的快照加载机制
/// - 添加快照加载状态的回调通知
/// - 支持状态驱动的新快照加载和当前快照重新加载
/// 
/// 状态驱动属性：
/// - shouldLoadNewSnapshot: 触发加载新快照
/// - newSnapshotPath: 新快照文件路径
/// - onSnapshotLoadComplete: 新快照加载完成回调
/// - shouldReloadSnapshot: 触发重新加载当前快照
/// - onSnapshotReloadComplete: 快照重新加载完成回调

class ArticleMhtmlWidget extends StatefulWidget {
  final String mhtmlPath;  // MHTML文件路径
  final String? title;     // 可选的标题显示
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final VoidCallback? onTap; // 添加点击回调
  final EdgeInsetsGeometry contentPadding;
  
  // 状态驱动的属性 - 移除公共方法，使用状态驱动
  final bool shouldLoadNewSnapshot;
  final String? newSnapshotPath;
  final VoidCallback? onSnapshotLoadComplete;
  final bool shouldReloadSnapshot;
  final VoidCallback? onSnapshotReloadComplete;
  
  const ArticleMhtmlWidget({
    super.key,
    required this.mhtmlPath,
    this.title,
    this.onScroll,
    this.onTap, // 添加点击回调
    this.contentPadding = EdgeInsets.zero,
    // 状态驱动的属性
    this.shouldLoadNewSnapshot = false,
    this.newSnapshotPath,
    this.onSnapshotLoadComplete,
    this.shouldReloadSnapshot = false,
    this.onSnapshotReloadComplete,
  });

  @override
  State<ArticleMhtmlWidget> createState() => ArticleMhtmlWidgetState();
}

class ArticleMhtmlWidgetState extends State<ArticleMhtmlWidget> with ArticlePageBLoC {
  double _lastScrollY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                initialUrlRequest: URLRequest(url: WebUri(mhtmlFileUrl)),
                initialSettings: optimizedWebViewSettings,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  getLogger().i('📱 MHTML WebView创建成功');
                },
                onLoadStart: (controller, url) {
                  getLogger().i('🔄 开始加载MHTML: $url');
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                },
                onLoadStop: (controller, url) async {
                  getLogger().i('✅ MHTML加载完成: $url');
                  setState(() {
                    isLoading = false;
                  });

                  // 使用新的样式同步工具优化MHTML显示效果
                  await SnapshotStyleSync.optimizeForMhtmlDisplay(controller);
                  
                  // 注入页面点击监听器
                  await _injectPageClickListener();
                  
                  // 注入内边距
                  await _applyContentPadding(controller);
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    loadingProgress = progress / 100;
                  });
                },
                onReceivedError: (controller, request, error) {
                  getLogger().e('MHTML加载错误', error: error.description);
                  
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'i18n_article_加载错误文件路径'.trParams({
                      'description': error.description ?? 'Unknown error',
                      'path': widget.mhtmlPath
                    });
                  });
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  getLogger().e('MHTML HTTP错误', error: '${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                  
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'i18n_article_HTTP错误'.trParams({
                      'statusCode': errorResponse.statusCode.toString(),
                      'reasonPhrase': errorResponse.reasonPhrase ?? 'Unknown error'
                    });
                  });
                },
                onScrollChanged: (controller, x, y) {
                  final scrollY = y.toDouble();
                  // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
                  if ((scrollY - _lastScrollY).abs() > 15) {
                    final direction = scrollY > _lastScrollY ? ScrollDirection.reverse : ScrollDirection.forward;
                    widget.onScroll?.call(direction, scrollY);
                    _lastScrollY = scrollY;
                  }
                },
                // 设置控制台消息处理
                onConsoleMessage: (controller, consoleMessage) {
                  getLogger().d('MHTML Console: ${consoleMessage.message}');
                },
              ),
            ),
        ],
      );
  }
}

/// @deprecated This mixin should be refactored to use state-driven approach
/// instead of direct method calls. Consider using callbacks and state variables.
mixin ArticlePageBLoC on State<ArticleMhtmlWidget> {
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
  }
  
  // WebView设置 - 针对MHTML文件优化，确保与原网页显示一致
  InAppWebViewSettings get optimizedWebViewSettings => InAppWebViewSettings(
    // ==== 核心功能设置 ====
    javaScriptEnabled: true,
    domStorageEnabled: true,
    
    // ==== 本地文件访问设置 ====
    allowFileAccess: true,
    allowContentAccess: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    
    // ==== 缓存设置 - 优化快照显示 ====
    clearCache: false,
    cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
    
    // ==== 安全设置（适用于本地文件） ====
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    
    // ==== 用户代理 - 与生成快照时保持一致 ====
    userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
    
    // ==== 视口和缩放设置 - 确保布局一致性 ====
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    
    // ==== 渲染设置 - 优化显示效果 ====
    blockNetworkImage: false,
    blockNetworkLoads: false,
    loadsImagesAutomatically: true,
    
    // ==== 字体和渲染优化 ====
    minimumFontSize: 0,
    defaultFontSize: 16,
    defaultFixedFontSize: 13,
    
    // ==== 媒体设置 ====
    mediaPlaybackRequiresUserGesture: false,
    
    // ==== 滚动条设置 ====
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: true,
    
    // ==== 禁用URL跳转拦截（本地文件不需要） ====
    useShouldOverrideUrlLoading: false,
    
    // ==== 确保样式完整性 ====
    forceDark: ForceDark.OFF, // 禁用强制暗色模式
    algorithmicDarkeningAllowed: false, // 禁用算法暗化
  );

  @override
  void initState() {
    super.initState();
    _initializeMhtmlView();
  }
  
  /// 处理加载新快照 - 基于状态驱动的快照加载机制
  Future<void> _handleLoadNewSnapshot(String newSnapshotPath) async {
    try {
      getLogger().i('🔄 开始加载新快照: $newSnapshotPath');
      
      // 验证新快照文件
      final isValid = await validateSnapshotFile(newSnapshotPath);
      if (!isValid) {
        getLogger().e('❌ 新快照文件验证失败');
        widget.onSnapshotLoadComplete?.call();
        return;
      }
      
      // 设置加载状态
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
      
      // 构建新的文件URL
      final newFileUrl = 'file://$newSnapshotPath';
      getLogger().i('🔄 加载新快照URL: $newFileUrl');
      
      // 加载新的快照文件
      if (webViewController != null) {
        await webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(newFileUrl))
        );
        getLogger().i('✅ 新快照加载请求已发送');
      } else {
        getLogger().e('❌ WebView控制器不可用，无法加载新快照');
        setState(() {
          hasError = true;
          errorMessage = 'WebView控制器不可用';
          isLoading = false;
        });
      }
      
      // 通知加载完成（实际加载完成会在onLoadStop中处理）
      widget.onSnapshotLoadComplete?.call();
      
    } catch (e) {
      getLogger().e('❌ 加载新快照失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '加载新快照失败: $e';
        isLoading = false;
      });
      widget.onSnapshotLoadComplete?.call();
    }
  }

  /// 处理重新加载快照 - 基于状态驱动的快照重新加载机制
  Future<void> _handleReloadSnapshot() async {
    try {
      getLogger().i('🔄 开始重新加载当前快照');
      
      // 验证当前快照文件
      final isValid = await validateSnapshotFile(widget.mhtmlPath);
      if (!isValid) {
        getLogger().e('❌ 当前快照文件验证失败');
        widget.onSnapshotReloadComplete?.call();
        return;
      }
      
      // 设置加载状态
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
      
      // 重新加载当前快照
      if (webViewController != null) {
        await webViewController!.reload();
        getLogger().i('✅ 快照重新加载请求已发送');
      } else {
        getLogger().e('❌ WebView控制器不可用，无法重新加载快照');
        setState(() {
          hasError = true;
          errorMessage = 'WebView控制器不可用';
          isLoading = false;
        });
      }
      
      // 通知重新加载完成（实际加载完成会在onLoadStop中处理）
      widget.onSnapshotReloadComplete?.call();
      
    } catch (e) {
      getLogger().e('❌ 重新加载快照失败: $e');
      setState(() {
        hasError = true;
        errorMessage = '重新加载快照失败: $e';
        isLoading = false;
      });
      widget.onSnapshotReloadComplete?.call();
    }
  }
  
  @override
  void didUpdateWidget(ArticleMhtmlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 监听新快照加载状态变化
    if (widget.shouldLoadNewSnapshot && !oldWidget.shouldLoadNewSnapshot) {
      getLogger().i('🔄 检测到新快照加载状态变化');
      if (widget.newSnapshotPath != null && widget.newSnapshotPath!.isNotEmpty) {
        _handleLoadNewSnapshot(widget.newSnapshotPath!);
      }
    }
    
    // 监听快照重新加载状态变化
    if (widget.shouldReloadSnapshot && !oldWidget.shouldReloadSnapshot) {
      getLogger().i('🔄 检测到快照重新加载状态变化');
      _handleReloadSnapshot();
    }
  }

  /// 处理页面点击事件
  void _handlePageClick(List<dynamic> args) {
    getLogger().d('🎯 MHTML页面被点击');
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  /// 注入页面点击监听器
  Future<void> _injectPageClickListener() async {
    try {
      getLogger().d('🔄 开始注入MHTML页面点击监听器...');
      
      // 注册JavaScript Handler
      webViewController!.addJavaScriptHandler(
        handlerName: 'onPageClicked',
        callback: _handlePageClick,
      );
      
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          // 防止重复注册
          if (window.mhtmlPageClickListenerInstalled) {
            console.log('⚠️ MHTML页面点击监听器已存在，跳过重复注册');
            return;
          }
          
          // 添加全局点击事件监听器
          document.addEventListener('click', function(e) {
            try {
              console.log('🎯 检测到MHTML页面点击');
              
              // 调用Flutter Handler
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('onPageClicked', {
                  timestamp: Date.now(),
                  target: e.target.tagName,
                  type: 'mhtml'
                });
                console.log('✅ MHTML页面点击数据已发送到Flutter');
              } else {
                console.error('❌ Flutter桥接不可用，无法发送MHTML页面点击数据');
              }
            } catch (error) {
              console.error('❌ 处理MHTML页面点击异常:', error);
            }
          }, false);
          
          // 标记监听器已安装
          window.mhtmlPageClickListenerInstalled = true;
          console.log('✅ MHTML页面点击监听器安装完成');
          
        })();
      ''');

      getLogger().i('✅ MHTML页面点击监听脚本注入成功');

    } catch (e) {
      getLogger().e('❌ 注入MHTML页面点击监听脚本失败: $e');
    }
  }

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  // 初始化MHTML视图
  Future<void> _initializeMhtmlView() async {
    try {
      getLogger().i('📄 初始化MHTML视图，文件路径: ${widget.mhtmlPath}');
      
      // 检查文件是否存在
      final file = File(widget.mhtmlPath);
      if (!file.existsSync()) {
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件不存在'.trParams({'path': widget.mhtmlPath});
          isLoading = false;
        });
        return;
      }
      
      // 检查文件大小
      final fileSize = await file.length();
      getLogger().i('📄 MHTML文件大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      if (fileSize == 0) {
        setState(() {
          hasError = true;
          errorMessage = 'i18n_article_快照文件为空'.trParams({'path': widget.mhtmlPath});
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



  /// 应用内容边距
  Future<void> _applyContentPadding(InAppWebViewController controller) async {
    try {
      final padding = widget.contentPadding.resolve(Directionality.of(context));
      
      if (padding != EdgeInsets.zero) {
        getLogger().i('📐 应用内容边距: top=${padding.top}, bottom=${padding.bottom}, left=${padding.left}, right=${padding.right}');
        
        await controller.evaluateJavascript(source: '''
          (function() {
            // 应用内容边距
            const paddingStyle = document.createElement('style');
            paddingStyle.id = 'content-padding';
            paddingStyle.textContent = `
              body {
                padding-top: ${padding.top}px !important;
                padding-bottom: ${padding.bottom}px !important;
                padding-left: ${padding.left}px !important;
                padding-right: ${padding.right}px !important;
                box-sizing: border-box !important;
              }
              
              html {
                scroll-padding-top: ${padding.top}px !important;
              }
            `;
            
            // 移除旧的边距样式
            const oldPaddingStyle = document.getElementById('content-padding');
            if (oldPaddingStyle) {
              oldPaddingStyle.remove();
            }
            
            document.head.appendChild(paddingStyle);
            console.log('📐 内容边距应用完成');
          })();
        ''');
      }
      
    } catch (e) {
      getLogger().e('❌ 应用内容边距失败: $e');
    }
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
      
      getLogger().i('✅ 快照文件验证通过: $filePath (${(fileSize / 1024).toStringAsFixed(2)} KB)');
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

  // /// 处理加载新快照 - 基于状态驱动的快照加载机制
  // Future<void> _handleLoadNewSnapshot(String newSnapshotPath) async {
  //   try {
  //     getLogger().i('🔄 开始加载新快照: $newSnapshotPath');
  //
  //     // 验证新快照文件
  //     final isValid = await validateSnapshotFile(newSnapshotPath);
  //     if (!isValid) {
  //       getLogger().e('❌ 新快照文件验证失败');
  //       widget.onSnapshotLoadComplete?.call();
  //       return;
  //     }
  //
  //     // 设置加载状态
  //     setState(() {
  //       isLoading = true;
  //       hasError = false;
  //       errorMessage = '';
  //     });
  //
  //     // 构建新的文件URL
  //     final newFileUrl = 'file://$newSnapshotPath';
  //     getLogger().i('🔄 加载新快照URL: $newFileUrl');
  //
  //     // 加载新的快照文件
  //     if (webViewController != null) {
  //       await webViewController!.loadUrl(
  //         urlRequest: URLRequest(url: WebUri(newFileUrl))
  //       );
  //       getLogger().i('✅ 新快照加载请求已发送');
  //     } else {
  //       getLogger().e('❌ WebView控制器不可用，无法加载新快照');
  //       setState(() {
  //         hasError = true;
  //         errorMessage = 'WebView控制器不可用';
  //         isLoading = false;
  //       });
  //     }
  //
  //     // 通知加载完成（实际加载完成会在onLoadStop中处理）
  //     widget.onSnapshotLoadComplete?.call();
  //
  //   } catch (e) {
  //     getLogger().e('❌ 加载新快照失败: $e');
  //     setState(() {
  //       hasError = true;
  //       errorMessage = '加载新快照失败: $e';
  //       isLoading = false;
  //     });
  //     widget.onSnapshotLoadComplete?.call();
  //   }
  // }

  // /// 处理重新加载快照 - 基于状态驱动的快照重新加载机制
  // Future<void> _handleReloadSnapshot() async {
  //   try {
  //     getLogger().i('🔄 开始重新加载当前快照');
  //
  //     // 验证当前快照文件
  //     final isValid = await validateSnapshotFile(widget.mhtmlPath);
  //     if (!isValid) {
  //       getLogger().e('❌ 当前快照文件验证失败');
  //       widget.onSnapshotReloadComplete?.call();
  //       return;
  //     }
  //
  //     // 设置加载状态
  //     setState(() {
  //       isLoading = true;
  //       hasError = false;
  //       errorMessage = '';
  //     });
  //
  //     // 重新加载当前快照
  //     if (webViewController != null) {
  //       await webViewController!.reload();
  //       getLogger().i('✅ 快照重新加载请求已发送');
  //     } else {
  //       getLogger().e('❌ WebView控制器不可用，无法重新加载快照');
  //       setState(() {
  //         hasError = true;
  //         errorMessage = 'WebView控制器不可用';
  //         isLoading = false;
  //       });
  //     }
  //
  //     // 通知重新加载完成（实际加载完成会在onLoadStop中处理）
  //     widget.onSnapshotReloadComplete?.call();
  //
  //   } catch (e) {
  //     getLogger().e('❌ 重新加载快照失败: $e');
  //     setState(() {
  //       hasError = true;
  //       errorMessage = '重新加载快照失败: $e';
  //       isLoading = false;
  //     });
  //     widget.onSnapshotReloadComplete?.call();
  //   }
  // }





}

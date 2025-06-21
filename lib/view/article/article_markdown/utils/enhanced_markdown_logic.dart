import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../../../basics/logger.dart';
import '../../../../db/article/article_db.dart';
import '../../../../db/article/article_service.dart';
import '../../../../db/annotation/enhanced_annotation_db.dart';
import '../../../../db/annotation/enhanced_annotation_service.dart';
import 'basic_scripts_logic.dart';
import 'simple_markdown_renderer.dart';
import 'selection_menu_logic.dart';

/// 增强版ArticleMarkdownWidget的业务逻辑核心
/// 
/// 基于Range API实现精确文本标注，支持：
/// - 跨段落选择和标注
/// - 精确的XPath定位
/// - 多重恢复策略
/// - 完整的标注生命周期管理
mixin EnhancedMarkdownLogic<T extends StatefulWidget> on State<T>, SelectionMenuLogic<T> {
  // === 可访问的属性 ===
  @protected
  InAppWebViewController? webViewController;
  @protected
  @override
  ArticleDb? get article;
  @protected
  @override
  GlobalKey get webViewKey;
  @protected
  @override
  late BasicScriptsLogic basicScriptsLogic;
  @protected
  @override
  EdgeInsetsGeometry get contentPadding;

  // === 内部状态 ===
  bool isLoading = true;
  bool isVisuallyRestoring = false;
  Timer? _positionSaveTimer;
  String _currentSessionId = '';
  bool _isRestoringPosition = false;
  bool _isDisposed = false;
  
  DateTime? _lastSaveTime;
  static const Duration _saveInterval = Duration(seconds: 20);
  static const Duration _minSaveInterval = Duration(seconds: 5);

  // === 增强标注相关状态 === （已迁移到 SelectionMenuLogic）
  
  late final AppLifecycleObserver _lifecycleObserver;

  // === 初始化和销毁 ===
  void initEnhancedLogic() {
    _lifecycleObserver = AppLifecycleObserver(this);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _ensureResourceManagerInitialized();
    Future.microtask(() => _ensureLatestArticleData());
    _recordReadingStart();
    
    // 确保增强标注服务已注册
    _ensureEnhancedAnnotationService();
  }

  void disposeEnhancedLogic() {
    getLogger().d('🔄 EnhancedMarkdownLogic开始销毁...');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    
    disposeSelectionMenu();
    _positionSaveTimer?.cancel();
    
    if (webViewController != null && article != null) {
      _saveCurrentReadingPosition().catchError((e) {
        getLogger().d('⚠️ dispose时保存阅读位置失败: $e');
      });
    }
    getLogger().d('✅ EnhancedMarkdownLogic销毁完成');
  }

  void _ensureEnhancedAnnotationService() {
    try {
      Get.find<EnhancedAnnotationService>();
    } catch (e) {
      // 如果没有注册，就注册一个
      Get.put(EnhancedAnnotationService());
      getLogger().d('✅ EnhancedAnnotationService已注册');
    }
  }

  // === WebView 设置 ===
  void onEnhancedWebViewCreated(InAppWebViewController controller) {
    getLogger().d('🎯 onEnhancedWebViewCreated被调用');
    webViewController = controller;
    basicScriptsLogic = BasicScriptsLogic(controller);
    getLogger().d('🎯 WebView控制器和JS管理器已设置');
    _setupEnhancedWebView();
    getLogger().d('�� 增强WebView设置已启动');
    
    // 注意：不在这里调用onEnhancedWebViewLoadStop，而是在onLoadStop回调中调用
    // 这样确保页面完全加载后再初始化增强功能
    
    // 备用方案：如果5秒后onLoadStop还没被触发，强制初始化
    // _setupBackupInitialization();
  }

  


  Future<void> _setupEnhancedWebView() async {
    if (!_isWebViewAvailable()) return;
    try {
      // 使用简单的WebView设置
      await SimpleMarkdownRenderer.setupBasicWebView(webViewController!);
      getLogger().i('✅ 简单WebView设置完成');
    } catch (e) {
      getLogger().e('❌ WebView设置失败: $e');
      // 降级到传统设置
      await basicScriptsLogic.setupTraditionalResources();
    }
  }

  Future<void> onEnhancedWebViewLoadStop() async {

    getLogger().d('🔥 增强文本选择回调处理器已注册11111');
    if (!_isWebViewAvailable()) return;
    try {
      // 【重要】首先立即注册回调处理器，确保JavaScript调用时Flutter已准备好
      _setupEnhancedTextSelectionHandlers();
      getLogger().d('🔥 增强文本选择回调处理器已注册');
      
      // 短暂延迟，确保Handler注册完成
      await Future.delayed(const Duration(milliseconds: 150));
      
      // 注入基础脚本
      await basicScriptsLogic.injectBasicScripts(webViewController!);
      
      // 注入Range标注引擎（这时Handler已经准备好了）
      final injectionSuccess = await basicScriptsLogic.injectRangeAnnotationScript();
      getLogger().d('🔥 Range引擎注入结果: $injectionSuccess');
      

      // 设置图片点击处理
      await _setupImageClickHandler();
      
      // 渲染Markdown内容
      await _renderMarkdownContent();

      // 恢复历史标注
      await _restoreEnhancedAnnotations();
      
      // 恢复阅读位置
      await _restoreReadingPosition();
      
      // 开始周期性位置保存
      _startPeriodicPositionSaving();
      
      getLogger().i('✅ 增强WebView设置完成，页面已显示');
    } catch (e) {
      getLogger().e('❌ 增强WebView最终设置失败: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void _ensureResourceManagerInitialized() {
    if (_isDisposed) return;
    // 使用简单方案，无需初始化资源管理器
    getLogger().d('ℹ️ 使用简单方案，跳过资源管理器初始化');
  }

  // === 增强文本选择处理 ===
  void _setupEnhancedTextSelectionHandlers() {
    try {
      getLogger().d('🔥 开始注册增强文本选择回调处理器...');
      
      webViewController!.addJavaScriptHandler(
        handlerName: 'onEnhancedTextSelected',
        callback: handleEnhancedTextSelected,
      );
      getLogger().d('🔥 已注册: onEnhancedTextSelected');
      
      webViewController!.addJavaScriptHandler(
        handlerName: 'onEnhancedSelectionCleared',
        callback: handleEnhancedSelectionCleared,
      );
      getLogger().d('🔥 已注册: onEnhancedSelectionCleared');
      
      webViewController!.addJavaScriptHandler(
        handlerName: 'onHighlightCreated',
        callback: handleHighlightCreated,
      );
      getLogger().d('🔥 已注册: onHighlightCreated');
      
      getLogger().i('✅ 所有增强文本选择回调处理器注册完成');
      
      // 验证JavaScript桥接
      _verifyJavaScriptBridge();
      
    } catch (e) {
      getLogger().e('❌ 注册增强文本选择回调处理器失败: $e');
    }
  }

  // 验证JavaScript桥接
  Future<void> _verifyJavaScriptBridge() async {
    try {
      getLogger().d('🔄 验证JavaScript桥接...');
      
      // 检查flutter_inappwebview桥接是否可用
      final bridgeAvailable = await webViewController!.evaluateJavascript(source: '''
        (function() {
          const available = typeof window.flutter_inappwebview !== 'undefined' && 
                           typeof window.flutter_inappwebview.callHandler === 'function';
          console.log('🔍 Flutter桥接可用性:', available);
          return available;
        })();
      ''');
      
      getLogger().d('🔍 Flutter桥接可用: $bridgeAvailable');
      
      // 测试一个简单的Handler调用
      webViewController!.addJavaScriptHandler(
        handlerName: 'testHandler',
        callback: (args) {
          getLogger().d('✅ 测试Handler被成功调用: $args');
        },
      );
      
      // 从JavaScript端调用测试Handler
      await webViewController!.evaluateJavascript(source: '''
        (function() {
          console.log('🧪 测试调用Flutter Handler...');
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('testHandler', 'bridge_test_successful');
          } else {
            console.error('❌ Flutter桥接不可用');
          }
        })();
      ''');
      
    } catch (e) {
      getLogger().e('❌ 验证JavaScript桥接失败: $e');
    }
  }

  // === 选择菜单处理（已迁移到 SelectionMenuLogic） ===

  // === 增强标注恢复 ===
  Future<void> _restoreEnhancedAnnotations() async {
    if (!_isWebViewAvailable() || article == null) return;
    
    try {
      getLogger().d('🔄 开始恢复增强标注，文章ID: ${article!.id}');
      
      final annotations = await EnhancedAnnotationService.instance
          .getAnnotationsForArticle(article!.id);
      
      getLogger().i('📊 从数据库获取到 ${annotations.length} 个增强标注');
      
      if (annotations.isEmpty) {
        getLogger().d('ℹ️ 本文无历史增强标注');
        return;
      }

      // 转换为Range数据格式
      final rangeDataList = annotations
          .map((annotation) => annotation.toRangeData())
          .toList();

      // 批量恢复标注
      final stats = await basicScriptsLogic.batchRestoreAnnotations(rangeDataList);
      
      getLogger().i('✅ 增强标注恢复完成: 成功 ${stats['successCount']}, 失败 ${stats['failCount']}');

      // 如果有失败的标注，尝试逐个恢复
      if (stats['failCount']! > 0) {
        await _restoreFailedAnnotationsOneByOne(annotations);
      }

    } catch (e) {
      getLogger().e('❌ 恢复增强标注失败: $e');
    }
  }

  Future<void> _restoreFailedAnnotationsOneByOne(List<EnhancedAnnotationDb> annotations) async {
    getLogger().i('🔄 尝试逐个恢复失败的标注...');
    
    int successCount = 0;
    for (final annotation in annotations) {
      try {
        final success = await basicScriptsLogic.restoreAnnotation(
          annotation.toRangeData()
        );
        
        if (success) {
          successCount++;
        } else {
          getLogger().w('⚠️ 标注恢复失败: ${annotation.highlightId}');
        }
        
        // 添加小延迟，避免过快操作
        await Future.delayed(const Duration(milliseconds: 100));
        
      } catch (e) {
        getLogger().e('❌ 恢复标注异常: ${annotation.highlightId}, $e');
      }
    }
    
    getLogger().i('✅ 逐个恢复完成: $successCount/${annotations.length}');
  }

  // === 阅读位置逻辑（保持不变） ===
  void _recordReadingStart() {
    if (_isDisposed || article == null) return;
    
    article!.readingSessionId = _currentSessionId;
    article!.readingStartTime = DateTime.now().millisecondsSinceEpoch;
    article!.readCount += 1;
    getLogger().i('📖 开始阅读会话: $_currentSessionId');
  }

  void _startPeriodicPositionSaving() {
    if (_isDisposed) return;
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(_saveInterval, (timer) {
      if (_isDisposed || !_isWebViewAvailable()) {
        timer.cancel();
        return;
      }
      _saveCurrentReadingPosition();
    });
  }

  Future<void> _saveCurrentReadingPosition() async {
    if (_isDisposed || !_isWebViewAvailable() || article == null || _isRestoringPosition) return;
    if (!_shouldSave()) return;

    try {
      // 使用简单的滚动位置保存
      final scrollY = await webViewController!.getScrollY();
      final scrollX = await webViewController!.getScrollX();
      
      final currentScrollY = scrollY ?? 0;
      final currentScrollX = scrollX ?? 0;
      
      getLogger().d('📊 当前滚动位置: X=$currentScrollX, Y=$currentScrollY, 上次保存: Y=${article!.markdownScrollY}');
      
      if ((currentScrollY - article!.markdownScrollY).abs() > 50) {
        final newProgress = 0.0; // 简化版本，不计算进度
        
        article!
          ..markdownScrollY = currentScrollY
          ..markdownScrollX = currentScrollX
          ..readProgress = newProgress
          ..lastReadTime = DateTime.now()
          ..updatedAt = DateTime.now();
        
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (article!.readingStartTime > 0) {
          article!.readDuration += ((currentTime - article!.readingStartTime) / 1000).round();
          article!.readingStartTime = currentTime;
        }
        
        getLogger().i('💾 保存阅读位置成功: X=$currentScrollX, Y=$currentScrollY');
        await ArticleService.instance.saveArticle(article!);
        _lastSaveTime = DateTime.now();
      } else {
        getLogger().d('📍 位置变化不大，跳过保存 (差值: ${(currentScrollY - article!.markdownScrollY).abs()})');
      }
    } catch (e) {
      if (e.toString().contains('disposed')) {
        getLogger().w('⚠️ WebView已销毁，跳过保存阅读位置');
      } else {
        getLogger().e('❌ 保存阅读位置异常: $e');
      }
    }
  }

  Future<void> _restoreReadingPosition() async {
    if (!_isWebViewAvailable() || article == null) {
      getLogger().w('⚠️ WebView不可用或文章为null，跳过位置恢复');
      if (mounted && !_isDisposed) {
        setState(() { isLoading = false; });
      }
      return;
    }
    
    final hasPositionData = article!.markdownScrollY > 0;
    getLogger().i('📍 检查阅读位置: X=${article!.markdownScrollX}, Y=${article!.markdownScrollY}, 有效: $hasPositionData');
    
    if (!hasPositionData) {
      getLogger().i('ℹ️ 无保存的阅读位置，从顶部开始');
      if (mounted && !_isDisposed) {
        setState(() { isLoading = false; });
      }
      return;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        isLoading = false;
        isVisuallyRestoring = true;
      });
    }

    _isRestoringPosition = true;
    try {
      getLogger().i('🔄 开始恢复阅读位置到 X=${article!.markdownScrollX}, Y=${article!.markdownScrollY}...');
      
      // 等待DOM完全准备好
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 检查页面内容是否已加载
      final contentHeight = await webViewController!.evaluateJavascript(source: '''
        document.body.scrollHeight || document.documentElement.scrollHeight || 0;
      ''');
      
      getLogger().d('📏 页面内容高度: $contentHeight, 目标Y位置: ${article!.markdownScrollY}');
      
      if (_isWebViewAvailable()) {
        // 先尝试滚动到目标位置
        await webViewController!.scrollTo(
          x: article!.markdownScrollX,
          y: article!.markdownScrollY,
        );
        
        // 验证滚动是否成功
        await Future.delayed(const Duration(milliseconds: 200));
        final actualY = await webViewController!.getScrollY();
        final actualX = await webViewController!.getScrollX();
        
        getLogger().i('✅ 阅读位置恢复: 目标(${article!.markdownScrollX}, ${article!.markdownScrollY}) -> 实际($actualX, $actualY)');
        
        // 如果位置差异较大，可能是内容还没完全加载
        if (actualY != null && (actualY - article!.markdownScrollY).abs() > 100) {
          getLogger().w('⚠️ 位置恢复可能不准确，差异: ${(actualY - article!.markdownScrollY).abs()}px');
        }
      }
    } catch (e, stackTrace) {
       if (e.toString().contains('disposed')) {
         getLogger().w('⚠️ WebView已销毁，终止恢复阅读位置');
       } else {
         getLogger().e('❌ 恢复阅读位置异常: $e');
         getLogger().d('堆栈跟踪: $stackTrace');
       }
    } finally {
      _isRestoringPosition = false;
      if (mounted && !_isDisposed) {
        setState(() {
          isVisuallyRestoring = false;
        });
      }
    }
  }

  // === 内容渲染 ===
  Future<void> _renderMarkdownContent() async {
    final markdownContent = (this as dynamic).markdownContent as String;
    if (markdownContent.isEmpty || !_isWebViewAvailable()) {
      getLogger().w('⚠️ Markdown内容为空或WebView不可用，跳过渲染');
      return;
    }
    
    try {
      getLogger().i('🎨 开始渲染Markdown内容 (长度: ${markdownContent.length})...');
      
      // 应用内边距样式
      final paddingStyle = _getPaddingStyle();
      getLogger().d('📐 内边距样式: $paddingStyle');
      
      // 使用简单的Markdown渲染器
      final success = await SimpleMarkdownRenderer.renderMarkdown(
        webViewController!,
        markdownContent,
        paddingStyle: paddingStyle,
      );
      
      if (success) {
        getLogger().i('✅ Markdown内容渲染成功');
        
        // 等待一下让DOM稳定
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 检查渲染后的页面高度
        final contentHeight = await webViewController!.evaluateJavascript(source: '''
          document.body.scrollHeight || document.documentElement.scrollHeight || 0;
        ''');
        getLogger().d('📏 渲染后页面高度: $contentHeight');
        
        // 渲染成功后更新加载状态
        if (mounted && !_isDisposed) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        getLogger().w('⚠️ Markdown渲染失败，但继续执行');
        // 即使渲染失败也要更新加载状态，避免一直显示加载中
        if (mounted && !_isDisposed) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      getLogger().e('❌ 渲染Markdown内容异常: $e');
      // 确保即使出现异常也要更新加载状态
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  // 获取内边距样式
  String _getPaddingStyle() {
    final padding = contentPadding;
    if (padding == EdgeInsets.zero) return '';
    
    // 将EdgeInsetsGeometry转换为CSS样式
    if (padding is EdgeInsets) {
      return 'padding: ${padding.top}px ${padding.right}px ${padding.bottom}px ${padding.left}px';
    }
    return '';
  }



  // === 图片点击处理 ===
  Future<void> _setupImageClickHandler() async {
    if (!_isWebViewAvailable()) return;
    webViewController!.addJavaScriptHandler(
      handlerName: 'onImageClicked',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String imageSrc = data['src'] ?? '';
        getLogger().d('🖼️ 图片被点击: $imageSrc');
        _handleImageClicked(imageSrc);
      },
    );
    
    // 注入图片点击处理脚本
    await webViewController!.evaluateJavascript(source: '''
      document.addEventListener('click', function(e) {
        if (e.target.tagName === 'IMG') {
          e.preventDefault();
          window.flutter_inappwebview.callHandler('onImageClicked', {
            src: e.target.src
          });
        }
      });
    ''');
  }

  void _handleImageClicked(String src) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(src, fit: BoxFit.contain)
            ),
          ),
        ),
      ),
    );
  }

  // === 辅助方法 ===
  bool _isWebViewAvailable() => !_isDisposed && webViewController != null && mounted;
  bool _shouldSave() => _lastSaveTime == null || DateTime.now().difference(_lastSaveTime!) >= _minSaveInterval;
  
  /// 手动触发位置保存（用于调试）
  Future<void> manualSavePosition() async {
    getLogger().i('🔧 手动触发位置保存...');
    final oldLastSaveTime = _lastSaveTime;
    _lastSaveTime = null; // 临时重置保存时间限制
    await _saveCurrentReadingPosition();
    if (oldLastSaveTime != null) _lastSaveTime = oldLastSaveTime;
  }
  
  /// 手动触发位置恢复（用于调试）
  Future<void> manualRestorePosition() async {
    getLogger().i('🔧 手动触发位置恢复...');
    await _restoreReadingPosition();
  }

  Future<void> _ensureLatestArticleData() async {
    if (article?.id == null) return;
    try {
      final latestArticle = await ArticleService.instance.getArticleById(article!.id);
      if (latestArticle != null && !_isDisposed) {
        setState(() {
          article
          ?..markdownScrollY = latestArticle.markdownScrollY
          ..markdownScrollX = latestArticle.markdownScrollX
          ..readProgress = latestArticle.readProgress
          ..lastReadTime = latestArticle.lastReadTime
          ..readCount = latestArticle.readCount
          ..readDuration = latestArticle.readDuration;
        });
      }
    } catch(e) {
      getLogger().e('❌ 刷新文章数据失败: $e');
    }
  }

  // === _showMessage 已迁移到 SelectionMenuLogic ===


}

/// 监听应用生命周期变化的辅助类
class AppLifecycleObserver with WidgetsBindingObserver {
  final EnhancedMarkdownLogic logic;
  AppLifecycleObserver(this.logic);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (logic._isDisposed) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        logic._saveCurrentReadingPosition();
        break;
      case AppLifecycleState.resumed:
        // 恢复时可以进行一些检查
        break;
      default:
        break;
    }
  }
}
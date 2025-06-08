import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import '../../basics/logger.dart';
import '../../db/article/article_db.dart';
import '../../db/article/article_service.dart';
import 'components/markdown_webview_pool_manager.dart';


class ArticleMarkdownWidget extends StatefulWidget {
  final String? url;
  final String markdownContent;
  final ArticleDb? article;

  const ArticleMarkdownWidget({
    super.key,
    this.url,
    required this.markdownContent,
    this.article,
  });

  @override
  State<ArticleMarkdownWidget> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticleMarkdownWidget> with WidgetsBindingObserver {
  final GlobalKey _webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  String get markdownContent => widget.markdownContent;
  ArticleDb? get article => widget.article;
  bool isLoading = true;

  // 阅读位置相关
  Timer? _positionSaveTimer;
  String _currentSessionId = '';
  bool _isRestoringPosition = false;
  bool _isDisposed = false; // 添加销毁标志
  
  // 性能优化相关
  bool _hasUnsavedChanges = false; // 是否有未保存的更改
  DateTime? _lastSaveTime; // 上次保存时间
  static const Duration _saveInterval = Duration(seconds: 20); // 调整为20秒
  static const Duration _minSaveInterval = Duration(seconds: 5); // 最小保存间隔

  // 自定义选择菜单状态
  OverlayEntry? _selectionMenuOverlay;
  OverlayEntry? _backgroundCatcher;
  String _currentSelectedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 使用优化的WebView
          _buildOptimizedWebView(),
          
          // 加载指示器
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在准备文章内容...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '使用预热WebView提升性能',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptimizedWebView() {
    return InAppWebView(
      key: _webViewKey,
      initialData: InAppWebViewInitialData(
        data: WebViewPoolManager().getHtmlTemplate(),
        mimeType: "text/html",
        encoding: "utf-8",
      ),
      // 配置选项以支持自定义选择菜单
      initialSettings: InAppWebViewSettings(
        // ==== 基础设置 ====
        javaScriptEnabled: true,
        domStorageEnabled: true,
        
        // ==== 强力阻止系统默认菜单 ====
        disableContextMenu: true,  // 重新启用，配合JavaScript完全控制
        disableDefaultErrorPage: true,
        
        // ==== Android特定设置 ====
        textZoom: 100,
        supportMultipleWindows: false,
        // Android平台特殊设置
        // overScrollMode: AndroidOverScrollMode.OVER_SCROLL_NEVER,
        
        // ==== iOS特定设置 ====
        allowsInlineMediaPlayback: true,
        // iOS平台特殊设置
        disableLongPressContextMenuOnLinks: true,
        
        // ==== 触控和选择设置 ====
        supportZoom: false,  // 禁用缩放避免与选择手势冲突
        builtInZoomControls: false,
        displayZoomControls: false,
        
        // ==== 选择相关设置 ====
        disableHorizontalScroll: false,
        disableVerticalScroll: false,
        
        // ==== 用户代理设置 ====
        userAgent: "Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 InkwellReader/1.0",
        
        // ==== 安全设置 ====
        allowFileAccess: true,
        allowContentAccess: true,
        
        // ==== 缓存设置 ====
        cacheMode: CacheMode.LOAD_DEFAULT,
        
        // ==== 其他设置 ====
        clearCache: false,
        // 禁用默认的用户选择样式
        disableInputAccessoryView: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _setupWebView();
        // 设置自定义选择处理器
        _setupTextSelectionHandlers(controller);
      },
      onLoadStop: (controller, url) async {
        if (_webViewController != null) {
          await _finalizeWebViewSetup();
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        getLogger().d('WebView Console: ${consoleMessage.message}');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 生成阅读会话ID
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    
    // 确保WebView资源管理器已初始化
    _ensureResourceManagerInitialized();
    
    // 异步加载最新的文章数据，不阻塞UI初始化
    Future.microtask(() => _ensureLatestArticleData());
    
    // 开始记录阅读开始时间
    _recordReadingStart();
  }

  @override
  void dispose() {
    getLogger().d('🔄 ArticleMarkdownWidget开始销毁...');
    
    // 立即设置销毁标志，防止后续操作
    _isDisposed = true;
    
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    
    // 清理自定义选择菜单
    _hideCustomSelectionMenu();
    
    // 取消定时器
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;
    
    // 保存最终的阅读位置（仅当有未保存更改时）
    if (_webViewController != null && article != null && _hasUnsavedChanges) {
      // 异步保存，不阻塞dispose流程
      _saveCurrentReadingPosition().catchError((e) {
        getLogger().d('⚠️ dispose时保存阅读位置失败: $e');
      });
    }
    
    // 销毁WebView控制器
    _webViewController?.dispose();
    _webViewController = null;
    
    getLogger().d('✅ ArticleMarkdownWidget销毁完成');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 如果已经销毁，不执行任何操作
    if (_isDisposed) return;
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // 应用进入后台时保存阅读位置（仅当有未保存更改时）
        if (_hasUnsavedChanges) {
          _saveCurrentReadingPosition();
        }
        break;
      case AppLifecycleState.resumed:
        // 应用恢复时标记有未保存更改，下次定时器会处理
        _markUnsavedChanges();
        break;
      default:
        break;
    }
  }

  /// 记录阅读开始
  void _recordReadingStart() {
    if (_isDisposed || article == null) return;
    
    article!.readingSessionId = _currentSessionId;
    article!.readingStartTime = DateTime.now().millisecondsSinceEpoch;
    article!.readCount += 1;
    getLogger().i('📖 开始阅读会话: $_currentSessionId');
  }

  /// 确保资源管理器已初始化
  void _ensureResourceManagerInitialized() {
    if (_isDisposed) return;
    
    WebViewPoolManager().initialize().catchError((e) {
      getLogger().e('❌ 资源管理器初始化失败: $e');
    });
  }

  /// 安全检查WebView是否可用
  bool _isWebViewAvailable() {
    return !_isDisposed && _webViewController != null && mounted;
  }

  /// WebView创建时的设置
  Future<void> _setupWebView() async {
    if (!_isWebViewAvailable()) return;
    
    try {
      getLogger().i('🎯 开始设置WebView...');
      
      // 检查资源是否已预热
      if (WebViewPoolManager().isResourcesReady) {
        getLogger().i('✅ 使用预热资源快速设置');
        await WebViewPoolManager().setupOptimizedWebView(_webViewController!);
      } else {
        getLogger().w('⚠️ 资源未预热，使用传统方式加载');
        await _setupTraditionalResources();
      }
      
      getLogger().i('✅ WebView设置完成');
    } catch (e) {
      getLogger().e('❌ WebView设置失败: $e');
      // 降级到传统方式
      await _setupTraditionalResources();
    }
  }

  /// WebView加载完成后的最终设置（优化版本）
  Future<void> _finalizeWebViewSetup() async {
    if (!_isWebViewAvailable()) return;
    
    try {
      // 注入精确定位追踪脚本
      await _injectPositionTracker();
      
      // 注入文字选择处理脚本
      await _injectTextSelectionScript();
      
      // 设置图片点击处理器
      await _setupImageClickHandler();
      
      // 渲染内容
      await _renderMarkdownContent();
      
      // 减少内容渲染等待时间
      await Future.delayed(const Duration(milliseconds: 600));
      
      // 异步恢复阅读位置，不阻塞UI显示
      Future.microtask(() => _restoreReadingPosition());
      
      // 先显示内容，再开始定位
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
      
      // 开始定期保存阅读位置
      _startPeriodicPositionSaving();
      
      getLogger().i('✅ WebView设置完成，页面已显示');
      
      // 输出性能统计
      final stats = WebViewPoolManager().getPerformanceStats();
      getLogger().d('📊 性能统计: $stats');
    } catch (e) {
      getLogger().e('❌ WebView最终设置失败: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// 注入精确定位追踪脚本
  Future<void> _injectPositionTracker() async {
    if (!_isWebViewAvailable()) return;
    
    const jsCode = '''
      (function() {
        console.log('🎯 注入精确定位追踪脚本');
        
        // 为页面元素添加唯一标识符
        function addElementIds() {
          const elements = document.querySelectorAll('h1, h2, h3, h4, h5, h6, p, blockquote, pre, div.markdown-body > *');
          elements.forEach((element, index) => {
            if (!element.id) {
              element.id = 'reading_element_' + index + '_' + Date.now();
            }
          });
          console.log('✅ 为 ' + elements.length + ' 个元素添加了ID');
        }
        
        // 获取当前可见的主要元素
        function getCurrentVisibleElement() {
          try {
            const elements = document.querySelectorAll('[id^="reading_element_"], h1, h2, h3, h4, h5, h6, p');
            const viewportTop = window.scrollY;
            const viewportBottom = viewportTop + window.innerHeight;
            const viewportCenter = viewportTop + (window.innerHeight / 2);
            
            let bestElement = null;
            let minDistance = Infinity;
            
            for (let element of elements) {
              const rect = element.getBoundingClientRect();
              const elementTop = rect.top + window.scrollY;
              const elementBottom = elementTop + rect.height;
              const elementCenter = elementTop + (rect.height / 2);
              
              // 检查元素是否在视窗内
              if (elementBottom >= viewportTop && elementTop <= viewportBottom) {
                // 计算元素中心点与视窗中心点的距离
                const distance = Math.abs(elementCenter - viewportCenter);
                
                if (distance < minDistance) {
                  minDistance = distance;
                  bestElement = element;
                }
              }
            }
            
            if (bestElement) {
              const rect = bestElement.getBoundingClientRect();
              return {
                id: bestElement.id,
                tagName: bestElement.tagName,
                text: bestElement.textContent ? bestElement.textContent.substring(0, 100) : '',
                offsetTop: rect.top + window.scrollY,
                scrollY: window.scrollY,
                scrollX: window.scrollX,
                viewportHeight: window.innerHeight,
                contentHeight: document.documentElement.scrollHeight,
                progress: window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)
              };
            }
            
            return {
              id: '',
              tagName: '',
              text: '',
              offsetTop: 0,
              scrollY: window.scrollY,
              scrollX: window.scrollX,
              viewportHeight: window.innerHeight,
              contentHeight: document.documentElement.scrollHeight,
              progress: window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)
            };
          } catch (error) {
            console.error('❌ 获取可见元素失败:', error);
            return null;
          }
        }
        
        // 滚动到指定元素
        function scrollToElement(elementId, offset = 0) {
          try {
            const element = document.getElementById(elementId);
            if (element) {
              const elementTop = element.getBoundingClientRect().top + window.scrollY;
              const targetPosition = Math.max(0, elementTop - offset);
              
              window.scrollTo({
                top: targetPosition,
                left: 0,
                behavior: 'smooth'
              });
              
              console.log('✅ 滚动到元素:', elementId, '位置:', targetPosition);
              return true;
            } else {
              console.warn('⚠️ 未找到目标元素:', elementId);
              return false;
            }
          } catch (error) {
            console.error('❌ 滚动到元素失败:', error);
            return false;
          }
        }
        
        // 滚动到指定位置
        function scrollToPosition(scrollY, scrollX = 0) {
          try {
            window.scrollTo({
              top: Math.max(0, scrollY),
              left: Math.max(0, scrollX),
              behavior: 'smooth'
            });
            console.log('✅ 滚动到位置: Y=' + scrollY + ', X=' + scrollX);
            return true;
          } catch (error) {
            console.error('❌ 滚动到位置失败:', error);
            return false;
          }
        }
        
        // 暴露给Flutter调用的方法
        window.flutter_reading_tracker = {
          addElementIds: addElementIds,
          getCurrentVisibleElement: getCurrentVisibleElement,
          scrollToElement: scrollToElement,
          scrollToPosition: scrollToPosition
        };
        
        // 内容加载完成后自动添加元素ID
        if (document.readyState === 'complete') {
          setTimeout(addElementIds, 100);
        } else {
          document.addEventListener('DOMContentLoaded', () => {
            setTimeout(addElementIds, 100);
          });
        }
        
        console.log('✅ 精确定位追踪脚本注入完成');
      })();
    ''';
    
    try {
      await _webViewController!.evaluateJavascript(source: jsCode);
      getLogger().i('✅ 精确定位追踪脚本注入成功');
    } catch (e) {
      getLogger().e('❌ 精确定位追踪脚本注入失败: $e');
    }
  }

  /// 注入文字选择处理脚本
  Future<void> _injectTextSelectionScript() async {
    if (!_isWebViewAvailable()) return;
    
    const jsCode = '''
      (function() {
        console.log('🎯 注入文字选择处理脚本');
        
        let currentSelection = null;
        let isSelecting = false;
        let highlightCounter = 0;
        let noteCounter = 0;
        let selectionTimeout = null;
        
        // 更强力地阻止系统默认行为
        function preventSystemBehavior(e) {
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          return false;
        }
        
        // 禁用系统默认的上下文菜单
        document.addEventListener('contextmenu', preventSystemBehavior, true);
        
        // 阻止系统选择菜单的各种触发方式
        document.addEventListener('selectstart', function(e) {
          console.log('🎯 开始选择文字');
          isSelecting = true;
        }, true);
        
        // 监听触摸开始（移动端）
        document.addEventListener('touchstart', function(e) {
          // 清除之前的超时
          if (selectionTimeout) {
            clearTimeout(selectionTimeout);
          }
        }, true);
        
        // 监听鼠标按下
        document.addEventListener('mousedown', function(e) {
          // 清除之前的超时
          if (selectionTimeout) {
            clearTimeout(selectionTimeout);
          }
        }, true);
        
        // 监听鼠标抬起事件（选择完成）
        document.addEventListener('mouseup', function(e) {
          selectionTimeout = setTimeout(function() {
            handleTextSelection(e);
          }, 100); // 增加延迟确保选择完成
        }, true);
        
        // 监听触摸结束事件（移动端选择完成）
        document.addEventListener('touchend', function(e) {
          selectionTimeout = setTimeout(function() {
            handleTextSelection(e);
          }, 150); // 移动端需要更长延迟
        }, true);
        
        // 监听选择变化事件
        document.addEventListener('selectionchange', function(e) {
          const selection = window.getSelection();
          if (selection && selection.toString().trim().length > 0) {
            // 有文字被选择
            currentSelection = selection;
            console.log('📝 检测到文字选择变化:', selection.toString().trim());
            
            // 延迟处理，防止过度触发
            if (selectionTimeout) {
              clearTimeout(selectionTimeout);
            }
            selectionTimeout = setTimeout(function() {
              handleSelectionChange();
            }, 200);
          } else {
            // 选择被清除
            if (currentSelection) {
              console.log('❌ 选择已清除');
              currentSelection = null;
              // 通知Flutter清除选择
              notifyFlutter('onSelectionCleared', {});
            }
          }
        }, true);
        
        // 处理选择变化
        function handleSelectionChange() {
          if (!currentSelection) return;
          
          const selectedText = currentSelection.toString().trim();
          if (selectedText.length < 2) {
            console.log('⚠️ 选择文字过短，跳过处理:', selectedText.length);
            return;
          }
          
          try {
            const range = currentSelection.getRangeAt(0);
            const rect = range.getBoundingClientRect();
            
            // 使用getBoundingClientRect()返回的视窗相对坐标
            const selectionData = {
              text: selectedText,
              x: rect.left,
              y: rect.top,
              width: rect.width,
              height: rect.height
            };
            
            console.log('📍 选择位置详细信息 (viewport-relative):', selectionData);
            
            // 通知Flutter
            notifyFlutter('onTextSelected', selectionData);
            
          } catch (error) {
            console.error('❌ 处理选择变化失败:', error);
          }
        }
        
        // 处理文字选择
        function handleTextSelection(originalEvent) {
          const selection = window.getSelection();
          if (!selection || selection.toString().trim().length === 0) {
            console.log('⚠️ 选择为空，跳过处理');
            return;
          }
          
          const selectedText = selection.toString().trim();
          if (selectedText.length < 2) { // 忽略过短的选择
            console.log('⚠️ 选择文字过短，跳过处理:', selectedText.length);
            return;
          }
          
          console.log('📝 处理文字选择:', selectedText);
          
          // 强制阻止系统默认行为
          if (originalEvent) {
            originalEvent.preventDefault();
            originalEvent.stopPropagation();
            originalEvent.stopImmediatePropagation();
          }
          
          // 阻止所有可能的系统菜单
          setTimeout(function() {
            document.addEventListener('contextmenu', preventSystemBehavior, true);
          }, 10);
          
          try {
            // 获取选择的位置信息
            const range = selection.getRangeAt(0);
            const rect = range.getBoundingClientRect();
            
            // 使用getBoundingClientRect()返回的视窗相对坐标
            const selectionData = {
              text: selectedText,
              x: rect.left,
              y: rect.top,
              width: rect.width,
              height: rect.height
            };
            
            console.log('📍 最终选择位置信息 (viewport-relative):', selectionData);
            
            // 通知Flutter
            notifyFlutter('onTextSelected', selectionData);
            
          } catch (error) {
            console.error('❌ 处理文字选择失败:', error);
          }
        }
        
        // 高亮选中的文字
        function highlightSelection(color = 'yellow') {
          const selection = window.getSelection();
          if (!selection || selection.toString().trim().length === 0) {
            console.warn('⚠️ 没有选中的文字可以高亮');
            return false;
          }
          
          try {
            const range = selection.getRangeAt(0);
            const selectedText = selection.toString().trim();
            
            // 创建高亮元素
            const highlightSpan = document.createElement('span');
            highlightSpan.className = 'flutter-highlight';
            highlightSpan.style.backgroundColor = color;
            highlightSpan.style.padding = '2px 1px';
            highlightSpan.style.borderRadius = '2px';
            highlightSpan.dataset.highlightId = 'highlight_' + (++highlightCounter) + '_' + Date.now();
            highlightSpan.dataset.originalText = selectedText;
            
            // 包装选中的内容
            try {
              range.surroundContents(highlightSpan);
              console.log('✅ 文字高亮成功:', selectedText);
              
              // 清除选择
              selection.removeAllRanges();
              
              // 通知Flutter
              notifyFlutter('onTextHighlighted', {
                text: selectedText,
                id: highlightSpan.dataset.highlightId,
                color: color
              });
              
              return true;
            } catch (e) {
              // 如果surroundContents失败，使用备用方法
              const contents = range.extractContents();
              highlightSpan.appendChild(contents);
              range.insertNode(highlightSpan);
              
              selection.removeAllRanges();
              
              console.log('✅ 文字高亮成功(备用方法):', selectedText);
              
              notifyFlutter('onTextHighlighted', {
                text: selectedText,
                id: highlightSpan.dataset.highlightId,
                color: color
              });
              
              return true;
            }
          } catch (error) {
            console.error('❌ 高亮文字失败:', error);
            return false;
          }
        }
        
        // 添加笔记到选中的文字
        function addNoteToSelection(noteText) {
          const selection = window.getSelection();
          if (!selection || selection.toString().trim().length === 0) {
            console.warn('⚠️ 没有选中的文字可以添加笔记');
            return false;
          }
          
          try {
            const range = selection.getRangeAt(0);
            const selectedText = selection.toString().trim();
            
            // 创建笔记元素
            const noteSpan = document.createElement('span');
            noteSpan.className = 'flutter-note';
            noteSpan.style.backgroundColor = '#fff3cd';
            noteSpan.style.borderBottom = '2px solid #ffc107';
            noteSpan.style.position = 'relative';
            noteSpan.style.cursor = 'help';
            noteSpan.dataset.noteId = 'note_' + (++noteCounter) + '_' + Date.now();
            noteSpan.dataset.noteText = noteText;
            noteSpan.dataset.originalText = selectedText;
            noteSpan.title = '笔记: ' + noteText;
            
            // 包装选中的内容
            try {
              range.surroundContents(noteSpan);
              console.log('✅ 笔记添加成功:', selectedText, '笔记:', noteText);
              
              // 清除选择
              selection.removeAllRanges();
              
              // 通知Flutter
              notifyFlutter('onNoteAdded', {
                note: noteText,
                selectedText: selectedText,
                id: noteSpan.dataset.noteId
              });
              
              return true;
            } catch (e) {
              // 备用方法
              const contents = range.extractContents();
              noteSpan.appendChild(contents);
              range.insertNode(noteSpan);
              
              selection.removeAllRanges();
              
              console.log('✅ 笔记添加成功(备用方法):', selectedText, '笔记:', noteText);
              
              notifyFlutter('onNoteAdded', {
                note: noteText,
                selectedText: selectedText,
                id: noteSpan.dataset.noteId
              });
              
              return true;
            }
          } catch (error) {
            console.error('❌ 添加笔记失败:', error);
            return false;
          }
        }
        
        // 清除当前选择
        function clearSelection() {
          const selection = window.getSelection();
          if (selection) {
            selection.removeAllRanges();
            console.log('✅ 清除选择完成');
          }
        }
        
        // 获取当前选择的文字
        function getCurrentSelection() {
          const selection = window.getSelection();
          if (selection && selection.toString().trim().length > 0) {
            const range = selection.getRangeAt(0);
            const rect = range.getBoundingClientRect();
            
            return {
              text: selection.toString().trim(),
              x: rect.left + (rect.width / 2),
              y: rect.top,
              width: rect.width,
              height: rect.height
            };
          }
          return null;
        }
        
        // 统一的Flutter通知函数
        function notifyFlutter(handlerName, data) {
          try {
            console.log('📤 向Flutter发送消息:', handlerName, data);
            
            // 检查flutter_inappwebview是否可用
            if (typeof window.flutter_inappwebview === 'undefined') {
              console.error('❌ window.flutter_inappwebview 未定义');
              return false;
            }
            
            if (typeof window.flutter_inappwebview.callHandler !== 'function') {
              console.error('❌ window.flutter_inappwebview.callHandler 不是函数');
              return false;
            }
            
            // 调用Flutter处理器
            window.flutter_inappwebview.callHandler(handlerName, data);
            console.log('✅ 消息发送成功:', handlerName);
            return true;
            
          } catch (error) {
            console.error('❌ 发送消息到Flutter失败:', error);
            return false;
          }
        }
        
        // 暴露给Flutter调用的方法
        window.flutter_text_selector = {
          highlightSelection: highlightSelection,
          addNoteToSelection: addNoteToSelection,
          clearSelection: clearSelection,
          getCurrentSelection: getCurrentSelection
        };
        
        console.log('✅ 文字选择处理脚本注入完成');
        console.log('🔍 检查flutter_inappwebview:', typeof window.flutter_inappwebview);
      })();
    ''';
    
    try {
      await _webViewController!.evaluateJavascript(source: jsCode);
      getLogger().i('✅ 文字选择处理脚本注入成功');
    } catch (e) {
      getLogger().e('❌ 文字选择处理脚本注入失败: $e');
    }
  }

  /// 开始定期保存阅读位置（优化版本）
  void _startPeriodicPositionSaving() {
    if (_isDisposed) return;
    
    // 取消之前的定时器
    _positionSaveTimer?.cancel();
    
    // 每20秒检查一次是否有未保存的更改
    _positionSaveTimer = Timer.periodic(_saveInterval, (timer) {
      // 检查组件是否已销毁
      if (_isDisposed || !_isWebViewAvailable()) {
        timer.cancel();
        return;
      }
      
      // 只有当有未保存的更改时才保存
      if (_hasUnsavedChanges) {
        _saveCurrentReadingPosition();
      }
    });
    
    getLogger().d('⏰ 开始定期保存阅读位置 (每${_saveInterval.inSeconds}秒检查)');
  }

  /// 标记有未保存的更改
  void _markUnsavedChanges() {
    _hasUnsavedChanges = true;
  }

  /// 检查是否应该保存（防抖）
  bool _shouldSave() {
    if (_lastSaveTime == null) return true;
    return DateTime.now().difference(_lastSaveTime!) >= _minSaveInterval;
  }

  /// 保存当前阅读位置（优化版本）
  Future<void> _saveCurrentReadingPosition() async {
    // 多重安全检查
    if (_isDisposed || !_isWebViewAvailable() || article == null || _isRestoringPosition) {
      return;
    }
    
    // 防抖检查
    if (!_shouldSave()) {
      getLogger().d('⏸️ 保存频率限制，跳过本次保存');
      return;
    }
    
    try {
      getLogger().d('🔍 开始保存阅读位置...');
      
      // 首先检查JavaScript函数是否可用
      final trackerAvailable = await _webViewController!.evaluateJavascript(
        source: 'typeof window.flutter_reading_tracker !== "undefined"'
      );
      
      if (trackerAvailable != true) {
        getLogger().w('⚠️ JavaScript追踪器不可用，重新注入...');
        
        // 再次检查WebView是否可用
        if (!_isWebViewAvailable()) {
          getLogger().w('⚠️ WebView已不可用，跳过重新注入');
          return;
        }
        
        await _injectPositionTracker();
        await Future.delayed(const Duration(milliseconds: 200)); // 减少延迟
      }
      
      // 再次检查WebView是否可用
      if (!_isWebViewAvailable()) {
        getLogger().w('⚠️ WebView已不可用，跳过位置获取');
        return;
      }
      
      final result = await _webViewController!.evaluateJavascript(
        source: 'window.flutter_reading_tracker ? window.flutter_reading_tracker.getCurrentVisibleElement() : null'
      );
      
      if (result != null && result is Map) {
        final data = Map<String, dynamic>.from(result);
        
        // 检查数据是否有实际变化
        final newScrollY = (data['scrollY'] ?? 0).toInt();
        final newElementId = data['id'] ?? '';
        final newProgress = (data['progress'] ?? 0.0).toDouble().clamp(0.0, 1.0);
        
        // 只有当位置有明显变化时才保存
        if ((newScrollY - article!.markdownScrollY).abs() > 50 || // 滚动变化超过50px
            newElementId != article!.currentElementId || // 元素ID变化
            (newProgress - article!.readProgress).abs() > 0.01) { // 进度变化超过1%
          
          // 保存之前的值用于对比
          final oldScrollY = article!.markdownScrollY;
          final oldElementId = article!.currentElementId;
          final oldProgress = article!.readProgress;
          
          // 更新文章的阅读位置信息
          article!.markdownScrollY = newScrollY;
          article!.markdownScrollx = (data['scrollX'] ?? 0).toInt();
          article!.currentElementId = newElementId;
          article!.currentElementText = data['text'] ?? '';
          article!.currentElementOffset = (data['offsetTop'] ?? 0).toInt();
          article!.viewportHeight = (data['viewportHeight'] ?? 0).toInt();
          article!.contentHeight = (data['contentHeight'] ?? 0).toInt();
          article!.readProgress = newProgress;
          article!.lastReadTime = DateTime.now();
          article!.updatedAt = DateTime.now();
          
          // 计算阅读时长
          final currentTime = DateTime.now().millisecondsSinceEpoch;
          if (article!.readingStartTime > 0) {
            article!.readDuration += ((currentTime - article!.readingStartTime) / 1000).round();
            article!.readingStartTime = currentTime; // 重置开始时间
          }
          
          getLogger().i('💾 保存阅读位置成功:');
          getLogger().i('  - 滚动位置变化: $oldScrollY → ${article!.markdownScrollY}');
          getLogger().i('  - 元素ID变化: $oldElementId → ${article!.currentElementId}');
          getLogger().i('  - 进度变化: ${(oldProgress * 100).toStringAsFixed(1)}% → ${(article!.readProgress * 100).toStringAsFixed(1)}%');
          
          // 保存到数据库
          try {
            await ArticleService.instance.saveArticle(article!);
            getLogger().i('✅ 阅读位置已保存到数据库');
            
            // 更新保存状态
            _lastSaveTime = DateTime.now();
            _hasUnsavedChanges = false;
          } catch (e) {
            getLogger().e('❌ 保存到数据库失败: $e');
          }
          
        } else {
          getLogger().d('📊 位置无明显变化，跳过保存');
          _markUnsavedChanges(); // 标记为有未保存更改，下次再检查
        }
        
      } else {
        getLogger().e('❌ 获取阅读位置失败: 无效的返回结果');
      }
    } catch (e, stackTrace) {
      // 如果是因为WebView已销毁导致的错误，只记录警告而不是错误
      if (e.toString().contains('disposed') || e.toString().contains('Disposed')) {
        getLogger().w('⚠️ WebView已销毁，跳过保存阅读位置');
      } else {
        getLogger().e('❌ 保存阅读位置异常: $e');
        getLogger().d('堆栈跟踪: $stackTrace');
      }
    }
  }

  /// 恢复阅读位置（优化版本）
  Future<void> _restoreReadingPosition() async {
    if (_isDisposed || !_isWebViewAvailable() || article == null) {
      getLogger().w('⚠️ 无法恢复阅读位置: WebView=${_isWebViewAvailable()}, Article=${article != null}, Disposed=$_isDisposed');
      return;
    }
    
    _isRestoringPosition = true;
    
    try {
      getLogger().i('🔄 开始恢复阅读位置...');
      
      // 检查是否有保存的位置数据
      final hasPositionData = article!.markdownScrollY > 0 || article!.currentElementId.isNotEmpty;
      if (!hasPositionData) {
        getLogger().i('ℹ️ 无保存的阅读位置，从头开始阅读');
        return;
      }
      
      getLogger().i('📋 恢复到保存位置: Y=${article!.markdownScrollY}, Element=${article!.currentElementId}');
      
      // 等待页面基本加载完成，但减少等待时间
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 再次检查WebView是否可用
      if (!_isWebViewAvailable()) {
        getLogger().w('⚠️ WebView已不可用，终止恢复操作');
        return;
      }
      
      // 检查JavaScript追踪器是否可用，如果不可用则等待
      for (int i = 0; i < 3; i++) { // 最多重试3次
        final trackerAvailable = await _webViewController!.evaluateJavascript(
          source: 'typeof window.flutter_reading_tracker !== "undefined"'
        );
        
        if (trackerAvailable == true) {
          break;
        } else if (i < 2) {
          getLogger().d('⚠️ JavaScript追踪器未就绪，等待重试...');
          await Future.delayed(const Duration(milliseconds: 300));
        } else {
          getLogger().w('⚠️ JavaScript追踪器始终未就绪');
        }
      }
      
      // 优先尝试使用元素ID定位
      if (article!.currentElementId.isNotEmpty) {
        getLogger().i('🎯 尝试使用元素ID定位: ${article!.currentElementId}');
        
        // 再次检查WebView是否可用
        if (!_isWebViewAvailable()) {
          getLogger().w('⚠️ WebView已不可用，终止元素定位');
          return;
        }
        
        final elementRestored = await _webViewController!.evaluateJavascript(
          source: '''
            (function() {
              var element = document.getElementById('${article!.currentElementId}');
              if (element) {
                element.scrollIntoView({ behavior: 'smooth', block: 'start' });
                return true;
              }
              return false;
            })()
          '''
        );
        
        if (elementRestored == true) {
          getLogger().i('✅ 使用元素ID成功恢复阅读位置');
          return;
        } else {
          getLogger().w('⚠️ 元素ID定位失败，尝试滚动位置定位');
        }
      }
      
      // 备用方案：使用滚动位置定位
      if (article!.markdownScrollY > 0) {
        getLogger().i('📍 使用滚动位置定位: Y=${article!.markdownScrollY}');
        
        // 再次检查WebView是否可用
        if (!_isWebViewAvailable()) {
          getLogger().w('⚠️ WebView已不可用，终止滚动定位');
          return;
        }
        
        await _webViewController!.evaluateJavascript(
          source: '''
            window.scrollTo({
              top: ${article!.markdownScrollY},
              left: ${article!.markdownScrollx},
              behavior: 'smooth'
            });
          '''
        );
        
        getLogger().i('✅ 使用滚动位置完成恢复');
      }
      
      // 简化最终验证，减少等待时间
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 最后检查WebView是否还可用
      if (_isWebViewAvailable()) {
        final finalPosition = await _webViewController!.evaluateJavascript(
          source: '({ scrollY: window.scrollY, scrollX: window.scrollX })'
        );
        getLogger().i('🎯 最终位置验证: $finalPosition');
      }
      
    } catch (e, stackTrace) {
      // 如果是因为WebView已销毁导致的错误，只记录警告而不是错误
      if (e.toString().contains('disposed') || e.toString().contains('Disposed')) {
        getLogger().w('⚠️ WebView已销毁，终止恢复阅读位置');
      } else {
        getLogger().e('❌ 恢复阅读位置异常: $e');
        getLogger().d('堆栈跟踪: $stackTrace');
      }
    } finally {
      _isRestoringPosition = false;
    }
  }

  /// 渲染Markdown内容
  Future<void> _renderMarkdownContent() async {
    if (_webViewController == null || markdownContent.isEmpty) return;

    try {
      // 优先使用WebView池管理器的优化渲染方法
      await WebViewPoolManager().renderMarkdownContent(_webViewController!, markdownContent);
      getLogger().d('✅ Markdown内容渲染完成');
    } catch (e) {
      getLogger().e('❌ 优化渲染失败，尝试备用方法: $e');
      // 备用渲染方法
      await _renderTraditionalMarkdownContent();
    }
  }

  /// 传统资源设置方法（备用）
  Future<void> _setupTraditionalResources() async {
    getLogger().i('🔧 使用传统方式加载资源...');
    
    if (_webViewController == null) return;

    try {
      final List<Future> resourceFutures = [
        _loadGitHubCSS(),
        _loadMarkedJS(),
        _loadHighlightJS(),
      ];
      
      await Future.wait(resourceFutures);
      await _configureMarked();
      
      getLogger().i('✅ 传统方式资源加载完成');
    } catch (e) {
      getLogger().e('❌ 传统方式资源加载失败: $e');
    }
  }

  Future<void> _loadGitHubCSS() async {
    try {
      final String githubCss = await rootBundle.loadString('assets/js/github.min.css');
      await _webViewController!.evaluateJavascript(source: '''
        var githubStyles = document.getElementById('github-styles');
        if (githubStyles) {
          githubStyles.textContent = ${_escapeForJS(githubCss)};
        }
      ''');
      getLogger().d('✅ GitHub CSS 传统加载完成');
    } catch (e) {
      getLogger().e('❌ GitHub CSS 传统加载失败: $e');
    }
  }

  Future<void> _loadMarkedJS() async {
    try {
      final String markedJs = await rootBundle.loadString('assets/js/marked.min.js');
      await _webViewController!.evaluateJavascript(source: markedJs);
      getLogger().d('✅ marked.js 传统加载完成');
    } catch (e) {
      getLogger().e('❌ marked.js 传统加载失败: $e');
    }
  }

  Future<void> _loadHighlightJS() async {
    try {
      final String highlightJs = await rootBundle.loadString('assets/js/highlight.min.js');
      await _webViewController!.evaluateJavascript(source: highlightJs);
      getLogger().d('✅ highlight.js 传统加载完成');
    } catch (e) {
      getLogger().e('❌ highlight.js 传统加载失败: $e');
    }
  }

  Future<void> _configureMarked() async {
    await _webViewController!.evaluateJavascript(source: '''
      if (typeof marked !== 'undefined') {
        marked.setOptions({
          highlight: function(code, lang) {
            if (typeof hljs !== 'undefined') {
              if (lang && hljs.getLanguage(lang)) {
                try {
                  return hljs.highlight(code, { language: lang }).value;
                } catch (err) {
                  return code;
                }
              }
              return hljs.highlightAuto(code).value;
            }
            return code;
          },
          langPrefix: 'hljs language-',
          breaks: true,
          gfm: true
        });
      }
    ''');
  }

  /// 传统的Markdown渲染方法
  Future<void> _renderTraditionalMarkdownContent() async {
    if (_webViewController == null || markdownContent.isEmpty) return;

    try {
      await _webViewController!.evaluateJavascript(source: '''
        if (typeof marked !== 'undefined' && marked.parse) {
          try {
            var content = ${_escapeForJS(markdownContent)};
            var htmlContent = marked.parse(content);
            var contentDiv = document.getElementById('content');
            if (contentDiv) {
              contentDiv.innerHTML = '<div class="markdown-body">' + htmlContent + '</div>';
              
              var images = document.querySelectorAll('.markdown-body img');
              images.forEach(function(img) {
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                img.style.display = 'block';
                img.style.margin = '16px auto';
                img.style.cursor = 'pointer';
              });
              
              console.log('✅ 传统方式Markdown渲染完成');
            }
          } catch (error) {
            console.error('❌ 传统方式Markdown渲染失败:', error);
            document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 内容解析失败</h3><p>' + error.message + '</p></div>';
          }
        } else {
          console.error('❌ marked.js 未加载');
          document.getElementById('content').innerHTML = '<div style="color: #e74c3c; padding: 20px; text-align: center;"><h3>⚠️ 解析器未就绪</h3><p>正在加载Markdown解析器，请稍后重试</p></div>';
        }
      ''');
    } catch (e) {
      getLogger().e('传统方式渲染Markdown内容失败: $e');
    }
  }

  String _escapeForJS(String content) {
    return '`${content.replaceAll('`', '\\`').replaceAll('\$', '\\\$')}`';
  }

  Future<void> _setupImageClickHandler() async {
    if (_webViewController == null) return;
    
    _webViewController!.addJavaScriptHandler(
      handlerName: 'onImageClicked',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String imageSrc = data['src'] ?? '';
        final String imageAlt = data['alt'] ?? '';
        final int imageWidth = data['width'] ?? 0;
        final int imageHeight = data['height'] ?? 0;
        
        getLogger().d('🖼️ 图片被点击: $imageSrc');
        _handleImageClicked(imageSrc, imageAlt, imageWidth, imageHeight);
      },
    );
  }

  void _handleImageClicked(String src, String alt, int width, int height) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                src,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('图片加载失败', style: TextStyle(color: Colors.grey[600])),
                        if (alt.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(alt, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 确保加载最新的文章数据（优化版本）
  Future<void> _ensureLatestArticleData() async {
    if (article?.id == null) return;
    
    try {
      getLogger().d('🔄 异步刷新文章数据，ID: ${article!.id}');
      final latestArticle = await ArticleService.instance.getArticleById(article!.id);
      if (latestArticle != null && !_isDisposed) {
        // 只更新阅读位置相关数据，避免不必要的赋值
        final hasPositionData = latestArticle.markdownScrollY > 0 || 
                               latestArticle.currentElementId.isNotEmpty;
        
        if (hasPositionData) {
          widget.article?.markdownScrollY = latestArticle.markdownScrollY;
          widget.article?.markdownScrollx = latestArticle.markdownScrollx;
          widget.article?.currentElementId = latestArticle.currentElementId;
          widget.article?.currentElementText = latestArticle.currentElementText;
          widget.article?.currentElementOffset = latestArticle.currentElementOffset;
          widget.article?.viewportHeight = latestArticle.viewportHeight;
          widget.article?.contentHeight = latestArticle.contentHeight;
          widget.article?.readProgress = latestArticle.readProgress;
          widget.article?.lastReadTime = latestArticle.lastReadTime;
          widget.article?.readCount = latestArticle.readCount;
          widget.article?.readDuration = latestArticle.readDuration;
          
          getLogger().d('✅ 发现保存的阅读位置: Y=${latestArticle.markdownScrollY}, 进度=${(latestArticle.readProgress * 100).toStringAsFixed(1)}%');
        } else {
          getLogger().d('ℹ️ 无保存的阅读位置数据');
        }
      }
    } catch (e) {
      getLogger().e('❌ 刷新文章数据失败: $e');
    }
  }

  /// 设置自定义选择处理器
  void _setupTextSelectionHandlers(InAppWebViewController controller) {
    // 设置文字选择事件处理器
    controller.addJavaScriptHandler(
      handlerName: 'onTextSelected',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String selectedText = data['text'] ?? '';
        final double x = (data['x'] ?? 0).toDouble();
        final double y = (data['y'] ?? 0).toDouble();
        final double width = (data['width'] ?? 0).toDouble();
        final double height = (data['height'] ?? 0).toDouble();
        
        getLogger().d('📝 文字被选择: $selectedText');
        getLogger().d('📍 选择位置: x=$x, y=$y, width=$width, height=$height');
        
        _showCustomSelectionMenu(selectedText, x, y, width, height);
      },
    );

    // 设置选择取消事件处理器
    controller.addJavaScriptHandler(
      handlerName: 'onSelectionCleared',
      callback: (args) {
        getLogger().d('❌ 选择已取消');
        _hideCustomSelectionMenu();
      },
    );

    // 设置高亮事件处理器
    controller.addJavaScriptHandler(
      handlerName: 'onTextHighlighted',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String highlightedText = data['text'] ?? '';
        final String highlightId = data['id'] ?? '';
        final String color = data['color'] ?? 'yellow';
        
        getLogger().d('🎨 文字已高亮: $highlightedText (ID: $highlightId, 颜色: $color)');
        _handleTextHighlighted(highlightedText, highlightId, color);
      },
    );

    // 设置笔记添加事件处理器
    controller.addJavaScriptHandler(
      handlerName: 'onNoteAdded',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>;
        final String noteText = data['note'] ?? '';
        final String selectedText = data['selectedText'] ?? '';
        final String noteId = data['id'] ?? '';
        
        getLogger().d('📝 笔记已添加: $noteText (关联文字: $selectedText, ID: $noteId)');
        _handleNoteAdded(noteText, selectedText, noteId);
      },
    );
    
    getLogger().i('✅ 文字选择处理器设置完成');
  }

  /// 显示自定义选择菜单
  void _showCustomSelectionMenu(String selectedText, double x, double y, double width, double height) {
    if (_isDisposed || !mounted) return;

    final RenderBox? renderBox = _webViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      getLogger().w('⚠️无法获取WebView的RenderBox，无法显示菜单');
      return;
    }

    // 获取WebView在屏幕上的位置
    final webViewOffset = renderBox.localToGlobal(Offset.zero);

    _currentSelectedText = selectedText;
    _hideCustomSelectionMenu(); // 先隐藏之前的菜单

    // 获取屏幕尺寸和安全区域
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // JS返回的是相对于WebView视窗的坐标(x,y)。x是left, y是top。
    // 计算选中文字在屏幕上的绝对位置
    final selectionRectOnScreen = Rect.fromLTWH(
      webViewOffset.dx + x,
      webViewOffset.dy + y,
      width,
      height,
    );
    
    const menuHeight = 50.0; // 预估菜单高度
    const menuWidth = 200.0; // 预估菜单宽度

    // 默认将菜单放在选中区域的上方
    double menuY = selectionRectOnScreen.top - menuHeight - 8;
    // 水平居中对齐
    double menuX = selectionRectOnScreen.center.dx - (menuWidth / 2);

    // Y轴边界检查, 如果上方空间不够，显示在选中文字下方
    if (menuY < padding.top) {
      menuY = selectionRectOnScreen.bottom + 8;
    }
    
    // X轴边界检查
    if (menuX < 16) {
      menuX = 16;
    } else if (menuX + menuWidth > screenSize.width - 16) {
      menuX = screenSize.width - menuWidth - 16;
    }

    getLogger().d('📍 菜单位置计算:');
    getLogger().d('  WebView偏移: $webViewOffset');
    getLogger().d('  选择区域 (WebView内): Rect.fromLTWH($x, $y, $width, $height)');
    getLogger().d('  选择区域 (屏幕): $selectionRectOnScreen');
    getLogger().d('  最终菜单位置: x=$menuX, y=$menuY');
    
    _backgroundCatcher = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: _hideCustomSelectionMenu,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );

    _selectionMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: menuX,
        top: menuY,
        child: GestureDetector(
          onTap: () {}, // 阻止事件穿透到背景
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: menuWidth,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuButton(
                      icon: Icons.copy,
                      label: '复制',
                      onTap: () => _handleCopyText(selectedText),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[600]),
                    _buildMenuButton(
                      icon: Icons.highlight,
                      label: '高亮',
                      onTap: () => _handleHighlightText(selectedText),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[600]),
                    _buildMenuButton(
                      icon: Icons.note_add,
                      label: '笔记',
                      onTap: () => _handleAddNote(selectedText),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[600]),
                    _buildMenuButton(
                      icon: Icons.share,
                      label: '分享',
                      onTap: () => _handleShareText(selectedText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insertAll([_backgroundCatcher!, _selectionMenuOverlay!]);
  }

  /// 构建菜单按钮
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        _hideCustomSelectionMenu();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 隐藏自定义选择菜单
  void _hideCustomSelectionMenu() {
    _selectionMenuOverlay?.remove();
    _selectionMenuOverlay = null;
    _backgroundCatcher?.remove();
    _backgroundCatcher = null;
  }

  /// 处理复制文字
  void _handleCopyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showMessage('已复制到剪贴板');
    getLogger().d('📋 文字已复制: $text');
  }

  /// 处理高亮文字
  void _handleHighlightText(String text) {
    if (!_isWebViewAvailable()) return;
    
    // 调用JavaScript高亮功能
    _webViewController!.evaluateJavascript(source: '''
      (function() {
        if (window.flutter_text_selector) {
          window.flutter_text_selector.highlightSelection('yellow');
        }
      })();
    ''');
    
    _showMessage('已添加高亮');
    getLogger().d('🎨 文字已高亮: $text');
  }

  /// 处理添加笔记
  void _handleAddNote(String selectedText) {
    _showAddNoteDialog(selectedText);
  }

  /// 处理分享文字
  void _handleShareText(String text) {
    // 这里可以集成分享功能
    _showMessage('分享功能待实现');
    getLogger().d('📤 分享文字: $text');
  }

  /// 显示添加笔记对话框
  void _showAddNoteDialog(String selectedText) {
    if (!mounted) return;
    
    final TextEditingController noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加笔记'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选中文字:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selectedText,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '笔记内容:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '请输入笔记内容...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final noteText = noteController.text.trim();
              if (noteText.isNotEmpty) {
                _addNoteToText(selectedText, noteText);
                Navigator.of(context).pop();
                _showMessage('笔记已添加');
              }
            },
            child: Text('添加'),
          ),
        ],
      ),
    );
  }

  /// 添加笔记到文字
  void _addNoteToText(String selectedText, String noteText) {
    if (!_isWebViewAvailable()) return;
    
    // 调用JavaScript添加笔记功能
    _webViewController!.evaluateJavascript(source: '''
      (function() {
        if (window.flutter_text_selector) {
          window.flutter_text_selector.addNoteToSelection('${_escapeForJS(noteText)}');
        }
      })();
    ''');
    
    getLogger().d('📝 笔记已添加: 文字="$selectedText", 笔记="$noteText"');
  }

  /// 处理文字高亮事件
  void _handleTextHighlighted(String text, String highlightId, String color) {
    // 这里可以保存高亮信息到数据库
    getLogger().i('🎨 高亮已保存: ID=$highlightId, 颜色=$color');
  }

  /// 处理笔记添加事件
  void _handleNoteAdded(String noteText, String selectedText, String noteId) {
    // 这里可以保存笔记信息到数据库
    getLogger().i('📝 笔记已保存: ID=$noteId');
  }

  /// 显示提示消息
  void _showMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import '../../../basics/logger.dart';
import '../../../db/article/article_db.dart';
import '../controller/article_controller.dart';
import 'utils/simple_html_template.dart';
import 'utils/enhanced_markdown_logic.dart';
import 'utils/selection_menu_logic.dart';
import 'utils/highlight_menu_logic.dart';


class ArticleMarkdownWidget extends StatefulWidget {
  final String? url;
  final String markdownContent;
  final ArticleDb? article;
  final void Function(ScrollDirection direction, double scrollY)? onScroll;
  final EdgeInsetsGeometry contentPadding;

  const ArticleMarkdownWidget({
    super.key,
    this.url,
    required this.markdownContent,
    this.article,
    this.onScroll,
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  State<ArticleMarkdownWidget> createState() => ArticleMarkdownWidgetState();
}

class ArticleMarkdownWidgetState extends State<ArticleMarkdownWidget> with SelectionMenuLogic<ArticleMarkdownWidget>, HighlightMenuLogic<ArticleMarkdownWidget>, EnhancedMarkdownLogic<ArticleMarkdownWidget> {
  final GlobalKey _webViewKey = GlobalKey();

  String get markdownContent => widget.markdownContent;
  
  @override
  ArticleDb? get article => widget.article;
  
  @override
  GlobalKey<State<StatefulWidget>> get webViewKey => _webViewKey;

  @override
  EdgeInsetsGeometry get contentPadding => widget.contentPadding;

  double _lastScrollY = 0.0;
  Timer? _savePositionTimer;
  
  // 用于跟踪上一次的内容，检测内容变化
  String _previousMarkdownContent = '';
  String _currentLanguageCode = 'original'; // 当前语言代码

  /// 重新加载Markdown内容
  /// 供外部调用的公开方法
  Future<void> reloadMarkdownContent() async {
    getLogger().i('🔄 重新加载Markdown内容');
    
    if (webViewController != null) {
      try {
        // 方式1：直接重新加载WebView（简单直接）
        await webViewController!.reload();
        getLogger().i('✅ WebView重新加载完成');
        
        // 注意：reload后会触发onLoadStop，在那里会重新渲染新的Markdown内容
      } catch (e) {
        getLogger().e('❌ 重新加载WebView失败，尝试直接更新内容: $e');
        
        // 方式2：如果reload失败，尝试直接更新内容
        try {
          await _renderMarkdownContent();
          getLogger().i('✅ 直接更新Markdown内容完成');
        } catch (e2) {
          getLogger().e('❌ 直接更新Markdown内容也失败: $e2');
        }
      }
    } else {
      getLogger().w('⚠️ WebView控制器不存在，无法重新加载');
    }
  }

  /// 渲染Markdown内容到WebView
  Future<void> _renderMarkdownContent() async {
    if (webViewController == null || markdownContent.isEmpty) return;
    
    try {
      // 安全地转义Markdown内容
      final escapedMarkdown = markdownContent
          .replaceAll('\\', '\\\\')    // 转义反斜杠
          .replaceAll('`', '\\`')      // 转义反引号
          .replaceAll('\$', '\\\$')    // 转义美元符号
          .replaceAll('\n', '\\n')     // 转义换行符
          .replaceAll('\r', '\\r');    // 转义回车符
      
      // 使用JavaScript直接更新Markdown内容
      await webViewController!.evaluateJavascript(source: '''
        if (typeof renderMarkdown === 'function') {
          const markdownText = `$escapedMarkdown`;
          const success = renderMarkdown(markdownText);
          if (success) {
            console.log('✅ Markdown内容更新成功，长度: ' + markdownText.length);
          } else {
            console.error('❌ Markdown渲染失败');
          }
        } else {
          console.error('❌ renderMarkdown函数不存在');
        }
      ''');
      
      getLogger().i('📄 Markdown内容已重新渲染到WebView，长度: ${markdownContent.length}');
    } catch (e) {
      getLogger().e('❌ 渲染Markdown内容失败: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _previousMarkdownContent = markdownContent;
    _detectCurrentLanguage();
    initEnhancedLogic();
  }

  @override
  void didUpdateWidget(ArticleMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测内容是否发生变化
    if (oldWidget.markdownContent != widget.markdownContent) {
      getLogger().i('🔄 检测到Markdown内容变化，准备重新渲染');
      _previousMarkdownContent = markdownContent;
      _detectCurrentLanguage();
      
      // 如果WebView已经准备好，立即重新渲染内容
      if (webViewController != null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _renderMarkdownContent();
        });
      }
    }
    
    // 检测文章是否变化（用于处理高亮和笔记的语言版本）
    if (oldWidget.article?.id != widget.article?.id) {
      getLogger().i('🔄 检测到文章变化，重新初始化增强功能');
      _detectCurrentLanguage();
      // 重新初始化增强功能
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          initEnhancedLogic();
        }
      });
    }
  }

  @override
  void dispose() {
    _savePositionTimer?.cancel();
    disposeEnhancedLogic();
    webViewController?.dispose();
    getLogger().d('✅ ArticleMarkdownWidget销毁完成');
    super.dispose();
  }
  
  /// 检测当前语言代码
  void _detectCurrentLanguage() {
    try {
      // 通过ArticleController获取当前语言状态
      final previousLanguage = _currentLanguageCode;
      
      // 尝试获取ArticleController的当前语言状态
      try {
        final articleController = Get.find<ArticleController>();
        _currentLanguageCode = articleController.currentLanguageCode;
        getLogger().d('🌐 从ArticleController获取当前语言: $_currentLanguageCode');
      } catch (e) {
        // 如果无法获取ArticleController，使用fallback逻辑
        if (markdownContent.isEmpty) {
          _currentLanguageCode = 'original';
        } else {
          // 保持当前语言设置不变，避免频繁切换
        }
      }
      
      if (previousLanguage != _currentLanguageCode) {
        getLogger().i('🌐 语言切换: $previousLanguage -> $_currentLanguageCode');
        // 语言切换时，需要重新加载对应语言的高亮和笔记
        _onLanguageChanged();
      }
    } catch (e) {
      getLogger().e('❌ 检测语言失败: $e');
      _currentLanguageCode = 'original';
    }
  }
  
  /// 语言切换时的处理
  void _onLanguageChanged() {
    getLogger().i('🌐 处理语言切换后的逻辑，当前语言: $_currentLanguageCode');
    
    // 这里可以添加语言切换后的特殊处理逻辑
    // 比如重新加载高亮、笔记等
    // 由于高亮和笔记在enhanced_markdown_logic中管理，这里先做标记
    
    // 通知增强功能语言已切换
    if (mounted) {
      // 延迟执行，确保内容已经渲染完成
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _notifyLanguageChanged();
        }
      });
    }
  }
  
  /// 通知增强功能语言已切换
  void _notifyLanguageChanged() {
    // 这个方法可以被enhanced_markdown_logic重写来处理语言切换
    getLogger().d('📢 通知增强功能语言已切换: $_currentLanguageCode');
    
    // 如果使用了enhanced_markdown_logic，调用语言切换方法
    if (this is dynamic && (this as dynamic)._reloadAnnotationsForLanguage != null) {
      (this as dynamic)._reloadAnnotationsForLanguage(_currentLanguageCode);
    }
  }
  
  /// 防抖保存位置，避免过于频繁的保存操作
  void _debounceSavePosition(VoidCallback callback) {
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(const Duration(seconds: 2), callback);
  }

  @override
  Widget build(BuildContext context) {
    // 如果markdownContent为空，显示空状态界面
    if (markdownContent.isEmpty) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: Stack(
        children: [
          _buildOptimizedWebView(),
        ],
      ),
    );
  }

  /// 构建空状态界面
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: widget.contentPadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.article_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // 标题
            Text(
              '暂无图文内容',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            
            // 描述
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '该文章尚未生成图文版本。\n请切换到网页标签查看原始内容，或等待系统自动生成图文版本。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // 提示信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '图文版本将在后台自动生成',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedWebView() {
    return Container(
      // padding: EdgeInsets.only(left: 4,right: 4),
      child: InAppWebView(
        key: _webViewKey,
        initialData: InAppWebViewInitialData(
          data: SimpleHtmlTemplate.generateHtmlTemplate(),
          mimeType: "text/html",
          encoding: "utf-8",
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          disableContextMenu: true,
          disableDefaultErrorPage: true,
          textZoom: 100,
          supportMultipleWindows: false,
          allowsInlineMediaPlayback: true,
          disableLongPressContextMenuOnLinks: true,
          supportZoom: false,
          builtInZoomControls: false,
          displayZoomControls: false,
          disableHorizontalScroll: false,
          disableVerticalScroll: false,
          userAgent: "Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 InkwellReader/1.0",
          allowFileAccess: true,
          allowContentAccess: true,
          cacheMode: CacheMode.LOAD_DEFAULT,
          clearCache: false,
          disableInputAccessoryView: true,
        ),
        onWebViewCreated: onEnhancedWebViewCreated,
        onLoadStart: (controller, url) {
          getLogger().d('🚀 WebView开始加载: $url');
          // 确保加载遮罩显示
          controller.evaluateJavascript(source: '''
            if (window.SmoothLoading) {
              window.SmoothLoading.show('正在加载页面...');
            }
          ''').catchError((e) {
            getLogger().d('⚠️ 加载开始时显示遮罩失败: $e');
          });
        },
        onLoadStop: (controller, url) async {

          try {
            // 更新加载状态：正在初始化
            // await controller.evaluateJavascript(source: '''
            //   if (window.SmoothLoading) {
            //     window.SmoothLoading.updateText('正在初始化页面...');
            //   }
            // ''').catchError((e) => getLogger().d('⚠️ 更新加载文本失败: $e'));

            // 确保DOM完全就绪
            await controller.evaluateJavascript(source: '''
              if (document.readyState !== 'complete') {
                await new Promise(resolve => {
                  if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', resolve);
                  } else {
                    resolve();
                  }
                });
              }
            ''');

            // 确保基本DOM元素存在
            await controller.evaluateJavascript(source: '''
              // 确保必要的DOM元素存在
              if (!document.head) {
                console.error('❌ document.head 不存在，DOM可能未完全加载');
                return;
              }
              if (!document.body) {
                console.error('❌ document.body 不存在，DOM可能未完全加载'); 
                return;
              }
              if (!document.getElementById('content')) {
                console.warn('⚠️ content元素不存在，某些功能可能无法正常工作');
              }
              console.log('✅ DOM基本元素检查通过');
            ''');

            // 确保背景在任何情况下都透明
            await controller.evaluateJavascript(source: '''
              document.body.style.backgroundColor = 'transparent';
              document.documentElement.style.backgroundColor = 'transparent';
            ''');

            // 调用增强功能初始化
            await onEnhancedWebViewLoadStop();
            // getLogger().d('✅ onEnhancedWebViewLoadStop执行完成');
          } catch (e) {
            getLogger().e('❌ WebView加载后初始化失败: $e');
            // 即使初始化失败，也要隐藏加载遮罩
            controller.evaluateJavascript(source: '''
              if (window.SmoothLoading) {
                window.SmoothLoading.hide();
              }
            ''').catchError((e) => getLogger().d('⚠️ 隐藏加载遮罩失败: $e'));
          }
        },
        onProgressChanged: (controller, progress) {
          getLogger().d('📊 WebView加载进度: $progress%');
        },
        onConsoleMessage: (controller, consoleMessage) {
          getLogger().d('🖥️ WebView控制台: [${consoleMessage.messageLevel}] ${consoleMessage.message}');
        },
        onScrollChanged: (controller, x, y) {
          final scrollY = y.toDouble();
          // 只有在滚动距离超过一个阈值时才触发，避免过于敏感
          if ((scrollY - _lastScrollY).abs() > 15) {
            final direction = scrollY > _lastScrollY ? ScrollDirection.reverse : ScrollDirection.forward;
            widget.onScroll?.call(direction, scrollY);
            _lastScrollY = scrollY;
            
            // 触发位置保存（如果是EnhancedMarkdownLogic的实例）
            if (this is dynamic && (this as dynamic).manualSavePosition != null) {
              // 使用防抖，避免过于频繁的保存
              _debounceSavePosition(() {
                (this as dynamic).manualSavePosition?.call();
              });
            }
          }
        },
      ),
    );
  }


}

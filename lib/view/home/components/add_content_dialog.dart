import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../basics/logger.dart';
import '../../../db/article/article_service.dart';

/// 添加内容对话框
class AddContentDialog extends StatefulWidget {
  const AddContentDialog({super.key});

  @override
  State<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<AddContentDialog> with TickerProviderStateMixin {
  late final TextEditingController _contentController;
  late final FocusNode _focusNode;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
  bool _isLoading = false;
  bool _hasUrl = false;
  String _detectedUrl = '';
  
  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _focusNode = FocusNode();
    _contentController.addListener(_onTextChanged);
    
    _initAnimations();
    _startEntryAnimation();
  }
  
  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
  }
  
  void _startEntryAnimation() {
    _fadeController.forward();
    _scaleController.forward();
    
    // 延迟自动聚焦到输入框
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }
  
  void _onTextChanged() {
    final text = _contentController.text;
    final hasUrl = _containsUrl(text);
    final detectedUrl = hasUrl ? _extractUrl(text) : '';
    
    if (hasUrl != _hasUrl || detectedUrl != _detectedUrl) {
      setState(() {
        _hasUrl = hasUrl;
        _detectedUrl = detectedUrl;
      });
    }
  }
  
  /// 判断文本是否包含URL
  bool _containsUrl(String text) {
    // 检查是否包含完整的URL（带协议）
    final fullUrlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    if (fullUrlRegex.hasMatch(text)) {
      return true;
    }
    
    // 检查是否包含域名格式（不带协议）
    final domainRegex = RegExp(
      r'(?:^|\s)(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.(?:[a-zA-Z]{2,}|[a-zA-Z]{2,}\.[a-zA-Z]{2,})(?:\.[a-zA-Z]{2,})?(?:/[^\s]*)?(?=\s|$)',
      caseSensitive: false,
    );
    return domainRegex.hasMatch(text);
  }
  
  /// 从文本中提取URL
  String _extractUrl(String text) {
    // 优先查找完整的URL（带协议）
    final fullUrlRegex = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
    );
    final fullUrlMatch = fullUrlRegex.firstMatch(text);
    if (fullUrlMatch != null) {
      return fullUrlMatch.group(1)!;
    }
    
    // 查找域名格式（不带协议）
    final domainRegex = RegExp(
      r'(?:^|\s)((?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.(?:[a-zA-Z]{2,}|[a-zA-Z]{2,}\.[a-zA-Z]{2,})(?:\.[a-zA-Z]{2,})?(?:/[^\s]*)?)(?=\s|$)',
      caseSensitive: false,
    );
    final domainMatch = domainRegex.firstMatch(text);
    if (domainMatch != null) {
      String domain = domainMatch.group(1)!.trim();
      // 为没有协议的域名自动添加 https:// 前缀
      return domain.startsWith('http') ? domain : 'https://$domain';
    }
    
    return '';
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  bool get _canSubmit => _contentController.text.trim().isNotEmpty && !_isLoading;
  
  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;
    
    setState(() => _isLoading = true);
    
    try {
      final content = _contentController.text.trim();
      
      String title = '';
      String url = '';
      
      if (_hasUrl) {
        // 解析链接内容
        final urlStartIndex = content.indexOf(_detectedUrl);
        if (urlStartIndex > 0) {
          // 提取URL前面的文本作为标题
          title = content.substring(0, urlStartIndex).trim();
        }
        if (title.isEmpty) {
          title = '手动添加的链接';
        }
        url = _detectedUrl;
      } else {
        // 提取文本标题（取前50个字符）
        title = _extractTitleFromText(content);
        url = '';
      }
      
      // 生成摘要
      final excerpt = _generateExcerpt(content);
      
      // 检查是否已存在相同URL的文章（只对URL类型检查）
      if (url.isNotEmpty) {
        final existingArticle = await ArticleService.instance.findArticleByUrl(url);
        if (existingArticle != null) {
          getLogger().i('⚠️ 文章已存在，跳过保存: ${existingArticle.title}');
          if (mounted) {
            _showErrorMessage('该链接已存在');
          }
          setState(() => _isLoading = false);
          return;
        }
      }
      
      // 直接使用ArticleService创建文章
      await ArticleService.instance.createArticleFromShare(
        title: title,
        url: url,
        originalContent: content,
        excerpt: excerpt,
        tags: [],
      );
      
      getLogger().i('✅ 手动添加内容成功: $title');
      
      // 显示成功提示
      _showSuccessMessage();
      
      // 延迟关闭对话框
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop(true); // 返回true表示成功添加
      }
      
    } catch (e) {
      getLogger().e('❌ 手动添加内容失败: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        _showErrorMessage('添加失败，请重试');
      }
    }
  }
  
  /// 从文本中提取标题（取前面部分作为标题）
  String _extractTitleFromText(String text) {
    if (text.isEmpty) return '未命名内容';
    
    // 取前50个字符作为标题，如果有换行符就在第一个换行符处截断
    final firstLineEnd = text.indexOf('\n');
    if (firstLineEnd > 0 && firstLineEnd < 50) {
      return text.substring(0, firstLineEnd).trim();
    }
    
    if (text.length <= 50) {
      return text.trim();
    }
    
    return text.substring(0, 50).trim() + '...';
  }

  /// 生成摘要
  String _generateExcerpt(String content) {
    if (content.isEmpty) return '';
    
    // 取前200个字符作为摘要
    if (content.length <= 200) {
      return content.trim();
    }
    
    return content.substring(0, 200).trim() + '...';
  }
  
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _hasUrl ? '链接添加成功' : '文本添加成功',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // 获取键盘高度和屏幕尺寸
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 计算可视区域高度
    final visibleHeight = screenHeight - keyboardHeight;
    final topSafeArea = MediaQuery.of(context).padding.top;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    
    // 对话框高度计算
    final reservedSpace = topSafeArea + bottomSafeArea + 150;
    final dialogMaxHeight = (visibleHeight - reservedSpace).clamp(300.0, 500.0);
    
    // 键盘弹出时的偏移
    final keyboardOffset = keyboardHeight > 0 
        ? -(keyboardHeight * 0.15).clamp(-60.0, 0.0)
        : 0.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, keyboardOffset, 0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(16),
            content: Container(
              constraints: BoxConstraints(
                maxHeight: dialogMaxHeight,
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildContentInput(),
                  const SizedBox(height: 16),
                  // if (_hasUrl) _buildUrlDetectionHint(),
                  // const SizedBox(height: 18),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加内容',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '输入链接或文本，系统自动识别链接',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildContentInput() {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? const Color(0xFF00BCF6) 
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _focusNode.hasFocus 
                ? const Color(0xFF00BCF6).withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: _focusNode.hasFocus ? 8 : 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        focusNode: _focusNode,
        maxLines: null,
        minLines: 4,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: '请输入文本内容或链接...\n\n支持的链接格式：\n• https://example.com\n• http://example.com\n• www.example.com\n• baidu.com\n\n或者输入任意文本内容',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 15,
            height: 1.4,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }
  
  Widget _buildUrlDetectionHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BCF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCF6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.link_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '检测到链接',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _detectedUrl.length > 40 
                      ? '${_detectedUrl.substring(0, 40)}...'
                      : _detectedUrl,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Text(
              '取消',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _canSubmit ? _handleSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCF6),
              disabledBackgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '添加',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// 显示添加内容对话框
Future<bool?> showAddContentDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AddContentDialog(),
  );
} 
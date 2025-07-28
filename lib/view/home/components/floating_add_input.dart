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



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../basics/logger.dart';
import '../../../db/article/service/article_service.dart';

/// 浮动添加内容输入框
class FloatingAddInput extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onSuccess;

  const FloatingAddInput({
    super.key,
    required this.onClose,
    this.onSuccess,
  });

  @override
  State<FloatingAddInput> createState() => _FloatingAddInputState();
}

class _FloatingAddInputState extends State<FloatingAddInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _contentController;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  bool _isLoading = false;
  bool _hasUrl = false;
  String _detectedUrl = '';

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _focusNode = FocusNode();
    _contentController.addListener(_onTextChanged);

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 启动进入动画
    _animationController.forward();

    // 延迟聚焦，确保动画完成后再聚焦，iOS需要更长的延迟
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted && _animationController.isCompleted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final text = _contentController.text;
      final hasUrl = _containsUrl(text);
      final detectedUrl = hasUrl ? _extractUrl(text) : '';

      if (hasUrl != _hasUrl || detectedUrl != _detectedUrl) {
        setState(() {
          _hasUrl = hasUrl;
          _detectedUrl = detectedUrl;
        });
      }
    });
  }

  bool _containsUrl(String text) {
    final fullUrlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    if (fullUrlRegex.hasMatch(text)) {
      return true;
    }

    final domainRegex = RegExp(
      r'(?:^|\s)(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.(?:[a-zA-Z]{2,}|[a-zA-Z]{2,}\.[a-zA-Z]{2,})(?:\.[a-zA-Z]{2,})?(?:/[^\s]*)?(?=\s|$)',
      caseSensitive: false,
    );
    return domainRegex.hasMatch(text);
  }

  String _extractUrl(String text) {
    final fullUrlRegex = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
    );
    final fullUrlMatch = fullUrlRegex.firstMatch(text);
    if (fullUrlMatch != null) {
      return fullUrlMatch.group(1)!;
    }

    final domainRegex = RegExp(
      r'(?:^|\s)((?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.(?:[a-zA-Z]{2,}|[a-zA-Z]{2,}\.[a-zA-Z]{2,})(?:\.[a-zA-Z]{2,})?(?:/[^\s]*)?)(?=\s|$)',
      caseSensitive: false,
    );
    final domainMatch = domainRegex.firstMatch(text);
    if (domainMatch != null) {
      String domain = domainMatch.group(1)!.trim();
      return domain.startsWith('http') ? domain : 'https://$domain';
    }

    return '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _contentController.removeListener(_onTextChanged);
    
    // 确保在dispose前释放焦点，避免iOS键盘问题
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    
    _contentController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _contentController.text.trim().isNotEmpty && _hasUrl && !_isLoading;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isLoading = true);

    try {
      final content = _contentController.text.trim();

      String title = '';
      final urlStartIndex = content.indexOf(_detectedUrl);
      if (urlStartIndex > 0) {
        title = content.substring(0, urlStartIndex).trim();
      }
      if (title.isEmpty) {
        title = 'i18n_addContent_手动添加的链接'.tr;
      }
      final url = _detectedUrl;

      final excerpt = _generateExcerpt(content);

      final existingArticle =
          await ArticleService.instance.findArticleByUrl(url);
      if (existingArticle != null) {
        getLogger().i('⚠️ 文章已存在，跳过保存: ${existingArticle.title}');
        if (mounted) {
          _showErrorMessage('i18n_addContent_该链接已存在'.tr);
        }
        setState(() => _isLoading = false);
        return;
      }

      await ArticleService.instance.createArticleFromShare(
        title: title,
        url: url,
        originalContent: content,
        excerpt: excerpt,
        tags: [],
      );

      getLogger().i('✅ 手动添加内容成功: $title');

      _showSuccessMessage();
      widget.onSuccess?.call();

      await Future.delayed(const Duration(milliseconds: 1500));
      _handleClose();
    } catch (e) {
      getLogger().e('❌ 手动添加内容失败: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        _showErrorMessage('i18n_addContent_添加失败请重试'.tr);
      }
    }
  }

  String _generateExcerpt(String content) {
    if (content.isEmpty) return '';
    if (content.length <= 200) {
      return content.trim();
    }
    return '${content.substring(0, 200).trim()}...';
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
              'i18n_addContent_链接添加成功'.tr,
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

  Future<void> _handleClose() async {
    // 先释放焦点，避免iOS键盘问题
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      // 给键盘一点时间收起
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // 然后执行关闭动画
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;

    // 计算可用空间
    final availableHeight =
        screenHeight - keyboardHeight - safeAreaTop - 10; // 40是上下边距
    final maxHeight = availableHeight * 0.8; // 最多占用80%的可用空间

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              elevation: 12,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight.clamp(
                      300.0, screenHeight * 0.8), // 最小300，最大屏幕80%
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildContentInput(keyboardHeight > 0), // 传递键盘状态
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _hasUrl
                                  ? _buildUrlDetectionHint()
                                  : (_contentController.text.isNotEmpty
                                      ? _buildNoUrlHint()
                                      : const SizedBox.shrink()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildButtons(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'i18n_addContent_添加内容'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'i18n_addContent_请输入包含链接的文本'.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _handleClose,
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput(bool isKeyboardVisible) {
    // 当键盘弹出时，减少输入框的行数以节省空间
    final maxLines = isKeyboardVisible ? 4 : 6;
    final minLines = isKeyboardVisible ? 2 : 4;
    final minHeight = isKeyboardVisible ? 80.0 : 120.0;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
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
        maxLines: maxLines,
        minLines: minLines,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'i18n_addContent_粘贴包含链接的文本内容'.tr,
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

  Widget _buildNoUrlHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[800],
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'i18n_addContent_内容中未检测到有效链接'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
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
                  'i18n_addContent_检测到链接'.tr,
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
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
            onPressed: _isLoading ? null : _handleClose,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Text(
              'i18n_addContent_取消'.tr,
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
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.outline.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                    'i18n_addContent_添加'.tr,
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

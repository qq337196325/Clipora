// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../basics/logger.dart';
import '../../../db/article/service/article_service.dart';

/// 添加内容对话框
class AddContentDialog extends StatefulWidget {
  const AddContentDialog({super.key});

  @override
  State<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<AddContentDialog> {
  late final TextEditingController _contentController;
  late final FocusNode _focusNode;

  bool _isLoading = false;
  bool _hasUrl = false;
  String _detectedUrl = '';

  // 优化：添加防抖机制，避免频繁的URL检测
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _focusNode = FocusNode();
    _contentController.addListener(_onTextChanged);

    // 优化：使用 addPostFrameCallback 确保在第一帧渲染后立即聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {

        Future.delayed(Duration(seconds: 150));
        _focusNode.requestFocus();
      }
    });
  }

  void _onTextChanged() {
    // 优化：使用防抖机制，避免频繁的URL检测和UI更新
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
    _debounceTimer?.cancel();
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    _focusNode.dispose();
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

      // 解析链接内容
      final urlStartIndex = content.indexOf(_detectedUrl);
      if (urlStartIndex > 0) {
        // 提取URL前面的文本作为标题
        title = content.substring(0, urlStartIndex).trim();
      }
      if (title.isEmpty) {
        title = 'i18n_addContent_手动添加的链接'.tr;
      }
      final url = _detectedUrl;

      // 生成摘要
      final excerpt = _generateExcerpt(content);

      // 检查是否已存在相同URL的文章
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
        _showErrorMessage('i18n_addContent_添加失败请重试'.tr);
      }
    }
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
              _hasUrl
                  ? 'i18n_addContent_链接添加成功'.tr
                  : 'i18n_addContent_文本添加成功'.tr,
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
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      // 优化：使用 AnimatedPadding 让键盘弹出动画更流畅
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Material(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        elevation: 8,
        shadowColor: theme.shadowColor.withOpacity(0.15),
        child: ConstrainedBox(
          // 优化：限制最大高度，避免键盘弹出时内容过度拉伸
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildContentInput(),
                  const SizedBox(height: 12),
                  // 优化：使用 AnimatedSwitcher 让提示信息切换更流畅
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _hasUrl
                        ? _buildUrlDetectionHint()
                        : (_contentController.text.isNotEmpty
                            ? _buildNoUrlHint()
                            : const SizedBox.shrink()),
                  ),
                  const SizedBox(height: 16),
                  _buildButtons(),
                  const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _buildContentInput() {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
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
        maxLines: 7,
        minLines: 4,
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

/// 显示添加内容对话框
Future<bool?> showAddContentDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled:
        true, // Crucial for the sheet to resize when the keyboard appears.
    backgroundColor: Colors
        .transparent, // The dialog itself will handle its background and shape.
    // 优化：添加键盘动画配置，提升体验
    useSafeArea: true,
    enableDrag: true,
    showDragHandle: false,
    // 优化：使用自定义动画曲线，让弹出更流畅
    transitionAnimationController: null,
    builder: (context) => const AddContentDialog(),
  );
}

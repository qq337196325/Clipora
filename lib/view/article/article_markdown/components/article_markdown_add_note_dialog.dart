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
import 'package:flutter/services.dart';
import 'package:get/get.dart';


/// 显示一个美观的对话框，用于为选定的文本添加笔记。
///
/// [context] BuildContext.
/// [selectedText] 用户选中的文本，将显示在对话框中。
///
/// 返回一个 `Future<String?>`，如果用户确认添加，则返回笔记内容，否则返回 `null`。
Future<String?> showArticleAddNoteDialog({
  required BuildContext context,
  required String selectedText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ArticleAddNoteDialog(selectedText: selectedText),
  );
}

class _ArticleAddNoteDialog extends StatefulWidget {
  const _ArticleAddNoteDialog({
    required this.selectedText,
  });

  final String selectedText;

  @override
  State<_ArticleAddNoteDialog> createState() => _ArticleAddNoteDialogState();
}

class _ArticleAddNoteDialogState extends State<_ArticleAddNoteDialog>
    with TickerProviderStateMixin {
  late final TextEditingController _noteController;
  late final FocusNode _focusNode;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  
  static const int _maxCharacters = 500;
  bool _isInputValid = false;
  int _currentCharacters = 0;
  
  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _focusNode = FocusNode();
    _noteController.addListener(_validateInput);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }
  
  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _validateInput() {
    final text = _noteController.text.trim();
    final charactersCount = _noteController.text.length;
    final isValid = text.isNotEmpty && charactersCount <= _maxCharacters;
    
    setState(() {
      _currentCharacters = charactersCount;
      _isInputValid = isValid;
    });
  }
  
  void _handleSubmit() {
    if (_isInputValid) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(_noteController.text.trim());
    }
  }
  
  void _handleCancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(null);
  }
  

  Widget _buildSelectedTextSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'i18n_article_选中文字'.tr,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              widget.selectedText,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: colorScheme.onSurface,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInputSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverLimit = _currentCharacters > _maxCharacters;
    final progress = (_currentCharacters / _maxCharacters).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_rounded,
                size: 16,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                'i18n_article_笔记内容'.tr,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverLimit 
                      ? colorScheme.errorContainer
                      : colorScheme.surfaceContainerHigh.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_currentCharacters/$_maxCharacters',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOverLimit
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            focusNode: _focusNode,
            maxLines: 4,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '在这里记录你的想法、感悟或灵感...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
          ),
          if (progress > 0) ...[
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: colorScheme.surfaceContainerHigh.withOpacity(0.4),
              ),
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 200),
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isOverLimit 
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
          if (isOverLimit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 16,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '内容超出 $_maxCharacters 字符限制',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                'i18n_article_取消'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isInputValid ? _handleSubmit : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _isInputValid 
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHigh,
                foregroundColor: _isInputValid
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant.withOpacity(0.38),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_add_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'i18n_article_添加笔记'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          elevation: 8,
          shadowColor: colorScheme.shadow.withOpacity(0.15),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildSelectedTextSection(),
                        const SizedBox(height: 20),
                        _buildNoteInputSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
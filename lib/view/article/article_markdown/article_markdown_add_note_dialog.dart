import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
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
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
  static const int _maxCharacters = 500;
  bool _isInputValid = false;
  bool _isInputFocused = false;
  int _currentCharacters = 0;
  
  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _focusNode = FocusNode();
    _noteController.addListener(_validateInput);
    _focusNode.addListener(_onFocusChange);
    
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
  
  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
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
  
  void _onFocusChange() {
    setState(() {
      _isInputFocused = _focusNode.hasFocus;
    });
    
    if (_isInputFocused) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _handleSubmit() {
    if (_isInputValid) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(_noteController.text.trim());
    }
  }
  
  Widget _buildSelectedTextCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '选中文字',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.selectedText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoteInputSection() {
    final isOverLimit = _currentCharacters > _maxCharacters;
    final progress = (_currentCharacters / _maxCharacters).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '笔记内容',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isOverLimit 
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOverLimit) ...[
                    Icon(
                      Icons.warning_rounded,
                      size: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    '$_currentCharacters/$_maxCharacters',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isOverLimit
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 200),
            widthFactor: progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: isOverLimit 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _noteController,
          focusNode: _focusNode,
          maxLines: 3,
          minLines: 2,
          textInputAction: TextInputAction.newline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '记录你的想法、感悟或灵感...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              height: 1.4,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.all(12),
            counterText: '',
          ),
        ),
        if (isOverLimit) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '内容超出${_maxCharacters}字符限制，请适当精简',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(null);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '取消',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isInputValid ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isInputValid 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: _isInputValid 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.38),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: _isInputValid ? 2 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_add_rounded,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '添加笔记',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // 获取键盘高度和屏幕尺寸
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 计算可视区域高度，更保守的空间预留
    final visibleHeight = screenHeight - keyboardHeight;
    final topSafeArea = MediaQuery.of(context).padding.top;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    
    // 对话框高度计算：预留更多安全空间
    final reservedSpace = topSafeArea + bottomSafeArea + 160; // 预留160px的安全空间
    final dialogMaxHeight = (visibleHeight - reservedSpace).clamp(250.0, 380.0);
    
    // 键盘弹出时的偏移策略：更保守的移动距离
    final keyboardOffset = keyboardHeight > 0 
        ? -(keyboardHeight * 0.25).clamp(-100.0, 0.0) // 最多向上移动100px
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
            shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note_add_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '添加笔记',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '记录思考与感悟',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: dialogMaxHeight,
                maxWidth: screenWidth * 0.85,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectedTextCard(),
                    const SizedBox(height: 16),
                    _buildNoteInputSection(),
                  ],
                ),
              ),
            ),
            actions: [
              _buildActionButtons(),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ),
    );
  }
}
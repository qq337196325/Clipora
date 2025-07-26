import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../basics/ui.dart';
import '../my_page/my_page.dart';

class AutoParseTipWidget extends StatefulWidget {
  const AutoParseTipWidget({super.key});

  @override
  State<AutoParseTipWidget> createState() => _AutoParseTipWidgetState();
}

class _AutoParseTipWidgetState extends State<AutoParseTipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    globalBoxStorage.write('auto_parse_enabled',null);
    globalBoxStorage.write('auto_parse_tip_dismissed',null);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 检查是否应该显示提示
  static bool shouldShowTip() {
    // 如果用户已经设置了自动解析（无论开启还是关闭），则不显示提示
    final hasSetAutoParse = globalBoxStorage.hasData('auto_parse_enabled');
    // 如果用户已经关闭了这个提示，则不显示
    final hasDismissedTip = globalBoxStorage.read('auto_parse_tip_dismissed') ?? false;
    
    return !hasSetAutoParse && !hasDismissedTip;
  }

  /// 关闭提示
  void _dismissTip() {
    globalBoxStorage.write('auto_parse_tip_dismissed', true);
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// 跳转到设置页面
  void _goToSettings() {
    _dismissTip();
    // 添加触觉反馈
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return const MyPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldShowTip()) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_fix_high_outlined,
              size: 14,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '可在设置中开或关闭自动解析',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: _goToSettings,
              child: Text(
                '去设置',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _dismissTip,
              child: Icon(
                Icons.close,
                size: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
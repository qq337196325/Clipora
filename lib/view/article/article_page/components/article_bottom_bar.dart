import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bot_toast/bot_toast.dart';
import 'dart:ui';

import 'more_actions_modal.dart';
import '../../controller/article_controller.dart';
import '../../../../basics/logger.dart';

class ArticleBottomBar extends StatefulWidget {
  final bool isVisible;
  final double bottomBarHeight;
  final VoidCallback onBack;
  final VoidCallback onGenerateSnapshot;
  final VoidCallback onReGenerateSnapshot;
  final VoidCallback onReGenerateMarkdown;
  final int articleId;
  final TabController currentTab;
  final int? webTabIndex;
  final List<String>? tabs;

  const ArticleBottomBar({
    super.key,
    required this.isVisible,
    required this.bottomBarHeight,
    required this.onBack,
    required this.onGenerateSnapshot,
    required this.onReGenerateSnapshot,
    required this.onReGenerateMarkdown,
    required this.articleId,
    required this.currentTab,
    this.webTabIndex,
    this.tabs,
  });

  @override
  State<ArticleBottomBar> createState() => _ArticleBottomBarState();
}

class _ArticleBottomBarState extends State<ArticleBottomBar> {
  // 文章控制器
  final ArticleController articleController = Get.find<ArticleController>();

  /// 浏览器访问功能
  Future<void> _openInBrowser() async {
    final url = articleController.articleUrl;
    
    if (url.isEmpty) {
      BotToast.showText(text: 'i18n_article_文章链接不存在'.tr);
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        getLogger().i('✅ 成功在浏览器中打开: $url');
      } else {
        BotToast.showText(text: 'i18n_article_无法打开该链接'.tr);
        getLogger().w('⚠️ 无法打开链接: $url');
      }
    } catch (e) {
      BotToast.showText(text: '${'i18n_article_打开链接失败'.tr}$e');
      getLogger().e('❌ 打开链接失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        offset: widget.isVisible ? Offset.zero : const Offset(0, 2.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: widget.isVisible ? 1.0 : 0.0,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colorScheme.surface.withOpacity(0.95),
                        colorScheme.surfaceVariant.withOpacity(0.9),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.grey.shade50.withOpacity(0.9),
                      ],
              ),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.08),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧 - 返回按钮
                  _buildActionButton(
                    context,
                    icon: Icons.keyboard_arrow_left_rounded,
                    label: 'i18n_article_返回'.tr,
                    isPrimary: true,
                    onPressed: widget.onBack,
                  ),
                  
                  // 中间 - 操作按钮组
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => _buildFloatingButton(
                        context,
                        icon: Icons.explore_outlined,
                        tooltip: 'i18n_article_浏览器打开'.tr,
                        onPressed: _openInBrowser,
                        isEnabled: articleController.articleUrl.isNotEmpty,
                      )),
                    ],
                  ),
                  
                  // 右侧 - 更多操作
                  _buildActionButton(
                    context,
                    icon: Icons.tune_rounded,
                    label: 'i18n_article_更多'.tr,
                    isPrimary: false,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        // elevation: 0, // 设置阴影为0，移除阴影效果
                        isScrollControlled: true,
                        useRootNavigator: true,
                        // barrierColor: Colors.transparent, // 移除遮罩效果
                        builder: (BuildContext context) {
                          return MoreActionsModal(
                            articleId: widget.articleId,
                            onReGenerateSnapshot: widget.onReGenerateSnapshot,
                            onReGenerateMarkdown: widget.onReGenerateMarkdown,
                            currentTab: widget.currentTab,
                            webTabIndex: widget.webTabIndex,
                            tabs: widget.tabs,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 主要操作按钮（带文字标签）
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        splashColor: isPrimary 
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.onSurface.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary 
                ? colorScheme.primaryContainer.withOpacity(0.8)
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(24),
            border: isPrimary 
                ? Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary 
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isPrimary 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 浮动圆形按钮
  Widget _buildFloatingButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          splashColor: colorScheme.primary.withOpacity(0.1),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled 
                  ? (isDark 
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04))
                  : (isDark 
                      ? Colors.white.withOpacity(0.03)
                      : Colors.black.withOpacity(0.02)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEnabled 
                    ? (isDark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06))
                    : (isDark 
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03)),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isEnabled 
                  ? colorScheme.onSurface.withOpacity(0.8)
                  : colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
} 
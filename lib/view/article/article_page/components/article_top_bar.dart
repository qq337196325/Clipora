import 'package:flutter/material.dart';

class ArticleTopBar extends StatelessWidget {
  final bool isVisible;
  final double topBarHeight;
  final TabController tabController;
  final List<String> tabs;

  const ArticleTopBar({
    super.key,
    required this.isVisible,
    required this.topBarHeight,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12, // 上方空隙
      left: 16, // 左侧空隙
      right: 16, // 右侧空隙
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        offset: isVisible ? Offset.zero : const Offset(0, -1.5),
        child: Center(
          child: Container(
            width: 220, // 固定宽度，不占满
            height: topBarHeight,
            child: _buildCustomTabBar(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        // 使用稍微带灰调的背景色，增加层次感
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        // 添加微妙的边框
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          // 增强阴影效果
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          // 添加内阴影效果
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 1,
            offset: const Offset(0, 0.5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        padding:const EdgeInsets.all(2),
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 1.5),
            )
          ],
        ),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
                  tabs: tabs.map((tabName) => Tab(
                    height: 24,
            child: Text(
              tabName,
              style: const TextStyle(
                fontSize: 13.5,
              ),
            ),
          )).toList(),
      ),
    );
  }
} 
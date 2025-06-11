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
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        offset: isVisible ? Offset.zero : const Offset(0, -1.5),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          height: MediaQuery.of(context).padding.top + topBarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCustomTabBar(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        tabs: tabs.map((tabName) => Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              tabName,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
} 
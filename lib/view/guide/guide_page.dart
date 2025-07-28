// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../basics/app_config_interface.dart';
import '../../basics/logger.dart';
import '../../route/route_name.dart';
import 'guide_service.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> with GuidePageBLoC {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 设置状态栏样式
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Stack(
          children: [
            // 背景渐变 - 全屏覆盖
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
              ),
            ),
            // 主要内容
            Column(
              children: [
                // 状态栏高度填充 + 跳过按钮
                _buildTopSection(context),
                // 引导页面内容
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: guideItems.length,
                    itemBuilder: (context, index) {
                      return _buildGuidePage(guideItems[index]);
                    },
                  ),
                ),
                // 底部操作区域
                _buildBottomSection(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: skipGuide,
          child: Text(
            'i18n_guide_跳过'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidePage(GuideItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标或插图
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          // 标题
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 描述
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        children: [
          // 页面指示器
          _buildPageIndicator(),
          const SizedBox(height: 32),
          // 操作按钮
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        guideItems.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPageIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPageIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isLastPage = currentPageIndex == guideItems.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLastPage ? completeGuide : nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667eea),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          isLastPage ? 'i18n_guide_开始使用'.tr : 'i18n_guide_下一步'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// 业务逻辑 Mixin
mixin GuidePageBLoC on State<GuidePage> {
  late PageController pageController;
  int currentPageIndex = 0;

  List<GuideItem> get guideItems => [
        GuideItem(
          icon: Icons.bookmark_add_outlined,
          title: 'i18n_guide_智能收藏'.tr,
          description:
              'i18n_guide_随时随地收集有价值的内容支持分享链接方式进行收藏您感兴趣的内容让知识不再丢失'.tr,
        ),
        GuideItem(
          icon: Icons.folder_outlined,
          title: 'i18n_guide_分类整理'.tr,
          description: 'i18n_guide_智能分类管理你的收藏标签文件夹多维度组织快速找到所需内容'.tr,
        ),
        GuideItem(
          icon: Icons.edit_note_outlined,
          title: 'i18n_guide_深度阅读'.tr,
          description: 'i18n_guide_专注的阅读体验支持标注笔记翻译让阅读更有价值'.tr,
        ),
      ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // 记录页面访问
    buryingPoint();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  void nextPage() {
    if (currentPageIndex < guideItems.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipGuide() {
    _completeGuideProcess();
  }

  void completeGuide() {
    _completeGuideProcess();
  }

  void _completeGuideProcess() async {
    try {
      // 保存引导完成状态
      await GuideService.markGuideCompleted();

      // 记录完成引导的埋点
      getLogger().i('用户完成引导页面，当前页面: ${currentPageIndex}');

      // 跳转到主页面（使用现有的路由名称）
      if (mounted) {
        final config = Get.find<IConfig>();

        if(config.isCommunityEdition){
          context.go('/${RouteName.index}');
          return;
        }
        context.go('/${RouteName.login}');
      }
    } catch (e) {
      getLogger().e('完成引导过程出错: $e');
      // 即使出错也要跳转，避免用户被困在引导页
      if (mounted) {
        context.go('/${RouteName.login}');
      }
    }
  }

  void buryingPoint() {
    getLogger().i('用户访问引导页面');
  }
}

// 引导项数据模型
class GuideItem {
  final IconData icon;
  final String title;
  final String description;

  const GuideItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/view/article_v2/tabs/mhtml/article_mhtml_widget.dart';
import '/view/article_v2/tabs/web/article_web_widget.dart';
import '/view/article_v2/tabs/markdown/article_markdown_widget.dart';
import '/view/article_v2/widgets/article_top_bar.dart';
import '/view/article_v2/controllers/tab_controller.dart';
import '/view/article_v2/widgets/article_bottom_bar.dart';
import 'controllers/article_page_controller.dart';


class ArticlePage extends StatefulWidget {

  final int id;

  const ArticlePage({
    super.key,
    required this.id,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}



class _ArticlePageState extends State<ArticlePage> with ArticlePageBLoC {



  @override
  Widget build(BuildContext context) {

    // 使用PopScope来监听返回事件，在返回前提前销毁WebView避免闪烁
    return Scaffold(
      body:

      GetBuilder<ArticleTabController>(
        tag: 'article_tab_${widget.id}', // 使用tag来确保获取正确的控制器实例
        builder: (model) {

          // 响应式状态观察 - 主内容UI
          return Stack(
            children: [
              // 主要内容区域 - 响应式构建
              // _buildContentView(context),

              // // 顶部操作栏 - 响应式UI可见性控制
              ArticleTopBar(
                  articleId: widget.id,
              ),
              //
              // // 底部操作栏 - 响应式UI可见性控制
              ArticleBottomBar(
                isVisible: true,
                bottomBarHeight: 40,
                onBack: () async {
                  // await _prepareForPageExit();
                  // await articleController.manualSavePosition();
                  // // await (_markdownWidgetKey.currentState)?.manualSavePosition();
                  // // Navigator.of(context).pop();
                  // context.pop(true);
                },
              ),
            ],
          );
        },
      ),


    );


    //   PopScope(
    //   canPop: true,
    //   onPopInvokedWithResult: (didPop, result) async {
    //     if (!didPop) {
    //       // 执行优化的返回操作
    //       // await _handleOptimizedBackNavigation(context);
    //     }
    //   },
    //   child: ,
    //
    //
    //   // AnimatedSwitcher(
    //   //   duration: const Duration(milliseconds: 500),
    //   //   transitionBuilder: (child, animation) {
    //   //     return FadeTransition(
    //   //       opacity: animation,
    //   //       child: SlideTransition(
    //   //         position: Tween<Offset>(
    //   //           begin: const Offset(0, 0.05),
    //   //           end: Offset.zero,
    //   //         ).animate(CurvedAnimation(
    //   //           parent: animation,
    //   //           curve: Curves.easeOutCubic,
    //   //         )),
    //   //         child: child,
    //   //       ),
    //   //     );
    //   //   },
    //   //   child:
    //   // )
    //
    //
    //
    // );
  }


}


mixin ArticlePageBLoC on State<ArticlePage> {

  // final ArticleTabController tabController = Get.put(ArticleTabController());

  // 初始化控制器
  late final ArticleTabController tabController;
  late final ArticlePageController articlePageController;

  @override
  void initState() {
    super.initState();

    // 进入沉浸式模式，隐藏系统状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);


    // 初始化控制器
    tabController = Get.put(ArticleTabController(), tag: 'article_tab_${widget.id}');
    articlePageController = Get.put(ArticlePageController(), tag: 'article_${widget.id}');
    _init();
  }

  _init() async {
    await articlePageController.loadArticleById(widget.id);
    if(articlePageController.currentArticle != null){
      // tabController.

      tabController.tabs.clear();
      tabController.tabWidgets.clear();
      // 根据isGenerateMarkdown决定是否显示图文tab
      if (articlePageController.currentArticle!.isGenerateMarkdown) {
        tabController.tabs.insert(0, 'i18n_article_图文'.tr);
        tabController.tabWidgets.insert(0, ArticleMarkdownWidget());
      }

      // 网页tab
      if (articlePageController.currentArticle!.url.isNotEmpty) {
        tabController.tabs.add('i18n_article_网页'.tr);
        tabController.tabWidgets.add(ArticleWebWidget());
      }

      // 根据isGenerateMhtml决定是否显示快照tab
      if (articlePageController.currentArticle!.mhtmlPath != "") {
        tabController.tabs.add('i18n_article_快照'.tr);
        tabController.tabWidgets.add(ArticleMhtmlWidget());
      }
      tabController.update();
    }
  }

  @override
  void dispose() {
    // 清理控制器
    Get.delete<ArticleTabController>(tag: 'article_tab_${widget.id}');
    Get.delete<ArticlePageController>(tag: 'article_${widget.id}');
    super.dispose();
  }


}


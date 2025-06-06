import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';


class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with TickerProviderStateMixin,ArticlePageBLoC {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文章阅读'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child:  SegmentedTabControl(
                controller: tabController, // 使用自定义的TabController
                barDecoration: BoxDecoration(
                  color: Color(0xFFF3F2F1),
                  borderRadius: BorderRadius.circular(3),
                ),
                tabTextColor: Color(0xFF161514),
                selectedTabTextColor: Color(0xFFF3F2F1),
                squeezeIntensity: 4,
                height: 28,
                tabPadding: EdgeInsets.symmetric(horizontal: 8),
                tabs: tabs,
              )
            ),
            Expanded(
              child: TabBarView(
                // controller: tabController, // 使用自定义的TabController
                // physics: const NeverScrollableScrollPhysics(), // 禁用默认滑动切换
                controller: tabController, // 使用自定义的TabController
                physics: const BouncingScrollPhysics(),
                // clipBehavior: Clip.none, // 避免裁剪问题
                children: tabWidget,
              ),
            ),
          ],
        ),
      ),
    
    );
  }


}

mixin ArticlePageBLoC on State<ArticlePage> {

  late TabController tabController;
   List<SegmentTab> tabs = [];
  List<Widget> tabWidget = [];

   @override
  void initState() {

   tabController = TabController(
     length: 4,
     vsync: this as TickerProvider,
     animationDuration: const Duration(milliseconds: 350), // 优化切换动画时长
   );

    tabs.add(const SegmentTab(label: '网页', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    tabs.add(const SegmentTab(label: '图文', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    tabs.add(const SegmentTab(label: '快照', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    tabs.add(const SegmentTab(label: '快照图', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    super.initState();
  }



}


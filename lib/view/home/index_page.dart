import 'dart:io';
import 'dart:typed_data';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import '../../../route/route_name.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin, IndexPageBLoC {

@override
  Widget build(BuildContext context) {
    return Scaffold( 
      // appBar: AppBar(
      //   title: const Text('InAppWebView Demo'),
      //   backgroundColor: Colors.blue,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: Row(
                children: [
                  // 左边的"我的"图标
                  GestureDetector(
                    onTap: () {
                      // 处理"我的"点击事件
                      // TODO: 添加"我的"页面路由
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('我的页面')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Icon(
                        Icons.person_outline,
                        size: 24,
                        color: Color(0xFF161514),
                      ),
                    ),
                  ),
                  // 中间的 SegmentedTabControl
                  Expanded(
                    child: SegmentedTabControl(
                      controller: tabController, // 使用自定义的TabController
                      barDecoration: BoxDecoration(
                        color: Color(0xFFF3F2F1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      tabTextColor: Color(0xFF161514),
                      selectedTabTextColor: Color(0xFFF3F2F1),
                      squeezeIntensity: 3,
                      height: 28,
                      tabPadding: EdgeInsets.symmetric(horizontal: 8),
                      tabs: tabs,
                    ),
                  ),
                  // 右边的"添加"图标
                  GestureDetector(
                    onTap: () {
                      // 处理"添加"点击事件
                      // TODO: 添加"添加"页面路由
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('添加功能')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 24,
                        color: Color(0xFF161514),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  // 记录滑动增量
                  _updatePanDelta(details.delta);
                },
                onPanEnd: (details) {
                  // 检查是否应该切换页面
                  _handlePanEnd();
                },
                child: TabBarView(
                  controller: tabController, // 使用自定义的TabController
                  physics: const NeverScrollableScrollPhysics(), // 禁用默认滑动切换
                  clipBehavior: Clip.none, // 避免裁剪问题
                  children: tabWidget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

mixin IndexPageBLoC on State<IndexPage> {

  late TabController tabController;
  List<SegmentTab> tabs = [];
  List<Widget> tabWidget = [];
  
  // 手势检测相关变量
  double _totalDx = 0.0; // 水平滑动总距离
  double _totalDy = 0.0; // 垂直滑动总距离
  static const double _horizontalThreshold = 80.0; // 水平滑动阈值
  static const double _verticalTolerance = 80.0; // 垂直滑动容忍度

  // 更新滑动增量
  void _updatePanDelta(Offset delta) {
    _totalDx += delta.dx;
    _totalDy += delta.dy.abs(); // 垂直距离取绝对值
  }

  // 处理滑动结束
  void _handlePanEnd() {
    // 只有当水平滑动距离足够大，且垂直滑动距离相对较小时，才切换页面
    if (_totalDx.abs() > _horizontalThreshold && _totalDy < _verticalTolerance) {
      if (_totalDx > 0) {
        // 向右滑动，切换到上一个tab
        if (tabController.index > 0) {
          tabController.animateTo(tabController.index - 1);
        }
      } else {
        // 向左滑动，切换到下一个tab
        if (tabController.index < tabController.length - 1) {
          tabController.animateTo(tabController.index + 1);
        }
      }
    }
    
    // 重置滑动距离
    _totalDx = 0.0;
    _totalDy = 0.0;
  }

    @override
  void initState() {

    tabController = TabController(
      length: 2, 
      vsync: this as TickerProvider,
      animationDuration: const Duration(milliseconds: 350), // 优化切换动画时长
    );
    
    // 添加页面切换监听，确保tab指示器与页面同步
    tabController.addListener(() {
      // 监听tab切换，保持状态同步
      if (mounted) {
        setState(() {});
      }
    });

    tabs.add(const SegmentTab(label: '首页', color: Color(0xFF00BCF6)));
    tabWidget.add(Container(
      // 添加一些内容以便测试滑动效果
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              await context.push('/${RouteName.articlePage}');
            },
            child: Center(
              child: Text('文章页面', style: TextStyle(fontSize: 18)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              await context.push('/${RouteName.articlePage2}');
            },
            child: Center(
              child: Text('文章页面2', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    )); 

    tabs.add(const SegmentTab(label: '收藏', color: Color(0xFF00BCF6)));
    tabWidget.add(Container(
      child: const Center(
        child: Text('供应商+商品页面', style: TextStyle(fontSize: 18)),
      ),
    )); 


    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

}

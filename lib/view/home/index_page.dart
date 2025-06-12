import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'group_widget.dart';
import 'index_widget.dart';
import 'components/my_page_modal.dart';


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
              // 添加渐变背景和阴影效果
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // 左边的"我的"图标 - 添加更好的交互效果
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // 添加触觉反馈
                        HapticFeedback.lightImpact();
                        _showMyPageModal();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 22,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 中间的 SegmentedTabControl - 优化样式
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: SegmentedTabControl(
                        controller: tabController,
                        barDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade50,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                        indicatorDecoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00BCF6),
                              Color(0xFF0099CC),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BCF6).withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        tabTextColor: Colors.grey.shade700,
                        selectedTabTextColor: Colors.white,
                        squeezeIntensity: 2,
                        height: 32,
                        tabPadding: const EdgeInsets.symmetric(horizontal: 12),
                        tabs: tabs.map((tab) => SegmentTab(
                          label: tab.label,
                          color: tab.color,
                        )).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 右边的"搜索"图标 - 突出显示并添加动画
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // 添加触觉反馈
                        HapticFeedback.lightImpact();
                        // TODO: 添加"搜索"页面路由
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('搜索功能'),
                            backgroundColor: Colors.grey.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200.withOpacity(0.6),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              offset: const Offset(0, -1),
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: Colors.grey.shade700,
                        ),
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
                  children: [
                    IndexWidget(), 
                    GroupPage(),
                  ],
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
  
  // 手势检测相关变量
  double _totalDx = 0.0; // 水平滑动总距离
  double _totalDy = 0.0; // 垂直滑动总距离
  static const double _horizontalThreshold = 80.0; // 水平滑动阈值
  static const double _verticalTolerance = 80.0; // 垂直滑动容忍度

  // 上次活跃时间，用于判断是否需要刷新
  DateTime? _lastActiveTime;

  @override
  void initState() {
    super.initState();

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
    tabs.add(const SegmentTab(label: '分组', color: Color(0xFF00BCF6)));

  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

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

  /// 显示"我的"页面模态框
  void _showMyPageModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return const MyPageModal();
      },
    );
  }

}

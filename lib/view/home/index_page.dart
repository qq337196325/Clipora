import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../basics/ui.dart';
import '../../services/snapshot_service_widget.dart';
import 'components/tutorial_guide_widget.dart';
import 'group/group_widget.dart';
import 'index_widget.dart';
import 'my_page/my_page.dart';
import '../../route/route_name.dart';
import 'components/floating_add_input.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with TickerProviderStateMixin, IndexPageBLoC {
  @override
  Widget build(BuildContext context) {
    final tabs = [
      SegmentTab(label: 'i18n_home_首页'.tr, color: const Color(0xFF00BCF6)),
      SegmentTab(label: 'i18n_home_分组'.tr, color: const Color(0xFF00BCF6)),
    ];

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            Theme.of(context).scaffoldBackgroundColor, // 或你想要的颜色
        // systemNavigationBarIconBrightness: Brightness.light, // 或 light，看你的主题
      ),
    );

    return Stack(
      children: [
        SnapshotServiceWidget(),
        Scaffold(
          // appBar: AppBar(
          //   title: const Text('InAppWebView Demo'),
          //   backgroundColor: Colors.blue,
          //   elevation: 0,
          // ),
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  // 添加渐变背景和阴影效果
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).cardColor,
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 22,
                              color: Theme.of(context).iconTheme.color,
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
                                color: Theme.of(context)
                                    .shadowColor
                                    .withOpacity(0.04),
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
                                  Theme.of(context).colorScheme.surface,
                                  Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                            ),
                            indicatorDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            tabTextColor:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            selectedTabTextColor:
                                Theme.of(context).colorScheme.onPrimary,
                            squeezeIntensity: 2,
                            height: 32,
                            tabPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            tabs: tabs,
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
                            // 跳转到搜索页面
                            context.push("/${RouteName.search}");
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).cardColor.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.6),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withOpacity(0.08),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.7),
                                  offset: const Offset(0, -1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search_rounded,
                              size: 22,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // 添加触觉反馈
                            HapticFeedback.lightImpact();
                            // 显示添加内容对话框
                            _showAddContentDialog();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).cardColor.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.6),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withOpacity(0.08),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.7),
                                  offset: const Offset(0, -1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              size: 22,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
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

                //
                // InkWell(
                //   onTap: (){
                //     context.push("/${RouteName.aiOrderPage}");
                //   },
                //   child: Container(
                //     child: Text("跳转到支付页面"),
                //   ),
                // )
              ],
            ),
          ),
        ),
        // This is the hidden WebView that will be used for background tasks.

        // Offstage(
        //   offstage: true,
        //   child: SizedBox(
        //     width: 1080,  // 最小尺寸，因为是后台任务
        //     height: 2460,
        //     child: SnapshotServiceWidget(),
        //   ),
        // ),

        // 浮动输入框背景遮罩
        if (_showFloatingInput)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeFloatingInput,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

        // 浮动输入框
        if (_showFloatingInput)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            top: _calculateFloatingInputTop(),
            left: 16,
            right: 16,
            child: FloatingAddInput(
              onClose: _closeFloatingInput,
              onSuccess: _onAddContentSuccess,
            ),
          ),
      ],
    );
  }
}

mixin IndexPageBLoC on State<IndexPage> {
  late TabController tabController;

  // 手势检测相关变量
  double _totalDx = 0.0; // 水平滑动总距离
  double _totalDy = 0.0; // 垂直滑动总距离
  static const double _horizontalThreshold = 80.0; // 水平滑动阈值
  static const double _verticalTolerance = 80.0; // 垂直滑动容忍度

  // 浮动输入框状态
  bool _showFloatingInput = false;
  bool _isClosingFloatingInput = false; // 防止重复关闭

  @override
  void initState() {
    super.initState();

    // _init();
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

    // 使用addPostFrameCallback确保在第一帧渲染后执行，避免阻塞UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() async {
    // getLogger().e('❌ 同步过程发生异常0000000000000000000');

    // 检查是否需要显示引导
    await _checkAndShowTutorial();






  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  /// 检查并显示引导
  Future<void> _checkAndShowTutorial() async {
    bool? tutorialCompleted = globalBoxStorage.read('tutorial_completed');

    if (tutorialCompleted == null) {
      // 延迟一点时间，确保页面完全加载
      await Future.delayed(const Duration(milliseconds: 200), () async {
        if (mounted) {
          await _showTutorialGuide();
        }
      });
    }
  }

  /// 显示引导弹窗
  Future<void> _showTutorialGuide() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TutorialGuideWidget(
        onCompleted: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // 更新滑动增量
  void _updatePanDelta(Offset delta) {
    _totalDx += delta.dx;
    _totalDy += delta.dy.abs(); // 垂直距离取绝对值
  }

  // 处理滑动结束
  void _handlePanEnd() {
    // 只有当水平滑动距离足够大，且垂直滑动距离相对较小时，才切换页面
    if (_totalDx.abs() > _horizontalThreshold &&
        _totalDy < _verticalTolerance) {
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return const MyPage();
      },
    );
  }

  /// 显示浮动添加内容输入框
  void _showAddContentDialog() {
    if (_showFloatingInput || _isClosingFloatingInput) return; // 防止重复打开

    setState(() {
      _showFloatingInput = true;
    });
  }

  /// 关闭浮动输入框
  void _closeFloatingInput() {
    if (_isClosingFloatingInput) return; // 防止重复关闭

    _isClosingFloatingInput = true;

    // 先隐藏键盘，然后关闭浮动框
    FocusScope.of(context).unfocus();

    // 延迟一点时间确保键盘完全收起
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showFloatingInput = false;
          _isClosingFloatingInput = false; // 重置状态
        });
      }
    });
  }

  /// 处理添加内容成功
  void _onAddContentSuccess() {
    // 内容添加成功，可以在这里做一些刷新操作
    // 例如刷新首页列表等
  }


  /// 计算浮动输入框的位置
  double _calculateFloatingInputTop() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    // 计算浮动框的理想高度（根据内容动态调整）
    final idealHeight = keyboardHeight > 0 ? 320.0 : 400.0;

    // 计算顶部位置
    double topPosition;

    if (keyboardHeight > 0) {
      // 键盘弹出时，在剩余可用空间中居中显示
      final keyboardTop = screenHeight - keyboardHeight - safeAreaBottom;
      final availableHeight = keyboardTop - safeAreaTop; // 键盘上方的可用高度

      // 在可用空间中居中
      final centerY = safeAreaTop + (availableHeight - idealHeight) / 2;

      // 设置合理的边界
      final minTop = safeAreaTop + 20; // 顶部最小边距
      final maxTop = keyboardTop - idealHeight - 20; // 距离键盘最小边距

      topPosition = centerY.clamp(minTop, maxTop);
    } else {
      // 键盘未弹出时，在整个屏幕中居中显示
      final contentHeight = screenHeight - safeAreaTop - safeAreaBottom;
      final centerY = safeAreaTop + (contentHeight - idealHeight) / 2;

      // 确保有合理的边距，但优先保持居中
      final minTop = safeAreaTop + 80; // 顶部最小边距
      final maxTop = screenHeight - safeAreaBottom - idealHeight - 80; // 底部最小边距

      topPosition = centerY.clamp(minTop, maxTop);
    }

    return topPosition;
  }
}

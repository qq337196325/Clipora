import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../api/user_api.dart';
import '../../basics/config.dart';
import '../../basics/logger.dart';
import '../../basics/ui.dart';
import '../../basics/utils/user_utils.dart';
import '../../db/article/service/article_service.dart';
import '../../services/get_sync_data/get_sync_data.dart';
import '../../services/get_sync_data/increment_sync_data.dart';
import '../../services/snapshot_service_widget.dart';
import '../../services/update_data_sync/data_sync_service.dart';
import 'components/tutorial_guide_widget.dart';
import 'utils/upgrade_service.dart';
import 'group/group_widget.dart';
import 'index_widget.dart';
import 'my_page/my_page.dart';
import '../../route/route_name.dart';
import 'components/add_content_dialog.dart';
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
          Positioned(
            top: 100,
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

  // 同步进度相关
  double _syncProgress = 0.0;
  String _syncMessage = 'i18n_home_正在初始化'.tr;

  // 浮动输入框状态
  bool _showFloatingInput = false;

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

    await _checkAppVersion(); // 在这里调用版本检查

    if (isHuawei) {
      bool? huaweiStoragePermission =
          globalBoxStorage.read('huaweiStoragePermission');
      if (huaweiStoragePermission == null) {
        await handleAndroidPermission();
      }
    }

    // 登录过的用户显示同步数据
    bool? isNotLogin = globalBoxStorage.read('is_not_login');
    if (isNotLogin == null || isNotLogin == false) {
      checkCompleteSync();
    }

    if (isNotLogin != null && isNotLogin == true) {
      // 首次登录的用户，添加介绍文章
      // 调用上传接口
      final response = await UserApi.getInitDataApi({});
      // 检查响应结果
      if (response['code'] != 0) {
        return;
      }

      if (response['data']["init_article"].length <= 0) {
        return;
      }

      try {
        for (int i = 0; response['data']["init_article"].length > i; i++) {
          Map<String, dynamic> initArticle =
              response['data']["init_article"][i];

          ArticleService.instance.createArticleFromShare(
            title: initArticle["title"]!,
            url: initArticle["url"]!,
            originalContent: initArticle["title"]!,
            excerpt: initArticle["title"]!,
            tags: [], // 可以根据内容类型添加不同标签
          );
        }

        globalBoxStorage.write('is_not_login', false); // 将状态设为登录过
      } catch (e) {
        getLogger().e('❌ 添加初始化文章失败: $e');
        return false;
      }
    }
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
    setState(() {
      _showFloatingInput = true;
    });
  }

  /// 关闭浮动输入框
  void _closeFloatingInput() {
    setState(() {
      _showFloatingInput = false;
    });
  }

  /// 处理添加内容成功
  void _onAddContentSuccess() {
    // 内容添加成功，可以在这里做一些刷新操作
    // 例如刷新首页列表等
  }

  /// 检查应用版本
  Future<void> _checkAppVersion() async {
    // 创建服务实例并调用检查方法
    await UpgradeService().checkAndShowUpgradeDialog(context);
  }

  final box = GetStorage();

  /// 新用户检查全量更新
  checkCompleteSync() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // box.write('completeSyncStatus', false);  /// 测试用
    bool? completeSyncStatus = box.read('completeSyncStatus');
    // getLogger().i('更新预热URL列表222');

    // 如果需要全量同步，显示对话框
    if (completeSyncStatus == null || completeSyncStatus == false) {
      if (mounted) {
        showDialog<bool>(
          context: context,
          barrierDismissible: false, // 防止用户意外关闭同步对话框
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return buildSyncDialogWithProgress(
                context,
                _syncMessage,
                _syncProgress,
              );
            },
          ),
        );

        // 开始同步过程
        _startSyncProcess();
      }
    } else {
      /// 只有全量更新完或者不需要全量更新的时候初始化
      Get.put(DataSyncService(), permanent: true);
      Get.put(IncrementSyncData(), permanent: true);
    }
  }

  /// 开始同步过程
  void _startSyncProcess() async {
    try {
      getLogger().i('🔄 开始执行全量同步...');

      // 更新同步状态显示
      _updateSyncProgress('i18n_home_正在初始化同步'.tr, 0.1);

      // 导入全量同步类
      final getSyncData = GetSyncData();

      // 执行全量同步，传递进度回调
      final syncResult = await getSyncData.completeSyncAllData(
        progressCallback: (message, progress) {
          _updateSyncProgress(message, progress);
        },
      );

      if (syncResult) {
        getLogger().i('✅ 全量同步成功完成');

        _updateSyncProgress('i18n_home_正在完成同步'.tr, 0.9);
        await Future.delayed(const Duration(milliseconds: 500));

        // 更新同步状态显示
        _updateSyncProgress('i18n_home_同步完成'.tr, 1.0);

        // 等待一下让用户看到完成状态
        await Future.delayed(const Duration(milliseconds: 1000));

        // 保存同步完成状态并关闭对话框
        if (mounted) {
          box.write('completeSyncStatus', true);
        }
      } else {
        getLogger().e('❌ 全量同步失败');

        // 更新同步状态显示
        _updateSyncProgress('i18n_home_同步失败请检查网络连接后重试'.tr, 0.0);

        // 等待一下然后关闭对话框
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      getLogger().e('❌ 同步过程发生异常: $e');

      // 更新同步状态显示
      _updateSyncProgress(
          'i18n_home_同步异常'.tr +
              (e.toString().length > 50
                  ? e.toString().substring(0, 50) + '...'
                  : e.toString()),
          0.0);
    } finally {
      final serviceCurrentTime = await getServiceCurrentTime();
      box.write('serviceCurrentTime', serviceCurrentTime);

      /// 只有全量更新完或者不需要全量更新的时候初始化
      Get.put(DataSyncService(), permanent: true);
      Get.put(IncrementSyncData(), permanent: true);

      // 等待一下然后关闭对话框
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  /// 更新同步进度
  void _updateSyncProgress(String message, double progress) {
    if (mounted) {
      setState(() {
        _syncMessage = message;
        _syncProgress = progress;
      });
    }
  }
}

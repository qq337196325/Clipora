import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../basics/logger.dart';
import '../../services/share_service.dart';

enum ShareStatus { initial, dropping, spreading, success, error }

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage>
    with SharePageBLoC, TickerProviderStateMixin {
  // 动画控制器声明在 State 类中
  late AnimationController dropController;
  late AnimationController spreadController;
  late AnimationController successController;
  late AnimationController breatheController;

  late Animation<double> _dropAnimation;
  late Animation<double> _spreadAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    startShareProcess();
  }

  void _initAnimations() {
    // 墨水滴落动画控制器
    dropController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 墨水扩散动画控制器
    spreadController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 成功图标缩放动画控制器
    successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 呼吸效果动画控制器
    breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 定义动画曲线
    _dropAnimation = CurvedAnimation(
      parent: dropController,
      curve: Curves.easeInQuart,
    );

    _spreadAnimation = CurvedAnimation(
      parent: spreadController,
      curve: Curves.easeOutCirc,
    );

    _successScaleAnimation = CurvedAnimation(
      parent: successController,
      curve: Curves.elasticOut,
    );

    _breatheAnimation = CurvedAnimation(
      parent: breatheController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    dropController.dispose();
    spreadController.dispose();
    successController.dispose();
    breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            // 纸张质感渐变背景
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFAF7F0),
                Color(0xFFF5F1E8),
                Color(0xFFF0EBE3),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 纸张纹理背景
              _buildPaperTexture(),
              // 主要内容区域
              _buildMainContent(),
              // 墨水动画层
              _buildInkAnimation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaperTexture() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PaperTexturePainter(),
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // 品牌标识区域
            _buildBrandSection(),
            const Spacer(flex: 1),
            // 状态信息区域
            _buildStatusSection(),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        // Clipora 品牌标识
        Text(
          "Clipora",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: Colors.grey[800],
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "i18n_theme_您的灵感墨水池".tr,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _buildStatusWidget(),
    );
  }

  Widget _buildStatusWidget() {
    switch (status) {
      case ShareStatus.initial:
      case ShareStatus.dropping:
      case ShareStatus.spreading:
        return Column(
          key: const ValueKey('processing'),
          children: [
            const SizedBox(height: 60), // 为墨水动画预留空间
            Text(
              _getStatusMessage(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case ShareStatus.success:
        return Column(
          key: const ValueKey('success'),
          children: [
            AnimatedBuilder(
              animation: _breatheAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_breatheAnimation.value * 0.05),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF2E7D32),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF2E7D32),
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              "i18n_theme_收藏成功".tr,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "i18n_theme_内容已安全保存到您的灵感库".tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        );

      case ShareStatus.error:
        return Column(
          key: const ValueKey('error'),
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFFD32F2F),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFFD32F2F),
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "i18n_theme_收藏失败".tr,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "i18n_theme_请稍后重试".tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildInkAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([dropController, spreadController]),
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: InkDropPainter(
              dropProgress: _dropAnimation.value,
              spreadProgress: _spreadAnimation.value,
              status: status,
            ),
          ),
        );
      },
    );
  }

  String _getStatusMessage() {
    switch (status) {
      case ShareStatus.initial:
        return "i18n_theme_准备接收您的灵感".tr;
      case ShareStatus.dropping:
        return "i18n_theme_墨水正在滴落".tr;
      case ShareStatus.spreading:
        return "i18n_theme_正在精心收藏".tr;
      default:
        return "";
    }
  }
}

// 自定义绘制器：纸张纹理
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.02)
      ..strokeWidth = 0.5;

    // 绘制细微的纸张纹理线条
    for (int i = 0; i < 100; i++) {
      final x = math.Random().nextDouble() * size.width;
      final y = math.Random().nextDouble() * size.height;
      final length = math.Random().nextDouble() * 20 + 5;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + length, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 自定义绘制器：墨水滴落和扩散效果
class InkDropPainter extends CustomPainter {
  final double dropProgress;
  final double spreadProgress;
  final ShareStatus status;

  InkDropPainter({
    required this.dropProgress,
    required this.spreadProgress,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (status == ShareStatus.dropping && dropProgress > 0) {
      _paintDrop(canvas, size);
    }

    if (status == ShareStatus.spreading && spreadProgress > 0) {
      _paintSpread(canvas, size);
    }
  }

  void _paintDrop(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;

    final centerX = size.width * 0.5;
    final maxDropY = size.height * 0.4;
    final currentY = maxDropY * dropProgress;

    // 绘制水滴形状
    final dropPath = Path();
    final dropRadius = 6.0;

    dropPath.addOval(Rect.fromCircle(
      center: Offset(centerX, currentY),
      radius: dropRadius,
    ));

    canvas.drawPath(dropPath, paint);
  }

  void _paintSpread(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final centerX = size.width * 0.5;
    final centerY = size.height * 0.4;
    final maxRadius = 50.0;
    final currentRadius = maxRadius * spreadProgress;

    canvas.drawCircle(
      Offset(centerX, centerY),
      currentRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

mixin SharePageBLoC on State<SharePage> {
  ShareStatus status = ShareStatus.initial;

  // 启动分享处理流程
  void startShareProcess() {
    // 等待一个微任务周期，确保 _initAnimations() 已经执行完毕
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() async {
    try {
      // 开始动画序列
      await _playAnimationSequence();

      // 实际处理分享内容
      final initialMedia =
          await ReceiveSharingIntent.instance.getInitialMedia();
      await Get.find<ShareService>().processInitialShare(initialMedia);

      if (!mounted) return;

      // 成功状态
      setState(() {
        status = ShareStatus.success;
      });

      // 播放成功动画
      (this as _SharePageState).successController.forward();

      // 播放有限次数的呼吸动画，避免无限闪烁
      for (int i = 0; i < 2; i++) {
        await (this as _SharePageState).breatheController.forward();
        await (this as _SharePageState).breatheController.reverse();
      }

      // 等待动画完成后关闭应用程序
      await Future.delayed(const Duration(milliseconds: 500));

      // 分享处理完成后直接关闭应用程序
      SystemNavigator.pop();
    } catch (e) {
      getLogger().e("Error processing share", error: e);
      if (!mounted) return;

      setState(() {
        status = ShareStatus.error;
      });

      await Future.delayed(const Duration(milliseconds: 1000));

      // 分享处理失败后也直接关闭应用程序
      SystemNavigator.pop();
    }
  }

  Future<void> _playAnimationSequence() async {
    // 1. 墨水滴落阶段
    setState(() {
      status = ShareStatus.dropping;
    });
    (this as _SharePageState).dropController.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. 墨水扩散阶段
    setState(() {
      status = ShareStatus.spreading;
    });
    (this as _SharePageState).spreadController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
  }
}

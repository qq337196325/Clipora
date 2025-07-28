// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class TutorialGuideWidget extends StatefulWidget {
  final VoidCallback? onCompleted;
  
  const TutorialGuideWidget({
    super.key,
    this.onCompleted,
  });

  @override
  State<TutorialGuideWidget> createState() => _TutorialGuideWidgetState();
}

class _TutorialGuideWidgetState extends State<TutorialGuideWidget>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _lottieController;
  
  // 可调整的点击位置配置 - 针对不同步骤的精确位置
  final List<Map<String, dynamic>> _clickPositions = [
    {
      'x': 0.5,  // 分享图标的相对位置
      'y': 0.87,   // 相对于图片高度的位置
      'description': '分享图标',
    },
    {
      'x': 0.36,   // Clipora logo 的相对位置
      'y': 0.4,   // 相对于图片高度的位置
      'description': 'Clipora图标',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _lottieController.repeat();
  }
  
  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildContent(),
          const SizedBox(height: 24),
          // _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).primaryColor,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'i18n_guide_如何收藏'.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${currentStep + 1}/2',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _onCompleted,
          icon: Icon(
            Icons.close,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentStep == 0 ? 'i18n_guide_在其他应用中点击分享'.tr : 'i18n_guide_点击Clipora图标即可收藏'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: _buildImageWithClickableArea(),
        ),
      ],
    );
  }

  // Widget _buildButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: OutlinedButton(
  //           onPressed: _onCompleted,
  //           style: OutlinedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //             side: BorderSide(
  //               color: Theme.of(context).dividerColor,
  //             ),
  //           ),
  //           child: Text(
  //             'i18n_guide_跳过'.tr,
  //             style: TextStyle(
  //               color: Theme.of(context).textTheme.bodyLarge?.color,
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: ElevatedButton(
  //           onPressed: currentStep == 1 ? _onCompleted : null,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Theme.of(context).primaryColor,
  //             foregroundColor: Colors.white,
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //             elevation: 0,
  //           ),
  //           child: Text(
  //             currentStep == 1 ? 'i18n_guide_我知道了'.tr : 'i18n_guide_继续'.tr,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  /// 构建带有可点击区域的图片组件
  Widget _buildImageWithClickableArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取屏幕宽度，留出一些边距
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth - 48; // 24px padding * 2
        
        // 计算合适的图片尺寸，保持合适的比例，确保最小尺寸
        final imageWidth = (maxWidth > 360 ? 360.0 : maxWidth).clamp(280.0, 360.0);
        final imageHeight = imageWidth * 1.2; // 保持原有比例 (300/360 ≈ 0.833)
        
        final position = _clickPositions[currentStep];
        
        return Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // 背景图片
                SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.asset(
                    currentStep == 0 ? 'assets/jiaocheng1.png' : 'assets/jiaocheng2.png',
                    fit: BoxFit.fill, // 使用fill确保填满整个容器
                  ),
                ),
                // 可点击的区域指示器
                _buildIndicator(imageWidth, imageHeight, position),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建指示器组件
  Widget _buildIndicator(double imageWidth, double imageHeight, Map<String, dynamic> position) {
    // 计算指示器尺寸，根据图片大小调整
    final indicatorSize = (imageWidth * 0.167).clamp(50.0, 70.0); // 动态调整指示器大小
    final centerIconSize = (indicatorSize * 0.5).clamp(30.0, 40.0);
    
    return Positioned(
      left: imageWidth * position['x'] - indicatorSize / 2,
      top: imageHeight * position['y'] - indicatorSize / 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('点击了指示器！当前步骤: $currentStep');
            _onTargetTap();
          },
          borderRadius: BorderRadius.circular(indicatorSize / 2),
          child: AnimatedBuilder(
            animation: _lottieController,
            builder: (context, child) {
              return Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 脉冲波纹效果
                    for (int i = 0; i < 3; i++)
                      Transform.scale(
                        scale: 1.0 + ((_lottieController.value + i * 0.3) % 1.0) * 0.8,
                        child: Container(
                          width: indicatorSize,
                          height: indicatorSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(
                                0.55 - ((_lottieController.value + i * 0.3) % 1.0) * 0.5,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    // 中心按钮
                    Container(
                      width: centerIconSize,
                      height: centerIconSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: currentStep == 0 ? Icon(
                         Icons.touch_app,
                        color: Colors.white.withOpacity(0.9),
                        size: centerIconSize * 0.5,
                      ) : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onTargetTap() {
    print('_onTargetTap called, currentStep: $currentStep');
    if (currentStep == 0) {
      setState(() {
        currentStep = 1;
        print('setState called, new currentStep: $currentStep');
      });
    } else {
      print('调用 _onCompleted');
      _onCompleted();
    }
  }

  void _onCompleted() {
    // 标记引导已完成
    GetStorage().write('tutorial_completed', true);
    widget.onCompleted?.call();
  }



}
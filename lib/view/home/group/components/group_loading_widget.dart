import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/group_constants.dart';

/// 分组页面加载状态组件
class GroupLoadingWidget extends StatelessWidget {
  const GroupLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GroupConstants.cardRadius),
        boxShadow: [GroupConstants.cardShadow],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                GroupConstants.primaryGradientStart,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'i18n_group_加载中'.tr,
              style: const TextStyle(
                color: GroupConstants.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                GroupConstants.primaryGradientStart,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(
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
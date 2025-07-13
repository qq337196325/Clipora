import 'package:flutter/material.dart';
import 'package:get/get.dart';


/// 分组页面空状态组件
class GroupEmptyWidget extends StatelessWidget {
  const GroupEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 56,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 12),
            Text(
              'i18n_group_暂无分类'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'i18n_group_点击右上角添加按钮创建第一个分类'.tr,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/group_constants.dart';

/// 分组页面空状态组件
class GroupEmptyWidget extends StatelessWidget {
  const GroupEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 56,
              color: GroupConstants.lightHint,
            ),
            const SizedBox(height: 12),
            Text(
              'i18n_group_暂无分类'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: GroupConstants.hintText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'i18n_group_点击右上角添加按钮创建第一个分类'.tr,
              style: const TextStyle(
                fontSize: 13,
                color: GroupConstants.lightHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
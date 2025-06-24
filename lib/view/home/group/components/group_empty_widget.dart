import 'package:flutter/material.dart';
import '../utils/group_constants.dart';

/// 分组页面空状态组件
class GroupEmptyWidget extends StatelessWidget {
  const GroupEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 56,
              color: GroupConstants.lightHint,
            ),
            SizedBox(height: 12),
            Text(
              "暂无分类",
              style: TextStyle(
                fontSize: 16,
                color: GroupConstants.hintText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "点击右上角添加按钮创建第一个分类",
              style: TextStyle(
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
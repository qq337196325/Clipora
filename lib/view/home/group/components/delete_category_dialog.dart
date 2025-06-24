import 'package:flutter/material.dart';
import '../../../../db/category/category_db.dart';
import '../utils/group_constants.dart';

/// 删除分类确认对话框
class DeleteCategoryDialog extends StatelessWidget {
  final CategoryDb category;
  final int articleCount;
  final VoidCallback onConfirm;

  const DeleteCategoryDialog({
    super.key,
    required this.category,
    required this.articleCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: GroupConstants.errorColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            '删除分类',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GroupConstants.itemText,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: GroupConstants.itemText,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: '确定要删除分类 '),
                TextSpan(
                  text: '「${category.name}」',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: GroupConstants.primaryGradientStart,
                  ),
                ),
                const TextSpan(text: ' 吗？'),
              ],
            ),
          ),
          if (articleCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFD591),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFA8C16),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '删除后目录下的 $articleCount 篇文章将移到未分类',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFD48806),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: GroupConstants.hintText,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            '取消',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GroupConstants.errorColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            '删除',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
} 
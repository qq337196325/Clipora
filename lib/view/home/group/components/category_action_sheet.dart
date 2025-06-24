import 'package:flutter/material.dart';
import '../../../../db/category/category_db.dart';
import '../utils/group_constants.dart';

/// 分类操作底部面板组件
class CategoryActionSheet extends StatelessWidget {
  final CategoryDb category;
  final VoidCallback? onAddSubCategory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryActionSheet({
    super.key,
    required this.category,
    this.onAddSubCategory,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(GroupConstants.cardRadius),
          topRight: Radius.circular(GroupConstants.cardRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildCategoryHeader(),
                const SizedBox(height: 24),
                if (category.level < 1)
                  _buildActionButton(
                    icon: Icons.add_circle_outline,
                    title: '添加子分类',
                    subtitle: '在此分类下创建子分类',
                    color: GroupConstants.primaryGradientStart,
                    onTap: () {
                      Navigator.pop(context);
                      onAddSubCategory?.call();
                    },
                  ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  title: '重命名',
                  subtitle: '修改分类名称和图标',
                  color: GroupConstants.successColor,
                  onTap: () {
                    Navigator.pop(context);
                    onEdit?.call();
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  title: '删除',
                  subtitle: '删除此分类',
                  color: GroupConstants.errorColor,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: GroupConstants.dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GroupConstants.primaryGradientStart.withOpacity(0.1),
                GroupConstants.primaryGradientEnd.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              category.icon ?? '📁',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GroupConstants.itemText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.level == 0 ? '主分类' : '子分类',
                style: const TextStyle(
                  fontSize: 14,
                  color: GroupConstants.hintText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDestructive 
                    ? color.withOpacity(0.2) 
                    : const Color(0xfff0f0f0),
                width: 1,
              ),
              color: isDestructive 
                  ? color.withOpacity(0.05) 
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? color : GroupConstants.itemText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: GroupConstants.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: GroupConstants.lightHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
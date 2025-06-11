import 'package:flutter/material.dart';

class MyPageModal extends StatelessWidget {
  const MyPageModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('设置'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('跳转到设置页面')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to about page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('跳转到关于页面')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Handle logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('执行退出登录操作')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 
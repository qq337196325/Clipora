import 'package:flutter/material.dart';

class UpgradeDialog extends StatelessWidget {
  final String version;
  final String releaseNotes;
  final VoidCallback onUpgrade;
  final bool isForceUpgrade;

  const UpgradeDialog({
    super.key,
    required this.version,
    required this.releaseNotes,
    required this.onUpgrade,
    this.isForceUpgrade = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpgrade,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.system_update_alt_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text('发现新版本 v$version'),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('我们建议您升级到最新版本，以获得更好的体验。'),
              const SizedBox(height: 16),
              const Text('更新内容:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(releaseNotes),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: <Widget>[
          if (!isForceUpgrade)
            TextButton(
              child: const Text('稍后提醒'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          // 使用一个更有吸引力的按钮
          FilledButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text('立即更新'),
            onPressed: onUpgrade,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
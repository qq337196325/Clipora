// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            Text('i18n_upgrade_发现新版本'.trParams({'version': version})),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
               Text('i18n_upgrade_我们建议您升级到最新版本'.tr),
              const SizedBox(height: 16),
               Text('i18n_upgrade_更新内容'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(releaseNotes),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: <Widget>[
          if (!isForceUpgrade)
            TextButton(
              child: Text('i18n_upgrade_稍后提醒'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          // 使用一个更有吸引力的按钮
          FilledButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: Text('i18n_upgrade_立即更新'.tr),
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
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
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../utils/app_store_helper.dart';
import '../../../basics/logger.dart';

class RatingDialog extends StatelessWidget {
  const RatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部图标和标题
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.star_rate,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'i18n_my_评价一下我们的应用'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'i18n_my_您的评价是我们前进的动力描述'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // 星级选择
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _handleStarTap(context, index + 1);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rate,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            
            Text(
              'i18n_my_点击星星直接跳转到应用商店评价'.tr,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            
            // 按钮区域
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Text(
                      'i18n_my_稍后再说'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRateNow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'i18n_my_立即评价'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 平台提示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Platform.isIOS ? Icons.phone_iphone : Icons.android,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Platform.isIOS 
                        ? 'i18n_my_将跳转到AppStore进行评价'.tr
                        : 'i18n_my_将根据您的设备自动选择应用商店'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleStarTap(BuildContext context, int stars) async {
    getLogger().i('用户点击了$stars星评价');
    Navigator.pop(context);
    await _openAppStore(context);
  }
  
  void _handleRateNow(BuildContext context) async {
    Navigator.pop(context);
    await _openAppStore(context);
  }
  
  Future<void> _openAppStore(BuildContext context) async {
    try {
      await AppStoreHelper.openAppStoreRating();
    } catch (e) {
      getLogger().e('打开应用商店失败: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'i18n_my_暂时无法打开应用商店请稍后重试'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'i18n_my_确定'.tr,
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  /// 显示评价对话框
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const RatingDialog();
      },
    );
  }
} 
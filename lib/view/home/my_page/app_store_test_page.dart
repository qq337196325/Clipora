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
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../utils/app_store_helper.dart';


class AppStoreTestPage extends StatefulWidget {
  const AppStoreTestPage({super.key});

  @override
  State<AppStoreTestPage> createState() => _AppStoreTestPageState();
}

class _AppStoreTestPageState extends State<AppStoreTestPage> {
  String deviceInfo = '';
  List<String> testResults = [];

  @override
  void initState() {
    super.initState();
    deviceInfo = 'i18n_my_正在获取设备信息'.tr;
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      setState(() {
        deviceInfo = '''
${'i18n_my_设备品牌'.tr}: ${androidInfo.brand}
${'i18n_my_制造商'.tr}: ${androidInfo.manufacturer}
${'i18n_my_型号'.tr}: ${androidInfo.model}
${'i18n_my_Android版本'.tr}: ${androidInfo.version.release}
${'i18n_my_API级别'.tr}: ${androidInfo.version.sdkInt}
''';
      });
    } else if (Platform.isIOS) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final iosInfo = await deviceInfoPlugin.iosInfo;
      setState(() {
        deviceInfo = '''
${'i18n_my_设备型号'.tr}: ${iosInfo.model}
${'i18n_my_系统名称'.tr}: ${iosInfo.systemName}
${'i18n_my_系统版本'.tr}: ${iosInfo.systemVersion}
${'i18n_my_设备名称'.tr}: ${iosInfo.name}
''';
      });
    }
  }

  void _addTestResult(String result) {
    setState(() {
      testResults.insert(0, '${DateTime.now().toString().substring(11, 19)}: $result');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('i18n_my_应用商店测试页面标题'.tr),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 设备信息卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Platform.isIOS ? Icons.phone_iphone : Icons.android,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'i18n_my_设备信息'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  deviceInfo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // 测试按钮区域
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildTestButton(
                  'i18n_my_测试通用market协议'.tr,
                  Icons.store,
                  () => _testUniversalMarket(),
                ),
                const SizedBox(height: 12),
                _buildTestButton(
                  'i18n_my_测试完整应用商店流程'.tr,
                  Icons.star_rate,
                  () => _testCompleteFlow(),
                ),
                if (Platform.isAndroid) ...[
                  const SizedBox(height: 12),
                  _buildTestButton(
                    'i18n_my_测试GooglePlay'.tr,
                    Icons.play_arrow,
                    () => _testGooglePlay(),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 测试结果
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'i18n_my_测试日志'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleSmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: testResults.isEmpty
                        ? Center(
                            child: Text(
                              'i18n_my_点击上方按钮开始测试'.tr,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: testResults.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  testResults[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testUniversalMarket() async {
    _addTestResult('i18n_my_开始测试通用market协议'.tr);
    try {
      await AppStoreHelper.openAppStoreRating();
      _addTestResult('i18n_my_成功打开应用商店'.tr);
    } catch (e) {
      _addTestResult('i18n_my_失败'.trParams({'error': e.toString()}));
    }
  }

  Future<void> _testCompleteFlow() async {
    _addTestResult('i18n_my_开始测试完整应用商店流程'.tr);
    try {
      await AppStoreHelper.openAppStoreRating();
      _addTestResult('i18n_my_成功打开应用商店'.tr);
    } catch (e) {
      _addTestResult('i18n_my_失败'.trParams({'error': e.toString()}));
    }
  }

  Future<void> _testGooglePlay() async {
    _addTestResult('i18n_my_开始测试GooglePlay'.tr);
    try {
      // 直接测试Google Play
      const packageName = 'com.guanshangyun.clipora';
      const playStoreUrl = 'market://details?id=$packageName';
      
      final uri = Uri.parse(playStoreUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      _addTestResult('i18n_my_成功打开GooglePlay'.tr);
    } catch (e) {
      _addTestResult('i18n_my_GooglePlay失败'.trParams({'error': e.toString()}));
    }
  }
} 
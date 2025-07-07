import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../utils/app_store_helper.dart';


class AppStoreTestPage extends StatefulWidget {
  const AppStoreTestPage({super.key});

  @override
  State<AppStoreTestPage> createState() => _AppStoreTestPageState();
}

class _AppStoreTestPageState extends State<AppStoreTestPage> {
  String deviceInfo = '正在获取设备信息...';
  List<String> testResults = [];

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      setState(() {
        deviceInfo = '''
设备品牌: ${androidInfo.brand}
制造商: ${androidInfo.manufacturer}
型号: ${androidInfo.model}
Android版本: ${androidInfo.version.release}
API级别: ${androidInfo.version.sdkInt}
''';
      });
    } else if (Platform.isIOS) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final iosInfo = await deviceInfoPlugin.iosInfo;
      setState(() {
        deviceInfo = '''
设备型号: ${iosInfo.model}
系统名称: ${iosInfo.systemName}
系统版本: ${iosInfo.systemVersion}
设备名称: ${iosInfo.name}
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
        title: const Text('应用商店测试'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 设备信息卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                      color: const Color(0xFF667eea),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '设备信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  deviceInfo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
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
                  '测试通用market://协议',
                  Icons.store,
                  () => _testUniversalMarket(),
                ),
                const SizedBox(height: 12),
                _buildTestButton(
                  '测试完整应用商店流程',
                  Icons.star_rate,
                  () => _testCompleteFlow(),
                ),
                if (Platform.isAndroid) ...[
                  const SizedBox(height: 12),
                  _buildTestButton(
                    '测试Google Play',
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
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: Color(0xFF667eea),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '测试日志',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: testResults.isEmpty
                        ? const Center(
                            child: Text(
                              '点击上方按钮开始测试',
                              style: TextStyle(
                                color: Color(0xFF999999),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF333333),
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
    _addTestResult('开始测试通用market://协议');
    try {
      await AppStoreHelper.openAppStoreRating();
      _addTestResult('✅ 成功打开应用商店');
    } catch (e) {
      _addTestResult('❌ 失败: $e');
    }
  }

  Future<void> _testCompleteFlow() async {
    _addTestResult('开始测试完整应用商店流程');
    try {
      await AppStoreHelper.openAppStoreRating();
      _addTestResult('✅ 成功打开应用商店');
    } catch (e) {
      _addTestResult('❌ 失败: $e');
    }
  }

  Future<void> _testGooglePlay() async {
    _addTestResult('开始测试Google Play');
    try {
      // 直接测试Google Play
      const packageName = 'com.guanshangyun.clipora';
      const playStoreUrl = 'market://details?id=$packageName';
      
      final uri = Uri.parse(playStoreUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      _addTestResult('✅ 成功打开Google Play');
    } catch (e) {
      _addTestResult('❌ Google Play失败: $e');
    }
  }
} 
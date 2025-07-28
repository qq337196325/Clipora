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
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import 'api_services_interface.dart';


// 字体大小范围
const double kMinFontSize = 12.0;
const double kMaxFontSize = 24.0;
const double kDefaultFontSize = 16.0;
const double kFontSizeStep = 2.0;

class UiColour {
  // 中性色
  static Color neutral_11 = const Color(0xFFFFFFFF);
  static Color neutral_10 = const Color(0xFFF5F5F5);
  static Color neutral_9 = const Color(0xFFF0F0F0);
  static Color neutral_8 = const Color(0xFFD9D9D9);
  static Color neutral_7 = const Color(0xFFBFBFBF);
  static Color neutral_6 = const Color(0xFF8C8C8C);
  static Color neutral_5 = const Color(0xFF595959);
  static Color neutral_4 = const Color(0xFF434343);
  static Color neutral_3 = const Color(0xFF262626);
  static Color neutral_2 = const Color(0xFF1F1F1F);
  static Color neutral_1 = const Color(0xFF141414);
  static Color neutral_0 = const Color(0xFF000000);


  static Color primary = const Color(0xFF2196F3);
  static Color secondary = const Color(0xFFFF9800);
  static Color background = const Color(0xFFF8F9FA);
  static Color text = const Color(0xFF212121);



  static Color funFF6600 = const Color(0xFFFF6600);

}
final globalBoxStorage = GetStorage();

String getUuid(){
  return Uuid().v4();
}

// 获取服务端当前时间戳
Future<int> getServiceCurrentTime() async {
  final apiServices = Get.find<IApiServices>();
  final res = await apiServices.getCurrentTime();
  if (res['code'] != 0) {
    return 0;
  }

  return res['data'];
}

// 获取存储的服务端时间
int getStorageServiceCurrentTime(){
  int serviceCurrentTime = globalBoxStorage.read('serviceCurrentTime') ?? 0;
  return serviceCurrentTime;
}

// 服务端时间加10秒，表示数据要同步到服务端
int getStorageServiceCurrentTimeAdding(){
  final serverTime = getStorageServiceCurrentTime();
  final localTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final serverLocalDiff = localTime - serverTime;

  return serverTime + (serverLocalDiff > 0 ? serverLocalDiff : 0) + 10;
}

// 获取自动解析设置状态
bool getAutoParseEnabled() {
  return globalBoxStorage.read('auto_parse_enabled') ?? true; // 默认开启
}

// 设置自动解析状态
void setAutoParseEnabled(bool enabled) {
  globalBoxStorage.write('auto_parse_enabled', enabled);
}


/// 跳转链接
Future<void> goLaunchUrl(Uri _url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

/// 构建带进度的数据同步对话框
Widget buildSyncDialogWithProgress(
  BuildContext context,
  String message,
  double progress,
) {
  return Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部图标和动画
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00BCF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: progress >= 1.0
                  ? Icon(
                      Icons.check_circle,
                      color: const Color(0xFF00BCF6),
                      size: 40,
                    )
                  : LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color(0xFF00BCF6),
                      size: 40,
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // 标题
          Text(
            progress >= 1.0 ? '同步完成' : '数据同步中',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
            ),
          ),

          const SizedBox(height: 12),

          // 动态消息文本
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // 进度条
          if (progress > 0.0 && progress < 1.0) ...[
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (320 - 48) * progress, // 考虑padding
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCF6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 提示信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00BCF6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  progress >= 1.0 ? Icons.check_circle_outline : Icons.info_outline_rounded,
                  size: 20,
                  color: const Color(0xFF00BCF6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    progress >= 1.0 
                        ? '数据同步已完成，享受您的使用体验！'
                        : '新设备正在同步数据，请保持网络连接',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF007AFF),
                      fontWeight: FontWeight.w500,
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
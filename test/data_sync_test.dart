import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clipora/view/data_sync/data_sync_page.dart';

void main() {
  group('DataSyncPage Tests', () {
    testWidgets('DataSyncPage should build without errors', (WidgetTester tester) async {
      // 设置测试窗口大小
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const DataSyncPage(),
        ),
      );

      // 验证页面标题
      expect(find.text('数据同步'), findsOneWidget);
      
      // 验证基本UI元素
      expect(find.text('信令服务器连接'), findsOneWidget);
      expect(find.text('房间管理'), findsOneWidget);
      expect(find.text('WebRTC连接'), findsOneWidget);
      expect(find.text('同步操作'), findsOneWidget);
      expect(find.text('同步日志'), findsOneWidget);
    });

    testWidgets('Basic UI elements should be present', (WidgetTester tester) async {
      // 设置测试窗口大小
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const DataSyncPage(),
        ),
      );

      // 验证按钮文本
      expect(find.text('连接信令服务器'), findsOneWidget);
      expect(find.text('加入房间'), findsOneWidget);
      expect(find.text('离开房间'), findsOneWidget);
      expect(find.text('建立WebRTC连接'), findsOneWidget);
      expect(find.text('发送测试'), findsOneWidget);
      expect(find.text('发送文件'), findsOneWidget);
    });

    testWidgets('Status indicators should be present', (WidgetTester tester) async {
      // 设置测试窗口大小
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const DataSyncPage(),
        ),
      );

      // 验证状态指示器
      expect(find.textContaining('信令服务器:'), findsOneWidget);
      expect(find.textContaining('WebRTC连接:'), findsOneWidget);
      expect(find.textContaining('用户ID:'), findsAtLeastNWidgets(1));
    });
  });
}
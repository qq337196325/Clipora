import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


/// 构建数据同步对话框
Widget buildSyncDialog() {
  return StatefulBuilder(
    builder: (context, setDialogState) {
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
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: const Color(0xFF00BCF6),
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 标题
              Text(
                '数据同步中',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),

              const SizedBox(height: 12),

              // 动态消息文本
              Text(
                "正在同步...",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8E8E93),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

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
                      Icons.info_outline_rounded,
                      size: 20,
                      color: const Color(0xFF00BCF6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '新设备正在同步数据，请保持网络连接',
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
    },
  );
}
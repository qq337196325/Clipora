import 'package:flutter/services.dart';
import 'dart:io';

void main() async {
  try {
    print('🧪 开始测试资源文件读取...');
    
    // 测试读取 marked.js
    try {
      final String markedJs = await rootBundle.loadString('assets/js/marked.min.js');
      print('✅ marked.js 读取成功，大小: ${markedJs.length} 字符');
      print('📄 marked.js 开头: ${markedJs.substring(0, 100)}...');
    } catch (e) {
      print('❌ marked.js 读取失败: $e');
    }
    
    // 测试读取 highlight.js
    try {
      final String highlightJs = await rootBundle.loadString('assets/js/highlight.min.js');
      print('✅ highlight.js 读取成功，大小: ${highlightJs.length} 字符');
      print('📄 highlight.js 开头: ${highlightJs.substring(0, 100)}...');
    } catch (e) {
      print('❌ highlight.js 读取失败: $e');
    }
    
    // 测试读取 CSS 文件
    try {
      final String css = await rootBundle.loadString('assets/js/github.min.css');
      print('✅ github.min.css 读取成功，大小: ${css.length} 字符');
      print('📄 CSS 开头: ${css.substring(0, 100)}...');
    } catch (e) {
      print('❌ github.min.css 读取失败: $e');
    }
    
    print('🎉 资源文件测试完成');
    
  } catch (e) {
    print('💥 测试过程出错: $e');
  }
  
  exit(0);
} 
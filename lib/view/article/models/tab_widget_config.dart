import 'package:flutter/material.dart';

/// 标签页Widget配置
class TabWidgetConfig {
  final String tabName;
  final Widget widget;
  final bool shouldKeepAlive;
  final EdgeInsetsGeometry padding;
  
  const TabWidgetConfig({
    required this.tabName,
    required this.widget,
    this.shouldKeepAlive = true,
    this.padding = EdgeInsets.zero,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TabWidgetConfig &&
      other.tabName == tabName &&
      other.shouldKeepAlive == shouldKeepAlive &&
      other.padding == padding;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      tabName,
      shouldKeepAlive,
      padding,
    );
  }
  
  @override
  String toString() {
    return 'TabWidgetConfig('
      'tabName: $tabName, '
      'shouldKeepAlive: $shouldKeepAlive, '
      'padding: $padding'
    ')';
  }
}
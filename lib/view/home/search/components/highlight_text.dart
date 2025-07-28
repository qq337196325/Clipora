// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';

/// 高亮文本组件
/// 
/// 用于在文本中高亮显示搜索关键词
class HighlightText extends StatelessWidget {
  final String text;
  final String searchQuery;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightText({
    super.key,
    required this.text,
    required this.searchQuery,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final List<TextSpan> spans = _buildHighlightedSpans();
    
    return RichText(
      text: TextSpan(
        children: spans,
        style: style ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  List<TextSpan> _buildHighlightedSpans() {
    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    
    int currentIndex = 0;
    
    while (currentIndex < text.length) {
      final int matchIndex = lowerText.indexOf(lowerQuery, currentIndex);
      
      if (matchIndex == -1) {
        // 没有更多匹配，添加剩余文本
        if (currentIndex < text.length) {
          spans.add(TextSpan(
            text: text.substring(currentIndex),
            // 普通文本不设置样式，使用默认样式
          ));
        }
        break;
      }
      
      // 添加匹配前的普通文本
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          // 普通文本不设置样式，使用默认样式
        ));
      }
      
      // 添加高亮的匹配文本
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + searchQuery.length),
        style: highlightStyle ?? _defaultHighlightStyle(),
      ));
      
      currentIndex = matchIndex + searchQuery.length;
    }
    
    return spans;
  }

  TextStyle _defaultHighlightStyle() {
    return const TextStyle(
      // backgroundColor: const Color(0xFFFFEB3B), // 黄色背景
      color: Color(0xFF1565C0), // 深蓝色文字
      fontWeight: FontWeight.w600,
    );
  }
}

/// 高亮文本构建器
/// 
/// 提供静态方法来快速构建高亮文本
class HighlightTextBuilder {
  /// 构建标题高亮文本
  static Widget buildTitle({
    required String text,
    required String searchQuery,
    TextStyle? baseStyle,
    required BuildContext context,
  }) {
    return HighlightText(
      text: text,
      searchQuery: searchQuery,
      style: baseStyle ?? TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
      highlightStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        // backgroundColor: const Color(0xFFFFEB3B).withOpacity(0.7),
        color: Theme.of(context).primaryColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建内容高亮文本
  static Widget buildContent({
    required String text,
    required String searchQuery,
    TextStyle? baseStyle,
    required BuildContext context,
  }) {
    return HighlightText(
      text: text,
      searchQuery: searchQuery,
      style: baseStyle ?? TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      highlightStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        // backgroundColor: const Color(0xFFFFEB3B).withOpacity(0.5),
        color: Theme.of(context).primaryColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 提取包含搜索词的内容片段
  static String extractRelevantContent({
    required String fullContent,
    required String searchQuery,
    int maxLength = 100,
    int contextLength = 30,
  }) {
    if (searchQuery.isEmpty || fullContent.isEmpty) {
      return fullContent.length > maxLength 
          ? '${fullContent.substring(0, maxLength)}...'
          : fullContent;
    }

    final String lowerContent = fullContent.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    
    final int matchIndex = lowerContent.indexOf(lowerQuery);
    
    if (matchIndex == -1) {
      // 没有匹配，返回开头部分
      return fullContent.length > maxLength 
          ? '${fullContent.substring(0, maxLength)}...'
          : fullContent;
    }

    // 计算摘取范围
    int startIndex = (matchIndex - contextLength).clamp(0, fullContent.length);
    int endIndex = (matchIndex + searchQuery.length + contextLength)
        .clamp(0, fullContent.length);

    // 调整到合适的长度
    if (endIndex - startIndex > maxLength) {
      endIndex = startIndex + maxLength;
    }

    String excerpt = fullContent.substring(startIndex, endIndex);
    
    // 添加省略号
    if (startIndex > 0) {
      excerpt = '...$excerpt';
    }
    if (endIndex < fullContent.length) {
      excerpt = '$excerpt...';
    }

    return excerpt;
  }
} 
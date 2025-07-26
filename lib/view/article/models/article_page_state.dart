import 'package:flutter/rendering.dart';

/// 文章页面状态数据模型
class ArticlePageState {
  final bool isInitialized;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<String> tabs;
  final int currentTabIndex;
  final bool isBottomBarVisible;
  final double lastScrollY;
  final ScrollDirection scrollDirection;
  
  const ArticlePageState({
    this.isInitialized = false,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.tabs = const [],
    this.currentTabIndex = 0,
    this.isBottomBarVisible = true,
    this.lastScrollY = 0.0,
    this.scrollDirection = ScrollDirection.idle,
  });
  
  ArticlePageState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<String>? tabs,
    int? currentTabIndex,
    bool? isBottomBarVisible,
    double? lastScrollY,
    ScrollDirection? scrollDirection,
  }) {
    return ArticlePageState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      tabs: tabs ?? this.tabs,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isBottomBarVisible: isBottomBarVisible ?? this.isBottomBarVisible,
      lastScrollY: lastScrollY ?? this.lastScrollY,
      scrollDirection: scrollDirection ?? this.scrollDirection,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ArticlePageState &&
      other.isInitialized == isInitialized &&
      other.isLoading == isLoading &&
      other.hasError == hasError &&
      other.errorMessage == errorMessage &&
      other.tabs.length == tabs.length &&
      other.currentTabIndex == currentTabIndex &&
      other.isBottomBarVisible == isBottomBarVisible &&
      other.lastScrollY == lastScrollY &&
      other.scrollDirection == scrollDirection;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      isInitialized,
      isLoading,
      hasError,
      errorMessage,
      tabs,
      currentTabIndex,
      isBottomBarVisible,
      lastScrollY,
      scrollDirection,
    );
  }
  
  @override
  String toString() {
    return 'ArticlePageState('
      'isInitialized: $isInitialized, '
      'isLoading: $isLoading, '
      'hasError: $hasError, '
      'errorMessage: $errorMessage, '
      'tabs: $tabs, '
      'currentTabIndex: $currentTabIndex, '
      'isBottomBarVisible: $isBottomBarVisible, '
      'lastScrollY: $lastScrollY, '
      'scrollDirection: $scrollDirection'
    ')';
  }
}
/// Tab页面状态模型
/// 用于描述单个Tab页面的详细状态信息
class TabPageState {
  /// Tab页面名称
  final String tabName;
  
  /// 是否为当前活跃的Tab
  final bool isActive;
  
  /// 是否正在加载中
  final bool isLoading;
  
  /// 是否有错误
  final bool hasError;
  
  /// 错误信息
  final String errorMessage;
  
  /// 内容是否准备就绪
  final bool isContentReady;
  
  /// 是否应该触发操作
  final bool shouldTriggerAction;
  
  /// 最后更新时间
  final DateTime lastUpdated;
  
  TabPageState({
    required this.tabName,
    this.isActive = false,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.isContentReady = false,
    this.shouldTriggerAction = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
  
  /// 创建副本并更新指定字段
  TabPageState copyWith({
    String? tabName,
    bool? isActive,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isContentReady,
    bool? shouldTriggerAction,
    DateTime? lastUpdated,
  }) {
    return TabPageState(
      tabName: tabName ?? this.tabName,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isContentReady: isContentReady ?? this.isContentReady,
      shouldTriggerAction: shouldTriggerAction ?? this.shouldTriggerAction,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
  
  /// 检查Tab是否处于忙碌状态
  bool get isBusy => isLoading || shouldTriggerAction;
  
  /// 检查Tab是否可以执行操作
  bool get canPerformAction => !isBusy && !hasError;
  
  /// 获取Tab的状态描述
  String get statusDescription {
    if (hasError) return '错误: $errorMessage';
    if (isLoading) return '加载中...';
    if (shouldTriggerAction) return '准备执行操作...';
    if (isContentReady) return '内容已准备就绪';
    return '空闲';
  }
  
  /// 获取Tab的状态类型
  TabStateType get stateType {
    if (hasError) return TabStateType.error;
    if (isLoading) return TabStateType.loading;
    if (shouldTriggerAction) return TabStateType.triggering;
    if (isContentReady) return TabStateType.ready;
    return TabStateType.idle;
  }
  
  @override
  String toString() {
    return 'TabPageState('
        'tabName: $tabName, '
        'isActive: $isActive, '
        'isLoading: $isLoading, '
        'hasError: $hasError, '
        'errorMessage: $errorMessage, '
        'isContentReady: $isContentReady, '
        'shouldTriggerAction: $shouldTriggerAction, '
        'lastUpdated: $lastUpdated'
        ')';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TabPageState &&
        other.tabName == tabName &&
        other.isActive == isActive &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.isContentReady == isContentReady &&
        other.shouldTriggerAction == shouldTriggerAction;
  }
  
  @override
  int get hashCode {
    return tabName.hashCode ^
        isActive.hashCode ^
        isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        isContentReady.hashCode ^
        shouldTriggerAction.hashCode;
  }
  
  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'tabName': tabName,
      'isActive': isActive,
      'isLoading': isLoading,
      'hasError': hasError,
      'errorMessage': errorMessage,
      'isContentReady': isContentReady,
      'shouldTriggerAction': shouldTriggerAction,
      'lastUpdated': lastUpdated.toIso8601String(),
      'statusDescription': statusDescription,
      'stateType': stateType.toString(),
      'isBusy': isBusy,
      'canPerformAction': canPerformAction,
    };
  }
  
  /// 从Map创建TabPageState
  factory TabPageState.fromMap(Map<String, dynamic> map) {
    return TabPageState(
      tabName: map['tabName'] ?? '',
      isActive: map['isActive'] ?? false,
      isLoading: map['isLoading'] ?? false,
      hasError: map['hasError'] ?? false,
      errorMessage: map['errorMessage'] ?? '',
      isContentReady: map['isContentReady'] ?? false,
      shouldTriggerAction: map['shouldTriggerAction'] ?? false,
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated']) 
          : DateTime.now(),
    );
  }
}

/// Tab状态类型枚举
enum TabStateType {
  /// 空闲状态
  idle,
  
  /// 加载中状态
  loading,
  
  /// 准备触发操作状态
  triggering,
  
  /// 内容准备就绪状态
  ready,
  
  /// 错误状态
  error,
}

/// Tab状态类型扩展
extension TabStateTypeExtension on TabStateType {
  /// 获取状态类型的显示名称
  String get displayName {
    switch (this) {
      case TabStateType.idle:
        return '空闲';
      case TabStateType.loading:
        return '加载中';
      case TabStateType.triggering:
        return '准备执行';
      case TabStateType.ready:
        return '就绪';
      case TabStateType.error:
        return '错误';
    }
  }
  
  /// 获取状态类型的图标
  String get icon {
    switch (this) {
      case TabStateType.idle:
        return '⏸️';
      case TabStateType.loading:
        return '⏳';
      case TabStateType.triggering:
        return '🔄';
      case TabStateType.ready:
        return '✅';
      case TabStateType.error:
        return '❌';
    }
  }
  
  /// 检查是否为活跃状态（正在进行某种操作）
  bool get isActive {
    return this == TabStateType.loading || this == TabStateType.triggering;
  }
  
  /// 检查是否为终止状态（操作已完成或出错）
  bool get isTerminal {
    return this == TabStateType.ready || this == TabStateType.error;
  }
}
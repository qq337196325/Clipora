import '../exceptions/article_state_exception.dart';

/// 错误状态模型
/// 用于描述错误的详细信息和状态
class ErrorState {
  /// 异常对象
  final ArticleStateException? exception;
  
  /// 发生错误的操作
  final String operation;
  
  /// 是否可以重试
  final bool canRetry;
  
  /// 错误上下文信息
  final Map<String, dynamic> context;
  
  /// 错误发生时间
  final DateTime timestamp;
  
  /// 错误严重程度
  final ErrorSeverity severity;
  
  /// 是否已被用户确认
  final bool isAcknowledged;
  
  ErrorState({
    this.exception,
    this.operation = '',
    this.canRetry = true,
    this.context = const {},
    DateTime? timestamp,
    this.severity = ErrorSeverity.medium,
    this.isAcknowledged = false,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 创建副本并更新指定字段
  ErrorState copyWith({
    ArticleStateException? exception,
    String? operation,
    bool? canRetry,
    Map<String, dynamic>? context,
    DateTime? timestamp,
    ErrorSeverity? severity,
    bool? isAcknowledged,
  }) {
    return ErrorState(
      exception: exception ?? this.exception,
      operation: operation ?? this.operation,
      canRetry: canRetry ?? this.canRetry,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }
  
  /// 检查是否有错误
  bool get hasError => exception != null;
  
  /// 获取错误消息
  String get errorMessage => exception?.message ?? '';
  
  /// 获取错误代码
  String get errorCode => exception?.code ?? '';
  
  /// 获取原始错误
  dynamic get originalError => exception?.originalError;
  
  /// 获取堆栈跟踪
  StackTrace? get stackTrace => exception?.stackTrace;
  
  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    if (!hasError) return '';
    
    // 根据异常类型返回用户友好的消息
    if (exception is ArticleInitializationException) {
      return _getInitializationErrorMessage();
    } else if (exception is ArticleTabException) {
      return _getTabErrorMessage();
    } else if (exception is ArticleScrollException) {
      return _getScrollErrorMessage();
    } else if (exception is ArticleUIException) {
      return _getUIErrorMessage();
    } else {
      return _getGenericErrorMessage();
    }
  }
  
  /// 获取初始化错误消息
  String _getInitializationErrorMessage() {
    if (errorMessage.contains('网络')) {
      return '网络连接异常，请检查网络后重试';
    } else if (errorMessage.contains('数据')) {
      return '数据加载失败，请稍后重试';
    } else if (errorMessage.contains('权限')) {
      return '权限不足，请检查应用权限设置';
    } else {
      return '页面初始化失败，请重新打开页面';
    }
  }
  
  /// 获取标签页错误消息
  String _getTabErrorMessage() {
    if (errorMessage.contains('WebView')) {
      return '网页加载失败，请检查网络连接';
    } else if (errorMessage.contains('快照')) {
      return '快照生成失败，请稍后重试';
    } else if (errorMessage.contains('Markdown')) {
      return '内容解析失败，请刷新页面';
    } else {
      return '标签页加载异常，请重新加载';
    }
  }
  
  /// 获取滚动错误消息
  String _getScrollErrorMessage() {
    return '页面滚动出现问题，请刷新页面';
  }
  
  /// 获取UI错误消息
  String _getUIErrorMessage() {
    return '界面显示异常，请重新加载页面';
  }
  
  /// 获取通用错误消息
  String _getGenericErrorMessage() {
    if (errorMessage.contains('超时')) {
      return '操作超时，请检查网络连接后重试';
    } else if (errorMessage.contains('内存')) {
      return '内存不足，请关闭其他应用后重试';
    } else if (errorMessage.contains('存储')) {
      return '存储空间不足，请清理设备存储';
    } else {
      return '操作失败，请稍后重试';
    }
  }
  
  /// 获取错误类型描述
  String get errorTypeDescription {
    if (!hasError) return '无错误';
    
    final type = exception.runtimeType.toString();
    switch (type) {
      case 'ArticleInitializationException':
        return '初始化错误';
      case 'ArticleTabException':
        return '标签页错误';
      case 'ArticleScrollException':
        return '滚动错误';
      case 'ArticleUIException':
        return 'UI错误';
      default:
        return '未知错误';
    }
  }
  
  /// 获取建议的解决方案
  List<String> get suggestedSolutions {
    if (!hasError) return [];
    
    final solutions = <String>[];
    
    // 根据错误类型提供解决方案
    if (exception is ArticleInitializationException) {
      solutions.addAll([
        '检查网络连接',
        '重新打开页面',
        '清理应用缓存',
        '重启应用',
      ]);
    } else if (exception is ArticleTabException) {
      solutions.addAll([
        '刷新当前标签页',
        '切换到其他标签页',
        '检查网络连接',
        '重新加载页面',
      ]);
    } else if (exception is ArticleScrollException) {
      solutions.addAll([
        '刷新页面',
        '重新打开文章',
        '清理应用缓存',
      ]);
    } else if (exception is ArticleUIException) {
      solutions.addAll([
        '刷新页面',
        '重启应用',
        '检查设备内存',
      ]);
    } else {
      solutions.addAll([
        '稍后重试',
        '检查网络连接',
        '重启应用',
      ]);
    }
    
    // 根据错误消息添加特定解决方案
    if (errorMessage.contains('网络')) {
      solutions.insert(0, '检查网络连接');
    }
    if (errorMessage.contains('内存')) {
      solutions.insert(0, '关闭其他应用释放内存');
    }
    if (errorMessage.contains('存储')) {
      solutions.insert(0, '清理设备存储空间');
    }
    
    return solutions.toSet().toList(); // 去重
  }
  
  /// 检查错误是否为临时性错误
  bool get isTemporary {
    if (!hasError) return false;
    
    return errorMessage.contains('网络') ||
           errorMessage.contains('超时') ||
           errorMessage.contains('连接') ||
           errorMessage.contains('服务器');
  }
  
  /// 检查错误是否为严重错误
  bool get isCritical {
    return severity == ErrorSeverity.high ||
           errorMessage.contains('崩溃') ||
           errorMessage.contains('内存') ||
           errorMessage.contains('权限');
  }
  
  /// 获取错误的显示颜色
  String get displayColor {
    switch (severity) {
      case ErrorSeverity.low:
        return '#FFA726'; // 橙色
      case ErrorSeverity.medium:
        return '#FF7043'; // 深橙色
      case ErrorSeverity.high:
        return '#F44336'; // 红色
    }
  }
  
  /// 获取错误的显示图标
  String get displayIcon {
    switch (severity) {
      case ErrorSeverity.low:
        return '⚠️';
      case ErrorSeverity.medium:
        return '❗';
      case ErrorSeverity.high:
        return '🚨';
    }
  }
  
  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'hasError': hasError,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'operation': operation,
      'canRetry': canRetry,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.toString(),
      'isAcknowledged': isAcknowledged,
      'userFriendlyMessage': userFriendlyMessage,
      'errorTypeDescription': errorTypeDescription,
      'suggestedSolutions': suggestedSolutions,
      'isTemporary': isTemporary,
      'isCritical': isCritical,
      'displayColor': displayColor,
      'displayIcon': displayIcon,
    };
  }
  
  /// 从Map创建ErrorState
  factory ErrorState.fromMap(Map<String, dynamic> map) {
    return ErrorState(
      operation: map['operation'] ?? '',
      canRetry: map['canRetry'] ?? true,
      context: Map<String, dynamic>.from(map['context'] ?? {}),
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.toString() == map['severity'],
        orElse: () => ErrorSeverity.medium,
      ),
      isAcknowledged: map['isAcknowledged'] ?? false,
    );
  }
  
  @override
  String toString() {
    return 'ErrorState('
        'hasError: $hasError, '
        'operation: $operation, '
        'errorMessage: $errorMessage, '
        'canRetry: $canRetry, '
        'severity: $severity, '
        'timestamp: $timestamp'
        ')';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ErrorState &&
        other.operation == operation &&
        other.errorMessage == errorMessage &&
        other.canRetry == canRetry &&
        other.severity == severity &&
        other.isAcknowledged == isAcknowledged;
  }
  
  @override
  int get hashCode {
    return operation.hashCode ^
        errorMessage.hashCode ^
        canRetry.hashCode ^
        severity.hashCode ^
        isAcknowledged.hashCode;
  }
}

/// 错误严重程度枚举
enum ErrorSeverity {
  /// 低严重程度 - 不影响核心功能
  low,
  
  /// 中等严重程度 - 影响部分功能
  medium,
  
  /// 高严重程度 - 影响核心功能或导致崩溃
  high,
}

/// 错误严重程度扩展
extension ErrorSeverityExtension on ErrorSeverity {
  /// 获取严重程度的显示名称
  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return '轻微';
      case ErrorSeverity.medium:
        return '中等';
      case ErrorSeverity.high:
        return '严重';
    }
  }
  
  /// 获取严重程度的数值
  int get value {
    switch (this) {
      case ErrorSeverity.low:
        return 1;
      case ErrorSeverity.medium:
        return 2;
      case ErrorSeverity.high:
        return 3;
    }
  }
  
  /// 检查是否需要立即处理
  bool get requiresImmediateAction {
    return this == ErrorSeverity.high;
  }
  
  /// 检查是否可以延迟处理
  bool get canBeDeferred {
    return this == ErrorSeverity.low;
  }
}
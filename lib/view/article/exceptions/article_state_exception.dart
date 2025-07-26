/// 文章状态管理异常类
class ArticleStateException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const ArticleStateException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer('ArticleStateException: $message');
    
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    
    if (originalError != null) {
      buffer.write('\nOriginal Error: $originalError');
    }
    
    if (stackTrace != null) {
      buffer.write('\nStack Trace: $stackTrace');
    }
    
    return buffer.toString();
  }
}

/// 文章初始化异常
class ArticleInitializationException extends ArticleStateException {
  const ArticleInitializationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// 文章滚动状态异常
class ArticleScrollException extends ArticleStateException {
  const ArticleScrollException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// 文章标签页异常
class ArticleTabException extends ArticleStateException {
  const ArticleTabException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// 文章UI状态异常
class ArticleUIException extends ArticleStateException {
  const ArticleUIException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
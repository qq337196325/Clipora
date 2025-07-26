import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/error_state.dart';
import '../controllers/article_error_controller.dart';

/// 错误显示组件
/// 用于显示用户友好的错误信息和提供重试选项
class ErrorDisplayWidget extends StatelessWidget {
  final ErrorState errorState;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;
  final bool showSolutions;
  
  const ErrorDisplayWidget({
    super.key,
    required this.errorState,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
    this.showSolutions = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!errorState.hasError) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildMessage(),
          if (showDetails && errorState.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetails(),
          ],
          if (showSolutions && errorState.suggestedSolutions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSolutions(),
          ],
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }
  
  /// 构建头部
  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          errorState.displayIcon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            errorState.errorTypeDescription,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (onDismiss != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            iconSize: 20,
          ),
      ],
    );
  }
  
  /// 构建错误消息
  Widget _buildMessage() {
    return Text(
      errorState.userFriendlyMessage,
      style: const TextStyle(
        fontSize: 16,
        height: 1.4,
      ),
    );
  }
  
  /// 构建详细信息
  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '详细信息:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            errorState.errorMessage,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          if (errorState.operation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '操作: ${errorState.operation}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 构建解决方案
  Widget _buildSolutions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '建议解决方案:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...errorState.suggestedSolutions.take(3).map((solution) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    solution,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建操作按钮
  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (errorState.canRetry && onRetry != null) ...[
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: TextButton.styleFrom(
              foregroundColor: _getAccentColor(),
            ),
          ),
          const SizedBox(width: 8),
        ],
        TextButton(
          onPressed: onDismiss ?? () {},
          child: const Text('知道了'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  /// 获取背景颜色
  Color _getBackgroundColor() {
    switch (errorState.severity) {
      case ErrorSeverity.low:
        return Colors.orange.withOpacity(0.1);
      case ErrorSeverity.medium:
        return Colors.deepOrange.withOpacity(0.1);
      case ErrorSeverity.high:
        return Colors.red.withOpacity(0.1);
    }
  }
  
  /// 获取边框颜色
  Color _getBorderColor() {
    switch (errorState.severity) {
      case ErrorSeverity.low:
        return Colors.orange.withOpacity(0.3);
      case ErrorSeverity.medium:
        return Colors.deepOrange.withOpacity(0.3);
      case ErrorSeverity.high:
        return Colors.red.withOpacity(0.3);
    }
  }
  
  /// 获取强调色
  Color _getAccentColor() {
    switch (errorState.severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.deepOrange;
      case ErrorSeverity.high:
        return Colors.red;
    }
  }
}

/// 错误提示条组件
/// 用于在页面顶部显示简洁的错误提示
class ErrorSnackBar extends StatelessWidget {
  final ErrorState errorState;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  
  const ErrorSnackBar({
    super.key,
    required this.errorState,
    this.onRetry,
    this.onDismiss,
  });
  
  /// 显示错误提示条
  static void show(
    ErrorState errorState, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    if (!errorState.hasError) return;
    
    Get.showSnackbar(
      GetSnackBar(
        message: errorState.userFriendlyMessage,
        icon: Text(
          errorState.displayIcon,
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: _getSnackBarColor(errorState.severity),
        duration: Duration(
          seconds: errorState.severity == ErrorSeverity.high ? 10 : 5,
        ),
        mainButton: errorState.canRetry && onRetry != null
            ? TextButton(
                onPressed: () {
                  Get.back();
                  onRetry?.call();
                },
                child: const Text(
                  '重试',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
        onTap: onDismiss != null ? (_) => onDismiss!() : null,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
  
  /// 获取提示条颜色
  static Color _getSnackBarColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.deepOrange;
      case ErrorSeverity.high:
        return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 这个组件主要用于静态方法
  }
}

/// 错误对话框组件
/// 用于显示详细的错误信息和多个操作选项
class ErrorDialog extends StatelessWidget {
  final ErrorState errorState;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final List<Widget>? additionalActions;
  
  const ErrorDialog({
    super.key,
    required this.errorState,
    this.onRetry,
    this.onCancel,
    this.additionalActions,
  });
  
  /// 显示错误对话框
  static Future<void> show(
    ErrorState errorState, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
    List<Widget>? additionalActions,
  }) async {
    if (!errorState.hasError) return;
    
    await Get.dialog(
      ErrorDialog(
        errorState: errorState,
        onRetry: onRetry,
        onCancel: onCancel,
        additionalActions: additionalActions,
      ),
      barrierDismissible: !errorState.isCritical,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(errorState.displayIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorState.errorTypeDescription,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorState.userFriendlyMessage,
              style: const TextStyle(fontSize: 16),
            ),
            if (errorState.suggestedSolutions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '建议解决方案:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...errorState.suggestedSolutions.map((solution) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(solution)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (additionalActions != null) ...additionalActions!,
        if (errorState.canRetry && onRetry != null)
          TextButton.icon(
            onPressed: () {
              Get.back();
              onRetry?.call();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        TextButton(
          onPressed: () {
            Get.back();
            onCancel?.call();
          },
          child: const Text('取消'),
        ),
      ],
    );
  }
}
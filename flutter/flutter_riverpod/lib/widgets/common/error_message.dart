import 'package:flutter/material.dart';

/// 错误消息显示组件
///
/// 以一致的方式显示错误信息，可选择是否显示重试按钮
///
/// 示例:
/// ```dart
/// ErrorMessage(
///   message: '加载失败',
///   onRetry: _loadData,
/// )
/// ```
class ErrorMessage extends StatelessWidget {
  /// 错误消息文本
  final String message;
  
  /// 重试回调函数，如果为null则不显示重试按钮
  final VoidCallback? onRetry;
  
  /// 错误图标，默认为error_outline
  final IconData icon;
  
  /// 图标颜色，默认为红色
  final Color iconColor;
  
  /// 图标大小
  final double iconSize;
  
  /// 错误消息文字样式
  final TextStyle? messageStyle;
  
  /// 重试按钮文本
  final String retryText;
  
  /// 重试按钮样式
  final ButtonStyle? retryButtonStyle;
  
  /// 容器内边距
  final EdgeInsetsGeometry padding;

  /// 创建一个错误消息组件
  const ErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = 32.0,
    this.messageStyle,
    this.retryText = '重试',
    this.retryButtonStyle,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveMessageStyle = messageStyle ?? TextStyle(
      color: Theme.of(context).colorScheme.error,
      fontSize: 14.0,
    );
    
    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: effectiveMessageStyle,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onRetry,
              style: retryButtonStyle ?? ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(retryText),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 创建一个内嵌在卡片中的错误消息
  factory ErrorMessage.card({
    Key? key,
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.red,
    double iconSize = 32.0,
    TextStyle? messageStyle,
    String retryText = '重试',
    ButtonStyle? retryButtonStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    Color? backgroundColor,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  }) {
    return _CardErrorMessage(
      key: key,
      message: message,
      onRetry: onRetry,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      messageStyle: messageStyle,
      retryText: retryText,
      retryButtonStyle: retryButtonStyle,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    );
  }
  
  /// 创建一个小型内联错误消息
  factory ErrorMessage.inline({
    Key? key,
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.red,
    double iconSize = 14.0,
    TextStyle? messageStyle,
    String retryText = '重试',
  }) {
    return _InlineErrorMessage(
      key: key,
      message: message,
      onRetry: onRetry,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      messageStyle: messageStyle,
      retryText: retryText,
    );
  }
}

/// 卡片式错误消息
class _CardErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final TextStyle? messageStyle;
  final String retryText;
  final ButtonStyle? retryButtonStyle;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  const _CardErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    this.messageStyle,
    required this.retryText,
    this.retryButtonStyle,
    required this.padding,
    this.backgroundColor,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? 
        Theme.of(context).colorScheme.error.withOpacity(0.1);
    
    return Card(
      margin: EdgeInsets.zero,
      color: effectiveBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: ErrorMessage(
        message: message,
        onRetry: onRetry,
        icon: icon,
        iconColor: iconColor,
        iconSize: iconSize,
        messageStyle: messageStyle,
        retryText: retryText,
        retryButtonStyle: retryButtonStyle,
        padding: padding,
      ),
    );
  }
}

/// 内联错误消息
class _InlineErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final TextStyle? messageStyle;
  final String retryText;

  const _InlineErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    this.messageStyle,
    required this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveMessageStyle = messageStyle ?? TextStyle(
      color: Theme.of(context).colorScheme.error,
      fontSize: 12.0,
    );
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            message,
            style: effectiveMessageStyle,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: 8.0),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              retryText,
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      ],
    );
  }
} 
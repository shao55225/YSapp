import 'package:flutter/material.dart';

/// 带有加载状态的按钮组件
/// 
/// 当 [isLoading] 为 true 时，显示一个进度指示器
/// 当 [isLoading] 为 false 时，显示正常的按钮
/// 
/// 示例:
/// ```dart
/// LoadingButton(
///   isLoading: _isSubmitting,
///   onPressed: _submitForm,
///   child: Text('提交'),
/// )
/// ```
class LoadingButton extends StatelessWidget {
  /// 是否处于加载状态
  final bool isLoading;

  /// 按钮点击回调
  final VoidCallback? onPressed;

  /// 按钮子组件，通常是一个Text组件
  final Widget child;

  /// 加载指示器颜色，默认为白色
  final Color? loadingColor;

  /// 按钮样式
  final ButtonStyle? style;
  
  /// 进度指示器大小
  final double progressSize;
  
  /// 进度指示器线条宽度
  final double progressStrokeWidth;
  
  /// 按钮类型，默认为填充样式
  final LoadingButtonType buttonType;

  /// 创建一个加载状态按钮
  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.loadingColor,
    this.style,
    this.progressSize = 20.0,
    this.progressStrokeWidth = 2.0,
    this.buttonType = LoadingButtonType.elevated,
  }) : super(key: key);
  
  /// 创建一个文本加载按钮
  factory LoadingButton.text({
    Key? key,
    required bool isLoading,
    required VoidCallback? onPressed,
    required Widget child,
    Color? loadingColor,
    ButtonStyle? style,
    double progressSize = 16.0,
    double progressStrokeWidth = 2.0,
  }) {
    return LoadingButton(
      key: key,
      isLoading: isLoading,
      onPressed: onPressed,
      child: child,
      loadingColor: loadingColor,
      style: style,
      progressSize: progressSize,
      progressStrokeWidth: progressStrokeWidth,
      buttonType: LoadingButtonType.text,
    );
  }
  
  /// 创建一个轮廓加载按钮
  factory LoadingButton.outlined({
    Key? key,
    required bool isLoading,
    required VoidCallback? onPressed,
    required Widget child,
    Color? loadingColor,
    ButtonStyle? style,
    double progressSize = 20.0,
    double progressStrokeWidth = 2.0,
  }) {
    return LoadingButton(
      key: key,
      isLoading: isLoading,
      onPressed: onPressed,
      child: child,
      loadingColor: loadingColor,
      style: style,
      progressSize: progressSize,
      progressStrokeWidth: progressStrokeWidth,
      buttonType: LoadingButtonType.outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确定加载指示器的颜色
    final effectiveLoadingColor = loadingColor ?? _getDefaultLoadingColor(context);
    
    // 构建进度指示器
    final loadingIndicator = SizedBox(
      width: progressSize,
      height: progressSize,
      child: CircularProgressIndicator(
        strokeWidth: progressStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveLoadingColor),
      ),
    );
    
    // 根据按钮类型返回不同的按钮组件
    switch (buttonType) {
      case LoadingButtonType.elevated:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: isLoading ? loadingIndicator : child,
        );
        
      case LoadingButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: isLoading ? loadingIndicator : child,
        );
        
      case LoadingButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: isLoading ? loadingIndicator : child,
        );
    }
  }
  
  // 获取默认的加载指示器颜色
  Color _getDefaultLoadingColor(BuildContext context) {
    switch (buttonType) {
      case LoadingButtonType.elevated:
        return Colors.white;
        
      case LoadingButtonType.outlined:
      case LoadingButtonType.text:
        return Theme.of(context).primaryColor;
    }
  }
}

/// 加载按钮类型枚举
enum LoadingButtonType {
  /// 填充样式按钮 (ElevatedButton)
  elevated,
  
  /// 轮廓样式按钮 (OutlinedButton)
  outlined,
  
  /// 文本样式按钮 (TextButton)
  text,
} 
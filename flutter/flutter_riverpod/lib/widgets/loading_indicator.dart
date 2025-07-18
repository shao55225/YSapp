import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 加载指示器组件
class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                message!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}

/// 全屏加载指示器
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color indicatorColor;
  final bool dismissible;
  final VoidCallback? onDismiss;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.backgroundColor,
    this.indicatorColor = AppColors.primary,
    this.dismissible = false,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: Stack(
        children: [
          LoadingIndicator(
            message: message,
            color: indicatorColor,
            textStyle: const TextStyle(color: Colors.white),
          ),
          if (dismissible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss ?? () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}

/// 列表底部加载指示器
class ListBottomLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasMoreData;
  final String loadingText;
  final String noMoreDataText;

  const ListBottomLoader({
    Key? key,
    required this.isLoading,
    required this.hasMoreData,
    this.loadingText = '正在加载更多...',
    this.noMoreDataText = '没有更多数据了',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              loadingText,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    } else if (!hasMoreData) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          noMoreDataText,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return const SizedBox(height: 0);
    }
  }
}

/// 骨架屏加载指示器
class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
} 
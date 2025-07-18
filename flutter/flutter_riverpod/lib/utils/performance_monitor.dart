import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 性能监控工具类，用于在调试模式下显示性能指标
class PerformanceMonitor {
  /// 单例实例
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();

  /// 是否启用性能监控
  bool _isEnabled = false;

  /// 私有构造函数
  PerformanceMonitor._internal();

  /// 获取单例实例
  factory PerformanceMonitor() => _instance;

  /// 启用性能监控
  void enable() {
    _isEnabled = true;
  }

  /// 禁用性能监控
  void disable() {
    _isEnabled = false;
  }

  /// 是否启用
  bool get isEnabled => _isEnabled && kDebugMode;

  /// 创建性能监控覆盖层
  Widget createPerformanceOverlay(Widget child) {
    if (!isEnabled) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: _buildPerformanceToggle(),
        ),
        if (_isEnabled)
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: 150,
            child: Opacity(
              opacity: 0.7,
              child: PerformanceOverlay.allEnabled(),
            ),
          ),
      ],
    );
  }

  /// 构建性能监控切换按钮
  Widget _buildPerformanceToggle() {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _isEnabled = !_isEnabled;
            // 可以在这里加入震动反馈
            HapticFeedback.mediumImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black.withOpacity(0.5),
            child: const Icon(
              Icons.speed,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }

  /// 记录组件构建性能
  static void logBuildPerformance(String widgetName, Function() buildFunction) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      final result = buildFunction();
      stopwatch.stop();
      print('$widgetName 构建用时: ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } else {
      return buildFunction();
    }
  }

  /// 检测组件树深度，警告过深的嵌套
  static void checkWidgetDepth(BuildContext context, String widgetName) {
    if (kDebugMode) {
      int depth = 0;
      BuildContext? currentContext = context;
      
      while (currentContext != null && depth < 100) {
        depth++;
        currentContext = currentContext.findAncestorRenderObjectOfType<RenderObject>()?.owner?.buildOwner?.focusManager?.rootScope?.context;
      }
      
      if (depth > 20) {
        print('警告: $widgetName 组件树深度为 $depth 层，可能影响性能');
      }
    }
  }
} 
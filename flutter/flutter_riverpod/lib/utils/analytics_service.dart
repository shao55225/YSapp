import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../api/services/api_service.dart';

/// 分析服务提供者
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AnalyticsService(apiService: apiService);
});

/// 事件类型枚举
enum EventType {
  pageView,      // 页面访问
  videoPlay,     // 视频播放
  videoComplete, // 视频播放完成
  search,        // 搜索
  click,         // 点击
  purchase,      // 购买
  register,      // 注册
  login,         // 登录
  share,         // 分享
  custom,        // 自定义事件
}

/// 分析服务类
class AnalyticsService {
  final ApiService apiService;
  
  // 设备信息
  String? _deviceId;
  String? _deviceModel;
  String? _osVersion;
  String? _appVersion;
  
  // 事件队列
  final List<Map<String, dynamic>> _eventQueue = [];
  Timer? _flushTimer;
  
  // 是否初始化完成
  bool _initialized = false;
  
  AnalyticsService({required this.apiService}) {
    _initDeviceInfo();
    _startFlushTimer();
  }
  
  /// 初始化设备信息
  Future<void> _initDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      _appVersion = packageInfo.version;
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        _deviceModel = androidInfo.model;
        _osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
        _deviceModel = iosInfo.model;
        _osVersion = iosInfo.systemVersion;
      }
      
      _initialized = true;
    } catch (e) {
      debugPrint('初始化设备信息失败: $e');
    }
  }
  
  /// 启动定时刷新事件队列的定时器
  void _startFlushTimer() {
    _flushTimer = Timer.periodic(Duration(seconds: 30), (_) {
      flushEvents();
    });
  }
  
  /// 跟踪事件
  Future<void> trackEvent(
    EventType eventType, 
    String eventName, {
    Map<String, dynamic>? params,
  }) async {
    if (!_initialized) {
      await _initDeviceInfo();
    }
    
    final event = {
      'eventType': eventType.toString().split('.').last,
      'eventName': eventName,
      'params': params ?? {},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'deviceInfo': {
        'deviceId': _deviceId,
        'deviceModel': _deviceModel,
        'osVersion': _osVersion,
        'appVersion': _appVersion,
        'platform': Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other'),
      }
    };
    
    _eventQueue.add(event);
    
    // 如果队列长度超过10，立即刷新
    if (_eventQueue.length >= 10) {
      flushEvents();
    }
  }
  
  /// 跟踪页面访问
  Future<void> trackPageView(String pageName, {Map<String, dynamic>? params}) async {
    await trackEvent(
      EventType.pageView, 
      'page_view', 
      params: {'page': pageName, ...?params},
    );
  }
  
  /// 跟踪视频播放
  Future<void> trackVideoPlay(
    String videoId, 
    String videoName, {
    String? category,
    int? duration,
    Map<String, dynamic>? params,
  }) async {
    await trackEvent(
      EventType.videoPlay, 
      'video_play', 
      params: {
        'videoId': videoId,
        'videoName': videoName,
        if (category != null) 'category': category,
        if (duration != null) 'duration': duration,
        ...?params,
      },
    );
  }
  
  /// 跟踪视频播放完成
  Future<void> trackVideoComplete(
    String videoId, 
    String videoName, {
    int? watchedDuration,
    Map<String, dynamic>? params,
  }) async {
    await trackEvent(
      EventType.videoComplete, 
      'video_complete', 
      params: {
        'videoId': videoId,
        'videoName': videoName,
        if (watchedDuration != null) 'watchedDuration': watchedDuration,
        ...?params,
      },
    );
  }
  
  /// 跟踪搜索
  Future<void> trackSearch(String keyword, {Map<String, dynamic>? params}) async {
    await trackEvent(
      EventType.search, 
      'search', 
      params: {'keyword': keyword, ...?params},
    );
  }
  
  /// 跟踪点击
  Future<void> trackClick(String target, {Map<String, dynamic>? params}) async {
    await trackEvent(
      EventType.click, 
      'click', 
      params: {'target': target, ...?params},
    );
  }
  
  /// 跟踪购买
  Future<void> trackPurchase(
    String productId, 
    String productName, 
    double price, {
    String? currency = 'CNY',
    Map<String, dynamic>? params,
  }) async {
    await trackEvent(
      EventType.purchase, 
      'purchase', 
      params: {
        'productId': productId,
        'productName': productName,
        'price': price,
        'currency': currency,
        ...?params,
      },
    );
  }
  
  /// 跟踪注册
  Future<void> trackRegister(String method, {Map<String, dynamic>? params}) async {
    await trackEvent(
      EventType.register, 
      'register', 
      params: {'method': method, ...?params},
    );
  }
  
  /// 跟踪登录
  Future<void> trackLogin(String method, {Map<String, dynamic>? params}) async {
    await trackEvent(
      EventType.login, 
      'login', 
      params: {'method': method, ...?params},
    );
  }
  
  /// 跟踪分享
  Future<void> trackShare(String content, String platform, {Map<String, dynamic>? params}) async {
    await trackEvent(
      EventType.share, 
      'share', 
      params: {'content': content, 'platform': platform, ...?params},
    );
  }
  
  /// 跟踪自定义事件
  Future<void> trackCustomEvent(String eventName, {Map<String, dynamic>? params}) async {
    await trackEvent(EventType.custom, eventName, params: params);
  }
  
  /// 刷新事件队列，将事件发送到服务器
  Future<void> flushEvents() async {
    if (_eventQueue.isEmpty) {
      return;
    }
    
    // 复制队列并清空原队列
    final events = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();
    
    try {
      await apiService.post('/openapi/analytics/track', data: {
        'events': events,
      });
    } catch (e) {
      // 发送失败，将事件放回队列
      _eventQueue.addAll(events);
      debugPrint('发送事件失败: $e');
    }
  }
  
  /// 销毁服务
  void dispose() {
    _flushTimer?.cancel();
    flushEvents();
  }
}

/// 分析服务扩展
extension AnalyticsServiceExtension on WidgetRef {
  /// 获取分析服务
  AnalyticsService get analytics => read(analyticsServiceProvider);
} 
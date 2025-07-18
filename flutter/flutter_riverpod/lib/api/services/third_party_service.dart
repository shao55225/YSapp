import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interceptors/logging_interceptor.dart';
import '../../constants/api_constants.dart';

// 第三方站点服务提供者
final thirdPartyServiceProvider = Provider<ThirdPartyService>((ref) {
  final dio = Dio();
  dio.interceptors.add(LoggingInterceptor());
  return ThirdPartyService(dio);
});

class ThirdPartyService {
  final Dio _dio;
  List<String> _cachedUrls = [];
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 15);

  ThirdPartyService(this._dio);

  /// 获取可用的第三方站点URL列表
  Future<List<String>> getAvailableUrls() async {
    // 如果缓存有效且不为空，直接返回缓存数据
    if (_isCacheValid() && _cachedUrls.isNotEmpty) {
      return _cachedUrls;
    }

    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.thirdPartySites}',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _cachedUrls = data.map((site) => site['url'].toString()).toList();
        _lastFetchTime = DateTime.now();
        return _cachedUrls;
      }
    } catch (e) {
      // 如果API请求失败，但缓存不为空，使用缓存数据
      if (_cachedUrls.isNotEmpty) {
        return _cachedUrls;
      }
      
      // 如果API请求失败且没有缓存，使用硬编码的备用URL
      _cachedUrls = _getFallbackUrls();
      return _cachedUrls;
    }

    // 如果API请求成功但返回空列表，使用硬编码的备用URL
    if (_cachedUrls.isEmpty) {
      _cachedUrls = _getFallbackUrls();
    }

    return _cachedUrls;
  }

  /// 获取下一个可用的URL
  Future<String?> getNextUrl(String currentUrl) async {
    // 获取所有可用URL
    final urls = await getAvailableUrls();
    
    if (urls.isEmpty) {
      return null;
    }
    
    // 找到当前URL的索引
    final currentIndex = urls.indexOf(currentUrl);
    
    // 如果当前URL不在列表中，返回第一个URL
    if (currentIndex == -1) {
      return urls.first;
    }
    
    // 如果当前URL是最后一个，返回第一个URL
    if (currentIndex == urls.length - 1) {
      return urls.first;
    }
    
    // 否则返回下一个URL
    return urls[currentIndex + 1];
  }

  /// 检查URL是否可访问
  Future<bool> checkUrlHealth(String url) async {
    try {
      // 使用API检查URL健康状态
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCheck}',
        data: {'url': url},
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] == true;
      }
      
      // 如果API不可用，则直接尝试访问
      return _directCheckUrl(url);
    } catch (e) {
      // 如果API调用失败，直接尝试访问URL
      return _directCheckUrl(url);
    }
  }
  
  /// 直接尝试访问URL以检查其是否可用
  Future<bool> _directCheckUrl(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }

  /// 检查缓存是否有效
  bool _isCacheValid() {
    if (_lastFetchTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    return now.difference(_lastFetchTime!) < cacheDuration;
  }

  /// 获取硬编码的备用URL
  List<String> _getFallbackUrls() {
    // 这些是备用URL，当API无法访问时使用
    return [
      'https://example.com/site1',
      'https://example.com/site2',
      'https://example.com/site3',
    ];
  }
} 
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// API缓存工具类
/// 用于缓存API响应数据，减少网络请求
class ApiCache {
  /// 缓存数据
  /// [key] 缓存的键名
  /// [data] 要缓存的数据
  /// [expiry] 缓存过期时间，如不设置则永不过期
  static Future<void> saveData(String key, dynamic data, {Duration? expiry}) async {
    final prefs = await SharedPreferences.getInstance();
    
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds ?? 0,
    };
    
    await prefs.setString(key, jsonEncode(cacheData));
  }

  /// 获取缓存数据
  /// [key] 缓存的键名
  /// 如果缓存不存在或已过期，返回null
  static Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString == null) {
      return null;
    }
    
    try {
      final cacheData = jsonDecode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      
      // 检查是否过期
      if (expiry > 0) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiry) {
          // 缓存已过期，删除并返回null
          await prefs.remove(key);
          return null;
        }
      }
      
      return cacheData['data'];
    } catch (e) {
      // 解析错误，删除缓存并返回null
      await prefs.remove(key);
      return null;
    }
  }
  
  /// 删除缓存数据
  /// [key] 缓存的键名
  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  
  /// 清除所有缓存数据
  /// [prefix] 如果提供，只清除以该前缀开头的缓存
  static Future<void> clearCache({String? prefix}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefix == null) {
      // 清除所有缓存
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('api_cache_')) {
          await prefs.remove(key);
        }
      }
    } else {
      // 清除指定前缀的缓存
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('api_cache_$prefix')) {
          await prefs.remove(key);
        }
      }
    }
  }
  
  /// 获取缓存数据，如果不存在则通过回调函数获取并缓存
  /// [key] 缓存的键名
  /// [fetchData] 获取数据的回调函数
  /// [expiry] 缓存过期时间
  static Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetchData, {
    Duration? expiry,
  }) async {
    // 尝试从缓存获取数据
    final cachedData = await getData(key);
    
    if (cachedData != null) {
      return cachedData as T;
    }
    
    // 缓存不存在或已过期，通过回调函数获取新数据
    final newData = await fetchData();
    
    // 缓存新数据
    await saveData(key, newData, expiry: expiry);
    
    return newData;
  }
  
  /// 检查缓存是否存在且未过期
  /// [key] 缓存的键名
  static Future<bool> exists(String key) async {
    final data = await getData(key);
    return data != null;
  }
  
  /// 获取缓存的剩余有效时间
  /// [key] 缓存的键名
  /// 如果缓存不存在或已过期，返回Duration.zero
  /// 如果缓存永不过期，返回null
  static Future<Duration?> getRemainingTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString == null) {
      return Duration.zero;
    }
    
    try {
      final cacheData = jsonDecode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      
      if (expiry == 0) {
        // 永不过期
        return null;
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final remaining = expiry - (now - timestamp);
      
      if (remaining <= 0) {
        // 已过期
        await prefs.remove(key);
        return Duration.zero;
      }
      
      return Duration(milliseconds: remaining);
    } catch (e) {
      // 解析错误
      await prefs.remove(key);
      return Duration.zero;
    }
  }
  
  /// 生成缓存键
  /// 用于生成标准格式的缓存键名
  /// [baseKey] 基础键名
  /// [params] 可选参数，用于区分不同参数的相同API请求
  static String generateKey(String baseKey, [Map<String, dynamic>? params]) {
    if (params == null || params.isEmpty) {
      return 'api_cache_$baseKey';
    }
    
    // 对参数排序，确保相同参数但顺序不同的请求生成相同的键
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    // 将参数转换为字符串
    final paramsString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return 'api_cache_${baseKey}_$paramsString';
  }
} 
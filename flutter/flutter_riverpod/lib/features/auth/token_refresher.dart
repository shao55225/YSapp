import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token刷新器
/// 
/// 负责管理JWT令牌的刷新流程，确保API调用始终使用有效的认证令牌
class TokenRefresher {
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  /// 安全存储器，用于存储令牌
  final FlutterSecureStorage _secureStorage;
  
  /// Dio HTTP客户端，用于发送刷新请求
  final Dio _dio;

  /// 刷新令牌锁，防止多个刷新请求同时发生
  final _refreshTokenLock = Completer<void>();
  bool _isRefreshing = false;

  /// 构造函数
  TokenRefresher({
    FlutterSecureStorage? secureStorage,
    Dio? dio,
  }) : 
    _secureStorage = secureStorage ?? const FlutterSecureStorage(),
    _dio = dio ?? Dio(BaseOptions(
      baseUrl: 'https://api.example.com', // 更改为实际的API基础URL
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ));

  /// 获取认证令牌
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// 保存令牌
  Future<void> saveTokens({
    required String authToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch.toString();
    
    await _secureStorage.write(key: _authTokenKey, value: authToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _tokenExpiryKey, value: expiryTime);
  }

  /// 清除令牌（登出时使用）
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }

  /// 检查令牌是否即将过期
  /// 
  /// 如果令牌将在5分钟内过期，返回true
  Future<bool> isTokenAboutToExpire() async {
    final expiryTimeStr = await _secureStorage.read(key: _tokenExpiryKey);
    if (expiryTimeStr == null) return true;
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryTimeStr));
    final now = DateTime.now();
    
    // 如果令牌将在5分钟内过期
    return expiryTime.difference(now).inMinutes < 5;
  }

  /// 判断是否需要刷新令牌
  Future<bool> needsRefresh() async {
    final hasToken = await getAuthToken() != null;
    final aboutToExpire = await isTokenAboutToExpire();
    
    return hasToken && aboutToExpire;
  }

  /// 刷新令牌
  Future<String?> refreshToken() async {
    // 如果已经在刷新，等待刷新完成
    if (_isRefreshing) {
      await _refreshTokenLock.future;
      return await getAuthToken();
    }

    // 准备开始刷新
    _isRefreshing = true;
    final completer = Completer<void>();
    _refreshTokenLock.complete(completer.future);

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: '刷新令牌不存在',
          type: DioExceptionType.badResponse,
        );
      }

      // 发送刷新令牌请求
      final response = await _dio.post('/openapi/member/refresh_token', data: {
        'refresh_token': refreshToken,
      });

      // 处理响应
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        await saveTokens(
          authToken: data['token'],
          refreshToken: data['refresh_token'],
          expiresIn: data['expires_in'],
        );
        completer.complete();
        _isRefreshing = false;
        return data['token'];
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: response.data['message'] ?? '令牌刷新失败',
          type: DioExceptionType.badResponse,
          response: response,
        );
      }
    } catch (e) {
      completer.completeError(e);
      _isRefreshing = false;
      
      // 令牌刷新失败，清除所有令牌
      await clearTokens();
      
      if (kDebugMode) {
        print('令牌刷新失败: $e');
      }
      rethrow;
    }
  }

  /// 自动刷新令牌
  /// 
  /// 检查令牌是否需要刷新，如果需要则刷新令牌
  Future<String?> ensureValidToken() async {
    if (await needsRefresh()) {
      return await refreshToken();
    }
    return await getAuthToken();
  }
} 
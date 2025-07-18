import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 获取存储的token
    final token = await _secureStorage.read(key: 'auth_token');
    
    if (token != null) {
      // 添加Authorization头
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // 继续请求
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理401错误（未授权）
    if (err.response?.statusCode == 401) {
      // 这里可以添加token刷新逻辑
      // 如果刷新失败，可以清除token并导航到登录页面
      
      // 清除token
      await _secureStorage.delete(key: 'auth_token');
      
      // 发送通知，让应用跳转到登录页面
      // 这里可以使用事件总线或其他方式通知应用
    }
    
    // 继续错误处理
    handler.next(err);
  }
} 
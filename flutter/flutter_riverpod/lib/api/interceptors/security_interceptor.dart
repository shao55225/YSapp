import 'package:dio/dio.dart';
import '../../core/security/certificate_pinning.dart';
import '../../features/auth/token_refresher.dart';

/// API安全拦截器
/// 
/// 提供令牌自动刷新和证书绑定功能
class SecurityInterceptor extends Interceptor {
  /// Token刷新器
  final TokenRefresher _tokenRefresher;
  
  /// 证书绑定管理器
  final CertificatePinningManager _certificatePinningManager;
  
  /// 构造函数
  SecurityInterceptor({
    TokenRefresher? tokenRefresher,
    CertificatePinningManager? certificatePinningManager,
  }) : 
    _tokenRefresher = tokenRefresher ?? TokenRefresher(),
    _certificatePinningManager = certificatePinningManager ?? CertificatePinningManager();
  
  /// 配置Dio客户端
  void configureDio(Dio dio) {
    // 添加证书绑定
    _certificatePinningManager.configureDio(dio);
    
    // 添加拦截器
    dio.interceptors.add(this);
  }
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 确保使用有效的token
      final token = await _tokenRefresher.ensureValidToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果是401错误（未授权），尝试刷新token
    if (err.response?.statusCode == 401) {
      try {
        // 获取原始请求
        final options = err.requestOptions;
        
        // 尝试刷新令牌
        final newToken = await _tokenRefresher.refreshToken();
        
        // 如果成功获取新令牌，重试请求
        if (newToken != null) {
          // 更新请求头中的令牌
          options.headers['Authorization'] = 'Bearer $newToken';
          
          // 使用dio发送请求
          final dio = Dio();
          _certificatePinningManager.configureDio(dio);
          
          // 创建新请求
          final response = await dio.request(
            options.path,
            data: options.data,
            queryParameters: options.queryParameters,
            options: Options(
              method: options.method,
              headers: options.headers,
              responseType: options.responseType,
            ),
          );
          
          // 返回响应
          return handler.resolve(response);
        }
      } catch (e) {
        // 令牌刷新失败，继续抛出原始错误
      }
    }
    
    // 处理其他错误
    return handler.next(err);
  }
} 
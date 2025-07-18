import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../api/interceptors/auth_interceptor.dart';
import '../api/interceptors/logging_interceptor.dart';

/// HTTP客户端工具类，封装Dio网络请求
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  late Dio _dio;

  /// 单例模式
  factory HttpClient() => _instance;

  /// 私有构造函数
  HttpClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
  }

  /// 获取Dio实例
  Dio get dio => _dio;

  /// GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 错误处理
  Exception _handleError(DioException error) {
    String errorMessage = "未知错误";
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = "连接超时";
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = "请求超时";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "响应超时";
        break;
      case DioExceptionType.badResponse:
        if (error.response != null) {
          final int? statusCode = error.response?.statusCode;
          final dynamic data = error.response?.data;
          
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          } else {
            switch (statusCode) {
              case 400:
                errorMessage = "请求参数错误";
                break;
              case 401:
                errorMessage = "未授权，请重新登录";
                break;
              case 403:
                errorMessage = "拒绝访问";
                break;
              case 404:
                errorMessage = "请求地址出错";
                break;
              case 408:
                errorMessage = "请求超时";
                break;
              case 500:
                errorMessage = "服务器内部错误";
                break;
              case 501:
                errorMessage = "服务未实现";
                break;
              case 502:
                errorMessage = "网关错误";
                break;
              case 503:
                errorMessage = "服务不可用";
                break;
              case 504:
                errorMessage = "网关超时";
                break;
              case 505:
                errorMessage = "HTTP版本不支持";
                break;
              default:
                errorMessage = "网络请求错误，状态码: $statusCode";
            }
          }
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "请求取消";
        break;
      case DioExceptionType.connectionError:
        errorMessage = "连接错误，请检查网络";
        break;
      case DioExceptionType.badCertificate:
        errorMessage = "证书验证失败";
        break;
      case DioExceptionType.unknown:
        errorMessage = "未知错误";
        break;
    }
    
    return Exception(errorMessage);
  }
} 
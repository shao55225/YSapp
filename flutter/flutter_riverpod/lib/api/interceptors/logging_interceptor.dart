import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method;
    final uri = options.uri;
    final data = options.data;
    final headers = options.headers;
    
    print('┌────── Request ──────');
    print('│ $method $uri');
    print('│ Headers: $headers');
    if (data != null) {
      print('│ Body: $data');
    }
    print('└────────────────────');
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode;
    final uri = response.requestOptions.uri;
    final data = response.data;
    
    print('┌────── Response ──────');
    print('│ $statusCode $uri');
    print('│ Data: $data');
    print('└─────────────────────');
    
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final uri = err.requestOptions.uri;
    final message = err.message;
    final data = err.response?.data;
    
    print('┌────── Error ──────');
    print('│ $statusCode $uri');
    print('│ $message');
    if (data != null) {
      print('│ Data: $data');
    }
    print('└───────────────────');
    
    handler.next(err);
  }
} 
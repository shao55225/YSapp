import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import '../../api/services/api_service.dart';
import '../../features/auth/token_refresher.dart';
import '../../core/security/certificate_pinning.dart';
import '../../api/interceptors/security_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 生成模拟类
@GenerateMocks([Dio, FlutterSecureStorage])
void main() {
  late MockDio mockDio;
  late MockFlutterSecureStorage mockStorage;
  late ApiService apiService;
  late TokenRefresher tokenRefresher;
  late CertificatePinningManager certificatePinningManager;
  late SecurityInterceptor securityInterceptor;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockFlutterSecureStorage();
    
    // 配置TokenRefresher
    tokenRefresher = TokenRefresher(
      secureStorage: mockStorage,
      dio: mockDio,
    );
    
    // 配置证书绑定管理器
    certificatePinningManager = CertificatePinningManager();
    
    // 配置安全拦截器
    securityInterceptor = SecurityInterceptor(
      tokenRefresher: tokenRefresher,
      certificatePinningManager: certificatePinningManager,
    );
    
    // 创建ApiService实例
    apiService = ApiService('https://api.test.com');
  });

  group('ApiService 认证测试', () {
    test('登录成功应保存令牌', () async {
      // 模拟响应数据
      final responseData = {
        'code': 200,
        'message': '登录成功',
        'data': {
          'token': 'test_token_123',
          'userInfo': {
            'id': 1,
            'userName': 'testuser',
            'nickname': '测试用户',
          },
        },
      };
      
      // 模拟Dio响应
      when(mockDio.post(
        '/openapi/member/login',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/openapi/member/login'),
      ));
      
      // 模拟存储令牌
      when(mockStorage.write(
        key: 'auth_token',
        value: 'test_token_123',
      )).thenAnswer((_) async => {});
      
      // 执行登录
      final result = await apiService.login('testuser', 'password123');
      
      // 验证结果
      expect(result['token'], 'test_token_123');
      expect(result['userInfo']['userName'], 'testuser');
      
      // 验证是否保存了令牌
      verify(mockStorage.write(
        key: 'auth_token',
        value: 'test_token_123',
      )).called(1);
    });
    
    test('登录失败应抛出异常', () async {
      // 模拟响应数据
      final responseData = {
        'code': 400,
        'message': '用户名或密码错误',
        'data': null,
      };
      
      // 模拟Dio响应
      when(mockDio.post(
        '/openapi/member/login',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/openapi/member/login'),
      ));
      
      // 验证登录失败抛出异常
      expect(
        () => apiService.login('testuser', 'wrong_password'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', '用户名或密码错误')
            .having((e) => e.code, 'code', 400)),
      );
    });
  });

  group('令牌刷新测试', () {
    test('令牌过期时应自动刷新', () async {
      // 模拟当前令牌和刷新令牌
      when(mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'old_token');
      when(mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh_token');
      when(mockStorage.read(key: 'token_expiry'))
          .thenAnswer((_) async => (DateTime.now()
                  .subtract(const Duration(minutes: 5))
                  .millisecondsSinceEpoch)
              .toString());
      
      // 模拟刷新令牌响应
      final refreshResponseData = {
        'code': 200,
        'message': '刷新成功',
        'data': {
          'token': 'new_token_123',
          'refresh_token': 'new_refresh_token',
          'expires_in': 3600,
        },
      };
      
      // 模拟Dio刷新令牌响应
      when(mockDio.post(
        '/openapi/member/refresh_token',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: refreshResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/openapi/member/refresh_token'),
      ));
      
      // 模拟保存新令牌
      when(mockStorage.write(
        key: 'auth_token',
        value: 'new_token_123',
      )).thenAnswer((_) async => {});
      
      // 执行刷新令牌
      final newToken = await tokenRefresher.refreshToken();
      
      // 验证结果
      expect(newToken, 'new_token_123');
      
      // 验证是否保存了新令牌
      verify(mockStorage.write(
        key: 'auth_token',
        value: 'new_token_123',
      )).called(1);
    });
  });
} 
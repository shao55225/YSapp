import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_constants.dart';
import '../../config/app_config.dart';

// API服务提供者
final apiServiceProvider = Provider<ApiService>((ref) {
  final appConfig = ref.watch(appConfigProvider);
  return ApiService(appConfig.apiBaseUrl);
});

// API服务基类
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl;
  
  ApiService(this.baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // 添加请求拦截器，自动添加token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // 处理401错误，可能是token过期
          if (e.response?.statusCode == 401) {
            // 可以在这里处理token刷新逻辑
          }
          return handler.next(e);
        },
      ),
    );
    
    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
  
  // 通用GET请求
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // 通用POST请求
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // 通用PUT请求
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // 通用DELETE请求
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // 处理响应
  dynamic _handleResponse(Response response) {
    // 爱影CMS API的响应格式为 { code: 200, message: "操作成功", data: {...} }
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == 200) {
        return data['data'];
      } else {
        throw ApiException(data['message'] ?? '未知错误', data['code'] ?? -1);
      }
    } else {
      throw ApiException('服务器错误', response.statusCode ?? -1);
    }
  }
  
  // 处理错误
  dynamic _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw ApiException('连接超时', -2);
      case DioExceptionType.sendTimeout:
        throw ApiException('请求超时', -3);
      case DioExceptionType.receiveTimeout:
        throw ApiException('响应超时', -4);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? -1;
        final message = e.response?.data?['message'] ?? '服务器错误';
        throw ApiException(message, statusCode);
      case DioExceptionType.cancel:
        throw ApiException('请求被取消', -5);
      default:
        throw ApiException('网络错误，请检查网络连接', -6);
    }
  }
  
  // 保存token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  // 清除token
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
  
  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null;
  }
  
  // ========== 用户认证系统 ==========
  
  // 用户登录
  Future<Map<String, dynamic>> login(String userName, String password) async {
    final response = await post(ApiConstants.login, data: {
      'userName': userName,
      'password': password,
    });
    
    if (response != null && response['token'] != null) {
      await saveToken(response['token']);
    }
    
    return response;
  }
  
  // 用户注册
  Future<Map<String, dynamic>> register(String userName, String password, String confirmPassword, {String? inviteCode}) async {
    final Map<String, dynamic> data = {
      'userName': userName,
      'password': password,
      'confirmPassword': confirmPassword,
    };
    
    if (inviteCode != null && inviteCode.isNotEmpty) {
      data['inviteCode'] = inviteCode;
    }
    
    final response = await post(ApiConstants.register, data: data);
    
    if (response != null && response['token'] != null) {
      await saveToken(response['token']);
    }
    
    return response;
  }
  
  // 验证码登录
  Future<Map<String, dynamic>> verifyLogin(String userName, String code, int verifyType) async {
    final response = await post(ApiConstants.verifyLogin, data: {
      'userName': userName,
      'code': code,
      'verifyType': verifyType,
    });
    
    if (response != null && response['token'] != null) {
      await saveToken(response['token']);
    }
    
    return response;
  }
  
  // 验证码注册
  Future<Map<String, dynamic>> verifyRegister(String userName, String code, int verifyType, {String? inviteCode}) async {
    final Map<String, dynamic> data = {
      'userName': userName,
      'code': code,
      'verifyType': verifyType,
    };
    
    if (inviteCode != null && inviteCode.isNotEmpty) {
      data['inviteCode'] = inviteCode;
    }
    
    final response = await post(ApiConstants.verifyRegister, data: data);
    
    if (response != null && response['token'] != null) {
      await saveToken(response['token']);
    }
    
    return response;
  }
  
  // 游客注册
  Future<Map<String, dynamic>> touristsRegister() async {
    final response = await post(ApiConstants.touristsRegister);
    
    if (response != null && response['token'] != null) {
      await saveToken(response['token']);
    }
    
    return response;
  }
  
  // 获取图形验证码
  Future<Map<String, dynamic>> getCaptcha() async {
    return await get(ApiConstants.captcha);
  }
  
  // 发送短信验证码
  Future<void> sendSmsCode(String phone) async {
    await post(ApiConstants.sendSms, data: {
      'phone': phone,
    });
  }
  
  // 发送邮件验证码
  Future<void> sendEmailCode(String email) async {
    await post(ApiConstants.sendEmail, data: {
      'email': email,
    });
  }
  
  // 退出登录
  Future<void> logout() async {
    await post(ApiConstants.logout);
    await clearToken();
  }
  
  // ========== 会员系统 ==========
  
  // 获取会员信息
  Future<Map<String, dynamic>> getMemberInfo() async {
    return await get(ApiConstants.memberInfo);
  }
  
  // 编辑会员信息
  Future<void> editMember({String? headImg, String? nickname, int? sex}) async {
    final Map<String, dynamic> data = {};
    
    if (headImg != null) {
      data['headImg'] = headImg;
    }
    
    if (nickname != null) {
      data['nickname'] = nickname;
    }
    
    if (sex != null) {
      data['sex'] = sex;
    }
    
    await put(ApiConstants.editMember, data: data);
  }
  
  // 修改用户名
  Future<void> changeName(String userName) async {
    await put(ApiConstants.changeName, data: {
      'userName': userName,
    });
  }
  
  // 绑定手机号
  Future<void> bindPhone({required String phone, required String verifyCode}) async {
    await post(ApiConstants.bindPhone, data: {
      'phone': phone,
      'verifyCode': verifyCode,
    });
  }
  
  // 绑定邮箱
  Future<void> bindEmail({required String email, required String verifyCode}) async {
    await post(ApiConstants.bindEmail, data: {
      'email': email,
      'verifyCode': verifyCode,
    });
  }
  
  // 修改密码
  Future<void> changePassword({required String oldPassword, required String newPassword, required String confirmPassword}) async {
    await put(ApiConstants.changePassword, data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }
  
  // 设置/修改资金密码
  Future<void> setFundPassword({
    required String newPassword,
    required String confirmPassword,
    String? oldPassword,
    required String verifyCode,
    required int verifyType
  }) async {
    final Map<String, dynamic> data = {
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'verifyCode': verifyCode,
      'verifyType': verifyType,
    };
    
    if (oldPassword != null) {
      data['oldPassword'] = oldPassword;
    }
    
    await post(ApiConstants.fundPassword, data: data);
  }
  
  // 获取会员评论列表
  Future<Map<String, dynamic>> getMemberComments({int limit = 10, int offset = 0}) async {
    return await get(ApiConstants.commentsPage, queryParameters: {
      'limit': limit,
      'offset': offset,
    });
  }
  
  // 删除评论
  Future<void> deleteComment(int id) async {
    await delete('${ApiConstants.deleteComment}${id}');
  }
  
  // 评论通知
  Future<void> notifyComments(List<int> ids) async {
    await put(ApiConstants.notifyComments, data: {
      'ids': ids,
    });
  }
  
  // 获取浏览记录
  Future<Map<String, dynamic>> getBrowseHistory({int limit = 10, int offset = 0, int? chargingMode}) async {
    final Map<String, dynamic> params = {
      'limit': limit,
      'offset': offset,
    };
    
    if (chargingMode != null) {
      params['chargingMode'] = chargingMode;
    }
    
    return await get(ApiConstants.browseHistory, queryParameters: params);
  }
  
  // 获取移动端浏览记录
  Future<Map<String, dynamic>> getMobileBrowseHistory({int limit = 10, int offset = 0}) async {
    return await get(ApiConstants.mobileBrowseHistory, queryParameters: {
      'limit': limit,
      'offset': offset,
    });
  }
  
  // 记录浏览历史
  Future<void> recordBrowseHistory(int vodId) async {
    await post(ApiConstants.recordBrowse, data: {
      'vodId': vodId,
    });
  }
  
  // ========== 影视系统 ==========
  
  // 获取影视列表
  Future<dynamic> getVodList({
    int limit = 20,
    int offset = 0,
    String? cateId,
    String? year,
    String? area,
    String? sort,
  }) async {
    return get(ApiConstants.vodList, queryParameters: {
      'limit': limit,
      'offset': offset,
      if (cateId != null) 'cateId': cateId,
      if (year != null) 'year': year,
      if (area != null) 'area': area,
      if (sort != null) 'sort': sort,
    });
  }
  
  // 获取影视详情
  Future<dynamic> getVodDetail(String id) async {
    return get(ApiConstants.vodDetail, queryParameters: {'id': id});
  }
  
  // 获取播放信息
  Future<dynamic> getVodPlay(String id, String sid, String nid) async {
    return get(ApiConstants.vodPlay, queryParameters: {
      'id': id,
      'sid': sid,
      'nid': nid,
    });
  }
  
  // 搜索影视
  Future<dynamic> searchVod(String keyword, {int limit = 20, int offset = 0}) async {
    return get(ApiConstants.vodSearch, queryParameters: {
      'keyword': keyword,
      'limit': limit,
      'offset': offset,
    });
  }
  
  // ========== 站点信息 ==========
  
  // 获取站点信息
  Future<dynamic> getSiteInfo() async {
    return get(ApiConstants.siteInfo);
  }
  
  // 获取站点广告
  Future<dynamic> getSiteAds() async {
    return get(ApiConstants.siteAds);
  }
  
  // 获取影视分类
  Future<dynamic> getVodCategory() async {
    return get(ApiConstants.vodCategory);
  }

  // 签到相关API
  Future<Map<String, dynamic>> getCheckinInfo() async {
    final response = await _dio.get('/user/checkin/info');
    return response.data;
  }

  Future<Map<String, dynamic>> performCheckin() async {
    final response = await _dio.post('/user/checkin/perform');
    return response.data;
  }

  // 任务中心API
  Future<Map<String, dynamic>> getTasks() async {
    final response = await _dio.get('/user/tasks');
    return response.data;
  }

  Future<bool> completeTask(int taskId) async {
    final response = await _dio.post('/user/tasks/complete/$taskId');
    return response.data['success'] ?? false;
  }

  // 推广系统API
  Future<Map<String, dynamic>> getPromotionData() async {
    final response = await _dio.get('/user/promotion');
    return response.data;
  }

  // 兑换中心API
  Future<Map<String, dynamic>> getExchangeItems() async {
    final response = await _dio.get('/user/exchange/items');
    return response.data;
  }

  Future<Map<String, dynamic>> getExchangeHistory() async {
    final response = await _dio.get('/user/exchange/history');
    return response.data;
  }

  Future<bool> exchangeItem(int itemId) async {
    final response = await _dio.post('/user/exchange/perform/$itemId');
    return response.data['success'] ?? false;
  }

  // 点播记录API
  Future<Map<String, dynamic>> getOnDemandHistory({int page = 1}) async {
    final response = await _dio.get('/user/ondemand/history', queryParameters: {'page': page});
    return response.data;
  }

  // 充值记录API
  Future<Map<String, dynamic>> getRechargeHistory() async {
    final response = await _dio.get('/user/recharge/history');
    return response.data;
  }

  // 消息系统API
  Future<Map<String, dynamic>> getMessages() async {
    final response = await _dio.get('/user/messages');
    return response.data;
  }

  Future<bool> markMessageAsRead(int messageId) async {
    final response = await _dio.post('/user/messages/read/$messageId');
    return response.data['success'] ?? false;
  }

  Future<bool> deleteMessage(int messageId) async {
    final response = await _dio.delete('/user/messages/$messageId');
    return response.data['success'] ?? false;
  }

  // 收藏API
  Future<Map<String, dynamic>> getFavorites() async {
    final response = await _dio.get('/user/favorites');
    return response.data;
  }

  Future<bool> removeFavorite(String videoId) async {
    final response = await _dio.delete('/user/favorites/$videoId');
    return response.data['success'] ?? false;
  }

  // 客服系统API
  Future<List<dynamic>> getFAQs() async {
    final response = await _dio.get('/support/faqs');
    return response.data;
  }

  Future<Map<String, dynamic>> getCustomerServiceInfo() async {
    final response = await _dio.get('/support/contact');
    return response.data;
  }
}

// API异常类
class ApiException implements Exception {
  final String message;
  final int code;
  
  ApiException(this.message, this.code);
  
  @override
  String toString() => 'ApiException: $message (Code: $code)';
} 
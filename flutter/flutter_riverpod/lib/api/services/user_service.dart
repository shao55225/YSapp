import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

// 用户服务提供者
final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
});

// 用户信息提供者
final userInfoProvider = StateProvider<UserInfo?>((ref) => null);

// 登录状态提供者
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.isLoggedIn();
});

class UserService {
  final ApiService _apiService;
  
  UserService(this._apiService);
  
  // 用户登录
  Future<UserInfo> login(String username, String password) async {
    try {
      final data = await _apiService.post('/openapi/member/login', data: {
        'userName': username,
        'password': password,
      });
      
      // 保存token
      await _apiService.saveToken(data['token']);
      
      return UserInfo.fromJson(data['userInfo']);
    } catch (e) {
      rethrow;
    }
  }
  
  // 验证码登录
  Future<UserInfo> verifyLogin(String code, String userName, int verifyType) async {
    try {
      final data = await _apiService.post('/openapi/member/verify/login', data: {
        'code': code,
        'userName': userName,
        'verifyType': verifyType,
      });
      
      // 保存token
      await _apiService.saveToken(data['token']);
      
      return UserInfo.fromJson(data['userInfo']);
    } catch (e) {
      rethrow;
    }
  }
  
  // 用户注册
  Future<void> register(String username, String password, String confirmPassword, {String? inviteCode}) async {
    try {
      await _apiService.post('/openapi/member/register', data: {
        'userName': username,
        'password': password,
        'confirmPassword': confirmPassword,
        if (inviteCode != null) 'inviteCode': inviteCode,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 验证码注册
  Future<void> verifyRegister(String code, String userName, int verifyType, {String? inviteCode}) async {
    try {
      await _apiService.post('/openapi/member/verify/register', data: {
        'code': code,
        'userName': userName,
        'verifyType': verifyType,
        if (inviteCode != null) 'inviteCode': inviteCode,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 游客注册
  Future<UserInfo> touristRegister() async {
    try {
      final data = await _apiService.post('/openapi/member/tourists/register');
      
      // 保存token
      await _apiService.saveToken(data['token']);
      
      return UserInfo.fromJson(data['userInfo']);
    } catch (e) {
      rethrow;
    }
  }
  
  // 发送短信验证码
  Future<void> sendSmsCode(String phone) async {
    try {
      await _apiService.post('/openapi/sms/send_sms', data: {
        'phone': phone,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 发送邮件验证码
  Future<void> sendEmailCode(String email) async {
    try {
      await _apiService.post('/openapi/sms/send_email', data: {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取图形验证码
  Future<CaptchaInfo> getCaptcha() async {
    try {
      final data = await _apiService.get('/openapi/auth/captcha');
      return CaptchaInfo(
        img: data['img'],
        id: data['id'],
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // 退出登录
  Future<void> logout() async {
    try {
      await _apiService.post('/api/v1/sso/web/logout');
      await _apiService.clearToken();
    } catch (e) {
      // 即使API调用失败，也要清除本地token
      await _apiService.clearToken();
      rethrow;
    }
  }
  
  // 获取用户信息
  Future<UserInfo> getUserInfo() async {
    try {
      final data = await _apiService.get('/openapi/member/info');
      return UserInfo.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 编辑用户信息
  Future<void> editUserInfo({String? headImg, String? nickname, int? sex}) async {
    try {
      await _apiService.put('/openapi/member/edit', data: {
        if (headImg != null) 'headImg': headImg,
        if (nickname != null) 'nickname': nickname,
        if (sex != null) 'sex': sex,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 修改用户名
  Future<void> changeUsername(String userName) async {
    try {
      await _apiService.put('/openapi/member/change_name', data: {
        'userName': userName,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 修改密码
  Future<void> changePassword(String password, String confirmPassword, String id, String captcha) async {
    try {
      await _apiService.put('/openapi/member/change_password', data: {
        'password': password,
        'confirmPassword': confirmPassword,
        'id': id,
        'captcha': captcha,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 设置/修改资金密码
  Future<void> setFundPassword(String latestFundPassword, String verifyId, String verifyCode, {String? originFundPassword}) async {
    try {
      await _apiService.post('/openapi/member/fund_password', data: {
        'latestFundPassword': latestFundPassword,
        'verifyId': verifyId,
        'verifyCode': verifyCode,
        if (originFundPassword != null) 'originFundPassword': originFundPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 绑定手机号
  Future<void> bindPhone(String phone, String verifyId, String verifyCode) async {
    try {
      await _apiService.post('/openapi/member/bind_phone', data: {
        'phone': phone,
        'verifyId': verifyId,
        'verifyCode': verifyCode,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 绑定邮箱
  Future<void> bindEmail(String email, String verifyId, String verifyCode) async {
    try {
      await _apiService.post('/openapi/member/bind_email', data: {
        'email': email,
        'verifyId': verifyId,
        'verifyCode': verifyCode,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await _apiService.isLoggedIn();
  }
}

// 用户信息模型
class UserInfo {
  final int id;
  final String userName;
  final String? nickname;
  final String? headImg;
  final int? sex;
  final String? phone;
  final String? email;
  final bool isVip;
  final String? vipExpireTime;
  
  UserInfo({
    required this.id,
    required this.userName,
    this.nickname,
    this.headImg,
    this.sex,
    this.phone,
    this.email,
    required this.isVip,
    this.vipExpireTime,
  });
  
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      userName: json['userName'],
      nickname: json['nickname'],
      headImg: json['headImg'],
      sex: json['sex'],
      phone: json['phone'],
      email: json['email'],
      isVip: json['isVip'] ?? false,
      vipExpireTime: json['vipExpireTime'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'nickname': nickname,
      'headImg': headImg,
      'sex': sex,
      'phone': phone,
      'email': email,
      'isVip': isVip,
      'vipExpireTime': vipExpireTime,
    };
  }
}

// 验证码信息模型
class CaptchaInfo {
  final String img;
  final String id;
  
  CaptchaInfo({
    required this.img,
    required this.id,
  });
} 
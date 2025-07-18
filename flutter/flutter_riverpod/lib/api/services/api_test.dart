import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/api_constants.dart';
import 'api_service.dart';

// API测试服务提供者
final apiTestServiceProvider = Provider<ApiTestService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ApiTestService(apiService);
});

// API测试服务类 - 用于验证和测试各种API接口
class ApiTestService {
  final ApiService _apiService;
  
  ApiTestService(this._apiService);
  
  // 记录API测试结果
  void _logTestResult(String apiName, String endpoint, dynamic result, {String? error}) {
    if (error != null) {
      debugPrint('❌ [$apiName] $endpoint 失败: $error');
    } else {
      debugPrint('✅ [$apiName] $endpoint 成功');
      debugPrint('响应数据: $result');
    }
  }
  
  // 执行API调用测试
  Future<bool> testApiCall(String apiName, String endpoint, Future<dynamic> Function() apiCall) async {
    try {
      final result = await apiCall();
      _logTestResult(apiName, endpoint, result);
      return true;
    } catch (e) {
      _logTestResult(apiName, endpoint, null, error: e.toString());
      return false;
    }
  }
  
  // ========== 用户认证系统测试 ==========
  
  // 测试登录API
  Future<bool> testLogin(String userName, String password) async {
    return testApiCall('登录', ApiConstants.login, () async {
      return await _apiService.login(userName, password);
    });
  }
  
  // 测试注册API
  Future<bool> testRegister(String userName, String password, String confirmPassword, {String? inviteCode}) async {
    return testApiCall('注册', ApiConstants.register, () async {
      return await _apiService.register(userName, password, confirmPassword, inviteCode: inviteCode);
    });
  }
  
  // 测试验证码登录API
  Future<bool> testVerifyLogin(String userName, String code, int verifyType) async {
    return testApiCall('验证码登录', ApiConstants.verifyLogin, () async {
      return await _apiService.verifyLogin(userName, code, verifyType);
    });
  }
  
  // 测试获取验证码API
  Future<bool> testCaptcha() async {
    return testApiCall('获取验证码', ApiConstants.captcha, () async {
      return await _apiService.getCaptcha();
    });
  }
  
  // 测试发送短信验证码API
  Future<bool> testSendSms(String phone) async {
    return testApiCall('发送短信', ApiConstants.sendSms, () async {
      await _apiService.sendSms(phone);
      return '短信验证码已发送';
    });
  }
  
  // ========== 会员系统测试 ==========
  
  // 测试获取会员信息API
  Future<bool> testGetMemberInfo() async {
    return testApiCall('会员信息', ApiConstants.memberInfo, () async {
      return await _apiService.getMemberInfo();
    });
  }
  
  // 测试编辑会员信息API
  Future<bool> testEditMember({String? nickname, int? sex}) async {
    return testApiCall('编辑会员', ApiConstants.editMember, () async {
      await _apiService.editMember(nickname: nickname, sex: sex);
      return '会员信息已更新';
    });
  }
  
  // 测试获取会员评论列表API
  Future<bool> testGetMemberComments() async {
    return testApiCall('会员评论列表', ApiConstants.commentsPage, () async {
      return await _apiService.getMemberComments();
    });
  }
  
  // 测试获取浏览记录API
  Future<bool> testGetBrowseHistory() async {
    return testApiCall('浏览记录', ApiConstants.browseHistory, () async {
      return await _apiService.getBrowseHistory();
    });
  }
  
  // ========== 支付系统测试 ==========
  
  // 测试获取支付配置API
  Future<bool> testGetPayConfig() async {
    return testApiCall('支付配置', ApiConstants.payConfig, () async {
      return await _apiService.get(ApiConstants.payConfig);
    });
  }
  
  // 测试获取套餐API
  Future<bool> testGetAllPackages() async {
    return testApiCall('所有套餐', ApiConstants.allPackages, () async {
      return await _apiService.get(ApiConstants.allPackages);
    });
  }
  
  // 测试获取金币记录API
  Future<bool> testGetGoldRecords() async {
    return testApiCall('金币记录', ApiConstants.goldPage, () async {
      return await _apiService.get(ApiConstants.goldPage, queryParameters: {
        'limit': 10,
        'offset': 0,
      });
    });
  }
  
  // ========== 站点信息测试 ==========
  
  // 测试获取站点信息API
  Future<bool> testGetSiteInfo() async {
    return testApiCall('站点信息', ApiConstants.siteInfo, () async {
      return await _apiService.getSiteInfo();
    });
  }
  
  // 测试获取站点广告API
  Future<bool> testGetSiteAds() async {
    return testApiCall('站点广告', ApiConstants.siteAds, () async {
      return await _apiService.getSiteAds();
    });
  }
  
  // ========== 批量测试 ==========
  
  // 运行所有不需要登录的API测试
  Future<Map<String, bool>> runPublicApiTests() async {
    final results = <String, bool>{};
    
    // 站点信息
    results['站点信息'] = await testGetSiteInfo();
    results['站点广告'] = await testGetSiteAds();
    
    // 认证系统
    results['获取验证码'] = await testCaptcha();
    
    return results;
  }
  
  // 运行所有需要登录的API测试
  Future<Map<String, bool>> runAuthenticatedApiTests() async {
    final results = <String, bool>{};
    
    // 确认已登录
    final isLoggedIn = await _apiService.isLoggedIn();
    if (!isLoggedIn) {
      debugPrint('⚠️ 警告: 用户未登录，无法测试需要认证的API');
      return results;
    }
    
    // 会员系统
    results['会员信息'] = await testGetMemberInfo();
    results['会员评论列表'] = await testGetMemberComments();
    results['浏览记录'] = await testGetBrowseHistory();
    
    // 支付系统
    results['支付配置'] = await testGetPayConfig();
    results['所有套餐'] = await testGetAllPackages();
    results['金币记录'] = await testGetGoldRecords();
    
    return results;
  }
  
  // 将测试结果保存到文件
  Future<void> saveTestResultsToFile(Map<String, bool> results, String fileName) async {
    try {
      final file = File(fileName);
      final buffer = StringBuffer();
      
      buffer.writeln('API测试结果报告');
      buffer.writeln('时间: ${DateTime.now()}');
      buffer.writeln('=====================================');
      
      int passed = 0;
      int failed = 0;
      
      results.forEach((api, success) {
        if (success) {
          buffer.writeln('✅ $api: 成功');
          passed++;
        } else {
          buffer.writeln('❌ $api: 失败');
          failed++;
        }
      });
      
      buffer.writeln('=====================================');
      buffer.writeln('总计: ${results.length} 项测试');
      buffer.writeln('通过: $passed');
      buffer.writeln('失败: $failed');
      buffer.writeln('通过率: ${(passed / results.length * 100).toStringAsFixed(2)}%');
      
      await file.writeAsString(buffer.toString());
      debugPrint('测试结果已保存到 $fileName');
    } catch (e) {
      debugPrint('保存测试结果失败: $e');
    }
  }
} 
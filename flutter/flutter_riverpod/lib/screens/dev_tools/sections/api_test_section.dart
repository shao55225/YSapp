import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/services/api_service.dart';
import '../../../constants/api_constants.dart';
import '../widgets/test_card.dart';
import '../widgets/result_dialog.dart';

class ApiTestSection extends StatelessWidget {
  final WidgetRef ref;
  
  const ApiTestSection({Key? key, required this.ref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = ref.read(apiServiceProvider);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TestCard(
          title: '基础API连接测试',
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await apiService.get(ApiConstants.siteInfo);
                  showResultDialog(context, '站点信息API', result);
                } catch (e) {
                  showResultDialog(context, '站点信息API', {'error': e.toString()});
                }
              },
              child: const Text('测试站点信息API'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await apiService.get(ApiConstants.vodCategory);
                  showResultDialog(context, '视频分类API', result);
                } catch (e) {
                  showResultDialog(context, '视频分类API', {'error': e.toString()});
                }
              },
              child: const Text('测试视频分类API'),
            ),
          ],
        ),
        
        TestCard(
          title: '认证API测试',
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await apiService.get(ApiConstants.captcha);
                  showResultDialog(context, '验证码API', result);
                } catch (e) {
                  showResultDialog(context, '验证码API', {'error': e.toString()});
                }
              },
              child: const Text('获取验证码'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final isLoggedIn = await apiService.isLoggedIn();
                  showResultDialog(context, '登录状态检查', {'isLoggedIn': isLoggedIn});
                } catch (e) {
                  showResultDialog(context, '登录状态检查', {'error': e.toString()});
                }
              },
              child: const Text('检查登录状态'),
            ),
          ],
        ),
        
        TestCard(
          title: '网络诊断',
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await _testApiLatency(apiService);
                  showResultDialog(context, 'API延迟测试', result);
                } catch (e) {
                  showResultDialog(context, 'API延迟测试', {'error': e.toString()});
                }
              },
              child: const Text('测试API延迟'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await _testAllEndpoints(apiService);
                  showResultDialog(context, '端点可用性测试', result);
                } catch (e) {
                  showResultDialog(context, '端点可用性测试', {'error': e.toString()});
                }
              },
              child: const Text('测试端点可用性'),
            ),
          ],
        ),
        
        TestCard(
          title: '错误处理测试',
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  // 故意调用不存在的API
                  await apiService.get('/non-existent-endpoint');
                } catch (e) {
                  showResultDialog(context, '错误处理测试', {'error': e.toString()});
                }
              },
              child: const Text('测试404错误'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // 故意传递错误参数
                  await apiService.post(ApiConstants.login, data: {
                    'userName': 'test',
                    // 缺少password参数
                  });
                } catch (e) {
                  showResultDialog(context, '参数错误测试', {'error': e.toString()});
                }
              },
              child: const Text('测试参数错误'),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<Map<String, dynamic>> _testApiLatency(ApiService apiService) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await apiService.get(ApiConstants.siteInfo);
      stopwatch.stop();
      
      final latency = stopwatch.elapsedMilliseconds;
      String quality;
      
      if (latency < 100) {
        quality = '极佳';
      } else if (latency < 300) {
        quality = '良好';
      } else if (latency < 1000) {
        quality = '一般';
      } else {
        quality = '较差';
      }
      
      return {
        'latency': '$latency ms',
        'quality': quality,
        'timestamp': DateTime.now().toString(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> _testAllEndpoints(ApiService apiService) async {
    final endpoints = [
      ApiConstants.siteInfo,
      ApiConstants.vodCategory,
      ApiConstants.captcha,
    ];
    
    final results = <String, String>{};
    
    for (final endpoint in endpoints) {
      try {
        final stopwatch = Stopwatch()..start();
        await apiService.get(endpoint);
        stopwatch.stop();
        
        results[endpoint] = '可用 (${stopwatch.elapsedMilliseconds} ms)';
      } catch (e) {
        results[endpoint] = '不可用: ${e.toString()}';
      }
    }
    
    return results;
  }
} 
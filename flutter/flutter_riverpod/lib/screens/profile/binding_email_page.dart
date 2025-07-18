import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class BindingEmailPage extends ConsumerStatefulWidget {
  const BindingEmailPage({Key? key}) : super(key: key);

  @override
  _BindingEmailPageState createState() => _BindingEmailPageState();
}

class _BindingEmailPageState extends ConsumerState<BindingEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  Timer? _timer;
  int _countdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // 发送验证码
  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty || !_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的邮箱地址')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.sendEmailCode(_emailController.text);
      
      // 开始倒计时
      setState(() {
        _countdown = 60;
      });
      
      _startCountdownTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验证码已发送到邮箱')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送验证码失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 开始倒计时
  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  // 绑定邮箱
  Future<void> _bindEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.bindEmail(
        email: _emailController.text,
        verifyCode: _codeController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('邮箱绑定成功')),
      );
      
      // 返回上一页
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('绑定邮箱失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 验证邮箱格式
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('绑定邮箱'),
      ),
      body: _isLoading 
          ? const LoadingIndicator() 
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      // 提示信息
                      const Text(
                        '绑定邮箱后，可以使用邮箱登录，也可以通过邮箱找回密码',
                        style: TextStyle(color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 邮箱输入
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '邮箱',
                          hintText: '请输入邮箱地址',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入邮箱地址';
                          }
                          if (!_isValidEmail(value)) {
                            return '请输入正确的邮箱格式';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 验证码输入
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '验证码',
                                hintText: '请输入验证码',
                                prefixIcon: Icon(Icons.security),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入验证码';
                                }
                                if (value.length < 4) {
                                  return '验证码格式不正确';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _countdown > 0 ? null : _sendVerificationCode,
                              child: Text(_countdown > 0 ? '$_countdown秒' : '获取验证码'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 绑定按钮
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _bindEmail,
                          child: const Text('绑定', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 提示信息
                      const Center(
                        child: Text(
                          '绑定即代表同意《隐私协议》',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
} 
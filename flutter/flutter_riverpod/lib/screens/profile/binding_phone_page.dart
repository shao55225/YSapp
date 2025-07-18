import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/common/verification_code_input.dart';
import '../../widgets/common/loading_button.dart';

class BindingPhonePage extends ConsumerStatefulWidget {
  const BindingPhonePage({Key? key}) : super(key: key);

  @override
  _BindingPhonePageState createState() => _BindingPhonePageState();
}

class _BindingPhonePageState extends ConsumerState<BindingPhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // 发送验证码
  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的手机号码')),
      );
      throw Exception('手机号码格式错误');
    }

    final apiService = ref.read(apiServiceProvider);
    await apiService.sendSmsCode(_phoneController.text);
  }

  // 绑定手机号
  Future<void> _bindPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.bindPhone(
        phone: _phoneController.text,
        verifyCode: _codeController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('手机绑定成功')),
      );
      
      // 返回上一页
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('绑定手机失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('绑定手机号'),
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
                        '绑定手机号后，可以使用手机号登录，也可以通过手机找回密码',
                        style: TextStyle(color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 手机号输入
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: '手机号',
                          hintText: '请输入手机号',
                          prefixIcon: Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入手机号';
                          }
                          if (value.length != 11) {
                            return '请输入正确的11位手机号码';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 使用验证码输入组件
                      VerificationCodeInput(
                        controller: _codeController,
                        onSendCode: _sendVerificationCode,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 使用加载按钮组件
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: LoadingButton(
                          isLoading: _isLoading,
                          onPressed: _bindPhone,
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
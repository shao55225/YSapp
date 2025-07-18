import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class FundPasswordPage extends ConsumerStatefulWidget {
  const FundPasswordPage({Key? key}) : super(key: key);

  @override
  _FundPasswordPageState createState() => _FundPasswordPageState();
}

class _FundPasswordPageState extends ConsumerState<FundPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginPasswordController = TextEditingController();
  final _fundPasswordController = TextEditingController();
  final _confirmFundPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _obscureFundPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isEdit = false; // 是否为修改资金密码（如果用户已设置资金密码，则为修改模式）

  @override
  void initState() {
    super.initState();
    // TODO: 这里可以检查用户是否已设置过资金密码
    // 如果已设置，将 _isEdit 设为 true
  }

  @override
  void dispose() {
    _loginPasswordController.dispose();
    _fundPasswordController.dispose();
    _confirmFundPasswordController.dispose();
    super.dispose();
  }

  // 设置或修改资金密码
  Future<void> _setFundPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.setFundPassword(
        loginPassword: _loginPasswordController.text,
        fundPassword: _fundPasswordController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '资金密码修改成功' : '资金密码设置成功')),
      );
      
      // 返回上一页
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isEdit ? '修改' : '设置'}资金密码失败: $e')),
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
        title: Text(_isEdit ? '修改资金密码' : '设置资金密码'),
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
                      Text(
                        _isEdit 
                            ? '修改资金密码前，需要验证您的登录密码' 
                            : '设置资金密码后，在进行金币/充值相关操作时需要验证',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 登录密码
                      TextFormField(
                        controller: _loginPasswordController,
                        obscureText: _obscureLoginPassword,
                        decoration: InputDecoration(
                          labelText: '登录密码',
                          hintText: '请输入登录密码',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureLoginPassword = !_obscureLoginPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入登录密码';
                          }
                          if (value.length < 6) {
                            return '密码长度不能少于6位';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 资金密码
                      TextFormField(
                        controller: _fundPasswordController,
                        obscureText: _obscureFundPassword,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '资金密码',
                          hintText: '请设置6位数字资金密码',
                          prefixIcon: const Icon(Icons.security),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureFundPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureFundPassword = !_obscureFundPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入资金密码';
                          }
                          if (value.length != 6) {
                            return '资金密码必须为6位数字';
                          }
                          // 检查是否全部为数字
                          if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                            return '资金密码只能包含数字';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 确认资金密码
                      TextFormField(
                        controller: _confirmFundPasswordController,
                        obscureText: _obscureConfirmPassword,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '确认资金密码',
                          hintText: '请再次输入资金密码',
                          prefixIcon: const Icon(Icons.security),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请确认资金密码';
                          }
                          if (value != _fundPasswordController.text) {
                            return '两次输入的资金密码不一致';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 设置/修改按钮
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _setFundPassword,
                          child: Text(
                            _isEdit ? '修改资金密码' : '设置资金密码', 
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 安全提示
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '安全提示：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('1. 资金密码用于保护您的账户资金安全'),
                            Text('2. 资金密码必须为6位数字'),
                            Text('3. 请勿使用简单的连续数字或重复数字作为资金密码'),
                            Text('4. 请妥善保管您的资金密码，不要与他人分享'),
                          ],
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// 注册表单状态提供者
final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  return RegisterFormNotifier();
});

// 注册表单状态
class RegisterFormState {
  final String username;
  final String password;
  final String confirmPassword;
  final String? inviteCode;
  final bool agreeTerms;
  final bool isLoading;
  final String? errorMessage;

  RegisterFormState({
    this.username = '',
    this.password = '',
    this.confirmPassword = '',
    this.inviteCode,
    this.agreeTerms = false,
    this.isLoading = false,
    this.errorMessage,
  });

  RegisterFormState copyWith({
    String? username,
    String? password,
    String? confirmPassword,
    String? inviteCode,
    bool? agreeTerms,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RegisterFormState(
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      inviteCode: inviteCode ?? this.inviteCode,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 注册表单状态管理
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier() : super(RegisterFormState());

  void setUsername(String username) {
    state = state.copyWith(username: username);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void setInviteCode(String inviteCode) {
    state = state.copyWith(inviteCode: inviteCode.isEmpty ? null : inviteCode);
  }

  void setAgreeTerms(bool agreeTerms) {
    state = state.copyWith(agreeTerms: agreeTerms);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setErrorMessage(String? errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }
}

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(registerFormProvider);
    final userService = ref.watch(userServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            // 用户名输入框
            TextField(
              decoration: const InputDecoration(
                labelText: '用户名',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
                hintText: '请输入用户名',
              ),
              onChanged: (value) {
                ref.read(registerFormProvider.notifier).setUsername(value);
              },
            ),
            const SizedBox(height: 16.0),
            // 密码输入框
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
                hintText: '请输入密码',
              ),
              onChanged: (value) {
                ref.read(registerFormProvider.notifier).setPassword(value);
              },
            ),
            const SizedBox(height: 16.0),
            // 确认密码输入框
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认密码',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
                hintText: '请再次输入密码',
              ),
              onChanged: (value) {
                ref.read(registerFormProvider.notifier).setConfirmPassword(value);
              },
            ),
            const SizedBox(height: 16.0),
            // 邀请码输入框（可选）
            TextField(
              decoration: const InputDecoration(
                labelText: '邀请码（可选）',
                prefixIcon: Icon(Icons.card_giftcard),
                border: OutlineInputBorder(),
                hintText: '请输入邀请码（可选）',
              ),
              onChanged: (value) {
                ref.read(registerFormProvider.notifier).setInviteCode(value);
              },
            ),
            const SizedBox(height: 16.0),
            // 用户协议
            Row(
              children: [
                Checkbox(
                  value: formState.agreeTerms,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setAgreeTerms(value ?? false);
                  },
                ),
                const Text('我已阅读并同意'),
                TextButton(
                  onPressed: () {
                    // 导航到用户协议页面
                    context.push('/terms');
                  },
                  child: const Text('《用户协议》'),
                ),
                const Text('和'),
                TextButton(
                  onPressed: () {
                    // 导航到隐私政策页面
                    context.push('/privacy');
                  },
                  child: const Text('《隐私政策》'),
                ),
              ],
            ),
            // 错误消息
            if (formState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  formState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24.0),
            // 注册按钮
            ElevatedButton(
              onPressed: formState.isLoading
                  ? null
                  : () async {
                      // 验证表单
                      if (formState.username.isEmpty) {
                        ref.read(registerFormProvider.notifier).setErrorMessage('请输入用户名');
                        return;
                      }
                      if (formState.password.isEmpty) {
                        ref.read(registerFormProvider.notifier).setErrorMessage('请输入密码');
                        return;
                      }
                      if (formState.confirmPassword.isEmpty) {
                        ref.read(registerFormProvider.notifier).setErrorMessage('请确认密码');
                        return;
                      }
                      if (formState.password != formState.confirmPassword) {
                        ref.read(registerFormProvider.notifier).setErrorMessage('两次输入的密码不一致');
                        return;
                      }
                      if (!formState.agreeTerms) {
                        ref.read(registerFormProvider.notifier).setErrorMessage('请阅读并同意用户协议和隐私政策');
                        return;
                      }

                      // 设置加载状态
                      ref.read(registerFormProvider.notifier).setLoading(true);
                      ref.read(registerFormProvider.notifier).setErrorMessage(null);

                      try {
                        // 调用注册API
                        await userService.register(
                          formState.username,
                          formState.password,
                          formState.confirmPassword,
                          inviteCode: formState.inviteCode,
                        );

                        // 注册成功，自动登录
                        await userService.login(
                          formState.username,
                          formState.password,
                        );

                        // 刷新用户信息
                        ref.refresh(userInfoProvider);
                        
                        // 返回上一页
                        if (context.mounted) {
                          // 显示注册成功提示
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('注册成功'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          // 返回到首页
                          context.go('/');
                        }
                      } catch (e) {
                        // 注册失败，显示错误信息
                        ref.read(registerFormProvider.notifier).setErrorMessage(e.toString());
                      } finally {
                        // 取消加载状态
                        ref.read(registerFormProvider.notifier).setLoading(false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: formState.isLoading
                  ? const SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text('注册'),
            ),
            const SizedBox(height: 16.0),
            // 其他注册方式
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('其他注册方式：'),
                TextButton(
                  onPressed: () {
                    // 导航到验证码注册页面
                    context.push('/register/code');
                  },
                  child: const Text('验证码注册'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            // 登录入口
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('已有账号？'),
                TextButton(
                  onPressed: () {
                    // 返回登录页面
                    context.pop();
                  },
                  child: const Text('立即登录'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
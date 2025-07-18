import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';

// 登录表单状态提供者
final loginFormProvider = StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});

// 登录表单状态
class LoginFormState {
  final String username;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  LoginFormState({
    this.username = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  LoginFormState copyWith({
    String? username,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 登录表单状态管理
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(LoginFormState());

  void setUsername(String username) {
    state = state.copyWith(username: username);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setErrorMessage(String? errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormProvider);
    final userService = ref.watch(userServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            // Logo或图标
            Center(
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.person,
                  size: 60.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            // 用户名输入框
            TextField(
              decoration: const InputDecoration(
                labelText: '用户名/手机号/邮箱',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(loginFormProvider.notifier).setUsername(value);
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
              ),
              onChanged: (value) {
                ref.read(loginFormProvider.notifier).setPassword(value);
              },
            ),
            const SizedBox(height: 8.0),
            // 错误消息
            if (formState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  formState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8.0),
            // 忘记密码
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 导航到忘记密码页面
                  context.push('/forgot-password');
                },
                child: const Text('忘记密码？'),
              ),
            ),
            const SizedBox(height: 24.0),
            // 登录按钮
            ElevatedButton(
              onPressed: formState.isLoading
                  ? null
                  : () async {
                      // 验证表单
                      if (formState.username.isEmpty) {
                        ref.read(loginFormProvider.notifier).setErrorMessage('请输入用户名');
                        return;
                      }
                      if (formState.password.isEmpty) {
                        ref.read(loginFormProvider.notifier).setErrorMessage('请输入密码');
                        return;
                      }

                      // 设置加载状态
                      ref.read(loginFormProvider.notifier).setLoading(true);
                      ref.read(loginFormProvider.notifier).setErrorMessage(null);

                      try {
                        // 调用登录API
                        await userService.login(
                          formState.username,
                          formState.password,
                        );

                        // 登录成功，刷新用户信息
                        ref.refresh(userInfoProvider);
                        
                        // 返回上一页
                        if (context.mounted) {
                          context.pop();
                        }
                      } catch (e) {
                        // 登录失败，显示错误信息
                        ref.read(loginFormProvider.notifier).setErrorMessage(e.toString());
                      } finally {
                        // 取消加载状态
                        ref.read(loginFormProvider.notifier).setLoading(false);
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
                  : const Text('登录'),
            ),
            const SizedBox(height: 16.0),
            // 其他登录方式
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('其他登录方式：'),
                TextButton(
                  onPressed: () {
                    // 导航到验证码登录页面
                    context.push('/login/code');
                  },
                  child: const Text('验证码登录'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            // 注册入口
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('还没有账号？'),
                TextButton(
                  onPressed: () {
                    // 导航到注册页面
                    context.push('/register');
                  },
                  child: const Text('立即注册'),
                ),
              ],
            ),
            // 游客登录
            TextButton(
              onPressed: () async {
                // 设置加载状态
                ref.read(loginFormProvider.notifier).setLoading(true);
                ref.read(loginFormProvider.notifier).setErrorMessage(null);

                try {
                  // 调用游客登录API
                  await userService.touristRegister();

                  // 登录成功，刷新用户信息
                  ref.refresh(userInfoProvider);
                  
                  // 返回上一页
                  if (context.mounted) {
                    context.pop();
                  }
                } catch (e) {
                  // 登录失败，显示错误信息
                  ref.read(loginFormProvider.notifier).setErrorMessage(e.toString());
                } finally {
                  // 取消加载状态
                  ref.read(loginFormProvider.notifier).setLoading(false);
                }
              },
              child: const Text('游客登录'),
            ),
          ],
        ),
      ),
    );
  }
} 
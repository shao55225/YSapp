import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/user_service.dart';
import '../../widgets/loading_indicator.dart';

final signInStateProvider = StateNotifierProvider<SignInNotifier, SignInState>((ref) {
  return SignInNotifier(ref);
});

class SignInState {
  final bool isLoading;
  final bool hasSignedIn;
  final int continueDays;
  final int todayReward;
  final String? message;

  SignInState({
    this.isLoading = false,
    this.hasSignedIn = false,
    this.continueDays = 0,
    this.todayReward = 0,
    this.message,
  });

  SignInState copyWith({
    bool? isLoading,
    bool? hasSignedIn,
    int? continueDays,
    int? todayReward,
    String? message,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      hasSignedIn: hasSignedIn ?? this.hasSignedIn,
      continueDays: continueDays ?? this.continueDays,
      todayReward: todayReward ?? this.todayReward,
      message: message,
    );
  }
}

class SignInNotifier extends StateNotifier<SignInState> {
  final Ref ref;
  SignInNotifier(this.ref) : super(SignInState()) {
    loadSignInStatus();
  }

  Future<void> loadSignInStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 调用后端API获取签到状态
      // 这里用模拟数据
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        isLoading: false,
        hasSignedIn: false,
        continueDays: 3,
        todayReward: 10,
        message: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, message: '加载失败: $e');
    }
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, message: null);
    try {
      // TODO: 调用后端API进行签到
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(
        isLoading: false,
        hasSignedIn: true,
        continueDays: state.continueDays + 1,
        todayReward: 10,
        message: '签到成功，获得${state.todayReward}金币！',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, message: '签到失败: $e');
    }
  }
}

class SignInScreen extends ConsumerWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signInStateProvider);
    final notifier = ref.read(signInStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('每日签到')),
      body: signInState.isLoading
          ? const Center(child: LoadingIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    signInState.hasSignedIn ? '今日已签到' : '今日未签到',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('已连续签到：${signInState.continueDays} 天', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('今日奖励：${signInState.todayReward} 金币', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: signInState.hasSignedIn || signInState.isLoading
                        ? null
                        : () async {
                            await notifier.signIn();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(signInState.hasSignedIn ? '已签到' : '立即签到'),
                  ),
                  if (signInState.message != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      signInState.message!,
                      style: const TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/services/user_service.dart';
import '../screens/profile/widgets/login_dialog.dart';

class AuthCheck {
  /// 检查用户是否已登录，如果未登录则显示登录弹窗
  /// 
  /// 返回值：
  /// - true: 用户已登录或者同意登录
  /// - false: 用户取消登录
  static Future<bool> check(BuildContext context, WidgetRef ref, {String? message}) async {
    final userService = ref.read(userServiceProvider);
    final isLoggedIn = await userService.isLoggedIn();
    
    if (isLoggedIn) {
      return true;
    }
    
    // 显示登录弹窗
    final result = await LoginDialog.show(context, message: message);
    return result ?? false;
  }
  
  /// 执行需要登录的操作
  /// 
  /// [onAuthenticated]: 用户已登录或同意登录后执行的回调
  /// [message]: 登录提示信息
  static Future<void> run(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function() onAuthenticated,
    String? message,
  }) async {
    final isAuthenticated = await check(context, ref, message: message);
    
    if (isAuthenticated) {
      await onAuthenticated();
    }
  }
} 
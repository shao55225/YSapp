import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/services/api_service.dart';
import '../../api/models/user_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

// 从API服务获取用户信息的Provider
final securityUserProvider = FutureProvider<UserModel>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final userData = await apiService.getMemberInfo();
  return UserModel.fromJson(userData);
});

class SecuritySettingsPage extends ConsumerWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(securityUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('账号安全'),
      ),
      body: userAsyncValue.when(
        data: (user) => _buildSecurityOptions(context, user),
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: '加载用户信息失败: $e', 
          onRetry: () => ref.refresh(securityUserProvider),
        ),
      ),
    );
  }

  Widget _buildSecurityOptions(BuildContext context, UserModel user) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        
        // 手机号绑定
        _buildSecurityItem(
          context,
          icon: Icons.phone_android,
          title: '手机号码',
          subtitle: user.phone != null && user.phone!.isNotEmpty 
              ? '已绑定: ${_maskPhoneNumber(user.phone!)}'
              : '未绑定',
          onTap: () {
            context.push('/profile/bind-phone');
          },
        ),
        
        const Divider(),
        
        // 邮箱绑定
        _buildSecurityItem(
          context,
          icon: Icons.email,
          title: '邮箱账号',
          subtitle: user.email != null && user.email!.isNotEmpty 
              ? '已绑定: ${_maskEmail(user.email!)}'
              : '未绑定',
          onTap: () {
            context.push('/profile/bind-email');
          },
        ),
        
        const Divider(),
        
        // 登录密码
        _buildSecurityItem(
          context,
          icon: Icons.lock,
          title: '登录密码',
          subtitle: '定期修改密码可以保护您的账号更加安全',
          onTap: () {
            context.push('/profile/change-password');
          },
        ),
        
        const Divider(),
        
        // 资金密码
        _buildSecurityItem(
          context,
          icon: Icons.security,
          title: '资金密码',
          subtitle: '设置资金密码可以保护您的账号资金安全',
          onTap: () {
            context.push('/profile/fund-password');
          },
        ),
        
        const SizedBox(height: 24),
        
        // 安全提示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '账号安全提示',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '1. 定期修改密码，且不要使用简单密码',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '2. 请勿将账号密码告知他人',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '3. 建议绑定手机和邮箱，方便账号找回',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // 手机号码脱敏处理
  String _maskPhoneNumber(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }

  // 邮箱脱敏处理
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    String name = parts[0];
    String domain = parts[1];
    
    if (name.length <= 2) {
      return '${name.substring(0, 1)}***@$domain';
    } else {
      return '${name.substring(0, 2)}***@$domain';
    }
  }
} 
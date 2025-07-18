import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/user_service.dart';
import '../../api/services/payment_service.dart';
import '../../constants/asset_paths.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/format_util.dart';
import '../../utils/auth_check.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'widgets/login_dialog.dart';

// 用户信息状态提供者
final userInfoStateProvider = FutureProvider<UserInfo?>((ref) async {
  final userService = ref.watch(userServiceProvider);
  final isLoggedIn = await userService.isLoggedIn();
  
  if (isLoggedIn) {
    try {
      return await userService.getUserInfo();
    } catch (e) {
      return null;
    }
  }
  return null;
});

// 金币信息状态提供者
final goldInfoStateProvider = FutureProvider<GoldInfo?>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  final isLoggedIn = await ref.watch(isLoggedInProvider.future);
  
  if (isLoggedIn) {
    try {
      return await paymentService.getGoldInfo();
    } catch (e) {
      return null;
    }
  }
  return null;
});

// 观看记录状态提供者
final watchHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  // 这里应该调用获取观看记录的API
  // 暂时返回空列表
  return [];
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoState = ref.watch(userInfoStateProvider);
    final goldInfoState = ref.watch(goldInfoStateProvider);
    final watchHistoryState = ref.watch(watchHistoryProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 导航到通知页面
              context.push('/notices');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 导航到设置页面
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 刷新数据
          ref.refresh(userInfoStateProvider);
          ref.refresh(goldInfoStateProvider);
          ref.refresh(watchHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 用户信息卡片
              userInfoState.when(
                data: (userInfo) => _buildUserInfoCard(context, userInfo, ref),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildUserInfoCard(context, null, ref),
                ),
              ),
              
              // VIP会员卡片
              userInfoState.when(
                data: (userInfo) => _buildVipCard(context, userInfo, ref),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => _buildVipCard(context, null, ref),
              ),
              
              // 金币乐园
              goldInfoState.when(
                data: (goldInfo) => _buildGoldSection(context, goldInfo, ref),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _buildGoldSection(context, null, ref),
              ),
              
              // 任务中心、兑换中心、交易明细
              _buildFunctionButtons(context),
              
              // 观看记录
              watchHistoryState.when(
                data: (history) => _buildViewingHistory(context, history),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _buildViewingHistory(context, []),
              ),
              
              // 推广横幅
              _buildPromotionBanner(context),
              
              // 常用功能
              _buildCommonFunctions(context),
              
              // 底部导航占位
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserInfo? userInfo, WidgetRef ref) {
    final isLoggedIn = userInfo != null;

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: isLoggedIn && userInfo.headImg != null
                  ? NetworkImage(userInfo.headImg!)
                  : null,
              child: isLoggedIn && userInfo.headImg != null
                  ? null
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 16.0),
            // 用户信息
            Expanded(
              child: isLoggedIn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo.nickname ?? userInfo.userName,
                          style: AppTextStyles.headline4,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          userInfo.isVip && userInfo.vipExpireTime != null
                              ? 'VIP会员 · ${userInfo.vipExpireTime}到期'
                              : '普通用户',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        // 导航到登录页面
                        context.push('/login');
                      },
                      child: const Text(
                        '登录注册',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            // 编辑按钮
            if (isLoggedIn)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // 导航到编辑个人资料页面
                  context.push('/profile/edit');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipCard(BuildContext context, UserInfo? userInfo, WidgetRef ref) {
    final isLoggedIn = userInfo != null;
    final isVip = isLoggedIn && userInfo.isVip;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VIP会员',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                isVip
                    ? '到期时间：${userInfo!.vipExpireTime ?? "未知"}'
                    : '开通VIP会员享受超多精彩内容',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // 导航到VIP开通页面
              context.push('/vip');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: Text(isVip ? '续费会员' : '开通会员'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldSection(BuildContext context, GoldInfo? goldInfo, WidgetRef ref) {
    final int goldBalance = goldInfo?.remainGold ?? 0;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.amber,
              ),
              const SizedBox(width: 8.0),
              const Text(
                '金币乐园',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_outlined,
                      size: 16.0,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '金币余额 $goldBalance',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const Text(
            '天天得金币，超多好礼等你来兑',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // 导航到购买金币页面
              context.push('/gold/buy');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('购买金币'),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFunctionButton(
              context,
              Icons.assignment,
              '任务中心',
              Colors.orange,
              onTap: () => context.push('/profile/task_center'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _buildFunctionButton(
              context,
              Icons.card_giftcard,
              '兑换中心',
              Colors.pink,
              onTap: () => context.push('/profile/exchange'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _buildFunctionButton(
              context,
              Icons.receipt_long,
              '交易明细',
              Colors.blue,
              onTap: () => context.push('/profile/transactions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        // 使用登录检查
        await AuthCheck.run(
          context,
          ref,
          onAuthenticated: () async {
            onTap();
          },
          message: '访问$label需要登录',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewingHistory(BuildContext context, List<dynamic> history) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '观看记录',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 查看更多观看记录
                  context.push('/history');
                },
                child: Row(
                  children: const [
                    Text('更多'),
                    Icon(Icons.chevron_right, size: 16.0),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // 这里可以添加观看记录列表
          history.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('暂无观看记录'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length > 3 ? 3 : history.length,
                  itemBuilder: (context, index) {
                    // 构建观看记录项
                    return const ListTile(
                      title: Text('视频标题'),
                      subtitle: Text('观看时间'),
                      leading: CircleAvatar(),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 导航到推广页面
        context.push('/profile/promotion');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12.0),
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_add,
              color: Colors.white,
              size: 32.0,
            ),
            const SizedBox(width: 16.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '推广新用户',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '注册成功',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Text(
                '享超多会员体验',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFunctions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '常用功能',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: [
              _buildCommonFunctionItem(
                context,
                Icons.check_circle,
                '签到',
                onTap: () => context.push('/profile/checkin'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.live_tv,
                '我的点播',
                onTap: () => context.push('/profile/on_demand_history'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.payment,
                '充值记录',
                onTap: () => context.push('/profile/recharge_history'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.message,
                '我的消息',
                onTap: () => context.push('/profile/messages'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.favorite,
                '我的收藏',
                onTap: () => context.push('/profile/favorites'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.support_agent,
                '我的客服',
                onTap: () => context.push('/profile/customer_service'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.vpn_key,
                '卡密激活',
                onTap: () => context.push('/payment/activate'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.monetization_on,
                '推广赚钱',
                onTap: () => context.push('/profile/promotion'),
              ),
              _buildCommonFunctionItem(
                context,
                Icons.settings,
                '个人设置',
                onTap: () => context.push('/profile/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFunctionItem(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        // 使用登录检查
        await AuthCheck.run(
          context,
          ref,
          onAuthenticated: () async {
            onTap();
          },
          message: '访问$label需要登录',
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
} 
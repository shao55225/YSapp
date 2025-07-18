import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/payment_service.dart';
import '../../api/services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/format_util.dart';

// VIP套餐状态提供者
final vipPackagesProvider = FutureProvider<List<Package>>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  // 获取VIP套餐列表（type=1表示VIP套餐）
  return await paymentService.getAllPackages(1);
});

// 选中套餐状态提供者
final selectedPackageProvider = StateProvider<Package?>((ref) => null);

class VipScreen extends ConsumerWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesState = ref.watch(vipPackagesProvider);
    final selectedPackage = ref.watch(selectedPackageProvider);
    final userInfoState = ref.watch(userInfoStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP会员'),
      ),
      body: Column(
        children: [
          // VIP特权介绍
          _buildVipBenefits(),
          
          // 用户VIP状态
          userInfoState.when(
            data: (userInfo) => _buildVipStatus(context, userInfo),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildVipStatus(context, null),
          ),
          
          // 套餐列表
          Expanded(
            child: packagesState.when(
              data: (packages) => _buildPackageList(context, packages, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('加载失败：$error'),
              ),
            ),
          ),
          
          // 底部购买按钮
          _buildBottomBar(context, selectedPackage, ref),
        ],
      ),
    );
  }

  Widget _buildVipBenefits() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.amber.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VIP特权',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBenefitItem(Icons.movie, '海量影片'),
              _buildBenefitItem(Icons.hd, '高清画质'),
              _buildBenefitItem(Icons.speed, '极速播放'),
              _buildBenefitItem(Icons.new_releases, '抢先看'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.amber,
          size: 32.0,
        ),
        const SizedBox(height: 8.0),
        Text(label),
      ],
    );
  }

  Widget _buildVipStatus(BuildContext context, UserInfo? userInfo) {
    final isVip = userInfo != null && userInfo.isVip;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo?.nickname ?? userInfo?.userName ?? '游客',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  isVip
                      ? '到期时间：${userInfo!.vipExpireTime ?? "未知"}'
                      : '您还不是VIP会员',
                  style: TextStyle(
                    color: isVip ? Colors.amber : Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          if (isVip)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Text(
                'VIP会员',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageList(BuildContext context, List<Package> packages, WidgetRef ref) {
    if (packages.isEmpty) {
      return const Center(
        child: Text('暂无可用套餐'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final isSelected = ref.watch(selectedPackageProvider) == package;

        return GestureDetector(
          onTap: () {
            ref.read(selectedPackageProvider.notifier).state = package;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.amber.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.grey[300]!,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '有效期：${package.days}天',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      if (package.remark != null && package.remark!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            package.remark!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${package.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.red,
                      ),
                    ),
                    if (package.gold > 0)
                      Text(
                        '赠送${package.gold}金币',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12.0,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8.0),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.amber,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, Package? selectedPackage, WidgetRef ref) {
    final userInfoState = ref.watch(userInfoStateProvider);
    final isLoggedIn = userInfoState.value != null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPackage != null
                      ? '总计：¥${selectedPackage.price.toStringAsFixed(2)}'
                      : '请选择套餐',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                if (selectedPackage != null && selectedPackage.gold > 0)
                  Text(
                    '赠送${selectedPackage.gold}金币',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12.0,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: selectedPackage == null || !isLoggedIn
                ? null
                : () {
                    // 导航到支付页面
                    context.push('/payment', extra: {
                      'package': selectedPackage,
                      'type': 'vip',
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('立即购买'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/payment_service.dart';
import '../../api/services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// 金币套餐状态提供者
final goldPackagesProvider = FutureProvider<List<Package>>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  // 获取金币套餐列表（type=2表示金币套餐）
  return await paymentService.getAllPackages(2);
});

// 选中套餐状态提供者
final selectedGoldPackageProvider = StateProvider<Package?>((ref) => null);

// 金币汇率状态提供者
final goldRateProvider = FutureProvider<double>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return await paymentService.getGoldRate();
});

class GoldBuyScreen extends ConsumerWidget {
  const GoldBuyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesState = ref.watch(goldPackagesProvider);
    final selectedPackage = ref.watch(selectedGoldPackageProvider);
    final goldInfoState = ref.watch(goldInfoStateProvider);
    final goldRateState = ref.watch(goldRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('购买金币'),
      ),
      body: Column(
        children: [
          // 金币余额
          goldInfoState.when(
            data: (goldInfo) => _buildGoldInfo(context, goldInfo, goldRateState),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildGoldInfo(context, null, goldRateState),
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

  Widget _buildGoldInfo(BuildContext context, GoldInfo? goldInfo, AsyncValue<double> goldRateState) {
    final int remainGold = goldInfo?.remainGold ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.amber.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '金币余额',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '$remainGold',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          goldRateState.when(
            data: (rate) => Text(
              '金币汇率：1元 = ${rate.toStringAsFixed(0)}金币',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Text(
              '金币汇率加载失败',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
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

    // 按价格排序
    packages.sort((a, b) => a.price.compareTo(b.price));

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final isSelected = ref.watch(selectedGoldPackageProvider) == package;

        return GestureDetector(
          onTap: () {
            ref.read(selectedGoldPackageProvider.notifier).state = package;
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.amber.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.grey[300]!,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${package.gold}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  '¥${package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
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
                if (selectedPackage != null)
                  Text(
                    '获得${selectedPackage.gold}金币',
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
                      'type': 'gold',
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/payment_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// 支付配置状态提供者
final payConfigStateProvider = FutureProvider<PayConfig>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return await paymentService.getPayConfig();
});

// 支付方式状态提供者
final selectedPaymentMethodProvider = StateProvider<String?>((ref) => null);

// 支付状态提供者
final paymentStatusProvider = StateProvider<AsyncValue<bool>>((ref) => const AsyncValue.data(false));

class PaymentScreen extends ConsumerWidget {
  final Package package;
  final String type; // 'vip' 或 'gold'

  const PaymentScreen({
    super.key,
    required this.package,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payConfigState = ref.watch(payConfigStateProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final paymentStatus = ref.watch(paymentStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('支付'),
      ),
      body: Column(
        children: [
          // 订单信息
          _buildOrderInfo(context),
          
          // 支付方式
          Expanded(
            child: payConfigState.when(
              data: (payConfig) => _buildPaymentMethods(context, payConfig, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('加载失败：$error'),
              ),
            ),
          ),
          
          // 底部支付按钮
          _buildBottomBar(context, selectedPaymentMethod, paymentStatus, ref),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '订单信息',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildOrderInfoItem('商品名称', package.name),
          const SizedBox(height: 8.0),
          _buildOrderInfoItem(
            '商品类型', 
            type == 'vip' ? 'VIP会员' : '金币充值',
          ),
          const SizedBox(height: 8.0),
          if (type == 'vip')
            _buildOrderInfoItem('有效期', '${package.days}天')
          else
            _buildOrderInfoItem('金币数量', '${package.gold}个'),
          const SizedBox(height: 8.0),
          _buildOrderInfoItem('支付金额', '¥${package.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildOrderInfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(BuildContext context, PayConfig payConfig, WidgetRef ref) {
    final List<Map<String, dynamic>> paymentMethods = [];
    
    if (payConfig.wechatEnabled) {
      paymentMethods.add({
        'id': 'wechat',
        'name': '微信支付',
        'icon': Icons.wechat,
        'color': Colors.green,
      });
    }
    
    if (payConfig.aliEnabled) {
      paymentMethods.add({
        'id': 'alipay',
        'name': '支付宝',
        'icon': Icons.account_balance_wallet,
        'color': Colors.blue,
      });
    }
    
    if (payConfig.appleEnabled) {
      paymentMethods.add({
        'id': 'apple',
        'name': 'Apple Pay',
        'icon': Icons.apple,
        'color': Colors.black,
      });
    }
    
    if (payConfig.googleEnabled) {
      paymentMethods.add({
        'id': 'google',
        'name': 'Google Pay',
        'icon': Icons.payment,
        'color': Colors.deepPurple,
      });
    }
    
    if (paymentMethods.isEmpty) {
      return const Center(
        child: Text('暂无可用支付方式'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        final method = paymentMethods[index];
        final isSelected = ref.watch(selectedPaymentMethodProvider) == method['id'];
        
        return GestureDetector(
          onTap: () {
            ref.read(selectedPaymentMethodProvider.notifier).state = method['id'];
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isSelected ? method['color'] : Colors.grey[300]!,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: method['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    method['icon'],
                    color: method['color'],
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                Text(
                  method['name'],
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: method['color'],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    String? selectedPaymentMethod,
    AsyncValue<bool> paymentStatus,
    WidgetRef ref,
  ) {
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
            child: Text(
              '应付金额：¥${package.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: selectedPaymentMethod == null || paymentStatus is AsyncLoading
                ? null
                : () async {
                    // 设置支付状态为加载中
                    ref.read(paymentStatusProvider.notifier).state = const AsyncValue.loading();
                    
                    try {
                      // 这里应该调用支付API
                      // 暂时模拟支付成功
                      await Future.delayed(const Duration(seconds: 2));
                      
                      // 支付成功
                      ref.read(paymentStatusProvider.notifier).state = const AsyncValue.data(true);
                      
                      // 刷新用户信息和金币信息
                      ref.refresh(userInfoStateProvider);
                      ref.refresh(goldInfoStateProvider);
                      
                      // 显示支付成功提示
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('支付成功'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        
                        // 返回上一页
                        context.pop();
                      }
                    } catch (e) {
                      // 支付失败
                      ref.read(paymentStatusProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
                      
                      // 显示支付失败提示
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('支付失败：$e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: paymentStatus is AsyncLoading
                ? const SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text('立即支付'),
          ),
        ],
      ),
    );
  }
} 
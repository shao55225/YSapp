import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';

// 支付配置提供者
final payConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getPayConfig();
  return result ?? {};
});

class PaymentPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> packageInfo;

  const PaymentPage({Key? key, required this.packageInfo}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  String? _orderId;
  Map<String, dynamic>? _paymentResult;

  @override
  Widget build(BuildContext context) {
    final payConfigAsync = ref.watch(payConfigProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单支付'),
      ),
      body: Stack(
        children: [
          payConfigAsync.when(
            data: (payConfig) {
              // 从支付配置中获取可用的支付方式
              final List<dynamic> payMethods = payConfig['methods'] ?? [];
              
              if (payMethods.isEmpty) {
                return const Center(
                  child: Text('暂无可用支付方式', style: TextStyle(color: Colors.grey)),
                );
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 订单信息卡片
                    _buildOrderInfoCard(),
                    
                    const SizedBox(height: 24),
                    
                    // 支付方式选择标题
                    const Text(
                      '选择支付方式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 支付方式列表
                    ...payMethods.map((method) => _buildPaymentMethodItem(method)).toList(),
                    
                    const SizedBox(height: 32),
                    
                    // 支付按钮
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectedPaymentMethod != null && !_isProcessing
                            ? () => _processPayment(payConfig)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          '确认支付 ¥${widget.packageInfo['price'] ?? 0.0}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 支付提示
                    const Center(
                      child: Text(
                        '支付即代表您同意《购买协议》',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('加载支付配置失败: $error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(payConfigProvider),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
          
          // 处理中遮罩
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('订单处理中，请稍候...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建订单信息卡片
  Widget _buildOrderInfoCard() {
    final packageId = widget.packageInfo['packageId'] ?? 0;
    final packageName = widget.packageInfo['packageName'] ?? '未知套餐';
    final price = widget.packageInfo['price'] ?? 0.0;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '订单信息',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(height: 24),
            _buildOrderInfoRow('商品名称', packageName),
            const SizedBox(height: 8),
            _buildOrderInfoRow('商品价格', '¥$price'),
            const SizedBox(height: 8),
            _buildOrderInfoRow('订单编号', _orderId ?? '待生成'),
            const SizedBox(height: 8),
            _buildOrderInfoRow('订单状态', _orderId != null ? '已创建' : '未创建'),
          ],
        ),
      ),
    );
  }
  
  // 构建订单信息行
  Widget _buildOrderInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  // 构建支付方式选项
  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final String id = method['id'] ?? '';
    final String name = method['name'] ?? '未知支付方式';
    final String? icon = method['icon'];
    final bool enabled = method['enabled'] ?? false;
    
    // 如果支付方式未启用，不显示
    if (!enabled) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedPaymentMethod == id
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // 支付图标
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: icon != null && icon.isNotEmpty
                    ? Image.network(
                        icon,
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.payment,
                          color: Colors.grey[400],
                        ),
                      )
                    : Icon(
                        Icons.payment,
                        color: Colors.grey[400],
                      ),
              ),
              const SizedBox(width: 16),
              
              // 支付名称
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              
              // 选择标记
              if (_selectedPaymentMethod == id)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 处理支付
  Future<void> _processPayment(Map<String, dynamic> payConfig) async {
    if (_selectedPaymentMethod == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // 创建订单
      final orderResult = await apiService.createOrder(
        packageId: widget.packageInfo['packageId'],
        payMethod: _selectedPaymentMethod!,
      );
      
      _orderId = orderResult['orderId'];
      _paymentResult = orderResult;
      
      // 导航到支付结果页面
      context.push('/payment/result', extra: {
        'orderId': _orderId,
        'paymentMethod': _selectedPaymentMethod,
        'paymentResult': _paymentResult,
        'packageInfo': widget.packageInfo,
      });
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建订单失败: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

// 订单列表Provider
final ordersProvider = FutureProvider.autoDispose.family<List<dynamic>, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getOrders(page: page);
  return result['records'] ?? [];
});

// 总页数Provider
final totalPagesProvider = StateProvider<int>((ref) => 1);

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  int _currentPage = 1;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    final ordersAsyncValue = ref.watch(ordersProvider(_currentPage));
    final totalPages = ref.watch(totalPagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
      ),
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无订单记录', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(ordersProvider(_currentPage));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderItem(order);
                    },
                  ),
                ),
              ),
              
              // 分页控制器
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1 
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.navigate_before),
                      ),
                      Text('$_currentPage / $totalPages'),
                      IconButton(
                        onPressed: _currentPage < totalPages 
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.navigate_next),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: '加载订单失败: $error',
          onRetry: () => ref.refresh(ordersProvider(_currentPage)),
        ),
      ),
    );
  }

  // 构建订单项
  Widget _buildOrderItem(Map<String, dynamic> order) {
    // 提取订单信息
    final String orderId = order['orderId'] ?? '';
    final String orderNo = order['orderNo'] ?? '';
    final String productName = order['productName'] ?? '未知商品';
    final double orderAmount = (order['orderAmount'] ?? 0.0).toDouble();
    final int payStatus = order['payStatus'] ?? 0;
    final String payMethod = order['payMethod'] ?? '';
    final String? createTime = order['createTime'];
    
    // 格式化时间
    final String formattedTime = createTime != null 
        ? _dateFormat.format(DateTime.parse(createTime))
        : '未知时间';
    
    // 订单状态
    final String status = _getOrderStatus(payStatus);
    final Color statusColor = _getStatusColor(payStatus);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onOrderTap(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单头部
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '订单号: $orderNo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // 商品信息
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '¥$orderAmount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 支付方式和时间
              Row(
                children: [
                  Text(
                    '支付方式: $_getPayMethodName(payMethod)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              // 待支付订单添加操作按钮
              if (payStatus == 0) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _cancelOrder(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('取消订单'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _continuePayment(order),
                      child: const Text('继续支付'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // 获取订单状态文本
  String _getOrderStatus(int payStatus) {
    switch (payStatus) {
      case 1: return '已支付';
      case 2: return '已关闭';
      case 3: return '已退款';
      default: return '待支付';
    }
  }
  
  // 获取状态颜色
  Color _getStatusColor(int payStatus) {
    switch (payStatus) {
      case 1: return Colors.green;
      case 2: return Colors.grey;
      case 3: return Colors.orange;
      default: return Colors.blue;
    }
  }
  
  // 获取支付方式名称
  String _getPayMethodName(String payMethod) {
    switch (payMethod) {
      case 'alipay': return '支付宝';
      case 'wechat': return '微信支付';
      case 'alipay_wap': return '支付宝(手机)';
      case 'wechat_wap': return '微信支付(手机)';
      default: return payMethod;
    }
  }
  
  // 处理订单点击
  void _onOrderTap(Map<String, dynamic> order) {
    // 跳转到订单详情页
    context.push('/payment/order-detail', extra: order);
  }
  
  // 继续支付
  void _continuePayment(Map<String, dynamic> order) {
    // 跳转到支付页面
    context.push('/payment/continue', extra: {
      'orderId': order['orderId'],
      'orderNo': order['orderNo'],
      'productName': order['productName'],
      'orderAmount': order['orderAmount'],
    });
  }
  
  // 取消订单
  Future<void> _cancelOrder(Map<String, dynamic> order) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取消'),
        content: const Text('确定要取消该订单吗？取消后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('返回'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认取消', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.cancelOrder(order['orderId']);
        
        // 刷新订单列表
        ref.refresh(ordersProvider(_currentPage));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('订单已取消')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消订单失败: $e')),
        );
      }
    }
  }
} 
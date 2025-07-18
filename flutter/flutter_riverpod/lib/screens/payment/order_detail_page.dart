import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../api/services/api_service.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> orderInfo;

  const OrderDetailPage({Key? key, required this.orderInfo}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    // 提取订单信息
    final String orderId = widget.orderInfo['orderId'] ?? '';
    final String orderNo = widget.orderInfo['orderNo'] ?? '';
    final String productName = widget.orderInfo['productName'] ?? '未知商品';
    final double orderAmount = (widget.orderInfo['orderAmount'] ?? 0.0).toDouble();
    final int payStatus = widget.orderInfo['payStatus'] ?? 0;
    final String payMethod = widget.orderInfo['payMethod'] ?? '';
    final String? createTime = widget.orderInfo['createTime'];
    final String? payTime = widget.orderInfo['payTime'];
    
    // 格式化时间
    final String formattedCreateTime = createTime != null 
        ? _dateFormat.format(DateTime.parse(createTime))
        : '未知时间';
    
    final String? formattedPayTime = payTime != null 
        ? _dateFormat.format(DateTime.parse(payTime))
        : null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 状态卡片
                _buildStatusCard(payStatus),
                
                const SizedBox(height: 16),
                
                // 订单详情卡片
                Card(
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('商品名称', productName),
                        _buildInfoRow('订单金额', '¥$orderAmount'),
                        _buildInfoRow('订单编号', orderNo),
                        _buildInfoRow('支付方式', _getPayMethodName(payMethod)),
                        _buildInfoRow('创建时间', formattedCreateTime),
                        if (formattedPayTime != null)
                          _buildInfoRow('支付时间', formattedPayTime),
                      ],
                    ),
                  ),
                ),
                
                // 待支付订单操作按钮
                if (payStatus == 0) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _continuePayment(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('继续支付', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _cancelOrder(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('取消订单', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
                
                // 订单号复制提示
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () => _copyOrderNo(orderNo),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '点击复制订单号',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 底部空白，防止内容被遮挡
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建状态卡片
  Widget _buildStatusCard(int payStatus) {
    String statusText;
    IconData statusIcon;
    Color statusColor;
    String statusDescription;
    
    switch (payStatus) {
      case 1:
        statusText = '支付成功';
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusDescription = '您的订单已支付成功';
        break;
      case 2:
        statusText = '订单已关闭';
        statusIcon = Icons.cancel;
        statusColor = Colors.grey;
        statusDescription = '该订单已关闭';
        break;
      case 3:
        statusText = '已退款';
        statusIcon = Icons.assignment_return;
        statusColor = Colors.orange;
        statusDescription = '订单已退款';
        break;
      default:
        statusText = '等待支付';
        statusIcon = Icons.pending;
        statusColor = Colors.blue;
        statusDescription = '请尽快完成支付，以免订单过期';
        break;
    }
    
    return Card(
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              statusIcon,
              size: 40,
              color: statusColor,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 获取支付方式名称
  String _getPayMethodName(String payMethod) {
    switch (payMethod) {
      case 'alipay': return '支付宝';
      case 'wechat': return '微信支付';
      case 'alipay_wap': return '支付宝(手机)';
      case 'wechat_wap': return '微信支付(手机)';
      default: return payMethod.isEmpty ? '未选择' : payMethod;
    }
  }
  
  // 复制订单号
  void _copyOrderNo(String orderNo) {
    Clipboard.setData(ClipboardData(text: orderNo)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('订单号已复制到剪贴板')),
      );
    });
  }
  
  // 继续支付
  void _continuePayment() {
    // 跳转到支付页面
    context.push('/payment/continue', extra: widget.orderInfo);
  }
  
  // 取消订单
  Future<void> _cancelOrder() async {
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
      setState(() {
        _isLoading = true;
      });
      
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.cancelOrder(widget.orderInfo['orderId']);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('订单已取消')),
        );
        
        // 返回订单列表页
        Navigator.of(context).pop(true); // 带上true表示刷新订单列表
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消订单失败: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 
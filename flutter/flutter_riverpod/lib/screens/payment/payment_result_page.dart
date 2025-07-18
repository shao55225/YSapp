import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../theme/app_colors.dart';

// 支付状态轮询间隔（秒）
const int _pollInterval = 5;

class PaymentResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> paymentInfo;

  const PaymentResultPage({Key? key, required this.paymentInfo}) : super(key: key);

  @override
  _PaymentResultPageState createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends ConsumerState<PaymentResultPage> {
  bool _isLoading = false;
  bool _isPaid = false;
  String _payStatus = 'pending'; // pending, success, failed
  Timer? _pollTimer;
  int _pollingCount = 0;
  int _remainingTime = 900; // 15分钟
  Timer? _countdownTimer;
  String? _payUrl;
  String? _qrCodeUrl;
  
  @override
  void initState() {
    super.initState();
    _initializePayment();
    _startCountdown();
    
    // 如果有支付链接，开始轮询支付状态
    if (_payUrl != null) {
      _startPolling();
    }
  }
  
  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  // 初始化支付信息
  void _initializePayment() {
    final paymentResult = widget.paymentInfo['paymentResult'];
    final paymentMethod = widget.paymentInfo['paymentMethod'];
    
    if (paymentResult != null) {
      // 提取支付URL
      _payUrl = paymentResult['payUrl'] as String?;
      _qrCodeUrl = paymentResult['qrCode'] as String?;
      
      // 尝试打开支付链接（如果是移动设备支付，如支付宝或微信）
      if (_payUrl != null && (paymentMethod == 'alipay_wap' || paymentMethod == 'wechat_wap')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _launchPaymentApp(_payUrl!);
        });
      }
    }
  }
  
  // 启动倒计时
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }
  
  // 启动轮询支付状态
  void _startPolling() {
    // 最多轮询30次，即2.5分钟
    const maxPollingCount = 30;
    
    _pollTimer = Timer.periodic(
      const Duration(seconds: _pollInterval), 
      (timer) async {
        _pollingCount++;
        
        if (_pollingCount > maxPollingCount || _isPaid) {
          timer.cancel();
          return;
        }
        
        await _checkPaymentStatus();
      },
    );
  }
  
  // 检查支付状态
  Future<void> _checkPaymentStatus() async {
    final orderId = widget.paymentInfo['orderId'];
    if (orderId == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.checkOrderPayStatus(orderId);
      
      setState(() {
        _isPaid = result['isPaid'] ?? false;
        _payStatus = _isPaid ? 'success' : 'pending';
        _isLoading = false;
      });
      
      if (_isPaid) {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        
        // 延迟导航到会员中心
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/profile');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('查询支付状态失败: $e')),
      );
    }
  }
  
  // 格式化倒计时
  String _formatCountdown() {
    final minutes = (_remainingTime / 60).floor();
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 打开支付应用
  Future<void> _launchPaymentApp(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开支付应用，请手动打开支付宝或微信完成支付')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmDialog() ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('支付结果'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              
              // 支付状态图标
              _buildStatusIcon(),
              
              const SizedBox(height: 16),
              
              // 支付状态文本
              Text(
                _getStatusText(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // 订单金额
              Text(
                '订单金额: ¥${widget.paymentInfo['packageInfo']?['price'] ?? 0.0}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 订单号
              Text(
                '订单编号: ${widget.paymentInfo['orderId'] ?? '未知'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 待支付状态显示二维码和倒计时
              if (_payStatus == 'pending' && _qrCodeUrl != null) ...[
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _qrCodeUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('二维码加载失败'),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  '请使用支付宝或微信扫码支付',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '订单将在 ${_formatCountdown()} 后自动关闭',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 13,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (_payUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => _launchPaymentApp(_payUrl!),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('打开支付页面'),
                  ),
                  
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkPaymentStatus,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('我已完成支付'),
                ),
              ],
              
              // 支付成功状态
              if (_payStatus == 'success') ...[
                const SizedBox(height: 24),
                
                Text(
                  '您已成功购买 ${widget.paymentInfo['packageInfo']?['packageName'] ?? '会员套餐'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('返回个人中心'),
                ),
              ],
              
              // 支付失败状态
              if (_payStatus == 'failed') ...[
                const SizedBox(height: 24),
                
                const Text(
                  '支付未完成，您可以稍后在订单列表中继续支付',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go('/payment/orders'),
                      child: const Text('查看订单'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/profile'),
                      child: const Text('返回个人中心'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: _payStatus == 'pending'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => _showExitConfirmDialog(),
                  child: const Text('稍后支付'),
                ),
              ),
            )
          : null,
      ),
    );
  }
  
  // 构建状态图标
  Widget _buildStatusIcon() {
    switch (_payStatus) {
      case 'success':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 48,
          ),
        );
      case 'failed':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 48,
          ),
        );
      default: // pending
        return _isLoading
            ? const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(),
              )
            : Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  color: Colors.white,
                  size: 48,
                ),
              );
    }
  }
  
  // 获取状态文本
  String _getStatusText() {
    switch (_payStatus) {
      case 'success':
        return '支付成功';
      case 'failed':
        return '支付失败';
      default: // pending
        return '等待支付';
    }
  }
  
  // 显示退出确认对话框
  Future<bool?> _showExitConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认离开'),
        content: const Text('您尚未完成支付，确定要离开吗？您可以稍后在订单列表中继续支付。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              context.go('/payment/orders');
            },
            child: const Text('查看订单'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              context.go('/profile');
            },
            child: const Text('返回个人中心'),
          ),
        ],
      ),
    );
  }
} 
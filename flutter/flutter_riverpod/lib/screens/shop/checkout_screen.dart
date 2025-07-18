import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models/shop_models.dart';
import '../../api/services/shop_service.dart';
import '../../api/services/payment_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../utils/format_util.dart';

// 结算页面参数
class CheckoutArgs {
  final List<CartItem>? cartItems;
  final String? productId;
  final int? quantity;

  CheckoutArgs({
    this.cartItems,
    this.productId,
    this.quantity,
  });
}

class CheckoutScreen extends ConsumerStatefulWidget {
  final CheckoutArgs args;

  const CheckoutScreen({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;
  String? _selectedAddressId;
  String _remark = '';
  String _paymentMethod = 'balance'; // 默认使用余额支付
  
  // 计算商品总价
  double _calculateTotalPrice(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      if (item.productPrice != null) {
        total += item.productPrice! * item.quantity;
      }
    }
    return total;
  }
  
  // 计算商品总金币数
  int _calculateTotalGold(List<CartItem> items) {
    int total = 0;
    for (var item in items) {
      if (item.productGoldPrice != null) {
        total += item.productGoldPrice! * item.quantity;
      }
    }
    return total;
  }
  
  // 提交订单
  Future<void> _submitOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择收货地址')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final shopService = ref.read(shopServiceProvider);
      final orderNo = await shopService.createOrder(
        cartItems: _getCartItems(),
        addressId: _selectedAddressId!,
        remarks: _remark.isNotEmpty ? _remark : null,
      );
      
      if (orderNo.isNotEmpty) {
        // 订单创建成功，刷新购物车数据
        ref.refresh(cartProvider);
        
        // 跳转到支付页面
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/payment',
            arguments: {
              'orderNo': orderNo,
              'paymentMethod': _paymentMethod,
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('创建订单失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建订单失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // 获取购物车商品列表
  List<CartItem> _getCartItems() {
    if (widget.args.cartItems != null) {
      return widget.args.cartItems!;
    } else if (widget.args.productId != null && widget.args.quantity != null) {
      // 如果是直接购买，需要创建一个临时的CartItem
      return [
        CartItem(
          id: 0, // 临时ID
          userId: 0,
          productId: int.parse(widget.args.productId!),
          quantity: widget.args.quantity!,
        ),
      ];
    }
    return [];
  }
  
  // 选择收货地址
  void _selectAddress() {
    // TODO: 实现选择地址的页面跳转
    // 暂时使用默认地址
    setState(() {
      _selectedAddressId = '1';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已选择默认地址')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _getCartItems();
    
    // 检查是否有商品
    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('结算'),
        ),
        body: const Center(
          child: Text('无法结算，未选择商品'),
        ),
      );
    }

    // 直接购买时需要获取商品详情
    if (widget.args.productId != null) {
      final productAsync = ref.watch(productDetailProvider(widget.args.productId!));
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('结算'),
        ),
        body: productAsync.when(
          data: (product) {
            // 创建一个带有商品信息的CartItem
            final item = CartItem(
              id: 0,
              userId: 0,
              productId: product.id,
              quantity: widget.args.quantity!,
              productName: product.name,
              productImage: product.imageUrl,
              productPrice: product.price,
              productGoldPrice: product.goldPrice,
            );
            
            return _buildCheckoutContent([item]);
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => ErrorView(
            error: error.toString(),
            onRetry: () => ref.refresh(productDetailProvider(widget.args.productId!)),
          ),
        ),
      );
    }

    // 从购物车结算
    return Scaffold(
      appBar: AppBar(
        title: const Text('结算'),
      ),
      body: _buildCheckoutContent(cartItems),
    );
  }

  Widget _buildCheckoutContent(List<CartItem> items) {
    final totalPrice = _calculateTotalPrice(items);
    final totalGold = _calculateTotalGold(items);

    return Stack(
      children: [
        // 内容区域
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 收货地址
              _buildAddressSection(),
              
              const SizedBox(height: 8),
              
              // 商品列表
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '商品信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...items.map((item) => _buildCartItemTile(item)),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 备注
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '备注',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: '选填，请填写备注信息',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          _remark = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 支付方式
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '支付方式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodTile(
                      title: '余额支付',
                      subtitle: '使用账户余额支付',
                      icon: Icons.account_balance_wallet,
                      value: 'balance',
                    ),
                    const Divider(),
                    _buildPaymentMethodTile(
                      title: '金币支付',
                      subtitle: '使用账户金币支付',
                      icon: Icons.monetization_on,
                      value: 'gold',
                    ),
                    const Divider(),
                    _buildPaymentMethodTile(
                      title: '微信支付',
                      subtitle: '使用微信支付',
                      icon: Icons.public,
                      value: 'wechat',
                    ),
                    const Divider(),
                    _buildPaymentMethodTile(
                      title: '支付宝支付',
                      subtitle: '使用支付宝支付',
                      icon: Icons.payment,
                      value: 'alipay',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 价格明细
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '价格明细',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('商品总价'),
                        Text('¥${FormatUtil.formatPrice(totalPrice)}'),
                      ],
                    ),
                    if (totalGold > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('金币总数'),
                          Text('$totalGold金币'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('运费'),
                        const Text('¥0.00'),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '实付款',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '¥${FormatUtil.formatPrice(totalPrice)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 底部占位，避免被按钮挡住
              const SizedBox(height: 80),
            ],
          ),
        ),
        
        // 底部提交订单按钮
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('实付款'),
                    Text(
                      '¥${FormatUtil.formatPrice(totalPrice)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '提交订单',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
        
        // 全屏加载
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: _selectedAddressId != null
          ? _buildAddressCard()
          : _buildAddressSelector(),
    );
  }
  
  Widget _buildAddressCard() {
    // TODO: 从API获取地址详情
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    '张三',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('13800138000'),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '广东省深圳市南山区科技园南区8栋101室',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _selectAddress,
        ),
      ],
    );
  }
  
  Widget _buildAddressSelector() {
    return InkWell(
      onTap: _selectAddress,
      child: Row(
        children: const [
          Icon(Icons.add_location, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              '请选择收货地址',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }
  
  Widget _buildCartItemTile(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.productImage != null
                  ? Image.network(
                      item.productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? '未知商品',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.productPrice != null)
                      Text(
                        '¥${FormatUtil.formatPrice(item.productPrice!)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const Spacer(),
                    Text('x${item.quantity}'),
                  ],
                ),
                if (item.productGoldPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.productGoldPrice}金币',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _paymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _paymentMethod = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 
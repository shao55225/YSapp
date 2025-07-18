import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models/shop_models.dart';
import '../../api/services/shop_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../utils/format_util.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Set<int> _selectedItemIds = {};
  bool _isAllSelected = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // 刷新购物车数据
    ref.refresh(cartProvider);
  }
  
  // 计算选中商品总价
  double _calculateTotalPrice(List<CartItem> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      if (_selectedItemIds.contains(item.id) && item.productPrice != null) {
        total += item.productPrice! * item.quantity;
      }
    }
    return total;
  }
  
  // 计算选中商品金币总数
  int _calculateTotalGold(List<CartItem> cartItems) {
    int total = 0;
    for (var item in cartItems) {
      if (_selectedItemIds.contains(item.id) && item.productGoldPrice != null) {
        total += item.productGoldPrice! * item.quantity;
      }
    }
    return total;
  }
  
  // 全选/取消全选
  void _toggleSelectAll(List<CartItem> cartItems) {
    setState(() {
      if (_isAllSelected) {
        _selectedItemIds = {};
      } else {
        _selectedItemIds = cartItems.map((e) => e.id).toSet();
      }
      _isAllSelected = !_isAllSelected;
    });
  }
  
  // 选择/取消选择单个商品
  void _toggleSelectItem(int itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }
  
  // 更新商品数量
  Future<void> _updateItemQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;
    
    setState(() => _isLoading = true);
    
    try {
      final shopService = ref.read(shopServiceProvider);
      final result = await shopService.updateCartItem(item.id.toString(), newQuantity);
      
      if (result) {
        // 更新成功，刷新购物车数据
        ref.refresh(cartProvider);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('更新数量失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新数量失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // 删除商品
  Future<void> _deleteCartItem(CartItem item) async {
    setState(() => _isLoading = true);
    
    try {
      final shopService = ref.read(shopServiceProvider);
      final result = await shopService.deleteCartItem(item.id.toString());
      
      if (result) {
        // 删除成功，刷新购物车数据并移除选择状态
        setState(() {
          _selectedItemIds.remove(item.id);
        });
        ref.refresh(cartProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已从购物车移除')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // 结算
  void _proceedToCheckout(List<CartItem> selectedItems) {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择商品')),
      );
      return;
    }
    
    // 跳转到结算页面
    Navigator.of(context).pushNamed('/shop/checkout', arguments: {
      'cartItems': selectedItems,
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
      ),
      body: cartAsync.when(
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return _buildEmptyCart();
          }
          
          final selectedItems = cartItems
              .where((item) => _selectedItemIds.contains(item.id))
              .toList();
          
          return Stack(
            children: [
              // 购物车列表
              ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  // 全选按钮
                  _buildSelectAllRow(cartItems),
                  
                  // 购物车商品列表
                  ...cartItems.map((item) => _buildCartItem(item)),
                ],
              ),
              
              // 底部结算栏
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCheckoutBar(cartItems, selectedItems),
              ),
              
              // 加载指示器
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(cartProvider),
        ),
      ),
    );
  }
  
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '购物车空空如也',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('去选购'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectAllRow(List<CartItem> cartItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _toggleSelectAll(cartItems),
            child: Row(
              children: [
                Icon(
                  _isAllSelected
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: _isAllSelected ? Theme.of(context).primaryColor : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text('全选'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItem(CartItem item) {
    final bool isSelected = _selectedItemIds.contains(item.id);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 选择按钮
          InkWell(
            onTap: () => _toggleSelectItem(item.id),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 24,
              ),
            ),
          ),
          
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
                    if (item.productGoldPrice != null)
                      Container(
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // 数量调整
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _updateItemQuantity(item, item.quantity - 1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              width: 28,
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          InkWell(
                            onTap: () => _updateItemQuantity(item, item.quantity + 1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              width: 28,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // 删除按钮
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.grey,
                      onPressed: () => _deleteCartItem(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckoutBar(List<CartItem> cartItems, List<CartItem> selectedItems) {
    final totalPrice = _calculateTotalPrice(cartItems);
    final totalGold = _calculateTotalGold(cartItems);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 价格信息
          Row(
            children: [
              const Text('合计:'),
              const SizedBox(width: 4),
              Text(
                '¥${FormatUtil.formatPrice(totalPrice)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (totalGold > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '($totalGold金币)',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '已选${selectedItems.length}件',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 结算按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedItems.isEmpty
                  ? null
                  : () => _proceedToCheckout(selectedItems),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                '去结算',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
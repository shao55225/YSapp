import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../api/models/shop_models.dart';
import '../../api/services/shop_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../utils/format_util.dart';
import '../../theme/app_colors.dart';

// 商品详情提供者
final productDetailProvider = FutureProvider.family<Product, String>((ref, productId) async {
  final shopService = ref.read(shopServiceProvider);
  return await shopService.getProductDetail(productId);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  void _incrementQuantity(int stock) {
    if (_quantity < stock) {
      setState(() {
        _quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已达到最大库存')),
      );
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final shopService = ref.read(shopServiceProvider);
      final result = await shopService.addToCart(widget.productId, _quantity);
      
      if (mounted) {
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已添加到购物车')),
          );
          
          // 刷新购物车数据
          ref.refresh(cartProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('添加购物车失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加购物车失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _buyNow() async {
    // 直接跳转到结算页面
    Navigator.of(context).pushNamed('/shop/checkout', arguments: {
      'productId': widget.productId,
      'quantity': _quantity,
    });
  }

  @override
  Widget build(BuildContext context) {
    final productDetailAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/shop/cart');
            },
          ),
        ],
      ),
      body: productDetailAsync.when(
        data: (product) => _buildProductDetail(context, product),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(productDetailProvider(widget.productId)),
        ),
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, Product product) {
    return Stack(
      children: [
        // 内容区域
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品图片
              _buildProductImages(product),

              // 价格和名称
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '¥${FormatUtil.formatPrice(product.price)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '${product.goldPrice}金币',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '库存: ${product.stock}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 商品描述
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '商品详情',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      product.description ?? '暂无详情描述',
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 详情图片
              if (product.detailImages != null && product.detailImages!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: Text(
                        '商品展示',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...product.detailImages!.map((imageUrl) => Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        )),
                  ],
                ),

              // 底部占位，避免被按钮挡住
              const SizedBox(height: 80.0),
            ],
          ),
        ),

        // 底部操作栏
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              children: [
                // 数量选择
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18.0),
                        onPressed: _decrementQuantity,
                        constraints: const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                      ),
                      SizedBox(
                        width: 40.0,
                        child: Center(
                          child: Text(
                            _quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18.0),
                        onPressed: () => _incrementQuantity(product.stock),
                        constraints: const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),

                // 加入购物车按钮
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAddingToCart ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('加入购物车'),
                  ),
                ),
                const SizedBox(width: 16.0),

                // 立即购买按钮
                Expanded(
                  child: ElevatedButton(
                    onPressed: _buyNow,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('立即购买'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImages(Product product) {
    final List<String> imageUrls = [];
    
    if (product.imageUrl != null) {
      imageUrls.add(product.imageUrl!);
    }
    
    if (product.detailImages != null && product.detailImages!.isNotEmpty) {
      imageUrls.addAll(product.detailImages!.take(3)); // 最多展示前3张详情图
    }
    
    // 如果没有图片，显示占位图
    if (imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
        ),
      );
    }
    
    // 如果只有一张图片，直接显示
    if (imageUrls.length == 1) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: Image.network(
          imageUrls.first,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
          ),
        ),
      );
    }
    
    // 如果有多张图片，使用轮播
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 1.0,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        pauseAutoPlayOnTouch: true,
        enableInfiniteScroll: true,
      ),
      items: imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              ),
            );
          },
        );
      }).toList(),
    );
  }
} 
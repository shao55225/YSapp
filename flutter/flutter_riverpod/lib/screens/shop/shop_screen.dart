import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models/shop_models.dart';
import '../../api/services/shop_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'product_detail_screen.dart';
import 'widgets/category_tabs.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  int? _selectedCategoryId;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听器，用于实现加载更多
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final productList = ref.read(productListProvider(
        ProductListParams(
          page: _currentPage,
          categoryId: _selectedCategoryId,
          keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ));

      if (productList.value != null && !productList.isLoading) {
        final response = productList.value!;
        if (_currentPage < response.totalPages) {
          setState(() {
            _currentPage++;
          });
        }
      }
    }
  }

  // 选择分类
  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _currentPage = 1;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  // 搜索商品
  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  // 开始/取消搜索
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  // 导航到商品详情页
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final productListAsync = ref.watch(productListProvider(
      ProductListParams(
        page: _currentPage,
        categoryId: _selectedCategoryId,
        keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    ));

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 分类栏
          categoriesAsync.when(
            data: (categories) => categories.isNotEmpty
                ? CategoryTabs(
                    categories: categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: LinearProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 商品列表
          Expanded(
            child: productListAsync.when(
              data: (productList) {
                if (productList.products.isEmpty) {
                  return _buildEmptyView();
                }
                
                return _buildProductGrid(productList.products);
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, _) => ErrorView(
                error: error.toString(),
                onRetry: () => ref.refresh(productListProvider(
                  ProductListParams(
                    page: _currentPage,
                    categoryId: _selectedCategoryId,
                    keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/shop/cart'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  // 构建 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '搜索商品',
                border: InputBorder.none,
              ),
              onSubmitted: _searchProducts,
            )
          : const Text('商城'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/shop/cart'),
        ),
      ],
    );
  }

  // 构建商品网格
  Widget _buildProductGrid(List<Product> products) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
        });
        ref.refresh(productListProvider(
          ProductListParams(
            page: _currentPage,
            categoryId: _selectedCategoryId,
            keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
        ));
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  // 构建商品卡片
  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () => _navigateToProductDetail(product),
      borderRadius: BorderRadius.circular(8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
            ),
            
            // 商品信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '¥${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (product.goldPrice > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '${product.goldPrice}金币',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建空视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? '未找到相关商品'
                : '该分类暂无商品',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _isSearching = false;
                });
              },
              child: const Text('清除搜索'),
            ),
          ],
        ],
      ),
    );
  }
} 
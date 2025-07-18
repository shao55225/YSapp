import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../../constants/api_constants.dart';
import '../models/shop_models.dart';

// 商城服务提供者
final shopServiceProvider = Provider<ShopService>((ref) {
  final dio = Dio();
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggingInterceptor());
  return ShopService(dio);
});

// 商品分类提供者
final productCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.getCategories();
});

// 商品列表提供者
final productListProvider = FutureProvider.family<ProductListResponse, ProductListParams>((ref, params) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.getProducts(
    page: params.page,
    categoryId: params.categoryId,
    keyword: params.keyword,
  );
});

// 购物车提供者
final cartProvider = FutureProvider<List<CartItem>>((ref) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.getCartItems();
});

class ProductListParams {
  final int page;
  final int? categoryId;
  final String? keyword;
  
  const ProductListParams({
    required this.page,
    this.categoryId,
    this.keyword,
  });
}

class ShopService {
  final Dio _dio;
  
  ShopService(this._dio);
  
  // 获取商品分类
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopCategories}'
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => ProductCategory.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      throw _handleError('获取分类失败', e);
    }
  }
  
  // 获取商品列表
  Future<ProductListResponse> getProducts({
    required int page,
    int? categoryId,
    String? keyword,
    int pageSize = 10,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'size': pageSize,
      };
      
      if (categoryId != null) {
        params['categoryId'] = categoryId;
      }
      
      if (keyword != null && keyword.isNotEmpty) {
        params['keyword'] = keyword;
      }
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopProducts}',
        queryParameters: params,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        return ProductListResponse.fromJson(data);
      }
      
      return ProductListResponse(
        products: [],
        total: 0,
        currentPage: page,
        totalPages: 1,
      );
    } catch (e) {
      throw _handleError('获取商品列表失败', e);
    }
  }
  
  // 获取商品详情
  Future<Product> getProductDetail(String productId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopProductDetail}$productId'
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return Product.fromJson(response.data['data']);
      }
      
      throw Exception('商品不存在');
    } catch (e) {
      throw _handleError('获取商品详情失败', e);
    }
  }
  
  // 获取购物车
  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopCart}'
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => CartItem.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      throw _handleError('获取购物车失败', e);
    }
  }
  
  // 添加商品到购物车
  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.shopCartAdd}',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError('添加到购物车失败', e);
    }
  }
  
  // 更新购物车商品数量
  Future<bool> updateCartItem(String cartItemId, int quantity) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.shopCartUpdate}',
        data: {
          'id': cartItemId,
          'quantity': quantity,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError('更新购物车失败', e);
    }
  }
  
  // 删除购物车商品
  Future<bool> deleteCartItem(String cartItemId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.shopCartDelete}',
        data: {
          'id': cartItemId,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError('删除购物车商品失败', e);
    }
  }
  
  // 创建订单
  Future<String> createOrder({
    required List<CartItem> cartItems,
    required String addressId,
    String? remarks,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.shopOrderCreate}',
        data: {
          'cartItems': cartItems.map((item) => item.toJson()).toList(),
          'addressId': addressId,
          'remarks': remarks,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']['orderNo'] ?? '';
      }
      
      throw Exception('创建订单失败');
    } catch (e) {
      throw _handleError('创建订单失败', e);
    }
  }
  
  // 获取订单列表
  Future<OrderListResponse> getOrders(int page, {int pageSize = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopOrderList}',
        queryParameters: {
          'page': page,
          'size': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        return OrderListResponse.fromJson(data);
      }
      
      return OrderListResponse(
        orders: [],
        total: 0,
        currentPage: page,
        totalPages: 1,
      );
    } catch (e) {
      throw _handleError('获取订单列表失败', e);
    }
  }
  
  // 获取订单详情
  Future<Order> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopOrderDetail}$orderId'
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return Order.fromJson(response.data['data']);
      }
      
      throw Exception('订单不存在');
    } catch (e) {
      throw _handleError('获取订单详情失败', e);
    }
  }
  
  // 取消订单
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.shopOrderCancel}$orderId'
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError('取消订单失败', e);
    }
  }
  
  // 错误处理
  Exception _handleError(String message, dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return Exception('$message: ${data['message']}');
        }
      }
      return Exception('$message: ${error.message}');
    }
    return Exception('$message: $error');
  }
} 
// 商品分类模型
class ProductCategory {
  final int id;
  final String name;
  final String? icon;
  final int sortOrder;
  final int status; // 0-禁用, 1-启用

  ProductCategory({
    required this.id,
    required this.name,
    this.icon,
    required this.sortOrder,
    required this.status,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      sortOrder: json['sortOrder'] ?? 0,
      status: json['status'] ?? 1,
    );
  }
}

// 商品模型
class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int goldPrice;
  final int stock;
  final int categoryId;
  final String? imageUrl;
  final List<String>? detailImages;
  final int status; // 0-下架, 1-上架

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.goldPrice,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
    this.detailImages,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String>? detailImages;
    if (json['detailImages'] != null) {
      if (json['detailImages'] is String) {
        try {
          // 如果是JSON字符串，解析它
          detailImages = (json['detailImages'] as List<dynamic>).cast<String>();
        } catch (_) {
          // 解析失败，保持为null
        }
      } else if (json['detailImages'] is List) {
        detailImages = (json['detailImages'] as List<dynamic>).cast<String>();
      }
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] != null) ? double.parse(json['price'].toString()) : 0.0,
      goldPrice: json['goldPrice'] ?? 0,
      stock: json['stock'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      imageUrl: json['imageUrl'],
      detailImages: detailImages,
      status: json['status'] ?? 1,
    );
  }
}

// 商品列表响应模型
class ProductListResponse {
  final List<Product> products;
  final int total;
  final int currentPage;
  final int totalPages;

  ProductListResponse({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    List<Product> products = [];
    if (json['records'] != null) {
      products = (json['records'] as List<dynamic>)
          .map((item) => Product.fromJson(item))
          .toList();
    }

    return ProductListResponse(
      products: products,
      total: json['total'] ?? 0,
      currentPage: json['current'] ?? 1,
      totalPages: json['pages'] ?? 1,
    );
  }
}

// 购物车项模型
class CartItem {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  final int? productGoldPrice;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productGoldPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 1,
      productName: json['productName'],
      productImage: json['productImage'],
      productPrice: json['productPrice'] != null
          ? double.parse(json['productPrice'].toString())
          : null,
      productGoldPrice: json['productGoldPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
    };
  }
}

// 订单模型
class Order {
  final int id;
  final String orderNo;
  final int userId;
  final double totalAmount;
  final int totalGold;
  final int status; // 0-待支付, 1-已支付, 2-已发货, 3-已完成, 4-已取消
  final String? payMethod;
  final String? payTime;
  final int? addressId;
  final String? consignee;
  final String? mobile;
  final String? address;
  final String? remark;
  final String? createdAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.totalAmount,
    required this.totalGold,
    required this.status,
    this.payMethod,
    this.payTime,
    this.addressId,
    this.consignee,
    this.mobile,
    this.address,
    this.remark,
    this.createdAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? items;
    if (json['items'] != null) {
      items = (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'] ?? 0,
      orderNo: json['orderNo'] ?? '',
      userId: json['userId'] ?? 0,
      totalAmount: json['totalAmount'] != null
          ? double.parse(json['totalAmount'].toString())
          : 0.0,
      totalGold: json['totalGold'] ?? 0,
      status: json['status'] ?? 0,
      payMethod: json['payMethod'],
      payTime: json['payTime'],
      addressId: json['addressId'],
      consignee: json['consignee'],
      mobile: json['mobile'],
      address: json['address'],
      remark: json['remark'],
      createdAt: json['createdAt'],
      items: items,
    );
  }

  // 获取订单状态文本
  String get statusText {
    switch (status) {
      case 0:
        return '待支付';
      case 1:
        return '已支付';
      case 2:
        return '已发货';
      case 3:
        return '已完成';
      case 4:
        return '已取消';
      default:
        return '未知状态';
    }
  }

  // 订单是否可取消
  bool get canCancel {
    return status == 0 || status == 1;
  }

  // 订单是否已完成
  bool get isCompleted {
    return status == 3;
  }
}

// 订单商品模型
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int goldPrice;
  final int quantity;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.goldPrice,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productImage: json['productImage'],
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : 0.0,
      goldPrice: json['goldPrice'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

// 订单列表响应模型
class OrderListResponse {
  final List<Order> orders;
  final int total;
  final int currentPage;
  final int totalPages;

  OrderListResponse({
    required this.orders,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    List<Order> orders = [];
    if (json['records'] != null) {
      orders = (json['records'] as List<dynamic>)
          .map((item) => Order.fromJson(item))
          .toList();
    }

    return OrderListResponse(
      orders: orders,
      total: json['total'] ?? 0,
      currentPage: json['current'] ?? 1,
      totalPages: json['pages'] ?? 1,
    );
  }
}

// 收货地址模型
class ShippingAddress {
  final int id;
  final int userId;
  final String consignee;
  final String mobile;
  final String province;
  final String city;
  final String district;
  final String detailAddress;
  final int isDefault; // 0-非默认, 1-默认

  ShippingAddress({
    required this.id,
    required this.userId,
    required this.consignee,
    required this.mobile,
    required this.province,
    required this.city,
    required this.district,
    required this.detailAddress,
    required this.isDefault,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      consignee: json['consignee'] ?? '',
      mobile: json['mobile'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      isDefault: json['isDefault'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'consignee': consignee,
      'mobile': mobile,
      'province': province,
      'city': city,
      'district': district,
      'detailAddress': detailAddress,
      'isDefault': isDefault,
    };
  }

  // 获取完整地址
  String get fullAddress {
    return '$province$city$district$detailAddress';
  }
} 
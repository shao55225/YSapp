import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../../constants/api_constants.dart';

// 支付服务提供者
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PaymentService(apiService);
});

// 金币信息提供者
final goldInfoProvider = FutureProvider<GoldInfo>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return await paymentService.getGoldInfo();
});

// 支付配置提供者
final payConfigProvider = FutureProvider<PayConfig>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return await paymentService.getPayConfig();
});

class PaymentService {
  final ApiService _apiService;
  
  PaymentService(this._apiService);
  
  // 获取支付配置
  Future<PayConfig> getPayConfig() async {
    try {
      final data = await _apiService.get(ApiConstants.payConfig);
      return PayConfig.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取金币汇率
  Future<GoldRate> getGoldRate() async {
    try {
      final data = await _apiService.get(ApiConstants.goldRate);
      return GoldRate.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 创建订单
  Future<PayOrder> createOrder({
    required int packageId, 
    required String payMethod, 
    String? payChannel, 
    String? returnUrl
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'packageId': packageId,
        'payMethod': payMethod,
      };
      
      if (payChannel != null) {
        requestData['payChannel'] = payChannel;
      }
      
      if (returnUrl != null) {
        requestData['returnUrl'] = returnUrl;
      }
      
      final data = await _apiService.post(ApiConstants.createOrder, data: requestData);
      return PayOrder.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 查询支付状态
  Future<PayStatus> getPayStatus(String orderId) async {
    try {
      final data = await _apiService.get('${ApiConstants.payStatus}$orderId');
      return PayStatus.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 查询订单状态
  Future<OrderStatus> getOrderStatus(String orderId) async {
    try {
      final data = await _apiService.post(ApiConstants.orderStatus, data: {
        'orderId': orderId,
      });
      return OrderStatus.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 关闭微信支付订单
  Future<void> closeWechatOrder(String orderId) async {
    try {
      await _apiService.post(ApiConstants.closeWechatOrder, data: {
        'orderId': orderId,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 关闭支付宝订单
  Future<void> closeAntOrder(String orderId) async {
    try {
      await _apiService.post(ApiConstants.closeAntOrder, data: {
        'orderId': orderId,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取所有套餐
  Future<List<Package>> getAllPackages({int? type}) async {
    try {
      final Map<String, dynamic>? params = type != null ? {'type': type} : null;
      final data = await _apiService.get(ApiConstants.allPackages, queryParameters: params);
      
      return (data as List).map((item) => Package.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取套餐分组
  Future<List<PackageGroup>> getAllPackageGroups() async {
    try {
      final data = await _apiService.get(ApiConstants.packageGroups);
      
      return (data as List).map((item) => PackageGroup.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // 兑换套餐
  Future<ExchangeResult> exchangePackage(int id) async {
    try {
      final data = await _apiService.post('${ApiConstants.exchangePackage}$id');
      return ExchangeResult.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取金币记录
  Future<GoldRecordResponse> getGoldRecords({required int limit, required int offset, int? type}) async {
    try {
      final data = await _apiService.get(ApiConstants.goldPage, queryParameters: {
        'limit': limit,
        'offset': offset,
        if (type != null) 'type': type,
      });
      
      final List<GoldRecord> records = (data['list'] as List).map((item) => GoldRecord.fromJson(item)).toList();
      
      return GoldRecordResponse(
        records: records,
        total: data['total'] ?? 0,
        hasMore: data['hasMore'] ?? false,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取金币信息
  Future<GoldInfo> getGoldInfo() async {
    try {
      final data = await _apiService.get(ApiConstants.goldInfo);
      return GoldInfo.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 卡密激活
  Future<CardActivation> activateCard(String account, String password) async {
    try {
      final data = await _apiService.post(ApiConstants.activeCard, data: {
        'account': account,
        'password': password,
      });
      return CardActivation.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取订单列表
  Future<OrderListResponse> getOrders({required int limit, required int offset, int? orderStatus}) async {
    try {
      final data = await _apiService.get(ApiConstants.orderPage, queryParameters: {
        'limit': limit,
        'offset': offset,
        if (orderStatus != null) 'orderStatus': orderStatus,
      });
      
      final List<Order> orders = (data['list'] as List).map((item) => Order.fromJson(item)).toList();
      
      return OrderListResponse(
        orders: orders,
        total: data['total'] ?? 0,
        hasMore: data['hasMore'] ?? false,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取订单详情
  Future<Order> getOrderDetail(int id) async {
    try {
      final data = await _apiService.get('${ApiConstants.orderDetail}$id');
      return Order.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // 删除订单
  Future<void> deleteOrder(String orderId, String pwd) async {
    try {
      await _apiService.post(ApiConstants.deleteOrder, data: {
        'orderId': orderId,
        'pwd': pwd,
      });
    } catch (e) {
      rethrow;
    }
  }
}

// 支付配置模型
class PayConfig {
  final int status;
  final List<PayMethod> methods;
  
  PayConfig({
    required this.status,
    required this.methods,
  });
  
  factory PayConfig.fromJson(Map<String, dynamic> json) {
    final List<PayMethod> methodsList = [];
    if (json['methods'] != null) {
      json['methods'].forEach((method) {
        methodsList.add(PayMethod.fromJson(method));
      });
    }
    
    return PayConfig(
      status: json['status'] ?? 0,
      methods: methodsList,
    );
  }
}

// 支付方式模型
class PayMethod {
  final String id;
  final String name;
  final String? icon;
  final int status;
  final String? description;
  final double? minAmount;
  final double? maxAmount;
  final List<String>? channels;
  
  PayMethod({
    required this.id,
    required this.name,
    this.icon,
    required this.status,
    this.description,
    this.minAmount,
    this.maxAmount,
    this.channels,
  });
  
  factory PayMethod.fromJson(Map<String, dynamic> json) {
    List<String>? channelsList;
    if (json['channels'] != null) {
      channelsList = List<String>.from(json['channels']);
    }
    
    return PayMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      status: json['status'] ?? 0,
      description: json['description'],
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      channels: channelsList,
    );
  }
}

// 金币汇率模型
class GoldRate {
  final double rate;
  final String? unit;
  final int? minExchange;
  final String? description;
  
  GoldRate({
    required this.rate,
    this.unit,
    this.minExchange,
    this.description,
  });
  
  factory GoldRate.fromJson(Map<String, dynamic> json) {
    return GoldRate(
      rate: json['rate']?.toDouble() ?? 0.0,
      unit: json['unit'],
      minExchange: json['minExchange'],
      description: json['description'],
    );
  }
}

// 支付订单模型
class PayOrder {
  final String orderId;
  final double amount;
  final String createTime;
  final String expireTime;
  final String? payUrl;
  final String? qrCode;
  final Map<String, dynamic>? payData;
  
  PayOrder({
    required this.orderId,
    required this.amount,
    required this.createTime,
    required this.expireTime,
    this.payUrl,
    this.qrCode,
    this.payData,
  });
  
  factory PayOrder.fromJson(Map<String, dynamic> json) {
    return PayOrder(
      orderId: json['orderId'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      createTime: json['createTime'] ?? '',
      expireTime: json['expireTime'] ?? '',
      payUrl: json['payUrl'],
      qrCode: json['qrCode'],
      payData: json['payData'],
    );
  }
}

// 支付状态模型
class PayStatus {
  final String orderId;
  final int status;
  final String statusText;
  final String? payTime;
  final double amount;
  final PackageInfo? packageInfo;
  
  PayStatus({
    required this.orderId,
    required this.status,
    required this.statusText,
    this.payTime,
    required this.amount,
    this.packageInfo,
  });
  
  factory PayStatus.fromJson(Map<String, dynamic> json) {
    return PayStatus(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 0,
      statusText: json['statusText'] ?? '',
      payTime: json['payTime'],
      amount: json['amount']?.toDouble() ?? 0.0,
      packageInfo: json['packageInfo'] != null ? PackageInfo.fromJson(json['packageInfo']) : null,
    );
  }
}

// 订单状态模型
class OrderStatus {
  final int status;
  final String message;
  
  OrderStatus({
    required this.status,
    required this.message,
  });
  
  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

// 套餐信息模型
class PackageInfo {
  final int id;
  final String name;
  final int days;
  
  PackageInfo({
    required this.id,
    required this.name,
    required this.days,
  });
  
  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      days: json['days'] ?? 0,
    );
  }
}

// 套餐模型
class Package {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final int days;
  final String? icon;
  final int type;
  final int? isRecommend;
  final int goldNum;
  final int status;
  
  Package({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    required this.days,
    this.icon,
    required this.type,
    this.isRecommend,
    required this.goldNum,
    required this.status,
  });
  
  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      originalPrice: json['originalPrice']?.toDouble(),
      days: json['days'] ?? 0,
      icon: json['icon'],
      type: json['type'] ?? 0,
      isRecommend: json['isRecommend'],
      goldNum: json['goldNum'] ?? 0,
      status: json['status'] ?? 0,
    );
  }
}

// 套餐分组模型
class PackageGroup {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int type;
  final int? sort;
  
  PackageGroup({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.type,
    this.sort,
  });
  
  factory PackageGroup.fromJson(Map<String, dynamic> json) {
    return PackageGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      type: json['type'] ?? 0,
      sort: json['sort'],
    );
  }
}

// 兑换结果模型
class ExchangeResult {
  final PackageInfo packageInfo;
  final UserInfo userInfo;
  
  ExchangeResult({
    required this.packageInfo,
    required this.userInfo,
  });
  
  factory ExchangeResult.fromJson(Map<String, dynamic> json) {
    return ExchangeResult(
      packageInfo: PackageInfo.fromJson(json['packageInfo'] ?? {}),
      userInfo: UserInfo.fromJson(json['userInfo'] ?? {}),
    );
  }
}

// 用户信息模型
class UserInfo {
  final int gold;
  final String? vipExpireTime;
  
  UserInfo({
    required this.gold,
    this.vipExpireTime,
  });
  
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      gold: json['gold'] ?? 0,
      vipExpireTime: json['vipExpireTime'],
    );
  }
}

// 金币记录模型
class GoldRecord {
  final int id;
  final int type;
  final String typeName;
  final int amount;
  final int beforeAmount;
  final int afterAmount;
  final String? description;
  final String createTime;
  
  GoldRecord({
    required this.id,
    required this.type,
    required this.typeName,
    required this.amount,
    required this.beforeAmount,
    required this.afterAmount,
    this.description,
    required this.createTime,
  });
  
  factory GoldRecord.fromJson(Map<String, dynamic> json) {
    return GoldRecord(
      id: json['id'] ?? 0,
      type: json['type'] ?? 0,
      typeName: json['typeName'] ?? '',
      amount: json['amount'] ?? 0,
      beforeAmount: json['beforeAmount'] ?? 0,
      afterAmount: json['afterAmount'] ?? 0,
      description: json['description'],
      createTime: json['createTime'] ?? '',
    );
  }
}

// 金币记录响应模型
class GoldRecordResponse {
  final List<GoldRecord> records;
  final int total;
  final bool hasMore;
  
  GoldRecordResponse({
    required this.records,
    required this.total,
    required this.hasMore,
  });
}

// 金币信息模型
class GoldInfo {
  final int gold;
  final int totalRecharge;
  final int totalConsume;
  final int? todayConsume;
  final int? monthlyConsume;
  
  GoldInfo({
    required this.gold,
    required this.totalRecharge,
    required this.totalConsume,
    this.todayConsume,
    this.monthlyConsume,
  });
  
  factory GoldInfo.fromJson(Map<String, dynamic> json) {
    return GoldInfo(
      gold: json['gold'] ?? 0,
      totalRecharge: json['totalRecharge'] ?? 0,
      totalConsume: json['totalConsume'] ?? 0,
      todayConsume: json['todayConsume'],
      monthlyConsume: json['monthlyConsume'],
    );
  }
}

// 卡密激活结果模型
class CardActivation {
  final int type;
  final String typeName;
  final int value;
  final String? unit;
  final String? expireTime;
  
  CardActivation({
    required this.type,
    required this.typeName,
    required this.value,
    this.unit,
    this.expireTime,
  });
  
  factory CardActivation.fromJson(Map<String, dynamic> json) {
    return CardActivation(
      type: json['type'] ?? 0,
      typeName: json['typeName'] ?? '',
      value: json['value'] ?? 0,
      unit: json['unit'],
      expireTime: json['expireTime'],
    );
  }
}

// 订单模型
class Order {
  final int id;
  final String orderNo;
  final String packageName;
  final double amount;
  final int status;
  final String statusName;
  final String createTime;
  final String? payTime;
  final int type;
  final String typeName;
  
  Order({
    required this.id,
    required this.orderNo,
    required this.packageName,
    required this.amount,
    required this.status,
    required this.statusName,
    required this.createTime,
    this.payTime,
    required this.type,
    required this.typeName,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNo: json['orderNo'] ?? '',
      packageName: json['packageName'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 0,
      statusName: json['statusName'] ?? '',
      createTime: json['createTime'] ?? '',
      payTime: json['payTime'],
      type: json['type'] ?? 0,
      typeName: json['typeName'] ?? '',
    );
  }
}

// 订单列表响应模型
class OrderListResponse {
  final List<Order> orders;
  final int total;
  final bool hasMore;
  
  OrderListResponse({
    required this.orders,
    required this.total,
    required this.hasMore,
  });
} 
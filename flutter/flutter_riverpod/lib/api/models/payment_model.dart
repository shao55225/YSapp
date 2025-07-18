/// 套餐模型类
class PackageModel {
  final int id;
  final String name;
  final String? description;
  final int type;        // 套餐类型：1-VIP，2-金币，3-金币兑换
  final double price;    // 价格
  final int? goldCoin;   // 金币数量
  final int? days;       // VIP天数
  final int? sort;       // 排序
  final int? status;     // 状态：0-下架，1-上架
  final String? createTime;
  final String? updateTime;
  final int? groupId;    // 分组ID
  final String? groupName; // 分组名称
  final String? icon;    // 图标

  PackageModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.goldCoin,
    this.days,
    this.sort,
    this.status,
    this.createTime,
    this.updateTime,
    this.groupId,
    this.groupName,
    this.icon,
  });

  /// 从JSON构造
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as int,
      price: (json['price'] as num).toDouble(),
      goldCoin: json['goldCoin'] as int?,
      days: json['days'] as int?,
      sort: json['sort'] as int?,
      status: json['status'] as int?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      groupId: json['groupId'] as int?,
      groupName: json['groupName'] as String?,
      icon: json['icon'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'goldCoin': goldCoin,
      'days': days,
      'sort': sort,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
      'groupId': groupId,
      'groupName': groupName,
      'icon': icon,
    };
  }

  /// 是否是VIP套餐
  bool get isVip => type == 1;

  /// 是否是金币套餐
  bool get isGoldCoin => type == 2;

  /// 是否是金币兑换套餐
  bool get isGoldCoinExchange => type == 3;
}

/// 套餐分组模型
class PackageGroupModel {
  final int id;
  final String name;
  final int? sort;
  final int? status;
  final String? createTime;
  final String? updateTime;
  final List<PackageModel>? packages;

  PackageGroupModel({
    required this.id,
    required this.name,
    this.sort,
    this.status,
    this.createTime,
    this.updateTime,
    this.packages,
  });

  /// 从JSON构造
  factory PackageGroupModel.fromJson(Map<String, dynamic> json) {
    List<PackageModel>? packagesList;
    if (json['packages'] != null) {
      packagesList = (json['packages'] as List)
          .map((packageJson) => PackageModel.fromJson(packageJson))
          .toList();
    }

    return PackageGroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sort: json['sort'] as int?,
      status: json['status'] as int?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      packages: packagesList,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sort': sort,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
      'packages': packages?.map((package) => package.toJson()).toList(),
    };
  }
}

/// 订单模型
class OrderModel {
  final String orderId;
  final int memberId;
  final int packageId;
  final String packageName;
  final double price;
  final int? goldCoin;
  final int? days;
  final int payType;     // 支付类型：1-微信，2-支付宝，3-余额
  final int orderStatus; // 订单状态：0-未支付，1-已支付，2-已取消
  final String? createTime;
  final String? updateTime;
  final String? payTime;

  OrderModel({
    required this.orderId,
    required this.memberId,
    required this.packageId,
    required this.packageName,
    required this.price,
    this.goldCoin,
    this.days,
    required this.payType,
    required this.orderStatus,
    this.createTime,
    this.updateTime,
    this.payTime,
  });

  /// 从JSON构造
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String,
      memberId: json['memberId'] as int,
      packageId: json['packageId'] as int,
      packageName: json['packageName'] as String,
      price: (json['price'] as num).toDouble(),
      goldCoin: json['goldCoin'] as int?,
      days: json['days'] as int?,
      payType: json['payType'] as int,
      orderStatus: json['orderStatus'] as int,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      payTime: json['payTime'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'memberId': memberId,
      'packageId': packageId,
      'packageName': packageName,
      'price': price,
      'goldCoin': goldCoin,
      'days': days,
      'payType': payType,
      'orderStatus': orderStatus,
      'createTime': createTime,
      'updateTime': updateTime,
      'payTime': payTime,
    };
  }

  /// 是否已支付
  bool get isPaid => orderStatus == 1;

  /// 是否已取消
  bool get isCancelled => orderStatus == 2;

  /// 支付方式名称
  String get payTypeName {
    switch (payType) {
      case 1:
        return '微信支付';
      case 2:
        return '支付宝';
      case 3:
        return '余额支付';
      default:
        return '未知';
    }
  }
}

/// 金币记录模型
class GoldCoinRecordModel {
  final int id;
  final int memberId;
  final int type;        // 类型：1-充值，2-消费，3-兑换，4-签到
  final int amount;      // 金币数量
  final String? description;
  final String? createTime;

  GoldCoinRecordModel({
    required this.id,
    required this.memberId,
    required this.type,
    required this.amount,
    this.description,
    this.createTime,
  });

  /// 从JSON构造
  factory GoldCoinRecordModel.fromJson(Map<String, dynamic> json) {
    return GoldCoinRecordModel(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      type: json['type'] as int,
      amount: json['amount'] as int,
      description: json['description'] as String?,
      createTime: json['createTime'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'type': type,
      'amount': amount,
      'description': description,
      'createTime': createTime,
    };
  }

  /// 是否是收入
  bool get isIncome => type == 1 || type == 3 || type == 4;

  /// 是否是支出
  bool get isExpense => type == 2;

  /// 类型名称
  String get typeName {
    switch (type) {
      case 1:
        return '充值';
      case 2:
        return '消费';
      case 3:
        return '兑换';
      case 4:
        return '签到';
      default:
        return '未知';
    }
  }
} 
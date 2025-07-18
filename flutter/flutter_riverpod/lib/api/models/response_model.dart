/// API响应模型类
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 从JSON构造
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value)? toJsonT) {
    return {
      'code': code,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }

  /// 是否成功
  bool get isSuccess => code == 200;
}

/// 分页响应模型
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int offset;
  final int limit;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  /// 从JSON构造
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final List<dynamic> records = json['records'] as List<dynamic>;
    final int total = json['total'] as int;
    final int offset = json['offset'] as int;
    final int limit = json['limit'] as int;

    final List<T> items = records
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      items: items,
      total: total,
      offset: offset,
      limit: limit,
      hasMore: offset + limit < total,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T item) toJsonT) {
    return {
      'records': items.map((item) => toJsonT(item)).toList(),
      'total': total,
      'offset': offset,
      'limit': limit,
    };
  }

  /// 当前页码
  int get currentPage => (offset ~/ limit) + 1;

  /// 总页数
  int get totalPages => (total / limit).ceil();
}

/// API异常类
class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  ApiException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    if (code != null) {
      return 'ApiException: [$code] $message';
    }
    return 'ApiException: $message';
  }
} 
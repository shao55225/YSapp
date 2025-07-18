import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/api_constants.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';

// 收藏服务提供者
final collectServiceProvider = Provider<CollectService>((ref) {
  final dio = Dio();
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggingInterceptor());
  return CollectService(dio);
});

class CollectService {
  final Dio _dio;

  CollectService(this._dio);

  /// 添加收藏
  /// [resourceId] - 资源ID
  /// [resourceType] - 资源类型（1-视频，2-文章）
  Future<void> addCollect(String resourceId, {int resourceType = 1}) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.collect}',
        data: {
          'resourceId': resourceId,
          'resourceType': resourceType,
        },
      );
    } catch (e) {
      throw '添加收藏失败: ${_handleError(e)}';
    }
  }

  /// 取消收藏
  /// [resourceId] - 资源ID
  /// [resourceType] - 资源类型（1-视频，2-文章）
  Future<void> cancelCollect(String resourceId, {int resourceType = 1}) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.cancelCollect}',
        data: {
          'resourceId': resourceId,
          'resourceType': resourceType,
        },
      );
    } catch (e) {
      throw '取消收藏失败: ${_handleError(e)}';
    }
  }

  /// 获取收藏列表
  /// [resourceType] - 资源类型（1-视频，2-文章）
  /// [page] - 页码
  /// [size] - 每页数量
  Future<CollectPageResult> getCollectPage(int page, {int size = 10, int resourceType = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.collectPage}',
        queryParameters: {
          'page': page,
          'size': size,
          'resourceType': resourceType,
        },
      );

      return CollectPageResult.fromJson(response.data['data']);
    } catch (e) {
      throw '获取收藏列表失败: ${_handleError(e)}';
    }
  }

  /// 检查是否已收藏
  /// [resourceId] - 资源ID
  /// [resourceType] - 资源类型（1-视频，2-文章）
  Future<bool> isCollected(String resourceId, {int resourceType = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.collectPage}',
        queryParameters: {
          'page': 1,
          'size': 100,
          'resourceType': resourceType,
        },
      );

      final result = CollectPageResult.fromJson(response.data['data']);
      return result.records.any((item) => item.resourceId == resourceId);
    } catch (e) {
      // 如果获取失败，默认未收藏
      return false;
    }
  }

  /// 处理错误
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        try {
          final errorData = error.response!.data;
          if (errorData is Map && errorData.containsKey('message')) {
            return errorData['message'];
          }
        } catch (e) {
          // 解析错误，返回原始错误信息
        }
      }
      return error.message ?? '网络错误';
    }
    return error.toString();
  }
}

// 收藏分页结果
class CollectPageResult {
  final List<CollectItem> records;
  final int total;
  final int size;
  final int current;
  final int pages;

  CollectPageResult({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
  });

  factory CollectPageResult.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'] as List? ?? [];
    final records = recordsList.map((item) => CollectItem.fromJson(item)).toList();

    return CollectPageResult(
      records: records,
      total: json['total'] ?? 0,
      size: json['size'] ?? 10,
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

// 收藏项
class CollectItem {
  final String id;
  final String resourceId;
  final int resourceType;
  final String? title;
  final String? cover;
  final String? createTime;

  CollectItem({
    required this.id,
    required this.resourceId,
    required this.resourceType,
    this.title,
    this.cover,
    this.createTime,
  });

  factory CollectItem.fromJson(Map<String, dynamic> json) {
    return CollectItem(
      id: json['id'] ?? '',
      resourceId: json['resourceId'] ?? '',
      resourceType: json['resourceType'] ?? 1,
      title: json['title'],
      cover: json['cover'],
      createTime: json['createTime'],
    );
  }
} 
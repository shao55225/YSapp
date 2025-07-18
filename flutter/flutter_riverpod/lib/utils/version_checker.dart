import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/api_service.dart';
import '../utils/api_cache.dart';

/// 版本信息模型
class VersionInfo {
  final String version;
  final String buildNumber;
  final String updateDescription;
  final String downloadUrl;
  final bool isForceUpdate;

  VersionInfo({
    required this.version,
    required this.buildNumber,
    required this.updateDescription,
    required this.downloadUrl,
    required this.isForceUpdate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] ?? '',
      buildNumber: json['buildNumber'] ?? '',
      updateDescription: json['updateDescription'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      isForceUpdate: json['isForceUpdate'] ?? false,
    );
  }

  /// 将版本号转换为可比较的整数
  int get versionCode {
    final parts = version.split('.');
    int major = 0, minor = 0, patch = 0;
    
    if (parts.length > 0) {
      major = int.tryParse(parts[0]) ?? 0;
    }
    if (parts.length > 1) {
      minor = int.tryParse(parts[1]) ?? 0;
    }
    if (parts.length > 2) {
      patch = int.tryParse(parts[2]) ?? 0;
    }
    
    return major * 10000 + minor * 100 + patch;
  }
}

/// 版本检查器提供者
final versionCheckerProvider = Provider<VersionChecker>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VersionChecker(apiService: apiService);
});

/// 版本检查器
class VersionChecker {
  final ApiService apiService;
  
  VersionChecker({required this.apiService});
  
  /// 检查应用版本
  /// 如果有新版本，返回版本信息，否则返回null
  Future<VersionInfo?> checkVersion() async {
    try {
      // 尝试从缓存获取版本信息
      final cacheKey = ApiCache.generateKey('app_version');
      VersionInfo? versionInfo;
      
      // 从服务端获取最新版本信息
      final data = await apiService.get('/openapi/app/version');
      versionInfo = VersionInfo.fromJson(data);
      
      // 缓存版本信息，有效期1小时
      await ApiCache.saveData(cacheKey, data, expiry: Duration(hours: 1));
      
      // 获取当前应用版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // 比较版本号
      final currentVersionCode = _getVersionCode(currentVersion);
      final newVersionCode = versionInfo.versionCode;
      
      if (newVersionCode > currentVersionCode) {
        return versionInfo;
      }
      
      return null;
    } catch (e) {
      print('版本检查失败: $e');
      return null;
    }
  }
  
  /// 将版本号转换为可比较的整数
  int _getVersionCode(String version) {
    final parts = version.split('.');
    int major = 0, minor = 0, patch = 0;
    
    if (parts.length > 0) {
      major = int.tryParse(parts[0]) ?? 0;
    }
    if (parts.length > 1) {
      minor = int.tryParse(parts[1]) ?? 0;
    }
    if (parts.length > 2) {
      patch = int.tryParse(parts[2]) ?? 0;
    }
    
    return major * 10000 + minor * 100 + patch;
  }
  
  /// 显示更新对话框
  void showUpdateDialog(BuildContext context, VersionInfo versionInfo) {
    showDialog(
      context: context,
      barrierDismissible: !versionInfo.isForceUpdate,
      builder: (context) => AlertDialog(
        title: Text('发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('新版本: ${versionInfo.version}'),
            SizedBox(height: 8),
            Text('更新内容:'),
            SizedBox(height: 4),
            Text(versionInfo.updateDescription),
          ],
        ),
        actions: [
          if (!versionInfo.isForceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('稍后再说'),
            ),
          TextButton(
            onPressed: () {
              _launchUrl(versionInfo.downloadUrl);
              if (versionInfo.isForceUpdate) {
                // 强制更新，退出应用
                SystemNavigator.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text('立即更新'),
          ),
        ],
      ),
    );
  }
  
  /// 打开URL
  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw '无法打开URL: $url';
    }
  }
  
  /// 获取应用商店URL
  String getAppStoreUrl() {
    if (Platform.isAndroid) {
      // Google Play商店URL
      return 'market://details?id=com.aiyingvideo.app';
    } else if (Platform.isIOS) {
      // App Store URL
      return 'itms-apps://itunes.apple.com/app/id123456789';
    } else {
      // 默认下载页面
      return 'https://yourdomain.com/download';
    }
  }
}

/// 版本检查扩展
extension VersionCheckExtension on WidgetRef {
  /// 检查应用版本并显示更新对话框
  Future<void> checkAppVersion(BuildContext context) async {
    final versionChecker = read(versionCheckerProvider);
    final versionInfo = await versionChecker.checkVersion();
    
    if (versionInfo != null) {
      versionChecker.showUpdateDialog(context, versionInfo);
    }
  }
} 
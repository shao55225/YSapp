import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// iOS专用权限处理工具类
/// 用于处理iOS平台特有的权限请求
class IOSPermissionHandler {
  /// 请求相册权限
  /// 返回是否授予权限
  static Future<bool> requestPhotoLibraryPermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.photos.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.photos.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '相册权限被拒绝',
        '请在设置中开启相册权限，以便上传头像和保存视频。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求相机权限
  /// 返回是否授予权限
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.camera.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '相机权限被拒绝',
        '请在设置中开启相机权限，以便使用扫码和拍照功能。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求通知权限
  /// 返回是否授予权限
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.notification.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '通知权限被拒绝',
        '请在设置中开启通知权限，以便接收重要消息和更新。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求麦克风权限
  /// 返回是否授予权限
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.microphone.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '麦克风权限被拒绝',
        '请在设置中开启麦克风权限，以便使用语音功能。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求位置权限
  /// 返回是否授予权限
  static Future<bool> requestLocationWhenInUsePermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.locationWhenInUse.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.locationWhenInUse.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '位置权限被拒绝',
        '请在设置中开启位置权限，以便获取定位服务。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求后台运行权限（用于后台播放音频）
  static Future<void> requestBackgroundModePermission() async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return;
    }
    
    // 这个权限通过Info.plist配置，不需要动态请求
    // 但可以在这里添加一些检查逻辑
  }
  
  /// 请求应用跟踪透明度权限（iOS 14+）
  /// 用于广告标识符访问
  static Future<bool> requestTrackingPermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.appTrackingTransparency.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.appTrackingTransparency.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '广告追踪权限被拒绝',
        '请在设置中开启广告追踪权限，以便获取个性化广告体验。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 请求联系人权限
  static Future<bool> requestContactsPermission(BuildContext context) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查当前权限状态
    var status = await Permission.contacts.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    status = await Permission.contacts.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '通讯录权限被拒绝',
        '请在设置中开启通讯录权限，以便使用好友推荐功能。'
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  /// 显示权限设置对话框
  /// 提示用户前往设置页面开启权限
  static void _showPermissionSettingsDialog(
    BuildContext context, 
    String title, 
    String message
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('去设置'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// 检查多个权限
  /// 返回是否所有权限都已授予
  static Future<bool> checkMultiplePermissions(
    List<Permission> permissions,
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    // 仅在iOS平台执行
    if (!Platform.isIOS) {
      return false;
    }
    
    // 检查所有权限状态
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    // 检查是否所有权限都已授予
    bool allGranted = true;
    Permission? deniedPermission;
    
    for (var entry in statuses.entries) {
      if (!entry.value.isGranted) {
        allGranted = false;
        deniedPermission = entry.key;
        break;
      }
    }
    
    // 如果有权限被永久拒绝，显示设置提示
    if (deniedPermission != null && 
        statuses[deniedPermission]?.isPermanentlyDenied == true) {
      _showPermissionSettingsDialog(
        context, 
        title ?? '权限被拒绝',
        message ?? '请在设置中开启所需权限，以便应用正常工作。'
      );
    }
    
    return allGranted;
  }
  
  /// 检查是否为iOS 14或更高版本
  /// iOS 14引入了应用跟踪透明度权限
  static Future<bool> isIOS14OrAbove() async {
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      // iOS 14对应的版本号是14.0
      final versionParts = iosInfo.systemVersion.split('.');
      if (versionParts.isNotEmpty) {
        final majorVersion = int.tryParse(versionParts[0]) ?? 0;
        return majorVersion >= 14;
      }
    }
    return false;
  }
} 
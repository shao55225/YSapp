import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限处理工具类
/// 用于处理Android和iOS平台的权限请求
class PermissionHandler {
  /// 请求存储权限
  /// 返回是否授予权限
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // 检查当前权限状态
    PermissionStatus status;
    
    if (Platform.isAndroid) {
      // Android平台
      if (await _isAndroid13OrAbove()) {
        // Android 13及以上使用照片和视频权限
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      } else {
        // Android 13以下使用存储权限
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }
    } else if (Platform.isIOS) {
      // iOS平台
      status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }
    } else {
      // 其他平台
      return false;
    }
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '存储权限被拒绝',
        '请在设置中开启存储权限，以便保存视频和图片。'
      );
      return false;
    }
    
    return status.isGranted;
  }

  /// 请求相机权限
  /// 返回是否授予权限
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // 检查当前权限状态
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    final result = await Permission.camera.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (result.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '相机权限被拒绝',
        '请在设置中开启相机权限，以便使用扫码和拍照功能。'
      );
      return false;
    }
    
    return result.isGranted;
  }
  
  /// 请求通知权限
  /// 返回是否授予权限
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    // 检查当前权限状态
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    final result = await Permission.notification.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (result.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '通知权限被拒绝',
        '请在设置中开启通知权限，以便接收重要消息和更新。'
      );
      return false;
    }
    
    return result.isGranted;
  }
  
  /// 请求麦克风权限
  /// 返回是否授予权限
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    // 检查当前权限状态
    final status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    final result = await Permission.microphone.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (result.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '麦克风权限被拒绝',
        '请在设置中开启麦克风权限，以便使用语音功能。'
      );
      return false;
    }
    
    return result.isGranted;
  }
  
  /// 请求位置权限
  /// 返回是否授予权限
  static Future<bool> requestLocationPermission(BuildContext context) async {
    // 检查当前权限状态
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    final result = await Permission.location.request();
    
    // 如果权限被拒绝且不再显示请求对话框，显示设置提示
    if (result.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context, 
        '位置权限被拒绝',
        '请在设置中开启位置权限，以便获取定位服务。'
      );
      return false;
    }
    
    return result.isGranted;
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
  
  /// 检查是否为Android 13或更高版本
  static Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33; // Android 13 is API level 33
    }
    return false;
  }
  
  /// 检查多个权限
  /// 返回是否所有权限都已授予
  static Future<bool> checkMultiplePermissions(
    List<Permission> permissions,
    BuildContext context, {
    String? title,
    String? message,
  }) async {
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
} 
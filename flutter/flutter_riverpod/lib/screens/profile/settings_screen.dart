import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../api/services/user_service.dart';
import '../../utils/auth_check.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// 缓存大小提供者
final cacheSizeProvider = FutureProvider<String>((ref) async {
  try {
    final cacheDir = await getTemporaryDirectory();
    final cacheSize = await _calculateDirectorySize(cacheDir);
    return _formatBytes(cacheSize);
  } catch (e) {
    return '0 B';
  }
});

// 计算目录大小
Future<int> _calculateDirectorySize(Directory dir) async {
  int totalSize = 0;
  try {
    final List<FileSystemEntity> entities = dir.listSync(recursive: true, followLinks: false);
    for (final FileSystemEntity entity in entities) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
  } catch (e) {
    // 忽略错误
  }
  return totalSize;
}

// 格式化字节大小
String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = (bytes > 0) ? (log(bytes) / log(1024)).floor() : 0;
  return ((bytes / pow(1024, i)).toStringAsFixed(2)) + ' ' + suffixes[i];
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoPlayVideos = true;
  bool _enableNotifications = true;
  bool _darkMode = false;
  String _videoQuality = '自动';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  // 加载设置
  Future<void> _loadSettings() async {
    // 这里应该从本地存储加载设置
    // 暂时使用默认值
  }
  
  // 保存设置
  Future<void> _saveSettings() async {
    // 这里应该保存设置到本地存储
    // 暂时只显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }
  
  // 清除缓存
  Future<void> _clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.listSync(recursive: true, followLinks: false).forEach((entity) {
          if (entity is File) {
            try {
              entity.deleteSync();
            } catch (e) {
              // 忽略错误
            }
          }
        });
      }
      
      // 刷新缓存大小
      ref.refresh(cacheSizeProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('缓存已清除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除缓存失败: $e')),
        );
      }
    }
  }
  
  // 退出登录
  Future<void> _logout() async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final userService = ref.read(userServiceProvider);
        await userService.logout();
        
        // 刷新用户信息
        ref.refresh(userInfoProvider);
        
        // 返回首页
        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('退出登录失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cacheSize = ref.watch(cacheSizeProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 通用设置
          _buildSectionHeader('通用设置'),
          SwitchListTile(
            title: const Text('自动播放视频'),
            subtitle: const Text('在Wi-Fi环境下自动播放视频'),
            value: _autoPlayVideos,
            onChanged: (value) {
              setState(() {
                _autoPlayVideos = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('通知提醒'),
            subtitle: const Text('接收消息和活动通知'),
            value: _enableNotifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('使用深色主题'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              _saveSettings();
            },
          ),
          
          // 视频设置
          _buildSectionHeader('视频设置'),
          ListTile(
            title: const Text('视频画质'),
            subtitle: Text('当前: $_videoQuality'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showVideoQualityDialog();
            },
          ),
          
          // 缓存管理
          _buildSectionHeader('缓存管理'),
          ListTile(
            title: const Text('清除缓存'),
            subtitle: cacheSize.when(
              data: (size) => Text('缓存大小: $size'),
              loading: () => const Text('计算中...'),
              error: (_, __) => const Text('计算失败'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
          
          // 账户设置
          _buildSectionHeader('账户设置'),
          ListTile(
            title: const Text('安全设置'),
            subtitle: const Text('修改密码、设置资金密码等'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await AuthCheck.run(
                context,
                ref,
                onAuthenticated: () {
                  context.push('/security-settings');
                },
                message: '访问安全设置需要登录',
              );
            },
          ),
          
          // 关于
          _buildSectionHeader('关于'),
          ListTile(
            title: const Text('版本信息'),
            subtitle: const Text('V1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 显示版本信息
            },
          ),
          ListTile(
            title: const Text('用户协议'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/terms');
            },
          ),
          ListTile(
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/privacy');
            },
          ),
          
          // 退出登录
          if (isLoggedIn.value == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text('退出登录'),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  Future<void> _showVideoQualityDialog() async {
    final qualities = ['自动', '流畅', '标清', '高清', '超清'];
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择视频画质'),
        children: qualities.map((quality) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(quality),
          child: Text(quality),
        )).toList(),
      ),
    );
    
    if (selected != null) {
      setState(() {
        _videoQuality = selected;
      });
      _saveSettings();
    }
  }
} 
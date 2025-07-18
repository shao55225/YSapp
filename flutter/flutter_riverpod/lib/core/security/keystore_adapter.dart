import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 安全存储适配器接口
abstract class KeystoreAdapter {
  /// 保存数据
  Future<void> write({required String key, required String value});
  
  /// 读取数据
  Future<String?> read({required String key});
  
  /// 删除数据
  Future<void> delete({required String key});
  
  /// 检查是否存在
  Future<bool> containsKey({required String key});
  
  /// 删除所有数据
  Future<void> deleteAll();
  
  /// 工厂构造函数，根据平台返回相应的实现
  factory KeystoreAdapter() {
    if (kIsWeb) {
      return WebKeystoreAdapter();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return MobileKeystoreAdapter();
    } else {
      return DesktopKeystoreAdapter();
    }
  }
}

/// 移动平台安全存储适配器（Android和iOS）
class MobileKeystoreAdapter implements KeystoreAdapter {
  final FlutterSecureStorage _secureStorage;
  
  /// 构造函数
  MobileKeystoreAdapter({FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            resetOnError: true,
            keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
            storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.unlocked,
            synchronizable: false,
          ),
        );
  
  @override
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  @override
  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }
  
  @override
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }
  
  @override
  Future<bool> containsKey({required String key}) async {
    return await _secureStorage.containsKey(key: key);
  }
  
  @override
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}

/// Web平台安全存储适配器
class WebKeystoreAdapter implements KeystoreAdapter {
  final String _prefix = 'secure_';
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  
  @override
  Future<void> write({required String key, required String value}) async {
    final prefs = await _prefs;
    await prefs.setString('$_prefix$key', value);
  }
  
  @override
  Future<String?> read({required String key}) async {
    final prefs = await _prefs;
    return prefs.getString('$_prefix$key');
  }
  
  @override
  Future<void> delete({required String key}) async {
    final prefs = await _prefs;
    await prefs.remove('$_prefix$key');
  }
  
  @override
  Future<bool> containsKey({required String key}) async {
    final prefs = await _prefs;
    return prefs.containsKey('$_prefix$key');
  }
  
  @override
  Future<void> deleteAll() async {
    final prefs = await _prefs;
    final allKeys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in allKeys) {
      await prefs.remove(key);
    }
  }
}

/// 桌面平台安全存储适配器（Windows, macOS, Linux）
class DesktopKeystoreAdapter implements KeystoreAdapter {
  final String _prefix = 'secure_';
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  
  @override
  Future<void> write({required String key, required String value}) async {
    if (kDebugMode) {
      print('警告：桌面平台使用非安全存储，仅用于开发测试');
    }
    final prefs = await _prefs;
    await prefs.setString('$_prefix$key', value);
  }
  
  @override
  Future<String?> read({required String key}) async {
    final prefs = await _prefs;
    return prefs.getString('$_prefix$key');
  }
  
  @override
  Future<void> delete({required String key}) async {
    final prefs = await _prefs;
    await prefs.remove('$_prefix$key');
  }
  
  @override
  Future<bool> containsKey({required String key}) async {
    final prefs = await _prefs;
    return prefs.containsKey('$_prefix$key');
  }
  
  @override
  Future<void> deleteAll() async {
    final prefs = await _prefs;
    final allKeys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in allKeys) {
      await prefs.remove(key);
    }
  }
} 
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 本地存储工具类，封装SharedPreferences和SecureStorage
class StorageUtil {
  static final StorageUtil _instance = StorageUtil._internal();
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _initialized = false;

  /// 单例模式
  factory StorageUtil() => _instance;

  /// 私有构造函数
  StorageUtil._internal();

  /// 初始化
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// 检查是否初始化
  void _checkInit() {
    if (!_initialized) {
      throw Exception('StorageUtil未初始化，请先调用init()方法');
    }
  }

  // ---------------------- SharedPreferences 操作 ----------------------

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    _checkInit();
    return await _prefs.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    _checkInit();
    return _prefs.getString(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    _checkInit();
    return await _prefs.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    _checkInit();
    return _prefs.getBool(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    _checkInit();
    return await _prefs.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    _checkInit();
    return _prefs.getInt(key);
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    _checkInit();
    return await _prefs.setDouble(key, value);
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    _checkInit();
    return _prefs.getDouble(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    _checkInit();
    return await _prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    _checkInit();
    return _prefs.getStringList(key);
  }

  /// 保存对象（转为JSON）
  Future<bool> setObject(String key, Object value) async {
    _checkInit();
    return await _prefs.setString(key, jsonEncode(value));
  }

  /// 获取对象（从JSON转换）
  T? getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    _checkInit();
    String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return fromJson(json);
    } catch (e) {
      print('解析JSON失败: $e');
      return null;
    }
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    _checkInit();
    return _prefs.containsKey(key);
  }

  /// 删除指定键的数据
  Future<bool> remove(String key) async {
    _checkInit();
    return await _prefs.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    _checkInit();
    return await _prefs.clear();
  }

  // ---------------------- SecureStorage 操作 ----------------------

  /// 安全存储字符串
  Future<void> secureWrite(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// 安全读取字符串
  Future<String?> secureRead(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// 安全存储对象（转为JSON）
  Future<void> secureWriteObject(String key, Object value) async {
    await _secureStorage.write(key: key, value: jsonEncode(value));
  }

  /// 安全读取对象（从JSON转换）
  Future<T?> secureReadObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    String? jsonString = await _secureStorage.read(key: key);
    if (jsonString == null) return null;
    
    try {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return fromJson(json);
    } catch (e) {
      print('解析JSON失败: $e');
      return null;
    }
  }

  /// 安全删除指定键的数据
  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// 安全清除所有数据
  Future<void> secureClear() async {
    await _secureStorage.deleteAll();
  }

  /// 检查安全存储中键是否存在
  Future<bool> secureContainsKey(String key) async {
    String? value = await _secureStorage.read(key: key);
    return value != null;
  }
} 
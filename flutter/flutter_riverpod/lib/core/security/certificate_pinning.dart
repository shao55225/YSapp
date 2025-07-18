import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// 证书绑定管理器
/// 
/// 用于验证服务器证书以防止中间人攻击
class CertificatePinningManager {
  /// 单例实例
  static final CertificatePinningManager _instance = CertificatePinningManager._internal();

  /// 受信任证书的SHA-256指纹（公钥哈希）
  final List<String> _trustedCertificates = [
    // 示例: 将这些替换为实际的证书指纹
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
  ];

  /// 是否启用证书绑定
  bool _enabled = true;

  /// 私有构造函数
  CertificatePinningManager._internal();

  /// 获取单例实例
  factory CertificatePinningManager() => _instance;

  /// 启用证书绑定
  void enable() => _enabled = true;
  
  /// 禁用证书绑定
  void disable() => _enabled = false;
  
  /// 是否已启用
  bool get isEnabled => _enabled;

  /// 添加一个受信任证书指纹
  void addTrustedCertificate(String certificateFingerprint) {
    if (!_trustedCertificates.contains(certificateFingerprint)) {
      _trustedCertificates.add(certificateFingerprint);
    }
  }

  /// 清除所有受信任证书指纹
  void clearTrustedCertificates() {
    _trustedCertificates.clear();
  }

  /// 为Dio HTTP客户端配置证书绑定
  void configureDio(Dio dio) {
    // 只在非Web平台上配置证书绑定
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          if (!_enabled) {
            // 如果证书绑定被禁用，接受任何证书
            if (kDebugMode) {
              print('警告: 证书绑定已禁用，接受来自 $host:$port 的不受信任证书');
            }
            return true;
          }

          // 获取证书的公钥哈希
          final fingerprint = _calculateSha256Fingerprint(cert);
          
          // 检查是否是受信任的证书
          final isTrusted = _trustedCertificates.contains(fingerprint);
          
          if (!isTrusted && kDebugMode) {
            print('拒绝不受信任的证书 ($fingerprint) 来自 $host:$port');
          }
          
          return isTrusted;
        };
        return client;
      };
    }
  }

  /// 计算证书的SHA-256指纹
  String _calculateSha256Fingerprint(X509Certificate cert) {
    final publicKeyBytes = cert.pem.codeUnits;
    final hash = sha256.convert(publicKeyBytes);
    final hashBase64 = base64.encode(hash.bytes);
    return 'sha256/$hashBase64';
  }
  
  /// 打印证书详情（用于调试）
  void printCertificateDetails(X509Certificate cert, String host, int port) {
    if (kDebugMode) {
      final fingerprint = _calculateSha256Fingerprint(cert);
      print('=== 证书详情 ($host:$port) ===');
      print('Subject: ${cert.subject}');
      print('Issuer: ${cert.issuer}');
      print('Valid from: ${cert.startValidity}');
      print('Valid to: ${cert.endValidity}');
      print('SHA-256指纹: $fingerprint');
      print('==============================');
    }
  }
} 
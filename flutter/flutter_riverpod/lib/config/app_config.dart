import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/services/api_service.dart';

// 环境枚举
enum Environment {
  development,
  production,
  testing,
}

// 当前环境提供者
final environmentProvider = StateProvider<Environment>((ref) {
  return Environment.development;
});

// 应用配置提供者
final appConfigProvider = StateProvider<AppConfig>((ref) {
  return AppConfig();
});

// 开发者模式提供者
final devModeProvider = StateProvider<bool>((ref) {
  final appConfig = ref.watch(appConfigProvider);
  return appConfig.isDevMode;
});

// 远程配置提供者
final remoteConfigProvider = FutureProvider<RemoteConfig>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final appConfig = ref.watch(appConfigProvider);
  
  try {
    // 尝试从服务端获取配置
    final data = await apiService.get('/openapi/template/site_info');
    return RemoteConfig.fromJson(data);
  } catch (e) {
    // 获取失败时使用本地默认配置
    return RemoteConfig(
      homeUrl: appConfig.defaultHomeUrl,
      siteName: '爱影视频',
      siteDescription: '最好的视频应用',
      isMaintenanceMode: false,
    );
  }
});

// 首页URL提供者
final homeUrlProvider = StateNotifierProvider<HomeUrlNotifier, String>((ref) {
  final appConfig = ref.watch(appConfigProvider);
  return HomeUrlNotifier(appConfig.defaultHomeUrl);
});

// 首页URL状态管理器
class HomeUrlNotifier extends StateNotifier<String> {
  HomeUrlNotifier(String initialUrl) : super(initialUrl) {
    _loadSavedUrl();
  }
  
  // 加载保存的URL
  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('home_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = savedUrl;
    }
  }
  
  // 更新URL
  Future<void> updateUrl(String url) async {
    state = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('home_url', url);
  }
}

// 远程配置模型
class RemoteConfig {
  final String homeUrl;
  final String siteName;
  final String siteDescription;
  final bool isMaintenanceMode;
  final Map<String, dynamic>? additionalConfig;
  
  RemoteConfig({
    required this.homeUrl,
    required this.siteName,
    required this.siteDescription,
    required this.isMaintenanceMode,
    this.additionalConfig,
  });
  
  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      homeUrl: json['homeUrl'] ?? '',
      siteName: json['siteName'] ?? '爱影视频',
      siteDescription: json['siteDescription'] ?? '',
      isMaintenanceMode: json['isMaintenanceMode'] ?? false,
      additionalConfig: json['additionalConfig'],
    );
  }
}

// 应用配置类
class AppConfig {
  // 应用名称
  final String appName;
  
  // API基础URL
  final String apiBaseUrl;
  
  // 是否为开发模式
  final String _appVersion;
  
  // CDN基础URL
  final String cdnBaseUrl;
  
  // 是否为开发模式
  final bool isDevMode;
  
  // 构造函数
  AppConfig({
    this.appName = '爱影视频',
    this.apiBaseUrl = 'https://api.example.com',
    this.isDevMode = false,
    this.cdnBaseUrl = 'https://cdn.example.com',
    String appVersion = '1.0.0',
  }) : _appVersion = appVersion;
  
  // 从持久化存储初始化
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDevMode = prefs.getBool('is_dev_mode') ?? false;
      
      // 更新配置
      container.read(appConfigProvider.notifier).state = AppConfig(
        isDevMode: isDevMode,
      );
    } catch (e) {
      debugPrint('初始化应用配置失败: $e');
    }
  }
  
  // 切换开发者模式
  static Future<void> toggleDevMode(WidgetRef ref) async {
    try {
      final appConfig = ref.read(appConfigProvider);
      final newDevMode = !appConfig.isDevMode;
      
      // 更新配置
      ref.read(appConfigProvider.notifier).state = AppConfig(
        appName: appConfig.appName,
        apiBaseUrl: appConfig.apiBaseUrl,
        isDevMode: newDevMode,
        cdnBaseUrl: appConfig.cdnBaseUrl,
        appVersion: appConfig._appVersion,
      );
      
      // 保存到持久化存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dev_mode', newDevMode);
    } catch (e) {
      debugPrint('切换开发者模式失败: $e');
    }
  }
  
  // 复制并更新配置
  AppConfig copyWith({
    String? appName,
    String? apiBaseUrl,
    bool? isDevMode,
    String? cdnBaseUrl,
    String? appVersion,
  }) {
    return AppConfig(
      appName: appName ?? this.appName,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      isDevMode: isDevMode ?? this.isDevMode,
      cdnBaseUrl: cdnBaseUrl ?? this.cdnBaseUrl,
      appVersion: appVersion ?? this._appVersion,
    );
  }
  
  // 是否启用日志
  bool get enableLogging {
    return !isDevMode;
  }
  
  // 默认语言
  Locale get defaultLocale => const Locale('zh');
  
  // 支持的语言
  List<Locale> get supportedLocales => const [
    Locale('zh'), // 中文
    Locale('en'), // 英文
    Locale('my'), // 缅文
    Locale('th'), // 泰文
  ];
  
  // 默认首页URL（第三方站点）
  String get defaultHomeUrl {
    switch (Environment.development) {
      case Environment.development:
        return 'http://dev.example.com/home';
      case Environment.testing:
        return 'http://test.example.com/home';
      case Environment.production:
        return 'https://example.com/home';
    }
  }
  
  // 应用版本
  String get appVersion => _appVersion;
  
  // 构建号
  String get buildNumber => '1';
  
  // 完整版本号
  String get fullVersion => '$_appVersion+$buildNumber';
  
  // 是否是开发环境
  bool get isDevelopment => Environment.development == Environment.development;
  
  // 是否是生产环境
  bool get isProduction => Environment.production == Environment.production;
  
  // 是否是测试环境
  bool get isTesting => Environment.testing == Environment.testing;
  
  // 初始化远程配置
  Future<void> initRemoteConfig(WidgetRef ref) async {
    try {
      final remoteConfig = await ref.read(remoteConfigProvider.future);
      
      // 更新首页URL
      if (remoteConfig.homeUrl.isNotEmpty) {
        ref.read(homeUrlProvider.notifier).updateUrl(remoteConfig.homeUrl);
      }
      
      // 处理其他远程配置...
      
    } catch (e) {
      // 远程配置获取失败，使用默认配置
      print('远程配置获取失败: $e');
    }
  }
} 

// 全局ProviderContainer，用于在非Widget环境中访问Provider
final container = ProviderContainer(); 

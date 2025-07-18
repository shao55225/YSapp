// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = '爱影视频';
  static const String appVersion = '1.0.0';
  
  // API配置
  static const String apiBaseUrl = 'https://api.example.com/v1';
  static const String apiPrefix = '/openapi';
  
  // 本地存储键
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userInfoKey = 'user_info';
  static const String languageCodeKey = 'language_code';
  static const String themeKey = 'app_theme';
  
  // 缓存配置
  static const int imageCacheDuration = 7; // 图片缓存天数
  static const int videoCacheDuration = 1; // 视频缓存天数
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int searchPageSize = 15;
  
  // 超时配置
  static const int connectTimeout = 15000; // 连接超时(毫秒)
  static const int receiveTimeout = 15000; // 接收超时(毫秒)
  
  // 底部导航栏索引
  static const int homeTabIndex = 0;
  static const int videoTabIndex = 1;
  static const int shopTabIndex = 2;
  static const int profileTabIndex = 3;
  
  // WebView配置
  static const String homeUrl = 'https://example.com';
  static const bool enableJavascript = true;
  static const bool enableLocalStorage = true;
} 
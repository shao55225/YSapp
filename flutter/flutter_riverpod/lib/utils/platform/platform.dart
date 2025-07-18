import 'package:flutter/foundation.dart' show kIsWeb;

// 平台检测
class PlatformUtils {
  static bool get isWeb => kIsWeb;
  
  static bool get isIOS {
    if (kIsWeb) return false;
    // 在 web 平台上，我们不能导入 dart:io
    // 所以这里需要使用条件导入
    return _PlatformImpl.isIOS;
  }
  
  static bool get isAndroid {
    if (kIsWeb) return false;
    return _PlatformImpl.isAndroid;
  }
  
  static bool get isMacOS {
    if (kIsWeb) return false;
    return _PlatformImpl.isMacOS;
  }
  
  static bool get isWindows {
    if (kIsWeb) return false;
    return _PlatformImpl.isWindows;
  }
  
  static bool get isLinux {
    if (kIsWeb) return false;
    return _PlatformImpl.isLinux;
  }
  
  static bool get isFuchsia {
    if (kIsWeb) return false;
    return _PlatformImpl.isFuchsia;
  }
  
  static String get operatingSystem {
    if (kIsWeb) return 'web';
    return _PlatformImpl.operatingSystem;
  }
  
  static String get operatingSystemVersion {
    if (kIsWeb) return 'web';
    return _PlatformImpl.operatingSystemVersion;
  }
}

// 这个类在 web 平台上不会被导入
class _PlatformImpl {
  static bool get isIOS => false;
  static bool get isAndroid => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isFuchsia => false;
  static String get operatingSystem => 'unknown';
  static String get operatingSystemVersion => 'unknown';
}

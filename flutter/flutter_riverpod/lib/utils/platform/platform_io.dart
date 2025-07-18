import 'dart:io' as io;

// 这个类只在非 web 平台上被导入
class _PlatformImpl {
  static bool get isIOS => io.Platform.isIOS;
  static bool get isAndroid => io.Platform.isAndroid;
  static bool get isMacOS => io.Platform.isMacOS;
  static bool get isWindows => io.Platform.isWindows;
  static bool get isLinux => io.Platform.isLinux;
  static bool get isFuchsia => io.Platform.isFuchsia;
  static String get operatingSystem => io.Platform.operatingSystem;
  static String get operatingSystemVersion => io.Platform.operatingSystemVersion;
}

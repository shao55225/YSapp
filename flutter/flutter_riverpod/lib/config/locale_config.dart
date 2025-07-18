import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 语言选项枚举
enum AppLanguage {
  system, // 跟随系统
  zh,     // 中文
  en,     // 英文
  my,     // 缅文
  th,     // 泰文
}

// 语言选项扩展
extension AppLanguageExtension on AppLanguage {
  // 获取语言代码
  String get code {
    switch (this) {
      case AppLanguage.system:
        return 'system';
      case AppLanguage.zh:
        return 'zh';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.my:
        return 'my';
      case AppLanguage.th:
        return 'th';
    }
  }
  
  // 获取语言名称
  String get name {
    switch (this) {
      case AppLanguage.system:
        return '跟随系统';
      case AppLanguage.zh:
        return '中文';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.my:
        return 'မြန်မာ';
      case AppLanguage.th:
        return 'ไทย';
    }
  }
  
  // 获取Locale对象
  Locale? get locale {
    switch (this) {
      case AppLanguage.system:
        return null; // 返回null表示跟随系统
      case AppLanguage.zh:
        return const Locale('zh');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.my:
        return const Locale('my');
      case AppLanguage.th:
        return const Locale('th');
    }
  }
  
  // 从字符串解析语言选项
  static AppLanguage fromCode(String code) {
    switch (code) {
      case 'zh':
        return AppLanguage.zh;
      case 'en':
        return AppLanguage.en;
      case 'my':
        return AppLanguage.my;
      case 'th':
        return AppLanguage.th;
      case 'system':
      default:
        return AppLanguage.system;
    }
  }
}

// 语言配置服务
class LocaleService {
  static const String _localeKey = 'app_locale';
  
  // 保存语言设置
  static Future<bool> saveLocale(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_localeKey, language.code);
  }
  
  // 获取保存的语言设置
  static Future<AppLanguage> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    return code != null ? AppLanguageExtension.fromCode(code) : AppLanguage.system;
  }
}

// 当前语言Provider
final currentLocaleProvider = StateNotifierProvider<LocaleNotifier, AsyncValue<AppLanguage>>((ref) {
  return LocaleNotifier();
});

// 实际Locale Provider（用于MaterialApp）
final localeProvider = Provider<Locale?>((ref) {
  final localeState = ref.watch(currentLocaleProvider);
  return localeState.when(
    data: (language) => language.locale,
    loading: () => null, // 加载中使用系统语言
    error: (_, __) => null, // 错误时使用系统语言
  );
});

// 语言状态管理器
class LocaleNotifier extends StateNotifier<AsyncValue<AppLanguage>> {
  LocaleNotifier() : super(const AsyncValue.loading()) {
    _init();
  }
  
  // 初始化，加载保存的语言设置
  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final savedLocale = await LocaleService.getSavedLocale();
      state = AsyncValue.data(savedLocale);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 更改语言设置
  Future<void> changeLocale(AppLanguage language) async {
    try {
      await LocaleService.saveLocale(language);
      state = AsyncValue.data(language);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
} 
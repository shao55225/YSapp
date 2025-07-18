import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 主题配置
class ThemeConfig {
  /// 获取当前主题
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? AppTheme.darkTheme() : AppTheme.lightTheme();
  }

  /// 获取系统主题模式
  static ThemeMode getThemeMode(String? themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// 获取主题模式名称
  static String getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'screens/main_layout.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';
import 'utils/performance_monitor.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化应用配置
  await AppConfig.initialize();
  
  // 在调试模式下启用性能监控
  if (kDebugMode) {
    PerformanceMonitor().enable();
  }
  
  runApp(
    // 使用Riverpod作为状态管理
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// 创建路由配置
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(),
      routes: [
        // 子路由在这里定义
      ],
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取应用配置
    final appConfig = ref.watch(appConfigProvider);
    
    // 创建应用基础组件
    final app = MaterialApp.router(
      title: appConfig.appName,
      
      // 使用路由配置
      routerConfig: _router,
      
      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // 国际化配置
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文
        Locale('en', 'US'), // 英文
      ],
      
      // 调试标签
      debugShowCheckedModeBanner: false,
    );

    // 在调试模式下添加性能监控覆盖层
    return PerformanceMonitor().createPerformanceOverlay(app);
  }
}

// 开发者模式按钮
class DevModeButton extends StatelessWidget {
  const DevModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.go('/dev-tools');
      },
      tooltip: '开发者工具',
      child: const Icon(Icons.developer_mode),
    );
  }
} 
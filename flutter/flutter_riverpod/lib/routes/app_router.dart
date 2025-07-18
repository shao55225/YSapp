import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/video/video_screen.dart';
import '../screens/video/video_detail_screen.dart';
import '../screens/video/video_player_screen.dart';
import '../screens/video/video_search_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/shop/cart_screen.dart';
import '../screens/shop/checkout_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/login_screen.dart';
import '../screens/profile/register_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/edit_profile_page.dart';
import '../screens/main_layout.dart';
import '../screens/dev_tools/dev_tools_screen.dart';
import '../screens/profile/sign_in_screen.dart';
import '../screens/profile/checkin_screen.dart';
import '../screens/profile/task_center_screen.dart';
import '../screens/profile/promotion_screen.dart';
import '../screens/profile/exchange_center_screen.dart';
import '../screens/profile/on_demand_history_screen.dart';
import '../screens/profile/recharge_history_screen.dart';
import '../screens/profile/message_screen.dart';
import '../screens/profile/favorites_screen.dart';
import '../screens/profile/customer_service_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // 首页
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // 影视页
          GoRoute(
            path: '/video',
            builder: (context, state) => const VideoScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return VideoDetailScreen(videoId: id);
                },
              ),
              GoRoute(
                path: 'player/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final title = state.uri.queryParameters['title'] ?? '';
                  return VideoPlayerScreen(videoId: id, title: title);
                },
              ),
              GoRoute(
                path: 'search',
                builder: (context, state) => const VideoSearchScreen(),
              ),
            ],
          ),
          
          // 商城页
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: id);
                },
              ),
              GoRoute(
                path: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
              GoRoute(
                path: 'checkout',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>?;
                  return CheckoutScreen(
                    args: CheckoutArgs(
                      cartItems: args?['cartItems'],
                      productId: args?['productId'],
                      quantity: args?['quantity'],
                    ),
                  );
                },
              ),
            ],
          ),
          
          // 个人中心页
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          
          // 开发者工具
          GoRoute(
            path: '/dev-tools',
            builder: (context, state) => const DevToolsScreen(),
          ),
        ],
      ),
      
      // 登录页面
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 注册页面
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // 设置页面
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // 编辑个人资料页面
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      
      // 签到页面
      GoRoute(
        path: '/profile/checkin',
        builder: (context) => const CheckinScreen(),
      ),
      
      // 任务中心
      GoRoute(
        path: '/profile/task_center',
        builder: (context) => const TaskCenterScreen(),
      ),
      
      // 推广系统
      GoRoute(
        path: '/profile/promotion',
        builder: (context) => const PromotionScreen(),
      ),
      
      // 兑换中心
      GoRoute(
        path: '/profile/exchange',
        builder: (context) => const ExchangeCenterScreen(),
      ),
      
      // 点播记录
      GoRoute(
        path: '/profile/on_demand_history',
        builder: (context) => const OnDemandHistoryScreen(),
      ),
      
      // 充值记录
      GoRoute(
        path: '/profile/recharge_history',
        builder: (context) => const RechargeHistoryScreen(),
      ),
      
      // 消息中心
      GoRoute(
        path: '/profile/messages',
        builder: (context) => const MessageScreen(),
      ),
      
      // 我的收藏
      GoRoute(
        path: '/profile/favorites',
        builder: (context) => const FavoritesScreen(),
      ),
      
      // 客服中心
      GoRoute(
        path: '/profile/customer_service',
        builder: (context) => const CustomerServiceScreen(),
      ),
      
      // 签到页面
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
    ],
  );
} 
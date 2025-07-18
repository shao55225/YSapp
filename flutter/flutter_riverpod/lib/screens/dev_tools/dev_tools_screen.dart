import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import 'sections/api_test_section.dart';
import 'sections/payment_test_section.dart';
import 'sections/system_info_section.dart';
import 'sections/url_test_section.dart';

/// 开发工具页面
class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发工具'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 组件展示入口
          _buildCard(
            context,
            title: '组件展示',
            description: '展示应用中的公共组件和UI元素',
            icon: Icons.widgets,
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.componentsShowcase);
            },
          ),
          
          const SizedBox(height: 16.0),
          
          // URL测试入口
          _buildCard(
            context,
            title: 'URL测试',
            description: '测试第三方站点URL可用性和预览',
            icon: Icons.link,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('URL测试')),
                    body: const UrlTestSection(),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16.0),
          
          // API测试入口
          _buildCard(
            context,
            title: 'API测试',
            description: '测试应用与CMS服务端的API连接',
            icon: Icons.http,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('API测试')),
                    body: const ApiTestSection(),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16.0),
          
          // 支付测试入口
          _buildCard(
            context,
            title: '支付测试',
            description: '测试支付相关功能',
            icon: Icons.payment,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('支付测试')),
                    body: const PaymentTestSection(),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16.0),
          
          // 系统信息入口
          _buildCard(
            context,
            title: '系统信息',
            description: '查看应用和设备系统信息',
            icon: Icons.info_outline,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('系统信息')),
                    body: const SystemInfoSection(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建卡片
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.0,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
} 
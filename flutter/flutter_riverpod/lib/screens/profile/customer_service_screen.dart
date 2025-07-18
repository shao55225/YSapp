import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final faqProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getFAQs();
  return result['faqs'] ?? [];
});

final customerServiceInfoProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getCustomerServiceInfo();
});

class CustomerServiceScreen extends ConsumerStatefulWidget {
  const CustomerServiceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends ConsumerState<CustomerServiceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客服中心'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '常见问题'),
            Tab(text: '联系客服'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildCustomerServiceTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ref.watch(faqProvider).when(
      data: (faqs) => _buildFAQList(faqs),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: '加载常见问题失败',
        onRetry: () => ref.refresh(faqProvider),
      ),
    );
  }

  Widget _buildFAQList(List<dynamic> faqs) {
    if (faqs.isEmpty) {
      return const Center(
        child: Text('暂无常见问题'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index] as Map<String, dynamic>;
        return _buildFAQItem(faq);
      },
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    final String question = faq['question'] ?? '';
    final String answer = faq['answer'] ?? '';
    final String category = faq['category'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerServiceTab() {
    return ref.watch(customerServiceInfoProvider).when(
      data: (info) => _buildCustomerServiceContent(info),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: '加载客服信息失败',
        onRetry: () => ref.refresh(customerServiceInfoProvider),
      ),
    );
  }

  Widget _buildCustomerServiceContent(Map<String, dynamic> info) {
    final String onlineServiceUrl = info['onlineServiceUrl'] ?? '';
    final String phoneNumber = info['phoneNumber'] ?? '';
    final String email = info['email'] ?? '';
    final String workingHours = info['workingHours'] ?? '';
    final List<dynamic> channels = info['channels'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent,
              size: 40,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '我们的客服团队随时为您提供帮助',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '工作时间: $workingHours',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildContactCard(
            title: '在线客服',
            icon: Icons.chat,
            iconColor: Colors.blue,
            description: '点击开始在线咨询',
            onTap: () => _launchURL(onlineServiceUrl),
            isHighlighted: true,
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            title: '电话客服',
            icon: Icons.phone,
            iconColor: Colors.green,
            description: phoneNumber,
            onTap: () => _makePhoneCall(phoneNumber),
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            title: '邮件咨询',
            icon: Icons.email,
            iconColor: Colors.orange,
            description: email,
            onTap: () => _sendEmail(email),
          ),
          const SizedBox(height: 32),
          const Text(
            '其他客服渠道',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialChannels(channels),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Card(
      elevation: isHighlighted ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isHighlighted
            ? BorderSide(color: AppColors.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialChannels(List<dynamic> channels) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: channels.map<Widget>((channel) {
        final String name = channel['name'] ?? '';
        final String iconUrl = channel['iconUrl'] ?? '';
        final String url = channel['url'] ?? '';

        return InkWell(
          onTap: () => _launchURL(url),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: iconUrl.isNotEmpty
                      ? Image.network(
                          iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.public,
                            size: 30,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.public,
                          size: 30,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开链接')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法拨打电话')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) return;
    
    final Uri uri = Uri.parse('mailto:$email?subject=客户咨询&body=');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法发送邮件')),
        );
      }
    }
  }
} 
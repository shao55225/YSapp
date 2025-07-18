import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/analytics_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final promotionDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getPromotionData();
});

class PromotionScreen extends ConsumerStatefulWidget {
  const PromotionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends ConsumerState<PromotionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _copySuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    AnalyticsService.logEvent('view_promotion_page');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    setState(() {
      _copySuccess = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('邀请码已复制到剪贴板')),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copySuccess = false;
        });
      }
    });
  }

  Future<void> _shareInviteLink(String code, String link) async {
    try {
      await Share.share(
        '我正在使用爱影视频APP，邀请你一起加入！\n\n下载链接：$link\n\n邀请码：$code',
        subject: '爱影视频APP邀请',
      );
      
      AnalyticsService.logEvent('share_invite_link');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final promotionData = ref.watch(promotionDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('推广赚钱'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '邀请好友'),
            Tab(text: '收益记录'),
          ],
        ),
      ),
      body: promotionData.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorView(
          message: '加载推广数据失败',
          onRetry: () => ref.refresh(promotionDataProvider),
        ),
      ),
    );
  }
  
  Widget _buildContent(Map<String, dynamic> data) {
    final String inviteCode = data['inviteCode'] ?? '';
    final String inviteLink = data['inviteLink'] ?? '';
    final int totalEarnings = data['totalEarnings'] ?? 0;
    final int invitedCount = data['invitedCount'] ?? 0;
    final List<dynamic> earningRecords = data['earningRecords'] ?? [];
    final List<dynamic> invitedUsers = data['invitedUsers'] ?? [];
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildInvitationTab(inviteCode, inviteLink, totalEarnings, invitedCount),
        _buildEarningsTab(earningRecords, invitedUsers),
      ],
    );
  }
  
  Widget _buildInvitationTab(String inviteCode, String inviteLink, int totalEarnings, int invitedCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildEarningsCard(totalEarnings, invitedCount),
          const SizedBox(height: 24),
          _buildPromotionRules(),
          const SizedBox(height: 24),
          _buildInviteCodeSection(inviteCode),
          const SizedBox(height: 24),
          _buildQrCodeSection(inviteLink),
          const SizedBox(height: 24),
          _buildShareButtons(inviteCode, inviteLink),
        ],
      ),
    );
  }
  
  Widget _buildEarningsCard(int totalEarnings, int invitedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '累计收益(金币)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalEarnings.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEarningsStatItem('已邀请好友', '$invitedCount 人'),
              _buildEarningsStatItem('每邀请1人奖励', '50 金币'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarningsStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPromotionRules() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推广规则',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRuleItem('好友通过您的邀请码注册，您将获得50金币奖励'),
          _buildRuleItem('好友充值VIP会员，您将获得充值金额的10%作为金币奖励'),
          _buildRuleItem('邀请的好友越多，获得的奖励越多'),
          _buildRuleItem('金币可用于购买VIP会员或兑换其他权益'),
        ],
      ),
    );
  }
  
  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInviteCodeSection(String inviteCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的邀请码',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inviteCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _copyInviteCode(inviteCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: _copySuccess
                    ? const Icon(Icons.check, color: Colors.white)
                    : const Text('复制'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQrCodeSection(String inviteLink) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '分享二维码',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: QrImage(
              data: inviteLink,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              errorStateBuilder: (context, error) => const Center(
                child: Text('二维码生成失败'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '扫描上方二维码或复制邀请码',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShareButtons(String inviteCode, String inviteLink) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _shareInviteLink(inviteCode, inviteLink),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.share),
          label: const Text('立即分享给好友'),
        ),
      ],
    );
  }
  
  Widget _buildEarningsTab(List<dynamic> earningRecords, List<dynamic> invitedUsers) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: '收益记录'),
              Tab(text: '邀请列表'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEarningsList(earningRecords),
                _buildInvitedUsersList(invitedUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarningsList(List<dynamic> earningRecords) {
    if (earningRecords.isEmpty) {
      return const Center(
        child: Text('暂无收益记录'),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: earningRecords.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final record = earningRecords[index];
        final String description = record['description'] ?? '';
        final int amount = record['amount'] ?? 0;
        final String time = record['time'] ?? '';
        
        return ListTile(
          title: Text(description),
          subtitle: Text(time),
          trailing: Text(
            '+$amount',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInvitedUsersList(List<dynamic> invitedUsers) {
    if (invitedUsers.isEmpty) {
      return const Center(
        child: Text('暂无邀请记录'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitedUsers.length,
      itemBuilder: (context, index) {
        final user = invitedUsers[index];
        final String username = user['username'] ?? '';
        final String joinTime = user['joinTime'] ?? '';
        final bool isVip = user['isVip'] ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
            ),
            title: Row(
              children: [
                Text(username),
                const SizedBox(width: 8),
                if (isVip)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'VIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text('注册时间：$joinTime'),
            trailing: isVip
                ? const Text(
                    '+50',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final checkinProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getCheckinInfo();
});

final performCheckinProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, void>((ref, _) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.performCheckin();
});

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  bool _isCheckingIn = false;

  Future<void> _performCheckin() async {
    if (_isCheckingIn) return;
    
    setState(() {
      _isCheckingIn = true;
    });
    
    try {
      await ref.refresh(performCheckinProvider);
      ref.refresh(checkinProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('签到成功，奖励已发放！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签到失败：${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkinInfo = ref.watch(checkinProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('每日签到'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: checkinInfo.when(
        data: (data) => _buildCheckinContent(data),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorView(
          message: '加载签到信息失败',
          onRetry: () => ref.refresh(checkinProvider),
        ),
      ),
    );
  }
  
  Widget _buildCheckinContent(Map<String, dynamic> data) {
    final bool hasCheckedToday = data['hasCheckedToday'] ?? false;
    final int consecutiveDays = data['consecutiveDays'] ?? 0;
    final int totalCheckins = data['totalCheckins'] ?? 0;
    final List<dynamic> rewards = data['rewards'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckinStats(hasCheckedToday, consecutiveDays, totalCheckins),
          const SizedBox(height: 24),
          _buildRewardsCalendar(rewards),
          const SizedBox(height: 32),
          if (!hasCheckedToday) _buildCheckinButton(),
        ],
      ),
    );
  }
  
  Widget _buildCheckinStats(bool hasCheckedToday, int consecutiveDays, int totalCheckins) {
    return Container(
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
            hasCheckedToday ? '今日已签到' : '今日未签到',
            style: AppTextStyles.subtitle.copyWith(
              color: hasCheckedToday ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('连续签到', '$consecutiveDays 天'),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem('总签到天数', '$totalCheckins 天'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRewardsCalendar(List<dynamic> rewards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '签到奖励',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            final bool isCollected = reward['isCollected'] ?? false;
            final String rewardAmount = reward['amount']?.toString() ?? '?';
            final String rewardType = reward['type'] ?? '金币';
            final bool isToday = reward['isToday'] ?? false;
            
            return Container(
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : isCollected
                        ? Colors.grey.withOpacity(0.2)
                        : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: AppColors.primaryColor, width: 2)
                    : Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '第${index + 1}天',
                    style: TextStyle(
                      fontSize: 10,
                      color: isCollected ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rewardAmount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCollected ? Colors.grey : AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rewardType,
                    style: TextStyle(
                      fontSize: 10,
                      color: isCollected ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (isCollected)
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildCheckinButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isCheckingIn ? null : _performCheckin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _isCheckingIn
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '立即签到',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 
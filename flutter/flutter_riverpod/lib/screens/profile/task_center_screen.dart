import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final tasksProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getTasks();
});

final completeTaskProvider = FutureProvider.autoDispose.family<bool, int>((ref, taskId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.completeTask(taskId);
});

class TaskCenterScreen extends ConsumerStatefulWidget {
  const TaskCenterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TaskCenterScreen> createState() => _TaskCenterScreenState();
}

class _TaskCenterScreenState extends ConsumerState<TaskCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<int, bool> _processingTasks = {};

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

  Future<void> _claimReward(int taskId) async {
    if (_processingTasks[taskId] == true) return;
    
    setState(() {
      _processingTasks[taskId] = true;
    });
    
    try {
      await ref.read(completeTaskProvider(taskId).future);
      ref.refresh(tasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('奖励领取成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('领取失败：${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _processingTasks[taskId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务中心'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '日常任务'),
            Tab(text: '成长任务'),
          ],
        ),
      ),
      body: ref.watch(tasksProvider).when(
        data: (data) => _buildTasksContent(data),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorView(
          message: '加载任务信息失败',
          onRetry: () => ref.refresh(tasksProvider),
        ),
      ),
    );
  }
  
  Widget _buildTasksContent(Map<String, dynamic> data) {
    final dailyTasks = data['dailyTasks'] as List<dynamic>? ?? [];
    final growthTasks = data['growthTasks'] as List<dynamic>? ?? [];
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTaskList(dailyTasks),
        _buildTaskList(growthTasks),
      ],
    );
  }
  
  Widget _buildTaskList(List<dynamic> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('暂无任务'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tasks.map((task) => _buildTaskItem(task)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildTaskItem(Map<String, dynamic> task) {
    final int taskId = task['id'] ?? 0;
    final String title = task['title'] ?? '';
    final String description = task['description'] ?? '';
    final String rewardType = task['rewardType'] ?? '金币';
    final int rewardAmount = task['rewardAmount'] ?? 0;
    final int currentProgress = task['currentProgress'] ?? 0;
    final int targetProgress = task['targetProgress'] ?? 1;
    final bool completed = task['completed'] ?? false;
    final bool claimed = task['claimed'] ?? false;
    
    final double progressPercent = targetProgress > 0 
        ? (currentProgress / targetProgress).clamp(0.0, 1.0)
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '完成进度',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: progressPercent,
                                  backgroundColor: Colors.grey[200],
                                  color: AppColors.primaryColor,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$currentProgress/$targetProgress',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              Text(
                                '奖励',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '$rewardAmount $rewardType',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildTaskButtonSection(taskId, completed, claimed),
        ],
      ),
    );
  }
  
  Widget _buildTaskButtonSection(int taskId, bool completed, bool claimed) {
    final bool isProcessing = _processingTasks[taskId] == true;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (claimed)
            const Chip(
              label: Text('已领取'),
              backgroundColor: Color(0xFFE0E0E0),
              labelStyle: TextStyle(color: Colors.grey),
            )
          else if (completed)
            ElevatedButton(
              onPressed: isProcessing ? null : () => _claimReward(taskId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('领取奖励'),
            )
          else
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('未完成'),
            ),
          TextButton(
            onPressed: () {
              // Navigate to the corresponding feature
            },
            child: const Text('去完成 >'),
          ),
        ],
      ),
    );
  }
} 
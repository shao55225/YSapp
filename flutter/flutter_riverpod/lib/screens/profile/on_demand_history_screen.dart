import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final onDemandHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getOnDemandHistory();
  return result['records'] ?? [];
});

class OnDemandHistoryScreen extends ConsumerStatefulWidget {
  const OnDemandHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnDemandHistoryScreen> createState() => _OnDemandHistoryScreenState();
}

class _OnDemandHistoryScreenState extends ConsumerState<OnDemandHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.getOnDemandHistory(page: _currentPage + 1);
      final newRecords = result['records'] as List<dynamic>? ?? [];

      if (newRecords.isEmpty) {
        setState(() {
          _hasReachedEnd = true;
        });
      } else {
        _currentPage++;
        ref.refresh(onDemandHistoryProvider);
      }
    } catch (e) {
      print('加载更多记录失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('点播记录'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: ref.watch(onDemandHistoryProvider).when(
        data: (records) => _buildHistoryList(records),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorView(
          message: '加载点播记录失败',
          onRetry: () => ref.refresh(onDemandHistoryProvider),
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<dynamic> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无点播记录'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: records.length + (_hasReachedEnd ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == records.length) {
          return _isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }
        
        final record = records[index];
        return _buildHistoryItem(record, index);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> record, int index) {
    final String title = record['title'] ?? '未知视频';
    final String coverUrl = record['coverUrl'] ?? '';
    final String demandTime = record['demandTime'] ?? '';
    final int goldCost = record['goldCost'] ?? 0;
    final String status = record['status'] ?? '点播成功';
    final String videoId = record['videoId']?.toString() ?? '';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case '点播成功':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case '处理中':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case '已失败':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 跳转到视频详情页
          if (videoId.isNotEmpty) {
            Navigator.pushNamed(
              context, 
              '/video/detail',
              arguments: {'id': videoId},
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 80,
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '点播时间：$demandTime',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 14,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '消费 $goldCost 金币',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              statusIcon,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
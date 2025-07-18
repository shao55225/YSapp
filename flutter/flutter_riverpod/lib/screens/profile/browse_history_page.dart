import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/services/api_service.dart';
import '../../api/models/browse_history_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../theme/app_colors.dart';

// 获取浏览历史记录的Provider
final browseHistoryProvider = FutureProvider.autoDispose.family<List<BrowseHistoryModel>, int>(
  (ref, page) async {
    final apiService = ref.read(apiServiceProvider);
    final data = await apiService.getBrowseHistory(page: page);
    
    final List<dynamic> history = data['records'] ?? [];
    return history.map((item) => BrowseHistoryModel.fromJson(item)).toList();
  },
);

// 总页数Provider
final totalPagesProvider = StateProvider<int>((ref) => 1);

class BrowseHistoryPage extends ConsumerStatefulWidget {
  const BrowseHistoryPage({Key? key}) : super(key: key);

  @override
  _BrowseHistoryPageState createState() => _BrowseHistoryPageState();
}

class _BrowseHistoryPageState extends ConsumerState<BrowseHistoryPage> {
  int _currentPage = 1;
  
  // 格式化日期时间
  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // 今天
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // 昨天
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays <= 7) {
      // 一周内
      final weekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][dateTime.weekday % 7];
      return '$weekday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 更早
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsyncValue = ref.watch(browseHistoryProvider(_currentPage));
    final totalPages = ref.watch(totalPagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('观看历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearHistoryDialog();
            },
          ),
        ],
      ),
      body: historyAsyncValue.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无观看历史', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(browseHistoryProvider(_currentPage));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildHistoryItem(item);
                    },
                  ),
                ),
              ),
              
              // 分页控制器
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1 
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.navigate_before),
                      ),
                      Text('$_currentPage / $totalPages'),
                      IconButton(
                        onPressed: _currentPage < totalPages 
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.navigate_next),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: '加载历史记录失败: $e',
          onRetry: () => ref.refresh(browseHistoryProvider(_currentPage)),
        ),
      ),
    );
  }
  
  // 构建历史记录项
  Widget _buildHistoryItem(BrowseHistoryModel item) {
    final formattedTime = _formatDateTime(item.createTime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/video/detail?id=${item.vodId}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 视频缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: item.vodPic != null 
                    ? Image.network(
                        item.vodPic!,
                        width: 100,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 56,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie),
                      ),
              ),
              const SizedBox(width: 12),
              
              // 视频信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      item.vodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // 视频信息（状态、语言、年份、地区）
                    Row(
                      children: [
                        if (item.vodRemarks != null)
                          _buildTag(item.vodRemarks!, AppColors.primary),
                        if (item.vodLang != null)
                          _buildTag(item.vodLang!, Colors.blue),
                        if (item.vodYear != null)
                          _buildTag(item.vodYear!, Colors.green),
                        if (item.vodArea != null)
                          _buildTag(item.vodArea!, Colors.orange),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 观看时间
                    Text(
                      '观看于 $formattedTime',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 收费标记
              if (item.chargingMode == 1)
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建标签
  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }
  
  // 清除历史记录弹窗
  Future<void> _showClearHistoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除历史记录'),
        content: const Text('确定要清除所有观看历史记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.clearBrowseHistory();
        
        // 刷新历史记录
        ref.refresh(browseHistoryProvider(_currentPage));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('历史记录已清除')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除历史记录失败: $e')),
        );
      }
    }
  }
} 
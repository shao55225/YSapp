import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../theme/app_colors.dart';

// 金币记录Provider
final goldRecordsProvider = FutureProvider.autoDispose.family<List<dynamic>, int>((ref, page) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getGoldRecords(page: page);
  return result['records'] ?? [];
});

// 总页数Provider
final totalPagesProvider = StateProvider<int>((ref) => 1);

// 金币信息Provider
final goldInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getGoldInfo();
});

class GoldRecordsPage extends ConsumerStatefulWidget {
  const GoldRecordsPage({Key? key}) : super(key: key);

  @override
  _GoldRecordsPageState createState() => _GoldRecordsPageState();
}

class _GoldRecordsPageState extends ConsumerState<GoldRecordsPage> {
  int _currentPage = 1;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  
  @override
  Widget build(BuildContext context) {
    final goldRecordsAsync = ref.watch(goldRecordsProvider(_currentPage));
    final goldInfoAsync = ref.watch(goldInfoProvider);
    final totalPages = ref.watch(totalPagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('金币记录'),
      ),
      body: Column(
        children: [
          // 金币概览卡片
          goldInfoAsync.when(
            data: (goldInfo) => _buildGoldInfoCard(goldInfo),
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // 金币记录列表
          Expanded(
            child: goldRecordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无金币交易记录', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(goldRecordsProvider(_currentPage));
                    ref.refresh(goldInfoProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _buildRecordItem(record);
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorView(
                message: '加载金币记录失败: $error',
                onRetry: () => ref.refresh(goldRecordsProvider(_currentPage)),
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
      ),
    );
  }
  
  // 构建金币概览卡片
  Widget _buildGoldInfoCard(Map<String, dynamic> goldInfo) {
    final int remainGold = goldInfo['remainGold'] ?? 0;
    final int totalIncome = goldInfo['totalIncome'] ?? 0;
    final int totalExpend = goldInfo['totalExpend'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[700]!, Colors.amber[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '当前金币余额',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$remainGold',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '总收入',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '+$totalIncome',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '总支出',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '-$totalExpend',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建记录项
  Widget _buildRecordItem(Map<String, dynamic> record) {
    // 提取记录信息
    final int id = record['id'] ?? 0;
    final int gold = record['gold'] ?? 0;
    final String type = record['type'] ?? '';
    final String remark = record['remark'] ?? '';
    final String? createTime = record['createTime'];
    final int opType = record['opType'] ?? 0; // 1: 收入, 2: 支出
    
    // 格式化时间
    final String formattedTime = createTime != null 
        ? _dateFormat.format(DateTime.parse(createTime))
        : '未知时间';
    
    // 记录图标
    IconData recordIcon;
    Color iconColor;
    
    if (opType == 1) {
      // 收入
      iconColor = Colors.green;
      
      if (type.contains('充值') || type.contains('购买')) {
        recordIcon = Icons.add_card;
      } else if (type.contains('赠送') || type.contains('奖励')) {
        recordIcon = Icons.card_giftcard;
      } else {
        recordIcon = Icons.arrow_circle_down;
      }
    } else {
      // 支出
      iconColor = Colors.redAccent;
      
      if (type.contains('购买') || type.contains('兑换')) {
        recordIcon = Icons.shopping_bag;
      } else if (type.contains('观看') || type.contains('播放')) {
        recordIcon = Icons.play_circle;
      } else {
        recordIcon = Icons.arrow_circle_up;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 记录图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                recordIcon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            
            // 记录详情
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remark,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // 金币变动
            Text(
              opType == 1 ? '+$gold' : '-$gold',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: opType == 1 ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
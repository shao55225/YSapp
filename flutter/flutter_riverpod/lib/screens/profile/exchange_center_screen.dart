import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final exchangeItemsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getExchangeItems();
  return result['items'] ?? [];
});

final exchangeHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getExchangeHistory();
  return result['history'] ?? [];
});

final exchangeItemProvider = FutureProvider.autoDispose.family<bool, int>((ref, itemId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.exchangeItem(itemId);
});

class ExchangeCenterScreen extends ConsumerStatefulWidget {
  const ExchangeCenterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExchangeCenterScreen> createState() => _ExchangeCenterScreenState();
}

class _ExchangeCenterScreenState extends ConsumerState<ExchangeCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<int, bool> _processingExchanges = {};

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

  Future<void> _exchangeItem(int itemId, int requiredGold) async {
    if (_processingExchanges[itemId] == true) return;
    
    setState(() {
      _processingExchanges[itemId] = true;
    });
    
    try {
      await ref.read(exchangeItemProvider(itemId).future);
      
      // 刷新数据
      ref.refresh(exchangeItemsProvider);
      ref.refresh(exchangeHistoryProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('兑换成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('兑换失败：${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _processingExchanges[itemId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('兑换中心'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '可兑换商品'),
            Tab(text: '兑换记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExchangeItemsTab(),
          _buildExchangeHistoryTab(),
        ],
      ),
    );
  }
  
  Widget _buildExchangeItemsTab() {
    final exchangeItems = ref.watch(exchangeItemsProvider);
    
    return exchangeItems.when(
      data: (items) => _buildItemsGrid(items),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: '加载兑换商品失败',
        onRetry: () => ref.refresh(exchangeItemsProvider),
      ),
    );
  }
  
  Widget _buildItemsGrid(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('暂无可兑换商品'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildExchangeItemCard(item);
      },
    );
  }
  
  Widget _buildExchangeItemCard(Map<String, dynamic> item) {
    final int id = item['id'] ?? 0;
    final String name = item['name'] ?? '';
    final String imageUrl = item['imageUrl'] ?? '';
    final int goldRequired = item['goldRequired'] ?? 0;
    final String description = item['description'] ?? '';
    final int stock = item['stock'] ?? 0;
    final bool isProcessing = _processingExchanges[id] == true;
    final bool isOutOfStock = stock <= 0;
    
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$goldRequired 金币',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOutOfStock || isProcessing 
                    ? null 
                    : () => _exchangeItem(id, goldRequired),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isOutOfStock ? '已售罄' : '立即兑换',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExchangeHistoryTab() {
    final exchangeHistory = ref.watch(exchangeHistoryProvider);
    
    return exchangeHistory.when(
      data: (history) => _buildHistoryList(history),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: '加载兑换记录失败',
        onRetry: () => ref.refresh(exchangeHistoryProvider),
      ),
    );
  }
  
  Widget _buildHistoryList(List<dynamic> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text('暂无兑换记录'),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final record = history[index];
        return _buildHistoryItem(record);
      },
    );
  }
  
  Widget _buildHistoryItem(Map<String, dynamic> record) {
    final String itemName = record['itemName'] ?? '';
    final int goldCost = record['goldCost'] ?? 0;
    final String exchangeTime = record['exchangeTime'] ?? '';
    final String status = record['status'] ?? '处理中';
    final String imageUrl = record['imageUrl'] ?? '';
    
    Color statusColor;
    switch (status) {
      case '已完成':
        statusColor = Colors.green;
        break;
      case '处理中':
        statusColor = Colors.orange;
        break;
      case '已失败':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          itemName,
          style: AppTextStyles.subtitle,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  '$goldCost 金币',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '兑换时间：$exchangeTime',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
} 
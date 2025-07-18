import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../theme/app_colors.dart';

// 套餐分组数据提供者
final packageGroupsProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getPackageGroups();
  return result ?? [];
});

// 根据分组ID获取套餐列表
final packagesProvider = FutureProvider.family<List<dynamic>, int?>((ref, groupId) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getPackages(groupId: groupId);
  return result ?? [];
});

// 当前选择的套餐分组
final selectedGroupProvider = StateProvider<int?>((ref) => null);

class PackageListPage extends ConsumerStatefulWidget {
  const PackageListPage({Key? key}) : super(key: key);

  @override
  _PackageListPageState createState() => _PackageListPageState();
}

class _PackageListPageState extends ConsumerState<PackageListPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(packageGroupsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员套餐'),
      ),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Text('暂无可用套餐', style: TextStyle(color: Colors.grey)),
            );
          }
          
          // 初始化TabController
          if (_tabController == null || _tabController!.length != groups.length) {
            _tabController = TabController(length: groups.length, vsync: this);
            // 当标签页改变时更新选中的分组
            _tabController!.addListener(() {
              if (_tabController!.index != _tabController!.previousIndex && !_tabController!.indexIsChanging) {
                ref.read(selectedGroupProvider.notifier).state = groups[_tabController!.index]['id'];
              }
            });
            
            // 初始化第一个选中的分组
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedGroupProvider.notifier).state = groups[0]['id'];
            });
          }
          
          return Column(
            children: [
              // 分组标签页
              TabBar(
                controller: _tabController,
                tabs: groups.map<Widget>((group) => 
                  Tab(text: group['name'] ?? '未命名'),
                ).toList(),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                isScrollable: groups.length > 3,
              ),
              
              // 套餐列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: groups.map((group) => 
                    _buildPackageListView(group['id']),
                  ).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorView(
          message: '加载套餐分组失败: $error',
          onRetry: () => ref.refresh(packageGroupsProvider),
        ),
      ),
    );
  }
  
  // 构建套餐列表视图
  Widget _buildPackageListView(int? groupId) {
    final packagesAsync = ref.watch(packagesProvider(groupId));
    
    return packagesAsync.when(
      data: (packages) {
        if (packages.isEmpty) {
          return const Center(
            child: Text('该分组下暂无套餐', style: TextStyle(color: Colors.grey)),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return _buildPackageItem(package);
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(
        message: '加载套餐列表失败: $error',
        onRetry: () => ref.refresh(packagesProvider(groupId)),
      ),
    );
  }
  
  // 构建套餐项
  Widget _buildPackageItem(dynamic package) {
    // 提取套餐信息
    final int id = package['id'] ?? 0;
    final String name = package['name'] ?? '未命名套餐';
    final String? pic = package['pic'];
    final double price = (package['price'] ?? 0.0).toDouble();
    final int validDays = package['validDays'] ?? 0;
    final String? remarks = package['remarks'];
    final int? originalPrice = package['originalPrice'];
    final int status = package['status'] ?? 0;
    
    // 如果套餐不可用，不显示
    if (status != 1) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onPackageSelected(package),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 套餐图片
              if (pic != null && pic.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pic,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              
              const SizedBox(width: 16),
              
              // 套餐信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '有效期 $validDays 天',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (remarks != null && remarks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        remarks,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // 价格信息
                    Row(
                      children: [
                        Text(
                          '¥$price',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (originalPrice != null && originalPrice > price)
                          Text(
                            '¥$originalPrice',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _onPackageSelected(package),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('立即购买'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 处理套餐选择
  void _onPackageSelected(dynamic package) {
    // 跳转到支付页面
    context.push('/payment', extra: {
      'packageId': package['id'],
      'packageName': package['name'],
      'price': package['price'],
    });
  }
} 
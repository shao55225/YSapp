import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/services/payment_service.dart';
import '../../../api/services/shop_service.dart';
import '../widgets/test_card.dart';
import '../widgets/result_dialog.dart';

class PaymentTestSection extends StatefulWidget {
  final WidgetRef ref;
  
  const PaymentTestSection({Key? key, required this.ref}) : super(key: key);

  @override
  State<PaymentTestSection> createState() => _PaymentTestSectionState();
}

class _PaymentTestSectionState extends State<PaymentTestSection> {
  List<dynamic> _packageList = [];
  List<dynamic> _packageGroups = [];
  String? _selectedPackageId;
  bool _isLoading = false;
  String? _orderId;
  final _cardAccountController = TextEditingController();
  final _cardPasswordController = TextEditingController();

  @override
  void dispose() {
    _cardAccountController.dispose();
    _cardPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentService = widget.ref.read(paymentServiceProvider);
    final shopService = widget.ref.read(shopServiceProvider);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TestCard(
          title: '支付配置测试',
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final config = await paymentService.getPayConfig();
                  showResultDialog(context, '支付配置', {
                    'wechatEnabled': config.wechatEnabled,
                    'aliEnabled': config.aliEnabled,
                    'appleEnabled': config.appleEnabled,
                    'googleEnabled': config.googleEnabled,
                  });
                } catch (e) {
                  showResultDialog(context, '支付配置', {'error': e.toString()});
                }
              },
              child: const Text('获取支付配置'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                try {
                  final rate = await paymentService.getGoldRate();
                  showResultDialog(context, '金币汇率', {'rate': rate});
                } catch (e) {
                  showResultDialog(context, '金币汇率', {'error': e.toString()});
                }
              },
              child: const Text('获取金币汇率'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                try {
                  final goldInfo = await paymentService.getGoldInfo();
                  showResultDialog(context, '金币信息', {
                    'goldBalance': goldInfo.goldBalance,
                    'totalRecharge': goldInfo.totalRecharge,
                    'totalConsume': goldInfo.totalConsume,
                  });
                } catch (e) {
                  showResultDialog(context, '金币信息', {'error': e.toString()});
                }
              },
              child: const Text('获取金币信息'),
            ),
          ],
        ),
        
        TestCard(
          title: '套餐列表测试',
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        final packages = await shopService.getPackageList(type: 1); // VIP套餐
                        setState(() {
                          _packageList = packages;
                          _isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        showResultDialog(context, '获取VIP套餐', {'error': e.toString()});
                      }
                    },
                    child: const Text('获取VIP套餐'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        final packages = await shopService.getPackageList(type: 2); // 金币套餐
                        setState(() {
                          _packageList = packages;
                          _isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        showResultDialog(context, '获取金币套餐', {'error': e.toString()});
                      }
                    },
                    child: const Text('获取金币套餐'),
                  ),
                ),
              ],
            ),
            
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  final groups = await shopService.getPackageGroups();
                  setState(() {
                    _packageGroups = groups;
                    _isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  showResultDialog(context, '获取套餐分组', {'error': e.toString()});
                }
              },
              child: const Text('获取套餐分组'),
            ),
            
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_packageList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('套餐列表:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _packageList.map((package) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPackageId = package.id;
                          });
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedPackageId == package.id ? Colors.blue : Colors.grey,
                              width: _selectedPackageId == package.id ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                package.name,
                                style: TextStyle(
                                  fontWeight: _selectedPackageId == package.id 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '¥${package.price / 100}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (package.days != null)
                                Text('${package.days}天'),
                              if (package.goldNum != null)
                                Text('${package.goldNum}金币'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            else if (_packageGroups.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('套餐分组:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _packageGroups.length,
                    itemBuilder: (context, index) {
                      final group = _packageGroups[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (group.packages != null && group.packages.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: group.packages.map<Widget>((package) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPackageId = package.id;
                                    });
                                  },
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedPackageId == package.id ? Colors.blue : Colors.grey,
                                        width: _selectedPackageId == package.id ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          package.name,
                                          style: TextStyle(
                                            fontWeight: _selectedPackageId == package.id 
                                                ? FontWeight.bold 
                                                : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          '¥${package.price / 100}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (package.days != null)
                                          Text('${package.days}天'),
                                        if (package.goldNum != null)
                                          Text('${package.goldNum}金币'),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
        
        if (_selectedPackageId != null)
          TestCard(
            title: '支付测试',
            children: [
              Text('已选择套餐ID: $_selectedPackageId', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await shopService.exchangePackage(_selectedPackageId!);
                    if (result.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('兑换成功')),
                      );
                    } else {
                      showResultDialog(context, '兑换套餐', {'message': result.message ?? '兑换失败'});
                    }
                  } catch (e) {
                    showResultDialog(context, '兑换套餐', {'error': e.toString()});
                  }
                },
                child: const Text('兑换套餐'),
              ),
            ],
          ),
          
        TestCard(
          title: '卡密测试',
          children: [
            TextField(
              controller: _cardAccountController,
              decoration: const InputDecoration(
                labelText: '卡号',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cardPasswordController,
              decoration: const InputDecoration(
                labelText: '卡密',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_cardAccountController.text.isEmpty || _cardPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('卡号和卡密不能为空')),
                  );
                  return;
                }
                
                try {
                  await paymentService.activateCard(
                    _cardAccountController.text,
                    _cardPasswordController.text,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('卡密激活成功')),
                  );
                } catch (e) {
                  showResultDialog(context, '卡密激活', {'error': e.toString()});
                }
              },
              child: const Text('激活卡密'),
            ),
          ],
        ),
        
        TestCard(
          title: '订单测试',
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '订单ID',
                border: OutlineInputBorder(),
                hintText: '输入订单ID后测试查询',
              ),
              onChanged: (value) {
                setState(() {
                  _orderId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            if (_orderId != null && _orderId!.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final status = await paymentService.getPayStatus(_orderId!);
                          showResultDialog(context, '支付状态', {
                            'isPaid': status.isPaid,
                            'payUrl': status.payUrl,
                          });
                        } catch (e) {
                          showResultDialog(context, '支付状态', {'error': e.toString()});
                        }
                      },
                      child: const Text('查询支付状态'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final status = await paymentService.getOrderStatus(_orderId!);
                          showResultDialog(context, '订单状态', {
                            'status': status.status,
                            'message': status.message,
                          });
                        } catch (e) {
                          showResultDialog(context, '订单状态', {'error': e.toString()});
                        }
                      },
                      child: const Text('查询订单状态'),
                    ),
                  ),
                ],
              ),
            
            ElevatedButton(
              onPressed: () async {
                try {
                  final orders = await paymentService.getOrders(limit: 10, offset: 0);
                  
                  if (orders.orders.isEmpty) {
                    showResultDialog(context, '订单列表', {'message': '没有订单记录'});
                    return;
                  }
                  
                  final orderList = orders.orders.map((order) => {
                    'id': order.id,
                    'status': order.status,
                    'amount': order.amount / 100,
                    'createdAt': order.createdAt,
                    'packageName': order.packageName,
                  }).toList();
                  
                  showResultDialog(context, '订单列表', {'orders': orderList});
                  
                  // 自动设置第一个订单ID
                  if (orders.orders.isNotEmpty) {
                    setState(() {
                      _orderId = orders.orders[0].id;
                    });
                  }
                } catch (e) {
                  showResultDialog(context, '订单列表', {'error': e.toString()});
                }
              },
              child: const Text('获取订单列表'),
            ),
          ],
        ),
      ],
    );
  }
} 
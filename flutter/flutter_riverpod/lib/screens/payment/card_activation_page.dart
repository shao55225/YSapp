import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';

class CardActivationPage extends ConsumerStatefulWidget {
  const CardActivationPage({Key? key}) : super(key: key);

  @override
  _CardActivationPageState createState() => _CardActivationPageState();
}

class _CardActivationPageState extends ConsumerState<CardActivationPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardCodeController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _activationResult;
  String? _errorMessage;

  @override
  void dispose() {
    _cardCodeController.dispose();
    super.dispose();
  }

  // 激活卡密
  Future<void> _activateCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _activationResult = null;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.activateCard(_cardCodeController.text.trim());
      
      setState(() {
        _isLoading = false;
        _activationResult = result;
      });
      
      // 显示成功弹窗
      _showSuccessDialog(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('激活失败: $_errorMessage')),
      );
    }
  }
  
  // 显示激活成功对话框
  void _showSuccessDialog(Map<String, dynamic> result) {
    final String cardType = result['cardType'] ?? '未知类型';
    final String value = result['value'] ?? '';
    final String days = result['days'] != null ? '${result['days']} 天' : '';
    
    String resultMessage = '';
    if (cardType == 'vip' && days.isNotEmpty) {
      resultMessage = '成功激活 $days VIP会员';
    } else if (cardType == 'gold' && value.isNotEmpty) {
      resultMessage = '成功获得 $value 金币';
    } else {
      resultMessage = '卡密激活成功';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('激活成功'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resultMessage),
            const SizedBox(height: 16),
            const Text('感谢您的支持！'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cardCodeController.clear();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡密激活'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 卡密激活说明卡片
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          '卡密使用说明',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. 输入卡密，点击激活按钮即可使用',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '2. 卡密激活成功后，相应权益将立即生效',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '3. 卡密仅能使用一次，激活后将失效',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '4. 如遇问题，请联系客服解决',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 激活表单
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '请输入卡密',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cardCodeController,
                    decoration: InputDecoration(
                      hintText: '请输入您的卡密',
                      prefixIcon: const Icon(Icons.vpn_key),
                      suffixIcon: _cardCodeController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _cardCodeController.clear()),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入卡密';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 辅助功能按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.content_paste, size: 16),
                        label: const Text('粘贴'),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data != null && data.text != null) {
                            setState(() {
                              _cardCodeController.text = data.text!.trim();
                            });
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('清空'),
                        onPressed: () {
                          setState(() {
                            _cardCodeController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 激活按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _activateCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('立即激活', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            
            // 错误信息
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 客服联系提示
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.headset_mic, size: 16),
                label: const Text('遇到问题？联系客服'),
                onPressed: () {
                  // 实现联系客服功能
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
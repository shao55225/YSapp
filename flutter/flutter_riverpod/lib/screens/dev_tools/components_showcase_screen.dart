import 'package:flutter/material.dart';
import 'dart:io';

import '../../widgets/common/loading_button.dart';
import '../../widgets/common/error_message.dart';
import '../../widgets/common/avatar_picker.dart';
import '../../widgets/common/verification_code_input.dart';

/// 组件展示页面，用于展示和测试我们创建的公共组件
class ComponentsShowcaseScreen extends StatefulWidget {
  const ComponentsShowcaseScreen({Key? key}) : super(key: key);

  @override
  _ComponentsShowcaseScreenState createState() => _ComponentsShowcaseScreenState();
}

class _ComponentsShowcaseScreenState extends State<ComponentsShowcaseScreen> {
  bool _isLoading = false;
  String? _avatarUrl;
  final _codeController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // 模拟发送验证码操作
  Future<void> _sendVerificationCode() async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 2));
    
    // 50%的概率模拟失败
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      throw Exception('模拟的发送验证码失败');
    }
  }

  // 显示消息提示
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 头像更改处理
  void _onAvatarChanged(File file) {
    setState(() {
      // 在实际应用中，这里会上传头像并获取URL
      _showMessage('头像已选择: ${file.path}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('组件展示'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 加载按钮组件展示
            _buildSectionTitle('加载按钮 LoadingButton'),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: () {
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                  },
                  child: const Text('默认按钮'),
                ),
                
                LoadingButton.outlined(
                  isLoading: _isLoading,
                  onPressed: () {
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                  },
                  child: const Text('轮廓按钮'),
                ),
                
                LoadingButton.text(
                  isLoading: _isLoading,
                  onPressed: () {
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                  },
                  child: const Text('文本按钮'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 错误消息组件展示
            _buildSectionTitle('错误消息 ErrorMessage'),
            ErrorMessage(
              message: '这是一个标准错误消息',
              onRetry: () => _showMessage('点击了重试按钮'),
            ),
            
            const SizedBox(height: 16),
            
            ErrorMessage.card(
              message: '这是一个卡片式错误消息',
              onRetry: () => _showMessage('点击了重试按钮'),
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            
            const SizedBox(height: 16),
            
            ErrorMessage.inline(
              message: '这是一个内联错误消息',
              onRetry: () => _showMessage('点击了重试按钮'),
            ),
            
            const SizedBox(height: 32),
            
            // 头像选择器组件展示
            _buildSectionTitle('头像选择器 AvatarPicker'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AvatarPicker(
                  avatarUrl: _avatarUrl,
                  onAvatarChanged: _onAvatarChanged,
                  size: 80,
                ),
                
                AvatarPicker(
                  avatarUrl: null,
                  onAvatarChanged: _onAvatarChanged,
                  size: 80,
                  borderColor: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
                
                const AvatarPicker(
                  avatarUrl: null,
                  size: 80,
                  editable: false,
                  placeholderIcon: Icons.business,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 验证码输入组件展示
            _buildSectionTitle('验证码输入 VerificationCodeInput'),
            VerificationCodeInput(
              controller: _codeController,
              onSendCode: _sendVerificationCode,
              buttonText: '发送验证码',
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                _showMessage('验证码：${_codeController.text}');
              },
              child: const Text('提交验证码'),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  // 构建部分标题
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
} 
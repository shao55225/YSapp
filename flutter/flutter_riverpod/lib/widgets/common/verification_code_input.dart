import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 验证码输入组件
///
/// 提供验证码输入框和发送验证码按钮，带有倒计时功能
class VerificationCodeInput extends StatefulWidget {
  /// 验证码输入控制器
  final TextEditingController controller;
  
  /// 发送验证码回调
  final Future<void> Function() onSendCode;
  
  /// 倒计时时长（秒）
  final int countdownDuration;
  
  /// 输入框装饰
  final InputDecoration? decoration;
  
  /// 按钮文本
  final String buttonText;

  /// 创建验证码输入组件
  const VerificationCodeInput({
    Key? key,
    required this.controller,
    required this.onSendCode,
    this.countdownDuration = 60,
    this.decoration,
    this.buttonText = '获取验证码',
  }) : super(key: key);

  @override
  _VerificationCodeInputState createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  bool _isLoading = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 发送验证码
  Future<void> _sendCode() async {
    if (_countdown > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSendCode();
      
      // 开始倒计时
      setState(() {
        _countdown = widget.countdownDuration;
        _startCountdown();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送验证码失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 开始倒计时
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = InputDecoration(
      labelText: '验证码',
      hintText: '请输入验证码',
      prefixIcon: const Icon(Icons.security),
      border: const OutlineInputBorder(),
    );
    
    final effectiveDecoration = widget.decoration ?? defaultDecoration;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            decoration: effectiveDecoration,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入验证码';
              }
              if (value.length < 4) {
                return '验证码格式错误';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 56.0,
          child: ElevatedButton(
            onPressed: (_countdown > 0 || _isLoading) ? null : _sendCode,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _countdown > 0 ? '$_countdown秒' : widget.buttonText,
                  ),
          ),
        ),
      ],
    );
  }
} 
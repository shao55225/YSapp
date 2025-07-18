import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/services/user_service.dart';
import '../widgets/test_card.dart';
import '../widgets/result_dialog.dart';

class UserTestSection extends ConsumerStatefulWidget {
  const UserTestSection({Key? key}) : super(key: key);

  @override
  ConsumerState<UserTestSection> createState() => _UserTestSectionState();
}

class _UserTestSectionState extends ConsumerState<UserTestSection> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final userService = ref.read(userServiceProvider);
    final isLoggedIn = await userService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    
    if (isLoggedIn) {
      _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userService = ref.read(userServiceProvider);
      final userInfo = await userService.getUserInfo();
      setState(() {
        _userInfo = {
          'id': userInfo.id,
          'userName': userInfo.userName,
          'nickname': userInfo.nickname,
          'headImg': userInfo.headImg,
          'sex': userInfo.sex,
          'phone': userInfo.phone,
          'email': userInfo.email,
        };
      });
    } catch (e) {
      showResultDialog(context, '获取用户信息', {'error': e.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = ref.read(userServiceProvider);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TestCard(
          title: '登录状态',
          children: [
            Text('当前状态: ${_isLoggedIn ? '已登录' : '未登录'}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isLoggedIn ? Colors.green : Colors.red,
                )),
            
            if (_isLoggedIn && _userInfo != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('用户ID: ${_userInfo!['id']}'),
                  Text('用户名: ${_userInfo!['userName']}'),
                  if (_userInfo!['nickname'] != null)
                    Text('昵称: ${_userInfo!['nickname']}'),
                  if (_userInfo!['phone'] != null)
                    Text('手机: ${_userInfo!['phone']}'),
                  if (_userInfo!['email'] != null)
                    Text('邮箱: ${_userInfo!['email']}'),
                  if (_userInfo!['headImg'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(_userInfo!['headImg']),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) => const AssetImage('assets/default_avatar.png'),
                        ),
                      ),
                    ),
                ],
              ),
            
            ElevatedButton(
              onPressed: () async {
                if (_isLoggedIn) {
                  try {
                    await userService.logout();
                    setState(() {
                      _isLoggedIn = false;
                      _userInfo = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已成功退出登录')),
                    );
                  } catch (e) {
                    showResultDialog(context, '退出登录', {'error': e.toString()});
                  }
                } else {
                  _checkLoginStatus();
                }
              },
              child: Text(_isLoggedIn ? '退出登录' : '刷新状态'),
            ),
          ],
        ),
        
        if (!_isLoggedIn)
          TestCard(
            title: '登录测试',
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('用户名和密码不能为空')),
                          );
                          return;
                        }
                        
                        try {
                          final userInfo = await userService.login(
                            _usernameController.text,
                            _passwordController.text,
                          );
                          
                          setState(() {
                            _isLoggedIn = true;
                            _userInfo = {
                              'id': userInfo.id,
                              'userName': userInfo.userName,
                              'nickname': userInfo.nickname,
                              'headImg': userInfo.headImg,
                              'sex': userInfo.sex,
                              'phone': userInfo.phone,
                              'email': userInfo.email,
                            };
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('登录成功')),
                          );
                        } catch (e) {
                          showResultDialog(context, '登录', {'error': e.toString()});
                        }
                      },
                      child: const Text('登录'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final userInfo = await userService.touristRegister();
                          
                          setState(() {
                            _isLoggedIn = true;
                            _userInfo = {
                              'id': userInfo.id,
                              'userName': userInfo.userName,
                              'nickname': userInfo.nickname,
                              'headImg': userInfo.headImg,
                              'sex': userInfo.sex,
                              'phone': userInfo.phone,
                              'email': userInfo.email,
                            };
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('游客登录成功')),
                          );
                        } catch (e) {
                          showResultDialog(context, '游客登录', {'error': e.toString()});
                        }
                      },
                      child: const Text('游客登录'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
        if (_isLoggedIn)
          TestCard(
            title: '用户功能测试',
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    final captchaInfo = await userService.getCaptcha();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('图形验证码'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.memory(
                              Uri.parse(captchaInfo.img).data!.contentAsBytes(),
                              width: 200,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text('验证码ID: ${captchaInfo.id}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    showResultDialog(context, '获取验证码', {'error': e.toString()});
                  }
                },
                child: const Text('获取图形验证码'),
              ),
              
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _fetchUserInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('用户信息已更新')),
                    );
                  } catch (e) {
                    showResultDialog(context, '获取用户信息', {'error': e.toString()});
                  }
                },
                child: const Text('刷新用户信息'),
              ),
            ],
          ),
      ],
    );
  }
} 
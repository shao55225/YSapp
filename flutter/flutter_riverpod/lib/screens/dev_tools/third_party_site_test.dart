import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';

class ThirdPartySiteTestScreen extends ConsumerStatefulWidget {
  const ThirdPartySiteTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ThirdPartySiteTestScreen> createState() => _ThirdPartySiteTestScreenState();
}

class _ThirdPartySiteTestScreenState extends ConsumerState<ThirdPartySiteTestScreen> {
  bool _isLoading = false;
  String _resultText = '';
  List<dynamic> _sites = [];
  String _selectedSiteUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchSites();
  }

  Future<void> _fetchSites() async {
    setState(() {
      _isLoading = true;
      _resultText = '正在获取第三方站点列表...';
    });

    try {
      final appConfig = ref.read(appConfigProvider);
      final url = Uri.parse('${appConfig.apiBaseUrl}${AppConfig.thirdPartySitesApi}');
      
      final response = await http.get(url);
      
      setState(() {
        _isLoading = false;
        _resultText = '响应状态码: ${response.statusCode}\n\n响应内容:\n${response.body}';
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['data'] != null && data['data'] is List) {
            _sites = data['data'];
            if (_sites.isNotEmpty && _sites[0]['url'] != null) {
              _selectedSiteUrl = _sites[0]['url'];
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = '错误: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('第三方站点测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchSites,
              child: Text(_isLoading ? '加载中...' : '获取第三方站点列表'),
            ),
            const SizedBox(height: 16),
            if (_sites.isNotEmpty) ...[
              const Text('可用站点列表:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: _sites.length,
                  itemBuilder: (context, index) {
                    final site = _sites[index];
                    return ListTile(
                      title: Text(site['name'] ?? '未命名站点'),
                      subtitle: Text(site['url'] ?? '无URL'),
                      trailing: Text('优先级: ${site['priority'] ?? 'N/A'}'),
                      selected: _selectedSiteUrl == site['url'],
                      onTap: () {
                        setState(() {
                          _selectedSiteUrl = site['url'] ?? '';
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedSiteUrl.isNotEmpty) ...[
                const Text('选中站点预览:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _selectedSiteUrl.isNotEmpty
                        ? WebView(
                            initialUrl: _selectedSiteUrl,
                            javascriptMode: JavascriptMode.unrestricted,
                          )
                        : const Center(child: Text('请选择站点')),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            const Text('API响应:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              flex: _sites.isEmpty ? 1 : 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Text(_resultText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 别忘了导入WebView
class WebView extends StatelessWidget {
  final String initialUrl;
  final JavascriptMode javascriptMode;

  const WebView({
    Key? key,
    required this.initialUrl,
    required this.javascriptMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 这里应该使用实际的WebView实现
    // 由于这只是一个示例，我们使用一个占位符
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('WebView加载: $initialUrl'),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

enum JavascriptMode { unrestricted }

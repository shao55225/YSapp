import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../api/services/third_party_service.dart';
import '../widgets/result_dialog.dart';
import '../widgets/test_card.dart';

class UrlTestSection extends ConsumerStatefulWidget {
  const UrlTestSection({Key? key}) : super(key: key);

  @override
  ConsumerState<UrlTestSection> createState() => _UrlTestSectionState();
}

class _UrlTestSectionState extends ConsumerState<UrlTestSection> {
  final TextEditingController _urlController = TextEditingController();
  List<String> _availableUrls = [];
  bool _isLoading = false;
  String? _selectedUrl;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _fetchUrls();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // 获取可用URL列表
  Future<void> _fetchUrls() async {
    setState(() => _isLoading = true);
    
    try {
      final thirdPartyService = ref.read(thirdPartyServiceProvider);
      final urls = await thirdPartyService.getAvailableUrls();
      
      setState(() {
        _availableUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showResultDialog('获取URL列表失败', e.toString());
      }
    }
  }

  // 测试URL健康状态
  Future<void> _testUrlHealth(String url) async {
    setState(() => _isLoading = true);
    
    try {
      final thirdPartyService = ref.read(thirdPartyServiceProvider);
      final isHealthy = await thirdPartyService.checkUrlHealth(url);
      
      setState(() => _isLoading = false);
      if (mounted) {
        _showResultDialog(
          'URL健康检测结果',
          '${isHealthy ? '✅ 正常' : '❌ 异常'}\nURL: $url',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showResultDialog('URL健康检测失败', e.toString());
      }
    }
  }

  // 预览URL
  void _previewUrl(String url) {
    setState(() {
      _selectedUrl = url;
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));
    });
  }

  // 显示结果对话框
  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => ResultDialog(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL输入框和测试按钮
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: '输入要测试的URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _testUrlHealth(_urlController.text),
                child: const Text('测试URL'),
              ),
            ],
          ),
          
          const SizedBox(height: 16.0),
          
          // URL列表标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '可用URL列表',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading ? null : _fetchUrls,
              ),
            ],
          ),
          
          const SizedBox(height: 8.0),
          
          // URL列表
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _availableUrls.isEmpty
                      ? const Center(child: Text('没有可用的URL'))
                      : Column(
                          children: [
                            // URL列表
                            Expanded(
                              flex: 1,
                              child: ListView.builder(
                                itemCount: _availableUrls.length,
                                itemBuilder: (context, index) {
                                  final url = _availableUrls[index];
                                  return TestCard(
                                    title: 'URL ${index + 1}',
                                    subtitle: url,
                                    onTest: () => _testUrlHealth(url),
                                    onPreview: () => _previewUrl(url),
                                  );
                                },
                              ),
                            ),
                            
                            // WebView预览
                            if (_selectedUrl != null) ...[
                              const Divider(),
                              const Text(
                                'WebView预览',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: _webViewController == null
                                        ? const Center(child: Text('没有选择URL'))
                                        : WebViewWidget(
                                            controller: _webViewController!,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
        ],
      ),
    );
  }
} 
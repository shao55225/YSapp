import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../api/services/third_party_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

// 第三方网站URL提供者
final thirdPartyUrlsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(thirdPartyServiceProvider);
  return service.getAvailableUrls();
});

// 当前URL提供者
final currentUrlProvider = StateProvider<String?>((ref) => null);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    // 在初始化时加载第三方站点
    _loadThirdPartySite();
  }

  // 加载第三方站点
  Future<void> _loadThirdPartySite() async {
    final urlsAsync = ref.read(thirdPartyUrlsProvider);
    
    urlsAsync.when(
      data: (urls) {
        if (urls.isNotEmpty) {
          // 设置当前URL
          ref.read(currentUrlProvider.notifier).state = urls.first;
          setState(() {
            _isLoading = false;
            _loadError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _loadError = true;
          });
        }
      },
      loading: () {
        setState(() {
          _isLoading = true;
        });
      },
      error: (_, __) {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
      },
    );
  }

  // 切换到下一个可用URL
  void _switchToNextUrl() async {
    setState(() => _isLoading = true);
    
    final currentUrl = ref.read(currentUrlProvider);
    if (currentUrl == null) {
      _loadThirdPartySite();
      return;
    }
    
    try {
      final service = ref.read(thirdPartyServiceProvider);
      final nextUrl = await service.getNextUrl(currentUrl);
      
      if (nextUrl != null) {
        ref.read(currentUrlProvider.notifier).state = nextUrl;
        setState(() {
          _isLoading = false;
          _loadError = false;
        });
        
        if (_webViewController != null) {
          _webViewController!.loadRequest(Uri.parse(nextUrl));
        }
      } else {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = ref.watch(currentUrlProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('爱影视频'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_webViewController != null && currentUrl != null) {
                _webViewController!.reload();
              } else {
                _loadThirdPartySite();
              }
            },
          ),
        ],
      ),
      body: _buildBody(currentUrl),
    );
  }
  
  Widget _buildBody(String? currentUrl) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }
    
    if (_loadError || currentUrl == null || currentUrl.isEmpty) {
      return ErrorView(
        error: '加载失败，请重试',
        onRetry: _loadThirdPartySite,
      );
    }
    
    // 使用WebView加载第三方站点
    return WebViewWidget(
      controller: _createWebViewController(currentUrl),
    );
  }
  
  WebViewController _createWebViewController(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            // 如果加载失败，尝试切换到下一个URL
            _switchToNextUrl();
          },
          onNavigationRequest: (NavigationRequest request) {
            // 处理导航请求，决定是否在WebView中打开链接
            // 这里可以添加拦截逻辑，例如打开特定链接
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    
    _webViewController = controller;
    return controller;
  }
} 
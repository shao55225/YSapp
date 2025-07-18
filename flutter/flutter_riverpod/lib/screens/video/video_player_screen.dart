import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock/wakelock.dart';
import '../../api/services/video_service.dart';
import '../../api/services/user_service.dart';
import '../../api/services/payment_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

// 视频播放信息提供者
final playInfoProvider = FutureProvider.family<PlayInfo, PlayParams>((ref, params) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getPlayInfo(params.videoId, params.sid, params.nid);
});

// 用户VIP信息提供者
final userVipStatusProvider = FutureProvider<bool>((ref) async {
  final userService = ref.watch(userServiceProvider);
  try {
    final userInfo = await userService.getUserInfo();
    return userInfo.isVip;
  } catch (e) {
    return false;
  }
});

// 用户金币信息提供者
final userGoldInfoProvider = FutureProvider<GoldInfo?>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  try {
    return await paymentService.getGoldInfo();
  } catch (e) {
    return null;
  }
});

// 播放参数
class PlayParams {
  final String videoId;
  final String sid;
  final String nid;
  
  const PlayParams({
    required this.videoId,
    required this.sid,
    required this.nid,
  });
}

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String sid;
  final String nid;
  
  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.sid,
    required this.nid,
  }) : super(key: key);

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isFullScreen = false;
  Timer? _positionTimer;
  Duration _currentPosition = Duration.zero;
  String _videoTitle = '';
  
  @override
  void initState() {
    super.initState();
    _initVideoTitle();
    
    // 保持屏幕常亮
    Wakelock.enable();
    
    // 记录播放位置
    _positionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _savePlayPosition();
    });
  }
  
  void _initVideoTitle() async {
    try {
      final videoService = ref.read(videoServiceProvider);
      final detail = await videoService.getVideoDetail(widget.videoId);
      
      if (mounted) {
        setState(() {
          _videoTitle = detail.name;
        });
      }
    } catch (e) {
      // 获取标题失败，不做处理
    }
  }
  
  @override
  void dispose() {
    _positionTimer?.cancel();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    
    // 恢复屏幕自动休眠
    Wakelock.disable();
    
    // 恢复竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // 恢复系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    
    super.dispose();
  }
  
  // 保存播放位置
  void _savePlayPosition() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      setState(() {
        _currentPosition = _videoPlayerController!.value.position;
      });
      
      // TODO: 保存播放进度到服务端或本地
    }
  }
  
  // 初始化播放器
  Future<void> _initializePlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    
    try {
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showOptions: true,
        fullScreenByDefault: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: const Center(child: LoadingIndicator()),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey[800]!,
          bufferedColor: Colors.grey,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 42),
                const SizedBox(height: 8),
                Text(
                  '播放错误: $errorMessage',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // 重试
                    if (_videoPlayerController != null) {
                      _videoPlayerController!.reload();
                    }
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        },
        additionalOptions: (context) => [
          OptionItem(
            onTap: () => _togglePlaybackSpeed(),
            iconData: Icons.speed,
            title: '播放速度',
          ),
          OptionItem(
            onTap: () => Navigator.pop(context), // 关闭菜单
            iconData: Icons.info_outline,
            title: '视频信息',
          ),
        ],
      );
      
      _chewieController!.addListener(_onControllerUpdate);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化播放器失败: $e')),
        );
      }
    }
  }
  
  void _onControllerUpdate() {
    if (_chewieController != null && mounted) {
      final isFullScreen = _chewieController!.isFullScreen;
      if (_isFullScreen != isFullScreen) {
        setState(() {
          _isFullScreen = isFullScreen;
        });
      }
    }
  }
  
  void _togglePlaybackSpeed() {
    if (_videoPlayerController != null) {
      final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
      final currentSpeed = _videoPlayerController!.value.playbackSpeed;
      final nextSpeedIndex = (speeds.indexOf(currentSpeed) + 1) % speeds.length;
      _videoPlayerController!.setPlaybackSpeed(speeds[nextSpeedIndex]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放速度: ${speeds[nextSpeedIndex]}x')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取播放信息
    final playParams = PlayParams(
      videoId: widget.videoId,
      sid: widget.sid,
      nid: widget.nid,
    );
    final playInfoAsync = ref.watch(playInfoProvider(playParams));
    
    // 全屏时隐藏AppBar
    return Scaffold(
      appBar: _isFullScreen 
          ? null 
          : AppBar(
              title: Text(_videoTitle.isEmpty ? '视频播放' : _videoTitle),
              backgroundColor: Colors.black,
              elevation: 0,
            ),
      backgroundColor: Colors.black,
      body: playInfoAsync.when(
        data: (playInfo) => _buildPlayerContent(playInfo),
        loading: () => const Center(
          child: LoadingIndicator(),
        ),
        error: (error, stackTrace) => ErrorView(
          error: '获取播放信息失败: $error',
          onRetry: () => ref.refresh(playInfoProvider(playParams)),
          textColor: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildPlayerContent(PlayInfo playInfo) {
    if (playInfo.isVip) {
      final vipStatusAsync = ref.watch(userVipStatusProvider);
      
      return vipStatusAsync.when(
        data: (isVip) {
          if (isVip) {
            return _buildVideoPlayer(playInfo.url);
          } else {
            return _buildVipRequiredView();
          }
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => _buildVipRequiredView(),
      );
    }
    
    if (playInfo.isGold && (playInfo.goldPrice ?? 0) > 0) {
      final goldInfoAsync = ref.watch(userGoldInfoProvider);
      
      return goldInfoAsync.when(
        data: (goldInfo) {
          final hasEnoughGold = goldInfo != null && 
              goldInfo.goldNum >= (playInfo.goldPrice ?? 0);
              
          if (hasEnoughGold) {
            return _buildVideoPlayer(playInfo.url);
          } else {
            return _buildGoldRequiredView(playInfo.goldPrice ?? 0);
          }
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, __) => _buildGoldRequiredView(playInfo.goldPrice ?? 0),
      );
    }
    
    return _buildVideoPlayer(playInfo.url);
  }
  
  // 构建视频播放器
  Widget _buildVideoPlayer(String url) {
    if (!_isInitialized) {
      _initializePlayer(url);
    }
    
    return _isInitialized && _chewieController != null
        ? Column(
            children: [
              Expanded(
                child: Chewie(controller: _chewieController!),
              ),
            ],
          )
        : const Center(child: LoadingIndicator());
  }
  
  // VIP提示界面
  Widget _buildVipRequiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'VIP专享内容',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            '开通VIP会员即可观看',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  // 跳转到VIP购买页面
                  Navigator.of(context).pushNamed('/payment/package/list');
                },
                child: const Text('立即开通', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('返回', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 金币提示界面
  Widget _buildGoldRequiredView(int goldPrice) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            '金币专享内容',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '需要 $goldPrice 金币观看',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  // 跳转到金币购买/支付页面
                  Navigator.of(context).pushNamed('/profile/gold/buy');
                },
                child: const Text('立即购买', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('返回', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../api/services/video_service.dart';
import '../widgets/test_card.dart';
import '../widgets/result_dialog.dart';

class VideoTestSection extends StatefulWidget {
  final WidgetRef ref;
  
  const VideoTestSection({Key? key, required this.ref}) : super(key: key);

  @override
  State<VideoTestSection> createState() => _VideoTestSectionState();
}

class _VideoTestSectionState extends State<VideoTestSection> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _selectedVideoId;
  String? _selectedVideoUrl;
  bool _isLoading = false;
  List<dynamic> _videoList = [];
  
  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoService = widget.ref.read(videoServiceProvider);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TestCard(
          title: '视频列表测试',
          children: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  final result = await videoService.getVideoList(limit: 10);
                  setState(() {
                    _videoList = result.videos;
                    _isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  showResultDialog(context, '获取视频列表', {'error': e.toString()});
                }
              },
              child: const Text('获取视频列表'),
            ),
            
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_videoList.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _videoList.length,
                  itemBuilder: (context, index) {
                    final video = _videoList[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVideoId = video.id.toString();
                        });
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedVideoId == video.id.toString() 
                                ? Colors.blue 
                                : Colors.grey,
                            width: _selectedVideoId == video.id.toString() ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (video.pic != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Image.network(
                                  video.pic!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                video.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: _selectedVideoId == video.id.toString()
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        
        if (_selectedVideoId != null)
          TestCard(
            title: '视频详情测试',
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await videoService.getVideoDetail(_selectedVideoId!);
                    showResultDialog(context, '视频详情', {
                      'id': result.id,
                      'name': result.name,
                      'director': result.director,
                      'actor': result.actor,
                      'playSources': result.playSources.map((e) => e.name).toList(),
                      'isVip': result.isVip,
                      'isGold': result.isGold,
                    });
                  } catch (e) {
                    showResultDialog(context, '视频详情', {'error': e.toString()});
                  }
                },
                child: const Text('获取视频详情'),
              ),
              
              ElevatedButton(
                onPressed: () async {
                  try {
                    final detail = await videoService.getVideoDetail(_selectedVideoId!);
                    if (detail.playSources.isNotEmpty && detail.playSources[0].urls.isNotEmpty) {
                      final playInfo = await videoService.getPlayInfo(
                        _selectedVideoId!,
                        '0', // 第一个播放源
                        '0', // 第一集
                      );
                      
                      setState(() {
                        _selectedVideoUrl = playInfo.url;
                      });
                      
                      _initializePlayer(playInfo.url);
                    } else {
                      showResultDialog(context, '获取播放地址', {'error': '没有可用的播放地址'});
                    }
                  } catch (e) {
                    showResultDialog(context, '获取播放地址', {'error': e.toString()});
                  }
                },
                child: const Text('获取播放地址'),
              ),
            ],
          ),
        
        if (_selectedVideoUrl != null)
          TestCard(
            title: '视频播放测试',
            children: [
              SizedBox(
                height: 200,
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator()),
              ),
              
              const SizedBox(height: 8),
              
              Text('播放地址: $_selectedVideoUrl', style: const TextStyle(fontSize: 12)),
              
              ElevatedButton(
                onPressed: () {
                  _disposePlayer();
                },
                child: const Text('释放播放器'),
              ),
            ],
          ),
          
        TestCard(
          title: '视频搜索测试',
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: '输入搜索关键词',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  try {
                    final result = await videoService.searchVideos(value, limit: 10);
                    showResultDialog(context, '搜索结果', {
                      'total': result.total,
                      'results': result.videos.map((v) => v.name).toList(),
                    });
                  } catch (e) {
                    showResultDialog(context, '搜索视频', {'error': e.toString()});
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
  
  void _initializePlayer(String videoUrl) {
    _disposePlayer();
    
    _videoPlayerController = VideoPlayerController.network(videoUrl);
    
    _videoPlayerController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              '播放错误: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      setState(() {});
    }).catchError((error) {
      showResultDialog(context, '初始化播放器', {'error': error.toString()});
    });
  }
  
  void _disposePlayer() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../api/services/video_service.dart';
import '../../api/services/collect_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'video_player_screen.dart';

// 视频详情提供者
final videoDetailProvider = FutureProvider.family<VideoDetail, String>((ref, videoId) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getVideoDetail(videoId);
});

// 收藏状态提供者
final collectStatusProvider = FutureProvider.family<bool, String>((ref, videoId) async {
  final collectService = ref.watch(collectServiceProvider);
  return await collectService.isCollected(videoId);
});

class VideoDetailScreen extends ConsumerWidget {
  final String videoId;
  const VideoDetailScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用Provider获取视频详情
    final videoDetailAsync = ref.watch(videoDetailProvider(videoId));
    final collectStatusAsync = ref.watch(collectStatusProvider(videoId));
    
    return Scaffold(
      body: videoDetailAsync.when(
        data: (detail) => _buildDetailContent(context, detail, collectStatusAsync, ref),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorView(
          error: '加载失败: $error',
          onRetry: () => ref.refresh(videoDetailProvider(videoId)),
        ),
      ),
    );
  }
  
  // 构建详情内容
  Widget _buildDetailContent(
    BuildContext context, 
    VideoDetail detail, 
    AsyncValue<bool> collectStatusAsync,
    WidgetRef ref
  ) {
    return CustomScrollView(
      slivers: [
        // 视频封面和标题(作为App Bar)
        _buildSliverAppBar(context, detail, collectStatusAsync, ref),
        
        // 操作按钮
        SliverToBoxAdapter(
          child: _buildActionButtons(context, detail, ref),
        ),
        
        // 视频信息
        SliverToBoxAdapter(
          child: _buildInfoSection(context, detail),
        ),
        
        // 视频简介
        SliverToBoxAdapter(
          child: _buildDescriptionSection(detail),
        ),
        
        // 播放源和剧集
        SliverToBoxAdapter(
          child: _buildPlaySources(context, detail, ref),
        ),
        
        // 推荐视频
        SliverToBoxAdapter(
          child: _buildRecommendations(context, detail.id.toString(), ref),
        ),
      ],
    );
  }
  
  // 构建滑动AppBar
  Widget _buildSliverAppBar(
    BuildContext context, 
    VideoDetail detail,
    AsyncValue<bool> collectStatusAsync,
    WidgetRef ref
  ) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          detail.name,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图
            detail.pic != null
                ? Image.network(
                    detail.pic!,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[800]),
            
            // 渐变遮罩
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // 收藏按钮
        collectStatusAsync.when(
          data: (isCollected) => IconButton(
            icon: Icon(
              isCollected ? Icons.favorite : Icons.favorite_border,
              color: isCollected ? Colors.red : Colors.white,
            ),
            onPressed: () => _toggleCollect(context, videoId, isCollected, ref),
          ),
          loading: () => const IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: null,
          ),
          error: (_, __) => IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => _toggleCollect(context, videoId, false, ref),
          ),
        ),
        
        // 分享按钮
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareVideo(context, detail),
        ),
      ],
    );
  }
  
  // 构建操作按钮
  Widget _buildActionButtons(BuildContext context, VideoDetail detail, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: detail.playSources.isNotEmpty
                  ? () => _playVideo(context, detail)
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('立即播放'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          ElevatedButton.icon(
            onPressed: () {
              // 下载功能逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('下载功能即将上线')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('缓存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建信息部分
  Widget _buildInfoSection(BuildContext context, VideoDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评分
          if (detail.score != null)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  detail.score.toString(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16.0),
                if (detail.year != null)
                  Text(detail.year.toString()),
                const SizedBox(width: 16.0),
                if (detail.area != null)
                  Text(detail.area!),
              ],
            ),
          
          const SizedBox(height: 8.0),
          
          // 导演和演员
          if (detail.director != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: '导演：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: detail.director),
                  ],
                ),
              ),
            ),
          
          if (detail.actor != null)
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text: '演员：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: detail.actor),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
  
  // 构建描述部分
  Widget _buildDescriptionSection(VideoDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '简介',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            detail.blurb ?? '暂无简介',
            style: const TextStyle(
              fontSize: 14.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
  
  // 构建播放源和剧集
  Widget _buildPlaySources(BuildContext context, VideoDetail detail, WidgetRef ref) {
    if (detail.playSources.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('暂无可用播放源'),
      );
    }
    
    return DefaultTabController(
      length: detail.playSources.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              '选集',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          // 播放源选项卡
          TabBar(
            isScrollable: true,
            tabs: detail.playSources.map((source) => Tab(text: source.name)).toList(),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
          
          // 剧集列表
          SizedBox(
            height: 300,
            child: TabBarView(
              children: detail.playSources.map((source) {
                return _buildEpisodeGrid(context, source, detail.id);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建剧集网格
  Widget _buildEpisodeGrid(BuildContext context, PlaySource source, int videoId) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: source.episodes.length,
      itemBuilder: (context, index) {
        final episode = source.episodes[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoId: videoId.toString(),
                  sid: source.id.toString(),
                  nid: episode.id.toString(),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              episode.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }
  
  // 构建推荐视频部分
  Widget _buildRecommendations(BuildContext context, String videoId, WidgetRef ref) {
    // 使用Provider获取推荐视频
    final recommendationsAsync = ref.watch(videoRecommendationsProvider(videoId));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '相关推荐',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 200,
            child: recommendationsAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return const Center(child: Text('暂无推荐'));
                }
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final video = recommendations[index];
                    return _buildRecommendationItem(context, video);
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (_, __) => const Center(child: Text('加载推荐失败')),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建推荐视频项目
  Widget _buildRecommendationItem(BuildContext context, VideoCard video) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailScreen(videoId: video.id.toString()),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: video.pic != null
                    ? Image.network(
                        video.pic!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 30),
                      ),
              ),
            ),
            const SizedBox(height: 6.0),
            // 视频标题
            Text(
              video.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
  
  // 播放视频
  void _playVideo(BuildContext context, VideoDetail detail) {
    if (detail.playSources.isEmpty || detail.playSources.first.episodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可播放的视频')),
      );
      return;
    }
    
    final firstSource = detail.playSources.first;
    final firstEpisode = firstSource.episodes.first;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoId: detail.id.toString(),
          sid: firstSource.id.toString(),
          nid: firstEpisode.id.toString(),
        ),
      ),
    );
  }
  
  // 切换收藏状态
  Future<void> _toggleCollect(BuildContext context, String videoId, bool isCollected, WidgetRef ref) async {
    try {
      final collectService = ref.read(collectServiceProvider);
      
      if (isCollected) {
        // 取消收藏
        await collectService.cancelCollect(videoId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消收藏')),
          );
        }
      } else {
        // 添加收藏
        await collectService.addCollect(videoId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已添加到收藏')),
          );
        }
      }
      
      // 刷新收藏状态
      ref.refresh(collectStatusProvider(videoId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
  
  // 分享视频
  void _shareVideo(BuildContext context, VideoDetail detail) {
    final title = detail.name;
    final desc = detail.blurb ?? '推荐一部好片';
    final url = 'https://aiying.app/video/${detail.id}'; // 示例URL，实际项目中应替换为真实分享URL
    
    Share.share(
      '$title\n$desc\n$url',
      subject: '分享: $title',
    );
  }
} 
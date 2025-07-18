import 'package:flutter/material.dart';
import '../../../api/services/video_service.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final double? aspectRatio;
  final VoidCallback onTap;
  final bool showScore;
  final bool showRemarks;

  const VideoCard({
    Key? key,
    required this.video,
    required this.onTap,
    this.aspectRatio = 0.7,
    this.showScore = true,
    this.showRemarks = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频封面
          AspectRatio(
            aspectRatio: aspectRatio!,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 封面图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: video.pic != null
                      ? Image.network(
                          video.pic!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.movie,
                            color: Colors.grey,
                          ),
                        ),
                ),

                // 评分标签
                if (showScore && video.score != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.score!.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                // 备注标签（例如更新集数等）
                if (showRemarks && video.remarks != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        video.remarks!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 视频标题
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: Text(
              video.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 其他信息
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Row(
              children: [
                if (video.year != null)
                  Text(
                    video.year!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (video.year != null && video.area != null)
                  Text(
                    ' · ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (video.area != null)
                  Expanded(
                    child: Text(
                      video.area!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoGridView extends StatelessWidget {
  final List<Video> videos;
  final Function(Video) onVideoTap;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showScore;
  final bool showRemarks;
  final ScrollPhysics? physics;
  
  const VideoGridView({
    Key? key,
    required this.videos,
    required this.onVideoTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.showScore = true,
    this.showRemarks = true,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
      ),
      itemCount: videos.length,
      physics: physics,
      shrinkWrap: physics != null,
      itemBuilder: (context, index) {
        return VideoCard(
          video: videos[index],
          onTap: () => onVideoTap(videos[index]),
          aspectRatio: childAspectRatio,
          showScore: showScore,
          showRemarks: showRemarks,
        );
      },
    );
  }
} 
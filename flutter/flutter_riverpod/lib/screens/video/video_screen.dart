import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'video_search_screen.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = ['首页', '电影', '电视剧', '综艺', '动漫'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryTabs(),
            _buildAnnouncementBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildCategoryContent(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.blue,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VideoSearchScreen(),
            ),
          );
        },
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索您想要观看的影片',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.blue,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: _categories.map((category) {
          return Tab(text: category);
        }).toList(),
      ),
    );
  }
  
  Widget _buildAnnouncementBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.blue),
          const SizedBox(width: 8.0),
          const Expanded(
            child: Text(
              '本站为演示站点',
              style: TextStyle(color: Colors.blue),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('更多'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryContent(String category) {
    // 模拟电影数据
    final List<Map<String, dynamic>> movies = [
      {
        'title': '血与玫瑰',
        'cover': 'https://via.placeholder.com/150x200',
        'description': '本片根据意大利...'
      },
      {
        'title': '嗜血妖兽',
        'cover': 'https://via.placeholder.com/150x200',
        'description': '70年前在一场...'
      },
      {
        'title': '怪物来袭',
        'cover': 'https://via.placeholder.com/150x200',
        'description': '公海国际共建...'
      },
      {
        'title': '周公伏妖',
        'cover': 'https://via.placeholder.com/150x200',
        'description': '古代奇幻故事...'
      },
      {
        'title': '达拉·奥布莱恩',
        'cover': 'https://via.placeholder.com/150x200',
        'description': '一部精彩的喜剧...'
      },
      {
        'title': '橘里的鱼',
        'cover': 'https://via.placeholder.com/150x200',
        'description': '一个关于成长的故事...'
      },
    ];
    
    return category == '首页' 
        ? _buildHomeCategoryContent(movies)
        : _buildGridCategoryContent(movies);
  }
  
  Widget _buildHomeCategoryContent(List<Map<String, dynamic>> movies) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('电影', true),
          _buildMovieRow(movies),
          _buildSectionHeader('电视剧', true),
          _buildMovieRow(movies),
          _buildSectionHeader('综艺', true),
          _buildMovieRow(movies),
          _buildSectionHeader('动漫', true),
          _buildMovieRow(movies),
        ],
      ),
    );
  }
  
  Widget _buildGridCategoryContent(List<Map<String, dynamic>> movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieItem(movie);
      },
    );
  }
  
  Widget _buildSectionHeader(String title, bool showMore) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showMore)
            TextButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Text('更多'),
                  Icon(Icons.chevron_right, size: 18.0),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMovieRow(List<Map<String, dynamic>> movies) {
    return SizedBox(
      height: 220.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return SizedBox(
            width: 130.0,
            child: _buildMovieItem(movie),
          );
        },
      ),
    );
  }
  
  Widget _buildMovieItem(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () {
        // 导航到电影详情页
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _DummyVideoDetailScreen(title: movie['title']),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: CachedNetworkImage(
                  imageUrl: movie['cover'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                movie['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                movie['description'],
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 临时电影详情页面，后续会移到单独的文件中
class _DummyVideoDetailScreen extends StatelessWidget {
  final String title;
  
  const _DummyVideoDetailScreen({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('$title 的详情页面'),
      ),
    );
  }
} 
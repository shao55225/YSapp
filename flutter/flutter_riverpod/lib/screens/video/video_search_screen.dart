import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/services/video_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'video_detail_screen.dart';
import 'widgets/video_card.dart';

// 搜索历史提供者
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

// 热门搜索提供者
final hotSearchProvider = FutureProvider<List<String>>((ref) async {
  try {
    final videoService = ref.read(videoServiceProvider);
    return await videoService.getHotSearches();
  } catch (e) {
    // 热门搜索获取失败时返回默认列表
    return [
      '热门电影',
      '新剧推荐',
      '动作片',
      '喜剧片',
      '科幻片',
      '最新综艺',
    ];
  }
});

// 搜索结果提供者
final searchResultsProvider = FutureProvider.family<VideoListResponse, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return VideoListResponse(videos: [], total: 0, hasMore: false);
  }
  
  final videoService = ref.read(videoServiceProvider);
  return await videoService.searchVideos(query);
});

// 搜索历史状态管理
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadSearchHistory();
  }
  
  static const String _prefsKey = 'search_history';
  static const int _maxHistoryItems = 10;
  
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefsKey) ?? [];
      state = history;
    } catch (e) {
      // 加载失败时保持空列表
    }
  }
  
  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state);
    } catch (e) {
      // 保存失败时不做处理
    }
  }
  
  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // 如果已存在，先移除
    state = state.where((item) => item != query).toList();
    
    // 添加到列表头部
    state = [query, ...state];
    
    // 限制历史记录数量
    if (state.length > _maxHistoryItems) {
      state = state.sublist(0, _maxHistoryItems);
    }
    
    _saveSearchHistory();
  }
  
  void removeSearch(String query) {
    state = state.where((item) => item != query).toList();
    _saveSearchHistory();
  }
  
  void clearHistory() {
    state = [];
    _saveSearchHistory();
  }
}

class VideoSearchScreen extends ConsumerStatefulWidget {
  const VideoSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoSearchScreen> createState() => _VideoSearchScreenState();
}

class _VideoSearchScreenState extends ConsumerState<VideoSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _currentQuery = '';
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text != _currentQuery) {
        setState(() {
          _currentQuery = _searchController.text;
          if (_currentQuery.isNotEmpty) {
            _isSearching = true;
          }
        });
      }
    });
  }
  
  void _onSearch(String query) {
    _searchController.text = query;
    setState(() {
      _currentQuery = query;
      _isSearching = true;
    });
    
    // 添加到搜索历史
    ref.read(searchHistoryProvider.notifier).addSearch(query);
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索影视剧',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
      body: _isSearching
          ? _buildSearchResults()
          : _buildSearchSuggestions(),
    );
  }
  
  Widget _buildSearchSuggestions() {
    final history = ref.watch(searchHistoryProvider);
    final hotSearchAsync = ref.watch(hotSearchProvider);
    
    return ListView(
      children: [
        // 搜索历史
        if (history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref.read(searchHistoryProvider.notifier).clearHistory(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: history.map((item) => _buildKeywordChip(item)).toList(),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // 热门搜索
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: const Text(
            '热门搜索',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: hotSearchAsync.when(
            data: (hotSearches) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hotSearches.map((item) => _buildKeywordChip(item)).toList(),
            ),
            loading: () => const Center(child: LoadingIndicator()),
            error: (_, __) => const Center(child: Text('无法获取热门搜索')),
          ),
        ),
      ],
    );
  }
  
  Widget _buildKeywordChip(String keyword) {
    return InputChip(
      label: Text(keyword),
      onPressed: () => _onSearch(keyword),
      onDeleted: keyword != '' ? () => ref.read(searchHistoryProvider.notifier).removeSearch(keyword) : null,
      backgroundColor: Colors.grey.withOpacity(0.2),
    );
  }
  
  Widget _buildSearchResults() {
    final resultsAsync = ref.watch(searchResultsProvider(_currentQuery));
    
    return resultsAsync.when(
      data: (results) {
        if (results.videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '未找到"$_currentQuery"相关视频',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.videos.length,
          itemBuilder: (context, index) {
            final video = results.videos[index];
            return VideoListItem(
              video: video,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoDetailScreen(videoId: video.id.toString()),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => ErrorView(
        error: error.toString(),
        onRetry: () => ref.refresh(searchResultsProvider(_currentQuery)),
      ),
    );
  }
}

class VideoListItem extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;
  
  const VideoListItem({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 100,
                height: 140,
                child: video.pic != null
                    ? Image.network(
                        video.pic!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey,
                        child: const Icon(Icons.movie, color: Colors.white),
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 视频信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (video.remarks != null)
                    Text(
                      video.remarks!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (video.score != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          video.score.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (video.year != null) Text('${video.year} · '),
                      if (video.area != null) Text('${video.area} · '),
                      if (video.cateName != null) Text(video.cateName!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (video.blurb != null)
                    Text(
                      video.blurb!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
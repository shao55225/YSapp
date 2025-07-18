import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../../constants/api_constants.dart';

// 视频服务提供者
final videoServiceProvider = Provider<VideoService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VideoService(apiService);
});

// 视频分类提供者
final videoCategoriesProvider = FutureProvider<List<VideoCategory>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getCategories();
});

// 视频推荐提供者
final videoRecommendationsProvider = FutureProvider.family<List<VideoCard>, String>((ref, videoId) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getRecommendations(videoId);
});

class VideoService {
  final ApiService _apiService;
  
  VideoService(this._apiService);
  
  // 获取视频列表
  Future<VideoListResponse> getVideoList({
    int limit = 20, 
    int offset = 0, 
    String? cateId, 
    String? year, 
    String? area, 
    String? sort
  }) async {
    try {
      final data = await _apiService.getVodList(
        limit: limit,
        offset: offset,
        cateId: cateId,
        year: year,
        area: area,
        sort: sort
      );
      
      final List<Video> videos = (data['list'] as List).map((item) => Video.fromJson(item)).toList();
      
      return VideoListResponse(
        videos: videos,
        total: data['total'] ?? 0,
        hasMore: data['hasMore'] ?? false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // 获取视频详情
  Future<VideoDetail> getVideoDetail(String id) async {
    try {
      final data = await _apiService.getVodDetail(id);
      return VideoDetail.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // 获取播放信息
  Future<PlayInfo> getPlayInfo(String id, String sid, String nid) async {
    try {
      final data = await _apiService.getVodPlay(id, sid, nid);
      return PlayInfo.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // 搜索视频
  Future<VideoListResponse> searchVideos(String keyword, {int limit = 20, int offset = 0}) async {
    try {
      final data = await _apiService.searchVod(keyword, limit: limit, offset: offset);
      
      final List<Video> videos = (data['list'] as List).map((item) => Video.fromJson(item)).toList();
      
      return VideoListResponse(
        videos: videos,
        total: data['total'] ?? 0,
        hasMore: data['hasMore'] ?? false,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取视频分类
  Future<List<VideoCategory>> getCategories() async {
    try {
      final data = await _apiService.getVodCategory();
      return (data as List).map((item) => VideoCategory.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取视频推荐
  Future<List<VideoCard>> getRecommendations(String videoId) async {
    try {
      final data = await _apiService.get(
        ApiConstants.vodRecommend,
        queryParameters: {'id': videoId}
      );
      
      if (data is List) {
        return data.map((item) => VideoCard.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('list') && data['list'] is List) {
        return (data['list'] as List).map((item) => VideoCard.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      // 推荐失败时返回空列表
      return [];
    }
  }
  
  // 获取热门搜索关键词
  Future<List<String>> getHotSearches() async {
    try {
      final data = await _apiService.get(ApiConstants.vodHot);
      
      if (data is List) {
        return data.map((item) => item.toString()).toList();
      } else if (data is Map && data.containsKey('list') && data['list'] is List) {
        return (data['list'] as List).map((item) {
          if (item is Map && item.containsKey('keyword')) {
            return item['keyword'].toString();
          } else if (item is String) {
            return item;
          }
          return '';
        }).where((keyword) => keyword.isNotEmpty).toList();
      }
      
      // 如果没有获取到数据或格式不匹配，返回默认热门搜索
      return _getDefaultHotSearches();
    } catch (e) {
      // 获取失败时返回默认热门搜索
      return _getDefaultHotSearches();
    }
  }
  
  // 默认热门搜索关键词
  List<String> _getDefaultHotSearches() {
    return [
      '热门电影',
      '新剧推荐',
      '动作片',
      '喜剧片',
      '科幻片',
      '最新综艺',
      '动漫',
      '纪录片',
    ];
  }
  
  // 记录浏览历史
  Future<void> recordBrowse(int vodId) async {
    try {
      await _apiService.post(ApiConstants.recordBrowse, data: {
        'vodId': vodId,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取浏览记录
  Future<List<BrowseRecord>> getBrowseHistory({required int limit, required int offset, int? chargingMode}) async {
    try {
      final data = await _apiService.get(ApiConstants.browseHistory, queryParameters: {
        'limit': limit,
        'offset': offset,
        if (chargingMode != null) 'chargingMode': chargingMode,
      });
      
      return (data['list'] as List).map((item) => BrowseRecord.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // 获取移动端浏览记录
  Future<List<BrowseRecord>> getMobileBrowseHistory({required int limit, required int offset}) async {
    try {
      final data = await _apiService.get(ApiConstants.mobileBrowseHistory, queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      
      return (data['list'] as List).map((item) => BrowseRecord.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

// 视频列表响应模型
class VideoListResponse {
  final List<Video> videos;
  final int total;
  final bool hasMore;
  
  VideoListResponse({
    required this.videos,
    required this.total,
    required this.hasMore,
  });
}

// 视频卡片模型（用于推荐）
class VideoCard {
  final int id;
  final String name;
  final String? pic;
  final String? remarks;
  final double? score;
  
  VideoCard({
    required this.id,
    required this.name,
    this.pic,
    this.remarks,
    this.score,
  });
  
  factory VideoCard.fromJson(Map<String, dynamic> json) {
    return VideoCard(
      id: json['id'],
      name: json['name'],
      pic: json['pic'],
      remarks: json['remarks'],
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
    );
  }
}

// 视频模型
class Video {
  final int id;
  final String name;
  final String? pic;
  final String? lang;
  final String? area;
  final String? year;
  final String? state;
  final String? remarks;
  final String? director;
  final String? actor;
  final String? blurb;
  final double? score;
  final int? hits;
  final int? cateId;
  final String? cateName;
  
  Video({
    required this.id,
    required this.name,
    this.pic,
    this.lang,
    this.area,
    this.year,
    this.state,
    this.remarks,
    this.director,
    this.actor,
    this.blurb,
    this.score,
    this.hits,
    this.cateId,
    this.cateName,
  });
  
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      name: json['name'],
      pic: json['pic'],
      lang: json['lang'],
      area: json['area'],
      year: json['year'],
      state: json['state'],
      remarks: json['remarks'],
      director: json['director'],
      actor: json['actor'],
      blurb: json['blurb'],
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      hits: json['hits'],
      cateId: json['cateId'],
      cateName: json['cateName'],
    );
  }
}

// 视频详情模型
class VideoDetail extends Video {
  final List<PlaySource> playSources;
  final List<Video>? relatedVideos;
  final bool? isCollected;
  final bool? isVip;
  final bool? isGold;
  final int? goldPrice;
  
  VideoDetail({
    required super.id,
    required super.name,
    super.pic,
    super.lang,
    super.area,
    super.year,
    super.state,
    super.remarks,
    super.director,
    super.actor,
    super.blurb,
    super.score,
    super.hits,
    super.cateId,
    super.cateName,
    required this.playSources,
    this.relatedVideos,
    this.isCollected,
    this.isVip,
    this.isGold,
    this.goldPrice,
  });
  
  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    return VideoDetail(
      id: json['id'],
      name: json['name'],
      pic: json['pic'],
      lang: json['lang'],
      area: json['area'],
      year: json['year'],
      state: json['state'],
      remarks: json['remarks'],
      director: json['director'],
      actor: json['actor'],
      blurb: json['blurb'],
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      hits: json['hits'],
      cateId: json['cateId'],
      cateName: json['cateName'],
      playSources: (json['playSources'] as List).map((item) => PlaySource.fromJson(item)).toList(),
      relatedVideos: json['relatedVideos'] != null 
          ? (json['relatedVideos'] as List).map((item) => Video.fromJson(item)).toList() 
          : null,
      isCollected: json['isCollected'],
      isVip: json['isVip'],
      isGold: json['isGold'],
      goldPrice: json['goldPrice'],
    );
  }
}

// 播放源模型
class PlaySource {
  final int id;
  final String name;
  final List<Episode> episodes;
  
  PlaySource({
    required this.id,
    required this.name,
    required this.episodes,
  });
  
  factory PlaySource.fromJson(Map<String, dynamic> json) {
    return PlaySource(
      id: json['id'],
      name: json['name'],
      episodes: (json['episodes'] as List).map((item) => Episode.fromJson(item)).toList(),
    );
  }
}

// 剧集模型
class Episode {
  final int id;
  final String name;
  final int? sort;
  
  Episode({
    required this.id,
    required this.name,
    this.sort,
  });
  
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      name: json['name'],
      sort: json['sort'],
    );
  }
}

// 播放信息模型
class PlayInfo {
  final String url;
  final String? subtitle;
  final bool isVip;
  final bool isGold;
  final int? goldPrice;
  
  PlayInfo({
    required this.url,
    this.subtitle,
    required this.isVip,
    required this.isGold,
    this.goldPrice,
  });
  
  factory PlayInfo.fromJson(Map<String, dynamic> json) {
    return PlayInfo(
      url: json['url'],
      subtitle: json['subtitle'],
      isVip: json['isVip'] ?? false,
      isGold: json['isGold'] ?? false,
      goldPrice: json['goldPrice'],
    );
  }
}

// 视频分类模型
class VideoCategory {
  final int id;
  final String name;
  final int? sort;
  
  VideoCategory({
    required this.id,
    required this.name,
    this.sort,
  });
  
  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'],
      name: json['name'],
      sort: json['sort'],
    );
  }
}

// 浏览记录模型
class BrowseRecord {
  final int id;
  final int vodId;
  final String vodName;
  final String? vodPic;
  final String? vodRemarks;
  final DateTime createTime;
  
  BrowseRecord({
    required this.id,
    required this.vodId,
    required this.vodName,
    this.vodPic,
    this.vodRemarks,
    required this.createTime,
  });
  
  factory BrowseRecord.fromJson(Map<String, dynamic> json) {
    return BrowseRecord(
      id: json['id'],
      vodId: json['vodId'],
      vodName: json['vodName'],
      vodPic: json['vodPic'],
      vodRemarks: json['vodRemarks'],
      createTime: DateTime.parse(json['createTime']),
    );
  }
} 
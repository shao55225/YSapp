/// 视频模型类
class VideoModel {
  final int id;
  final String title;
  final String? coverUrl;
  final String? description;
  final int? cateId;
  final String? cateName;
  final String? area;
  final String? year;
  final String? director;
  final String? actor;
  final int? chargingMode;  // 收费模式：0免费，1VIP，2金币
  final int? goldCoin;      // 需要金币数
  final int? status;        // 状态：0下架，1上架
  final String? createTime;
  final String? updateTime;
  final int? playCount;     // 播放次数
  final int? likeCount;     // 点赞次数
  final int? commentCount;  // 评论次数
  final List<VideoSource>? sources; // 播放源

  VideoModel({
    required this.id,
    required this.title,
    this.coverUrl,
    this.description,
    this.cateId,
    this.cateName,
    this.area,
    this.year,
    this.director,
    this.actor,
    this.chargingMode,
    this.goldCoin,
    this.status,
    this.createTime,
    this.updateTime,
    this.playCount,
    this.likeCount,
    this.commentCount,
    this.sources,
  });

  /// 从JSON构造
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    List<VideoSource>? sourcesList;
    if (json['sources'] != null) {
      sourcesList = (json['sources'] as List)
          .map((sourceJson) => VideoSource.fromJson(sourceJson))
          .toList();
    }

    return VideoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      cateId: json['cateId'] as int?,
      cateName: json['cateName'] as String?,
      area: json['area'] as String?,
      year: json['year'] as String?,
      director: json['director'] as String?,
      actor: json['actor'] as String?,
      chargingMode: json['chargingMode'] as int?,
      goldCoin: json['goldCoin'] as int?,
      status: json['status'] as int?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      playCount: json['playCount'] as int?,
      likeCount: json['likeCount'] as int?,
      commentCount: json['commentCount'] as int?,
      sources: sourcesList,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'description': description,
      'cateId': cateId,
      'cateName': cateName,
      'area': area,
      'year': year,
      'director': director,
      'actor': actor,
      'chargingMode': chargingMode,
      'goldCoin': goldCoin,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
      'playCount': playCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'sources': sources?.map((source) => source.toJson()).toList(),
    };
  }

  /// 是否是免费视频
  bool get isFree => chargingMode == 0;

  /// 是否是VIP视频
  bool get isVip => chargingMode == 1;

  /// 是否是金币视频
  bool get isGoldCoin => chargingMode == 2;
}

class Video {
  final String id;
  final String title;
  final String cover;
  final String? desc;

  Video({required this.id, required this.title, required this.cover, this.desc});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      desc: json['desc'],
    );
  }
}

class VideoDetail {
  final String id;
  final String title;
  final String cover;
  final String? desc;
  final List<dynamic>? playSources;

  VideoDetail({required this.id, required this.title, required this.cover, this.desc, this.playSources});

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    return VideoDetail(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      desc: json['desc'],
      playSources: json['playSources'],
    );
  }
}

/// 视频源模型
class VideoSource {
  final int id;
  final String name;
  final List<VideoEpisode>? episodes;

  VideoSource({
    required this.id,
    required this.name,
    this.episodes,
  });

  /// 从JSON构造
  factory VideoSource.fromJson(Map<String, dynamic> json) {
    List<VideoEpisode>? episodesList;
    if (json['episodes'] != null) {
      episodesList = (json['episodes'] as List)
          .map((episodeJson) => VideoEpisode.fromJson(episodeJson))
          .toList();
    }

    return VideoSource(
      id: json['id'] as int,
      name: json['name'] as String,
      episodes: episodesList,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'episodes': episodes?.map((episode) => episode.toJson()).toList(),
    };
  }
}

/// 视频剧集模型
class VideoEpisode {
  final int id;
  final String name;
  final String? url;
  final int? sort;

  VideoEpisode({
    required this.id,
    required this.name,
    this.url,
    this.sort,
  });

  /// 从JSON构造
  factory VideoEpisode.fromJson(Map<String, dynamic> json) {
    return VideoEpisode(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String?,
      sort: json['sort'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'sort': sort,
    };
  }
}

/// 视频分类模型
class VideoCategory {
  final int id;
  final String name;
  final int? sort;
  final int? status;

  VideoCategory({
    required this.id,
    required this.name,
    this.sort,
    this.status,
  });

  /// 从JSON构造
  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      sort: json['sort'] as int?,
      status: json['status'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sort': sort,
      'status': status,
    };
  }
}

/// 视频评论模型
class VideoComment {
  final int id;
  final int vodId;
  final int memberId;
  final String content;
  final String? createTime;
  final String? memberName;
  final String? memberAvatar;
  final List<VideoComment>? replies;

  VideoComment({
    required this.id,
    required this.vodId,
    required this.memberId,
    required this.content,
    this.createTime,
    this.memberName,
    this.memberAvatar,
    this.replies,
  });

  /// 从JSON构造
  factory VideoComment.fromJson(Map<String, dynamic> json) {
    List<VideoComment>? repliesList;
    if (json['replies'] != null) {
      repliesList = (json['replies'] as List)
          .map((replyJson) => VideoComment.fromJson(replyJson))
          .toList();
    }

    return VideoComment(
      id: json['id'] as int,
      vodId: json['vodId'] as int,
      memberId: json['memberId'] as int,
      content: json['content'] as String,
      createTime: json['createTime'] as String?,
      memberName: json['memberName'] as String?,
      memberAvatar: json['memberAvatar'] as String?,
      replies: repliesList,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vodId': vodId,
      'memberId': memberId,
      'content': content,
      'createTime': createTime,
      'memberName': memberName,
      'memberAvatar': memberAvatar,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
    };
  }
} 
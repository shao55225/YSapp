class CommentModel {
  final int id;
  final String content;
  final int resourcesId;
  final String? resourcesName;
  final String? resourcesPic;
  final String createTime;
  final int memberId;
  final String? memberName;
  final String? memberHeadImg;
  final int isNotify;
  final int? likeCount;
  final int? dislikeCount;
  final String? resourcesUrl;
  final int commentType;
  
  CommentModel({
    required this.id,
    required this.content,
    required this.resourcesId,
    this.resourcesName,
    this.resourcesPic,
    required this.createTime,
    required this.memberId,
    this.memberName,
    this.memberHeadImg,
    required this.isNotify,
    this.likeCount,
    this.dislikeCount,
    this.resourcesUrl,
    required this.commentType,
  });
  
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      resourcesId: json['resourcesId'] ?? 0,
      resourcesName: json['resourcesName'],
      resourcesPic: json['resourcesPic'],
      createTime: json['createTime'] ?? '',
      memberId: json['memberId'] ?? 0,
      memberName: json['memberName'],
      memberHeadImg: json['memberHeadImg'],
      isNotify: json['isNotify'] ?? 0,
      likeCount: json['likeCount'],
      dislikeCount: json['dislikeCount'],
      resourcesUrl: json['resourcesUrl'],
      commentType: json['commentType'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'resourcesId': resourcesId,
      'resourcesName': resourcesName,
      'resourcesPic': resourcesPic,
      'createTime': createTime,
      'memberId': memberId,
      'memberName': memberName,
      'memberHeadImg': memberHeadImg,
      'isNotify': isNotify,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'resourcesUrl': resourcesUrl,
      'commentType': commentType,
    };
  }
} 
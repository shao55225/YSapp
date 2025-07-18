class BrowseHistoryModel {
  final int id;
  final int vodId;
  final String vodName;
  final String? vodPic;
  final String? vodRemarks;
  final int chargingMode;
  final String? vodLang;
  final String? vodYear;
  final String? vodArea;
  final String createTime;
  
  BrowseHistoryModel({
    required this.id,
    required this.vodId,
    required this.vodName,
    this.vodPic,
    this.vodRemarks,
    required this.chargingMode,
    this.vodLang,
    this.vodYear,
    this.vodArea,
    required this.createTime,
  });
  
  factory BrowseHistoryModel.fromJson(Map<String, dynamic> json) {
    return BrowseHistoryModel(
      id: json['id'] ?? 0,
      vodId: json['vodId'] ?? 0,
      vodName: json['vodName'] ?? '',
      vodPic: json['vodPic'],
      vodRemarks: json['vodRemarks'],
      chargingMode: json['chargingMode'] ?? 0,
      vodLang: json['vodLang'],
      vodYear: json['vodYear'],
      vodArea: json['vodArea'],
      createTime: json['createTime'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vodId': vodId,
      'vodName': vodName,
      'vodPic': vodPic,
      'vodRemarks': vodRemarks,
      'chargingMode': chargingMode,
      'vodLang': vodLang,
      'vodYear': vodYear,
      'vodArea': vodArea,
      'createTime': createTime,
    };
  }
} 
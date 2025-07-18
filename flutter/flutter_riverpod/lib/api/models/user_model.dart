/// 用户模型类
class UserModel {
  final int id;
  final String userName;
  final String? nickName;
  final String? headImg;
  final int? sex;
  final String? vipExpireTime;
  final int isVip;
  final int? gold;
  final int? points;
  final String? phone;
  final String? email;
  final int? agentLevel;
  final String? inviteCode;
  final int? isBindPhone;
  final int? isBindEmail;
  final String? createTime;
  
  UserModel({
    required this.id,
    required this.userName,
    this.nickName,
    this.headImg,
    this.sex,
    this.vipExpireTime,
    required this.isVip,
    this.gold,
    this.points,
    this.phone,
    this.email,
    this.agentLevel,
    this.inviteCode,
    this.isBindPhone,
    this.isBindEmail,
    this.createTime,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      nickName: json['nickName'],
      headImg: json['headImg'],
      sex: json['sex'],
      vipExpireTime: json['vipExpireTime'],
      isVip: json['isVip'] ?? 0,
      gold: json['gold'],
      points: json['points'],
      phone: json['phone'],
      email: json['email'],
      agentLevel: json['agentLevel'],
      inviteCode: json['inviteCode'],
      isBindPhone: json['isBindPhone'],
      isBindEmail: json['isBindEmail'],
      createTime: json['createTime'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'nickName': nickName,
      'headImg': headImg,
      'sex': sex,
      'vipExpireTime': vipExpireTime,
      'isVip': isVip,
      'gold': gold,
      'points': points,
      'phone': phone,
      'email': email,
      'agentLevel': agentLevel,
      'inviteCode': inviteCode,
      'isBindPhone': isBindPhone,
      'isBindEmail': isBindEmail,
      'createTime': createTime,
    };
  }
} 
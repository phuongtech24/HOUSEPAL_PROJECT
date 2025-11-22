import 'dart:core';

class UserModel {
  final String memberId;
  final String name;
  final String email;
  final String role;
  final String avatar;
  final int point;
  UserModel({
    required this.memberId,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
    required this.point,
  });
  //chuyển dữ liệu thành map để lưu vào firestore
  Map<String, dynamic> toDocument(){
    return {
      'memberId': memberId,
      'name':name,
      'email':email,
      'role':role,
      'avatar':avatar,
      'point':point,
    };
  }
  //Giống satitc, gọi qua tên class
  factory UserModel.fromDocument(Map<String, dynamic> doc) {
    return UserModel(
      memberId: doc['memberId'] ?? '',
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      role: doc['role'] ?? 'Member',
      avatar: doc['avatar'] ?? '',
      point: doc['point'] ?? 0,
    );
  }
}
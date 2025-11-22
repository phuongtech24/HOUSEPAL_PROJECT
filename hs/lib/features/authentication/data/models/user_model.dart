import 'dart:core';

import 'package:hs/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel ({
    required super.memberId,
    required super.name,
    required super.email,
    required super.avatar,
    required super.point,
    required super.role,
  }
  );
  
  
  //chuyển dữ liệu thành map để lưu vào firestore
  Map<String, Object?> toDocument(){
    return {
      'memberId': memberId,
      'name':name,
      'email':email,
      'role':role,
      'avatar':avatar,
      'point':point,
    };
  }
  factory UserModel.fromEntity(UserEntity user){
    return UserModel(
      memberId: user.memberId,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      point: user.point,
      role: user.role, 
    );
  }

  // 4. Đọc từ Map (JSON) của Firebase về thành Model
  factory UserModel.fromDocument(Map<String, Object?> doc){
    return UserModel(
      memberId: doc['memberId'] as String,
      name: doc['name'] as String,
      email: doc['email'] as String,
      avatar: doc['avatar'] as String,
      point: doc['point'] as int,
      role: doc['role'] as String,
    );
  }
}
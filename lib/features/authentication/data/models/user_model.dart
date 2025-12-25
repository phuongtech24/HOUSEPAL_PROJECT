import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String dob;
  final String gender;
  final String bio;
  final String avatarUrl;     
  final String houseId;        
  final String role;           
  final int currentPoints;     
  final String fcmToken;       
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.dob = '',
    this.gender = 'Khác',
    this.bio = '',
    this.avatarUrl = '',
    this.houseId = '',
    this.role = 'member',
    this.currentPoints = 0,
    this.fcmToken = '',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? 'Khác',
      bio: map['bio'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      houseId: map['houseId'] ?? '',
      role: map['role'] ?? 'member',
      currentPoints: map['currentPoints'] ?? 0,
      fcmToken: map['fcmToken'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dob': dob,
      'gender': gender,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'houseId': houseId,
      'role': role,
      'currentPoints': currentPoints,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
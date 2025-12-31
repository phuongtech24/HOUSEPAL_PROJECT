import 'package:cloud_firestore/cloud_firestore.dart';

class HouseModel {
  final String id;
  final String name;
  final String adminId;
  final String inviteCode;
  final List<String> members; // Danh sách UID thành viên
  final String address;
  final DateTime createdAt;

  HouseModel({
    required this.id,
    required this.name,
    required this.adminId,
    required this.inviteCode,
    required this.members,
    this.address = '',
    required this.createdAt,
  });

  factory HouseModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HouseModel(
      id: doc.id,
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
      'inviteCode': inviteCode,
      'members': members,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
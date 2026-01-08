import 'package:cloud_firestore/cloud_firestore.dart';

class ChoreModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final String status; // pending | completed
  final List<String> groupOrder; // list uid
  final String currentGroupId;

  final String repeatType;
  final DateTime startDate;

  ChoreModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
    required this.groupOrder,
    required this.currentGroupId,
    required this.repeatType,
    required this.startDate,
  });

  factory ChoreModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChoreModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      points: data['points'] ?? 0,
      status: data['status'] ?? 'pending',
      groupOrder: List<String>.from(data['groupOrder'] ?? []),
      currentGroupId: data['currentGroupId'] ?? '',
      repeatType: data['repeatType'] ?? 'none',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

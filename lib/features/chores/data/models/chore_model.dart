import 'package:cloud_firestore/cloud_firestore.dart';

class ChoreModel {
  final String id;
  final String title;
  final String description;
  final String frequency;     
  final int points;           
  final String assigneeId;    
  final String nextAssigneeId; 
  final DateTime dueDate;
  final String status;        

  ChoreModel({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.points,
    required this.assigneeId,
    this.nextAssigneeId = '',
    required this.dueDate,
    this.status = 'pending',
  });

  factory ChoreModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChoreModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      frequency: data['frequency'] ?? 'daily',
      points: data['points'] ?? 0,
      assigneeId: data['assigneeId'] ?? '',
      nextAssigneeId: data['nextAssigneeId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'frequency': frequency,
      'points': points,
      'assigneeId': assigneeId,
      'nextAssigneeId': nextAssigneeId,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
    };
  }
}
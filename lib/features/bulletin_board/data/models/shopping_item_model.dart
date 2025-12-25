import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItemModel {
  final String id;
  final String itemName;
  final String note;
  final String requestedBy;
  final bool isBought;
  final DateTime createdAt;

  ShoppingItemModel({
    required this.id,
    required this.itemName,
    this.note = '',
    required this.requestedBy,
    this.isBought = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'note': note,
      'requestedBy': requestedBy,
      'isBought': isBought,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ShoppingItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItemModel(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      note: data['note'] ?? '',
      requestedBy: data['requestedBy'] ?? '',
      isBought: data['isBought'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
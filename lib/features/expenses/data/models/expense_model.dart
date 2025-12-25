import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String payerId;
  final String category;      // 'Điện', 'Nước', 'Ăn uống'...
  final String splitType;     // 'equal', 'percent', 'exact'
  final Map<String, double> splitDetails; // Key là UID, Value là số tiền nợ
  final DateTime date;
  final String evidenceUrl;   // Ảnh hóa đơn

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.category,
    this.splitType = 'equal',
    required this.splitDetails,
    required this.date,
    this.evidenceUrl = '',
  });

  factory ExpenseModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Xử lý Map<String, double> từ JSON
    Map<String, double> details = {};
    if (data['splitDetails'] != null) {
      (data['splitDetails'] as Map<String, dynamic>).forEach((key, value) {
        details[key] = (value as num).toDouble();
      });
    }

    return ExpenseModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      payerId: data['payerId'] ?? '',
      category: data['category'] ?? 'Khác',
      splitType: data['splitType'] ?? 'equal',
      splitDetails: details,
      date: (data['date'] as Timestamp).toDate(),
      evidenceUrl: data['evidenceUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'payerId': payerId,
      'category': category,
      'splitType': splitType,
      'splitDetails': splitDetails,
      'date': Timestamp.fromDate(date),
      'evidenceUrl': evidenceUrl,
    };
  }
}
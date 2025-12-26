import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _getHouseId() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc['houseId'];
  }

  // --- SỬA HÀM NÀY ---
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String payerId,           // UI truyền vào ai là người trả
    required String splitType,         // UI truyền vào kiểu chia ('equal', 'percent', 'exact')
    required Map<String, double> splitDetails, // UI truyền vào Map đã tính toán sẵn
    DateTime? date, // Thêm ngày giờ tùy chọn
  }) async {
    final houseId = await _getHouseId();

    final expense = ExpenseModel(
      id: '',
      title: title,
      amount: amount,
      payerId: payerId,
      category: category,
      splitType: splitType,
      splitDetails: splitDetails,
      date: date ?? DateTime.now(),
      evidenceUrl: '',
    );

    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('expenses')
        .add(expense.toMap());
  }

  // ... (Các hàm getExpensesStream, calculateMyBalance giữ nguyên)
}
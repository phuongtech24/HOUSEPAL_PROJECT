import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Lấy ID nhà của User hiện tại
  Future<String> _getHouseId() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc['houseId'];
  }

  // 2. Thêm chi tiêu (Code mới bạn đã cập nhật - OK)
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String payerId,
    required String splitType,
    required Map<String, double> splitDetails,
    DateTime? date,
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

  // 3. LẤY DANH SÁCH CHI TIÊU (Đây là hàm bạn đang THIẾU)
  Stream<List<ExpenseModel>> getExpensesStream() async* {
    try {
      final houseId = await _getHouseId();
      
      // Lắng nghe thay đổi từ collection 'expenses'
      yield* _firestore
          .collection('houses')
          .doc(houseId)
          .collection('expenses')
          .orderBy('date', descending: true) // Sắp xếp ngày mới nhất lên đầu
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ExpenseModel.fromSnapshot(doc))
                .toList();
          });
    } catch (e) {
      // Nếu lỗi (ví dụ chưa có nhà), trả về danh sách rỗng để app không crash
      print("Lỗi getExpensesStream: $e");
      yield [];
    }
  }
  // 4. THANH TOÁN NỢ (SETTLEMENT)
  // debtorId: Người nợ (Người trả tiền)
  // creditorId: Chủ nợ (Người nhận tiền)
// ... (existing code)
  Future<void> settleDebt({
    required String debtorId,
    required String creditorId,
    required double amount,
  }) async {
    final houseId = await _getHouseId();

    // Logic: Tạo một khoản chi mới
    // Người trả (Payer) = Người nợ (debtor)
    // Người thụ hưởng (Split) = Chủ nợ (creditor) nhận 100% lợi ích
    
    final settlement = ExpenseModel(
      id: '',
      title: "Thanh toán nợ",
      amount: amount,
      payerId: debtorId,
      category: "Thanh toán", // Category đặc biệt
      splitType: 'settlement',
      splitDetails: {creditorId: amount}, // Chủ nợ được hưởng trọn số tiền này
      date: DateTime.now(),
      evidenceUrl: '',
    );

    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('expenses')
        .add(settlement.toMap());
  }

  // 5. XÓA CHI TIÊU
  Future<void> deleteExpense(String expenseId) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // 6. CẬP NHẬT CHI TIÊU
  Future<void> updateExpense(ExpenseModel expense) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }
}
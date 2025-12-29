import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs/features/profile/data/models/history_item_mode.dart' show HistoryItemModel, HistoryType;
import 'package:rxdart/rxdart.dart'; // <--- Thêm dòng này

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream kết hợp (Merge) từ Tiền và Việc nhà
  Stream<List<HistoryItemModel>> getUserHistoryStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // 1. Stream Tiền (Expenses) - Chỉ lấy cái user này trả hoặc tham gia
    final expenseStream = _firestore
        .collection('expenses')
        .where('payerId', isEqualTo: user.uid) // Hoặc logic phức tạp hơn
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return HistoryItemModel(
                id: doc.id,
                title: data['description'] ?? 'Chi tiêu',
                createdAt: (data['date'] as Timestamp).toDate(),
                type: HistoryType.money,
                valueDisplay: "-${data['amount']}k", // Format tiền tùy ý
                isNegative: true,
                icon: Icons.bolt, // Hoặc logic chọn icon tùy loại chi tiêu
                bgColor: const Color(0xFFE0F9F4),
                iconColor: const Color(0xFF00BFA5),
              );
            }).toList());

    // 2. Stream Việc nhà (Chores) - Giả sử bạn có collection 'chore_completions'
    // Hoặc query từ 'chores' where 'assignee' == user.uid
    final choreStream = _firestore
        .collection('chores') // Sửa thành collection việc nhà của bạn
        .where('assigneeId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'done') // Chỉ lấy việc đã xong
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return HistoryItemModel(
                id: doc.id,
                title: data['title'] ?? 'Dọn dẹp',
                createdAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                type: HistoryType.chore,
                valueDisplay: "+${data['points'] ?? 10} điểm",
                isNegative: false,
                icon: Icons.cleaning_services,
                bgColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
              );
            }).toList());

    // 3. Gộp 2 Stream lại và sắp xếp theo thời gian (Mới nhất lên đầu)
    return Rx.combineLatest2(
      expenseStream, 
      choreStream, 
      (List<HistoryItemModel> money, List<HistoryItemModel> chores) {
        final all = [...money, ...chores];
        all.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort giảm dần
        return all;
      }
    );
  }
}
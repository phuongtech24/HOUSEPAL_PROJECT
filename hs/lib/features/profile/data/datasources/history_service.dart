import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs/features/profile/data/models/history_item_mode.dart' show HistoryItemModel, HistoryType;
import 'package:rxdart/rxdart.dart'; // <--- Thêm dòng này

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream kết hợp (Merge) từ Tiền và Việc nhà
  Stream<List<HistoryItemModel>> getUserHistoryStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    try {
      // 1. Get House ID
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc['houseId'] == null) {
        yield [];
        return;
      }
      final houseId = userDoc['houseId'];

      // 2. Stream Expenses (houses -> houseId -> expenses)
      final expenseStream = _firestore
          .collection('houses')
          .doc(houseId)
          .collection('expenses')
          .where('payerId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                return HistoryItemModel(
                  id: doc.id,
                  title: data['title'] ?? 'Chi tiêu',
                  createdAt: (data['date'] as Timestamp).toDate(),
                  type: HistoryType.money,
                  valueDisplay: "-${data['amount']}k",
                  isNegative: true,
                  icon: Icons.bolt,
                  bgColor: const Color(0xFFE0F9F4),
                  iconColor: const Color(0xFF00BFA5),
                );
              }).toList());

      // 3. Stream Chores (houses -> houseId -> chores)
      final choreStream = _firestore
          .collection('houses')
          .doc(houseId)
          .collection('chores')
          .where('status', isEqualTo: 'completed') // Only completed items
          // Note: In your structure, completed items don't explicitly store "who" completed it in a 'completedBy' field for history, 
          // but we can infer or if you store it. 
          // However, based on ChoreService, completeChore increments points for the current user.
          // BUT, the chore doc doesn't seem to store 'completedBy'. 
          // It DOES update 'currentGroupId' to next person.
          // IF YOU DON'T STORE 'completedBy', we can't filter by user easily here unless we assume 'assignee' logic or similar.
          // FOR NOW: I will show ALL completed chores in the house, or if you have a way to filter.
          // Update: The previous code assumed 'assigneeId'. Your createChore uses 'groupOrder'.
          // Let's assume for now we show all completed chores for the house history (or you need to add completedBy to ChoreModel).
          // To be safe and show *something*, let's list all completed chores.
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                return HistoryItemModel(
                  id: doc.id,
                  title: data['title'] ?? 'Dọn dẹp',
                  createdAt: (data['createdAt'] != null) ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
                  type: HistoryType.chore,
                  valueDisplay: "+${data['points'] ?? 10} điểm",
                  isNegative: false,
                  icon: Icons.cleaning_services,
                  bgColor: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue,
                );
              }).toList());

      yield* Rx.combineLatest2(
        expenseStream, 
        choreStream, 
        (List<HistoryItemModel> money, List<HistoryItemModel> chores) {
          final all = [...money, ...chores];
          all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return all;
        }
      );

    } catch (e) {
      debugPrint("History Error: $e");
      yield [];
    }
  }
}
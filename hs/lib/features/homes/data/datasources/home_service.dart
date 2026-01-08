import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/home_model.dart';
import '../../../chores/data/models/chore_model.dart';
import '../../../authentication/data/models/user_model.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===============================
  // PRIVATE: GET HOUSE ID
  // ===============================
  Future<String> _getHouseId() async {
    final uid = _auth.currentUser!.uid;
    final userDoc =
        await _firestore.collection('users').doc(uid).get();
    return userDoc['houseId'] as String;
  }

  // ===============================
  // GET CURRENT USER
  // ===============================
  Future<UserModel> getCurrentUser() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data()!);
  }

  // ===============================
  // 🏠 HOME SUMMARY
  // ===============================
  Future<HomeSummaryModel> getHomeSummary() async {
    final uid = _auth.currentUser!.uid;
    final houseId = await _getHouseId();

    final userDoc =
        await _firestore.collection('users').doc(uid).get();

    /// ===== VIỆC HÔM NAY =====
    final choresSnap = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .where('currentGroupId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    /// ===== QUỸ CHUNG =====
    final expenseSnap = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('expenses')
        .get();

    int debt = 0;   // bạn nợ
    int credit = 0; // nợ bạn

    for (final doc in expenseSnap.docs) {
      final data = doc.data();

      /// splitDetails: { uid: số tiền }
      final split =
          Map<String, dynamic>.from(data['splitDetails'] ?? {});

      if (split.containsKey(uid)) {
        debt += (split[uid] as num).toInt();
      }

      /// người trả
      if (data['payerId'] == uid) {
        credit += (data['amount'] as num).toInt();
      }
    }

    return HomeSummaryModel(
      todayChores: choresSnap.docs
          .map((e) => ChoreModel.fromSnapshot(e))
          .toList(),
      monthPoints: (userDoc['currentPoints'] ?? 0) as int,
      debt: debt,
      credit: credit,
    );
  }

  // ===============================
  // 🔔 UNREAD NOTIFICATION COUNT
  // ===============================
  Stream<int> unreadNotificationCount() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ===============================
  // 📌 RECENT ACTIVITIES
  // ===============================
  Future<List<HomeActivityModel>> getRecentActivities() async {
    final houseId = await _getHouseId();

    final choresSnap = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

    final expenseSnap = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .limit(3)
        .get();

    final List<HomeActivityModel> activities = [];

    for (final c in choresSnap.docs) {
      activities.add(
        HomeActivityModel(
          title: c['title'],
          subtitle: 'đã hoàn thành việc nhà',
          createdAt:
              (c['createdAt'] as Timestamp).toDate(),
        ),
      );
    }

    for (final e in expenseSnap.docs) {
      activities.add(
        HomeActivityModel(
          title: e['title'],
          subtitle:
              'đã thêm khoản chi ${(e['amount'] as num).toInt()}đ',
          createdAt:
              (e['date'] as Timestamp).toDate(),
        ),
      );
    }

    /// sort mới → cũ
    activities.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return activities.take(4).toList();
  }
}

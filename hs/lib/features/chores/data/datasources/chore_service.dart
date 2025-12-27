import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';
import '../models/chore_model.dart';

class ChoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> _getHouseId() async {
    final uid = _auth.currentUser!.uid;
    final userDoc =
        await _firestore.collection('users').doc(uid).get();
    return userDoc['houseId'];
  }

  /// 🔥 LẤY DANH SÁCH THÀNH VIÊN TRONG NHÀ
  Future<List<UserModel>> getHouseMembers() async {
    final houseId = await _getHouseId();

    final houseSnap =
        await _firestore.collection('houses').doc(houseId).get();
    final memberUids = List<String>.from(houseSnap['members']);

    final usersSnap = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberUids)
        .get();

    return usersSnap.docs
        .map((e) => UserModel.fromMap(e.data()))
        .toList();
  }

  /// STREAM chores
  Stream<List<ChoreModel>> getChoresStream() async* {
    final houseId = await _getHouseId();

    yield* _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((e) => ChoreModel.fromSnapshot(e)).toList(),
        );
  }
    Stream<List<UserModel>> getHouseMembersStream() async* {
  final houseId = await _getHouseId();

  yield* _firestore
      .collection('users')
      .where('houseId', isEqualTo: houseId)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((e) => UserModel.fromMap(e.data()))
            .toList(),
      );
}

  /// ✅ TẠO CHORE
  Future<void> createChore({
  required String title,
  required String description,
  required String repeatType,
  required int points,
  required List<String> groupOrder,
  required DateTime startDate,
}) async {
  final houseId = await _getHouseId();

  await _firestore
      .collection('houses')
      .doc(houseId)
      .collection('chores')
      .add({
    'title': title,
    'description': description,
    'points': points,
    'status': 'pending',
    'groupOrder': groupOrder,
    'currentGroupId': groupOrder.first,
    'repeatType': repeatType,
    'createdAt': Timestamp.now(),
    'startDate': Timestamp.fromDate(startDate),
  });
}


  /// COMPLETE + cộng điểm + xoay vòng
  Future<void> completeChore(ChoreModel chore) async {
    final uid = _auth.currentUser!.uid;
    final houseId = await _getHouseId();

    final currentIndex =
        chore.groupOrder.indexOf(chore.currentGroupId);
    final nextIndex =
        (currentIndex + 1) % chore.groupOrder.length;

    final batch = _firestore.batch();

    batch.update(
      _firestore
          .collection('houses')
          .doc(houseId)
          .collection('chores')
          .doc(chore.id),
      {
        'status': 'completed',
        'currentGroupId': chore.groupOrder[nextIndex],
      },
    );

    batch.update(
      _firestore.collection('users').doc(uid),
      {'currentPoints': FieldValue.increment(chore.points)},
    );

    await batch.commit();
  }
}

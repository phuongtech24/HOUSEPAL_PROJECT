import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';
import '../models/chore_model.dart';
import '../models/ranking_user_model.dart';


class ChoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  // PRIVATE: GET HOUSE ID
  
  Future<String> _getHouseId() async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc['houseId'];
  }

  
  // GET HOUSE MEMBERS (ONCE)
  
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

 
  // STREAM HOUSE MEMBERS
  
  Stream<List<UserModel>> getHouseMembersStream() async* {
    final houseId = await _getHouseId();

    yield* _firestore
        .collection('users')
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((e) => UserModel.fromMap(e.data())).toList(),
        );
  }

  
  // STREAM CHORES
 
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

 
  // CREATE CHORE
 
  // CREATE CHORE
 
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

  // EDIT CHORE
  Future<void> updateChore({
    required String choreId,
    required String title,
    required String description,
    required String repeatType,
    required int points,
    required List<String> groupOrder,
    required DateTime startDate,
    String? currentGroupId, // Optional: Update current assignee if needed
  }) async {
    final houseId = await _getHouseId();

    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'points': points,
      'groupOrder': groupOrder,
      'repeatType': repeatType,
      'startDate': Timestamp.fromDate(startDate),
    };
    
    // reset status if it was completed? 
    // Logic decision: If editing, usually we keep status unless explicitly reset. 
    // However, if assignee changes, we might want to ensure it's pending.
    // For now, let's simpler update.
    
    if (currentGroupId != null) {
      data['currentGroupId'] = currentGroupId;
    }

    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .doc(choreId)
        .update(data);
  }

  // DELETE CHORE
  Future<void> deleteChore(String choreId) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .doc(choreId)
        .delete();
  }


  // COMPLETE CHORE + ROTATE + POINTS

  Future<void> completeChore(ChoreModel chore) async {
    final uid = _auth.currentUser!.uid;
    final houseId = await _getHouseId();

    final currentIndex = chore.groupOrder.indexOf(chore.currentGroupId);
    final nextIndex = (currentIndex + 1) % chore.groupOrder.length;

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

    batch.update(_firestore.collection('users').doc(uid), {
      'currentPoints': FieldValue.increment(chore.points),
    });

    await batch.commit();
  }


  // SEND REMINDER
 
  Future<void> sendReminder({
    required String toUid,
    required String choreId,
    required String choreTitle,
  }) async {
    final fromUid = _auth.currentUser!.uid;

    await _firestore.collection('notifications').add({
      'toUid': toUid,
      'fromUid': fromUid,
      'choreId': choreId,
      'title': 'Nhắc việc nhà',
      'body': 'Bạn đang đến lượt làm: $choreTitle',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // MONTHLY CHORE RANKING

Future<List<UserModel>> getMonthlyRanking() async {
  final user = _auth.currentUser;
  if (user == null) return [];

  final userDoc =
      await _firestore.collection('users').doc(user.uid).get();

  if (!userDoc.exists) return [];

  final houseId = userDoc['houseId'];

  final usersSnap = await _firestore
    .collection('users')
    .where('houseId', isEqualTo: houseId)
    .orderBy('currentPoints', descending: true)
    .get();

  return usersSnap.docs
      .map((e) => UserModel.fromMap(e.data()))
      .toList();
}
  ///  STREAM RANKING – dùng cho LeaderboardCard (Việc nhà)
  Stream<List<UserModel>> getHouseRankingStream({int limit = 3}) async* {
    final uid = _auth.currentUser!.uid;

    final userDoc =
        await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      yield [];
      return;
    }

    final houseId = userDoc['houseId'];

    yield* _firestore
        .collection('users')
        .where('houseId', isEqualTo: houseId)
        .orderBy('currentPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((e) => UserModel.fromMap(e.data())).toList(),
        );
  }

}

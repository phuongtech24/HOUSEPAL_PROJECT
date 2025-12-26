import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/house_model.dart';

class HouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Tạo mã mời ngẫu nhiên 6 chữ số
  String _generateInviteCode() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  // 2. TẠO NHÀ MỚI (Admin)
  Future<void> createHouse(String houseName) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Vui lòng đăng nhập lại");

    String houseId = _firestore.collection('houses').doc().id;
    String inviteCode = _generateInviteCode();

    // Batch Write: Đảm bảo cả 2 lệnh (Tạo nhà + Sửa user) cùng thành công
    WriteBatch batch = _firestore.batch();

    // A. Tạo document House mới
    HouseModel newHouse = HouseModel(
      id: houseId,
      name: houseName,
      adminId: user.uid,
      inviteCode: inviteCode,
      members: [user.uid], // Người tạo là thành viên đầu tiên
      createdAt: DateTime.now(),
    );
    
    DocumentReference houseRef = _firestore.collection('houses').doc(houseId);
    batch.set(houseRef, newHouse.toMap());

    // B. Cập nhật User (Gán houseId và role Admin)
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    batch.update(userRef, {
      'houseId': houseId,
      'role': 'admin'
    });

    await batch.commit();
  }

  // 3. THAM GIA NHÀ (Member)
  Future<void> joinHouse(String code) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Vui lòng đăng nhập lại");

    // A. Tìm nhà có mã code này
    QuerySnapshot query = await _firestore
        .collection('houses')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("Mã mời không đúng hoặc không tồn tại");
    }

    DocumentSnapshot houseDoc = query.docs.first;
    String houseId = houseDoc.id;
    List<dynamic> currentMembers = houseDoc['members'];

    if (currentMembers.contains(user.uid)) {
      throw Exception("Bạn đã là thành viên của nhà này rồi");
    }

    WriteBatch batch = _firestore.batch();

    // B. Thêm UID vào mảng members của House
    batch.update(houseDoc.reference, {
      'members': FieldValue.arrayUnion([user.uid])
    });

    // C. Cập nhật User (Gán houseId và role Member)
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    batch.update(userRef, {
      'houseId': houseId,
      'role': 'member'
    });

    await batch.commit();
  }

  // 4. LẤY HOUSE ID CỦA USER (Để check Login xong đi đâu)
  Future<String?> getUserHouseId() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      return data['houseId']; 
    }
    return null;
  }
}
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/house_model.dart'; // Giữ nguyên import model của bạn

class HouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // PHẦN 1: CÁC HÀM CŨ (GIỮ NGUYÊN HOẶC TỐI ƯU NHẸ)
  // ==========================================

  // 1. Tạo mã mời ngẫu nhiên
  String _generateInviteCode() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  // 2. TẠO NHÀ MỚI
  Future<void> createHouse(String houseName) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Vui lòng đăng nhập lại");

    String houseId = _firestore.collection('houses').doc().id;
    String inviteCode = _generateInviteCode();

    WriteBatch batch = _firestore.batch();

    // A. Tạo document House
    // Lưu ý: Đảm bảo HouseModel của bạn có hàm toMap()
    HouseModel newHouse = HouseModel(
      id: houseId,
      name: houseName,
      adminId: user.uid,
      inviteCode: inviteCode,
      members: [user.uid],
      createdAt: DateTime.now(),
    );

    DocumentReference houseRef = _firestore.collection('houses').doc(houseId);
    batch.set(houseRef, newHouse.toMap());

    // B. Cập nhật User
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    batch.update(userRef, {
      'houseId': houseId,
      'role': 'admin'
    });

    await batch.commit();
  }

  // 3. THAM GIA NHÀ
  Future<void> joinHouse(String code) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Vui lòng đăng nhập lại");

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

    // A. Thêm UID vào House
    batch.update(houseDoc.reference, {
      'members': FieldValue.arrayUnion([user.uid])
    });

    // B. Cập nhật User
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    batch.update(userRef, {
      'houseId': houseId,
      'role': 'member'
    });

    await batch.commit();
  }

  // 4. LẤY HOUSE ID CỦA USER
  Future<String?> getUserHouseId() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      return data?['houseId'];
    }
    return null;
  }

  // ==========================================
  // PHẦN 2: CÁC HÀM MỚI (PHỤC VỤ QUẢN LÝ NHÀ)
  // ==========================================

  // 5. STREAM: Lấy thông tin nhà (Realtime - dùng cho đổi tên, xem mã mời)
  Stream<DocumentSnapshot> getHouseInfoStream(String houseId) {
    return _firestore.collection('houses').doc(houseId).snapshots();
  }

  // 6. STREAM: Lấy danh sách thành viên (Realtime - query từ collection users)
  Stream<QuerySnapshot> getHouseMembersStream(String houseId) {
    return _firestore
        .collection('users')
        .where('houseId', isEqualTo: houseId)
        .snapshots();
  }

  // 7. UPDATE: Đổi tên nhà
  Future<void> updateHouseName(String houseId, String newName) async {
    await _firestore.collection('houses').doc(houseId).update({
      'name': newName,
    });
  }

  // 8. DELETE: Xóa thành viên (Dùng Batch để xóa sạch 2 đầu)
  Future<void> removeMember(String houseId, String memberUid) async {
    WriteBatch batch = _firestore.batch();

    // A. Xóa UID khỏi mảng members trong House
    DocumentReference houseRef = _firestore.collection('houses').doc(houseId);
    batch.update(houseRef, {
      'members': FieldValue.arrayRemove([memberUid])
    });

    // B. Reset thông tin user (Xóa houseId và role)
    DocumentReference userRef = _firestore.collection('users').doc(memberUid);
    batch.update(userRef, {
      'houseId': FieldValue.delete(), // Hoặc set là null
      'role': FieldValue.delete()     // Hoặc set là null
    });

    await batch.commit();
  }

  // 9. UPDATE: Chuyển quyền Admin
  Future<void> transferAdmin(String houseId, String currentAdminUid, String newAdminUid) async {
    WriteBatch batch = _firestore.batch();

    // A. Cập nhật adminId mới cho House
    DocumentReference houseRef = _firestore.collection('houses').doc(houseId);
    batch.update(houseRef, {
      'adminId': newAdminUid
    });

    // B. Hạ quyền Admin cũ xuống Member
    DocumentReference oldAdminRef = _firestore.collection('users').doc(currentAdminUid);
    batch.update(oldAdminRef, {
      'role': 'member'
    });

    // C. Nâng quyền Member mới lên Admin
    DocumentReference newAdminRef = _firestore.collection('users').doc(newAdminUid);
    batch.update(newAdminRef, {
      'role': 'admin'
    });

    await batch.commit();
  }
  
  // 10. LEAVE: Rời nhà (Tương tự removeMember nhưng cho chính mình)
  Future<void> leaveHouse(String houseId) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    // Tận dụng hàm removeMember cho chính mình
    await removeMember(houseId, user.uid);
  }
}
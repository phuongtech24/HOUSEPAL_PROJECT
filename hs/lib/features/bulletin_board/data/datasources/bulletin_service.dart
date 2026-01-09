import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bulletin_note_model.dart';
import '../models/shopping_item_model.dart';

class BulletinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Lấy HouseID của user hiện tại
  Future<String> _getHouseId() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists || userDoc['houseId'] == null || userDoc['houseId'] == '') {
      throw Exception("Bạn chưa tham gia nhà nào");
    }
    return userDoc['houseId'];
  }

  // --- 1. GHI CHÚ (NOTES) ---

  Future<void> addNote(String title, String content, bool isPinned) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final houseId = await _getHouseId();
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName = userDoc['name'] ?? 'Thành viên'; // Thêm check null an toàn

    final note = BulletinNoteModel(
      id: '',
      title: title,
      content: content,
      authorName: userName,
      authorId: user.uid,
      isPinned: isPinned,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('notes')
        .add(note.toMap());
  }

  Future<void> updateNote(
      String noteId, String title, String content, bool isPinned) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('notes')
        .doc(noteId)
        .update({
      'title': title,
      'content': content,
      'isPinned': isPinned,
    });
  }

  Future<void> deleteNote(String noteId) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  Stream<List<BulletinNoteModel>> getNotesStream() async* {
    try {
      final houseId = await _getHouseId();
      yield* _firestore
          .collection('houses')
          .doc(houseId)
          .collection('notes')
          .orderBy('isPinned', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BulletinNoteModel.fromSnapshot(doc))
              .toList());
    } catch (e) {
      yield [];
    }
  }

  // --- 2. MUA SẮM (SHOPPING) ---

  // CẬP NHẬT: Thêm tham số quantity, unit, isUrgent, imageUrl
  Future<void> addShoppingItem(
    String itemName, 
    String note, 
    double quantity, 
    String unit, 
    bool isUrgent, {
    String? imageUrl, // Tham số tùy chọn (nếu có ảnh)
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final houseId = await _getHouseId();
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName = userDoc.data()?['name'] ?? 'Thành viên';

    // Tạo model với đầy đủ dữ liệu mới
    final item = ShoppingItemModel(
      id: '', // Firestore tự sinh
      itemName: itemName,
      note: note,
      requestedBy: userName,
      isBought: false,
      createdAt: DateTime.now(),
      // Các trường mới thêm vào:
      quantity: quantity,
      unit: unit,
      isUrgent: isUrgent,
      imageUrl: imageUrl,
    );

    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('shopping_items')
        .add(item.toMap());
  }

  // Đổi trạng thái Đã mua / Chưa mua
  Future<void> toggleShoppingItem(String itemId, bool currentStatus) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('shopping_items')
        .doc(itemId)
        .update({'isBought': !currentStatus});
  }

  Future<void> updateShoppingItem(
    String itemId, 
    String itemName, 
    String note, 
    double quantity, 
    String unit, 
    bool isUrgent, {
    String? imageUrl,
  }) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('shopping_items')
        .doc(itemId)
        .update({
      'itemName': itemName,
      'note': note,
      'quantity': quantity,
      'unit': unit,
      'isUrgent': isUrgent,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

  Future<void> deleteShoppingItem(String itemId) async {
    final houseId = await _getHouseId();
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('shopping_items')
        .doc(itemId)
        .delete();
  }

  Stream<List<ShoppingItemModel>> getShoppingStream() async* {
    try {
      final houseId = await _getHouseId();
      yield* _firestore
          .collection('houses')
          .doc(houseId)
          .collection('shopping_items')
          // --- XÓA HOẶC COMMENT 3 DÒNG ORDERBY NÀY ĐI ---
          // .orderBy('isBought', descending: false) 
          // .orderBy('isUrgent', descending: true)  
          // .orderBy('createdAt', descending: true) 
          // -----------------------------------------------
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ShoppingItemModel.fromSnapshot(doc))
              .toList());
    } catch (e) {
      // In lỗi ra để dễ debug nếu có vấn đề khác
      print("Lỗi getShoppingStream: $e"); 
      yield [];
    }
  }
}
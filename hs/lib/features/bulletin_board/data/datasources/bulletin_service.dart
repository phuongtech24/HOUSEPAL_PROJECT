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

  Future<BulletinNoteModel?> addNote(String title, String content, bool isPinned) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final houseId = await _getHouseId();
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName = userDoc['name'] ?? 'Thành viên';
    final createdAt = DateTime.now();

    final note = BulletinNoteModel(
      id: '',
      title: title,
      content: content,
      authorName: userName,
      authorId: user.uid,
      isPinned: isPinned,
      createdAt: createdAt,
    );

    final docRef = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('notes')
        .add(note.toMap());

    // Trả về note với ID từ Firestore
    return BulletinNoteModel(
      id: docRef.id,
      title: title,
      content: content,
      authorName: userName,
      authorId: user.uid,
      isPinned: isPinned,
      createdAt: createdAt,
    );
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
  Future<ShoppingItemModel?> addShoppingItem(
    String itemName, 
    String note, 
    double quantity, 
    String unit, 
    bool isUrgent, {
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final houseId = await _getHouseId();
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName = userDoc.data()?['name'] ?? 'Thành viên';
    final createdAt = DateTime.now();

    final item = ShoppingItemModel(
      id: '',
      itemName: itemName,
      note: note,
      requestedBy: userName,
      isBought: false,
      createdAt: createdAt,
      quantity: quantity,
      unit: unit,
      isUrgent: isUrgent,
      imageUrl: imageUrl,
    );

    final docRef = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('shopping_items')
        .add(item.toMap());

    // Trả về item với ID từ Firestore
    return ShoppingItemModel(
      id: docRef.id,
      itemName: itemName,
      note: note,
      requestedBy: userName,
      isBought: false,
      createdAt: createdAt,
      quantity: quantity,
      unit: unit,
      isUrgent: isUrgent,
      imageUrl: imageUrl,
    );
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
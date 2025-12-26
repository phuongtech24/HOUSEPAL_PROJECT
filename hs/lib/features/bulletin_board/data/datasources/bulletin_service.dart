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
    
    // Lấy thông tin user để biết đang ở nhà nào
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists || userDoc['houseId'] == null || userDoc['houseId'] == '') {
      throw Exception("Bạn chưa tham gia nhà nào");
    }
    return userDoc['houseId'];
  }

  // --- 1. GHI CHÚ (NOTES) ---

  // Thêm Ghi chú
  Future<void> addNote(String title, String content, bool isPinned) async {
    final user = _auth.currentUser;
    final houseId = await _getHouseId();
    
    // Lấy tên người dùng để hiển thị "Đăng bởi..."
    final userDoc = await _firestore.collection('users').doc(user!.uid).get();
    final userName = userDoc['name'];

    final note = BulletinNoteModel(
      id: '', // Firestore tự sinh ID
      title: title,
      content: content,
      authorName: userName,
      authorId: user.uid,
      isPinned: isPinned,
      createdAt: DateTime.now(),
    );

    // Lưu vào sub-collection 'notes' bên trong 'houses'
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('notes')
        .add(note.toMap());
  }

  // Lấy danh sách Ghi chú (Realtime Stream)
  Stream<List<BulletinNoteModel>> getNotesStream() async* {
    try {
      final houseId = await _getHouseId();
      yield* _firestore
          .collection('houses')
          .doc(houseId)
          .collection('notes')
          .orderBy('isPinned', descending: true) // Ghim lên đầu
          .orderBy('createdAt', descending: true) // Mới nhất lên đầu
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BulletinNoteModel.fromSnapshot(doc))
              .toList());
    } catch (e) {
      yield [];
    }
  }

  // --- 2. MUA SẮM (SHOPPING) ---

  // Thêm vật phẩm
  Future<void> addShoppingItem(String itemName, String note) async {
    final user = _auth.currentUser;
    final houseId = await _getHouseId();
    final userDoc = await _firestore.collection('users').doc(user!.uid).get();

    final item = ShoppingItemModel(
      id: '',
      itemName: itemName,
      note: note,
      requestedBy: userDoc['name'],
      isBought: false,
      createdAt: DateTime.now(),
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

  // Stream danh sách mua sắm
  Stream<List<ShoppingItemModel>> getShoppingStream() async* {
    try {
      final houseId = await _getHouseId();
      yield* _firestore
          .collection('houses')
          .doc(houseId)
          .collection('shopping_items')
          .orderBy('isBought', descending: false) // Chưa mua lên đầu
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ShoppingItemModel.fromSnapshot(doc))
              .toList());
    } catch (e) {
      yield [];
    }
  }
}
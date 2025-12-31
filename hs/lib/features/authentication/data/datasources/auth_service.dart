import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Đăng ký bằng Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 2. Đăng nhập bằng Email & Password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy tài khoản với email này.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không chính xác.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ.');
      } else {
        throw Exception(e.message ?? 'Đăng nhập thất bại.');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // 3. Lưu thông tin User vào Firestore (SỬA LẠI ĐOẠN NÀY)
  Future<void> saveUserData({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    String dob = '',
    String gender = 'Khác',
    String bio = '',
  }) async {
    try {
      print("--- BẮT ĐẦU LƯU USER ---");
      print("UID: $uid");

      // Cập nhật UserModel với đầy đủ các trường mới
      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        dob: dob,
        gender: gender,
        bio: bio,
        createdAt: DateTime.now(),
        
        // --- CÁC TRƯỜNG MỚI BỔ SUNG (Quan trọng) ---
        houseId: '',         // Mặc định rỗng (chưa vào nhà nào)
        role: 'member',      // Mặc định là thành viên
        currentPoints: 0,    // Điểm ban đầu là 0
        fcmToken: '',        // Token thông báo (cập nhật sau)
        avatarUrl: '',       // Avatar mặc định rỗng
      );

      // Lưu vào collection 'users'
      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      print("--- LƯU THÀNH CÔNG! ---");
    } catch (e) {
      print("--- LỖI RỒI: $e ---");
      throw Exception("Không thể lưu thông tin người dùng: $e");
    }
  }

  // Hàm lấy user hiện tại
  User? get currentUser => _auth.currentUser;
}
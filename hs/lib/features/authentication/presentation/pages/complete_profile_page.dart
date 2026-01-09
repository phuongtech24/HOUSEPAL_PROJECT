import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/auth_service.dart';
import '../widgets/auth_label.dart';       
import '../widgets/auth_text_field.dart';  
import '../widgets/primary_button.dart';   

class CompleteProfilePage extends StatefulWidget {
  final String initialName;
  final String initialPassword;
  final String? initialEmail;
  final String? initialPhone;
  final bool isPhoneRegistered;

  const CompleteProfilePage({
    super.key,
    required this.initialName,
    required this.initialPassword,
    this.initialEmail,
    this.initialPhone,
    required this.isPhoneRegistered,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _missingInfoController;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  String _selectedGender = "Nam";
  bool _isLoading = false;

  // 1. KHAI BÁO DANH SÁCH ẢNH CÓ SẴN (Theo Cách 2: Đường dẫn đầy đủ trong lib)
  // Bạn hãy chắc chắn đã khai báo dòng này trong pubspec.yaml:
  // assets:
  //   - lib/core/assets/avatars/
  final List<String> _avatarAssets = [
    'lib/core/assets/avatars/meo.jpg',
    'lib/core/assets/avatars/meo1.jpg',
    'lib/core/assets/avatars/meo2.jpg',
    'lib/core/assets/avatars/meo3.jpg',
  ];

  // Mặc định chọn ảnh đầu tiên (meo.jpg)
  int _selectedIndex = 0; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _missingInfoController = TextEditingController();
  }

  Future<void> _onFinish() async {
    // 1. Validate dữ liệu
    final missingInfo = _missingInfoController.text.trim();
    if (missingInfo.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Vui lòng nhập ${widget.isPhoneRegistered ? 'Email' : 'Số điện thoại'}"))
       );
       return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser; // Hoặc FirebaseAuth.instance.currentUser
      if (user == null) throw Exception("Không tìm thấy người dùng (Vui lòng đăng nhập lại)");

      // 2. LẤY ĐƯỜNG DẪN ẢNH ĐANG ĐƯỢC CHỌN
      String chosenAvatarPath = _avatarAssets[_selectedIndex];

      // 3. LƯU THÔNG TIN VÀO FIRESTORE
      // Lưu ý: Chúng ta lưu thẳng đường dẫn 'lib/core/...' vào avatarUrl
      await _authService.saveUserData(
        uid: user.uid,
        name: widget.initialName,
        email: widget.initialEmail ?? user.email ?? "",
        phoneNumber: widget.isPhoneRegistered ? (widget.initialPhone ?? "") : missingInfo,
        dob: _dobController.text.trim(),
        gender: _selectedGender,
        bio: _bioController.text.trim(),
      );

      // Update riêng trường avatarUrl (để chắc chắn nó được lưu)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'avatarUrl': chosenAvatarPath,
      });

      setState(() => _isLoading = false);

      // 4. CHUYỂN MÀN HÌNH
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String missingLabel = widget.isPhoneRegistered ? "Email" : "Số điện thoại";
    String missingHint = widget.isPhoneRegistered ? "Nhập địa chỉ Email" : "Nhập số điện thoại";
    TextInputType missingKeyType = widget.isPhoneRegistered ? TextInputType.emailAddress : TextInputType.phone;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Hoàn tất hồ sơ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Chọn một ảnh đại diện yêu thích nhé", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 20),
            
            // --- UI 1: ẢNH ĐANG ĐƯỢC CHỌN (TO) ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    // Hiển thị ảnh từ Assets
                    backgroundImage: AssetImage(_avatarAssets[_selectedIndex]),
                  ),
                  const SizedBox(height: 8),
                  const Text("Ảnh hiển thị", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- UI 2: DANH SÁCH ẢNH ĐỂ CHỌN (LIST NGANG) ---
            SizedBox(
              height: 80, // Chiều cao list
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarAssets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final bool isSelected = index == _selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index); // Cập nhật ảnh được chọn
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3), // Viền
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Nếu đang chọn -> Viền màu xanh, Không chọn -> Không viền
                        border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: AssetImage(_avatarAssets[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ----------------------------------------------------

            const SizedBox(height: 30),

            AuthLabel(text: missingLabel),
            AuthTextField(
              controller: _missingInfoController, 
              hintText: missingHint, 
              keyboardType: missingKeyType
            ),
            const SizedBox(height: 16),

            const AuthLabel(text: "Ngày sinh"),
            AuthTextField(
              controller: _dobController,
              hintText: "DD / MM / YYYY",
              suffixIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now(),
                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
                );
                if (picked != null) {
                  _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                }
              },
            ),
            const SizedBox(height: 16),

            const AuthLabel(text: "Giới tính"),
            Row(
              children: ["Nam", "Nữ", "Khác"].map((gender) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(gender),
                    selected: _selectedGender == gender,
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: _selectedGender == gender ? AppColors.primary : Colors.grey.shade300),
                    labelStyle: TextStyle(color: _selectedGender == gender ? AppColors.primary : Colors.black, fontWeight: FontWeight.bold),
                    onSelected: (val) => setState(() => _selectedGender = gender),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            const AuthLabel(text: "Giới thiệu ngắn"),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: TextField(
                controller: _bioController, maxLines: 3,
                decoration: const InputDecoration(hintText: "Chia sẻ một chút về bản thân bạn...", contentPadding: EdgeInsets.all(12), border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 30),

            // Nút bấm
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : PrimaryButton(text: "Bắt đầu ngay ->", onPressed: _onFinish),
          ],
        ),
      ),
    );
  }
}

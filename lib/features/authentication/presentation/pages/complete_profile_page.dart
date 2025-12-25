import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/auth_service.dart'; // Import AuthService
import '../widgets/auth_label.dart';       
import '../widgets/auth_text_field.dart';  
import '../widgets/primary_button.dart';   
import 'otp_verification_page.dart';

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
  
  final AuthService _authService = AuthService(); // Khởi tạo Service
  String _selectedGender = "Nam";
  bool _isLoading = false; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _missingInfoController = TextEditingController();
  }

  Future<void> _onFinish() async {
    // 1. Validate dữ liệu
    print("DEBUG: Nút đã được bấm!");
    final missingInfo = _missingInfoController.text.trim();
    final dob = _dobController.text.trim();
    final bio = _bioController.text.trim();

    if (missingInfo.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Vui lòng nhập ${widget.isPhoneRegistered ? 'Email' : 'Số điện thoại'}"))
       );
       return;
    }

    // 2. Xử lý logic theo luồng
    if (widget.isPhoneRegistered) {
       // --- TRƯỜNG HỢP SĐT (Đã OTP xong -> Lưu Data) ---
       // Logic này giả định bạn đã verify phone và user đã được tạo
       // Tạm thời chỉ điều hướng
       Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } else {
       // --- TRƯỜNG HỢP EMAIL (Đã Đăng ký Auth xong -> Cần verify Phone -> Lưu Data) ---
       // Lưu ý: Để đơn giản hóa, mình sẽ LƯU DATA LUÔN mà không qua OTP Phone.
       // Nếu bạn muốn OTP Phone thì logic sẽ phức tạp hơn.
       // Dưới đây là code LƯU DATA VÀO FIRESTORE:
       
       setState(() => _isLoading = true);

       try {
         // Lấy user hiện tại (vừa đăng ký ở bước trước)
         final user = _authService.currentUser;
         if (user == null) throw Exception("Không tìm thấy người dùng");

         // Gọi Service lưu vào Firestore
         await _authService.saveUserData(
            uid: user.uid,
            name: widget.initialName,
            email: widget.initialEmail!,
            phoneNumber: missingInfo, // SĐT người dùng nhập thêm
            dob: dob,
            gender: _selectedGender,
            bio: bio,
         );

         setState(() => _isLoading = false);

         // Thành công -> Vào App chính
         if (mounted) {
           Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
         }

       } catch (e) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Lỗi lưu hồ sơ: ${e.toString()}"))
         );
       }
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
            const Center(child: Text("Thêm ảnh đại diện để mọi người dễ\nnhận ra bạn nhé", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 20),
            
            // Avatar Picker
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Color(0xFFFFE0B2), child: Icon(Icons.person, size: 60, color: Colors.white)),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
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

            // Nút bấm có loading
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : PrimaryButton(text: "Bắt đầu ngay ->", onPressed: _onFinish),
          ],
        ),
      ),
    );
  }
}

// Widget giả _NavigateToWelcome không cần thiết nữa vì ta điều hướng trực tiếp trong hàm _onFinish
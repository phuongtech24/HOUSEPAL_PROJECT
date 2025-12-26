import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/auth_service.dart'; // Import AuthService
import '../widgets/auth_label.dart';       
import '../widgets/auth_text_field.dart';  
import '../widgets/primary_button.dart';   
import 'complete_profile_page.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService(); // Khởi tạo Service
  bool _isObscure = true;
  bool _isLoading = false; // Biến trạng thái loading

  bool _isPhoneNumber(String input) {
    final RegExp phoneRegex = RegExp(r'^[0-9]{9,}$');
    return phoneRegex.hasMatch(input);
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || contact.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin"))
      );
      return;
    }

    bool isPhone = _isPhoneNumber(contact);

    setState(() => _isLoading = true); // Bắt đầu loading

    if (isPhone) {
      // --- Xử lý cho SĐT (Tạm thời giữ nguyên logic điều hướng) ---
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            phoneNumber: contact,
            nextPage: CompleteProfilePage(
              initialName: name,
              initialPhone: contact,
              initialPassword: password,
              isPhoneRegistered: true,
            ),
          ),
        ),
      );
    } else {
      // --- Xử lý cho EMAIL (Kết nối Firebase thật) ---
      try {
        // 1. Gọi Firebase Auth tạo tài khoản
        await _authService.registerWithEmail(contact, password);
        
        setState(() => _isLoading = false);
        
        // 2. Thành công -> Chuyển sang trang Hoàn tất hồ sơ
        if (mounted) {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompleteProfilePage(
                initialName: name,
                initialEmail: contact,
                initialPassword: password,
                isPhoneRegistered: false,
              ),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        // Hiển thị lỗi từ Firebase (ví dụ: email đã tồn tại, pass yếu...)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thất bại: ${e.toString()}"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.home_work_rounded, size: 60, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text("Chào mừng đến với HousePal", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                    const SizedBox(height: 8),
                    const Text("Tạo tài khoản để bắt đầu quản lý ngôi nhà của bạn", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const AuthLabel(text: "Họ và tên"),
              AuthTextField(controller: _nameController, hintText: "Nhập họ và tên của bạn"),
              
              const SizedBox(height: 16),
              const AuthLabel(text: "Email hoặc Số điện thoại"),
              AuthTextField(controller: _contactController, hintText: "Nhập email hoặc số điện thoại"),
              
              const SizedBox(height: 16),
              const AuthLabel(text: "Mật khẩu"),
              AuthTextField(
                controller: _passwordController,
                hintText: "Tạo mật khẩu của bạn",
                isPassword: true,
                isObscure: _isObscure,
                onToggleObscure: () => setState(() => _isObscure = !_isObscure),
              ),
              
              const SizedBox(height: 24),
              
              // Nút bấm có hiệu ứng loading
              _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : PrimaryButton(text: "Đăng ký", onPressed: _handleRegister),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
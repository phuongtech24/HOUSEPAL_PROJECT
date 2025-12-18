import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/auth_label.dart';       // Import Widget mới
import '../widgets/auth_text_field.dart';  // Import Widget mới
import '../widgets/primary_button.dart';   // Import Widget mới
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
  bool _isObscure = true;

  bool _isPhoneNumber(String input) {
    final RegExp phoneRegex = RegExp(r'^[0-9]{9,}$');
    return phoneRegex.hasMatch(input);
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || contact.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ thông tin")));
      return;
    }

    bool isPhone = _isPhoneNumber(contact);

    if (isPhone) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
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

              // DÙNG WIDGET MỚI
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
              PrimaryButton(text: "Đăng ký", onPressed: _handleRegister),
              
              const SizedBox(height: 16),
              // Footer điều khoản...
            ],
          ),
        ),
      ),
    );
  }
}
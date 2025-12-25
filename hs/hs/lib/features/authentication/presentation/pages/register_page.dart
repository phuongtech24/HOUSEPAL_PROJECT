import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isObscure = true; // Ẩn/hiện mật khẩu

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Nút back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Logo & Header
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.home_work_rounded, size: 60, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text(
                      "Chào mừng đến với HousePal",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.textBlack
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tạo tài khoản để bắt đầu quản lý ngôi nhà của bạn",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Form Nhập liệu
              _buildLabel("Họ và tên"),
              _buildTextField(
                controller: _nameController, 
                hint: "Nhập họ và tên của bạn"
              ),
              const SizedBox(height: 16),

              _buildLabel("Email hoặc Số điện thoại"),
              _buildTextField(
                controller: _emailController, 
                hint: "Nhập email hoặc số điện thoại"
              ),
              const SizedBox(height: 16),

              _buildLabel("Mật khẩu"),
              _buildTextField(
                controller: _passwordController, 
                hint: "Tạo mật khẩu của bạn",
                isPassword: true,
                isObscure: _isObscure,
                onToggleObscure: () => setState(() => _isObscure = !_isObscure),
              ),
              
              const SizedBox(height: 24),

              // 3. Nút Đăng ký
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Logic Đăng ký Firebase
                    // Sau khi đăng ký xong -> Vào App (Expenses)
                    Navigator.pushNamedAndRemoveUntil(context, '/expenses', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Đăng ký", 
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Điều khoản (Text Rich)
              const Text.rich(
                TextSpan(
                  text: "Bằng việc đăng ký, bạn đồng ý với ",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  children: [
                    TextSpan(
                      text: "Điều khoản Dịch vụ",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " và "),
                    TextSpan(
                      text: "Chính sách Bảo mật",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " của chúng tôi."),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 5. Hoặc đăng nhập với...
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Hoặc đăng nhập với", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Social Buttons (Giả lập Icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.g_mobiledata, Colors.red), // Google
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.facebook, Colors.blue),    // Facebook
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.apple, Colors.black),      // Apple
                ],
              ),

              const SizedBox(height: 32),
              
              // 6. Footer: Đã có tài khoản?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Đã có tài khoản? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Quay về trang Login
                    },
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3436))),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onToggleObscure,
              )
            : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
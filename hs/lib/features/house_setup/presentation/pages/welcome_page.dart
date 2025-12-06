import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Nhà to
              const Icon(Icons.home_rounded, size: 100, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                "Chào mừng đến với\nHousePal!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textBlack),
              ),
              const SizedBox(height: 12),
              const Text(
                "Hãy bắt đầu bằng cách tạo hoặc tham gia\nmột nhà nhé.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Spacer(),

              // Nút Tạo Nhà Mới
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_house');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_home_work, color: Colors.white),
                  label: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Tạo Nhà Mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Bạn sẽ là quản trị viên (admin) của nhà", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nút Tham gia bằng mã
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/join_house');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0F9F4), // Xanh nhạt
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.qr_code, color: Colors.black87),
                  label: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Tham gia bằng mã mời", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Nhập mã từ bạn cùng nhà của bạn", style: TextStyle(color: Colors.black54, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Đăng xuất", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
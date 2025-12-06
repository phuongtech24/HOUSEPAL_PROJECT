import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/house_info_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- CẤU HÌNH GIAO DIỆN ---
    // Đặt false để xem giao diện Thành viên
    // Đặt true để xem giao diện Admin
    const bool isUserAdmin = true; 
    // --------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Header
              const ProfileHeader(
                avatarUrl: "https://i.pravatar.cc/150?img=11",
                name: "Nguyễn Văn Dũng",
                email: "dung.nguyen@housepal.com",
                // Tự động đổi chữ Admin/Thành viên dựa trên biến isUserAdmin
                role: isUserAdmin ? "Admin" : "Thành viên", 
              ),

              const SizedBox(height: 24),

              // 2. Thẻ Nhà
              HouseInfoCard(
                hasHouse: true,
                isAdmin: isUserAdmin, // Truyền trạng thái vào đây
                onTap: () {
                  // Chỉ Admin mới bấm được để vào trang quản lý
                  if (isUserAdmin) {
                    Navigator.pushNamed(context, '/house_management');
                  }
                },
              ),

              const SizedBox(height: 24),

              // 3. Tổng quan cá nhân
              Align(alignment: Alignment.centerLeft, child: Text("Tổng quan cá nhân", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard("Điểm việc nhà", "1.250", Colors.blue.shade50, Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard("Công nợ hiện tại", "-50.000đ", const Color(0xFFFFF0F0), AppColors.debtRed),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.creditGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text("Xem lịch sử của tôi", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13))),
              ),

              const SizedBox(height: 24),

              // 4. Cài đặt
              Align(alignment: Alignment.centerLeft, child: Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildSwitchItem("Thông báo việc nhà", true),
                    const Divider(height: 1),
                    _buildSwitchItem("Thông báo chi tiêu", true),
                    const Divider(height: 1),
                    _buildSwitchItem("Thông báo bảng tin", false),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text("Ngôn ngữ", style: TextStyle(fontSize: 14)),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: "Tiếng Việt",
                          items: ["Tiếng Việt", "English"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) {},
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Tài khoản
              Align(alignment: Alignment.centerLeft, child: Text("Tài khoản", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActionButton("Rời nhà", Icons.logout, const Color(0xFFFFEBEE), Colors.red, onTap: () {}),
              ),
              
              _buildActionButton("Đăng xuất", Icons.exit_to_app, Colors.grey.shade300, Colors.black87, onTap: () {
                 Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 4, 
        onTap: (index) {
          if (index == 2) Navigator.pushReplacementNamed(context, '/expenses');
          if (index == 3) Navigator.pushReplacementNamed(context, '/bulletin_board');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.cleaning_services_outlined), label: "Việc nhà"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Quỹ chung"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Bảng tin"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Hồ sơ"),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Switch(value: value, onChanged: (val) {}, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(25)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
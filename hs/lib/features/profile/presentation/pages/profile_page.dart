import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs/core/widgets/housepal_bottom_nav.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_menu_option.dart';
import 'manage_house_page.dart'; // Import trang mới tạo

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    
    // Lấy User
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data()!;
    
    String houseName = "Chưa có nhà";
    String inviteCode = "";

    // Lấy House
    if (userData['houseId'] != null && userData['houseId'].toString().isNotEmpty) {
      final houseDoc = await FirebaseFirestore.instance.collection('houses').doc(userData['houseId']).get();
      if (houseDoc.exists) {
        houseName = houseDoc['name'];
        inviteCode = houseDoc['inviteCode'];
      }
    }

    return {
      ...userData,
      'houseName': houseName,
      'inviteCode': inviteCode,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Hồ sơ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;

          final bool isAdmin = (data['role'] == 'admin');
          final String inviteCode = data['inviteCode'] ?? '';
          final String houseName = data['houseName'] ?? 'Nhà chung';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. HEADER (Có Badge Role)
                ProfileHeader(
                  name: data['name'] ?? 'User',
                  email: data['email'] ?? '',
                  avatarUrl: data['avatarUrl'] ?? '',
                  role: data['role'] ?? 'member',
                ),
                const SizedBox(height: 16),
                
                // Nút chỉnh sửa
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                    label: const Text("Chỉnh sửa thông tin", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0F9F4), elevation: 0),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. KHU VỰC NHÀ (PHÂN QUYỀN)
                if (isAdmin) 
                  // --- GIAO DIỆN ADMIN ---
                  GestureDetector(
                    onTap: () {
                      // ĐIỀU HƯỚNG SANG TRANG QUẢN LÝ (FRAME 51)
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ManageHousePage(
                            houseName: houseName, 
                            inviteCode: inviteCode
                          )
                        )
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.apartment, color: Colors.orange, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Quản lý Nhà", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("Quản lý thành viên, tài chính, quy định", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  )
                else 
                  // --- GIAO DIỆN MEMBER (GIỐNG FRAME 31) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Thông tin nhà", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        const Text("Nhà Chung", style: TextStyle(color: Colors.grey, fontSize: 13)), // Hoặc tên thật houseName
                        const SizedBox(height: 4),
                        const Text("Vai trò của bạn: Thành viên", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 12),
                        // Nút xem Mã nhà
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              _showInviteCodeDialog(context, inviteCode);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.qr_code, size: 16),
                                  SizedBox(width: 6),
                                  Text("Xem Mã Nhà", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // 3. THỐNG KÊ (Giữ nguyên)
                ProfileStatCard(points: data['currentPoints'] ?? 0, debt: -50000), // Mock
                
                const SizedBox(height: 20),

                // 4. CÀI ĐẶT (Giữ nguyên)
                // ... Copy lại phần Container Cài đặt từ code trước ...
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 8),
                      ProfileMenuOption(title: "Thông báo việc nhà", type: MenuType.switchType, switchValue: true),
                      Divider(height: 1),
                      ProfileMenuOption(title: "Thông báo chi tiêu", type: MenuType.switchType, switchValue: true),
                      Divider(height: 1),
                      ProfileMenuOption(title: "Ngôn ngữ", type: MenuType.dropdown, dropdownValue: "Tiếng Việt"),
                      Divider(height: 1),
                      ProfileMenuOption(title: "Giao diện", type: MenuType.dropdown, dropdownValue: "Hệ thống"),
                    ],
                  ),
                ),
                 const SizedBox(height: 20),

                 // 5. RỜI NHÀ / ĐĂNG XUẤT (Giữ nguyên)
                 // ... Copy lại phần Tài khoản từ code trước ...
                 Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                          label: const Text("Rời nhà", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEECEB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton.icon(
                          onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          },
                          icon: const Icon(Icons.logout, color: Colors.grey, size: 18),
                          label: const Text("Đăng xuất", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(backgroundColor: const Color(0xFFF2F4F5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 4),
    );
  }

  // Popup hiển thị mã cho Member
  void _showInviteCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mã Nhà"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.primary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép!")));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Sao chép"),
            )
          ],
        ),
      ),
    );
  }
}
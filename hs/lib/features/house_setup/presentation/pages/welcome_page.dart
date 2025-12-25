import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/house_service.dart'; // Import HouseService

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final HouseService _houseService = HouseService();
  bool _isLoading = false;

  // Controller để lấy dữ liệu nhập vào
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _houseNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  // --- LOGIC 1: ĐĂNG XUẤT ---
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Về trang Login và xóa hết lịch sử back
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // --- LOGIC 2: TẠO NHÀ MỚI ---
  void _showCreateHouseDialog() {
    _houseNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đặt tên cho Ngôi nhà"),
        content: TextField(
          controller: _houseNameController,
          decoration: const InputDecoration(
            hintText: "Ví dụ: Nhà trọ 304, Gia đình vui vẻ...",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog trước
              _createHouse(); // Gọi hàm xử lý
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Tạo ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _createHouse() async {
    final name = _houseNameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _houseService.createHouse(name);
      
      if (mounted) {
        // Tạo xong -> Vào thẳng trang chủ
        Navigator.pushReplacementNamed(context, '/expenses');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 3: THAM GIA BẰNG MÃ ---
  void _showJoinHouseDialog() {
    _inviteCodeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập mã mời"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nhập mã 6 số bạn nhận được từ admin nhà:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: _inviteCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 5, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "000000",
                counterText: "",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinHouse();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Tham gia", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _joinHouse() async {
    final code = _inviteCodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã mời phải đủ 6 số")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _houseService.joinHouse(code);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tham gia thành công!")));
        // Join xong -> Vào thẳng trang chủ
        Navigator.pushReplacementNamed(context, '/expenses');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.replaceAll("Exception: ", ""))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // GIAO DIỆN CHÍNH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
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
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _showCreateHouseDialog, // Gọi Dialog
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.add_home_work, color: Colors.white),
                      label: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tạo Nhà Mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Bạn sẽ là quản trị viên (admin) của nhà", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút Tham gia bằng mã
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _showJoinHouseDialog, // Gọi Dialog
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0F9F4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.qr_code, color: Colors.black87),
                      label: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tham gia bằng mã mời", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Nhập mã từ bạn cùng nhà của bạn", style: TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: _handleLogout,
                    child: const Text("Đăng xuất", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // LOADING OVERLAY (Hiệu ứng xoay khi đang xử lý)
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
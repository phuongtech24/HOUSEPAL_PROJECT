import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package intl vào pubspec.yaml nếu chưa có
import '../../../../core/constants/app_colors.dart';
import '../pages/user_history_page.dart'; // Import trang lịch sử vừa tạo

class ProfileStatCard extends StatelessWidget {
  final int points;
  final double debt; // Giá trị: Dương (Người khác nợ mình), Âm (Mình nợ)

  const ProfileStatCard({super.key, required this.points, required this.debt});

  @override
  Widget build(BuildContext context) {
    // Format tiền: 50000 -> 50.000đ
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    String debtString = currencyFormat.format(debt.abs()); // Lấy trị tuyệt đối để hiển thị số
    
    // Logic hiển thị
    bool isOwing = debt < 0; // Mình đang nợ
    String label = isOwing ? "Bạn đang nợ" : "Số dư hiện tại";
    Color valueColor = isOwing ? Colors.red : AppColors.primary;
    Color boxColor = isOwing ? const Color(0xFFFEECEB) : const Color(0xFFE0F9F4);
    String displayValue = isOwing ? "-$debtString" : "+$debtString";
    if (debt == 0) {
       displayValue = "0đ";
       label = "Số dư";
       valueColor = Colors.black87;
       boxColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tổng quan cá nhân", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBox("Điểm việc nhà", "$points", const Color(0xFFE0F9F4), AppColors.primary),
              const SizedBox(width: 12),
              _buildBox(label, displayValue, boxColor, valueColor),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // Điều hướng sang trang Lịch Sử
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserHistoryPage()),
                );
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0F9F4), elevation: 0),
              child: const Text("Xem lịch sử của tôi", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBox(String label, String value, Color bg, Color textC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textC)),
          ],
        ),
      ),
    );
  }
}
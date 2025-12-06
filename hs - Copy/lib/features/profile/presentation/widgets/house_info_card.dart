import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng Clipboard

class HouseInfoCard extends StatelessWidget {
  final bool hasHouse;    // Đã có nhà hay chưa
  final bool isAdmin;     // Có phải là Admin không
  final VoidCallback? onTap; // Hành động khi bấm vào thẻ (chỉ dành cho Admin hoặc chưa có nhà)

  const HouseInfoCard({
    super.key,
    required this.hasHouse,
    this.isAdmin = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TRƯỜNG HỢP 1: Chưa có nhà -> Hiển thị nút "Tạo hoặc Tham gia"
    if (!hasHouse) {
      return GestureDetector(
        onTap: onTap,
        child: _buildCardContainer(
          icon: Icons.add_home_outlined,
          iconColor: Colors.orange,
          iconBg: Colors.orange.shade50,
          title: "Tạo hoặc Tham gia Nhà",
          subtitle: "Bạn chưa là thành viên của nhà nào",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      );
    }

    // TRƯỜNG HỢP 2: Là ADMIN -> Hiển thị "Quản lý Nhà" (Bấm vào để sang trang quản lý)
    if (isAdmin) {
      return GestureDetector(
        onTap: onTap,
        child: _buildCardContainer(
          icon: Icons.home_work_outlined, // Icon toà nhà
          iconColor: Colors.orange,
          iconBg: Colors.orange.shade50,
          title: "Quản lý Nhà",
          subtitle: "Quản lý thành viên, tài chính, quy định",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      );
    }

    // TRƯỜNG HỢP 3: Là THÀNH VIÊN -> Hiển thị "Thông tin nhà" (Chỉ xem, có nút copy mã)
    return _buildCardContainer(
      icon: Icons.home, // Icon ngôi nhà nhỏ
      iconColor: Colors.blue,
      iconBg: Colors.blue.shade50,
      title: "Thông tin nhà",
      subtitle: "Nhà Chung - Vai trò: Thành viên",
      trailing: InkWell(
        onTap: () {
          Clipboard.setData(const ClipboardData(text: "122379"));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã sao chép mã nhà!")),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code, size: 14, color: Colors.black87),
              SizedBox(width: 4),
              Text("Xem Mã", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget khung thẻ chung để tái sử dụng code
  Widget _buildCardContainer({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
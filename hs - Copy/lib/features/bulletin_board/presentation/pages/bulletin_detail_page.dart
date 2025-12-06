import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BulletinDetailPage extends StatelessWidget {
  const BulletinDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Chi tiết ghi chú", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề ghi chú
              const Text(
                "Lịch dọn dẹp vệ sinh tuần này",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 20),

              // 2. Thông tin người đăng
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"), // Avatar giả lập
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Đăng bởi Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("2 giờ trước", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 20),

              // 3. Nội dung chi tiết
              const Text(
                "Xin chào mọi người,\n\n"
                "Đây là lịch phân công dọn dẹp vệ sinh khu vực chung cho tuần này nhé:\n\n"
                "• Thứ 2 & 3: Văn Dũng (Phòng 1) - Lau dọn phòng khách và ban công.\n"
                "• Thứ 4 & 5: Minh Tuấn (Phòng 2) - Vệ sinh khu vực bếp và đổ rác.\n"
                "• Thứ 6 & 7: Nam Phương (Phòng 3) - Lau dọn nhà vệ sinh chung.\n"
                "• Chủ nhật: Mọi người cùng nhau tổng vệ sinh.\n\n"
                "Mọi người chú ý hoàn thành công việc được giao để giữ gìn không gian sống chung sạch sẽ nhé!\n\n"
                "Cảm ơn cả nhà!",
                style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF2D3436)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
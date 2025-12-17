import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DebtDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const DebtDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    bool isCreditor = item['isCreditor'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết nợ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Card thông tin chính
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(item['fromAvatar']), radius: 30),
                          const SizedBox(height: 8),
                          Text(item['fromName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.arrow_forward, color: Colors.grey, size: 28),
                      ),
                      Column(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(item['toAvatar']), radius: 30),
                          const SizedBox(height: 8),
                          Text(item['toName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(item['amount'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Chưa thanh toán", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Lý do gom nợ
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
                  const Text("Lý do gom nợ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(item['description'], style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Các khoản chi liên quan (Giả lập)
            const Text("Các khoản chi liên quan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildRelatedExpense("Đi siêu thị BigC", "292.000đ", Icons.shopping_cart, Colors.blue),
            const SizedBox(height: 12),
            _buildRelatedExpense("Tiền Internet FPT", "117.000đ", Icons.wifi, Colors.purple),

            const Spacer(),

            // 4. Nút Hành động (Xanh lá)
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Trả về kết quả 'paid' để trang trước xóa item
                  Navigator.pop(context, 'paid');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Màu xanh lá chủ đạo
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isCreditor ? "Xác nhận đã nhận" : "Thanh toán ngay",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedExpense(String title, String amount, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
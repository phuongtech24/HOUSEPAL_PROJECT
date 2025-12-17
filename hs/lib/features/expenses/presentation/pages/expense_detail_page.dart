import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExpenseDetailPage extends StatelessWidget {
  // Trong thực tế, bạn sẽ truyền Expense Object vào đây. 
  // Hiện tại tôi dùng dữ liệu giả lập (dummy data) theo ảnh mẫu.
  final Map<String, dynamic>? arguments;

  const ExpenseDetailPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết khoản chi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ thông tin chính
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text("Đi siêu thị BigC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("875.000đ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 24),
                  _buildInfoRow("Người trả", "Nam Phương"),
                  const SizedBox(height: 12),
                  _buildInfoRow("Ngày chi", "28/11/2025"),
                  const SizedBox(height: 12),
                  _buildInfoRow("Loại chi tiêu", "Đi chợ"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Ghi chú
            const Text("Ghi chú", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Mua đồ ăn ở siêu thị BigC. Bao gồm: Rau củ, thịt bò và vài món ăn vặt cho cả nhà.",
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),

            const SizedBox(height: 24),

            // 3. Ảnh hóa đơn
            const Text("Ảnh hóa đơn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildImagePreview("https://picsum.photos/200/300"), // Ảnh giả lập
                const SizedBox(width: 12),
                _buildImagePreview("https://picsum.photos/200/301"),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Chi tiết chia tiền
            const Text("Chi tiết chi tiền", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Danh sách người nợ
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMemberDebtRow("Minh Tuấn", "Người trả", "292.000đ", Colors.green),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildMemberDebtRow("Văn Dũng", "Đang nợ", "292.000đ", AppColors.debtRed),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildMemberDebtRow("Bạn (Nam Phương)", "Người trả", "291.000đ", Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildImagePreview(String url) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildMemberDebtRow(String name, String status, String amount, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
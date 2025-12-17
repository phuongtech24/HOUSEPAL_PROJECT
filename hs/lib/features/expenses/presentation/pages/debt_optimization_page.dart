import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import 'debt_detail_page.dart'; // Import trang chi tiết mới

class DebtOptimizationPage extends StatefulWidget {
  const DebtOptimizationPage({super.key});

  @override
  State<DebtOptimizationPage> createState() => _DebtOptimizationPageState();
}

class _DebtOptimizationPageState extends State<DebtOptimizationPage> {
  // Dữ liệu giả lập
  List<Map<String, dynamic>> debtItems = [
    {
      "fromName": "Văn Dũng",
      "fromAvatar": "https://i.pravatar.cc/150?img=11",
      "toName": "Minh Tuấn",
      "toAvatar": "https://i.pravatar.cc/150?img=13",
      "amount": "500.000đ",
      "description": "Tổng hợp các khoản chi chung trong tháng 10",
      "isCreditor": false, // Người nợ -> Cần thanh toán
    },
    {
      "fromName": "Minh Tuấn",
      "fromAvatar": "https://i.pravatar.cc/150?img=13",
      "toName": "Nam Phương", 
      "toAvatar": "https://i.pravatar.cc/150?img=12",
      "amount": "200.000đ",
      "description": "Tiền ăn trưa hôm qua",
      "isCreditor": true, // Chủ nợ -> Cần xác nhận
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Tối ưu công nợ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.creditGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.cached, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Đã tối ưu công nợ !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Hệ thống đã tính toán và rút gọn các khoản nợ chéo.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text("Gợi ý thanh toán tối ưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            
            // Danh sách
            Expanded(
              child: debtItems.isEmpty
                  ? Center(child: Text("Không còn khoản nợ nào!", style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.builder(
                      itemCount: debtItems.length,
                      itemBuilder: (context, index) {
                        return _buildDebtItem(debtItems[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2),
    );
  }

  Widget _buildDebtItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () async {
        // Chuyển sang trang chi tiết và chờ kết quả trả về
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DebtDetailPage(item: item),
          ),
        );

        // Bảo đảm widget vẫn còn mounted trước khi sử dụng lại `context`
        if (!mounted) return;

        // Nếu trả về 'paid' (đã thanh toán/xác nhận) thì xóa khỏi danh sách
        if (result == 'paid') {
          setState(() {
            debtItems.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Giao dịch đã được xử lý thành công!"), backgroundColor: Colors.green),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(item['fromAvatar']), radius: 24),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_right_alt, color: Colors.grey)),
                CircleAvatar(backgroundImage: NetworkImage(item['toAvatar']), radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${item['fromName']} → ${item['toName']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(item['amount'], style: const TextStyle(color: AppColors.debtRed, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                  child: const Text("Chưa thanh toán", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Text("Xem chi tiết >", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
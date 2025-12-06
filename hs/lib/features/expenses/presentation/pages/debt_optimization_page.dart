import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DebtOptimizationPage extends StatelessWidget {
  const DebtOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- GIẢ LẬP DỮ LIỆU (Sau này sẽ lấy từ BLoC/Firebase) ---
    // Danh sách các khoản nợ sau khi tối ưu
    final List<Map<String, dynamic>> debtItems = [
      {
        "fromName": "Văn Dũng",
        "fromAvatar": "https://i.pravatar.cc/150?img=11",
        "toName": "Minh Tuấn",
        "toAvatar": "https://i.pravatar.cc/150?img=13",
        "amount": "500.000đ",
        "description": "Gộp nợ: Văn Dũng nợ Nam Phương 500k & Nam Phương nợ Minh Tuấn 500k",
        "isCreditor": false, // User hiện tại (Nam Phương) KHÔNG PHẢI là người nhận tiền trong giao dịch này
      },
      {
        "fromName": "Minh Tuấn",
        "fromAvatar": "https://i.pravatar.cc/150?img=13",
        "toName": "Nam Phương", // User hiện tại
        "toAvatar": "https://i.pravatar.cc/150?img=12",
        "amount": "200.000đ",
        "description": "Tiền ăn trưa hôm qua",
        "isCreditor": true, // User hiện tại LÀ người nhận tiền
      },
    ];
    // -----------------------------------------------------------

    return Scaffold(
      backgroundColor: AppColors.background,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Card thông báo đã tối ưu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.creditGreen, 
                      shape: BoxShape.circle,
                    ),
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
                        // SizedBox(height: 4),
                        // Text.rich(
                        //   TextSpan(
                        //     children: [
                        //       TextSpan(text: "Tổng số tiền phải chuyển: ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        //       TextSpan(text: "700.000đ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Gợi ý thanh toán tối ưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 2. Danh sách gợi ý chuyển tiền (Dùng ListView để hiển thị danh sách động)
            Expanded(
              child: ListView.builder(
                itemCount: debtItems.length,
                itemBuilder: (context, index) {
                  final item = debtItems[index];
                  return _buildDebtItem(
                    fromName: item['fromName'],
                    fromAvatar: item['fromAvatar'],
                    toName: item['toName'],
                    toAvatar: item['toAvatar'],
                    amount: item['amount'],
                    description: item['description'],
                    isCreditor: item['isCreditor'], // Truyền trạng thái vào
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // --- THANH NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 2, // Tab Quỹ chung
        onTap: (index) {
          if (index == 2) {
             Navigator.pop(context); 
          } else if (index == 3) {
             Navigator.pushReplacementNamed(context, '/bulletin_board');
          }
          // Xử lý các tab khác...
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.cleaning_services_outlined), label: "Việc nhà"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "Quỹ chung"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Bảng tin"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Hồ sơ"),
        ],
      ),
    );
  }

  Widget _buildDebtItem({
    required String fromName,
    required String fromAvatar,
    required String toName,
    required String toAvatar,
    required String amount,
    required String description,
    required bool isCreditor, // Thêm tham số này
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Thêm margin dưới để tách các item
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(fromAvatar), radius: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20), // Đổi icon mũi tên cho đơn giản
              ),
              CircleAvatar(backgroundImage: NetworkImage(toAvatar), radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(fromName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text("trả cho", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(toName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(amount, style: const TextStyle(color: AppColors.debtRed, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // --- NÚT BẤM TÙY CHỈNH THEO VAI TRÒ ---
          SizedBox(
            width: double.infinity,
            height: 45,
            child: isCreditor
                ? ElevatedButton.icon( // Nút cho Người cho vay (Creditor)
                    onPressed: () {
                      // TODO: Logic xác nhận đã nhận tiền
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Màu cam cho nút xác nhận
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text("Xác nhận đã nhận", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : ElevatedButton.icon( // Nút cho Người nợ (Debtor)
                    onPressed: () {
                      // TODO: Logic mở app ngân hàng / QR code
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Màu xanh cho nút thanh toán
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text("Thanh toán ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
          )
        ],
      ),
    );
  }
}
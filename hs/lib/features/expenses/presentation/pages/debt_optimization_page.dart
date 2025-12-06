import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DebtOptimizationPage extends StatelessWidget {
  const DebtOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        Text("Số giao dịch cần thanh toán: 1 (từ 2 giao dịch ban đầu)", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Tổng số tiền phải chuyển: ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              TextSpan(text: "500.000đ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Gợi ý thanh toán tối ưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 2. Danh sách gợi ý chuyển tiền
            _buildDebtItem(
              fromName: "Văn Dũng",
              fromAvatar: "https://i.pravatar.cc/150?img=11",
              toName: "Minh Tuấn",
              toAvatar: "https://i.pravatar.cc/150?img=13",
              amount: "500.000đ",
              description: "Gộp nợ: Văn Dũng nợ Nam Phương 500k & Nam Phương nợ Minh Tuấn 500k",
            ),
          ],
        ),
      ),
    bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 2, // Vẫn giữ tab Quỹ chung sáng đèn
        onTap: (index) {
          if (index == 2) {
             // Nếu bấm lại vào Quỹ chung thì quay về màn hình chính của Quỹ chung
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

  // Widget con hiển thị từng mục gợi ý chuyển khoản
  Widget _buildDebtItem({
    required String fromName,
    required String fromAvatar,
    required String toName,
    required String toAvatar,
    required String amount,
    required String description,
  }) {
    return Container(
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
              // Người trả
              CircleAvatar(backgroundImage: NetworkImage(fromAvatar), radius: 24),
              
              // Mũi tên icon ở giữa
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.currency_exchange, color: Colors.amber, size: 28),
              ),
              
              // Người nhận
              CircleAvatar(backgroundImage: NetworkImage(toAvatar), radius: 24),
              
              const SizedBox(width: 12),
              
              // Thông tin text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(fromName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
                        Text(toName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(amount, style: const TextStyle(color: AppColors.debtRed, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Nút Thanh toán
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Logic thanh toán
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Thanh toán", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
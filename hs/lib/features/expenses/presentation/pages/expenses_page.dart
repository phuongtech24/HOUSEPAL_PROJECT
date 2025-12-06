import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text("Quỹ chung", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false, // Tắt nút back mặc định
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ cân đối
            const BalanceCard(),
            
            const SizedBox(height: 24),
            
            // 2. Tiêu đề "Khoản chi tiêu gần đây" và Filter
            const Text("Khoản chi tiêu gần đây", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Filter Chips (Tháng, Loại chi, Trạng thái)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Tháng 11/2023", true),
                  const SizedBox(width: 8),
                  _buildFilterChip("Loại chi", false),
                  const SizedBox(width: 8),
                  _buildFilterChip("Trạng thái", false),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // 3. Danh sách giao dịch (Dummy Data)
            const TransactionItem(
              title: "Đi siêu thị BigC",
              payer: "Nam Phương",
              amount: "-875.000đ",
              amountColor: Colors.black,
              status: "Đang nợ",
              statusBgColor: Color(0xFFFFE0B2), 
              statusTextColor: Colors.deepOrange,
              icon: Icons.shopping_cart_outlined,
              iconBgColor: Color(0xFFE3F2FD),
            ),
            const TransactionItem(
              title: "Tiền Internet FPT",
              payer: "Minh Tuấn",
              amount: "-350.000đ",
              amountColor: Colors.black,
              status: "Đã thanh toán",
              statusBgColor: Color(0xFFE8F5E9),
              statusTextColor: Colors.green,
              icon: Icons.wifi,
              iconBgColor: Color(0xFFF3E5F5),
            ),
             const TransactionItem(
              title: "Tiền điện tháng 10",
              payer: "Bạn",
              amount: "-1.230.000đ",
              amountColor: Colors.black,
              status: "Đã thanh toán",
              statusBgColor: Color(0xFFE8F5E9),
              statusTextColor: Colors.green,
              icon: Icons.electric_bolt,
              iconBgColor: Color(0xFFFFF8E1),
            ),
             // Padding dưới cùng để nội dung không bị che bởi FAB và BottomBar
             const SizedBox(height: 80),
          ],
        ),
      ),
      
      // Floating Action Button (Nút dấu cộng)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Mở form thêm khoản chi (đã khai báo route trong main.dart)
           Navigator.pushNamed(context, '/add_expense');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      // --- CẬP NHẬT BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 2, // Đang chọn tab Quỹ chung (Index 2)
        onTap: (index) {
          // Logic chuyển trang
          if (index == 3) {
            Navigator.pushReplacementNamed(context, '/bulletin_board'); // Sang Bảng tin
          }
          // if (index == 4) Navigator.pushNamed(context, '/profile'); // Sang Hồ sơ (Sau này)
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            label: "Trang chủ"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services_outlined), 
            label: "Việc nhà"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined), 
            activeIcon: Icon(Icons.account_balance_wallet), // Icon đậm khi active
            label: "Quỹ chung"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), 
            label: "Bảng tin"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"
          ),
        ],
      ),
    );
  }

  // Widget con cho Filter Chip
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EED8), 
        borderRadius: BorderRadius.circular(20),
        // Thêm viền xám cho nút chưa chọn để dễ nhìn
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54)
        ],
      ),
    );
  }
}
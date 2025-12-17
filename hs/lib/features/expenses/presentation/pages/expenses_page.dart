import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/balance_card.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
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
<<<<<<< Updated upstream
        title: const Text("Quỹ chung", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
=======
        title: const Text(
          "Quỹ chung",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
>>>>>>> Stashed changes
        automaticallyImplyLeading: false, // Tắt nút back ở trang chính
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ cân đối
            const BalanceCard(),
            
            const SizedBox(height: 24),
<<<<<<< Updated upstream
            
            // 2. Filter Bar
            const Text("Khoản chi tiêu gần đây", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
=======

            // 2. Filter Bar
            const Text(
              "Khoản chi tiêu gần đây",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
>>>>>>> Stashed changes
            const SizedBox(height: 12),
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

            // 3. Danh sách giao dịch (ĐÃ SỬA: Thêm GestureDetector cho TẤT CẢ các mục)
<<<<<<< Updated upstream
            
=======

>>>>>>> Stashed changes
            // Mục 1: Đi siêu thị
            GestureDetector(
              onTap: () {
                // Chuyển sang màn hình Chi tiết khoản chi
<<<<<<< Updated upstream
                Navigator.pushNamed(context, '/expense_detail'); 
=======
                Navigator.pushNamed(context, '/expense_detail');
>>>>>>> Stashed changes
              },
              child: const TransactionItem(
                title: "Đi siêu thị BigC",
                payer: "Nam Phương",
                amount: "-875.000đ",
                amountColor: Colors.black,
                status: "Đang nợ",
<<<<<<< Updated upstream
                statusBgColor: Color(0xFFFFE0B2), 
=======
                statusBgColor: Color(0xFFFFE0B2),
>>>>>>> Stashed changes
                statusTextColor: Colors.deepOrange,
                icon: Icons.shopping_cart_outlined,
                iconBgColor: Color(0xFFE3F2FD),
              ),
            ),
<<<<<<< Updated upstream
            
            // Mục 2: Tiền Internet
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/expense_detail'); 
=======

            // Mục 2: Tiền Internet
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/expense_detail');
>>>>>>> Stashed changes
              },
              child: const TransactionItem(
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
            ),

            // Mục 3: Tiền điện
            GestureDetector(
              onTap: () {
<<<<<<< Updated upstream
                Navigator.pushNamed(context, '/expense_detail'); 
=======
                Navigator.pushNamed(context, '/expense_detail');
>>>>>>> Stashed changes
              },
              child: const TransactionItem(
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
            ),
<<<<<<< Updated upstream
             
             // Padding dưới cùng để nội dung không bị che bởi FAB và BottomBar
             const SizedBox(height: 80),
          ],
        ),
      ),
      
      // Nút Thêm mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.pushNamed(context, '/add_expense');
=======

            // Padding dưới cùng để nội dung không bị che bởi FAB và BottomBar
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Nút Thêm mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_expense');
>>>>>>> Stashed changes
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
<<<<<<< Updated upstream
      
=======

>>>>>>> Stashed changes
      // Bottom Navigation Bar
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
<<<<<<< Updated upstream
        color: isSelected ? const Color(0xFFD4EED8) : Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: isSelected ? null : Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(
            fontSize: 13, 
            color: isSelected ? Colors.black87 : Colors.grey[600], 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 18, color: isSelected ? Colors.black54 : Colors.grey)
=======
        color: isSelected ? const Color(0xFFD4EED8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.black87 : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: isSelected ? Colors.black54 : Colors.grey,
          ),
>>>>>>> Stashed changes
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../widgets/transaction_item.dart';
import '../widgets/balance_card.dart'; // Import file vừa tạo ở trên

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
        title: const Text(
          "Quỹ chung",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- SỬ DỤNG BALANCE CARD ĐÃ GỘP ---
            const BalanceCard(
              // QUAN TRỌNG: Dòng này quyết định tô xanh ô "Người khác nợ"
              highlightType: HighlightType.debt, 
              
              // Bạn có thể truyền số tiền vào đây (sau này lấy từ Firebase)
              totalBalance: "70.000đ",
              debtAmount: "500.000đ",
              receivableAmount: "850.000đ",
            ),
            // -----------------------------------

            const SizedBox(height: 24),

            // ... (Các phần code bên dưới giữ nguyên như cũ) ...
            const Text(
              "Khoản chi tiêu gần đây",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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

            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/expense_detail'),
              child: const TransactionItem(
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
            ),
            // ... (Các item khác)
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_expense'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
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
        ],
      ),
    );
  }
}
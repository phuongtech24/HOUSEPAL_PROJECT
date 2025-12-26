import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// Enum để định nghĩa loại nào đang được chọn
enum HighlightType {
  debt,       // Chọn ô "Bạn đang nợ"
  receivable, // Chọn ô "Người khác nợ bạn"
}

class BalanceCard extends StatelessWidget {
  final HighlightType highlightType; // Biến quyết định tô màu ô nào
  final String totalBalance;
  final String debtAmount;
  final String receivableAmount;

  const BalanceCard({
    super.key,
    // Mặc định chọn ô 'debt' (nợ), nhưng có thể thay đổi khi gọi
    this.highlightType = HighlightType.debt, 
    this.totalBalance = "70.000đ",
    this.debtAmount = "500.000đ",
    this.receivableAmount = "850.000đ",
  });

  @override
  Widget build(BuildContext context) {
    // Logic xác định viền (Border)
    // Nếu type là debt thì viền xanh, ngược lại là null
    final Border? debtBorder = (highlightType == HighlightType.debt)
        ? Border.all(color: Colors.blue, width: 2)
        : null;

    // Nếu type là receivable thì viền xanh, ngược lại là null
    final Border? receivableBorder = (highlightType == HighlightType.receivable)
        ? Border.all(color: Colors.blue, width: 2)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Dùng withOpacity cho ổn định
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng cân đối của bạn",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/debt_optimization');
                },
                child: const Text(
                  "Tối ưu công nợ >",
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          
          // --- TỔNG TIỀN ---
          Text(
            totalBalance,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // --- HAI Ô TRẠNG THÁI ---
          Row(
            children: [
              // 1. Ô BẠN ĐANG NỢ (Màu Đỏ)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0), // Nền đỏ nhạt
                    borderRadius: BorderRadius.circular(12),
                    border: debtBorder, // <--- Logic viền tự động ở đây
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bạn đang nợ",
                          style: TextStyle(
                              color: AppColors.debtRed, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(debtAmount,
                          style: const TextStyle(
                              color: AppColors.debtRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 2. Ô NGƯỜI KHÁC NỢ BẠN (Màu Xanh)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F9F4), // Nền xanh nhạt
                    borderRadius: BorderRadius.circular(12),
                    border: receivableBorder, // <--- Logic viền tự động ở đây
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Người khác nợ bạn",
                          style: TextStyle(color: Colors.teal, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(receivableAmount,
                          style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
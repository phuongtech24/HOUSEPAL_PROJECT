import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng cân đối của bạn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () {},
                child: const Text("Tối ưu công nợ >", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text("70.000đ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Ô Bạn đang nợ
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0), // Đỏ rất nhạt
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2), // Viền xanh như trong ảnh design
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bạn đang nợ", style: TextStyle(color: AppColors.debtRed, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("500.000đ", style: TextStyle(color: AppColors.debtRed, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Ô Người khác nợ bạn
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F9F4), // Xanh rất nhạt
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Người khác nợ bạn", style: TextStyle(color: Colors.teal, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("850.000đ", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18)),
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
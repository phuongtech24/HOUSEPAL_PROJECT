import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileStatCard extends StatelessWidget {
  final int points;
  final double debt;

  const ProfileStatCard({super.key, required this.points, required this.debt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tổng quan cá nhân", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBox("Điểm việc nhà", "$points", const Color(0xFFE0F9F4), AppColors.primary),
              const SizedBox(width: 12),
              _buildBox("Công nợ hiện tại", "${debt.toInt()}đ", const Color(0xFFFEECEB), Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0F9F4), elevation: 0),
              child: const Text("Xem lịch sử của tôi", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBox(String label, String value, Color bg, Color textC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textC)),
          ],
        ),
      ),
    );
  }
}
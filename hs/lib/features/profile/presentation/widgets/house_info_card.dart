import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HouseInfoCard extends StatelessWidget {
  final String houseName;

  const HouseInfoCard({super.key, required this.houseName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_work, color: AppColors.primary, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Đang ở tại:", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                houseName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }
}
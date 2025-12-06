import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String author;
  final IconData icon;
  final bool isPinned;

  const NoteCard({
    super.key,
    required this.title,
    required this.author,
    required this.icon,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F9F4), // Màu xanh ngọc nhạt đặc trưng
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textBlack, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isPinned)
            const Icon(Icons.push_pin, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/bulletin_note_model.dart';
import '../pages/bulletin_detail_page.dart';

class BulletinNoteCard extends StatelessWidget {
  final BulletinNoteModel note;

  const BulletinNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    // Logic màu sắc: Ghim -> Xanh nhạt, Thường -> Trắng
    final bgColor = note.isPinned ? const Color(0xFFE0F9F4) : Colors.white;
    final pinColor = note.isPinned ? const Color(0xFFFFB02E) : AppColors.primary.withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BulletinDetailPage(note: note)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          // Chỉ đổ bóng nếu là card trắng
          boxShadow: note.isPinned ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          border: note.isPinned ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(_getIcon(note.title), color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text("Đăng bởi: ${note.authorName}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: pinColor, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String title) {
    if (title.toLowerCase().contains("wifi")) return Icons.wifi;
    if (title.toLowerCase().contains("quy")) return Icons.gavel;
    if (title.toLowerCase().contains("vệ sinh")) return Icons.cleaning_services;
    return Icons.article;
  }
}
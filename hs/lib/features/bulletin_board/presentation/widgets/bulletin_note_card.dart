import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/bulletin_note_model.dart';
import '../pages/bulletin_detail_page.dart';

// ... (imports remain the same) 

class BulletinNoteCard extends StatelessWidget {
  final BulletinNoteModel note;

  const BulletinNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Logic màu sắc: Ghim -> Xanh nhạt (Sáng) / Xanh đậm (Tối), Thường -> Trắng / DarkGrey
    final pinnedBg = isDark ? const Color(0xFF004D40) : const Color(0xFFE0F9F4);
    final normalBg = Theme.of(context).cardTheme.color ?? Colors.white;
    
    final bgColor = note.isPinned ? pinnedBg : normalBg;
    
    final pinColor = note.isPinned 
        ? const Color(0xFFFFB02E) 
        : AppColors.primary.withOpacity(0.5);
    
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey[600];

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
          // Chỉ đổ bóng nếu là card thường (ở dark mode thì hạn chế shadow cũng được)
          boxShadow: note.isPinned ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), 
              blurRadius: 8, 
              offset: const Offset(0, 2)
            )
          ],
          border: note.isPinned ? null : Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white, // Icon bg
                shape: BoxShape.circle
              ),
              child: Icon(_getIcon(note.title), color: isDark ? Colors.white70 : Colors.black87, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)), // [FIX] Dynamic text
                  const SizedBox(height: 4),
                  Text("Đăng bởi: ${note.authorName}", style: TextStyle(color: subTextColor, fontSize: 12)), // [FIX] Dynamic subtext
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/bulletin_note_model.dart';
import '../../data/datasources/bulletin_service.dart';
import 'add_bulletin_page.dart';
import 'delete_success_page.dart';

class BulletinDetailPage extends StatelessWidget {
  final BulletinNoteModel note;
  final BulletinService _service = BulletinService();

  BulletinDetailPage({super.key, required this.note});


  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 32, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Nút Chỉnh sửa
            InkWell(
              onTap: () {
                Navigator.pop(context); // Đóng modal
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBulletinPage(note: note)),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: AppColors.primary), // Dùng màu primary hoặc xanh lá
                        SizedBox(width: 16),
                        Text("Chỉnh sửa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Nút Xóa
            InkWell(
              onTap: () async {
                // LƯU NavigatorState TRƯỚC KHI LÀM GÌ
                final navigator = Navigator.of(context);
                final rootNavigator = Navigator.of(context, rootNavigator: true);
                
                // Đóng bottom sheet
                navigator.pop();
                
                // Hiện dialog xác nhận
                final confirm = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Xác nhận xóa"),
                    content: const Text("Bạn có chắc chắn muốn xóa ghi chú này không?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false), 
                        child: const Text("Hủy")
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true), 
                        child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                // Nếu người dùng xác nhận xóa
                if (confirm == true) {
                  try {
                    // Xóa note
                    await _service.deleteNote(note.id);
                    
                    // Chuyển sang trang Thành công
                    rootNavigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => DeleteSuccessPage(
                          title: "Ghi chú đã được\nxóa thành công!",
                          message: "Thông báo đã xóa ghi chú khỏi\nBảng tin thành công!",
                        ),
                      ),
                    );
                  } catch (e) {
                    // Hiển thị lỗi nếu có
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Lỗi khi xóa: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE), // Nền đỏ nhạt
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 16),
                    Text("Xóa ghi chú này", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Nút Đóng
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB), // Xám nhạt
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text("Đóng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned Badge
            if (note.isPinned)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Xanh lá nhạt
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Đã ghim lên đầu", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            
            // Title
            Text(
              note.title, 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
            ),
            
            const SizedBox(height: 16),
            
            // Author info
            Row(
              children: [
                 CircleAvatar(
                   radius: 16,
                   backgroundColor: Colors.grey[300],
                   // Nếu có avatar thì dùng NetworkImage, tạm thời dùng Icon
                   child: const Icon(Icons.person, color: Colors.white, size: 20),
                 ),
                 const SizedBox(width: 10),
                 Text(note.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                 const SizedBox(width: 8),
                 Text("•", style: TextStyle(color: Colors.grey[400])),
                 const SizedBox(width: 8),
                 Text(
                   DateFormat('dd/MM \'lúc\' HH:mm').format(note.createdAt),
                   style: TextStyle(color: Colors.grey[500], fontSize: 13),
                 ),
              ],
            ),

             const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
             ),

             const Text("Nội dung", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
             const SizedBox(height: 12),

             // Content Container
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: const Color(0xFFF2F4F5), // Xám nhạt giống design
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Text(
                 note.content,
                 style: const TextStyle(
                   fontSize: 16, 
                   height: 1.6, 
                   color: Color(0xFF4B5563), // Xám đậm hơn cho text
                 ),
               ),
             ),
             
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
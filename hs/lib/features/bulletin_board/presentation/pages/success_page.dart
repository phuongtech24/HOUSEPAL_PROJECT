import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/bulletin_note_model.dart';
import '../../data/models/shopping_item_model.dart';
import 'bulletin_detail_page.dart';
import 'shopping_detail_page.dart';

class SuccessPage extends StatelessWidget {
  final String message;
  final String previewTitle;
  final bool isNote;
  final BulletinNoteModel? note;           // Ghi chú vừa thêm
  final ShoppingItemModel? shoppingItem;   // Vật phẩm vừa thêm

  const SuccessPage({
    super.key, 
    required this.message, 
    required this.previewTitle,
    required this.isNote,
    this.note,
    this.shoppingItem,
  });

  void _handleViewDetail(BuildContext context) {
    if (isNote && note != null) {
      // Điều hướng đến trang chi tiết ghi chú và xóa các trang trước đó trừ trang bảng tin
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BulletinDetailPage(note: note!),
        ),
        (route) => route.isFirst, // Giữ lại trang bảng tin (route đầu tiên)
      );
    } else if (!isNote && shoppingItem != null) {
      // Điều hướng đến trang chi tiết vật phẩm và xóa các trang trước đó trừ trang bảng tin
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingDetailPage(item: shoppingItem!),
        ),
        (route) => route.isFirst, // Giữ lại trang bảng tin (route đầu tiên)
      );
    } else {
      // Nếu không có dữ liệu, quay về trang bảng tin
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Dấu tích xanh to
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x3300E06C), blurRadius: 20, offset: Offset(0, 10))]
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 32),
            const Text("Thành công!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Card xem trước (Giống trong ảnh)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F9F4), // Xanh rất nhạt
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(isNote ? Icons.description : Icons.shopping_cart, color: Colors.black87, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(previewTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text("Thêm bởi Bạn • Vừa xong", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Spacer(),

            // Nút Xem - Điều hướng đến trang chi tiết
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _handleViewDetail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(isNote ? "Xem ghi chú" : "Xem vật phẩm", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            // Nút Đóng - Về trang Bảng tin
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () {
                  // Pop tất cả các trang và quay về trang bảng tin (route gốc)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDDE2E5), // Màu xám đậm hơn chút
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Đóng", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
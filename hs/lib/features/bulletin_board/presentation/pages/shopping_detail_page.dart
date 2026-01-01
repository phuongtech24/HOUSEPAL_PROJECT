import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/shopping_item_model.dart';
import '../../data/datasources/bulletin_service.dart';
import 'add_bulletin_page.dart';
import 'delete_success_page.dart';

class ShoppingDetailPage extends StatelessWidget {
  final ShoppingItemModel item;
  final BulletinService _service = BulletinService();

  ShoppingDetailPage({super.key, required this.item});

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
                  MaterialPageRoute(builder: (context) => AddBulletinPage(shoppingItem: item)),
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
                        Icon(Icons.edit, size: 20, color: AppColors.primary),
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
                // Lưu navigator trước
                final navigator = Navigator.of(context);
                final rootNavigator = Navigator.of(context, rootNavigator: true);
                
                navigator.pop(); // Đóng bottom sheet
                
                // Hiện confirm dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Xác nhận xóa"),
                    content: const Text("Bạn có chắc chắn muốn xóa vật phẩm này không?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  try {
                    await _service.deleteShoppingItem(item.id);
                    
                    // Chuyển sang trang thành công
                    rootNavigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const DeleteSuccessPage(
                          title: "Vật phẩm cần mua đã\nđược xóa thành công!",
                          message: "Thông báo đã xóa vật phẩm cần mua khỏi\nBảng tin thành công!",
                        ),
                      ),
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 16),
                    Text("Xóa vật phẩm cần mua này", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
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
      backgroundColor: Colors.white, // Hoặc màu nền chung
      appBar: AppBar(
        title: const Text("", style: TextStyle(color: Colors.black)), // Tiêu đề rỗng để giống hình
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
             icon: const Icon(Icons.more_vert, color: Colors.black),
             onPressed: () => _showOptions(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Ảnh (Placeholder hoặc thật) - Giống design
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: item.imageUrl != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 48),
                        const SizedBox(height: 8),
                        Text("Chưa có ảnh đính kèm", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: GẤP + Số lượng
                  Row(
                    children: [
                      if (item.isUrgent)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text("GẤP", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("Số lượng: ${item.quantity.toInt()} ${item.unit}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tên vật phẩm
                  Text(
                    item.itemName, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    "Thêm bởi ${item.requestedBy}", // Thêm thời gian nếu có
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(height: 1),
                  ),

                  const Text("Ghi chú", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item.note.isNotEmpty ? item.note : "Không có ghi chú.",
                      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

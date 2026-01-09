import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/shopping_item_model.dart';
import '../../data/datasources/bulletin_service.dart';
import 'add_bulletin_page.dart';

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
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                "Xóa khỏi Bảng tin",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bạn có chắc chắn muốn xóa mục đã chọn không?\nHành động này không thể hoàn tác.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Hủy bỏ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                           await _service.deleteShoppingItem(item.id);
                           if (context.mounted) {
                             Navigator.pop(ctx); // Close Dialog
                             Navigator.pop(context); // Back to list
                             // Show success dialog (optional, but requested in flow)
                             _showSuccessDialog(context);
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x3300E06C), blurRadius: 20, offset: Offset(0, 10))]
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),
              const Text(
                "Vật phẩm cần mua đã được\nxóa thành công!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 12),
              const Text(
                "Thông báo đã xóa vật phẩm cần mua khỏi Bảng tin thành công!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("Đóng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
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

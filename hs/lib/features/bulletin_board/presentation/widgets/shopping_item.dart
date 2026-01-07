import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/shopping_item_model.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const ShoppingItemCard({
    super.key, 
    required this.item, 
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên
          children: [
            // 1. Checkbox
            Padding(
              padding: const EdgeInsets.only(top: 2), // Căn chỉnh với dòng đầu tiên
              child: SizedBox(
                height: 24, width: 24,
                child: Checkbox(
                  value: item.isBought,
                  activeColor: Colors.green, // Đã mua thì màu xanh lá
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  onChanged: (_) => onToggle(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 2. Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Dòng 1: Tên + Badge GẤP ---
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            decoration: item.isBought ? TextDecoration.lineThrough : null,
                            color: item.isBought ? Colors.grey : Colors.black87
                          ),
                        ),
                      ),
                      // Hiển thị badge GẤP nếu item.isUrgent == true và chưa mua
                      if (item.isUrgent && !item.isBought)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.withOpacity(0.5)),
                          ),
                          child: const Text(
                            "GẤP",
                            style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // --- Dòng 2: Số lượng & Đơn vị + Người tạo ---
                  Row(
                    children: [
                      // Chip hiển thị số lượng (Ví dụ: 2 Cái)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${item.quantity.toInt()} ${item.unit}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Người tạo
                      Text(
                        "• Thêm bởi ${item.requestedBy}", 
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)
                      ),
                    ],
                  ),

                  // --- Dòng 3: Ghi chú (Nếu có) ---
                  if (item.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item.note, 
                        style: TextStyle(
                          color: Colors.grey[600], 
                          fontSize: 13, 
                          fontStyle: FontStyle.italic
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
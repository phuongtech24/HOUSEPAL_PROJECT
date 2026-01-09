import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/expense_model.dart';
import '../../data/datasources/ExpenseService.dart';
import 'edit_expense_page.dart';

class ExpenseDetailPage extends StatelessWidget {
  // 1. Khai báo biến nhận dữ liệu
  final ExpenseModel expense;

  const ExpenseDetailPage({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final ExpenseService _service = ExpenseService();

    // Dynamic Colors
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Chi tiết giao dịch", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Nút Sửa
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditExpensePage(expense: expense),
                ),
              );
            },
          ),
          // Nút Xóa
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmDialog(context, _service);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon và Tên khoản chi
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForCategory(expense.category),
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    expense.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${currencyFormat.format(expense.amount)}đ",
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: expense.splitType == 'settlement' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Thông tin chi tiết
            _buildDetailRow(Icons.category, "Danh mục", expense.category, textColor),
            _buildDetailRow(Icons.calendar_today, "Thời gian", dateFormat.format(expense.date), textColor),
            
            _buildDetailRow(Icons.person, "Người trả tiền", _formatPayerId(expense.payerId), textColor), 
            
            Divider(height: 40, color: Colors.grey.shade300),
            
            Text("Chia sẻ với:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            const SizedBox(height: 10),
            
            // Danh sách người tham gia
            ...expense.splitDetails.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Thành viên...${entry.key.substring(0, 4)}", style: TextStyle(color: textColor)), 
                    Text("${currencyFormat.format(entry.value)}đ", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
              );
            }).toList(), 
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ExpenseService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa khoản chi?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await service.deleteExpense(expense.id);
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Về trang danh sách
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xóa khoản chi")),
              );
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Hàm phụ trợ để hiển thị ID cho gọn (vì chưa load được tên thật từ ID)
  String _formatPayerId(String id) {
    if (id.isEmpty) return "Không rõ";
    // Nếu ID quá dài, cắt bớt cho đẹp
    if (id.length > 5) return "Thành viên (...${id.substring(0, 5)})";
    return id;
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    String cat = category.toLowerCase();
    if (cat.contains("thanh toán") || cat.contains("trả nợ")) return Icons.check_circle_outline;
    if (cat.contains("điện")) return Icons.electric_bolt;
    if (cat.contains("nước")) return Icons.water_drop;
    if (cat.contains("net") || cat.contains("wifi")) return Icons.wifi;
    if (cat.contains("chợ") || cat.contains("ăn")) return Icons.shopping_cart;
    if (cat.contains("nhà")) return Icons.home;
    return Icons.receipt_long;
  }
}
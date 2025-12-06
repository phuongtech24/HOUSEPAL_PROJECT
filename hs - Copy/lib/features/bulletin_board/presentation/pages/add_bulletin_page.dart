import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddBulletinPage extends StatefulWidget {
  const AddBulletinPage({super.key});

  @override
  State<AddBulletinPage> createState() => _AddBulletinPageState();
}

class _AddBulletinPageState extends State<AddBulletinPage> {
  int _selectedIndex = 0; // 0: Ghi chú, 1: Mua sắm
  bool _isPinned = false; // Trạng thái ghim

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Thêm mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TAB SWITCHER (Ghi chú | Mua sắm) ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabItem("Ghi chú", 0),
                  _buildTabItem("Mua sắm", 1),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hiển thị Form tương ứng với Tab đang chọn
            if (_selectedIndex == 0) _buildNoteForm() else _buildShoppingForm(),
          ],
        ),
      ),
      
      // Nút Lưu ở dưới cùng
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Logic lưu vào database
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thêm mới thành công!"), 
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _selectedIndex == 0 ? "Lưu ghi chú" : "Thêm vật phẩm",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Widget con: Item của Tab
  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Widget con: Form Ghi chú
  Widget _buildNoteForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Tiêu đề"),
        _buildTextField(hint: "Ví dụ: Lịch dọn vệ sinh tuần này"),
        const SizedBox(height: 16),
        _buildLabel("Nội dung"),
        Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const TextField(
            maxLines: null,
            decoration: InputDecoration.collapsed(
              hintText: "Nhập nội dung ghi chú của bạn ở đây...",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Toggle Ghim
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.push_pin, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                const Text("Ghim ghi chú", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            Switch(
              value: _isPinned,
              onChanged: (val) => setState(() => _isPinned = val),
              activeColor: AppColors.primary,
            ),
          ],
        )
      ],
    );
  }

  // Widget con: Form Mua sắm
  Widget _buildShoppingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Tên vật phẩm cần mua"),
        _buildTextField(hint: "Ví dụ: Dầu ăn, nước rửa bát..."),
        const SizedBox(height: 16),
        _buildLabel("Ghi chú (Tùy chọn)"),
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const TextField(
            maxLines: null,
            decoration: InputDecoration.collapsed(
              hintText: "Ví dụ: Hãng Simple, Chai to...",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
    );
  }

  Widget _buildTextField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
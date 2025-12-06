import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreateHousePage extends StatefulWidget {
  const CreateHousePage({super.key});

  @override
  State<CreateHousePage> createState() => _CreateHousePageState();
}

class _CreateHousePageState extends State<CreateHousePage> {
  // Controller để quản lý dữ liệu nhập vào
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Nền màu xám nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo Nhà Mới", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Thiết lập ngôi nhà chung của bạn", 
              style: TextStyle(color: Colors.grey)
            ),
            const SizedBox(height: 32),

            // --- 1. Ảnh đại diện nhà (Placeholder) ---
            GestureDetector(
              onTap: () {
                // TODO: Mở thư viện ảnh để chọn avatar cho nhà
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade100, width: 2),
                ),
                child: const Icon(Icons.add_photo_alternate, size: 40, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Thêm ảnh đại diện cho \"Nhà\"", 
              style: TextStyle(fontSize: 12, color: Colors.grey)
            ),
            
            const SizedBox(height: 32),

            // --- 2. Form nhập liệu ---
            _buildLabel("Tên nhà*"),
            _buildTextField(
              controller: _nameController, 
              hint: "Ví dụ: Nhà trọ Hạnh Phúc"
            ),
            
            const SizedBox(height: 20),
            
            _buildLabel("Mô tả (Không bắt buộc)"),
            _buildTextField(
              controller: _descController, 
              hint: "Ví dụ: Địa chỉ, quy định chung...", 
              maxLines: 4
            ),

            const SizedBox(height: 40),

            // --- 3. Nút Tạo ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Validate dữ liệu
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập tên nhà!"), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // TODO: Gọi API/Firebase tạo nhà mới tại đây
                  
                  // Giả lập thành công -> Quay lại hoặc chuyển vào trang Home
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tạo nhà thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Màu xanh chủ đạo
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Tạo nhà", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tiện ích để vẽ nhãn (Label)
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  // Widget tiện ích để vẽ ô nhập liệu (TextField)
  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
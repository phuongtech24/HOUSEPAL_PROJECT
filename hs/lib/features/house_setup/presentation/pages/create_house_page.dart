import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/primary_button.dart'; 
// Lưu ý: Đảm bảo bạn có file primary_button.dart trong folder house_setup/presentation/widgets/
// Nếu không có, hãy thay thế widget PrimaryButton bên dưới bằng ElevatedButton thường.

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

  void _handleCreateHouse() {
    // 1. Validate dữ liệu
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên nhà!"), backgroundColor: Colors.red),
      );
      return;
    }

    // TODO: Gọi API/Firebase tạo nhà mới tại đây
    
    // 2. Thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tạo nhà thành công!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // 3. CHUYỂN HƯỚNG
    Navigator.pushNamedAndRemoveUntil(context, '/expenses', (route) => false);
  }

  // Hàm helper để tạo style cho TextField giống nhau (Thay thế AuthTextField)
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
          crossAxisAlignment: CrossAxisAlignment.start, // Canh lề trái cho Label
          children: [
            const Center(
              child: Text(
                "Thiết lập ngôi nhà chung của bạn", 
                style: TextStyle(color: Colors.grey)
              ),
            ),
            const SizedBox(height: 32),

            // --- 1. Ảnh đại diện nhà ---
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Mở thư viện ảnh
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
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // --- 2. Form nhập liệu ---
            
            // Thay AuthLabel bằng Text thường
            const Text(
              "Tên nhà*", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
            ),
            const SizedBox(height: 8),
            
            // Thay AuthTextField bằng TextField thường với decoration
            TextField(
              controller: _nameController,
              decoration: _buildInputDecoration("Ví dụ: Nhà trọ Hạnh Phúc"),
            ),
            
            const SizedBox(height: 20),
            
            // Thay AuthLabel bằng Text thường
            const Text(
              "Mô tả (Không bắt buộc)", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
            ),
            const SizedBox(height: 8),

            // Ô nhập mô tả nhiều dòng
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: _buildInputDecoration("Ví dụ: Địa chỉ, quy định chung..."),
            ),

            const SizedBox(height: 40),

            // --- 3. Nút Tạo ---
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Tạo nhà", 
                onPressed: _handleCreateHouse
              ),
            ),
          ],
        ),
      ),
    );
  }
}
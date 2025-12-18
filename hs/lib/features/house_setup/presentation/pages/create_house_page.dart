import 'package:flutter/material.dart';
import 'package:hs/features/authentication/presentation/widgets/auth_label.dart';
import 'package:hs/features/authentication/presentation/widgets/auth_text_field.dart';
import '../../../../core/constants/app_colors.dart';
// Import các widget dùng chung (đường dẫn tùy thuộc vào cấu trúc folder của bạn)
import '../../authentication/presentation/widgets/auth_label.dart';
import '../../authentication/presentation/widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';   

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
    // Ví dụ: await houseRepository.createHouse(...);

    // 2. Thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tạo nhà thành công!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // 3. CHUYỂN HƯỚNG VỀ TRANG CHỦ
    // Xóa hết các trang cũ (Welcome, CreateHouse) khỏi stack và vào thẳng Expenses (hoặc Home)
    Navigator.pushNamedAndRemoveUntil(context, '/expenses', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Hoặc Color(0xFFF5F6FA) tùy thiết kế
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
            
            const SizedBox(height: 32),

            // --- 2. Form nhập liệu (Dùng Widget tái sử dụng) ---
            
            const AuthLabel(text: "Tên nhà*"),
            AuthTextField(
              controller: _nameController, 
              hintText: "Ví dụ: Nhà trọ Hạnh Phúc"
            ),
            
            const SizedBox(height: 20),
            
            const AuthLabel(text: "Mô tả (Không bắt buộc)"),
            // Với AuthTextField mặc định chỉ 1 dòng, nếu muốn nhiều dòng 
            // bạn có thể sửa AuthTextField để nhận maxLines hoặc dùng Container bọc TextField thủ công
            // Ở đây mình dùng Container thủ công cho ô Mô tả để đẹp hơn
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Ví dụ: Địa chỉ, quy định chung...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- 3. Nút Tạo (Dùng Widget tái sử dụng) ---
            PrimaryButton(
              text: "Tạo nhà", 
              onPressed: _handleCreateHouse
            ),
          ],
        ),
      ),
    );
  }
}
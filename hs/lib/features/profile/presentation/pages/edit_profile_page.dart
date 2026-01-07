import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart'; // Đảm bảo import đúng file màu của bạn
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  // Bạn có thể truyền dữ liệu user hiện tại vào đây để hiển thị sẵn
  final String? currentName;
  final String? currentEmail;
  final String? currentPhone;
  final String? currentBio;
  final String? currentDob;
  final String? currentGender;

  const EditProfilePage({
    super.key,
    this.currentName,
    this.currentEmail,
    this.currentPhone,
    this.currentBio,
    this.currentDob,
    this.currentGender,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller để quản lý dữ liệu nhập vào
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu (nếu có truyền vào, không thì để trống)
    _nameController = TextEditingController(text: widget.currentName ?? "Nguyễn Văn Dũng");
    _bioController = TextEditingController(text: widget.currentBio ?? "Thích sạch sẽ, yêu màu hồng...");
    _phoneController = TextEditingController(text: widget.currentPhone ?? "0987654321");
    _emailController = TextEditingController(text: widget.currentEmail ?? "dung.nguyen@housepal.com");
    _dobController = TextEditingController(text: widget.currentDob ?? "20/10/1999");
    _selectedGender = widget.currentGender ?? 'Nam';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999, 10, 20),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary), // Màu lịch
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // Show loading or just wait
                // For simplicity, we just await
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                   'name': _nameController.text.trim(),
                   'bio': _bioController.text.trim(),
                   'phoneNumber': _phoneController.text.trim(),
                   'dob': _dobController.text.trim(),
                   'gender': _selectedGender,
                });

                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Cập nhật thành công!")),
                   );
                   Navigator.pop(context, true); // Return true to indicate update
                }
              } catch (e) {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("Lỗi: $e")),
                   );
                 }
              }
            },
            child: const Text("Lưu", style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR ---
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/300"), // Thay bằng link ảnh thật
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- PHẦN 1: THÔNG TIN CƠ BẢN ---
            const Text("Thông tin cơ bản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            _buildLabel("Họ và tên"),
            _buildTextField(controller: _nameController, hint: "Nhập họ tên", icon: Icons.person_outline),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Ngày sinh"),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer( // Chặn nhập tay, chỉ cho chọn lịch
                          child: _buildTextField(controller: _dobController, hint: "dd/mm/yyyy", icon: Icons.calendar_today),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Giới tính"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            items: _genderOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel("Giới thiệu ngắn"),
            _buildTextField(controller: _bioController, hint: "Mô tả bản thân...", maxLines: 3),

            const SizedBox(height: 30),

            // --- PHẦN 2: LIÊN HỆ ---
            const Text("Thông tin liên hệ & Bảo mật", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            
            _buildLabel("Số điện thoại"),
            _buildTextField(controller: _phoneController, hint: "Nhập số điện thoại", icon: Icons.phone_android),

            const SizedBox(height: 16),
            _buildLabel("Email"),
            _buildTextField(controller: _emailController, hint: "Email", icon: Icons.email_outlined, readOnly: true), // Email thường không cho sửa
            
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text("Lưu ý: Thay đổi Email hoặc SĐT sẽ cần xác thực OTP", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget helper để vẽ Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  // Widget helper để vẽ TextField
  Widget _buildTextField({
    required TextEditingController controller, 
    String? hint, 
    IconData? icon, 
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}




import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Cần import package này
import 'package:hs/core/widgets/housepal_bottom_nav.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/bulletin_service.dart';
import 'success_page.dart';

class AddBulletinPage extends StatefulWidget {
  const AddBulletinPage({super.key});

  @override
  State<AddBulletinPage> createState() => _AddBulletinPageState();
}

class _AddBulletinPageState extends State<AddBulletinPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BulletinService _service = BulletinService();
  
  // --- Controllers Ghi chú ---//
  final _titleController = TextEditingController();
  final _contentController = TextEditingController(); 
  bool _isPinned = false;

  // --- Controllers Mua sắm (MỚI) ---
  final _itemNameController = TextEditingController(); 
  final _itemNoteController = TextEditingController();
  double _quantity = 1;      // Mặc định số lượng là 1
  String _selectedUnit = 'Cái'; // Mặc định đơn vị
  bool _isUrgent = false;    // Mặc định không gấp
  File? _selectedImage;      // Biến lưu ảnh đã chọn

  bool _isLoading = false;

  // Danh sách đơn vị để chọn
  final List<String> _units = ['Cái', 'Kg', 'Hộp', 'Chai', 'Gói', 'Lít', 'Quả'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Lắng nghe để cập nhật lại UI khi chuyển tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      String successMsg = "";
      String subMsg = "";
      bool isNote = _tabController.index == 0;

      if (isNote) {
        // Xử lý lưu Ghi chú
        await _service.addNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
          _isPinned,
        );
        successMsg = "Ghi chú mới của bạn đã được thêm vào Bảng tin chung.";
        subMsg = _titleController.text;
      } else {
        // Xử lý lưu Mua sắm (Đã cập nhật đủ tham số)
        await _service.addShoppingItem(
          _itemNameController.text.trim(), // 1. Tên
          _itemNoteController.text.trim(), // 2. Ghi chú
          _quantity,                       // 3. Số lượng
          _selectedUnit,                   // 4. Đơn vị
          _isUrgent,                       // 5. Gấp hay không
          // imageUrl: ... (Nếu sau này bạn làm upload ảnh thì truyền link vào đây)
        );
        successMsg = "Vật phẩm cần mua sắm mới của bạn đã được thêm vào Bảng tin chung.";
        subMsg = _itemNameController.text;
      }

      if (mounted) {
        // Chuyển sang trang Thành công
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(
              message: successMsg,
              previewTitle: subMsg,
              isNote: isNote,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thêm mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Switcher
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
              ),
              labelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: "Ghi chú"), Tab(text: "Mua sắm")],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Form Ghi chú (Giữ nguyên)
                _buildNoteForm(),

                // 2. Form Mua sắm (CẬP NHẬT MỚI - GIỐNG DESIGN)
                _buildShoppingForm(),
              ],
            ),
          ),

          // Nút Lưu
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_tabController.index == 0 ? "Lưu ghi chú" : "Thêm vật phẩm", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Widget Form Ghi chú ---
  Widget _buildNoteForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Tiêu đề"),
          _buildInput(_titleController, "Ví dụ: Lịch dọn vệ sinh tuần này"),
          const SizedBox(height: 20),
          _buildLabel("Nội dung"),
          _buildInput(_contentController, "Nhập nội dung ghi chú của bạn ở đây...", maxLines: 6),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                  Icon(Icons.push_pin, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text("Ghim ghi chú", style: TextStyle(fontWeight: FontWeight.w600)),
                ]),
                Switch(
                  value: _isPinned,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isPinned = val),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Widget Form Mua sắm (GIAO DIỆN MỚI) ---
  Widget _buildShoppingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tên vật phẩm
          _buildLabel("Tên vật phẩm"),
          _buildInput(_itemNameController, "Ví dụ: Con cá, Con gà..."),
          
          const SizedBox(height: 20),

          // 2. Số lượng & Đơn vị (Row)
          _buildLabel("Số lượng & Đơn vị"),
          Row(
            children: [
              // Bộ đếm số lượng (+ / -)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text(
                      _quantity.toInt().toString(), 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Dropdown Đơn vị
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      items: _units.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUnit = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. GẤP - Hết sạch rồi (Card màu cam nhạt)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6), // Màu cam nhạt
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD591).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("GẤP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text("Hết sạch rồi!", style: TextStyle(color: Colors.orange, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _isUrgent,
                  activeColor: Colors.orange,
                  activeTrackColor: Colors.orange.withOpacity(0.3),
                  onChanged: (val) => setState(() => _isUrgent = val),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Ghi chú thêm
          _buildLabel("Ghi chú thêm"),
          _buildInput(_itemNoteController, "Ghi chú thêm (VD: Mua loại tươi nhé)...", maxLines: 3),

          const SizedBox(height: 20),

          // 5. Ảnh mẫu
          _buildLabel("Ảnh mẫu"),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _selectedImage != null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: AppColors.primary, size: 32),
                      SizedBox(height: 8),
                      Text("Đính kèm ảnh mẫu", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
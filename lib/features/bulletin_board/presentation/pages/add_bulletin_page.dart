import 'package:flutter/material.dart';
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
  
  // Controllers
  final _titleController = TextEditingController();
  final _contentController = TextEditingController(); 
  final _itemNameController = TextEditingController(); 
  final _itemNoteController = TextEditingController();
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      String successMsg = "";
      String subMsg = "";
      bool isNote = _tabController.index == 0;

      if (isNote) {
        await _service.addNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
          _isPinned,
        );
        successMsg = "Ghi chú mới của bạn đã được thêm vào Bảng tin chung.";
        subMsg = _titleController.text;
      } else {
        await _service.addShoppingItem(
          _itemNameController.text.trim(),
          _itemNoteController.text.trim(),
        );
        successMsg = "Vật phẩm cần mua sắm mới của bạn đã được thêm vào Bảng tin chung.";
        subMsg = _itemNameController.text;
      }

      if (mounted) {
        // Chuyển sang trang Thành công (Giống Frame 53/54)
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
          icon: const Icon(Icons.close, color: Colors.black), // Nút X
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thêm mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Switcher (Ghi chú | Mua sắm) - Giống Design
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
              dividerColor: Colors.transparent, // Bỏ gạch chân
              tabs: const [Tab(text: "Ghi chú"), Tab(text: "Mua sắm")],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Form Ghi chú (Frame 39)
                SingleChildScrollView(
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
                      
                      // Toggle Ghim
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
                ),

                // 2. Form Mua sắm (Frame 41)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tên vật phẩm"),
                      _buildInput(_itemNameController, "Bình xịt côn trùng"),
                      const SizedBox(height: 20),
                      _buildLabel("Ghi chú (Tùy chọn)"),
                      _buildInput(_itemNoteController, "Chai bé nhé", maxLines: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nút Lưu to màu xanh
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
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 3, isSubPage: true),
    );
  }

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
      ),
    );
  }
}
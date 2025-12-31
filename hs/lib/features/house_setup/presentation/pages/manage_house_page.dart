import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs/features/house_setup/data/datasources/house_service.dart';

// Import Service và Constants
import '../../../../core/constants/app_colors.dart';

// Import các trang con
import 'house_members_page.dart';
import 'transfer_admin_page.dart';

class ManageHousePage extends StatefulWidget {
  final String houseName;
  final String inviteCode;
  
  // THÊM: Cần ID để gọi API và phân quyền
  final String houseId; 
  final String adminId; 

  const ManageHousePage({
    super.key,
    required this.houseName,
    required this.inviteCode,
    required this.houseId, // <--- Bắt buộc
    required this.adminId, // <--- Bắt buộc
  });

  @override
  State<ManageHousePage> createState() => _ManageHousePageState();
}

class _ManageHousePageState extends State<ManageHousePage> {
  late String currentHouseName;

  @override
  void initState() {
    super.initState();
    currentHouseName = widget.houseName;
  }

  // LOGIC: Đổi tên nhà (Đã kết nối Firebase)
  void _showRenameDialog() {
    final TextEditingController controller = TextEditingController(text: currentHouseName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi tên nhà"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Nhập tên mới",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  // 1. Gọi Firebase Service để cập nhật
                  await HouseService().updateHouseName(widget.houseId, controller.text);
                  
                  // 2. Cập nhật UI
                  setState(() {
                    currentHouseName = controller.text;
                  });
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Đóng dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đổi tên thành công!")),
                    );
                  }
                } catch (e) {
                  // Xử lý lỗi nếu có
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Quản lý Nhà", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD TÊN NHÀ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.apartment, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tên nhà", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(currentHouseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _showRenameDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Text("Đổi tên nhà", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.edit, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. MÃ MỜI THAM GIA
            const Text("Mã mời tham gia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.inviteCode, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2)
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép mã!")));
                    },
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                    label: const Text("Sao chép", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. QUẢN LÝ CHUNG
            const Text("Quản lý chung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.people, iconColor: Colors.green, 
                    bgIcon: const Color(0xFFE8F5E9),
                    title: "Thành viên", subtitle: "Quản lý danh sách thành viên",
                    onTap: () {
                      // SỬA: Truyền houseId và adminId
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => HouseMembersPage(
                          houseId: widget.houseId, 
                          adminId: widget.adminId
                        )
                      ));
                    }
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuTile(
                    icon: Icons.admin_panel_settings, iconColor: Colors.amber, 
                    bgIcon: const Color(0xFFFFF8E1),
                    title: "Chuyển quyền Admin", subtitle: "Bàn giao quyền quản trị",
                    onTap: () {
                       // SỬA: Truyền houseId
                       Navigator.push(context, MaterialPageRoute(
                        builder: (_) => TransferAdminPage(
                          houseId: widget.houseId
                        )
                      ));
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon, required Color iconColor, required Color bgIcon,
    required String title, required String subtitle, required VoidCallback onTap
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
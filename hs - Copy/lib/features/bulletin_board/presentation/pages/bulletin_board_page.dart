import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/bulletin_filter_bar.dart';
import '../widgets/note_card.dart';
import '../widgets/shopping_item.dart';

class BulletinBoardPage extends StatefulWidget {
  const BulletinBoardPage({super.key});

  @override
  State<BulletinBoardPage> createState() => _BulletinBoardPageState();
}

class _BulletinBoardPageState extends State<BulletinBoardPage> {
  String _selectedFilter = "Hôm nay";
  
  // Biến giả lập trạng thái checkbox mua sắm
  bool isNuocRuaChenDone = false;
  bool isGiayVeSinhDone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Bảng tin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // Tắt nút back mặc định vì đã có BottomBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thanh Filter (Hôm nay | Ghi chú | Mua sắm)
            BulletinFilterBar(
              selectedFilter: _selectedFilter,
              onFilterSelected: (val) {
                setState(() => _selectedFilter = val);
              },
            ),

            // 2. Section: Ghi chú chung
            const Text("Ghi chú chung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            const NoteCard(
              title: "Mật khẩu Wifi",
              author: "Người trả: Minh Tuấn",
              icon: Icons.wifi,
              isPinned: true,
            ),
            const NoteCard(
              title: "Nội quy nhà",
              author: "Thêm bởi Admin",
              icon: Icons.format_list_bulleted,
              isPinned: true,
            ),
            const NoteCard(
              title: "Lịch dọn vệ sinh",
              author: "Thêm bởi Admin",
              icon: Icons.calendar_month,
              isPinned: true,
            ),

            const SizedBox(height: 24),

            // 3. Section: Cần mua sắm
            const Text("Cần mua sắm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ShoppingItem(
              itemName: "Nước rửa chén",
              addedBy: "Minh Tuấn",
              isChecked: isNuocRuaChenDone,
              onTap: () {
                setState(() => isNuocRuaChenDone = !isNuocRuaChenDone);
              },
            ),
            ShoppingItem(
              itemName: "Giấy vệ sinh",
              addedBy: "Nam Phương",
              isChecked: isGiayVeSinhDone,
              onTap: () {
                setState(() => isGiayVeSinhDone = !isGiayVeSinhDone);
              },
            ),

            const SizedBox(height: 24),

            // 4. Section: Ghi chú khác
            const Text("Ghi chú khác", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            const NoteCard(
              title: "Lịch sửa điện",
              author: "Thêm bởi Văn Dũng",
              icon: Icons.electric_bolt,
              isPinned: true,
            ),
            
            // Padding đáy để nội dung cuối không bị nút FAB hoặc BottomBar che mất
            const SizedBox(height: 80), 
          ],
        ),
      ),

      // --- NÚT THÊM MỚI (+) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Đã cập nhật: Chuyển sang màn hình thêm ghi chú mới
          Navigator.pushNamed(context, '/add_bulletin');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      // --- BOTTOM NAVIGATION BAR (5 items) ---
      bottomNavigationBar: BottomNavigationBar(
        // Quan trọng: Fixed để hiển thị đủ 5 icon và chữ không bị ẩn
        type: BottomNavigationBarType.fixed, 
        
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 3, // Index 3 là tab Bảng tin
        onTap: (index) {
          // Xử lý chuyển trang
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/expenses'); // Chuyển sang Quỹ chung
          }
          // if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          // if (index == 4) Navigator.pushNamed(context, '/profile'); 
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            label: "Trang chủ"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services_outlined), 
            label: "Việc nhà"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined), 
            label: "Quỹ chung"
          ),
          // Tab hiện tại (Bảng tin) dùng icon đậm (activeIcon)
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), 
            activeIcon: Icon(Icons.chat_bubble), 
            label: "Bảng tin"
          ),
          // Item Hồ sơ
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"
          ),
        ],
      ),
    );
  }
}
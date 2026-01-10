import 'package:flutter/material.dart';
import 'package:hs/core/widgets/housepal_bottom_nav.dart';
import 'package:hs/features/bulletin_board/presentation/widgets/shopping_item.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/bulletin_service.dart';
import '../../data/models/bulletin_note_model.dart';
import '../../data/models/shopping_item_model.dart';
import '../widgets/bulletin_filter_bar.dart'; 
import '../widgets/bulletin_note_card.dart';  
import 'add_bulletin_page.dart';
import 'shopping_detail_page.dart';

// ... (imports remain the same)

// ... (imports remain the same)

class BulletinBoardPage extends StatefulWidget {
  const BulletinBoardPage({super.key});

  @override
  State<BulletinBoardPage> createState() => _BulletinBoardPageState();
}

class _BulletinBoardPageState extends State<BulletinBoardPage> {
  final BulletinService _service = BulletinService();
  int _filterIndex = 0; // 0: Tất cả, 1: Ghi chú, 2: Mua sắm

  @override
  Widget build(BuildContext context) {
    // Dynamic Colors
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subHeaderColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: bgColor, // [FIX] Dynamic background
      appBar: AppBar(
        title: Text("Bảng tin", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)), // [FIX] Dynamic text
        backgroundColor: bgColor, // [FIX] Dynamic appBar
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // THANH LỌC (Filter Bar)
          BulletinFilterBar(
            selectedIndex: _filterIndex,
            onTabSelected: (index) => setState(() => _filterIndex = index),
            // You might need to update this widget internally too if it has hardcoded colors
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- SECTION GHI CHÚ ---
                  if (_filterIndex == 0 || _filterIndex == 1) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text("Ghi chú chung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: subHeaderColor)),
                    ),
                    StreamBuilder<List<BulletinNoteModel>>(
                      stream: _service.getNotesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyText("Chưa có ghi chú nào");
                        }
                        return Column(
                          children: snapshot.data!.map((note) => BulletinNoteCard(note: note)).toList(),
                        );
                      },
                    ),
                  ],

                  // --- SECTION MUA SẮM ---
                  if (_filterIndex == 0 || _filterIndex == 2) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text("Cần mua sắm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: subHeaderColor)),
                    ),
                    StreamBuilder<List<ShoppingItemModel>>(
                      stream: _service.getShoppingStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyText("Danh sách mua sắm trống");
                        }
                        
                        // Lấy dữ liệu và sắp xếp client-side (để chắc chắn về thứ tự hiển thị)
                        // Ưu tiên: Chưa mua > Gấp > Mới nhất
                        final items = snapshot.data!;
                        items.sort((a, b) {
                          if (a.isBought != b.isBought) return a.isBought ? 1 : -1; // Chưa mua lên trước
                          if (a.isUrgent != b.isUrgent) return b.isUrgent ? 1 : -1; // Gấp lên trước
                          return b.createdAt.compareTo(a.createdAt); // Mới nhất lên trước
                        });

                        return Column(
                          children: items.map((item) => ShoppingItemCard(
                            item: item,
                            onToggle: () => _service.toggleShoppingItem(item.id, item.isBought),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoppingDetailPage(item: item),
                                ),
                              );
                            },
                          )).toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 80), // Khoảng trống dưới cùng
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBulletinPage())),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 3),
    );
  }

  Widget _buildEmptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text(text, style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic))),
    );
  }
}
// [Update] UI spacing

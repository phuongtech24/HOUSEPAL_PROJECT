import 'package:flutter/material.dart';
import 'package:hs/core/widgets/housepal_bottom_nav.dart';
import 'package:hs/features/bulletin_board/presentation/widgets/shopping_item.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/bulletin_service.dart';
import '../../data/models/bulletin_note_model.dart';
import '../../data/models/shopping_item_model.dart';
import '../widgets/bulletin_filter_bar.dart'; // Import Widget tách
import '../widgets/bulletin_note_card.dart';  // Import Widget tách
import 'add_bulletin_page.dart';

class BulletinBoardPage extends StatefulWidget {
  const BulletinBoardPage({super.key});

  @override
  State<BulletinBoardPage> createState() => _BulletinBoardPageState();
}

class _BulletinBoardPageState extends State<BulletinBoardPage> {
  final BulletinService _service = BulletinService();
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Bảng tin", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // GỌI WIDGET FILTER
          BulletinFilterBar(
            selectedIndex: _filterIndex,
            onTabSelected: (index) => setState(() => _filterIndex = index),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION GHI CHÚ ---
                  if (_filterIndex == 0 || _filterIndex == 1) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Ghi chú chung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    StreamBuilder<List<BulletinNoteModel>>(
                      stream: _service.getNotesStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        // GỌI WIDGET NOTE CARD
                        return Column(
                          children: snapshot.data!.map((note) => BulletinNoteCard(note: note)).toList(),
                        );
                      },
                    ),
                  ],

                  // --- SECTION MUA SẮM ---
                  if (_filterIndex == 0 || _filterIndex == 2) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Cần mua sắm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    StreamBuilder<List<ShoppingItemModel>>(
                      stream: _service.getShoppingStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        // GỌI WIDGET SHOPPING CARD
                        return Column(
                          children: snapshot.data!.map((item) => ShoppingItemCard(
                            item: item,
                            onToggle: () => _service.toggleShoppingItem(item.id, item.isBought),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 80),
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
}
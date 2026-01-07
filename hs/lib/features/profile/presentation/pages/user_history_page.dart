import 'package:flutter/material.dart';
import 'package:hs/features/profile/data/datasources/history_service.dart';
import 'package:hs/features/profile/data/models/history_item_mode.dart';
import 'package:intl/intl.dart'; // Cần import intl để format ngày giờ
import '../../../../core/constants/app_colors.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HistoryService _service = HistoryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Lịch Sử Hoạt Động", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Tất cả"),
                Tab(text: "Tiền"),
                Tab(text: "Việc nhà"),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<HistoryItemModel>>(
        stream: _service.getUserHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có hoạt động nào", style: TextStyle(color: Colors.grey)));
          }

          final allItems = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(allItems), // Tất cả
              _buildList(allItems.where((e) => e.type == HistoryType.money).toList()), // Tiền
              _buildList(allItems.where((e) => e.type == HistoryType.chore).toList()), // Việc nhà
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<HistoryItemModel> items) {
    if (items.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        
        // Logic hiển thị Header Ngày (Hôm nay, Hôm qua...)
        bool showHeader = false;
        if (index == 0) {
          showHeader = true;
        } else {
          final prevDate = items[index - 1].createdAt;
          final currDate = item.createdAt;
          if (!_isSameDay(prevDate, currDate)) {
            showHeader = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  _formatDateHeader(item.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ),
            
            _buildHistoryItemCard(item),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItemCard(HistoryItemModel item) {
    // Format thời gian (VD: 14:30 hoặc 2 giờ trước)
    String timeString = DateFormat('HH:mm').format(item.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: item.bgColor, shape: BoxShape.circle),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(timeString, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            item.valueDisplay,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: item.isNegative ? Colors.black87 : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper check cùng ngày
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Helper format Header
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return "Hôm nay";
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return "Hôm qua";
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
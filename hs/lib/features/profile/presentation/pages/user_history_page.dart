import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
              indicatorSize: TabBarIndicatorSize.tab,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryList(),         // Tab Tất cả
          _buildHistoryList(filter: 'money'), // Tab Tiền
          _buildHistoryList(filter: 'chore'), // Tab Việc nhà
        ],
      ),
    );
  }

  Widget _buildHistoryList({String? filter}) {
    // Dữ liệu Mock giống ảnh mẫu (Sau này bạn có thể thay bằng StreamBuilder)
    final List<Map<String, dynamic>> allActivities = [
      {
        'type': 'money',
        'title': 'Thanh toán tiền điện',
        'time': '2 giờ trước',
        'value': '-500k',
        'isNegative': true,
        'icon': Icons.bolt,
        'bg': const Color(0xFFE0F9F4),
        'iconColor': AppColors.primary
      },
      {
        'type': 'chore',
        'title': 'Dọn dẹp phòng khách',
        'time': '4 giờ trước',
        'value': '+15 điểm',
        'isBadge': false,
        'icon': Icons.cleaning_services,
        'bg': const Color(0xFFE3F2FD),
        'iconColor': Colors.blue
      },
      {
        'type': 'badge',
        'title': 'Siêu chăm chỉ',
        'time': '5 giờ trước',
        'value': 'Huy hiệu',
        'isBadge': true,
        'icon': Icons.emoji_events,
        'bg': const Color(0xFFFFF3E0),
        'iconColor': Colors.orange
      },
      {
        'type': 'money',
        'title': 'Mua đồ tạp hóa chung',
        'time': '17:30 hôm qua',
        'value': '-250k',
        'isNegative': true,
        'icon': Icons.shopping_cart,
        'bg': const Color(0xFFF1F8E9),
        'iconColor': Colors.green
      },
      {
        'type': 'chore',
        'title': 'Đổ rác',
        'time': '08:15 hôm qua',
        'value': '+10 điểm',
        'isBadge': false,
        'icon': Icons.delete,
        'bg': const Color(0xFFE1F5FE),
        'iconColor': Colors.lightBlue
      },
    ];

    // Lọc dữ liệu theo Tab
    List<Map<String, dynamic>> items = [];
    if (filter == 'money') {
      items = allActivities.where((e) => e['type'] == 'money').toList();
    } else if (filter == 'chore') {
      items = allActivities.where((e) => e['type'] == 'chore' || e['type'] == 'badge').toList();
    } else {
      items = allActivities;
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        // Logic hiển thị Header "Hôm nay", "Hôm qua" (Giả lập đơn giản)
        bool showHeaderToday = (index == 0);
        bool showHeaderYesterday = (index == 3 && filter == null); 

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeaderToday) 
              const Padding(padding: EdgeInsets.only(bottom: 10), child: Text("Hôm nay", style: TextStyle(fontWeight: FontWeight.bold))),
            if (showHeaderYesterday) 
              const Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Text("Hôm qua", style: TextStyle(fontWeight: FontWeight.bold))),
            
            Container(
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
                    decoration: BoxDecoration(color: item['bg'], shape: BoxShape.circle),
                    child: Icon(item['icon'], color: item['iconColor'], size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(item['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (item['isBadge'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
                      child: Text(item['value'], style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  else
                    Text(
                      item['value'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15,
                        color: (item['isNegative'] == true) ? Colors.black87 : AppColors.primary
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
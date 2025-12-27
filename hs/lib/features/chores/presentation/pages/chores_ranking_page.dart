import 'package:flutter/material.dart';
import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

class ChoresRankingPage extends StatefulWidget {
  const ChoresRankingPage({super.key});

  @override
  State<ChoresRankingPage> createState() => _ChoresRankingPageState();
}

class _ChoresRankingPageState extends State<ChoresRankingPage> {
  int _selectedMonth = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedFilter(
              labels: const ['Tháng 11/2023', 'Tháng 10/2023', 'Tháng 9/2023'],
              selectedIndex: _selectedMonth,
              onSelected: (index) {
                setState(() {
                  _selectedMonth = index;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: kCardRadius,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF5C2), Color(0xFFFFE189)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      'lib/core/assets/avatars/meo3.jpg',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Văn Dũng (Bạn)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Thành viên Tích cực của Tháng',
                    style: TextStyle(fontSize: 13, color: kGreyText),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    child: const Text(
                      '1250 điểm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _RankingRow(order: 2, name: 'Nam Phương', points: 1100),
                SizedBox(height: 8),
                _RankingRow(order: 3, name: 'Minh Tuấn', points: 980),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 1),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.order,
    required this.name,
    required this.points,
  });

  final int order;
  final String name;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: kCardRadius,
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(
            '$order',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('lib/core/assets/avatars/meo3.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$points điểm',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

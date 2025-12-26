import 'package:flutter/material.dart';
import '../widgets/chore_widgets.dart';
import 'create_chore_page.dart';
import 'chores_ranking_page.dart';
import 'chore_detail_page.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

class ChoresPage extends StatefulWidget {
  const ChoresPage({super.key});

  @override
  State<ChoresPage> createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  int _selectedFilter = 1; 

  final Map<String, List<_ChoreUiModel>> _data = {
    'Thứ Hai, 28/11': [
      _ChoreUiModel(
        title: 'Hút bụi phòng khách',
        subtitle: 'Minh Tuấn • Đến hạn lúc 18:00 • +15 điểm',
      ),
      _ChoreUiModel(
        title: 'Rửa bát',
        subtitle: 'Nam Phương • Đến hạn lúc 18:00 • +10 điểm',
      ),
      _ChoreUiModel(
        title: 'Dọn nhà tắm',
        subtitle: 'Bạn • Hoàn thành • +30 điểm',
        done: true,
      ),
    ],
    'Thứ Ba, 29/11': [
      _ChoreUiModel(
        title: 'Lau nhà',
        subtitle: 'Nam Phương • Đến hạn lúc 18:00 • +10 điểm',
      ),
    ],
    'Thứ Tư, 30/11': [
      _ChoreUiModel(
        title: 'Đổ rác',
        subtitle: 'Minh Tuấn • Đến hạn lúc 09:00 • +5 điểm',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackground,
        centerTitle: true,
        title: const Text(
          'Lịch việc nhà',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: LeaderboardCard(
              onTapViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChoresRankingPage(),
                  ),
                );
              },
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedFilter(
              labels: const ['Hôm nay', 'Tuần này', 'Tháng này'],
              selectedIndex: _selectedFilter,
              onSelected: (index) {
                setState(() => _selectedFilter = index);
              },
            ),
          ),

          const SizedBox(height: 16),


          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              itemCount: _data.keys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final dayLabel = _data.keys.elementAt(index);
                final chores = _data[dayLabel]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Column(
                      children: List.generate(chores.length, (i) {
                        final item = chores[i];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i == chores.length - 1 ? 0 : 10,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ChoreDetailPage(),
                                ),
                              );
                            },
                            child: _ChoreRow(
                              item: item,
                              onToggle: () {
                                setState(() {
                                  item.done = !item.done;
                                });
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateChorePage(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),

      bottomNavigationBar: const HousePalBottomNav(currentIndex: 1),
    );
  }
}


class _ChoreRow extends StatelessWidget {
  const _ChoreRow({
    required this.item,
    required this.onToggle,
  });

  final _ChoreUiModel item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.done ? const Color(0xFFEFF5F1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// CHECKBOX
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.done ? kPrimaryGreen : Colors.grey,
                  width: 2,
                ),
                color: item.done ? kPrimaryGreen : Colors.transparent,
              ),
              child: item.done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration:
                        item.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kGreyText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}


class _ChoreUiModel {
  _ChoreUiModel({
    required this.title,
    required this.subtitle,
    this.done = false,
  });

  final String title;
  final String subtitle;
  bool done;
}

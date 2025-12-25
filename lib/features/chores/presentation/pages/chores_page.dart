import 'package:flutter/material.dart';
import '../widgets/chore_widgets.dart';
import 'create_chore_page.dart';
import 'chores_ranking_page.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

class ChoresPage extends StatefulWidget {
  const ChoresPage({super.key});

  @override
  State<ChoresPage> createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  int _selectedFilter = 0;

  final Map<String, List<_ChoreUiModel>> _data = {
    'Thứ Hai, 28/11': [
      _ChoreUiModel(
        title: 'Rửa bát',
        deadline: 'Đến hạn lúc 20:00',
        pointsLabel: '+10 điểm',
      ),
      _ChoreUiModel(
        title: 'Hút bụi phòng khách',
        deadline: 'Đến hạn lúc 18:00',
        pointsLabel: '+15 điểm',
      ),
      _ChoreUiModel(
        title: 'Dọn nhà tắm',
        deadline: 'Đến hạn lúc 18:00',
        pointsLabel: '+30 điểm',
      ),
    ],
    'Thứ Ba, 29/11': [
      _ChoreUiModel(
        title: 'Lau nhà',
        deadline: 'Hoàn thành',
        pointsLabel: '+20 điểm',
        done: true,
      ),
    ],
    'Thứ Tư, 30/11': [
      _ChoreUiModel(
        title: 'Đổ rác',
        deadline: 'Đến hạn lúc 09:00',
        pointsLabel: '+5 điểm',
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leadingWidth: 56,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 4,
              bottom: 12,
            ),
            child: LeaderboardCard(
              onTapViewAll: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChoresRankingPage()),
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
                setState(() {
                  _selectedFilter = index;
                });
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
                final String dayLabel = _data.keys.elementAt(index);
                final List<_ChoreUiModel> chores = _data[dayLabel]!;
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
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(chores.length, (i) {
                        final _ChoreUiModel item = chores[i];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i == chores.length - 1 ? 0 : 10,
                          ),
                          child: ChoreListItem(
                            title: item.title,
                            deadlineText: item.deadline,
                            pointsText: item.pointsLabel,
                            done: item.done,
                            onToggle: () {
                              setState(() {
                                item.done = !item.done;
                              });
                            },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryGreen,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateChorePage()));
        },
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 1),
    );
  }
}

class _ChoreUiModel {
  _ChoreUiModel({
    required this.title,
    required this.deadline,
    required this.pointsLabel,
    this.done = false,
  });

  final String title;
  final String deadline;
  final String pointsLabel;
  bool done;
}

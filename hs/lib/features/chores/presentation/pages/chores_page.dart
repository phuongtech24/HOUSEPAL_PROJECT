import 'package:flutter/material.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';
import 'package:hs/features/chores/presentation/widgets/LeaderboardCard.dart';
import '../../data/datasources/chore_service.dart';
import '../../data/models/chore_model.dart';

import '../widgets/chore_widgets.dart' hide LeaderboardCard;

import 'create_chore_page.dart';
import 'chores_ranking_page.dart';
import 'chore_detail_page.dart';

import '../../../../core/widgets/housepal_bottom_nav.dart';


import '../../../../core/constants/app_colors.dart';



class ChoresPage extends StatefulWidget {
  const ChoresPage({super.key});

  @override
  State<ChoresPage> createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  final ChoreService _choreService = ChoreService();
  int _selectedFilter = 1;

  @override
  Widget build(BuildContext context) {

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        centerTitle: true,
        title: Text(
          'Lịch việc nhà',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor),
        ),
        actions: [
          Icon(Icons.calendar_today_outlined, color: titleColor),
        ],
      ),

      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: StreamBuilder<List<UserModel>>(
              stream: _choreService.getHouseMembersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 120);
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(height: 120);
                }

                
                final List<UserModel> rankedUsers =
                    List<UserModel>.from(snapshot.data!)
                      ..sort(
                        (a, b) =>
                            b.currentPoints.compareTo(a.currentPoints),
                      );

                return LeaderboardCard(
                  users: rankedUsers.take(3).toList(), 
                  onTapViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChoresRankingPage(),
                      ),
                    );
                  },
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
            child: StreamBuilder<List<ChoreModel>>(
              stream: _choreService.getChoresStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Không thể tải việc nhà.',
                      style: TextStyle(color: titleColor),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có việc nhà nào.',
                      style: TextStyle(color: titleColor),
                    ),
                  );
                }


                final allChores = snapshot.data!;
                final now = DateTime.now();
                
                final filteredChores = allChores.where((chore) {
                  final date = chore.startDate; 
                  
                   if (_selectedFilter == 0) {
                    return date.year == now.year && date.month == now.month && date.day == now.day;
                  } else if (_selectedFilter == 1) {
                     final diff = date.difference(now).inDays;
                     return diff.abs() <= 7;
                  } else {
                    return date.month == now.month && date.year == now.year;
                  }
                }).toList();

                 if (filteredChores.isEmpty) {
                   return Center(
                    child: Text(
                      'Không có việc trong khoảng thời gian này.',
                       style: TextStyle(color: titleColor),
                    ),
                  );
                 }


                filteredChores.sort((a, b) => a.startDate.compareTo(b.startDate));


                final List<Widget> listItems = [];
                DateTime? lastDate;

                for (var chore in filteredChores) {
                  final date = chore.startDate;
                  final dateKey = DateTime(date.year, date.month, date.day);

                  if (lastDate == null || lastDate != dateKey) {
                    listItems.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          '${_getDayName(date.weekday)}, ${date.day}/${date.month}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                    );
                  }

                   listItems.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChoreDetailPage(chore: chore),
                            ),
                          );
                        },
                        child: _ChoreRow(
                          chore: chore,
                          done: chore.status == 'completed',
                          onToggle: chore.status == 'completed'
                              ? null
                              : () async {
                                  await _choreService.completeChore(chore);
                                },
                        ),
                      ),
                    ),
                  );
                }
                

                listItems.add(const SizedBox(height: 90));

                return ListView(
                  children: listItems,
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateChorePage(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),

      bottomNavigationBar:
          const HousePalBottomNav(currentIndex: 1),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Thứ Hai';
      case 2: return 'Thứ Ba';
      case 3: return 'Thứ Tư';
      case 4: return 'Thứ Năm';
      case 5: return 'Thứ Sáu';
      case 6: return 'Thứ Bảy';
      case 7: return 'Chủ Nhật';
      default: return '';
    }
  }
}



class _ChoreRow extends StatelessWidget {
  const _ChoreRow({
    required this.chore,
    required this.done,
    required this.onToggle,
  });

  final ChoreModel chore;
  final bool done;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    final bgColor = done 
        ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1B5E20) : const Color(0xFFEFF5F1)) 
        : cardColor;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
                color: done ? AppColors.primary : Colors.transparent,
              ),
              child: done
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chore.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chore.currentGroupId} • +${chore.points} điểm',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
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

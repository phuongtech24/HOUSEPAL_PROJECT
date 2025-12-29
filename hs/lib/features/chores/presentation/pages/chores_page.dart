import 'package:flutter/material.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';

import '../../data/datasources/chore_service.dart';
import '../../data/models/chore_model.dart';

import '../widgets/chore_widgets.dart';
import '../widgets/LeaderboardCard.dart';

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
  final ChoreService _choreService = ChoreService();
  int _selectedFilter = 1;

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
        actions: const [
          Icon(Icons.calendar_today_outlined),
        ],
      ),

      body: Column(
        children: [
          /// ================= LEADERBOARD (DATA THỰC – FIX HOÀN CHỈNH) =================
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

                // ✅ CLONE LIST + SORT (KHÔNG ĐÈ SNAPSHOT)
                final List<UserModel> rankedUsers =
                    List<UserModel>.from(snapshot.data!)
                      ..sort(
                        (a, b) =>
                            b.currentPoints.compareTo(a.currentPoints),
                      );

                return LeaderboardCard(
                  users: rankedUsers.take(3).toList(), // 
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

          /// ================= FILTER (GIỮ NGUYÊN) =================
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

          /// ================= CHORES LIST (GIỮ NGUYÊN) =================
          Expanded(
            child: StreamBuilder<List<ChoreModel>>(
              stream: _choreService.getChoresStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Không thể tải việc nhà.\nVui lòng kiểm tra House / Firebase.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có việc nhà nào.\nHãy tạo việc đầu tiên!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final chores = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: chores.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final chore = chores[index];
                    final bool done =
                        chore.status == 'completed';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChoreDetailPage(chore: chore),
                          ),
                        );
                      },
                      child: _ChoreRow(
                        chore: chore,
                        done: done,
                        onToggle: done
                            ? null
                            : () async {
                                await _choreService
                                    .completeChore(chore);
                              },
                      ),
                    );
                  },
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

      bottomNavigationBar:
          const HousePalBottomNav(currentIndex: 1),
    );
  }
}

/// ================= ROW (GIỮ NGUYÊN) =================

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFEFF5F1) : Colors.white,
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
                  color: done ? kPrimaryGreen : Colors.grey,
                  width: 2,
                ),
                color: done ? kPrimaryGreen : Colors.transparent,
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
                    decoration:
                        done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chore.currentGroupId} • +${chore.points} điểm',
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

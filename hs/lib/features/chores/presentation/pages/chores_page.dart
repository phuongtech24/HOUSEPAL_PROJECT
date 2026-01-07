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

// ... (imports remain the same)
//[FIX] Remove imports if not used or replace
import '../../../../core/constants/app_colors.dart';

// [FIX] Define or import kPrimaryGreen/kBackground if missing, or use AppColors
// Assuming they existed in a separate constants file that isn't shown, I will replace them with dynamic colors.

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
    // Dynamic Colors
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    return Scaffold(
      backgroundColor: bgColor, // [FIX] Dynamic background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor, // [FIX] Dynamic appBar bg
        centerTitle: true,
        title: Text(
          'Lịch việc nhà',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor), // [FIX] Dynamic text color
        ),
        actions: [
          Icon(Icons.calendar_today_outlined, color: titleColor),
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
                  return Center(
                    child: Text(
                      'Không thể tải việc nhà.\nVui lòng kiểm tra House / Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: titleColor),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có việc nhà nào.\nHãy tạo việc đầu tiên!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: titleColor),
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
        backgroundColor: AppColors.primary, // [FIX] Use AppColors
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
    // Dynamic colors for Row
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
     // If done, use a light green background, else use card color
    final bgColor = done 
        ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1B5E20) : const Color(0xFFEFF5F1)) 
        : cardColor;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor, // [FIX] Dynamic item bg
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
                    color: textColor, // [FIX] Dynamic text
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chore.currentGroupId} • +${chore.points} điểm',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, // [FIX] Dynamic subtext
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

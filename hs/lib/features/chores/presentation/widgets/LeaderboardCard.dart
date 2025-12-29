import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../authentication/data/models/user_model.dart';

class LeaderboardCard extends StatelessWidget {
  final List<UserModel> users;
  final VoidCallback onTapViewAll;

  const LeaderboardCard({
    super.key,
    required this.users,
    required this.onTapViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox(height: 120);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bảng xếp hạng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onTapViewAll,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ================= TOP USERS =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              users.length,
              (index) => _TopUserItem(
                user: users[index],
                rank: index + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= ITEM ================= */

class _TopUserItem extends StatelessWidget {
  final UserModel user;
  final int rank;

  const _TopUserItem({
    required this.user,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isTop = rank == 1;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: isTop ? 26 : 22,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? AssetImage(user.avatarUrl)
                  : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
            ),
            CircleAvatar(
              radius: 9,
              backgroundColor:
                  isTop ? AppColors.primary : Colors.grey.shade400,
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user.name,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isTop
                ? AppColors.primary.withOpacity(0.15)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${user.currentPoints}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isTop ? AppColors.primary : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

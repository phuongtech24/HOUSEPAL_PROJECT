import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../authentication/data/models/user_model.dart';
import 'package:hs/features/chores/presentation/widgets/chore_widgets.dart' show kPrimaryGreen;

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

    // Ensure we have up to 3 users for the podium
    // Users are assumed to be sorted by rank (1, 2, 3...)
    final u1 = users.isNotEmpty ? users[0] : null;
    final u2 = users.length > 1 ? users[1] : null;
    final u3 = users.length > 2 ? users[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ]
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
                child: Row(
                  children: const [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryGreen,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: kPrimaryGreen),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// ================= PODIUM =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // RANK 2 (Left)
              if (u2 != null)
                _PodiumItem(
                  user: u2, 
                  rank: 2, 
                  color: const Color(0xFFC6F4D6), // Light Green
                  height: 70,
                  textColor: const Color(0xFF1B5E20),
                )
              else 
                const SizedBox(width: 80),

              // RANK 1 (Center)
              if (u1 != null)
                _PodiumItem(
                  user: u1, 
                  rank: 1, 
                  color: const Color(0xFF00E676), // Vibrant Green
                  height: 100,
                  isWinner: true,
                  textColor: Colors.black, // Figma shows black text on green
                )
               else 
                const SizedBox(width: 80),

              // RANK 3 (Right)
              if (u3 != null)
                _PodiumItem(
                  user: u3, 
                  rank: 3, 
                  color: const Color(0xFFC6F4D6), // Light Green
                  height: 50,
                  textColor: const Color(0xFF1B5E20),
                )
               else 
                const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final UserModel user;
  final int rank;
  final double height;
  final Color color;
  final Color textColor;
  final bool isWinner;

  const _PodiumItem({
    required this.user,
    required this.rank,
    required this.height,
    required this.color,
    required this.textColor,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    // Badges: 1 (Gold/Yellow), 2 & 3 (Brownish/Grey in mock, but keeping uniform circular based on image)
    // Figma Image 0: Rank 1 is yellow circle "1", Rank 2 is grey/white circle "1" (typo in mock?), Rank 3 is orange "1"
    // We will stick to standard: 1=Gold, 2=Silver/Grey, 3=Bronze/Orange.
    
    Color badgeColor;
    if (rank == 1) badgeColor = const Color(0xFFFFD700);
    else if (rank == 2) badgeColor = Colors.grey;
    else badgeColor = const Color(0xFFCD7F32); 

    // Override based on visual observation: 
    // Rank 1 has yellow outline and yellow badge.
    // Rank 2 & 3 have simpler grey badges in many apps, but here image shows colors.
    // Let's use simple circles.

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // AVATAR WITH BADGE
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isWinner ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
              ),
              child: CircleAvatar(
                radius: isWinner ? 28 : 22,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? AssetImage(user.avatarUrl)
                    : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
              ),
            ),
            Positioned(
              bottom: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // NAME
        SizedBox(
          width: 80,
          child: Text(
            user.name.split(' ').last, // Show last name for compactness
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),

        // BAR
        Container(
          width: isWinner ? 70 : 60,
          height: height,
          decoration: BoxDecoration(
            color: color, // Dynamic color
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${user.currentPoints}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

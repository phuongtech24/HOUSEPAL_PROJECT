import 'package:flutter/material.dart';

const Color kPrimaryGreen = Color(0xFF00D26A);
const Color kBackground = Color(0xFFF5F7FB);
const Color kCardBackground = Colors.white;
const Color kGreyText = Color(0xFF8E8E93);
const BorderRadius kCardRadius = BorderRadius.all(Radius.circular(16));

// ... (imports remain the same) 

class SegmentedFilter extends StatelessWidget {
  const SegmentedFilter({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final activeBg = Theme.of(context).cardTheme.color ?? kCardBackground;
    final inactiveBg = Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFFE7F1E9);
    final activeText = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: inactiveBg, // [FIX] Dynamic background
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool active = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? activeBg : Colors.transparent, // [FIX] Dynamic active bg
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? activeText : kGreyText, // [FIX] Dynamic text
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key, required this.onTapViewAll});

  final VoidCallback onTapViewAll;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? kCardBackground;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: cardColor, // [FIX] Dynamic
        borderRadius: kCardRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bảng xếp hạng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor), // [FIX] Dynamic
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _LeaderboardItem(
                name: 'Nam Phương',
                points: 120,
                rank: 2,
                avatarColor: Colors.grey,
              ),
              _LeaderboardItem(
                name: 'Văn Dũng',
                points: 180,
                rank: 1,
                avatarColor: kPrimaryGreen,
                highlight: true,
              ),
              _LeaderboardItem(
                name: 'Minh Tuấn',
                points: 95,
                rank: 3,
                avatarColor: Colors.brown,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  const _LeaderboardItem({
    required this.name,
    required this.points,
    required this.rank,
    required this.avatarColor,
    this.highlight = false,
  });

  final String name;
  final int points;
  final int rank;
  final Color avatarColor;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = highlight
        ? kPrimaryGreen
        : const Color(0xFFDDDDDD);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarColor,
              backgroundImage: const AssetImage(
                'lib/core/assets/avatars/meo3.jpg', // thay bằng ảnh thật
              ),
              onBackgroundImageError: (_, __) {},
            ),
            Positioned(
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: highlight
                ? const Color(0xFFE5F8ED)
                : const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$points',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlight ? kPrimaryGreen : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class ChoreListItem extends StatelessWidget {
  const ChoreListItem({
    super.key,
    required this.title,
    required this.deadlineText,
    required this.pointsText,
    required this.done,
    required this.onToggle,
    this.avatarImage,
  });

  final String title;
  final String deadlineText;
  final String pointsText;
  final bool done;
  final VoidCallback onToggle;
  final ImageProvider? avatarImage;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = done ? const Color(0xFFEFF5F1) : kCardBackground;
    final Color borderColor = done ? kPrimaryGreen : const Color(0xFFE3E5EA);
    final Color textColor = done ? kGreyText : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: kCardRadius,
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE3E5EA),
            backgroundImage:
                avatarImage ??
                const AssetImage('lib/core/assets/avatars/meo3.jpg'),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    decoration: done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done
                      ? 'Hoàn thành  $pointsText'
                      : '$deadlineText  $pointsText',
                  style: const TextStyle(fontSize: 13, color: kGreyText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? kPrimaryGreen : const Color(0xFFD0D3DB),
                  width: 2,
                ),
                color: done ? kPrimaryGreen : Colors.transparent,
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

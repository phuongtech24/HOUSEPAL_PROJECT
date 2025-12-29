import 'package:flutter/material.dart';

const Color kPrimaryGreen = Color(0xFF00D26A);
const Color kBackground = Color(0xFFF5F7FB);
const Color kCardBackground = Colors.white;
const Color kGreyText = Color(0xFF8E8E93);
const BorderRadius kCardRadius = BorderRadius.all(Radius.circular(16));

/// ================= SEGMENTED FILTER =================

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
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1E9),
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
                  color: active ? kCardBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.black : kGreyText,
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

/// ================= CHORE LIST ITEM =================

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
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done
                      ? 'Hoàn thành  $pointsText'
                      : '$deadlineText  $pointsText',
                  style: const TextStyle(
                    fontSize: 13,
                    color: kGreyText,
                  ),
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

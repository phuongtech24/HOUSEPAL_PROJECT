import 'package:flutter/material.dart';
import '../../data/models/chore_model.dart';
import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

class ChoreDetailPage extends StatelessWidget {
  final ChoreModel chore;

  const ChoreDetailPage({
    super.key,
    required this.chore,
  });

  @override
  Widget build(BuildContext context) {
    final bool done = chore.status == 'completed';

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chi tiết việc nhà',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          _HeaderCard(chore: chore),
          const SizedBox(height: 16),
          _RotationSection(chore: chore),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.star_border,
            title: 'Điểm thưởng',
            value: '+${chore.points} điểm',
          ),
        ],
      ),

      bottomNavigationBar: const HousePalBottomNav(
        currentIndex: 1,
        isSubPage: true,
      ),
    );
  }
}

/* ================= HEADER ================= */

class _HeaderCard extends StatelessWidget {
  final ChoreModel chore;

  const _HeaderCard({required this.chore});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: kCardRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  color: kPrimaryGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chore.status == 'completed'
                      ? const Color(0xFFE5F8ED)
                      : const Color(0xFFFFF1E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chore.status == 'completed'
                      ? 'Đã hoàn thành'
                      : 'Chưa hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    color: chore.status == 'completed'
                        ? kPrimaryGreen
                        : Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            chore.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F8ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${chore.points} điểm',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kPrimaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= ROTATION ================= */

class _RotationSection extends StatelessWidget {
  final ChoreModel chore;

  const _RotationSection({required this.chore});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: kCardRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhóm được phân công',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Nhóm hiện tại: ${chore.currentGroupId}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Thứ tự xoay vòng: ${chore.groupOrder.join(' → ')}',
            style: const TextStyle(fontSize: 13, color: kGreyText),
          ),
        ],
      ),
    );
  }
}

/* ================= INFO ================= */

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: kCardRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kGreyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

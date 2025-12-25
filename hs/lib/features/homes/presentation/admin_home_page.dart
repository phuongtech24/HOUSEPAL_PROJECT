import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

const Color _greyText = Color(0xFF8B8E98);
const double _cardRadius = 18;

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            /// ✅ TỔNG QUAN CỦA BẠN (BỊ THIẾU TRƯỚC ĐÓ)
            const Text(
              'Tổng quan của bạn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildSummaryCards(),

            const SizedBox(height: 20),
            _buildTodayTasks(),

            const SizedBox(height: 20),
            _buildMembersOverview(),

            const SizedBox(height: 20),
            _buildFinanceOverview(),

            const SizedBox(height: 20),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  /* ================= HEADER ================= */

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFE3E5EA),
          child: Icon(Icons.person, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Xin chào, Admin 👋',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE3E5EA)),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.notifications_none, size: 22),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  /* ================= SUMMARY ================= */

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.star_border,
            value: '250',
            label: 'Điểm tháng này',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.arrow_downward,
            value: '50.000đ',
            label: 'Bạn đang nợ',
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: _greyText)),
        ],
      ),
    );
  }

  /* ================= TODAY TASKS ================= */

  Widget _buildTodayTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Việc của bạn hôm nay'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _taskRow('Lau dọn phòng khách', false),
              const SizedBox(height: 10),
              _taskRow('Mua đồ dùng sinh hoạt', false),
              const SizedBox(height: 10),
              _taskRow('Đổ rác', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taskRow(String title, bool done) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.primary : const Color(0xFFB8BBC3),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              decoration:
                  done ? TextDecoration.lineThrough : TextDecoration.none,
              color: done ? _greyText : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  /* ================= MEMBERS ================= */

  Widget _buildMembersOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Tổng quan thành viên'),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _MemberCard(
                  name: 'Văn Dũng', points: '230 điểm', debt: 'Nợ 15k'),
              SizedBox(width: 12),
              _MemberCard(
                  name: 'Nam Phương', points: '210 điểm', debt: 'Nợ bạn 35k'),
              SizedBox(width: 12),
              _MemberCard(
                  name: 'Minh Tuấn',
                  points: '280 điểm',
                  debt: 'Nợ Nam Phương'),
            ],
          ),
        ),
      ],
    );
  }

  /* ================= FINANCE ================= */

  Widget _buildFinanceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Tổng quan tài chính', trailing: 'Xem tất cả'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _financeCol('Bạn nợ', '50.000đ', Colors.red),
              Container(width: 1, height: 40, color: const Color(0xFFE3E5EA)),
              _financeCol(
                  'Nợ bạn', '120.000đ', AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _financeCol(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _greyText)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  /* ================= ACTIVITY ================= */

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Hoạt động gần đây'),
        const SizedBox(height: 12),
        _activityItem(
          'Nam Phương đã hoàn thành việc Lau dọn bếp.',
          '5 phút trước',
        ),
        const SizedBox(height: 12),
        _activityItem(
          'Minh Tuấn đã thêm một khoản chi 150.000đ cho tiền điện.',
          '',
        ),
      ],
    );
  }

  Widget _activityItem(String title, String time) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F8ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                if (time.isNotEmpty)
                  Text(time,
                      style:
                          const TextStyle(fontSize: 12, color: _greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {String? trailing}) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (trailing != null)
          Text(trailing,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/* ================= MEMBER CARD ================= */

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.name,
    required this.points,
    required this.debt,
  });

  final String name;
  final String points;
  final String debt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const CircleAvatar(radius: 24),
          const SizedBox(height: 8),
          Text(name,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(points, style: const TextStyle(fontSize: 12, color: _greyText)),
          Text(debt, style: const TextStyle(fontSize: 12, color: _greyText)),
        ],
      ),
    );
  }
}

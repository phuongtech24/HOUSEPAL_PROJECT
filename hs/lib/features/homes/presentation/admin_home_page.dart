import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

const Color _greyText = Color(0xFF8B8E98);
const double _cardRadius = 16;

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            const Text(
              'Tổng quan của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildSummaryCards(),
            const SizedBox(height: 16),
            _buildTodayChores(),
            const SizedBox(height: 16),
            _buildMembersOverview(),
            const SizedBox(height: 16),
            _buildFinanceOverview(),
            const SizedBox(height: 16),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.black12,
          child: Icon(Icons.person, size: 28, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, Admin 👋',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'Chào mừng bạn đến với HousePal',
                style: TextStyle(fontSize: 13, color: _greyText),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE3E5EA)),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_outlined,
                  size: 22,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
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
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: const Color(0xFFE3E5EA)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.star_border,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  '250',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Điểm tháng này',
                  style: TextStyle(fontSize: 13, color: _greyText),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: const Color(0xFFE3E5EA)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  '50.000đ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Bạn đang nợ',
                  style: TextStyle(fontSize: 13, color: _greyText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: const [
                Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTodayChores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Việc của bạn hôm nay', onViewAll: () {}),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildSimpleTaskRow('Lau dọn phòng khách', false),
              const SizedBox(height: 8),
              _buildSimpleTaskRow('Mua đồ dùng sinh hoạt', false),
              const SizedBox(height: 8),
              _buildSimpleTaskRow('Đổ rác', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTaskRow(String title, bool done) {
    return Row(
      children: [
        Icon(
          done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 20,
          color: done ? AppColors.primary : const Color(0xFFB8BBC3),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration:
                  done ? TextDecoration.lineThrough : TextDecoration.none,
              color: done ? _greyText : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng quan thành viên',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 152,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _MemberCard(
                name: 'Văn Dũng',
                points: '230 điểm',
                debtText: 'Nợ 15k',
              ),
              SizedBox(width: 12),
              _MemberCard(
                name: 'Nam Phương',
                points: '210 điểm',
                debtText: 'Nợ bạn 35k',
              ),
              SizedBox(width: 12),
              _MemberCard(
                name: 'Minh Tuấn',
                points: '280 điểm',
                debtText: 'Nợ Nam Phương',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tổng quan tài chính', onViewAll: () {}),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bạn nợ',
                      style: TextStyle(fontSize: 13, color: _greyText),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '50.000đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE3E5EA)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nợ bạn',
                      style: TextStyle(fontSize: 13, color: _greyText),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '120.000đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: const [
              _ActivityItem(
                title: 'Nam Phương đã hoàn thành việc Lau dọn bếp',
                subtitle: '5 phút trước',
              ),
              Divider(height: 18),
              _ActivityItem(
                title: 'Minh Tuấn đã thêm một khoản chi 150.000đ cho tiền điện.',
                subtitle: 'Vừa xong',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.name,
    required this.points,
    required this.debtText,
  });

  final String name;
  final String points;
  final String debtText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 22),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            points,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _greyText),
          ),
          const SizedBox(height: 2),
          Text(
            debtText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _greyText),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: _greyText),
        ),
      ],
    );
  }
}

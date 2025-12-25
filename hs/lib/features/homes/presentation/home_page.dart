import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

const Color _greyText = Color(0xFF8B8E98);
const double _cardRadius = 16;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            _buildFinanceOverview(),
            const SizedBox(height: 16),
            _buildRecentNews(),
            const SizedBox(height: 20),
            _buildMonthlyStarButton(),
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
                'Xin chào! 👋',
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
          child: const Icon(
            Icons.notifications_none_outlined,
            size: 22,
            color: Colors.black87,
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
                  Icons.event_available_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  '3',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Việc hôm nay',
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
                Icon(Icons.star_border, color: AppColors.primary, size: 24),
                SizedBox(height: 8),
                Text(
                  '150',
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
              decoration: done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: done ? _greyText : Colors.black,
            ),
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

  Widget _buildRecentNews() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('Hoạt động gần đây', onViewAll: () {}),
      const SizedBox(height: 12),
      _ActivityItem(
        title: 'Nam Phương',
        action: 'đã hoàn thành việc Lau dọn bếp.',
        time: '5 phút trước',
      ),
      const SizedBox(height: 12),
      _ActivityItem(
        title: 'Minh Tuấn',
        action: 'đã thêm một khoản chi 150.000đ cho tiền điện.',
        time: '',
      ),
    ],
  );
}

  Widget _buildMonthlyStarButton() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        onPressed: () {},
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 20),
            SizedBox(width: 8),
            Text('Người xuất sắc tháng này'),
          ],
        ),
      ),
    );
  }
}

class _NewsItem extends StatelessWidget {
  const _NewsItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: _greyText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.title,
    required this.action,
    required this.time,
  });

  final String title;
  final String action;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON TRẠNG THÁI
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBF2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' $action'),
                    ],
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _greyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

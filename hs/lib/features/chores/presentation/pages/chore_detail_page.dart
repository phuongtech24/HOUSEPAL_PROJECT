import 'package:flutter/material.dart';
import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

class ChoreDetailPage extends StatelessWidget {
  const ChoreDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: const [
          _HeaderCard(),
          SizedBox(height: 16),
          _RotationSection(),
          SizedBox(height: 16),
          _InfoCard(
            icon: Icons.schedule,
            title: 'Thời gian đề xuất',
            value: '09:00 - 18:00',
          ),
          SizedBox(height: 12),
          _InfoCard(
            icon: Icons.calendar_today,
            title: 'Hạn chót & Tần suất',
            value: '28 Thg 11, 2025\nLặp lại: Hàng tháng',
          ),
          SizedBox(height: 12),
          _InfoCard(
            icon: Icons.description,
            title: 'Mô tả',
            value: 'Dọn các kệ sau bữa trưa, sử dụng chất tẩy rửa chuyên dụng.',
          ),
        ],
      ),
      bottomNavigationBar: const HousePalBottomNav(
        currentIndex: 1,
        isSubPage: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const _ReminderButton(),
    );
  }
}


class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

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
                  color: const Color(0xFFFFF1E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đến hạn hôm nay',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Dọn tủ lạnh',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F8ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '+20 Điểm',
              style: TextStyle(
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


class _RotationSection extends StatelessWidget {
  const _RotationSection();

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
            children: const [
              Text(
                'Chu kỳ xoay vòng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Spacer(),
              Text(
                'Xem lịch sử',
                style: TextStyle(
                  fontSize: 13,
                  color: kPrimaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _MemberAvatar(name: 'Huy'),
              Icon(Icons.arrow_forward_ios, size: 14),
              _MemberAvatar(
                name: 'Nam Phương',
                highlight: true,
                subtitle: 'Lượt hiện tại\nChưa hoàn thành',
              ),
              Icon(Icons.arrow_forward_ios, size: 14),
              _MemberAvatar(name: 'Tuấn', subtitle: 'Tiếp theo'),
            ],
          ),
        ],
      ),
    );
  }
}


class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.name,
    this.subtitle,
    this.highlight = false,
  });

  final String name;
  final String? subtitle;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: highlight ? 28 : 22,
          backgroundColor:
              highlight ? kPrimaryGreen : const Color(0xFFE3E5EA),
          child: CircleAvatar(
            radius: highlight ? 24 : 20,
            backgroundImage:
                const AssetImage('assets/images/sample_avatar.png'),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: highlight ? Colors.orange : kGreyText,
              fontWeight:
                  highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }
}


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


class _ReminderButton extends StatelessWidget {
  const _ReminderButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: MediaQuery.of(context).size.width - 32,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {},
        icon: const Icon(
          Icons.notifications_active_outlined,
          color: Colors.black,
        ),
        label: const Text(
          'Nhắc Nam Phương',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

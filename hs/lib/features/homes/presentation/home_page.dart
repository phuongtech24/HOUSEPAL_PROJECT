import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../data/datasources/home_service.dart';
import '../data/models/home_model.dart';
import '../../chores/presentation/pages/chores_ranking_page.dart';


const Color _greyText = Color(0xFF8B8E98);
const double _cardRadius = 16;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeService = HomeService();

  HomeSummaryModel? _summary;
  List<HomeActivityModel> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _homeService.getHomeSummary();
    final activities = await _homeService.getRecentActivities();

    if (!mounted) return;
    setState(() {
      _summary = summary;
      _activities = activities;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            _buildMonthlyStarButton(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

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
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () =>
              Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  // ================= SUMMARY =================

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.event_available_outlined,
            value: _summary!.todayChores.toString(),
            label: 'Việc hôm nay',
            onTap: () => Navigator.pushNamed(context, '/chores'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.star_border,
            value: _summary!.monthPoints.toString(),
            label: 'Điểm tháng này',
            onTap: () => Navigator.pushNamed(context, '/chores-ranking'),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(_cardRadius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: const Color(0xFFE3E5EA)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: _greyText),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TODAY CHORES =================

  Widget _buildTodayChores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Việc của bạn hôm nay',
          onViewAll: () => Navigator.pushNamed(context, '/chores'),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Bạn có ${_summary!.todayChores} việc đang chờ',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ================= FINANCE =================

  Widget _buildFinanceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Tổng quan tài chính',
          onViewAll: () => Navigator.pushNamed(context, '/expenses'),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              _financeCol('Bạn nợ', _summary!.debt, Colors.red),
              Container(width: 1, height: 40, color: const Color(0xFFE3E5EA)),
              const SizedBox(width: 16),
              _financeCol(
                'Nợ bạn',
                _summary!.credit,
                AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _financeCol(String label, int value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: _greyText)),
          const SizedBox(height: 6),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                .format(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIVITY =================

  Widget _buildRecentNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Hoạt động gần đây',
          onViewAll: () =>
              Navigator.pushNamed(context, '/notifications'),
        ),
        const SizedBox(height: 12),
        ..._activities.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityItem(
              title: e.title,
              action: e.subtitle,
              time: DateFormat('dd/MM HH:mm').format(e.createdAt),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStarButton(BuildContext context) {
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
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChoresRankingPage(),
            ),
          );
        },
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
                Icon(Icons.chevron_right,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

// ================= ACTIVITY ITEM =================

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
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE9FBF2),
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
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700),
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
                        fontSize: 12, color: _greyText),
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

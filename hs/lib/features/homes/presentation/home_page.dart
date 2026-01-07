import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../data/datasources/home_service.dart';
import '../data/models/home_model.dart';
import '../../chores/presentation/pages/chores_ranking_page.dart';


// ... (imports remain the same)

// Remove constant colors that might clash
// const Color _greyText = Color(0xFF8B8E98); // Use generic grey or theme caption
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
    // Determine if in dark mode for manual overrides if needed
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_loading) {
       return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // [FIX] Dynamic background
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            _buildHeader(context), // Pass context for theme access
            const SizedBox(height: 16),
            Text(
              'Tổng quan của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            _buildSummaryCards(context),
            const SizedBox(height: 16),
            _buildTodayChores(context),
            const SizedBox(height: 16),
            _buildFinanceOverview(context),
            const SizedBox(height: 16),
            _buildRecentNews(context),
            const SizedBox(height: 20),
            _buildMonthlyStarButton(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    // Dynamic text color
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subtitleColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).cardColor, // [FIX] Dynamic bg
          child: Icon(Icons.person, size: 28, color: titleColor), // [FIX] Dynamic icon color
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào! 👋',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: titleColor),
              ),
              const SizedBox(height: 2),
              Text(
                'Chào mừng bạn đến với HousePal',
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: titleColor),
          onPressed: () =>
              Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  // ================= SUMMARY =================

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            context: context,
            icon: Icons.event_available_outlined,
            value: _summary!.todayChores.toString(),
            label: 'Việc hôm nay',
            onTap: () => Navigator.pushNamed(context, '/chores'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            context: context,
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
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final borderColor = Theme.of(context).dividerTheme.color ?? const Color(0xFFE3E5EA);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(_cardRadius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor, // [FIX] Dynamic background
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TODAY CHORES =================

  Widget _buildTodayChores(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Việc của bạn hôm nay',
          onViewAll: () => Navigator.pushNamed(context, '/chores'),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor, // [FIX] Dynamic
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Bạn có ${_summary!.todayChores} việc đang chờ',
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ),
      ],
    );
  }

  // ================= FINANCE =================

  Widget _buildFinanceOverview(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Tổng quan tài chính',
          onViewAll: () => Navigator.pushNamed(context, '/expenses'),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor, // [FIX] Dynamic
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              _financeCol(context, 'Bạn nợ', _summary!.debt, Colors.red),
              Container(width: 1, height: 40, color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE3E5EA)),
              const SizedBox(width: 16),
              _financeCol(
                context,
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

  Widget _financeCol(BuildContext context, String label, int value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
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

  Widget _buildRecentNews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
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
        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
           shape: MaterialStateProperty.all(RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(18),
           ))
        ) ?? ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
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
            Text('Người xuất sắc tháng này', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onViewAll}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
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
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final borderColor = Theme.of(context).dividerTheme.color ?? const Color(0xFFE3E5EA);
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    // For RichText inside, we need explicit colors
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
                    style: TextStyle(fontSize: 14, color: titleColor), // [FIX] Dynamic rich text color
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
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
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

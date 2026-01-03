import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../data/datasources/home_service.dart';
import '../data/models/home_model.dart';
import '../../chores/presentation/pages/chores_ranking_page.dart';
import '../../authentication/data/models/user_model.dart';


// ... (imports remain the same)



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeService = HomeService();

  HomeSummaryModel? _summary;
  List<HomeActivityModel> _activities = [];
  UserModel? _currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _homeService.getHomeSummary();
    final activities = await _homeService.getRecentActivities();
    final user = await _homeService.getCurrentUser();

    if (!mounted) return;
    setState(() {
      _summary = summary;
      _activities = activities;
      _currentUser = user;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 0),
      body: SafeArea(
        child: _currentUser?.role == 'admin' || _currentUser?.role == 'owner'
            ? _buildAdminHome(context)
            : _buildMemberInfoHome(context),
      ),
    );
  }


  Widget _buildAdminHome(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),

        Text(
          'Quản lý Nhà',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 16),
        _buildAdminGrid(context),
        const SizedBox(height: 24),
        Text(
          'Hoạt động gần đây',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 12),
        _buildRecentNews(context),
      ],
    );
  }

  Widget _buildAdminGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _adminCard(context, 'Thành viên', Icons.people_outline, Colors.blue,
            () => Navigator.pushNamed(context, '/members')),
        _adminCard(context, 'Duyệt việc', Icons.check_circle_outline, Colors.orange,
            () {}),
        _adminCard(context, 'Tài chính', Icons.attach_money, Colors.green,
            () => Navigator.pushNamed(context, '/expenses')),
        _adminCard(context, 'Cài đặt', Icons.settings_outlined, Colors.grey,
            () => Navigator.pushNamed(context, '/settings')),
      ],
    );
  }

  Widget _adminCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


  Widget _buildMemberInfoHome(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        _buildHeader(context),
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
    );
  }



  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                backgroundImage: _currentUser?.avatarUrl != null && _currentUser!.avatarUrl.isNotEmpty
                    ? NetworkImage(_currentUser!.avatarUrl)
                    : const AssetImage('lib/core/assets/avatars/meo3.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Xin chào, ${_currentUser?.name ?? "Bạn"}! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chào mừng bạn đến với HousePal',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ),
      ],
    );
  }



  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            context: context,
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF00D26A),
            value: _summary!.todayChores.length.toString(),
            label: 'Việc hôm nay',
            onTap: () => Navigator.pushNamed(context, '/chores'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _summaryCard(
            context: context,
            icon: Icons.star_border_rounded,
            iconColor: const Color(0xFF00D26A),
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
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E5EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTodayChores(BuildContext context) {
    if (_summary == null) return const SizedBox.shrink();
    
    final chores = _summary!.todayChores.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Việc của bạn hôm nay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/chores'),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D26A),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (chores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Bạn đã hoàn thành hết việc hôm nay!', style: TextStyle(color: Colors.grey)),
            )
          else
            ...chores.map((chore) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE3E5EA), width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chore.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          
          if (chores.isNotEmpty) ...[
             const SizedBox(height: 8),
             Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00D26A),
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                   const Text(
                      'Đổ rác',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9EA3AE),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFF9EA3AE),
                      ),
                    ),
                ],
             ),
          ]
        ],
      ),
    );
  }



  Widget _buildFinanceOverview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng quan tài chính',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/expenses'),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D26A),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _financeCol(context, 'Bạn nợ', _summary!.debt, const Color(0xFFFF3B30)),
              Container(width: 1, height: 40, color: const Color(0xFFE3E5EA)),
              const SizedBox(width: 24),
              _financeCol(
                context,
                'Nợ bạn',
                _summary!.credit,
                const Color(0xFF00D26A),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _financeCol(BuildContext context, String label, int value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                .format(value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildRecentNews(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bảng tin gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/bulletin_board'),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D26A),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          ..._activities.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ActivityItem(
                title: e.title,
                action: e.subtitle,
                time: DateFormat('dd/MM HH:mm').format(e.createdAt),
              ),
            ),
          ),
          if (_activities.isEmpty) ...[
             const _ActivityItem(
              title: 'Họp nhà khẩn cấp tối nay',
              action: 'bởi Admin',
              time: '1 giờ trước',
             ),
             const SizedBox(height: 16),
             const _ActivityItem(
              title: 'Nhắc nhở đóng tiền mạng tháng 12',
              action: 'bởi Admin',
              time: '1 ngày trước',
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildMonthlyStarButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF00D26A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
            color: const Color(0xFF00D26A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
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
              Icon(Icons.emoji_events_outlined, size: 24, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Người xuất sắc tháng này', 
                style: TextStyle(
                  fontWeight: FontWeight.w700, 
                  color: Colors.white,
                  fontSize: 16,
                )
              ),
            ],
          ),
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              children: [
                TextSpan(text: action),
                const TextSpan(text: ' • '),
                TextSpan(text: time),
              ]
            )
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF2F4F7)),
      ],
    );
  }
}

// Updated logic

// Minor optimization

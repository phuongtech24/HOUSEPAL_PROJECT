import 'package:flutter/material.dart';
import '../../data/datasources/chore_service.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';
import '../../../../core/constants/app_colors.dart';

class ChoresRankingPage extends StatefulWidget {
  const ChoresRankingPage({super.key});

  @override
  State<ChoresRankingPage> createState() => _ChoresRankingPageState();
}

class _ChoresRankingPageState extends State<ChoresRankingPage> {
  final _service = ChoreService();

  List<UserModel> _ranking = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    try {
      setState(() => _loading = true);
      final result = await _service.getMonthlyRanking();

      if (!mounted) return;
      setState(() {
        _ranking = result;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Ranking error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảng xếp hạng tháng'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ranking.isEmpty
              ? _buildEmpty()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTopUser(_ranking.first),
                    const SizedBox(height: 16),
                    ..._ranking
                        .skip(1)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RankingItem(
                              rank: e.key + 2,
                              user: e.value,
                            ),
                          ),
                        ),
                  ],
                ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'Chưa có dữ liệu xếp hạng',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildTopUser(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFF176)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? AssetImage(user.avatarUrl)
                : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hạng 1',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thành viên tích cực của tháng',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${user.currentPoints} điểm',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int rank;
  final UserModel user;

  const _RankingItem({
    required this.rank,
    required this.user,
  });

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
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? AssetImage(user.avatarUrl)
                : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.currentPoints} điểm',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
  int _selectedMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    try {
      setState(() => _loading = true);
      // Construct date based on selection
      final now = DateTime.now();
      final selectedDate = DateTime(now.year, now.month - _selectedMonthIndex);

      
      List<UserModel> result = [];
      if (_selectedMonthIndex == 0) {
         result = await _service.getMonthlyRanking();
      } else {
         result = []; 
      }

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
      backgroundColor: const Color(0xFFF5F7FA), // Light grey bg
      appBar: AppBar(
        title: const Text('Bảng xếp hạng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FA),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
           // 1. Month Selector Headers (Always visible)
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(3, (index) {
                  final now = DateTime.now();
                  final date = DateTime(now.year, now.month - index);
                  final label = 'Tháng ${date.month}/${date.year}';
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMonthIndex = index;
                        });
                        _loadRanking();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: _MonthChip(
                        text: label,
                        isSelected: _selectedMonthIndex == index,
                      ),
                    ),
                  );
                }),
              ),
                     ),
           ),
           
           Expanded(
             child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _ranking.isEmpty
                    ? _buildEmpty()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // 2. Featured Top 1 Card
                            if (_ranking.isNotEmpty)
                              _buildFeaturedTopCard(context, _ranking.first),
      
                            const SizedBox(height: 20),
      
                            // 3. Remaining List
                            if (_ranking.length > 1)
                              ..._ranking.skip(1).map((user) {
                                 final index = _ranking.indexOf(user);
                                 return Padding(
                                   padding: const EdgeInsets.only(bottom: 12),
                                   child: _RankingListItem(user: user, rank: index + 1),
                                 );
                              }),
                              
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
           ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedMonthIndex == 0 
                ? 'Chưa có phân hạng tháng này' 
                : 'Chưa có dữ liệu lịch sử', 
            style: const TextStyle(color: Colors.grey)
          ),
        ],
      )
    );
  }

  Widget _buildFeaturedTopCard(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Image / Gradient
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Background (Starry Night Theme)
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFF4527A0), Color(0xFF7B1FA2)], // Deep Purple to Purple
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // Decorative Stars (Simulated with Icons for now, replace with Image in prod)
                child: Stack(
                  children: const [
                     Positioned(top: 20, left: 30, child: Icon(Icons.star, color: Colors.white30, size: 16)),
                     Positioned(top: 50, right: 40, child: Icon(Icons.star, color: Colors.white24, size: 24)),
                     Positioned(bottom: 40, left: 80, child: Icon(Icons.star, color: Colors.white12, size: 12)),
                     Positioned(top: 30, right: 100, child: Icon(Icons.star, color: Colors.white38, size: 20)),
                  ],
                ),
              ),

              // 2. Avatar (Overlapping)
              Positioned(
                bottom: -40,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: user.avatarUrl.isNotEmpty
                            ? AssetImage(user.avatarUrl)
                            : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
                      ),
                    ),
                    // Rank Badge
                    Container(
                       padding: const EdgeInsets.all(6),
                       decoration: const BoxDecoration(
                         color: Color(0xFFFFD700), // Gold
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 50), // Space for avatar

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                const Text('Hạng 1', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${user.name} (Bạn)', // Adding "(Bạn)" as per design, logic can clarify if it is indeed 'me' later
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Thành viên Tích cực của Tháng',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.currentPoints} điểm',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E676), // Bright Green
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

class _MonthChip extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _MonthChip({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE0F2F1) : const Color(0xFFEEEEEE), // Light Green or Grey background
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.black, size: 20),
          ]
        ],
      ),
    );
  }
}

class _RankingListItem extends StatelessWidget {
  final UserModel user;
  final int rank;

  const _RankingListItem({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    // Rank styling: 2 (Silver), 3 (Bronze), others Grey
    final rankColor = rank == 2 
        ? const Color(0xFFC0C0C0) 
        : rank == 3 
            ? const Color(0xFFCD7F32) 
            : const Color(0xFF757575);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Rank text
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: rankColor.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          
          CircleAvatar(
             radius: 24,
             backgroundImage: user.avatarUrl.isNotEmpty
                ? AssetImage(user.avatarUrl)
                : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          Text(
            '${user.currentPoints} điểm',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}



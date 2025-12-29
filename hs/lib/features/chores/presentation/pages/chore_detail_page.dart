import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/chore_model.dart';
import '../../../authentication/data/models/user_model.dart';
import '../widgets/chore_widgets.dart';
import '../../data/datasources/chore_service.dart';

class ChoreDetailPage extends StatefulWidget {
  final ChoreModel chore;

  const ChoreDetailPage({
    super.key,
    required this.chore,
  });

  @override
  State<ChoreDetailPage> createState() => _ChoreDetailPageState();
}

class _ChoreDetailPageState extends State<ChoreDetailPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _choreService = ChoreService();

  Map<String, UserModel> _userMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHouseMembers();
  }

  Future<void> _loadHouseMembers() async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final houseId = userDoc['houseId'];

    _firestore
        .collection('users')
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .listen((snapshot) {
      final map = <String, UserModel>{};
      for (final doc in snapshot.docs) {
        final user = UserModel.fromMap(doc.data());
        map[user.uid] = user;
      }

      setState(() {
        _userMap = map;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final chore = widget.chore;
    final currentUserUid = _auth.currentUser!.uid;

    final bool isCompleted = chore.status == 'completed';
    final bool isMyTurn = chore.currentGroupId == currentUserUid;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIndex =
        chore.groupOrder.indexOf(chore.currentGroupId);

    final String currentUid = chore.currentGroupId;
    final String? prevUid =
        currentIndex > 0 ? chore.groupOrder[currentIndex - 1] : null;
    final String? nextUid =
        currentIndex < chore.groupOrder.length - 1
            ? chore.groupOrder[currentIndex + 1]
            : null;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chi tiết việc nhà',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _MainHeader(chore: chore),
          const SizedBox(height: 16),

          /// ===== ROTATION =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chu kỳ xoay vòng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prevUid != null && _userMap[prevUid] != null)
                      _RotationAvatar(
                        user: _userMap[prevUid]!,
                        label: 'Trước đó',
                        highlight: false,
                      ),
                    _RotationAvatar(
                      user: _userMap[currentUid]!,
                      label: 'Lượt hiện tại',
                      highlight: true,
                    ),
                    if (nextUid != null && _userMap[nextUid] != null)
                      _RotationAvatar(
                        user: _userMap[nextUid]!,
                        label: 'Tiếp theo',
                        highlight: false,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _InfoRow(
            icon: Icons.schedule,
            title: 'Thời gian đề xuất',
            value: '09:00 - 18:00',
          ),
          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.calendar_month,
            title: 'Hạn chót & tần suất',
            value: '28 Thg 11, 2025 · Hàng tháng',
          ),
          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.description,
            title: 'Mô tả',
            value:
                chore.description.isEmpty ? 'Không có mô tả' : chore.description,
          ),
        ],
      ),

      /// ===== BOTTOM ACTION =====
      bottomNavigationBar: _buildBottomAction(
        isMyTurn: isMyTurn,
        isCompleted: isCompleted,
        chore: chore,
        currentUid: currentUid,
      ),
    );
  }

  Widget? _buildBottomAction({
    required bool isMyTurn,
    required bool isCompleted,
    required ChoreModel chore,
    required String currentUid,
  }) {
    if (isCompleted) return null;

    if (isMyTurn) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                await _choreService.completeChore(chore);
                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Hoàn thành việc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              await _choreService.sendReminder(
                toUid: currentUid,
                choreId: chore.id,
                choreTitle: chore.title,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi nhắc nhở')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            label: Text(
              'Nhắc ${_userMap[currentUid]!.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= HEADER ================= */

class _MainHeader extends StatelessWidget {
  final ChoreModel chore;

  const _MainHeader({required this.chore});

  @override
  Widget build(BuildContext context) {
    final done = chore.status == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.cleaning_services, color: kPrimaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chore.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Chip(
                      text: done ? 'Đã hoàn thành' : 'Đến hạn hôm nay',
                      color: done
                          ? const Color(0xFFE5F8ED)
                          : const Color(0xFFFFEEE8),
                      textColor:
                          done ? kPrimaryGreen : Colors.deepOrange,
                      icon: done ? Icons.check : Icons.warning_amber_rounded,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      text: '+${chore.points} điểm',
                      color: const Color(0xFFE5F8ED),
                      textColor: kPrimaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= SMALL WIDGETS ================= */

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const _Chip({
    required this.text,
    required this.color,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationAvatar extends StatelessWidget {
  final UserModel user;
  final String label;
  final bool highlight;

  const _RotationAvatar({
    required this.user,
    required this.label,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: highlight ? 32 : 22,
            backgroundColor:
                highlight ? kPrimaryGreen : Colors.grey.shade300,
            child: CircleAvatar(
              radius: highlight ? 28 : 18,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? AssetImage(user.avatarUrl)
                  : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
            ),
          ),
          const SizedBox(height: 6),
          if (highlight)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: kPrimaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Lượt hiện tại',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            user.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (highlight)
            const Text(
              'Chưa hoàn thành',
              style: TextStyle(fontSize: 12, color: Colors.deepOrange),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kGreyText)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
